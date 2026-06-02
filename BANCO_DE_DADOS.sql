-- =====================================================
-- KRONEXA STORE — Schema Completo do Banco de Dados
-- Execute no Supabase SQL Editor (novo projeto)
-- =====================================================

-- TENANTS (lojas)
CREATE TABLE IF NOT EXISTS tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome_loja TEXT NOT NULL,
  cnpj TEXT,
  telefone TEXT,
  telefone_dono TEXT,
  email TEXT,
  endereco TEXT,
  nicho TEXT, -- perfumaria, bijuteria, otica, moda, etc
  logo_url TEXT,
  plano TEXT DEFAULT 'TRIAL', -- STARTER, PRO, FRANQUIA
  status TEXT DEFAULT 'TRIAL', -- TRIAL, ATIVO, SUSPENSO, CANCELADO
  trial_fim TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '7 days'),
  evolution_instance TEXT, -- instância Evolution API
  telegram_bot_token TEXT,
  cloudinary_cloud TEXT,
  horario_abertura TIME DEFAULT '08:00',
  horario_fechamento TIME DEFAULT '18:00',
  dias_funcionamento TEXT[] DEFAULT ARRAY['seg','ter','qua','qui','sex'],
  desconto_fidelidade INT DEFAULT 5, -- % desconto cliente fiel
  pedidos_para_fidelidade INT DEFAULT 5, -- qtd pedidos para ser fiel
  meta_vendas_mensal NUMERIC(10,2),
  msg_boas_vindas TEXT,
  msg_ausencia TEXT,
  ativo BOOLEAN DEFAULT true,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

-- PRODUTOS
CREATE TABLE IF NOT EXISTS produtos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  descricao TEXT,
  categoria TEXT,
  preco NUMERIC(10,2) NOT NULL,
  preco_custo NUMERIC(10,2),
  preco_promocional NUMERIC(10,2),
  estoque_atual INT DEFAULT 0,
  estoque_minimo INT DEFAULT 2,
  estoque_maximo INT,
  unidade TEXT DEFAULT 'un',
  codigo_barras TEXT,
  sku TEXT,
  fotos TEXT[], -- URLs Cloudinary
  variações JSONB, -- [{cor: 'Rosa', tamanho: 'P', estoque: 5}]
  peso_g INT,
  ativo BOOLEAN DEFAULT true,
  destaque BOOLEAN DEFAULT false,
  tags TEXT[],
  vendas_total INT DEFAULT 0,
  avaliacao_media NUMERIC(3,2) DEFAULT 0,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

-- CLIENTES
CREATE TABLE IF NOT EXISTS clientes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  telefone TEXT NOT NULL,
  email TEXT,
  data_nascimento DATE,
  endereco TEXT,
  bairro TEXT,
  cidade TEXT,
  estado TEXT,
  cep TEXT,
  notas TEXT,
  segmento TEXT DEFAULT 'NORMAL', -- NORMAL, VIP, FIEL, INATIVO
  total_pedidos INT DEFAULT 0,
  total_gasto NUMERIC(10,2) DEFAULT 0,
  ultimo_pedido TIMESTAMPTZ,
  canal_origem TEXT DEFAULT 'WHATSAPP',
  ativo BOOLEAN DEFAULT true,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- PEDIDOS
CREATE TABLE IF NOT EXISTS pedidos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  cliente_id UUID REFERENCES clientes(id),
  numero_pedido INT,
  status TEXT DEFAULT 'PENDENTE', -- PENDENTE, APROVADO, SEPARANDO, PRONTO, ENTREGUE, CANCELADO
  canal TEXT DEFAULT 'WHATSAPP', -- WHATSAPP, TELEGRAM, SITE, PRESENCIAL
  subtotal NUMERIC(10,2) DEFAULT 0,
  desconto NUMERIC(10,2) DEFAULT 0,
  frete NUMERIC(10,2) DEFAULT 0,
  total NUMERIC(10,2) DEFAULT 0,
  forma_pagamento TEXT, -- PIX, CARTAO, BOLETO, DINHEIRO
  status_pagamento TEXT DEFAULT 'PENDENTE',
  link_pagamento TEXT,
  pago_em TIMESTAMPTZ,
  tipo_entrega TEXT DEFAULT 'RETIRADA', -- RETIRADA, DELIVERY, CORREIOS
  endereco_entrega TEXT,
  observacoes TEXT,
  atendente_ia BOOLEAN DEFAULT true,
  conversa_id TEXT,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

-- ITENS DO PEDIDO
CREATE TABLE IF NOT EXISTS itens_pedido (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pedido_id UUID REFERENCES pedidos(id) ON DELETE CASCADE,
  produto_id UUID REFERENCES produtos(id),
  nome_produto TEXT NOT NULL,
  variacao TEXT,
  quantidade INT NOT NULL DEFAULT 1,
  preco_unitario NUMERIC(10,2) NOT NULL,
  desconto_item NUMERIC(10,2) DEFAULT 0,
  subtotal NUMERIC(10,2) NOT NULL
);

