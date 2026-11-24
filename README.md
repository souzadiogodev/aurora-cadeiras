# Aurora Cadeiras (PIM IV)

Sistema de automação da fábrica de cadeiras fictícia **Aurora Cadeiras**
(pedido → ordem de produção → etapas por estação → estoque → qualidade → expedição).
Projeto Integrado Multidisciplinar IV, Análise e Desenvolvimento de Sistemas, UNIP.

A especificação está em [`docs/`](docs/README.md); o contexto para o Claude Code, em [`CLAUDE.md`](CLAUDE.md).

## Status

Todas as fases de implementação (0 a 6) estão concluídas. A infraestrutura do Azure está escrita e validada offline,
mas não foi aplicada.

| Fase | Situação |
|---|---|
| 0 Esqueleto da solução | Concluída |
| 1a Banco (25 tabelas, procedures, triggers, segurança, seed) | Concluída, 37 testes de integração |
| 1b API base e autenticação (JWT, refresh, usuários, perfis, Swagger, health) | Concluída, 77 testes |
| 1c Cadastros básicos (produtos e matérias-primas), runner DbUp, Docker e CI | Concluída, 211 testes no total |
| 2a API da fase 2 (clientes, fornecedores, ficha técnica, roteiro, estações, pedidos, movimentos e ajuste de estoque) | Concluída |
| 2b Painel web (login por cookie, layout acessível, cadastros, produtos com ficha técnica e roteiro, pedidos) | Concluída |
| 3 Produção e estoque (confirmar pedido, OPs e etapas com baixa de estoque, perdas, alertas, quadro de produção, etiqueta com QR code, saldos e movimentos) | Concluída, 761 testes no total |
| 4a API do chão de fábrica (QR, fila da estação, sincronização offline, inspeção, expedição, acompanhamento) | Concluída |
| 4b App mobile (login, etapas, QR, apontamento offline, perda, inspeção, estoque, pedidos, cadastro de cliente offline) | Concluída, testado no emulador Android |
| 5a Compras (pedidos de compra, emissão, cancelamento e recebimento por item) | Concluída |
| 5b Painel gerencial e relatórios em PDF e Excel | Concluída |
| 5c Telas web de compras, expedição, painel e relatórios | Concluída |
| 6a Auditoria (histórico de alterações na API e tela do administrador) | Concluída |
| 6b Acessibilidade (axe e Lighthouse 100 nas telas do painel) | Concluída |
| 6c Nuvem (Bicep, workflows de deploy e infra, telemetria) | Concluída; validada offline, ainda não aplicada no Azure |

Total: 1.363 testes .NET e 242 testes do app.

## Estrutura

| Pasta | Conteúdo |
|---|---|
| `src/Aurora.Domain` | Entidades, enums, eventos e exceções de domínio |
| `src/Aurora.Application` | Casos de uso, DTOs, validadores, interfaces |
| `src/Aurora.Infrastructure` | EF Core, procedures, JWT, QR code, relatórios |
| `src/Aurora.Api` | Web API REST (composição das dependências) |
| `src/Aurora.Web` | Painel administrativo ASP.NET Core MVC (cliente tipado da API em `Api/`, sessão em cookie, telas por módulo) |
| `src/Aurora.DbUp` | Runner que aplica os scripts de `database/` (usado pelo Docker e por qualquer ambiente) |
| `tests/` | Domain, Application, Api (integração), Database (procedures e triggers), Web (painel) e Tests.Common (SQL Server de teste) |
| `database/` | Scripts SQL numerados `001` a `011` (schema, views, procedures, triggers, segurança, seed e as correções posteriores: idempotência, dia de negócio, revisão das regras) |
| `docker/` | Dockerfiles (api, web, dbup) e `docker-compose.yml` |
| `.github/workflows/` | CI (`ci.yml`), análise estática (`codeql.yml`), infraestrutura (`infra.yml`) e deploy (`deploy.yml`, `implantar.yml`) |
| `infra/` | Bicep do Azure (ACR, Container Apps, SQL, Key Vault, Storage, monitoramento); ver [`infra/README.md`](infra/README.md) |
| `mobile/aurora_mobile` | App mobile React Native (Expo + TypeScript, SQLite local), fora da solução .NET; ver [`README`](mobile/aurora_mobile/README.md) |
| `tools/acessibilidade` | Auditoria automática de acessibilidade do painel (axe e Lighthouse) |
| `docs/evidencias/` | Prints e diagramas usados no relatório |

## Comandos

```bash
dotnet build
dotnet test        # testes de banco e de API sobem um SQL Server em container (Docker aberto)
```

Para rodar os testes contra um SQL Server já instalado (sem Docker), defina `AURORA_TEST_SQL` com a
connection string do servidor; os bancos `aurora_test_*` são criados e apagados automaticamente.

