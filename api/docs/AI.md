# RepFinder API — Guia para Implementação de Novas Features (AI.md)

## 🎯 Objetivo

Este documento define regras e padrões obrigatórios para evolução da aplicação.

Qualquer nova feature deve seguir estritamente estas diretrizes **E obrigatoriamente respeitar todas as regras definidas em `BUSINESS.md`**.

---

## 🚨 Regra Suprema

> **Nenhuma implementação pode violar as regras de negócio definidas em `BUSINESS.md`.**

Se houver conflito entre implementação e arquitetura:

👉 **BUSINESS.md sempre vence**

---

## ⚠️ Regras Gerais

### 🚫 PROIBIDO

* Usar `any` em qualquer contexto
* Misturar lógica de negócio com rotas
* Acessar banco fora do repository
* Criar classes sem necessidade real
* Retornar `new Response()` manualmente (usar `c.json`)
* Confiar em dados vindos do cliente sem validação/autenticação
* Introduzir frameworks adicionais sem justificativa
* Ignorar regras de autorização/autenticação

---

## 🔐 Autenticação e Segurança

* Toda rota protegida deve utilizar middleware de autenticação (JWT)
* O `userId` deve ser obtido **exclusivamente do token**
* Nunca confiar em `userId` vindo do body
* O service deve validar permissões com base no usuário autenticado

---

## 🧠 Regras de Negócio (Integração com BUSINESS.md)

Toda implementação deve garantir:

* Validação de ownership (ex: dono da vaga, dono da aplicação)
* Validação de duplicidade (ex: 1 aplicação por vaga por usuário)
* Validação de status (ex: não alterar após accepted/rejected)
* Validação de existência de entidades
* Respeito às regras de exclusão
* Respeito às regras de autenticação

👉 Essas validações **DEVEM estar no service**

---

## ✅ Tipagem

A aplicação é **100% tipada**. Sempre utilizar tipos explícitos.

```ts
export type Application = {
  id: string
  userId: string
  vacancyId: string
  status: 'pending' | 'accepted' | 'rejected'
  createdAt: Date
}
```

---

## 📦 DTOs (Data Transfer Objects)

Utilizar DTOs para entrada de dados.

```ts
export type CreateApplicationDTO = {
  userId: string
  vacancyId: string
}
```

⚠️ O `userId` do DTO pode ser ignorado/substituído pelo token quando necessário.

---

## 🧱 Estrutura Obrigatória

```
modules/<feature>/
├── feature.types.ts
├── feature.repo.ts
├── feature.service.ts
├── feature.routes.ts
```

---

## 🧠 Padrão Arquitetural

### 🔹 Repository

* Acesso ao banco
* Sem lógica de negócio

```ts
const repo = {
  create,
  list
}

export default repo
```

---

### 🔹 Service

* Implementa TODAS as regras de negócio
* Valida permissões
* Valida consistência

```ts
const service = {
  create,
  list
}

export default service
```

---

### 🔹 Routes

* Validação de entrada (DTO)
* Chamada de service
* Uso de middleware (auth + validation)

```ts
app.post(
  '/',
  validateBody(CreateValidator),
  authMiddleware,
  async (c) => {
    const user = c.get('user')
    return c.json(await service.create({ ...dto, userId: user.id }))
  }
)
```

---

## 🔄 Fluxo de Implementação

### 1. Criar Types

* Entidade
* DTOs

---

### 2. Criar Repository

* SQL puro
* Retorno tipado

---

### 3. Criar Service

* Aplicar regras do BUSINESS.md
* Validar permissões
* Validar consistência

---

### 4. Criar Routes

* Validar entrada
* Aplicar middleware
* Chamar service

---

## ⚠️ Regra Crítica

### ❌ Nunca usar `any`

Se necessário:

* Criar tipo
* Criar DTO
* Usar generics

---

## 🧠 Boas Práticas

### ✔ Separação de responsabilidades

* Route → HTTP
* Service → regras de negócio
* Repo → banco

---

### ✔ Validação correta

* Route → valida formato (DTO)
* Service → valida regras de negócio

---

### ✔ Nomeação consistente

* `createX`
* `listX`
* `findXById`

---

### ✔ Mapeamento explícito

```ts
return rows.map((row) => ({
  id: row.id,
  userId: row.user_id
}))
```

---

## 🗄️ Banco de Dados

* `CREATE TABLE IF NOT EXISTS`
* IDs não sequenciais (UUID/ULID)
* Garantir integridade referencial

---

## ⚡ Performance

* Pool de conexões
* Evitar N+1
* Queries eficientes

---

## 🔜 Futuro (Eventos)

* Não acoplar eventos no service
* Criar camada separada
* Utilizar Redis Pub/Sub

---

## 📌 Padrão de Código

### ✔ Objetos wrapper

```ts
const service = {
  create,
  list
}
```

---

### ❌ Evitar classes

```ts
class Service {}
```

---

## 🚀 Evolução Esperada

* Arquitetura orientada a eventos
* Processamento assíncrono
* Escalabilidade

---

## ❗ Regra de Ouro

Se algo parecer complexo demais:

👉 provavelmente está errado.

---

## ✅ Checklist antes de finalizar uma feature

* [ ] Tipagem definida
* [ ] DTO criado
* [ ] Sem uso de `any`
* [ ] Repository separado
* [ ] Service implementado
* [ ] Routes funcionando
* [ ] Uso de `c.json`
* [ ] Middleware aplicado (auth/validation)
* [ ] Regras do BUSINESS.md respeitadas

---

## 🧠 Filosofia do Projeto

> Escalabilidade com simplicidade.

O sistema deve ser projetado desde o início para suportar crescimento, sem introduzir complexidade desnecessária.

### Princípios

* Construir soluções simples, mas que não limitem a evolução futura
* Evitar overengineering, mas também evitar atalhos que prejudiquem escalabilidade
* Manter separação clara de responsabilidades (route, service, repository)
* Garantir que regras de negócio sejam centralizadas e consistentes
* Projetar pensando em futura adoção de:

  * eventos (Pub/Sub)
  * workers assíncronos
  * possível divisão em serviços

### Diretriz prática

Se houver duas opções:

* uma mais simples porém difícil de escalar
* outra levemente mais estruturada e escalável

👉 prefira a segunda, **desde que não adicione complexidade desnecessária**

---

## ❗ Regra de Ouro

A solução deve ser:

* simples de entender
* fácil de manter
* pronta para evoluir

---

Evite overengineering.
