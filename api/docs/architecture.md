## 🏗️ Arquitetura da Aplicação

A arquitetura do RepFinder foi pensada para refletir diretamente o fluxo de interação entre os diferentes tipos de usuários e o sistema, mantendo uma separação clara entre responsabilidades e preparando o terreno para evoluções futuras.

### 🧑‍💻 Clientes

A aplicação é consumida por dois clientes distintos, ambos desenvolvidos em Flutter:

* um aplicativo voltado para estudantes, responsável por buscar vagas e enviar solicitações
* um aplicativo voltado para representantes, responsável por gerenciar vagas e avaliar candidatos

Apesar de atenderem perfis diferentes, ambos interagem com o mesmo backend por meio de requisições HTTP, utilizando autenticação baseada em token.

---

### 🌐 Backend

O backend atua como ponto central de orquestração, sendo responsável por:

* autenticação dos usuários
* aplicação das regras de negócio
* controle de acesso aos recursos
* persistência e recuperação de dados

A comunicação com os clientes ocorre via API REST, onde cada requisição passa por um fluxo bem definido:

1. **Recebimento da requisição HTTP**
2. **Validação de autenticação (JWT)**
3. **Encaminhamento para o módulo responsável**
4. **Execução das regras de negócio**
5. **Acesso à camada de dados**
6. **Retorno da resposta ao cliente**

---

### 🧩 Organização por Módulos

O sistema é dividido em módulos que representam os principais domínios da aplicação:

* **users**: responsável por autenticação, cadastro e gerenciamento de perfil
* **vacancies**: responsável pela criação e gestão de vagas
* **applications**: responsável pelo envio e acompanhamento de candidaturas

Cada módulo encapsula sua própria lógica, reduzindo acoplamento e facilitando manutenção.

---

### 🔐 Autenticação

O acesso às rotas protegidas é controlado por um middleware de autenticação, que valida tokens JWT enviados pelos clientes.

Esse mecanismo garante que:

* apenas usuários autenticados acessem recursos protegidos
* informações como identidade e permissões estejam disponíveis durante o processamento da requisição

---

### 🧠 Camadas Internas

Dentro de cada módulo, a aplicação segue uma divisão em camadas que organiza o fluxo de execução:

* **Service Layer**: concentra as regras de negócio e decisões do domínio
* **Repository Layer**: responsável pela comunicação direta com o banco de dados
* **Camada HTTP (routes)**: responsável apenas pela interface com o cliente

Essa separação evita mistura de responsabilidades e mantém o código mais previsível.

---

### 🗄️ Persistência

A persistência é realizada em um banco relacional, onde são armazenadas as informações de:

* usuários
* vagas
* aplicações

A comunicação com o banco é feita de forma direta, permitindo controle total sobre as operações realizadas.

![RepFinder - MR](./images/RepFinder%20-%20MR.svg)

---

### 🔄 Comunicação Assíncrona (Evolução)

Embora a versão atual da aplicação seja síncrona, a arquitetura já considera a introdução de um componente intermediário de mensageria (MOM — Message-Oriented Middleware).

Esse componente será responsável por:

* desacoplar partes do sistema
* permitir processamento assíncrono
* viabilizar notificações em tempo real

Eventos como:

* criação de uma nova aplicação
* atualização de status de candidatura

podem ser publicados pelo backend e consumidos por um serviço dedicado, responsável por notificar os clientes.

---

### 📡 Notificações e Tempo Real

Em estágios futuros, os clientes poderão ser atualizados de forma assíncrona por meio de:

* WebSockets
* ou mecanismos de polling

Isso permitirá que mudanças relevantes sejam refletidas na interface do usuário sem necessidade de atualização manual.

---

### 🧠 Visão Geral

De forma geral, a arquitetura segue um fluxo simples e bem definido:

* clientes interagem com o backend via HTTP
* o backend processa requisições aplicando regras de negócio
* os dados são persistidos em banco relacional
* eventos relevantes podem ser publicados para processamento assíncrono

Essa organização mantém o sistema compreensível no presente, ao mesmo tempo em que possibilita sua evolução para cenários mais complexos.

## 🗯️ Diagrama Arquitetural

![RepFinder - DA](./images/RepFinder%20-%20DA.png)

> **Protocolos:** clientes → backend via HTTP/REST com JWT Bearer.  
> Backend → banco via TCP (pool MySQL). Backend → MOM via AMQP (RabbitMQ) ou Redis Pub/Sub.  
> MOM → clientes via WebSocket ou polling assíncrono (Sprint 3/4).