## Subindo tudo com Docker

Requisitos: Git, Docker com containers **Linux** e as portas **1433**, **8080** e **8081** livres. A primeira subida
precisa de internet (imagens e pacotes). O app mobile não faz parte do compose (veja [App mobile](#app-mobile)).

Windows (PowerShell):

```powershell
git clone https://github.com/souzadiogodev/aurora-cadeiras.git
cd aurora-cadeiras
copy docker.env.example docker.env      # só na primeira vez: sobrescreve um .env existente
notepad docker.env                       # preencha as três variáveis abaixo
docker compose -f docker/docker-compose.yml up --build -d
```

Linux e macOS: os mesmos passos, com `cp docker/.env.example docker/.env` no lugar do `copy`.

| Variável | Regra |
|---|---|
| `SA_PASSWORD` | 8 ou mais caracteres, com maiúscula, minúscula, número e símbolo; sem `;`, `=` ou aspas. Não mude depois da primeira subida: o banco guarda a senha original |
| `JWT_KEY` | Texto aleatório com 32 ou mais caracteres |
| `SEED_ADMIN_PASSWORD` | 10 ou mais caracteres; com menos, o administrador não é criado |

Sobem, nesta ordem: `sql` (SQL Server 2022), `dbup` (aplica `database/*.sql` e termina), `api` e `web`.

| Endereço | O que é |
|---|---|
| http://localhost:8081 | Painel web (entre com `admin@aurora.local` e a senha de `SEED_ADMIN_PASSWORD`) |
| http://localhost:8080/health/ready | Saúde da API |
| http://localhost:8080/swagger | Swagger, só com `SWAGGER_HABILITADO=true` no `.env` |

O arquivo `docker/.env` é ignorado pelo Git. O banco começa com os dados de `database/006-seed.sql`.

Para parar e voltar depois, com os containers já criados (sem build):

```bash
docker compose -f docker/docker-compose.yml stop
docker compose -f docker/docker-compose.yml start
```

> `down -v` apaga o banco. Se a porta 1433 já estiver em uso, remova o bloco `ports` do serviço `sql`: a API usa a
> rede interna do Docker.

> No compose a API conecta como `sa`, só para o ambiente local. Em homologação e produção a conexão vem do
> Key Vault, com o login restrito `role_aurora_app` criado conforme `database/005-seguranca.sql`.

Para aplicar os scripts em um banco já existente, sem Docker:

```bash
ConnectionStrings__Aurora="<connection string>" dotnet run --project src/Aurora.DbUp
```

## Rodando a API localmente

1. Crie o banco e aplique os scripts de `database/` com o runner acima (ou na ordem `001` a `011`).
2. Configure os segredos fora do repositório:

```bash
cd src/Aurora.Api
dotnet user-secrets set "Jwt:Key" "<texto aleatório com 32 caracteres ou mais>"
dotnet user-secrets set "Seed:AdminPassword" "<senha do administrador inicial>"
dotnet run
```

3. Abra `/swagger` (ambiente Development), faça login em `POST /api/v1/auth/login` com `admin@aurora.local`
   e a senha de `Seed:AdminPassword`, e use o token no botão **Authorize**.

A connection string de desenvolvimento (`appsettings.Development.json`) usa a autenticação do Windows em
`localhost`, sem senha. Em hom/prod ela vem de `ConnectionStrings__Aurora` (Key Vault).

## Painel web

Com o ambiente de pé (`docker compose`), abra http://localhost:8081 e entre com `admin@aurora.local` e a senha
definida em `SEED_ADMIN_PASSWORD`. O painel só fala com a API (`Api__BaseUrl`); a sessão fica num cookie e o menu
mostra só as áreas do perfil. Sem Docker, rode a API e depois `dotnet run --project src/Aurora.Web` (a URL da API
de desenvolvimento está em `appsettings.Development.json`).

## Decisões

Registradas em [`docs/DECISOES.md`](docs/DECISOES.md).

## App mobile

```bash
cd mobile/aurora_mobile
npm install
npm run check                     # tipos, ESLint e testes
npx expo start --android          # emulador Android ou Expo Go
```

A URL da API vem de `EXPO_PUBLIC_API_BASE_URL`. O padrão é a porta 5011 (`dotnet run`); **com o Docker Compose a API
fica na 8080**, então defina antes de abrir o app:

```powershell
$env:EXPO_PUBLIC_API_BASE_URL="http://10.0.2.2:8080/api/v1"   # emulador; no celular use o IP do computador
npx expo start --android
```

Detalhes e perfis em [`mobile/aurora_mobile/README.md`](mobile/aurora_mobile/README.md).
