# gerar_sql_eventos.py
# Gera um SQL unico (DDL + INSERTs) a partir dos CSVs do dataset de EVENTOS

import pandas as pd
import numpy as np
from pathlib import Path

# ──────────────────────────────────────────────────────────────────────────────
# Config: pasta com os CSVs
# Ex.: se estiver no Colab, aponte para Path("/content")
# Se estiver em um projeto local, aponte para a pasta onde estao os CSVs.
# ──────────────────────────────────────────────────────────────────────────────
BASE_DIR = Path(__file__).resolve().parent
CSV_DIR = BASE_DIR / "data"  # <- mude aqui se precisar (ex.: Path("/content"))

# nomes esperados dos arquivos
csv_files = {
    "clientes":      CSV_DIR / "clientes.csv",
    "eventos":       CSV_DIR / "eventos.csv",
    "vendedores":    CSV_DIR / "vendedores.csv",
    "pedidos":       CSV_DIR / "pedidos.csv",
    "faturas":       CSV_DIR / "faturas.csv",
    "item_vendas":   CSV_DIR / "item_vendas.csv",
}

# colunas esperadas por tabela (ordem define a ordem do INSERT)
schema_columns = {
    "clientes":    ["id_cliente","nome","email","cidade","estado","pais","data_cadastro","canal_aquisicao","segmento"],
    "eventos":     ["id_evento","nome_evento","tipo_evento","modalidade","data_inicio","data_fim","cidade","estado","pais","capacidade"],
    "vendedores":  ["id_vendedor","nome","equipe","regiao"],
    "pedidos":     ["id_pedido","id_cliente","id_vendedor","data_pedido","status_pedido"],
    "faturas":     ["id_fatura","id_pedido","data_emissao","data_vencimento","valor_fatura","status_fatura","dias_em_atraso"],
    "item_vendas": ["id_item_venda","id_pedido","id_fatura","id_evento",
                    "data_faturamento","data_pagamento",
                    "meio_pagamento","prazo_medio_credito_dias",
                    "quantidade","preco_unitario","desconto","valor_total",
                    "moeda","status_pagamento"],
}

# dicas de tipo numerico para nao colocar aspas nos INSERTs
numeric_hints = {
    "clientes":   {"id_cliente": True},
    "eventos":    {"id_evento": True, "capacidade": True},
    "vendedores": {"id_vendedor": True},
    "pedidos":    {"id_pedido": True, "id_cliente": True, "id_vendedor": True},
    "faturas":    {"id_fatura": True, "id_pedido": True, "valor_fatura": True, "dias_em_atraso": True},
    "item_vendas": {
        "id_item_venda": True, "id_pedido": True, "id_fatura": True, "id_evento": True,
        "prazo_medio_credito_dias": True, "quantidade": True,
        "preco_unitario": True, "desconto": True, "valor_total": True
    },
}

# DDL do modelo de EVENTOS (sem meios_pagamento tabela; meio eh atributo na fato)
DDL = """
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS item_vendas;
DROP TABLE IF EXISTS faturas;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS vendedores;
DROP TABLE IF EXISTS eventos;
DROP TABLE IF EXISTS clientes;

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
""".strip()

# ──────────────────────────────────────────────────────────────────────────────
# Helpers para formatar valores
# ──────────────────────────────────────────────────────────────────────────────
def coerce_numeric(val):
    if pd.isna(val):
        return None
    if isinstance(val, (int, float, np.integer, np.floating)):
        return val
    s = str(val).strip()
    if s == "":
        return None
    # normaliza casos com virgula decimal
    if "." in s and "," in s:
        s = s.replace(".", "").replace(",", ".")
    elif "," in s and "." not in s:
        s = s.replace(",", ".")
    try:
        return float(s)
    except Exception:
        return None

def format_date_like(val):
    """Retorna 'YYYY-MM-DD' ou NULL."""
    if pd.isna(val) or str(val).strip() == "":
        return "NULL"
    try:
        dt = pd.to_datetime(val)
        return f"'{dt.date()}'"
    except Exception:
        # fallback: grava como string
        s = str(val).replace("'", "''")
        return f"'{s}'"

def q(value, numeric=False, is_date=False):
    """Quoter: retorna representacao pronta para SQL (MySQL-like)."""
    if is_date:
        return format_date_like(value)
    if pd.isna(value):
        return "NULL"
    if numeric:
        num = coerce_numeric(value)
        if num is None:
            return "NULL"
        if float(num).is_integer():
            return str(int(round(num)))
        return f"{float(num):.10g}"  # evita notacao cientifica grande
    # string
    s = str(value).replace("'", "''")
    return f"'{s}'"

def build_insert(table, df):
    cols = schema_columns[table]
    for c in cols:
        if c not in df.columns:
            df[c] = np.nan
    df = df[cols]

    hints = numeric_hints.get(table, {})
    # quais sao datas?
    date_cols = {c for c in cols if "data_" in c or c in {"data_pedido","data_emissao","data_vencimento","data_faturamento","data_pagamento"}}

    col_list = ", ".join(f"`{c}`" for c in cols)
    lines = []
    batch = 10_000

    for i in range(0, len(df), batch):
        chunk = df.iloc[i:i+batch]
        if chunk.empty:
            continue
        rows = []
        for _, row in chunk.iterrows():
            vals = []
            for c in cols:
                is_date = c in date_cols
                is_num  = hints.get(c, False)
                vals.append(q(row[c], numeric=is_num, is_date=is_date))
            rows.append("(" + ", ".join(vals) + ")")
        lines.append(f"INSERT INTO `{table}` ({col_list}) VALUES\n  " + ",\n  ".join(rows) + ";")
    return "\n\n".join(lines)

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────
def main():
    # ordem respeita FKs
    ordem = ["clientes","eventos","vendedores","pedidos","faturas","item_vendas"]

    inserts = []
    avisos = []

    for tbl in ordem:
        path = csv_files[tbl]
        if not path.exists():
            avisos.append(f"[AVISO] Arquivo nao encontrado: {path.name}")
            continue
        try:
            try:
                df = pd.read_csv(path)  # utf-8-sig funciona tambem
            except UnicodeDecodeError:
                df = pd.read_csv(path, encoding="latin-1")
            df.columns = [c.strip() for c in df.columns]
            ins = build_insert(tbl, df)
            inserts.append(f"-- === {tbl.upper()} ===\n{ins if ins else '-- Nenhum dado para inserir.'}")
        except Exception as e:
            avisos.append(f"[ERRO] Falha em {path.name}: {e}")

    out_path = BASE_DIR / "carga_eventos.sql"
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("-- Arquivo gerado automaticamente a partir dos CSVs do dataset de eventos\n")
        f.write("SET FOREIGN_KEY_CHECKS = 0;\n\n")
        f.write(DDL + "\n\n-- ==== INSERTS ====\n\n")
        f.write("\n\n".join(inserts))
        f.write("\n\nSET FOREIGN_KEY_CHECKS = 1;\n")

    print(f"SQL gerado em: {out_path}")
    if avisos:
        print("\nOcorrencias:")
        for a in avisos:
            print(" -", a)

if __name__ == "__main__":
    main()
