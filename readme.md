# RepFinder

Plataforma para centralizar a busca por vagas em repúblicas universitárias, conectando estudantes que procuram moradia a representantes que divulgam oportunidades.

## O problema

A busca por moradia universitária ainda acontece de forma majoritariamente informal — grupos de WhatsApp, indicações de colegas, publicações espalhadas em redes sociais. Para quem procura, faltam informações organizadas. Para quem oferece, faltam ferramentas para gerenciar candidatos de forma estruturada.

Esse cenário gera alguns problemas recorrentes:

- Vagas divulgadas em canais fragmentados e de difícil acesso
- Nenhum histórico ou rastreabilidade nas candidaturas
- Processo de seleção informal, sem critérios claros
- Comunicação descentralizada entre estudantes e representantes

## A proposta

O RepFinder organiza esse processo em uma plataforma estruturada com dois perfis de usuário:

- **Estudantes** — buscam vagas disponíveis e se candidatam de forma padronizada
- **Representantes** — divulgam vagas, acompanham candidaturas e gerenciam o processo de seleção

## Estrutura do projeto

```
repfinder/
├── api/          # Backend REST (Node.js + Hono + TypeScript)
│   └── docs/     # Documentação técnica, schema do banco e coleção Insomnia
├── apps/         # Aplicativos Flutter (em desenvolvimento)
└── docs/         # Enunciado do projeto
```

## Como rodar a API

**Pré-requisitos:** Node.js 18+, MariaDB/MySQL rodando localmente.

```bash
cd api
cp .env.example .env # preencha as variáveis abaixo
npm install
npm run dev
```

Variáveis de ambiente necessárias em `api/.env`:

```
DB_HOST=SEU_HOST
DB_USER=SEU_USER
DB_PASS=SUA_SENHA
DB_NAME=SEU_BANCO
JWT_SECRET=SEU_SEGREDO
REDIS_URL=SUA_URL_REDIS
REDIS_PORT=SUA_PORTA_REDIS
REDIS_PASSWORD=SUA_SENHA_REDIS
```

O banco de dados e as tabelas são criados automaticamente na primeira execução.

A API sobe em `http://localhost:3030`.  
A coleção de testes está em `api/docs/Insomnia_RepFinder_API.json`.

## Documentação técnica

A documentação da API — contexto do problema, decisões arquiteturais, regras de negócio e schema do banco — está em [`api/docs/`](./api/docs/).