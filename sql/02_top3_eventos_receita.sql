/*
Arquivo: 02_top3_eventos_receita.sql
Objetivo: Ranking dos 3 eventos com maior receita mensal com critério de desempate por ticket médio.
*/


with top3_ranking as (
	select
		date_format(i.data_pagamento, '%Y-%m') as 'Ano_Mes',
		i.id_evento as 'ID_Evento',
		sum(i.valor_total) as 'Receita_Mes',
		round(sum(i.valor_total) / NULLIF(SUM(i.quantidade), 0), 2) as 'Ticket_Medio_Mes'
	from item_vendas i
		join pedidos p on i.id_pedido = p.id_pedido
	where
		i.status_pagamento = 'confirmado'
		and p.status_pedido = 'ganho'
	group by
		date_format(i.data_pagamento, '%Y-%m'),
		i.id_evento)
select * from (
select
	Ano_Mes,
    ID_Evento,
    Receita_Mes,
    Ticket_Medio_Mes,
    rank() over(
		partition by Ano_Mes
		order by Receita_Mes desc, Ticket_Medio_Mes desc
    ) as 'Posicao_Mes'
from top3_ranking ) t
where t.Posicao_Mes <=3;
