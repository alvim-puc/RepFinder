#!/usr/bin/env bash
# RepFinder — smoke test (notifications persistence)
# Uso: bash smoke_notifications.sh [base_url]

BASE="${1:-http://localhost:3030}"
API="$BASE/api"
PASS=0
FAIL=0
TMPBODY="/tmp/rf_notif_body.json"

GREEN=$'\e[32m'
RED=$'\e[31m'
BOLD=$'\e[1m'
DIM=$'\e[2m'
RESET=$'\e[0m'

ok() {
  PASS=$((PASS + 1))
  printf "  %s✔%s %s\n" "$GREEN" "$RESET" "$*"
}

fail() {
  FAIL=$((FAIL + 1))
  printf "  %s✘%s %s\n" "$RED" "$RESET" "$*"
}

section() {
  printf "\n%s── %s%s\n" "$BOLD" "$*" "$RESET"
}

assert_status() {
  local label="$1"
  local actual="$2"
  local expected="$3"

  if [[ "$actual" == "$expected" ]]; then
    ok "$label → $actual"
  else
    fail "$label → esperado $expected, recebeu $actual"
  fi
}

assert_value() {
  local label="$1"
  local actual="$2"
  local expected="$3"

  if [[ "$actual" == "$expected" ]]; then
    ok "$label → '$actual'"
  else
    fail "$label → esperado '$expected', recebeu '$actual'"
  fi
}

jget() {
  python3 - "$TMPBODY" "$1" <<'PY' 2>/dev/null
import json
import sys

data = json.load(open(sys.argv[1]))
print(data.get(sys.argv[2]) or '')
PY
}

# extrai campo de um item de lista pelo índice
# jlist_get <index> <field>
jlist_get() {
  python3 - "$TMPBODY" "$1" "$2" <<'PY' 2>/dev/null
import json
import sys

data = json.load(open(sys.argv[1]))
idx = int(sys.argv[2])
field = sys.argv[3]
if isinstance(data, list) and len(data) > idx:
    item = data[idx]
    val = item.get(field)
    if isinstance(val, dict):
        print(json.dumps(val))
    else:
        print(val if val is not None else '')
else:
    print('')
PY
}

jlist_len() {
  python3 - "$TMPBODY" <<'PY' 2>/dev/null
import json
import sys

data = json.load(open(sys.argv[1]))
print(len(data) if isinstance(data, list) else 0)
PY
}