-- RESERVAS
CREATE TABLE IF NOT EXISTS reservas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  produto_id UUID REFERENCES produtos(id),
  cliente_id UUID REFERENCES clientes(id),
  variacao TEXT,
  quantidade INT DEFAULT 1,
  expira_em TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '2 hours'),
  status TEXT DEFAULT 'ATIVA', -- ATIVA, CONVERTIDA, EXPIRADA, CANCELADA
  conversa_id TEXT,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- MOVIMENTOS DE ESTOQUE
CREATE TABLE IF NOT EXISTS estoque_movimentos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  produto_id UUID REFERENCES produtos(id),
  tipo TEXT NOT NULL, -- ENTRADA, SAIDA, RESERVA, LIBERACAO, AJUSTE
  quantidade INT NOT NULL,
  estoque_antes INT,
  estoque_depois INT,
  motivo TEXT,
  referencia_id UUID,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- CAIXA
CREATE TABLE IF NOT EXISTS caixa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  tipo TEXT NOT NULL, -- ENTRADA, SAIDA
  categoria TEXT, -- VENDA, DEVOLUCAO, DESPESA, COMISSAO, etc
  valor NUMERIC(10,2) NOT NULL,
  descricao TEXT,
  referencia_id UUID,
  forma_pagamento TEXT,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- SOCIAL POSTS
CREATE TABLE IF NOT EXISTS social_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  produto_id UUID REFERENCES produtos(id),
  plataforma TEXT, -- INSTAGRAM, FACEBOOK, X, TODOS
  titulo TEXT,
  legenda TEXT,
  hashtags TEXT[],
  imagem_url TEXT,
  status TEXT DEFAULT 'RASCUNHO', -- RASCUNHO, AGENDADO, PUBLICADO, ERRO
  agendado_para TIMESTAMPTZ,
  publicado_em TIMESTAMPTZ,
  instrucao_dono TEXT,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- AVALIACOES NPS
CREATE TABLE IF NOT EXISTS avaliacoes_nps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  pedido_id UUID REFERENCES pedidos(id),
  cliente_id UUID REFERENCES clientes(id),
  nota INT CHECK (nota BETWEEN 1 AND 10),
  comentario TEXT,
  status TEXT DEFAULT 'PENDENTE',
  enviado_em TIMESTAMPTZ,
  respondido_em TIMESTAMPTZ,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- CAMPANHAS MARKETING
CREATE TABLE IF NOT EXISTS campanhas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  tipo TEXT, -- REENGAJAMENTO, ANIVERSARIO, PROMOCAO, LANCAMENTO
  canal TEXT, -- WHATSAPP, EMAIL, AMBOS
  mensagem TEXT,
  segmento TEXT, -- TODOS, VIP, FIEL, INATIVO
  status TEXT DEFAULT 'RASCUNHO',
  agendado_para TIMESTAMPTZ,
  enviado_para INT DEFAULT 0,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- FORNECEDORES
CREATE TABLE IF NOT EXISTS fornecedores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  contato TEXT,
  whatsapp TEXT,
  email TEXT,
  cnpj TEXT,
  categoria TEXT,
  ativo BOOLEAN DEFAULT true,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- CONVERSAS (histórico WhatsApp)
CREATE TABLE IF NOT EXISTS conversas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  cliente_id UUID REFERENCES clientes(id),
  canal TEXT DEFAULT 'WHATSAPP',
  numero_cliente TEXT NOT NULL,
  nome_cliente TEXT,
  ultima_mensagem TEXT,
  ultimo_contato TIMESTAMPTZ,
  status TEXT DEFAULT 'ABERTA',
  contexto JSONB, -- estado da conversa para a IA
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- MENSAGENS
CREATE TABLE IF NOT EXISTS mensagens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversa_id UUID REFERENCES conversas(id) ON DELETE CASCADE,
  remetente TEXT NOT NULL, -- CLIENTE, IA, HUMANO
  conteudo TEXT,
  tipo TEXT DEFAULT 'TEXTO', -- TEXTO, IMAGEM, AUDIO, DOCUMENTO
  midia_url TEXT,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- INTEGRACOES
CREATE TABLE IF NOT EXISTS integracoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  tipo TEXT NOT NULL, -- BLING, NUVEMSHOP, VTEX, SHOPIFY
  config JSONB,
  status TEXT DEFAULT 'INATIVO',
  ultimo_sync TIMESTAMPTZ,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- ÍNDICES
CREATE INDEX IF NOT EXISTS idx_produtos_tenant ON produtos(tenant_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_tenant ON pedidos(tenant_id);
CREATE INDEX IF NOT EXISTS idx_clientes_tenant ON clientes(tenant_id);
CREATE INDEX IF NOT EXISTS idx_clientes_telefone ON clientes(telefone);
CREATE INDEX IF NOT EXISTS idx_conversas_numero ON conversas(numero_cliente, tenant_id);

-- VERIFICAÇÃO
SELECT 'Kronexa Store DB OK' as status, COUNT(*) as tabelas
FROM information_schema.tables 
WHERE table_schema = 'public';
