#!/usr/bin/env fish
# RepFinder — smoke test (notifications persistence)
# Uso: fish smoke_notifications.fish [base_url]

set BASE (if test (count $argv) -gt 0; printf "%s" $argv[1]; else; printf "http://localhost:3030"; end)
set API     $BASE/api
set PASS    0
set FAIL    0
set TMPBODY /tmp/rf_notif_body.json

set GREEN  \e'[32m'
set RED    \e'[31m'
set BOLD   \e'[1m'
set DIM    \e'[2m'
set RESET  \e'[0m'

function ok
    set -g PASS (math $PASS + 1)
    printf "  %s✔%s %s\n" $GREEN $RESET "$argv"
end

function fail
    set -g FAIL (math $FAIL + 1)
    printf "  %s✘%s %s\n" $RED $RESET "$argv"
end

function section
    printf "\n%s── %s%s\n" $BOLD "$argv" $RESET
end

function assert_status
    if test "$argv[2]" = "$argv[3]"
        ok "$argv[1] → $argv[2]"
    else
        fail "$argv[1] → esperado $argv[3], recebeu $argv[2]"
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
d = json.load(open('$TMPBODY'))
print(d.get('$argv[1]') or '')
" 2>/dev/null
end

# extrai campo de um item de lista pelo índice
# jlist_get <index> <field>
function jlist_get
    python3 -c "
import json
data = json.load(open('$TMPBODY'))
if isinstance(data, list) and len(data) > $argv[1]:
    item = data[$argv[1]]
    val = item.get('$argv[2]')
    if isinstance(val, dict):
        print(json.dumps(val))
    else:
        print(val if val is not None else '')
else:
    print('')
" 2>/dev/null
end

function jlist_len
    python3 -c "
import json
data = json.load(open('$TMPBODY'))
print(len(data) if isinstance(data, list) else 0)
" 2>/dev/null
end

function GET
    if test (count $argv) -ge 2
        curl -s -o $TMPBODY -w "%{http_code}" \
            -H "Authorization: Bearer $argv[2]" \
            "$argv[1]"
    else
        curl -s -o $TMPBODY -w "%{http_code}" "$argv[1]"
    end
end

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

function PATCH
    curl -s -o $TMPBODY -w "%{http_code}" \
        -X PATCH \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $argv[3]" \
        -d "$argv[2]" \
        "$argv[1]"
end

# ── setup
section "setup — criar usuários e vaga"

set s (POST $API/users/register '{"email":"rep_notif@repfinder.com","name":"Rep Notif","password":"senha123","role":"representative"}')
assert_status "register representante" $s 201
set rep_token (jget token)

set s (POST $API/users/register '{"email":"stu_notif@repfinder.com","name":"Stu Notif","password":"senha123","role":"student"}')
assert_status "register estudante" $s 201
set stu_token (jget token)

set s (POST $API/vacancies '{"title":"Vaga Notif Test","description":"Teste notificações"}' $rep_token)
assert_status "criar vaga" $s 201
set vacancy_id (jget id)

# ── application.created → notificação para representante
section "application.created → notificação persistida para representante"

set s (POST $API/applications "{\"vacancyId\":\"$vacancy_id\"}" $stu_token)
assert_status "estudante aplica" $s 201
set app_id (jget id)

# aguarda processamento do evento pelo subscriber
sleep 1

set s (GET $API/notifications $rep_token)
assert_status "GET /notifications (representante)" $s 200

set notif_count (jlist_len)
if test "$notif_count" -ge 1
    ok "representante tem $notif_count notificação(ões)"
else
    fail "nenhuma notificação encontrada para representante"
    exit 1
end

set notif_id    (jlist_get 0 id)
set notif_event (jlist_get 0 event)
set notif_readed (jlist_get 0 readed_at)