GET() {
  if [[ $# -ge 2 ]]; then
    curl -s -o "$TMPBODY" -w "%{http_code}" \
      -H "Authorization: Bearer $2" \
      "$1"
  else
    curl -s -o "$TMPBODY" -w "%{http_code}" "$1"
  fi
}

POST() {
  if [[ $# -ge 3 ]]; then
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

PATCH() {
  curl -s -o "$TMPBODY" -w "%{http_code}" \
    -X PATCH \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $3" \
    -d "$2" \
    "$1"
}

# ── setup
section "setup — criar usuários e vaga"

s=$(POST "$API/users/register" '{"email":"rep_notif@repfinder.com","name":"Rep Notif","password":"senha123","role":"representative"}')
assert_status "register representante" "$s" 201
rep_token=$(jget token)

s=$(POST "$API/users/register" '{"email":"stu_notif@repfinder.com","name":"Stu Notif","password":"senha123","role":"student"}')
assert_status "register estudante" "$s" 201
stu_token=$(jget token)

s=$(POST "$API/vacancies" '{"title":"Vaga Notif Test","description":"Teste notificações"}' "$rep_token")
assert_status "criar vaga" "$s" 201
vacancy_id=$(jget id)

# ── application.created → notificação para representante
section "application.created → notificação persistida para representante"

s=$(POST "$API/applications" "{\"vacancyId\":\"$vacancy_id\"}" "$stu_token")
assert_status "estudante aplica" "$s" 201
app_id=$(jget id)

# aguarda processamento do evento pelo subscriber
sleep 1

s=$(GET "$API/notifications" "$rep_token")
assert_status "GET /notifications (representante)" "$s" 200

notif_count=$(jlist_len)
if [[ "$notif_count" -ge 1 ]]; then
  ok "representante tem $notif_count notificação(ões)"
else
  fail "nenhuma notificação encontrada para representante"
  exit 1
fi

notif_id=$(jlist_get 0 id)
notif_event=$(jlist_get 0 event)
notif_readed=$(jlist_get 0 readed_at)

# extrai applicationId do campo data (objeto aninhado)
notif_appid=$(python3 - "$TMPBODY" <<'PY' 2>/dev/null
import json
import sys

data = json.load(open(sys.argv[1]))
d = data[0].get('data', {}) if data else {}
if isinstance(d, str):
    d = json.loads(d)
print(d.get('applicationId', ''))
PY
)

assert_value "evento é application.created" "$notif_event" "application.created"
assert_value "applicationId na notificação bate" "$notif_appid" "$app_id"

if [[ -z "$notif_readed" || "$notif_readed" == "None" || "$notif_readed" == "null" ]]; then
  ok "readed_at inicial está vazio (não lida)"
else
  fail "readed_at deveria estar vazio, recebeu '$notif_readed'"
fi

# ── autenticação: estudante não vê notificações do representante
section "isolamento — estudante não vê notificações do representante"

s=$(GET "$API/notifications" "$stu_token")
assert_status "GET /notifications (estudante antes de aceite)" "$s" 200

stu_count=$(jlist_len)
assert_value "estudante não tem notificações ainda" "$stu_count" "0"

# ── mark as read
section "PATCH /:id/read — marcar como lida"

s=$(PATCH "$API/notifications/$notif_id/read" '{}' "$rep_token")
assert_status "PATCH /notifications/:id/read" "$s" 200

updated_readed=$(jget readed_at)
if [[ -n "$updated_readed" && "$updated_readed" != "null" ]]; then
  ok "readed_at preenchido após mark read → '$updated_readed'"
else
  fail "readed_at deveria estar preenchido após mark read"
fi

# confirma via GET que persiste
s=$(GET "$API/notifications" "$rep_token")
assert_status "GET /notifications após mark read" "$s" 200

readed_persisted=$(python3 - "$TMPBODY" <<'PY' 2>/dev/null
import json
import sys

data = json.load(open(sys.argv[1]))
print(data[0].get('readed_at') or '')
PY
)

if [[ -n "$readed_persisted" && "$readed_persisted" != "null" ]]; then
  ok "readed_at persistido no banco → '$readed_persisted'"
else
  fail "readed_at não persistido no banco"
fi

# ── mark read de notificação de outro usuário deve falhar
section "autorização — não pode marcar notificação de outro usuário"

s=$(PATCH "$API/notifications/$notif_id/read" '{}' "$stu_token")
assert_status "estudante não pode marcar notificação do representante → 404" "$s" 404

# ── application.status.updated → notificação para estudante
section "application.status.updated → notificação persistida para estudante"

s=$(PATCH "$API/applications/$app_id/status" '{"status":"accepted"}' "$rep_token")
assert_status "representante aceita aplicação" "$s" 200

sleep 1

s=$(GET "$API/notifications" "$stu_token")
assert_status "GET /notifications (estudante após aceite)" "$s" 200

stu_count_after=$(jlist_len)
if [[ "$stu_count_after" -ge 1 ]]; then
  ok "estudante tem $stu_count_after notificação(ões)"
else
  fail "nenhuma notificação encontrada para estudante"
  exit 1
fi

stu_evt=$(jlist_get 0 event)
stu_status=$(python3 - "$TMPBODY" <<'PY' 2>/dev/null
import json
import sys

data = json.load(open(sys.argv[1]))
d = data[0].get('data', {}) if data else {}
if isinstance(d, str):
    d = json.loads(d)
print(d.get('status', ''))
PY
)

assert_value "evento é application.status.updated" "$stu_evt" "application.status.updated"
assert_value "status no evento é accepted" "$stu_status" "accepted"

# ── autenticação básica
section "autenticação — rotas protegidas"

s=$(GET "$API/notifications")
assert_status "GET /notifications sem token → 401" "$s" 401

s=$(PATCH "$API/notifications/$notif_id/read" '{}')
assert_status "PATCH /notifications/:id/read sem token → 401" "$s" 401

# ── resultado
printf "\n%s────────────────────────────────%s\n" "$BOLD" "$RESET"
TOTAL=$((PASS + FAIL))
printf "  total:   %s\n" "$TOTAL"
printf "  %s passou:  %s%s\n" "$GREEN" "$PASS" "$RESET"
if [[ "$FAIL" -gt 0 ]]; then
  printf "  %s falhou:  %s%s\n" "$RED" "$FAIL" "$RESET"
else
  printf "  falhou:  0\n"
fi
printf "%s────────────────────────────────%s\n" "$BOLD" "$RESET"

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
