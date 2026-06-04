# Kronexa Store — Portais

**Site:** https://store.kronexa.com.br  
**Stack:** GitHub Pages + Supabase + Evolution API + Gemini + Mercado Pago

## Páginas (21 arquivos)
| Página | URL | Descrição |
|--------|-----|-----------|
| Landing | `/` | Landing page completa |
| Checkout | `/checkout.html` | 3 planos com modal |
| Admin | `/portal-admin.html` | Dashboard principal |
| Atendente | `/portal-atendente.html` | Gerenciar conversas |
| Estoque | `/portal-estoque.html` | Controle de estoque |
| Financeiro | `/portal-financeiro.html` | Caixa e receitas |
| Marketing | `/portal-marketing.html` | Posts IA + campanhas |
| Cliente | `/portal-cliente.html` | Rastrear pedido + NPS |
| Config | `/portal-configuracoes.html` | Configurações da loja |
| Onboarding | `/onboarding.html` | Pós-assinatura |
| Status | `/status.html` | Status do sistema |
| Auto-deploy | `/auto-deploy.html` | Instalar Edge Functions |
| Setup | `/setup-store.html` | Config manual |
| Termos | `/termos.html` | LGPD/CDC |
| Privacidade | `/privacidade.html` | LGPD |
| Cancelar | `/cancelar.html` | Cancelamento |
| 404 | `/404.html` | Erro |

## Banco de Dados (Supabase)
**Projeto:** tcjynyfusqkqtdohnyzq (mesmo do Mecani.AI)  
**Tabelas:** ks_tenants, ks_produtos, ks_clientes, ks_pedidos, ks_itens_pedido, ks_reservas, ks_estoque_movimentos, ks_caixa, ks_social_posts, ks_avaliacoes_nps, ks_conversas

**Tenant demo:** `b2c3d4e5-0001-0000-0000-000000000001`  
**5 produtos de exemplo** já inseridos

## Edge Functions
- `orchestrator-store` — Roteador WhatsApp
- `vendas-store` — IA de vendas Gemini
- `nps-store` — NPS pós-venda
- `estoque-store` — Alertas de estoque
- `relatorio-store` — Relatório diário
- `marketing-store` — Posts e reengajamento

## Configurar
1. Abrir `auto-deploy.html` e clicar "Executar"
2. Adicionar DNS no Registro.br: `A store → 185.199.108-111.153`
3. Deploy dashboard: `vercel.com/new` → `kronexa-store-dashboard`
4. Conectar WhatsApp: Evolution API → nova instância → QR Code
5. Criar planos MP: `mercadopago.com.br/developers` → criar assinaturas
