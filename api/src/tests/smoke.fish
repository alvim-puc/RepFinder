#!/usr/bin/env fish
# RepFinder — smoke test
# Uso: fish smoke.fish [base_url]

set BASE (if test (count $argv) -gt 0; echo $argv[1]; else; echo "http://localhost:3030"; end)
set API $BASE/api
set PASS 0
set FAIL 0
set TMPBODY /tmp/rf_resp_body.json

function ok;   set -g PASS (math $PASS + 1); echo "  ✔ $argv"; end
function fail; set -g FAIL (math $FAIL + 1); echo "  ✘ $argv"; end
function section; echo ""; echo "── $argv"; end

function assert_status
    if test "$argv[2]" = "$argv[3]"
        ok "$argv[1] → $argv[2]"
    else
        fail "$argv[1] → esperado $argv[3], recebeu $argv[2]"
    end
end

function assert_field
    set val (python3 -c "
import json
d=json.load(open('$TMPBODY'))
v=d.get('$argv[2]')
print(v if v is not None else '')
" 2>/dev/null)
    if test -z "$val"
        fail "$argv[1] → campo '$argv[2]' ausente"
    else
        ok "$argv[1] → $argv[2] presente"
    end
end

function assert_value
    if test "$argv[2]" = "$argv[3]"
        ok "$argv[1] → '$argv[2]'"
    else
        fail "$argv[1] → esperado '$argv[3]', recebeu '$argv[2]'"
    end
end

function jget
    python3 -c "
import json
d=json.load(open('$TMPBODY'))
print(d.get('$argv[1]') or '')
" 2>/dev/null
end

# GET <url> [token]
function GET
    if test (count $argv) -ge 2
        curl -s -o $TMPBODY -w "%{http_code}" \
            -H "Authorization: Bearer $argv[2]" \
            "$argv[1]"
    else
        curl -s -o $TMPBODY -w "%{http_code}" "$argv[1]"
    end
end

# POST <url> <body> [token]
function POST
    if test (count $argv) -ge 3
        curl -s -o $TMPBODY -w "%{http_code}" \
            -X POST \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $argv[3]" \
            -d "$argv[2]" \
            "$argv[1]"
    else
        curl -s -o $TMPBODY -w "%{http_code}" \
            -X POST \
            -H "Content-Type: application/json" \
            -d "$argv[2]" \
            "$argv[1]"
    end
end

# PATCH <url> <body> [token]
function PATCH
    if test (count $argv) -ge 3
        curl -s -o $TMPBODY -w "%{http_code}" \
            -X PATCH \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $argv[3]" \
            -d "$argv[2]" \
            "$argv[1]"
    else
        curl -s -o $TMPBODY -w "%{http_code}" \
            -X PATCH \
            -H "Content-Type: application/json" \
            -d "$argv[2]" \
            "$argv[1]"
    end
end

# DELETE <url> [token]
function DELETE
    if test (count $argv) -ge 2
        curl -s -o $TMPBODY -w "%{http_code}" \
            -X DELETE \
            -H "Authorization: Bearer $argv[2]" \
            "$argv[1]"
    else
        curl -s -o $TMPBODY -w "%{http_code}" \
            -X DELETE "$argv[1]"
    end
end

# ── health check
section "health check"
set s (GET $API)
assert_status "GET /api" $s 200

# ── validações de entrada
section "validações — campos obrigatórios"
set s (POST $API/users/register "{}")
assert_status "register sem body" $s 400

set s (POST $API/users/register '{"email":"a@a.com","name":"A","password":"123456"}')
assert_status "register sem role" $s 400

set s (POST $API/users/register '{"email":"a@a.com","name":"A","password":"123","role":"student"}')
assert_status "register senha curta" $s 400

set s (POST $API/users/login "{}")
assert_status "login sem body" $s 400

# ── rotas protegidas sem token
section "autenticação — rotas protegidas sem token"
set s (GET $API/users/me)
assert_status "GET /users/me sem token" $s 401

set s (GET $API/vacancies/mine)
assert_status "GET /vacancies/mine sem token" $s 401

set s (GET $API/applications/mine)
assert_status "GET /applications/mine sem token" $s 401

# ── registro
section "registro de usuários"
set s (POST $API/users/register '{"email":"rep@repfinder.com","name":"Ana Representante","password":"senha123","role":"representative"}')
assert_status "register representante" $s 201
assert_field  "representante tem token" token
set rep_token (jget token)

set s (POST $API/users/register '{"email":"student@repfinder.com","name":"Bruno Estudante","password":"senha123","role":"student"}')
assert_status "register estudante" $s 201
set stu_token (jget token)

set s (POST $API/users/register '{"email":"rep@repfinder.com","name":"X","password":"senha123","role":"representative"}')
assert_status "register email duplicado → 409" $s 409

# ── login
section "login"
set s (POST $API/users/login '{"email":"rep@repfinder.com","password":"senha123"}')
assert_status "login representante" $s 200
assert_field  "login retorna token" token

set s (POST $API/users/login '{"email":"rep@repfinder.com","password":"errada"}')
assert_status "login senha errada → 401" $s 401

set s (POST $API/users/login '{"email":"naoexiste@x.com","password":"senha123"}')
assert_status "login email inexistente → 401" $s 401

# ── perfil
section "perfil do usuário autenticado"
set s (GET $API/users/me $rep_token)
assert_status "GET /users/me" $s 200
assert_field  "me retorna email" email
assert_field  "me retorna role" role
assert_value  "role é representative" (jget role) "representative"

set s (PATCH $API/users/me '{"name":"Ana Rep Atualizada"}' $rep_token)
assert_status "PATCH /users/me" $s 200

set s (PATCH $API/users/me '{"email":"student@repfinder.com"}' $rep_token)
assert_status "PATCH /users/me email já em uso → 409" $s 409

# ── vagas: criação e listagem
section "vagas — criação e listagem"
set s (POST $API/vacancies '{"title":"Vaga X","description":"Desc"}')
assert_status "POST /vacancies sem token → 401" $s 401

set s (POST $API/vacancies '{"title":"Vaga X","description":"Desc"}' $stu_token)
assert_status "estudante não pode criar vaga → 403" $s 403

set s (POST $API/vacancies '{"title":"Quarto disponível centro","description":"República masculina, quarto individual, R$600"}' $rep_token)
assert_status "POST /vacancies (representante)" $s 201
assert_field  "vaga tem id" id
set vacancy_id (jget id)

set s (GET $API/vacancies)
assert_status "GET /vacancies público" $s 200

set s (GET $API/vacancies/$vacancy_id)
assert_status "GET /vacancies/:id" $s 200

set s (GET $API/vacancies/mine $rep_token)
assert_status "GET /vacancies/mine" $s 200

set s (GET $API/vacancies/id-que-nao-existe)
assert_status "GET /vacancies/id-inexistente → 404" $s 404

# ── vagas: edição
section "vagas — edição"
set s (PATCH $API/vacancies/$vacancy_id '{"title":"Título atualizado"}' $rep_token)
assert_status "PATCH /vacancies/:id (dono)" $s 200
assert_value  "título foi atualizado" (jget title) "Título atualizado"

set s (PATCH $API/vacancies/$vacancy_id '{"title":"Invasão"}' $stu_token)
assert_status "PATCH /vacancies/:id (não dono) → 403" $s 403

# ── aplicações: criação
section "aplicações — criação"
set s (POST $API/applications "{\"vacancyId\":\"$vacancy_id\"}" $stu_token)
assert_status "POST /applications (estudante)" $s 201
assert_field  "aplicação tem id" id
assert_value  "status inicial é pending" (jget status) "pending"
set app_id (jget id)

set s (POST $API/applications "{\"vacancyId\":\"$vacancy_id\"}" $stu_token)
assert_status "aplicação duplicada → 409" $s 409

set s (POST $API/applications '{"vacancyId":"id-inexistente"}' $stu_token)
assert_status "aplicação para vaga inexistente → 404" $s 404

# ── aplicações: listagem
section "aplicações — listagem"
set s (GET $API/applications/mine $stu_token)
assert_status "GET /applications/mine (estudante)" $s 200

set s (GET $API/applications/vacancies/$vacancy_id $rep_token)
assert_status "GET /applications/vacancies/:id (dono)" $s 200

set s (GET $API/applications/vacancies/$vacancy_id $stu_token)
assert_status "GET /applications/vacancies/:id (não dono) → 403" $s 403

# ── aplicações: status
section "aplicações — status"
set s (PATCH $API/applications/$app_id/status '{"status":"accepted"}' $stu_token)
assert_status "estudante não pode alterar status → 403" $s 403

set s (PATCH $API/applications/$app_id/status '{"status":"accepted"}' $rep_token)
assert_status "PATCH status → accepted" $s 200
assert_value  "status é accepted" (jget status) "accepted"

set s (PATCH $API/applications/$app_id/status '{"status":"rejected"}' $rep_token)
assert_status "alterar após status final → 409" $s 409

set s (PATCH $API/applications/$app_id/status '{"status":"invalido"}' $rep_token)
assert_status "status inválido → 400" $s 400

# ── aplicações: deleção
section "aplicações — deleção"
set s (POST $API/users/register '{"email":"carol@repfinder.com","name":"Carol","password":"senha123","role":"student"}')
assert_status "register Carol" $s 201
set carol_token (jget token)

set s (POST $API/applications "{\"vacancyId\":\"$vacancy_id\"}" $carol_token)
assert_status "Carol aplica para vaga" $s 201
set carol_app_id (jget id)

set s (DELETE $API/applications/$carol_app_id $stu_token)
assert_status "DELETE aplicação de outro → 403" $s 403

set s (DELETE $API/applications/$app_id $stu_token)
assert_status "DELETE aplicação aceita → 409" $s 409

set s (DELETE $API/applications/$carol_app_id $carol_token)
assert_status "DELETE aplicação pending (dono) → 200" $s 200

# ── vagas: deleção
section "vagas — deleção"
set s (DELETE $API/vacancies/$vacancy_id $rep_token)
assert_status "DELETE vaga com aplicações → 409" $s 409

set s (POST $API/vacancies '{"title":"Vaga temporária","description":"Sem candidatos"}' $rep_token)
set tmp_id (jget id)

set s (DELETE $API/vacancies/$tmp_id $stu_token)
assert_status "DELETE vaga (não dono) → 403" $s 403

set s (DELETE $API/vacancies/$tmp_id $rep_token)
assert_status "DELETE vaga sem aplicações → 200" $s 200

# ── resultado
echo ""
echo "────────────────────────────────"
set TOTAL (math $PASS + $FAIL)
echo "  total:   $TOTAL"
echo "  passou:  $PASS"
echo "  falhou:  $FAIL"
echo "────────────────────────────────"
if test $FAIL -gt 0; exit 1; end
