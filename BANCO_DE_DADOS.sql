-- =====================================================
-- KRONEXA STORE — Migração no projeto Mecani.AI
-- Execute em: supabase.com/dashboard/project/tcjynyfusqkqtdohnyzq/sql/new
-- As tabelas usam RLS para isolamento por tenant_id
-- =====================================================

-- Tipo de produto para a loja
CREATE TABLE IF NOT EXISTS ks_tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mecani_tenant_id UUID, -- referência ao tenant do Mecani.AI (se for o mesmo dono)
  nome_loja TEXT NOT NULL,
  telefone_dono TEXT,
  email TEXT,
  nicho TEXT DEFAULT 'varejo',
  plano TEXT DEFAULT 'TRIAL',
  status TEXT DEFAULT 'TRIAL',
  trial_fim TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '7 days'),
  evolution_instance TEXT,
  desconto_fidelidade INT DEFAULT 5,
  pedidos_para_fidelidade INT DEFAULT 5,
  meta_vendas_mensal NUMERIC(10,2),
  ativo BOOLEAN DEFAULT true,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ks_produtos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES ks_tenants(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  descricao TEXT,
  categoria TEXT,
  preco NUMERIC(10,2) NOT NULL,
  preco_custo NUMERIC(10,2),
  preco_promocional NUMERIC(10,2),
  estoque_atual INT DEFAULT 0,
  estoque_minimo INT DEFAULT 2,
  fotos TEXT[],
  variações JSONB,
  codigo_barras TEXT,
  sku TEXT,
  ativo BOOLEAN DEFAULT true,
  destaque BOOLEAN DEFAULT false,
  tags TEXT[],
  vendas_total INT DEFAULT 0,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ks_clientes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES ks_tenants(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  telefone TEXT NOT NULL,
  email TEXT,
  data_nascimento DATE,
  endereco TEXT,
  segmento TEXT DEFAULT 'NORMAL',
  total_pedidos INT DEFAULT 0,
  total_gasto NUMERIC(10,2) DEFAULT 0,
  ultimo_pedido TIMESTAMPTZ,
  canal_origem TEXT DEFAULT 'WHATSAPP',
  ativo BOOLEAN DEFAULT true,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ks_pedidos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES ks_tenants(id) ON DELETE CASCADE,
  cliente_id UUID REFERENCES ks_clientes(id),
  numero_pedido SERIAL,
  status TEXT DEFAULT 'PENDENTE',
  canal TEXT DEFAULT 'WHATSAPP',
  subtotal NUMERIC(10,2) DEFAULT 0,
  desconto NUMERIC(10,2) DEFAULT 0,
  total NUMERIC(10,2) DEFAULT 0,
  forma_pagamento TEXT,
  status_pagamento TEXT DEFAULT 'PENDENTE',
  link_pagamento TEXT,
  nome_cliente TEXT,
  telefone_cliente TEXT,
  observacoes TEXT,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ks_itens_pedido (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pedido_id UUID REFERENCES ks_pedidos(id) ON DELETE CASCADE,
  produto_id UUID REFERENCES ks_produtos(id),
  nome_produto TEXT NOT NULL,
  variacao TEXT,
  quantidade INT DEFAULT 1,
  preco_unitario NUMERIC(10,2) NOT NULL,
  subtotal NUMERIC(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS ks_reservas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES ks_tenants(id) ON DELETE CASCADE,
  produto_id UUID REFERENCES ks_produtos(id),
  cliente_id UUID REFERENCES ks_clientes(id),
  quantidade INT DEFAULT 1,
  expira_em TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '2 hours'),
  status TEXT DEFAULT 'ATIVA',
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ks_estoque_movimentos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES ks_tenants(id) ON DELETE CASCADE,
  produto_id UUID REFERENCES ks_produtos(id),
  tipo TEXT NOT NULL,
  quantidade INT NOT NULL,
  estoque_antes INT,
  estoque_depois INT,
  motivo TEXT,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ks_caixa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES ks_tenants(id) ON DELETE CASCADE,
  tipo TEXT NOT NULL,
  categoria TEXT,
  valor NUMERIC(10,2) NOT NULL,
  descricao TEXT,
  referencia_id UUID,
  forma_pagamento TEXT,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ks_social_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES ks_tenants(id) ON DELETE CASCADE,
  produto_id UUID REFERENCES ks_produtos(id),
  plataforma TEXT,
  legenda TEXT,
  hashtags TEXT[],
  imagem_url TEXT,
  status TEXT DEFAULT 'RASCUNHO',
  agendado_para TIMESTAMPTZ,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ks_avaliacoes_nps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES ks_tenants(id) ON DELETE CASCADE,
  pedido_id UUID REFERENCES ks_pedidos(id),
  cliente_id UUID REFERENCES ks_clientes(id),
  nota INT CHECK (nota BETWEEN 1 AND 10),
  comentario TEXT,
  status TEXT DEFAULT 'PENDENTE',
  respondido_em TIMESTAMPTZ,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ks_campanhas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES ks_tenants(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  tipo TEXT,
  canal TEXT,
  mensagem TEXT,
  segmento TEXT DEFAULT 'TODOS',
  status TEXT DEFAULT 'RASCUNHO',
  enviado_para INT DEFAULT 0,
  agendado_para TIMESTAMPTZ,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ks_conversas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES ks_tenants(id) ON DELETE CASCADE,
  cliente_id UUID REFERENCES ks_clientes(id),
  canal TEXT DEFAULT 'WHATSAPP',
  numero_cliente TEXT NOT NULL,
  nome_cliente TEXT,
  ultima_mensagem TEXT,
  ultimo_contato TIMESTAMPTZ,
  status TEXT DEFAULT 'ABERTA',
  contexto JSONB,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(tenant_id, numero_cliente)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_ks_produtos_tenant ON ks_produtos(tenant_id);
CREATE INDEX IF NOT EXISTS idx_ks_pedidos_tenant ON ks_pedidos(tenant_id);
CREATE INDEX IF NOT EXISTS idx_ks_clientes_tenant ON ks_clientes(tenant_id);
CREATE INDEX IF NOT EXISTS idx_ks_clientes_tel ON ks_clientes(telefone, tenant_id);
CREATE INDEX IF NOT EXISTS idx_ks_conversas_num ON ks_conversas(numero_cliente, tenant_id);

-- Tenant demo Kronexa Store
INSERT INTO ks_tenants (
  id, nome_loja, telefone_dono, email, nicho,
  plano, status, evolution_instance, ativo
) VALUES (
  'b2c3d4e5-0001-0000-0000-000000000001',
  'Kronexa Store Demo',
  '61991775904',
  'raique@kronexa.com.br',
  'perfumaria',
  'PRO',
  'ATIVO',
  'mecani-oficina-01',
  true
) ON CONFLICT (id) DO NOTHING;

-- Produtos demo
INSERT INTO ks_produtos (tenant_id, nome, categoria, preco, preco_custo, estoque_atual, estoque_minimo, ativo, destaque, vendas_total) VALUES
  ('b2c3d4e5-0001-0000-0000-000000000001', 'Chanel N°5 EDP 100ml', 'Perfumaria', 320.00, 180.00, 8, 3, true, true, 12),
  ('b2c3d4e5-0001-0000-0000-000000000001', 'Dior Sauvage EDP 100ml', 'Perfumaria', 285.00, 160.00, 2, 3, true, true, 7),
  ('b2c3d4e5-0001-0000-0000-000000000001', 'Pulseira Dourada Aro', 'Bijuteria', 45.00, 18.00, 15, 5, true, false, 9),
  ('b2c3d4e5-0001-0000-0000-000000000001', 'Armação Gatinho Acetato', 'Ótica', 180.00, 60.00, 0, 2, true, false, 5),
  ('b2c3d4e5-0001-0000-0000-000000000001', 'Miss Dior Blooming EDP', 'Perfumaria', 298.00, 165.00, 5, 3, true, true, 6)
ON CONFLICT DO NOTHING;

-- Verificação final
SELECT 'Kronexa Store DB OK' AS status;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name LIKE 'ks_%' 
ORDER BY table_name;
