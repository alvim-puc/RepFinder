# Regras de Negócio — RepFinder API

Implemente as regras de negócio abaixo respeitando a arquitetura do projeto (routes → service → repository), tipagem forte (TypeScript) e sem uso de `any`.

---

## 🔐 Autenticação (JWT)

* A autenticação deve ser baseada em **token JWT**

* O token deve ser gerado no login

* O token deve conter:

  * `userId`
  * (opcional) `email`

* O token deve ser enviado em:

  * Header: `Authorization: Bearer <token>`

---

## 🔒 Middleware de Autenticação

* Criar middleware para:

  * validar token
  * extrair `userId`
  * anexar ao contexto da requisição

* Exemplo de uso:

```ts
app.use('/protected/*', authMiddleware)
```

* Rotas protegidas devem exigir autenticação

---

## 👤 Usuário Autenticado

* Todas as operações protegidas devem usar o `userId` do token
* Nunca confiar em `userId` vindo do body da requisição

---

## 🔐 Autorização

* Apenas o criador da vaga (`vacancy.providerId`) pode:

  * editar a vaga
  * deletar a vaga
  * aprovar ou rejeitar aplicações relacionadas à sua vaga

* Um usuário só pode:

  * visualizar e alterar seus próprios dados

* Apenas o usuário que criou uma aplicação pode removê-la

---

## 📌 Aplicações (Applications)

* Um usuário só pode possuir **uma aplicação por vaga**

  * validar antes de inserir (buscar por `userId + vacancyId`)

* Status possíveis:

  * `pending`
  * `accepted`
  * `rejected`

* Regras de status:

  * aplicações começam como `pending`
  * apenas o dono da vaga pode alterar status
  * uma aplicação não pode ser modificada após ser `accepted` ou `rejected`

* Exclusão:

  * aplicações só podem ser removidas se estiverem com status `pending`

---

## 🏠 Vagas (Vacancies)

* Apenas o criador pode editar ou remover a vaga

* Ao remover uma vaga:

  * definir comportamento:

    * ou bloquear exclusão se houver aplicações
    * ou deletar aplicações relacionadas (cascade)

---

## 👤 Usuários (Users)

* Campos obrigatórios:

  * `id` (não sequencial)
  * `email` (único)
  * `name`
  * `password` (hash seguro, ex: bcrypt)

* Regras:

  * email deve ser único
  * senha nunca deve ser armazenada em texto puro

---

## 🆔 Identificadores

* Todas as entidades devem usar identificadores não sequenciais:

  * UUID (recomendado via `crypto.randomUUID`)
  * ou ULID (se ordenação for necessária)

---

## 🔎 Validações obrigatórias

Antes de qualquer operação:

* verificar se usuário existe
* verificar se vaga existe
* verificar se aplicação existe (quando aplicável)

---

## ⚠️ Consistência

* Nunca permitir operações em entidades inexistentes
* Garantir integridade entre:

  * usuários
  * vagas
  * aplicações

---

## 🧠 Arquitetura

* **Routes**

  * validar entrada (DTO)
  * chamar service

* **Middleware**

  * autenticação (JWT)
  * validação de dados

* **Service**

  * implementar regras de negócio
  * validar permissões
  * validar consistência

* **Repository**

  * acesso ao banco (SQL puro)
  * sem lógica de negócio

---

## ❗ Restrições Técnicas

* Não utilizar `any`
* Sempre utilizar DTOs tipados
* Sempre mapear retorno do banco para tipos explícitos
* Não misturar responsabilidades entre camadas

---

## 🎯 Objetivo da Implementação

Garantir que:

* regras de negócio sejam aplicadas no service
* autenticação seja obrigatória em rotas protegidas
* dados estejam sempre consistentes
* API seja previsível e segura
