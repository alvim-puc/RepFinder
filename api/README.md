# RepFinder API - Backend

Plataforma distribuída de busca e gestão de oportunidades de emprego com arquitetura escalável orientada a eventos.

## 🎯 Sobre o Projeto

**RepFinder** conecta **candidatos (estudantes)** com **representantes de empresas (recrutadores)** em uma plataforma de vagas de emprego. O sistema suporta o fluxo completo: autenticação, publicação de vagas, candidaturas, aprovação/rejeição e notificações assíncronas.

### Perfis de Usuário
- **Student**: Busca vagas e se candidata
- **Representative**: Publica vagas e seleciona candidatos

## 📋 Requisitos

- Node.js 18+
- npm ou yarn
- MariaDB 10.4+ (ou MySQL 8.0+)

## 🚀 Instalação e Setup

### 1. Instalar dependências
```bash
npm install
```

### 2. Configurar variáveis de ambiente (.env)
```env
PORT=3030
DATABASE_HOST=localhost
DATABASE_USER=root
DATABASE_PASSWORD=
DATABASE_NAME=repfinder
JWT_SECRET=seu-secret-jwt-muito-seguro-aqui
```

### 3. Iniciar servidor
```bash
npm run dev
```

Servidor rodará em `http://localhost:3030`

## 📚 API Endpoints (15 total)

### 🔐 Auth
- `POST /api/users/register` - Registrar novo usuário
- `POST /api/users/login` - Autenticar usuário

### 👤 Users
- `GET /api/users/me` - Perfil do usuário (protegido)
- `PATCH /api/users/me` - Atualizar dados (protegido)

### 🏠 Vacancies
- `GET /api/vacancies` - Listar todas as vagas
- `GET /api/vacancies/mine` - Vagas do usuário (protegido)
- `GET /api/vacancies/:id` - Detalhes de vaga
- `POST /api/vacancies` - Criar vaga (protegido, representante)
- `PATCH /api/vacancies/:id` - Atualizar vaga (protegido, owner)
- `DELETE /api/vacancies/:id` - Deletar vaga (protegido, owner)

### 📌 Applications
- `GET /api/applications/mine` - Minhas candidaturas (protegido)
- `GET /api/applications/vacancies/:vacancyId` - Candidatos da vaga (protegido, owner)
- `POST /api/applications` - Candidatar para vaga (protegido)
- `PATCH /api/applications/:id/status` - Aprovar/rejeitar (protegido, owner vaga)
- `DELETE /api/applications/:id` - Remover candidatura (protegido, criador)

## 🔐 Autenticação

Usar token JWT no header:
```
Authorization: Bearer <token>
```

## 📝 Stack Tecnológico

- **Runtime**: Node.js 18+
- **Framework**: Hono 4.12.16
- **Linguagem**: TypeScript 5.8.3
- **Banco**: MariaDB/MySQL
- **Auth**: JWT (jose) + PBKDF2-SHA512

## 📊 Database Schema

**users** - id, email, name, password, role  
**vacancies** - id, title, description, provider_id, created_at  
**applications** - id, user_id, vacancy_id, status, created_at

## 🧪 Testes

Coleção completa em `Insomnia_RepFinder_API.json` com 15 requisições documentadas.
