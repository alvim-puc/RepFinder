#!/usr/bin/env bash
# RepFinder — smoke test (Bash version)
# Uso: bash smoke.sh [base_url]

BASE="${1:-http://localhost:3030}"
API="$BASE/api"
PASS=0
FAIL=0
TMPBODY="/tmp/rf_resp_body.json"

# Cores para o terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

ok( ) {
  PASS=$((PASS + 1))
  printf "  ${GREEN}✔${RESET} %s\n" "$*"
}

fail() {
  FAIL=$((FAIL + 1))
  printf "  ${RED}✘${RESET} %s\n" "$*"
}

section() {
  printf "\n${BOLD}── %s${RESET}\n" "$*"
}

assert_status() {
  local label="$1"
  local actual="$2"
  local expected="$3"

  if [ "$actual" = "$expected" ]; then
    ok "$label → $actual"
  else
    fail "$label → esperado $expected, recebeu $actual"
  fi
}

assert_field() {
  local label="$1"
  local field="$2"

  local val=$(python3 -c "
import json
try:
    d=json.load(open('$TMPBODY'))
    v=d.get('$field')
    print(v if v is not None else '')
except:
    print('')
" 2>/dev/null)

  if [ -z "$val" ]; then
    fail "$label → campo '$field' ausente"
  else
    ok "$label → $field presente"
  fi
}

assert_value() {
  local label="$1"
  local actual="$2"
  local expected="$3"

  if [ "$actual" = "$expected" ]; then
    ok "$label → '$actual'"
  else
    fail "$label → esperado '$expected', recebeu '$actual'"
  fi
}

jget() {
  local field="$1"
  python3 -c "
import json
try:
    d=json.load(open('$TMPBODY'))
    print(d.get('$field') or '')
except:
    print('')
" 2>/dev/null
}

# GET <url> [token]
GET() {
  if [ $# -ge 2 ]; then
    curl -s -o "$TMPBODY" -w "%{http_code}" \
      -H "Authorization: Bearer $2" \
      "$1"
  else
    curl -s -o "$TMPBODY" -w "%{http_code}" "$1"
  fi
}

# POST <url> <body> [token]
POST( ) {
  if [ $# -ge 3 ]; then
    curl -s -o "$TMPBODY" -w "%{http_code}" \
      -X POST \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $3" \
      -d "$2" \
      "$1"
  else
    curl -s -o "$TMPBODY" -w "%{http_code}" \
      -X POST \
      -H "Content-Type: application/json" \
      -d "$2" \
      "$1"
  fi
}

# PATCH <url> <body> [token]
PATCH( ) {
  if [ $# -ge 3 ]; then
    curl -s -o "$TMPBODY" -w "%{http_code}" \
      -X PATCH \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $3" \
      -d "$2" \
      "$1"
  else
    curl -s -o "$TMPBODY" -w "%{http_code}" \
      -X PATCH \
      -H "Content-Type: application/json" \
      -d "$2" \
      "$1"
  fi
}

# DELETE <url> [token]
DELETE( ) {
  if [ $# -ge 2 ]; then
    curl -s -o "$TMPBODY" -w "%{http_code}" \
      -X DELETE \
      -H "Authorization: Bearer $2" \
      "$1"
  else
    curl -s -o "$TMPBODY" -w "%{http_code}" \
      -X DELETE "$1"
  fi
}

# ── health check
section "health check"
s=$(GET "$API" )
assert_status "GET /api" "$s" 200

# ── validações de entrada
section "validações — campos obrigatórios"
s=$(POST "$API/users/register" "{}")
assert_status "register sem body" "$s" 400

s=$(POST "$API/users/register" '{"email":"a@a.com","name":"A","password":"123456"}')
assert_status "register sem role" "$s" 400

s=$(POST "$API/users/register" '{"email":"a@a.com","name":"A","password":"123","role":"student"}')
assert_status "register senha curta" "$s" 400

s=$(POST "$API/users/login" "{}")
assert_status "login sem body" "$s" 400

# ── rotas protegidas sem token
section "autenticação — rotas protegidas sem token"
s=$(GET "$API/users/me")
assert_status "GET /users/me sem token" "$s" 401

s=$(GET "$API/vacancies/mine")
assert_status "GET /vacancies/mine sem token" "$s" 401

s=$(GET "$API/applications/mine")
assert_status "GET /applications/mine sem token" "$s" 401

# ── registro
section "registro de usuários"
s=$(POST "$API/users/register" '{"email":"rep@repfinder.com","name":"Ana Representante","password":"senha123","role":"representative"}')
assert_status "register representante" "$s" 201
assert_field  "representante tem token" "token"
rep_token=$(jget "token")

s=$(POST "$API/users/register" '{"email":"student@repfinder.com","name":"Bruno Estudante","password":"senha123","role":"student"}')
assert_status "register estudante" "$s" 201
stu_token=$(jget "token")

s=$(POST "$API/users/register" '{"email":"rep@repfinder.com","name":"X","password":"senha123","role":"representative"}')
assert_status "register email duplicado → 409" "$s" 409

# ── login
section "login"
s=$(POST "$API/users/login" '{"email":"rep@repfinder.com","password":"senha123"}')
assert_status "login representante" "$s" 200
assert_field  "login retorna token" "token"

s=$(POST "$API/users/login" '{"email":"rep@repfinder.com","password":"errada"}')
assert_status "login senha errada → 401" "$s" 401

s=$(POST "$API/users/login" '{"email":"naoexiste@x.com","password":"senha123"}')
assert_status "login email inexistente → 401" "$s" 401

# ── perfil
section "perfil do usuário autenticado"
s=$(GET "$API/users/me" "$rep_token")
assert_status "GET /users/me" "$s" 200
assert_field  "me retorna email" "email"
assert_field  "me retorna role" "role"
assert_value  "role é representative" "$(jget role)" "representative"

s=$(PATCH "$API/users/me" '{"name":"Ana Rep Atualizada"}' "$rep_token")
assert_status "PATCH /users/me" "$s" 200

s=$(PATCH "$API/users/me" '{"email":"student@repfinder.com"}' "$rep_token")
assert_status "PATCH /users/me email já em uso → 409" "$s" 409

# ── vagas: criação e listagem
section "vagas — criação e listagem"
s=$(POST "$API/vacancies" '{"title":"Vaga X","description":"Desc"}')
assert_status "POST /vacancies sem token → 401" "$s" 401

s=$(POST "$API/vacancies" '{"title":"Vaga X","description":"Desc"}' "$stu_token")
assert_status "estudante não pode criar vaga → 403" "$s" 403

s=$(POST "$API/vacancies" '{"title":"Quarto disponível centro","description":"República masculina, quarto individual, R$600"}' "$rep_token")
assert_status "POST /vacancies (representante)" "$s" 201
assert_field  "vaga tem id" "id"
vacancy_id=$(jget "id")

s=$(GET "$API/vacancies")
assert_status "GET /vacancies público" "$s" 200

s=$(GET "$API/vacancies/$vacancy_id")
assert_status "GET /vacancies/:id" "$s" 200

s=$(GET "$API/vacancies/mine" "$rep_token")
assert_status "GET /vacancies/mine" "$s" 200

s=$(GET "$API/vacancies/id-que-nao-existe")
assert_status "GET /vacancies/id-inexistente → 404" "$s" 404

# ── vagas: edição
section "vagas — edição"
s=$(PATCH "$API/vacancies/$vacancy_id" '{"title":"Título atualizado"}' "$rep_token")
assert_status "PATCH /vacancies/:id (dono)" "$s" 200
assert_value  "título foi atualizado" "$(jget title)" "Título atualizado"

s=$(PATCH "$API/vacancies/$vacancy_id" '{"title":"Invasão"}' "$stu_token")
assert_status "PATCH /vacancies/:id (não dono) → 403" "$s" 403

# ── aplicações: criação
section "aplicações — criação"
s=$(POST "$API/applications" "{\"vacancyId\":\"$vacancy_id\"}" "$stu_token")
assert_status "POST /applications (estudante)" "$s" 201
assert_field  "aplicação tem id" "id"
assert_value  "status inicial é pending" "$(jget status)" "pending"
app_id=$(jget "id")

s=$(POST "$API/applications" "{\"vacancyId\":\"$vacancy_id\"}" "$stu_token")
assert_status "aplicação duplicada → 409" "$s" 409

s=$(POST "$API/applications" '{"vacancyId":"id-inexistente"}' "$stu_token")
assert_status "aplicação para vaga inexistente → 404" "$s" 404

# ── aplicações: listagem
section "aplicações — listagem"
s=$(GET "$API/applications/mine" "$stu_token")
assert_status "GET /applications/mine (estudante)" "$s" 200

s=$(GET "$API/applications/vacancies/$vacancy_id" "$rep_token")
assert_status "GET /applications/vacancies/:id (dono)" "$s" 200

s=$(GET "$API/applications/vacancies/$vacancy_id" "$stu_token")
assert_status "GET /applications/vacancies/:id (não dono) → 403" "$s" 403

# ── aplicações: status
section "aplicações — status"
s=$(PATCH "$API/applications/$app_id/status" '{"status":"accepted"}' "$stu_token")
assert_status "estudante não pode alterar status → 403" "$s" 403

s=$(PATCH "$API/applications/$app_id/status" '{"status":"accepted"}' "$rep_token")
assert_status "PATCH status → accepted" "$s" 200
assert_value  "status é accepted" "$(jget status)" "accepted"

s=$(PATCH "$API/applications/$app_id/status" '{"status":"rejected"}' "$rep_token")
assert_status "alterar após status final → 409" "$s" 409

s=$(PATCH "$API/applications/$app_id/status" '{"status":"invalido"}' "$rep_token")
assert_status "status inválido → 400" "$s" 400

# ── aplicações: deleção
section "aplicações — deleção"
s=$(POST "$API/users/register" '{"email":"carol@repfinder.com","name":"Carol","password":"senha123","role":"student"}')
assert_status "register Carol" "$s" 201
carol_token=$(jget "token")

s=$(POST "$API/applications" "{\"vacancyId\":\"$vacancy_id\"}" "$carol_token")
assert_status "Carol aplica para vaga" "$s" 201
carol_app_id=$(jget "id")

s=$(DELETE "$API/applications/$carol_app_id" "$stu_token")
assert_status "DELETE aplicação de outro → 403" "$s" 403

s=$(DELETE "$API/applications/$app_id" "$stu_token")
assert_status "DELETE aplicação aceita → 409" "$s" 409

s=$(DELETE "$API/applications/$carol_app_id" "$carol_token")
assert_status "DELETE aplicação pending (dono) → 200" "$s" 200

# ── vagas: deleção
section "vagas — deleção"
s=$(DELETE "$API/vacancies/$vacancy_id" "$rep_token")
assert_status "DELETE vaga com aplicações → 409" "$s" 409

s=$(POST "$API/vacancies" '{"title":"Vaga temporária","description":"Sem candidatos"}' "$rep_token")
tmp_id=$(jget "id")

s=$(DELETE "$API/vacancies/$tmp_id" "$stu_token")
assert_status "DELETE vaga (não dono) → 403" "$s" 403

s=$(DELETE "$API/vacancies/$tmp_id" "$rep_token")
assert_status "DELETE vaga sem aplicações → 200" "$s" 200

# ── resultado
printf "\n────────────────────────────────\n"
TOTAL=$((PASS + FAIL))
printf "  total:   %s\n" "$TOTAL"
printf "  passou:  %s\n" "$PASS"
printf "  falhou:  %s\n" "$FAIL"
printf "────────────────────────────────\n"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
