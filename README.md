# 📊 Portfólio SQL – Análises de Eventos

Repositório criado para demonstrar meu aprendizado e prática em **SQL aplicado à análise de dados**, usando um cenário de **empresa de eventos corporativos**.

O foco é mostrar domínio nas principais operações de análise — agrupamentos, filtros, subconsultas, CTEs e funções de janela — em consultas que simulam situações reais de negócio.

---

## 🎯 Objetivos do Projeto

- Consolidar aprendizados em **consultas intermediárias e avançadas em SQL**
- Aplicar **funções de agregação**, **joins** e **CTEs**
- Criar análises voltadas para **indicadores reais de negócio**
- Praticar boas práticas de **organização e documentação** de consultas

---

## 🗂 Estrutura do Repositório

eventos_sql_analytics/
├─ .venv/
│
├─ data/
│ ├─ clientes.csv
│ ├─ eventos.csv
│ ├─ faturas.csv
│ ├─ item_vendas.csv
│ ├─ pedidos.csv
│ └─ vendedores.csv
│
├─ sql/
│ ├─ 00_schema_minimo.sql
│ ├─ 01_receita_mensal.sql
│ ├─ 02_top3_eventos_receita.sql
│ ├─ 03_top3_clientes_ticket_trimestral.sql
│ ├─ 04_conversao_por_canal_2025.sql
│ ├─ 05_receita_por_tipo_evento_minimo.sql
│ ├─ 06_receita_uf_meio_pagamento_ranking.sql
│ ├─ 07_faturas_atrasadas_faixa.sql
│ ├─ 08_ocupacao_top2_meses_por_evento.sql
│ ├─ 09_receita_por_vendedor_min_pedidos.sql
│ ├─ 10_top5_eventos_receita_2025_ticket.sql
│ └─ 11_clientes_dormientes_180d.sql
│
├─ carga_eventos.sql # arquivo gerado automaticamente pelo script
├─ gerar_sql_eventos.py # script Python que gera o SQL completo a partir dos CSVs
├─ diagrama_eventos.png 
├─ .gitignore
└─ README.md

Cada arquivo `.sql` possui comentários explicativos no início, indicando **objetivo**, **tabelas envolvidas** e **regras de cálculo**.

---

## 🧠 Habilidades Demonstradas

- Criação de **consultas com GROUP BY, HAVING e JOINs**
- Uso de **funções de agregação e condicionais (CASE, IF, etc.)**
- Criação de **CTEs** e **subqueries** para métricas compostas
- Aplicação de **funções de janela (OVER, LAG, LEAD)** em análises temporais
- Estruturação de um **projeto SQL organizado por tema**
- Documentação clara e legível em cada consulta

---

## ⚙️ Como Executar no MySQL Workbench

1. **Abra o MySQL Workbench.**
2. Crie uma nova conexão ou use uma já existente.
3. Vá até o menu superior e selecione **File → Open SQL Script...**
4. Selecione o arquivo `sql/00_schema_minimo.sql` e execute com **Ctrl + Shift + Enter** para criar as tabelas.
5. Em seguida, abra qualquer outro arquivo dentro da pasta `sql/` e execute o script da consulta desejada.
6. Os resultados aparecerão na aba **Results Grid**, prontos para análise.

> 💡 **Dica:** Você pode abrir várias abas no Workbench e comparar diferentes consultas lado a lado, por exemplo `05_receita_por_tipo_evento_minimo.sql` e `06_receita_uf_meio_pagamento_ranking.sql`.

---

## 💬 Exemplo de Consulta

**Arquivo:** `sql/05_receita_por_tipo_evento_minimo.sql`  
**Objetivo:** Somar receita por tipo de evento e aplicar um filtro mínimo de valor.

```sql
/*
Arquivo: 05_receita_por_tipo_evento_minimo.sql
Objetivo: Somar receita por tipo de evento e aplicar filtro mínimo de valor.
*/

SELECT
	e.tipo_evento AS 'Tipo_Evento',
    SUM(i.valor_total) AS 'Receita_Confirmada'
FROM item_vendas i
	JOIN eventos e ON e.id_evento = i.id_evento
WHERE
	YEAR(i.data_pagamento) IN ('2024', '2025')
    AND i.status_pagamento = 'confirmado'
GROUP BY
	e.tipo_evento
HAVING 
	SUM(i.valor_total) > 250000;

---
 
## 📌 Sobre o Aprendizado

Este projeto representa meu momento atual de evolução em SQL, com foco em **clareza, lógica e aplicabilidade prática**.  
A ideia é mostrar entendimento de conceitos e capacidade de estruturar análises úteis — não apenas complexidade técnica.

---

✦ *Autor:* [Lucas Borges]  
✦ *Propósito:* Portfólio de estudos em análise de dados com SQL
