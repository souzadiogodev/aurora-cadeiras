# Evidências para o relatório

Prints em tema claro (pedido do professor). Os prints de código são do VS Code. A sugestão é intercalar: para cada
funcionalidade, a **tela** que o usuário vê e o **código** que a implementa.

## Roteiro sugerido (tela → código)

| # | Funcionalidade | Tela | Código |
|---|---|---|---|
| 1 | Arquitetura em camadas | `E06-estrutura-solucao.png` | `E06-codigo-entidade-pedido.png` (regra no domínio: só edita pedido Aberto) |
| 2 | Pedido de venda (RF07) | `E04-pedido-novo.png` | `E06-codigo-pedido-service.png` (confirmar, cancelar e "o vendedor só vê os próprios") |
| 3 | Confirmação gera OP ou reserva estoque (RN01, RN02) | `E04-quadro-producao.png` | `E07-codigo-sp-gerar-ordens-rn02.png` |
| 4 | Ficha técnica e roteiro (RF04, RF10) | `E04-ficha-tecnica.png` | `E07-der-logico.png` |
| 5 | Apontamento no app pelo QR (RF11) | `E05-minhas-etapas.png`, `E05-leitura-qr.png`, `E05-detalhe-etapa.png` | `E04-codigo-controller-etapas.png` (controller fino) |
| 6 | Baixa de matéria-prima e bloqueio sem saldo (RN03, RN04, RN05) | `E07-teste-procedure-saldo-insuficiente.png` | `E07-codigo-sp-iniciar-etapa.png` |
| 7 | Modo offline e sincronização (RF23) | `E05-modo-offline.png`, `E05-fila-sincronizacao.png` | `E05-codigo-sincronizacao-offline.png` |
| 8 | Inspeção e retrabalho (RN06) | `mobile/23-inspetor-formulario-aprovar.png`, `mobile/25-inspetor-formulario-reprovar.png` | `E07-codigo-sp-registrar-inspecao-rn06.png` |
| 9 | Expedição só de pedido Pronto (RN07) | `E04-expedicao.png` | `E05-pedido-cliente.png` (o cliente acompanha) |
| 10 | Compras e comunidades tradicionais (RF16, RF17) | `E04-compras.png` | `E04-relatorios.png` |
| 11 | Painel gerencial (RF20) | `E04-painel.png` | — |
| 12 | Auditoria (RNF10) | `E07-auditoria-exemplo.png` | — |
| 13 | Desempenho com índice | `E07-plano-execucao-antes.png` | `E07-plano-execucao-depois.png` |
| 14 | Testes automatizados | `E08-pipeline-ci.png` | `E06-codigo-teste-integracao-banco.png` |
| 15 | API REST documentada (RF24) | `E04-swagger.png` | — |
| 16 | Acessibilidade (RNF08) | `E04-lighthouse.png` | — |
| 17 | Infraestrutura | `E08-docker-compose.png`, `E08-arquitetura-nuvem.png` | `E08-pipeline-cd.png` |

## Código do painel web

| Arquivo | O que mostra |
|---|---|
| `E04-codigo-web-controller-pedidos.png` | Controller MVC: confirmação do pedido em duas etapas (tela de confirmação e POST), com permissão por perfil |
| `E04-codigo-web-view-detalhes-pedido.png` | View Razor: os botões aparecem conforme o perfil e a situação do pedido (só expede se Pronto) |
| `E04-codigo-web-cliente-api.png` | O painel só fala com a API por HTTP; erros da API viram mensagens na tela |
| `E04-codigo-web-renovacao-token.png` | Renovação automática do token JWT antes de expirar |
| `E04-codigo-web-situacoes.png` | Situações do pedido, da OP e da compra num único lugar (sem textos espalhados) |

Sugestão: intercalar `E04-pedido-novo.png` com o controller, e a tela de detalhes/expedição com a view.

## Banco de dados

`E07-diagrama-chen.png` é o diagrama completo em notação de Chen (25 tabelas). Para o texto, os recortes por módulo
leem melhor: `E07-diagrama-chen-vendas-producao.png`, `E07-diagrama-chen-estoque-compras.png` e
`E07-diagrama-chen-acesso-auditoria.png`.

## Pasta `mobile/`

Todos os prints do app (36), na ordem do teste: Operador, modo offline, Inspetor, Vendedor, Cliente e Gerente.

## Ainda falta

`E08-container-apps.png`, `E08-app-insights.png` e `E08-alerta.png` dependem do sistema publicado no Azure.
