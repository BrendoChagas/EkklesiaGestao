# Ekklesia Gestão

Conectando Fé e Tecnologia: Software para a Igreja.

## Visão Geral

O **Ekklesia Gestão** é um software em Flutter projetado para auxiliar no gerenciamento das atividades da igreja local de Santa Rita do Sapucaí-MG. Desenvolvido por Brendo Cesar dos Reis Chagas e Blender Alex dos Reis Chagas, o projeto consolida o controle de membros, gestão financeira (doações e despesas), eventos e permissões de acesso em uma plataforma unificada e intuitiva.

Com as adições recentes, o app agora conta com uma **Visão Geral (Dashboard)** responsiva que traz um resumo financeiro e social da igreja logo na inicialização.

## Principais Funcionalidades

- **Autenticação Segura:** Login e cadastro com níveis de acesso (Membro para visualização, Administrador para edição), integrados com Supabase.
- **Dashboard / Visão Geral:** Tela principal responsiva (Stacking cards para Mobile e Row para Desktop/Tablets) que exibe o total instantâneo de membros cadastrados e as despesas totais, além de ações rápidas.
- **Gestão de Membros:** Lista de membros com busca rápida e, para administradores, controle total de adições (via **Supabase Edge Functions** para garantir a segurança no gerenciamento de contas do Auth), atualizações e remoções.
- **Gestão Financeira:** Acompanhamento transparente das finanças, permitindo a visualização flexível (layout auto-ajustável via `Row` com `Expanded`) e o controle ativo das despesas por administradores.
- **Responsividade:** Interface intuitiva e adaptativa construída para escalar perfeitamente em dispositivos móveis (Android/iOS), tablets, web e telas amplas.

## Tecnologias e Arquitetura

- **Front-end / App Client:** Flutter / Dart (Utilizando `flutter_riverpod` para injeção de dependências e estado reativo).
- **Back-end e Banco de Dados (BaaS):** Supabase (Postgres, Auth).
- **Serverless / Edge Functions:** Funcionalidades protegidas escritas em Deno e TypeScript para criação segura de usuários no Auth.

## Primeiros Passos

1. Certifique-se de ter o [Flutter](https://docs.flutter.dev/get-started/install) instalado.
2. Clone este repositório.
3. Instale as dependências do projeto:
   ```bash
   flutter pub get
   ```
4. Configure as variáveis de ambiente necessárias (Supabase URL e Anon Key).
5. Certifique-se que o schema do Supabase esteja atualizado e que a Edge Function `create_member` esteja em deploy no seu projeto, caso vá utilizar um banco de testes diferente da produção:
   ```bash
   supabase functions deploy create_member --no-verify-jwt
   ```
6. Execute o aplicativo:
   ```bash
   flutter run
   ```

_Nota: Em ambiente de desenvolvimento, é possível testar a compilação paralela do aplicativo gerando um APK temporário através do script `gerar_apk.bat` ou pelo próprio build system do Flutter `flutter build apk`._
