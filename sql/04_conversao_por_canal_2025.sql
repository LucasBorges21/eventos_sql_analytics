/*
Arquivo: 04_conversao_por_canal_2025.sql
Objetivo: Calcular taxa de conversão por canal de aquisição para o ano de 2025.
*/

with conversao_canal as (
	select
		c.canal_aquisicao as 'Canal_Aquisicao',
		count(p.id_pedido) as 'Pedidos_Totais',
		sum(case when p.status_pedido = 'ganho' then 1 else 0 end) as 'Pedidos_Ganhos'
	from pedidos p
		join clientes c on p.id_cliente = c.id_cliente
	group by
		c.canal_aquisicao
	)
select
	Canal_Aquisicao,
    Pedidos_Totais,
    Pedidos_Ganhos,
    concat(round(Pedidos_Ganhos / Pedidos_Totais * 100,2),'%') as 'Taxa_Conversão'
from
	conversao_canal;
