/*
Arquivo: 00_schema_minimo.sql
Objetivo: Estrutura mínima do banco de dados para executar as consultas de análise de eventos.
*/

CREATE TABLE clientes (
	  id_cliente INT PRIMARY KEY,
	  nome VARCHAR(120) NOT NULL,
	  email VARCHAR(150),
	  cidade VARCHAR(100),
	  estado CHAR(2),
	  pais CHAR(2) DEFAULT 'BR',
	  data_cadastro DATE,
	  canal_aquisicao VARCHAR(30),
	  segmento VARCHAR(20)
	);

	CREATE TABLE eventos (
	  id_evento INT PRIMARY KEY,
	  nome_evento VARCHAR(120) NOT NULL,
	  tipo_evento VARCHAR(30),
	  modalidade VARCHAR(20),
	  data_inicio DATE,
	  data_fim DATE,
	  cidade VARCHAR(100),
	  estado CHAR(2),
	  pais CHAR(2) DEFAULT 'BR',
	  capacidade INT
	);

	CREATE TABLE vendedores (
	  id_vendedor INT PRIMARY KEY,
	  nome VARCHAR(120) NOT NULL,
	  equipe VARCHAR(40),
	  regiao VARCHAR(40)
	);

	CREATE TABLE pedidos (
	  id_pedido INT PRIMARY KEY,
	  id_cliente INT NOT NULL,
	  id_vendedor INT NOT NULL,
	  data_pedido DATE,
	  status_pedido VARCHAR(20),
	  FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
	  FOREIGN KEY (id_vendedor) REFERENCES vendedores(id_vendedor)
	);

	CREATE TABLE faturas (
	  id_fatura INT PRIMARY KEY,
	  id_pedido INT NOT NULL,
	  data_emissao DATE,
	  data_vencimento DATE,
	  valor_fatura DECIMAL(12,2),
	  status_fatura VARCHAR(20),
	  dias_em_atraso INT,
	  FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
	);

	CREATE TABLE item_vendas (
	  id_item_venda INT PRIMARY KEY,
	  id_pedido INT NOT NULL,
	  id_fatura INT NULL,
	  id_evento INT NOT NULL,
	  data_faturamento DATE,
	  data_pagamento DATE,
	  meio_pagamento VARCHAR(20),
	  prazo_medio_credito_dias INT,
	  quantidade INT,
	  preco_unitario DECIMAL(12,2),
	  desconto DECIMAL(12,2),
	  valor_total DECIMAL(12,2),
	  moeda CHAR(3) DEFAULT 'BRL',
	  status_pagamento VARCHAR(20),
	  FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
	  FOREIGN KEY (id_fatura) REFERENCES faturas(id_fatura),
	  FOREIGN KEY (id_evento) REFERENCES eventos(id_evento)
	);