# extrai applicationId do campo data (objeto aninhado)
set notif_appid (python3 -c "
import json
data = json.load(open('$TMPBODY'))
d = data[0].get('data', {}) if data else {}
if isinstance(d, str):
    d = json.loads(d)
print(d.get('applicationId', ''))
" 2>/dev/null)

assert_value "evento é application.created"           $notif_event  "application.created"
assert_value "applicationId na notificação bate"      $notif_appid  $app_id

if test -z "$notif_readed" -o "$notif_readed" = "None" -o "$notif_readed" = "null"
    ok "readed_at inicial está vazio (não lida)"
else
    fail "readed_at deveria estar vazio, recebeu '$notif_readed'"
end

# ── autenticação: estudante não vê notificações do representante
section "isolamento — estudante não vê notificações do representante"

set s (GET $API/notifications $stu_token)
assert_status "GET /notifications (estudante antes de aceite)" $s 200

set stu_count (jlist_len)
assert_value "estudante não tem notificações ainda" $stu_count "0"

# ── mark as read
section "PATCH /:id/read — marcar como lida"

set s (PATCH $API/notifications/$notif_id/read '{}' $rep_token)
assert_status "PATCH /notifications/:id/read" $s 200

set updated_readed (jget readed_at)
if test -n "$updated_readed" -a "$updated_readed" != "null"
    ok "readed_at preenchido após mark read → '$updated_readed'"
else
    fail "readed_at deveria estar preenchido após mark read"
end

# confirma via GET que persiste
set s (GET $API/notifications $rep_token)
assert_status "GET /notifications após mark read" $s 200

set readed_persisted (python3 -c "
import json
data = json.load(open('$TMPBODY'))
print(data[0].get('readed_at') or '')
" 2>/dev/null)

if test -n "$readed_persisted" -a "$readed_persisted" != "null"
    ok "readed_at persistido no banco → '$readed_persisted'"
else
    fail "readed_at não persistido no banco"
end

# ── mark read de notificação de outro usuário deve falhar
section "autorização — não pode marcar notificação de outro usuário"

set s (PATCH $API/notifications/$notif_id/read '{}' $stu_token)
assert_status "estudante não pode marcar notificação do representante → 404" $s 404

# ── application.status.updated → notificação para estudante
section "application.status.updated → notificação persistida para estudante"

set s (PATCH $API/applications/$app_id/status '{"status":"accepted"}' $rep_token)
assert_status "representante aceita aplicação" $s 200

sleep 1

set s (GET $API/notifications $stu_token)
assert_status "GET /notifications (estudante após aceite)" $s 200

set stu_count_after (jlist_len)
if test "$stu_count_after" -ge 1
    ok "estudante tem $stu_count_after notificação(ões)"
else
    fail "nenhuma notificação encontrada para estudante"
    exit 1
end

set stu_evt    (jlist_get 0 event)
set stu_status (python3 -c "
import json
data = json.load(open('$TMPBODY'))
d = data[0].get('data', {}) if data else {}
if isinstance(d, str):
    d = json.loads(d)
print(d.get('status', ''))
" 2>/dev/null)

assert_value "evento é application.status.updated" $stu_evt    "application.status.updated"
assert_value "status no evento é accepted"         $stu_status "accepted"

# ── autenticação básica
section "autenticação — rotas protegidas"

set s (GET $API/notifications)
assert_status "GET /notifications sem token → 401" $s 401

set s (PATCH $API/notifications/$notif_id/read '{}')
assert_status "PATCH /notifications/:id/read sem token → 401" $s 401

# ── resultado
printf "\n%s────────────────────────────────%s\n" $BOLD $RESET
set TOTAL (math $PASS + $FAIL)
printf "  total:   %s\n" $TOTAL
printf "  %s passou:  %s%s\n" $GREEN $PASS $RESET
if test $FAIL -gt 0
    printf "  %s falhou:  %s%s\n" $RED $FAIL $RESET
else
    printf "  falhou:  0\n"
end
printf "%s────────────────────────────────%s\n" $BOLD $RESET

if test $FAIL -gt 0; exit 1; end