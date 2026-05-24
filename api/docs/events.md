# 📣 Eventos da Aplicação (RepFinder)

Este documento descreve os eventos de domínio publicados pela API, como eles são consumidos no módulo de notificações e quais decisões de arquitetura foram aplicadas na Sprint 2.

---

## 🎯 Objetivo

O fluxo de eventos foi introduzido para desacoplar partes do sistema e permitir notificações em tempo real sem acoplar diretamente o módulo de `applications` ao módulo de `notifications`.

Em vez de chamar notificações de forma síncrona, a aplicação publica eventos em um canal Redis e o consumidor de notificações processa esses eventos no mesmo processo (monólito modular).

---

## 🧩 Eventos Publicados

Os eventos estão tipados em `src/events/events.types.ts`.

### 1) `application.created`

Disparado quando uma nova candidatura é criada.

Campos:
- `event`: `application.created`
- `applicationId`: ID da candidatura
- `vacancyId`: ID da vaga
- `applicantId`: ID do estudante que aplicou
- `providerId`: ID do representante dono da vaga (destinatário da notificação)
- `occurredAt`: timestamp ISO do momento do evento

### 2) `application.status.updated`

Disparado quando o representante altera o status de uma candidatura.

Campos:
- `event`: `application.status.updated`
- `applicationId`: ID da candidatura
- `vacancyId`: ID da vaga
- `applicantId`: ID do estudante (destinatário da notificação)
- `status`: `accepted` ou `rejected`
- `occurredAt`: timestamp ISO do momento do evento

---

## 📤 Fluxo de Publicação

1. Requisição HTTP chega em `applications.routes`.
2. `applications.service` executa regra de negócio e persiste no banco.
3. Service cria o evento via `eventFactory`.
4. Evento é publicado em Redis Pub/Sub por `events/publisher`.
5. Canal utilizado: `repfinder:events`.

Observação:
- A publicação está protegida por `try/catch` para não quebrar a resposta HTTP principal caso o broker esteja indisponível.

---

## 📥 Fluxo de Consumo

1. `modules/notifications/notifications.service` assina o canal `repfinder:events` no start da aplicação.
2. Ao receber mensagem, faz parse do payload para `AppEvent`.
3. Para cada tipo de evento:
   - envia evento SSE ao usuário destinatário conectado;
   - persiste a notificação na entidade `notifications` no banco.
4. Endpoints REST de notificações permitem consulta e marcação de leitura:
   - `GET /api/notifications`
   - `PATCH /api/notifications/:id/read`

---

## 🗄️ Entidade `notifications`

Tabela criada no banco:

- `id` (VARCHAR(36), PK)
- `user_id` (VARCHAR(36), destinatário)
- `event` (VARCHAR(255), nome do evento)
- `data` (TEXT com payload serializado em JSON)
- `readed_at` (DATETIME, `NULL` enquanto estiver em aberto)
- `created_at` (DATETIME)

Finalidade:
- permitir histórico de notificações;
- suportar leitura posterior mesmo sem conexão SSE ativa;
- indicar leitura por timestamp, não por booleano;
- oferecer base para futuras regras de paginação e filtros.

---

## ⚖️ Decisões Arquiteturais Aplicadas

### Decisão 1: Consumidor in-process (sem worker separado)

Decisão:
- manter o consumidor de eventos no mesmo processo da API durante a Sprint 2.

Motivo:
- projeto em monólito modular, com evolução planejada para extração futura de serviços.
- menor complexidade operacional nesta fase.

Impacto:
- positivo: setup e deploy mais simples.
- atenção: escalabilidade do consumidor fica acoplada à API.

### Decisão 2: Redis Pub/Sub como MOM inicial

Decisão:
- usar Redis Pub/Sub no canal `repfinder:events`.

Motivo:
- implementação simples e aderente ao escopo da sprint.

Impacto:
- positivo: baixa latência e integração rápida.
- atenção: Pub/Sub não garante persistência de mensagens (se subscriber estiver offline, pode perder evento).

### Decisão 3: Persistência de notificações no banco

Decisão:
- além da entrega em tempo real via SSE, persistir notificações em tabela própria.

Motivo:
- permitir consulta de histórico e marcação de leitura.

Impacto:
- melhora rastreabilidade e experiência do usuário.

---

## 🖼️ Evidência de Broker (redis-cli)

Espaço reservado para adicionar print do subscriber recebendo eventos do canal RepFinder.

### Comandos

```bash
>  redis-cli -u redis://default:{{PASSWORD}}@{{HOST}}:{{PORT}}
>  SUBSCRIBE repfinder:events
```

### Print do subscriber

<!-- 
> Cole aqui a imagem (ex.: `./images/redis-subscriber-events.png`) e descomente a linha abaixo.

![Subscriber Redis recebendo eventos](./images/redis-subscriber-events.png) 
-->
![RepFinder - redis-cli](./images/RepFinder%20-%20redis-cli.png)

### Exemplo esperado de saída

```text
1) "message"
2) "repfinder:events"
3) "{\"event\":\"application.created\",\"applicationId\":\"...\",\"vacancyId\":\"...\",\"applicantId\":\"...\",\"providerId\":\"...\",\"occurredAt\":\"2026-05-23T12:34:56.000Z\"}"
```
