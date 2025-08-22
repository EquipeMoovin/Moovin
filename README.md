# Moovin

## 📌 Descrição do Projeto
Moovin visa conectar locatários e inquilinos, proporcionando um ambiente seguro para a busca, anúncio e gerenciamento de imóveis para aluguel. Além disso, oferecerá funcionalidades adicionais para facilitar a administração dos contratos e aprimorar a experiência do usuário. O compromisso com a segurança se reflete na verificação de perfis e autenticação de usuários, a transparência será promovida por meio de avaliações e relatórios detalhados, e a eficiência será garantida com filtros avançados, notificações inteligentes e comunicação ágil.




## 🧠 Disciplina
Projeto de Sistemas - Ciência da Computação

Universidade: Universidade Federal do Tocantins  

📚 Professor: Edeilson Milhomem

---
## 👥 Integrantes
| Nome                        | GitHub                                           |
|----------------------------|---------------------------------------------      |
| Victhor Cabral Magalhães   | [@VicthorCM](https://github.com/VicthorCM)        |
| João Vitor Reis Dias       | [@joaovitro99l](https://github.com/joaovitro99)   |
| Ana Júlia Campos Vieira    | [@Ana4Julia](https://github.com/Ana4Julia)        |
| Mayconn Cardoso Soares     | [@Mayconncs](https://github.com/Mayconncs)        |
| Pedro Lucas Moreira Pinto  | [@Swampertian](https://github.com/Swampertian)    |
---

## 🔗 Links Importantes
- Repositório do projeto: [link aqui]
- Documentação: [link aqui]
- Protótipo no Figma: [link aqui]
- Apresentações ou relatórios: [link aqui]

---
## 🎯 Escopo

### 📝 Introdução
O projeto **Moviin** consiste no desenvolvimento de um aplicativo para busca, oferta e aluguel de imóveis, conectando locatários e inquilinos de forma prática e segura. O sistema contará com funcionalidades básicas como cadastro, pesquisa e negociação de imóveis, além de recursos extras para gerenciamento de contratos e imóveis, disponíveis em um plano premium.

### 🎯 Objetivo
Criar um ambiente confiável para que locatários e inquilinos possam interagir, negociar e gerenciar imóveis. O app será centrado nos pilares de **segurança** (com autenticação e verificação de perfis), **transparência** (com avaliações e relatórios), e **eficiência** (com filtros inteligentes, notificações e comunicação ágil).



### ✅ Requisitos Funcionais

- **RF 01:** Cadastro de usuários (locatários e inquilinos)  
- **RF 02:** Cadastro, edição e exclusão de imóveis (CRUD)  
- **RF 03:** Pesquisa de imóveis com filtros avançados  
- **RF 04:** Exibição de fotos dos imóveis  
- **RF 05:** Chat seguro entre inquilino e locatário  
- **RF 06:** Exibição de perfil de locatários e inquilinos  
- **RF 07:** Sistema de avaliação para usuários e imóveis  
- **RF 08:** Notificações automáticas  
- **RF 09:** Perfil detalhado dos imóveis  
- **RF 10:** Aluguel por temporada  
- **RF 11:** Plano premium para inquilinos e proprietários  
- **RF 12:** Opção de aluguéis compartilhados  
- **RF 13:** Suporte ao cliente  
- **RF 14:** Parcerias com prestadores de serviços  
- **RF 15:** Verificação de perfis



### 💎 Funcionalidades Premium – Proprietário

- RF 16: Armazenamento de contratos  
- RF 17: Gerenciamento avançado de imóveis  
- RF 18: Geração de relatórios  
- RF 19: Agendamento de visitas  
- RF 20: Acompanhamento de prazos de aluguel  
- RF 21: Notificações sobre vencimento de contratos  
- RF 22: Notificações de pagamento  
- RF 23: Armazenamento de imagens da vistoria  
- RF 24: Registro de visitas no calendário  
- RF 25: Histórico de manutenções  
- RF 26: Maior visibilidade para anúncios

### 💎 Funcionalidades Premium – Inquilino

- RF 27: Notificações antecipadas sobre novos imóveis



### 💰 Fontes de Receita

- Assinaturas de planos premium  
- Parcerias com prestadores de serviços  
- Parcerias com imobiliárias  
- Publicidade e marketing



### 🛠️ Tecnologias Utilizadas
- **Backend:** Django  
- **Frontend:** Flutter (Dart)  
- **Banco de Dados:** PostgreSQL  
- **Versionamento:** Git e GitHub


### 🧩 Observações Finais
O escopo poderá ser ajustado ao longo do projeto conforme necessário, mantendo o foco em segurança, transparência e eficiência como fundamentos do aplicativo Moviin.

---

## 🏃‍♂️ Sprints

### 📅 Sprint 1 – Modelagem do Banco e Funcionalidades Básicas
📆 **Período:** 07/04 a 21/04  
📋 **Objetivo:** Modelar o banco de dados e fornecer funcionalidades básicas para o usuário.  
🎯 **Valor da Sprint:** Permitir registro, autenticação, criação de perfis e gerenciamento de imóveis.

#### ✅ Requisitos da Sprint:

1. **Criar o banco de dados e tabelas**
   - **Responsáveis:** Mayconn, Ana Julia, Victhor, Pedro Lucas e João Vitor
   - **Descrição:** Criar o banco de dados e tabelas no modelo relacional
   - **Revisores:** Todos os responsáveis

2. **Implementar operações CRUD para usuários**
   - **Responsável:** Victhor
   - **Descrição:** Criar API para cadastro, atualização, remoção e listagem de usuários
   - **Revisores:** Pedro Lucas e Mayconn

3. **Desenvolver login e registro de usuários (frontend e backend)**
   - **Responsáveis:** Ana Júlia e Victhor
   - **Descrição:** Formulários com autenticação JWT
   - **Revisor:** João Vitor

4. **Criar e visualizar perfis de inquilino e proprietário (frontend e backend)**
   - **Responsáveis:** Pedro e Mayconn
   - **Descrição:** Edição e exibição de perfil com foto e informações. Inclui protótipo da tela "Criar perfil"
   - **Revisora:** Ana Julia

5. **Implementar operações CRUD para os imóveis**
   - **Responsável:** João Vitor
   - **Descrição:** API para adicionar, editar, excluir e visualizar imóveis
   - **Revisor:** Victhor


### 📅 Sprint 2 – Gerenciamento e detalhamento de Imóveis, Criação de Perfis e Avaliações   
📆 **Período:** 28/04 a 11/05  
📋 **Objetivo:** Desenvolver a tela de detalhes do imóvel, criar a tela de criação de perfil, estabelecer um sistema de avaliação de usuários e imóveis e permitir o gerenciamento de imóveis para proprietários.  
🎯 **Valor da Sprint:**  
Permitir que os usuários personalizem seus perfis com informações pessoais, promovendo uma experiência mais personalizada e segura. Também facilitará a tomada de decisão dos usuários, fornecendo detalhes completos sobre os imóveis anunciados e implementando um sistema de avaliações de imóveis e usuários, aumentando a confiabilidade da plataforma. Além disso, os proprietários terão acesso a ferramentas de gerenciamento e relatórios, otimizando a administração de seus imóveis anunciados.

---

#### 🗓️ Cronograma:
- **Início:** 28/04  
- **Primeira Revisão:** 05/05  
- **Segunda Revisão:** 09/05  
- **Entrega Final:** 10/05  

---

#### ✅ Requisitos da Sprint:

1. **Gerenciamento avançado de imóveis pelo proprietário**  
   - **Responsável:** Victhor  
   - **Descrição:** Desenvolver o Frontend e Backend do gerenciamento de imóveis, permitindo edição, visualização e exclusão pelos proprietários.  
   - **Revisor:** Mayconn  

2. **Geração de relatórios sobre imóveis alugados e anunciados**  
   - **Responsável:** Mayconn  
   - **Descrição:** Desenvolver o Frontend e Backend para o gerenciamento dos dados de imóveis alugados e anunciados, incluindo geração de relatórios detalhados.  
   - **Revisor:** Victhor  

3. **Sistema de avaliação para inquilinos, locatários e imóveis**  
   - **Responsáveis:** Pedro Lucas e João Vitor  
   - **Descrição:** Desenvolver o Frontend e Backend para as funcionalidades de avaliar usuários e imóveis, bem como exibir avaliações já realizadas.  
   - **Revisores:** Victhor 

4. **Perfil detalhado dos imóveis cadastrados**  
   - **Responsável:** João Vitor  
   - **Descrição:** Desenvolver o Frontend da tela de detalhes do imóvel no aplicativo mobile, exibindo todas as características e informações relevantes do imóvel selecionado.  
   - **Revisora:** Ana Júlia  

5. **Desenvolver tela “Criar Perfil” para os usuários**  
   - **Responsável:** Ana Júlia  
   - **Descrição:** Desenvolver o Frontend da tela de criação de perfil no aplicativo mobile, com integração ao Backend via requisição API.  
   - **Revisor:** João Vitor  
---

## 🚀 MVP (Produto Mínimo Viável)

---

## 🧪 Protótipos
- Versão final no [Figma](https://www.figma.com/design/Y1FgOveRfAKnDERhYwlbF4/Untitled?node-id=32-2&t=Xh5WSWHNx7wfXYiD-1)

---


