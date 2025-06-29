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
- APK: [link aqui]
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

### 📅 Sprint 3 – Notificações, Planos Premium e Melhorias de Usabilidade  
📆 **Período:** 12/05 a 26/05  

📋 **Objetivo:** Melhorar a experiência do usuário com notificações, agendamento de visitas, acompanhamento de prazos, plano premium, permissões e usabilidade geral.  

🎯 **Valor da Sprint:** Proporcionar recursos mais dinâmicos e exclusivos aos usuários, aumentar o engajamento e garantir maior segurança e organização no acesso às funcionalidades.

---

#### ✅ Requisitos da Sprint:



1. **Sistema de Notificações**
   - **Responsável:** Mayconn  
   - **Revisores:** Pedro e Ana Júlia  
   - **Descrição:** Criar sistema de notificações em tempo real para alertar os usuários sobre eventos importantes, como mensagens, avaliações ou prazos de aluguel.  
   - **Funcionalidades:**
     - Criação de tabela de notificações no banco de dados  
     - API para envio de notificações por tipo de evento  
     - Suporte a WebSocket ou push notifications  
     - Endpoint para marcar notificações como lidas  
     - Exibição no frontend com ícones e tela dedicada  
     - Preferências de notificações configuráveis pelo usuário  



2. **Acompanhamento de Prazos de Aluguel**
   - **Responsável:** João Vitor  
   - **Revisores:** Victhor e Mayconn  
   - **Descrição:** Permitir que o usuário acompanhe os prazos de seus aluguéis ativos e seja notificado sobre renovações e encerramentos.  
   - **Funcionalidades:**
     - API para consulta dos aluguéis do usuário  
     - Sistema de alertas com antecedência (ex.: 3 dias antes)  
     - Tela para exibir e gerenciar aluguéis ativos, passados e futuros  
     - Opções para marcar como renovado ou encerrado  
     - Visualização clara dos prazos e status de cada aluguel  



3. **Agendamento de Visitas a Imóveis**
   - **Responsável:** Pedro Lucas  
   - **Revisores:** João Vitor e Ana Júlia  
   - **Descrição:** Desenvolver funcionalidade de agendamento de visitas, exclusiva para usuários premium, com controle de datas e status.  
   - **Funcionalidades:**
     - Tabela para armazenar solicitações de visitas  
     - API para criação, confirmação e cancelamento de visitas  
     - Validação de horários disponíveis  
     - Interface com calendário interativo  
     - Tela de histórico de visitas e seus status  
     - Integração completa com backend  



4. **Plano Premium para Inquilinos e Proprietários**
   - **Responsável:** Victhor  
   - **Revisor:** Mayconn  
   - **Descrição:** Desenvolver o sistema de controle de planos premium e seus acessos, com gerenciamento de assinaturas e liberação de funcionalidades exclusivas.  
   - **Funcionalidades:**
     - Backend com tabelas para assinaturas e status  
     - API para verificar e renovar plano premium  
     - Controle de acesso a funcionalidades exclusivas (como agendamento)  
     - Tela para exibir plano atual e adquirir assinatura  
     - Alertas de expiração e renovação  



5. **Refatorar Permissões do Backend**
   - **Responsável:** Victhor  
   - **Revisor:** Pedro  
   - **Descrição:** Refatorar o sistema de permissões no backend para garantir controle seguro e organizado de acesso baseado em tipo de usuário.  
   - **Funcionalidades:**
     - Criação de sistema de roles (funções) no backend  
     - APIs protegidas por permissões específicas  
     - Validações por tipo de usuário (inquilino, proprietário, admin)  
     - Adaptação do frontend para respeitar os níveis de acesso  
     - Feedback visual em caso de acesso negado  


6. **Menus de Navegação e Refatoração de Telas**
   - **Responsável:** Ana Júlia  
   - **Revisores:** João Vitor e Victhor  
   - **Descrição:** Melhorar a usabilidade do app com navegação intuitiva e organização clara das telas.  
   - **Funcionalidades:**
     - Refatoração do fluxo de navegação com menus claros e acessíveis  
     - Implementação de componentes como BottomNavigationBar ou Drawer  
     - Organização por categorias e ícones orientativos  
     - Exibição de dados dinâmicos nas telas (perfil, imóveis, favoritos)  
     - Integração com permissões e autenticação  
     - Backend preparado para fornecer os dados necessários  



