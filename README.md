# Ekklesia Gestão

Conectando Fé e Tecnologia: Software para a Igreja.

## Visão Geral

O **Ekklesia Gestão** é um software em Flutter projetado para auxiliar no gerenciamento das atividades da igreja local de Santa Rita do Sapucaí-MG. Desenvolvido por Brendo Cesar dos Reis Chagas e Blender Alex dos Reis Chagas, o projeto consolida o controle de membros, gestão financeira (doações e despesas), eventos e permissões de acesso em uma plataforma unificada e intuitiva.

## Principais Funcionalidades

- **Autenticação Segura:** Login e cadastro com níveis de acesso (Membro para visualização, Administrador para edição), integrados com Supabase.
- **Gestão de Membros:** Lista de membros com busca rápida e, para administradores, controle total de adições, atualizações ou remoções.
- **Gestão Financeira:** Acompanhamento transparente das finanças, permitindo a visualização das despesas registradas e o controle ativo por administradores.
- **Responsividade:** Interface intuitiva otimizada para ser acompanhada em dispositivos móveis, tablets e TV boxes.

## Tecnologias e Arquitetura

- **Front-end:** Flutter / Dart
- **Back-end e Banco de Dados (BaaS):** Supabase

## Primeiros Passos

1. Certifique-se de ter o [Flutter](https://docs.flutter.dev/get-started/install) instalado.
2. Clone este repositório.
3. Instale as dependências do projeto:
   ```bash
   flutter pub get
   ```
4. Configure as variáveis de ambiente necessárias (Supabase URL e Anon Key).
5. Execute o aplicativo:
   ```bash
   flutter run
   ```

_Nota: Em ambiente Windows devidamente configurado, é possível testar a compilação do aplicativo gerando um APK temporário através do script `gerar_apk.bat`._
