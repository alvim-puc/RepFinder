#!/usr/bin/env fish
# RepFinder — smoke test (eventos SSE)
# Uso: fish smoke_events.fish [base_url]

set BASE (if test (count $argv) -gt 0; printf "%s" $argv[1]; else; printf "http://localhost:3030"; end)
set API      $BASE/api
set PASS     0
set FAIL     0
set TMPBODY  /tmp/rf_evt_body.json
set SSE_REP  /tmp/rf_sse_rep.log
set SSE_STU  /tmp/rf_sse_stu.log

set GREEN  \e'[32m'
set YELLOW \e'[33m'
set RED    \e'[31m'
set RESET  \e'[0m'
set DIM    \e'[2m'
set BOLD   \e'[1m'

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
d=json.load(open('$TMPBODY'))
print(d.get('$argv[1]') or '')
" 2>/dev/null
end

function GET
    curl -s -o $TMPBODY -w "%{http_code}" \
        -H "Authorization: Bearer $argv[2]" \
        "$argv[1]"
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

function sse_listen
    curl -s -N \
        -H "Authorization: Bearer $argv[1]" \
        -H "Accept: text/event-stream" \
        "$API/notifications/events" \
        > $argv[2] &
    printf "%s" $last_pid
end

function sse_wait_event
    set logfile  $argv[1]
    set evt_name $argv[2]
    set timeout  $argv[3]
    set elapsed  0

    while test $elapsed -lt $timeout
        if test -f $logfile
            if grep -q "event: $evt_name" $logfile 2>/dev/null
                return 0
            end
        end
        sleep 0.5
        set elapsed (math $elapsed + 1)
    end
    return 1
end

function sse_extract
    python3 -c "
import json, re

logfile    = '$argv[1]'
event_name = '$argv[2]'
field      = '$argv[3]'

try:
    content = open(logfile).read()
    pattern = rf'event: {re.escape(event_name)}\ndata: (.*?)(?:\n\n|\Z)'
    match = re.search(pattern, content, re.DOTALL)
    if match:
        data = json.loads(match.group(1))
        print(data.get(field, ''))
    else:
        print('')
except:
    print('')
" 2>/dev/null
end

# ── setup
section "setup — usuários e vaga"

set s (POST $API/users/register '{"email":"rep_evt@repfinder.com","name":"Ana Rep","password":"senha123","role":"representative"}')
assert_status "register representante" $s 201
set rep_token (jget token)

set s (POST $API/users/register '{"email":"stu_evt@repfinder.com","name":"Bruno Estudante","password":"senha123","role":"student"}')
assert_status "register estudante" $s 201
set stu_token (jget token)

set s (POST $API/vacancies '{"title":"Vaga Evento Test","description":"Para testar SSE"}' $rep_token)
assert_status "criar vaga" $s 201
set vacancy_id (jget id)

# ── conectar SSE
section "SSE — conectando clientes"

rm -f $SSE_REP $SSE_STU

set rep_sse_pid (sse_listen $rep_token $SSE_REP)
set stu_sse_pid (sse_listen $stu_token $SSE_STU)

sleep 1

if test -n "$rep_sse_pid"
    ok "conexão SSE representante aberta (pid $rep_sse_pid)"
else
    fail "conexão SSE representante não iniciou"
end

if test -n "$stu_sse_pid"
    ok "conexão SSE estudante aberta (pid $stu_sse_pid)"
else
    fail "conexão SSE estudante não iniciou"
end

# ── application.created
section "evento — application.created"

set s (POST $API/applications "{\"vacancyId\":\"$vacancy_id\"}" $stu_token)
assert_status "estudante aplica para vaga" $s 201
set app_id (jget id)

printf "  %s[publish] application.created → vacancyId=%s enviado%s\n" $DIM $vacancy_id $RESET

if sse_wait_event $SSE_REP "application.created" 5
    ok "representante recebeu evento application.created"

    set evt_app_id   (sse_extract $SSE_REP "application.created" "applicationId")
    set evt_vac_id   (sse_extract $SSE_REP "application.created" "vacancyId")
    set evt_occurred (sse_extract $SSE_REP "application.created" "occurredAt")

    printf "  %s[receive] payload recebido:%s\n" $DIM $RESET
    printf "    applicationId → %s\n" $evt_app_id
    printf "    vacancyId     → %s\n" $evt_vac_id
    printf "    occurredAt    → %s\n" $evt_occurred

    assert_value "applicationId bate com o criado" $evt_app_id  $app_id
    assert_value "vacancyId bate com a vaga"        $evt_vac_id $vacancy_id
else
    fail "timeout — representante não recebeu application.created em 5s"
    printf "  %s[debug] log SSE representante:%s\n" $DIM $RESET
    cat $SSE_REP 2>/dev/null || printf "    (vazio)\n"
end

sleep 0.5
if grep -q "event: application.created" $SSE_STU 2>/dev/null
    fail "estudante não deveria receber application.created"
else
    ok "estudante não recebeu application.created (correto)"
end

# ── application.status.updated
section "evento — application.status.updated"

set s (PATCH $API/applications/$app_id/status '{"status":"accepted"}' $rep_token)
assert_status "representante aceita aplicação" $s 200

printf "  %s[publish] application.status.updated → status=accepted enviado%s\n" $DIM $RESET

if sse_wait_event $SSE_STU "application.status.updated" 5
    ok "estudante recebeu evento application.status.updated"

    set evt_app_id2   (sse_extract $SSE_STU "application.status.updated" "applicationId")
    set evt_status    (sse_extract $SSE_STU "application.status.updated" "status")
    set evt_occurred2 (sse_extract $SSE_STU "application.status.updated" "occurredAt")

    printf "  %s[receive] payload recebido:%s\n" $DIM $RESET
    printf "    applicationId → %s\n" $evt_app_id2
    printf "    status        → %s\n" $evt_status
    printf "    occurredAt    → %s\n" $evt_occurred2

    assert_value "applicationId bate"          $evt_app_id2 $app_id
    assert_value "status no evento é accepted" $evt_status  "accepted"
else
    fail "timeout — estudante não recebeu application.status.updated em 5s"
    printf "  %s[debug] log SSE estudante:%s\n" $DIM $RESET
    cat $SSE_STU 2>/dev/null || printf "    (vazio)\n"
end

sleep 0.5
if grep -q "event: application.status.updated" $SSE_REP 2>/dev/null
    fail "representante não deveria receber application.status.updated"
else
    ok "representante não recebeu application.status.updated (correto)"
end

# ── autenticação
section "SSE — autenticação"

set s (curl -s -o $TMPBODY -w "%{http_code}" "$API/notifications/events")
assert_status "GET /notifications/events sem token → 401" $s 401

# ── cleanup
kill $rep_sse_pid 2>/dev/null
kill $stu_sse_pid 2>/dev/null

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