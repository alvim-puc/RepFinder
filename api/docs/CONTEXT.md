# RepFinder API

## 📌 Contexto do Problema

A busca por moradia universitária, especialmente em repúblicas, ainda ocorre de forma majoritariamente informal. Estudantes dependem de redes sociais, indicações ou grupos fechados para encontrar vagas, enquanto representantes de repúblicas enfrentam dificuldade para organizar e filtrar candidatos de forma estruturada.

Esse cenário gera alguns desafios recorrentes:

* Falta de centralização das informações sobre vagas disponíveis
* Dificuldade em comparar candidatos de forma justa e organizada
* Comunicação fragmentada entre interessados e representantes
* Ausência de histórico ou rastreabilidade nas interações

Diante disso, surge a necessidade de um sistema que organize esse processo, permitindo que vagas sejam divulgadas de forma estruturada e que candidatos possam se apresentar de maneira padronizada.

---

## 🎯 Proposta da Aplicação

O **RepFinder** surge como uma solução para mediar essa relação, organizando o fluxo entre quem oferece vagas e quem busca moradia.

A aplicação propõe um ambiente onde:

* Representantes de repúblicas possam divulgar oportunidades
* Estudantes possam demonstrar interesse de forma estruturada
* O processo de seleção seja mais transparente e rastreável

Mais do que apenas conectar usuários, o sistema busca **organizar um processo que hoje é difuso e pouco padronizado**.

---

## 🧠 Direcionamento do Projeto

Desde o início, o desenvolvimento foi guiado por uma preocupação dupla:

> **manter simplicidade na implementação sem comprometer a capacidade de evolução do sistema**

Isso significa que decisões não foram tomadas apenas com base no que é mais rápido de implementar, mas também considerando:

* clareza do código
* previsibilidade do comportamento
* facilidade de manutenção
* possibilidade de expansão futura

---

## 🧱 Organização da Aplicação

A estrutura da aplicação reflete diretamente os elementos centrais do problema: usuários, vagas e aplicações.

Mais do que uma divisão técnica, essa organização busca alinhar o código com o domínio da aplicação, facilitando o entendimento e reduzindo o acoplamento entre partes distintas do sistema.

Cada domínio é tratado de forma isolada, permitindo que mudanças em uma área tenham impacto mínimo nas demais. Essa separação também favorece a evolução incremental, já que novas funcionalidades podem ser adicionadas sem comprometer o restante da aplicação.

---

## 🏗️ Arquitetura

A aplicação adota uma abordagem de **monólito modular**, onde todas as funcionalidades estão no mesmo projeto, mas organizadas em módulos independentes.

Essa escolha representa um equilíbrio entre dois extremos:

* sistemas totalmente centralizados e difíceis de evoluir
* arquiteturas distribuídas complexas desde o início

Dentro de cada módulo, a estrutura é dividida em camadas com responsabilidades bem definidas:

* **entrada (HTTP)**: responsável por lidar com requisições e respostas
* **regras de negócio**: onde as decisões do domínio são aplicadas
* **persistência**: responsável pelo acesso aos dados

Essa separação permite que o sistema mantenha um fluxo claro de execução, evitando que regras importantes fiquem espalhadas ou implícitas.

Além disso, essa organização já antecipa uma possível evolução para arquiteturas mais distribuídas, onde módulos podem ser extraídos sem necessidade de reestruturação profunda.

---

## ⚙️ Tecnologias e Abordagem

A escolha das tecnologias foi orientada por três princípios:

* reduzir complexidade desnecessária
* manter controle sobre o comportamento do sistema
* utilizar ferramentas já consolidadas no ecossistema

### 🟦 Ambiente de execução

A aplicação utiliza **Node.js** com **TypeScript**, combinando a flexibilidade do JavaScript com a segurança da tipagem estática.

A tipagem não é apenas uma escolha de linguagem, mas uma ferramenta para:

* garantir consistência de dados
* documentar contratos entre partes do sistema
* reduzir erros em tempo de execução

---

### 🌐 Camada HTTP

Foi adotado o **Hono** como framework HTTP.

A escolha por uma ferramenta mais leve está diretamente ligada à proposta do projeto:

* evitar abstrações excessivas
* manter controle explícito sobre o fluxo das requisições
* reduzir dependências desnecessárias

Isso permite que a aplicação permaneça simples, sem abrir mão de organização.

---

### 🗄️ Persistência de dados

Para armazenamento, foi escolhido o **MariaDB**, acessado via driver `mysql2`.

A interação com o banco é feita por meio de SQL direto, evitando o uso de ORMs.

Essa decisão foi tomada para:

* manter transparência nas operações realizadas
* evitar camadas adicionais de abstração
* facilitar o entendimento do comportamento das queries

Embora isso exija maior atenção na escrita do código, também oferece maior controle e previsibilidade.

---

### ⚡ Execução e desenvolvimento

A utilização de ferramentas como `tsx` permite executar código TypeScript diretamente, reduzindo o ciclo de desenvolvimento e tornando o processo mais fluido.

---

## 🧠 Decisões de Projeto

Ao longo do desenvolvimento, algumas diretrizes foram mantidas de forma consistente:

* evitar abstrações antes que elas sejam realmente necessárias
* manter responsabilidades bem definidas entre as camadas
* centralizar regras de negócio em pontos previsíveis
* tratar tipagem como parte fundamental do design

Essas decisões contribuem para um código mais legível e reduzem o risco de inconsistências à medida que o sistema cresce.

---

## 🗄️ Persistência de Dados

A camada de dados foi pensada para ser simples e funcional, garantindo:

* consistência das informações
* integridade entre entidades relacionadas
* facilidade de inicialização do ambiente de desenvolvimento

A criação automática das tabelas durante a inicialização da aplicação reduz barreiras de entrada e facilita testes e experimentação, especialmente em ambientes locais.

---

## 🔜 Perspectiva de Evolução

Embora o sistema atual seja síncrono e centralizado, ele foi pensado considerando possíveis evoluções, como:

* processamento assíncrono de eventos
* desacoplamento de responsabilidades
* crescimento da base de usuários e volume de dados

A estrutura modular adotada permite que essas evoluções ocorram de forma gradual, sem necessidade de reescrita completa do sistema.

---

## 📌 Considerações Finais

O RepFinder não busca apenas resolver um problema técnico, mas organizar um processo social que hoje ocorre de maneira desestruturada.

O projeto equilibra:

* simplicidade na implementação
* clareza nas regras de negócio
* preparação para crescimento

A proposta não é antecipar complexidade, mas também não ignorar a necessidade de evolução — mantendo o sistema compreensível hoje e adaptável amanhã.
