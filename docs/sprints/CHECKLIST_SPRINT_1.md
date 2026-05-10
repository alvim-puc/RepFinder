# CHECKLIST SPRINT 1 - RepFinder API
## Validação de Requisitos e Critérios de Avaliação

## ✅ REQUISITOS DA SPRINT 1

### 1. Documento de Proposta
- [x] Descrição do domínio escolhido
- [x] Justificativa
- [x] Identificação dos dois perfis (student, representative)
- [x] Principais funcionalidades listadas
- [x] Regras de negócio documentadas
- **Arquivo**: [RepFinder.pdf](/docs/RepFinder.pdf)
- **Status**: ✅ COMPLETO

### 2. Diagrama de Arquitetura
- [x] Representação visual dos componentes (apps, backend, MOM, BD)
- [x] Identificação de protocolos de comunicação
- [x] Camadas do sistema identificadas
- [x] Fluxo de requisições documentado
- **Arquivo**: [RepFinder - DA.svg](/api/docs/images/RepFinder%20-%20DA.svg)
- **Status**: ✅ COMPLETO

### 3. Backend REST Funcional
- [x] Mínimo 4 endpoints: **15 implementados**
  - POST /users/register ✅
  - POST /users/login ✅
  - GET /users/me ✅ (protegido)
  - PATCH /users/me ✅ (protegido)
  - POST /vacancies ✅ (protegido, representante)
  - GET /vacancies ✅ (público)
  - GET /vacancies/mine ✅ (protegido)
  - GET /vacancies/:id ✅ (público)
  - PATCH /vacancies/:id ✅ (protegido, owner)
  - DELETE /vacancies/:id ✅ (protegido, owner)
  - POST /applications ✅ (protegido)
  - GET /applications/mine ✅ (protegido)
  - GET /applications/vacancies/:vacancyId ✅ (protegido, owner)
  - PATCH /applications/:id/status ✅ (protegido, owner vaga)
  - DELETE /applications/:id ✅ (protegido, criador)

- [x] Operações essenciais cobertas:
  - CREATE: register, createVacancy, createApplication ✅
  - READ: listVacancies, getMe, getById ✅
  - UPDATE: updateUser, updateVacancy, updateApplicationStatus ✅
  - DELETE: deleteVacancy, deleteApplication ✅

- **Status**: ✅ COMPLETO (15/4 endpoints mínimo)

### 4. Banco de Dados
- [x] Utiliza PostgreSQL/MySQL: **MariaDB** ✅
- [x] Schema documentado
  - Tabela `users`: id, email, name, password, role, created_at
  - Tabela `vacancies`: id, title, description, provider_id, created_at
  - Tabela `applications`: id, user_id, vacancy_id, status, created_at
- [x] Constraints e FK implementadas
  - FK users.id ← vacancies.provider_id
  - FK users.id ← applications.user_id
  - FK vacancies.id ← applications.vacancy_id
  - UNIQUE email em users
  - DEFAULT status='pending' em applications
- **Status**: ✅ COMPLETO

### 5. Coleção de Testes
- [x] Arquivo Insomnia exportado: `Insomnia_RepFinder_API.json` ✅
- [x] Todos os endpoints documentados ✅
- [x] Exemplos de requisição e resposta ✅
- [x] Variáveis de ambiente (base_url, token) ✅
- [x] Headers de autenticação configurados ✅
- [x] Organização por grupos (Auth, Users, Vacancies, Applications) ✅
- **Status**: ✅ COMPLETO

---

## 📊 CRITÉRIOS DE AVALIAÇÃO SPRINT 1 (20 pontos)

### 1. Clareza e Viabilidade da Proposta (20% = 4,0 pontos)
| Aspecto | Status | Evidência |
|---------|--------|-----------|
| Domínio claramente descrito | ✅ | [RepFinder.pdf](/docs/RepFinder.pdf) - seção 1 |
| Viabilidade técnica | ✅ | Tecnologias padrão: Node.js, MariaDB |
| Dois perfis distintos | ✅ | Student vs Representative bem definidos |
| Funcionalidades justificadas | ✅ | Fluxos de autenticação, vagas e candidaturas |
| Alinhamento com arquitetura EDA | ✅ | Preparado para Sprint 2 com MOM |
| **Pontuação esperada** | **4,0** | |

### 2. Qualidade e Completude do Diagrama (20% = 4,0 pontos)
| Aspecto | Status | Evidência |
|---------|--------|-----------|
| Componentes representados | ✅ | Apps Flutter, API (Node.js + Hono + TypeScript), Routes, Services, Repositories, MariaDB, Redis Pub/Sub e Worker |
| Protocolos identificados | ✅ | HTTP/REST, JWT Bearer, MySQL/TCP, Redis Pub/Sub, SSE |
| Fluxo de dados | ✅ | Cliente → Routes → Services → Repositories → MariaDB, com publicação para MOM e consumo por Worker |
| Clareza visual | ✅ | Diagrama feito em Excalidraw com separação explícita dos blocos |
| Documentação | ✅ | [RepFinder - DA.svg](/api/docs/images/RepFinder%20-%20DA.svg) com explicações em [architecture.md](/api/docs/architecture.md) |
| **Pontuação esperada** | **4,0** | |