### 📅 Sprint 4 – Integrações Críticas e Comunicação entre Usuários  
📆 **Período:** 26/05 a 09/06 

📋 **Objetivo:** Implementar funcionalidades críticas como sistema de pagamento, recuperação de senha, chat entre usuários e landing page.  

🎯 **Valor da Sprint:** Proporcionar uma experiência segura, interativa e integrada no Moovin, com foco em serviços externos, segurança e comunicação.

---

#### ✅ Requisitos da Sprint:


1. **Integração com API de Pagamento**
   - **Responsável:** Victhor  
   - **Revisor:** Mayconn  
   - **Descrição:** Integrar o Moovin com o Stripe, permitindo transações seguras no app. A interface será feita com Flutter e o backend em Django validará as operações.  
   - **Funcionalidades:**
     - Integração com Stripe via SDK ou API REST  
     - Tela de seleção de assinatura e execução do pagamento  
     - Endpoint Django para webhooks de pagamento  
     - Armazenamento seguro de transações  
     - Feedback em tempo real ao usuário  


2. **Chat de Mensagens**
   - **Responsáveis:** Mayconn e Pedro  
   - **Revisor:** João Vitor  
   - **Descrição:** Desenvolver chat em tempo real entre usuários usando Flutter e backend Django com autenticação JWT e persistência de mensagens.  
   - **Funcionalidades:**
     - Interface de chat com envio e recebimento em tempo real  
     - Controle de acesso e autenticação JWT  
     - Status de mensagens: enviadas, entregues e lidas  
     - Integração com sistema de notificações  
     - Funcionalidades extras para usuários premium:
       - Registro de visitas  
       - Registro de aluguéis  


3. **Recuperação de Senha ("Esqueci minha senha")**
   - **Responsável:** João Vitor  
   - **Revisores:** Ana Júlia e Pedro  
   - **Descrição:** Criar fluxo seguro de redefinição de senha via e-mail, com geração de token, envio automático e validação no backend.  
   - **Funcionalidades:**
     - Tela de solicitação de recuperação no Flutter  
     - Backend para geração de token temporário  
     - Envio automático de e-mail com link de redefinição  
     - Validação do token e redefinição da senha  
     - Expiração automática de tokens  
     - Feedback claro ao usuário  


4. **Landing Page do Produto**
   - **Responsável:** Ana Júlia  
   - **Revisor:** Victhor  
   - **Descrição:** Criar página de apresentação do Moovin com identidade visual moderna, minimalista e responsiva, promovendo o app e o plano premium.  
   - **Funcionalidades e Seções:**
     1. **Topo da Página:**  
        - Nome e slogan  
        - Mockup do app  
        - Botões “Baixar APK” e “Assine agora”  
     2. **Descrição e Benefícios:**  
        - Texto explicativo sobre o Moovin  
        - Lista de funcionalidades  
        - Depoimentos ou cases de sucesso  
     3. **Diferenciais do Moovin:**  
        - Destaque para vantagens competitivas (facilidade, transparência, etc.)  
     4. **Plano Premium para Proprietários:**  
        - Benefícios exclusivos  
        - Tabela comparativa entre planos  
        - Botão de assinatura destacado  
     5. **Instruções para Download:**  
        - Link direto, QR Code e orientações sobre APK  
     6. **FAQ:**  
        - Dúvidas frequentes (assinatura, segurança, senha)  
   - **Funcionalidades Técnicas:**
     - Redirecionamento para checkout no botão “Assine agora”  
     - Link direto para download do APK  

### 📅 Sprint 5 – Melhorias Visuais, Avaliações e Funcionalidades de Perfil  
📆 **Período:** 10/06 a 24/06  
📋 **Objetivo:** Corrigir pendências identificadas durante o uso do aplicativo, implementar funcionalidades de avaliação e gerenciamento de aluguéis, além de aprimorar a experiência de navegação e criação de perfis.  
🎯 **Valor da Sprint:** Corrigir falhas críticas e agregar novas funcionalidades que melhoram a usabilidade, fluidez e confiabilidade do sistema, com foco em avaliações, perfis e interface.


#### ✅ Requisitos da Sprint:


1. **Ajustar exibição de avaliações e imagens no search-immobile**
   - **Responsável:** João Vitor  
   - **Revisor:** Mayconn  
   - **Descrição:** Exibir corretamente a média das avaliações reais de cada imóvel e carregar suas imagens na listagem de busca.  
   - **Funcionalidades:**
     - Ajuste da lógica de cálculo e exibição da nota do imóvel  
     - Integração com banco de dados de imagens para exibição no card de busca  


2. **Inserir foto ao criar perfil**
   - **Responsável:** Pedro Lucas  
   - **Revisor:** Victhor  
   - **Descrição:** Adicionar campo de upload de imagem ao formulário de criação de perfil.  
   - **Funcionalidades:**
     - Upload de imagem no Flutter  
     - Armazenamento da imagem no backend  
     - Exibição da imagem de perfil após criação  


3. **Adicionar botão de "Alugar" nos detalhes do imóvel**
   - **Responsável:** Mayconn  
   - **Revisor:** João Vitor  
   - **Descrição:** Criar botão de ação que leve o usuário direto ao chat com o proprietário, com envio automático de mensagem padrão.  
   - **Funcionalidades:**
     - Botão fixo no detalhe do imóvel  
     - Redirecionamento automático para o chat  
     - Envio de mensagem como "Olá! Tenho interesse neste imóvel."  


4. **Direcionamento automático para perfil de Owner ou Tenant**
   - **Responsável:** Mayconn  
   - **Revisor:** Pedro  
   - **Descrição:** Implementar lógica de direcionamento condicional para o tipo de perfil (proprietário ou inquilino) conforme o tipo de usuário logado.  
   - **Funcionalidades:**
     - Verificação do tipo de perfil no login  
     - Renderização dinâmica da navbar e redirecionamento correto  


5. **Refatorar tela de detalhes do imóvel (Frontend)**
   - **Responsável:** Ana Júlia  
   - **Revisor:** Ana Júlia  
   - **Descrição:** Melhorar o design visual e organização dos elementos da tela de detalhes para torná-la mais intuitiva e consistente.  
   - **Funcionalidades:**
     - Ajustes no layout (cores, espaçamento, botões)  
     - Padronização com restante do app  


6. **Resolver problemas na criação de perfil**
   - **Responsável:** Pedro Lucas 
   - **Revisor:** Mayconn  
   - **Descrição:** Corrigir erros e bugs que impedem ou dificultam o processo de criação de perfil.  
   - **Funcionalidades:**
     - Verificação de campos obrigatórios  
     - Tratamento de erros no backend e frontend  
     - Testes de fluxo completo de criação  


7. **Exibir informações do proprietário na página de detalhes do imóvel**
   - **Responsável:** Ana Júlia e Victhor
   - **Revisor:** Victhor  
   - **Descrição:** Permitir que o usuário visualize o perfil do proprietário ao acessar os detalhes de um imóvel.  
   - **Funcionalidades:**
     - Link ou botão “Ver proprietário”  
     - Exibição de informações básicas do perfil (nome, foto, avaliações)  


8. **Permitir avaliações de perfis (proprietário e inquilino)**
   - **Responsável:** João Vitor  
   - **Revisores:** Ana Júlia e João Vitor  
   - **Descrição:** Permitir que usuários avaliem mutuamente após uma locação concluída.  
   - **Funcionalidades:**
     - Backend para armazenar avaliações de usuários  
     - Tela de avaliação no app com nota e comentário  
     - Exibição da média de avaliações no perfil  


9. **Adicionar registro de aluguéis no painel do proprietário**
   - **Responsável:** Victhor  
   - **Revisor:** Pedro  
   - **Descrição:** Implementar tela no painel do proprietário com a listagem de aluguéis realizados e seus detalhes.  
   - **Funcionalidades:**
     - API para listagem de aluguéis vinculados ao proprietário  
     - Tela com imóveis alugados, datas e inquilino  
     - Filtros e ordenação por data ou imóvel  




## 🚀 MVP (Produto Mínimo Viável)

---

## 🧪 Protótipos
- Versão final no [Figma](https://www.figma.com/design/Y1FgOveRfAKnDERhYwlbF4/Untitled?node-id=32-2&t=Xh5WSWHNx7wfXYiD-1)

---


