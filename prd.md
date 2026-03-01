Product Requirements Document (PRD)

1. Visão Geral do Produto

Nome do Produto: Ekklesia Gestão (Conectando Fé e Tecnologia: Software para a Igreja)

Desenvolvedores: Brendo Cesar dos Reis Chagas e Blender Alex dos Reis Chagas

Objetivo Principal: Desenvolver um software em Flutter utilizando a linguagem Dart para auxiliar no gerenciamento de atividades da igreja. O sistema controlará cadastros de membros, doações, finanças, além de gerenciar eventos e permissões de acesso.

2. Escopo e Público-Alvo

Setor de Aplicação: Comunidade religiosa local da cidade de Santa Rita do Sapucaí-MG.

Alinhamento ODS:

- Indústria, inovação e infraestrutura
- Cidades e comunidades sustentáveis
- Paz, justiça e instituições eficazes

3.  Requisitos Funcionais (RF)

RF01 - Autenticação de Usuários: O sistema deve permitir que usuários se cadastrem e façam login. Existirão duas categorias de acesso: membro (permissões de visualização) e administrador (permissões de edição).

RF02 - Visualizar Despesas: O sistema deve permitir que usuários cadastrados vejam uma lista das despesas da igreja , exibindo no mínimo data, valor e motivo/descrição do gasto.

RF03 - Gerenciar Despesas (Administrador): O usuário com permissão de administrador poderá inserir novas despesas , além de editar ou remover registros financeiros já existentes.

RF04 - Visualizar Membros: O aplicativo apresentará uma lista de membros com informações básicas, como nome completo e cargo/função.

RF05 - Gerenciar Membros (Administrador): Administradores poderão adicionar novos membros, editar informações de cadastros existentes e remover membros do sistema em caso de mudança ou falecimento.

RF06 - Filtros de Busca: As listas de despesas e de membros devem possuir opções de filtro por nome para facilitar a consulta rápida.

4. Requisitos Não Funcionais (RNF)

RNF01 - Segurança e Privacidade: O sistema garantirá que apenas usuários autenticados acessem informações restritas. O armazenamento seguro de senhas e a gestão de sessões serão tratados nativamente pela autenticação do Supabase.

RNF02 - Desempenho: O tempo de resposta para carregar as listas não deve ultrapassar 2 segundos em condições normais de conexão. O sistema deve suportar um volume adequado de requisições simultâneas.

RNF03 - Usabilidade: A interface será simples e intuitiva, permitindo o uso fluido por membros sem conhecimento técnico avançado.

RNF04 - Portabilidade e Tecnologia: O código será desenvolvido nativamente em Dart através do Flutter. O aplicativo rodará inicialmente em dispositivos Android. O back-end e o banco de dados serão hospedados e escalados via Supabase. Durante as fases de teste, a geração e distribuição do APK de homologação será conduzida utilizando o Google Antigravity.

RNF05 - Manutenibilidade: O código deve ser organizado de forma modular, possibilitando atualizações e manutenções futuras sem quebra sistêmica.

5. Cronograma e Metodologia
   O ciclo de desenvolvimento segue o fluxo de atividades mapeado para o projeto, com otimizações técnicas decorrentes do uso de BaaS (Supabase):

Atividade A: Levantamento de Dados - 5 dias

Atividade B: Criar o Design do App - 8 dias

Atividade C: Aprovação do Design - 2 dias

Atividade D & G: Modelagem de Banco de Dados e API (Supabase) - 15 a 20 dias (Unificadas)

Atividade E: Criar Front End do App - 15 dias

Atividade F: Testar Banco de Dados - 5 dias

Atividade H: Controle de Qualidade do App - 4 dias

Atividade I: Integração do Back End no Front End (Consumo da API Supabase) - 12 dias

Atividade J: Testes de UI e UX - 12 dias

Atividade K: Teste de Campo - 20 dias