### 3. Funcionalidade e Correção (30% = 6,0 pontos)
| Aspecto | Status | Evidência |
|---------|--------|-----------|
| CRUD criar | ✅ | register, createVacancy, createApplication |
| CRUD listar | ✅ | listVacancies, listApplications, etc. |
| CRUD atualizar | ✅ | updateUser, updateVacancy, updateStatus |
| CRUD deletar | ✅ | deleteVacancy, deleteApplication |
| Endpoints funcionando | ✅ | Testados via Insomnia |
| Validações implementadas | ✅ | DTO validators em todas as rotas |
| Regras de negócio | ✅ | Ownership, email unique, status workflow |
| Erros tratados | ✅ | AppError com statusCode (401, 403, 404, 409) |
| **Pontuação esperada** | **6,0** | |

### 4. Organização do Código (Clean Architecture) (20% = 4,0 pontos)
| Aspecto | Status | Evidência |
|---------|--------|-----------|
| Separação camadas | ✅ | routes → service → repo (3 camadas) |
| Padrão repositório | ✅ | objects wrapper (export default) |
| Services com lógica | ✅ | Business rules centralizadas |
| DTOs tipados | ✅ | Types em .types.ts |
| Validators | ✅ | Validators em .validator.ts |
| Middleware | ✅ | authMiddleware em lib/auth.ts |
| Helpers | ✅ | assertIsOwner, assertExists em lib/helpers.ts |
| Sem Any types | ✅ | TypeScript strict mode, zero `any` |
| JWT seguro | ✅ | jose library, PBKDF2-SHA512 |
| **Pontuação esperada** | **4,0** | |

### 5. Documentação dos Endpoints (10% = 2,0 pontos)
| Aspecto | Status | Evidência |
|---------|--------|-----------|
| Coleção Insomnia | ✅ | 15 requisições documentadas |
| Exemplos de body | ✅ | JSON bodies com valores realistas |
| Headers configurados | ✅ | Authorization: Bearer {{ token }} |
| Variáveis de ambiente | ✅ | base_url, token |
| Organização | ✅ | 4 pastas: Auth, Users, Vacancies, Apps |
| Método HTTP correto | ✅ | POST/GET/PATCH/DELETE aplicados corretamente |
| Status codes | ✅ | 201 Create, 200 OK, 401/403/404/409 errors |
| **Pontuação esperada** | **2,0** | |

---

## 📋 RESUMO DE PONTUAÇÃO

| Critério | Peso | Máx. | Esperado |
|----------|------|------|----------|
| Proposta | 20% | 4,0 | 4,0 |
| Diagrama | 20% | 4,0 | 4,0 |
| Funcionalidade | 30% | 6,0 | 6,0 |
| Clean Architecture | 20% | 4,0 | 4,0 |
| Documentação | 10% | 2,0 | 2,0 |
| **TOTAL** | **100%** | **20,0** | **20,0** |

---

## 📝 ARQUIVOS ENTREGÁVEIS

```
/home/alvim/codes/repfinder/
├── api/
│   ├── src/
│   │   ├── app.ts
│   │   ├── routes.ts
│   │   ├── lib/
│   │   │   ├── auth.ts
│   │   │   ├── helpers.ts
│   │   │   ├── errors.ts
│   │   │   ├── db.ts
│   │   │   ├── init-db.ts
│   │   │   └── env.ts
│   │   └── modules/
│   │       ├── users/
│   │       ├── vacancies/
│   │       └── applications/
│   ├── package.json
│   └── tsconfig.json
├── Insomnia_RepFinder_API.json ✅
├── PROPOSTA_SPRINT_1.md ✅
├── DIAGRAMA_ARQUITETURA.md ✅
└── CHECKLIST_SPRINT_1.md ✅
```

---

## ✨ PONTOS FORTES

1. **Mais endpoints que obrigatório**: 15 vs 4 mínimo
2. **Segurança robusta**: JWT (jose), PBKDF2-SHA512, timing-safe verification
3. **Clean Architecture**: 3 camadas bem separadas
4. **Type Safety**: TypeScript strict, sem `any`
5. **Documentação**: Proposta, diagrama, coleção de testes
6. **Regras de negócio**: Todas implementadas com validações
7. **Tratamento de erro**: AppError centralizado com status codes apropriados

---

## 📌 CONCLUSÃO

**✅ PRONTO PARA ENTREGAR SPRINT 1**

Seu projeto atende a **todos os requisitos** e critérios da Sprint 1 com qualidade acima do esperado. A arquitetura é limpa, segura e bem documentada. Recomenda-se revisar os documentos (Proposta e Diagrama) e converter para PDF antes da submissão oficial.

**Data de Entrega**: 11/05/2026  
**Status**: ✅ PRONTO (10/05/2026)
