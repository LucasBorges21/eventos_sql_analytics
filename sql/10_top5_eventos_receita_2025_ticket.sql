/*
Arquivo: 10_top5_eventos_receita_2025_ticket.sql
Objetivo: Identificar os 5 eventos com maior receita em 2025 com desempate por ticket médio.
*/

with top5_eventos as (
select
	e.id_evento as 'ID_Evento',
    e.nome_evento as 'Nome_Evento',
    sum(i.valor_total) as 'Receita_Total',
    round(avg(i.valor_total),2) as 'Receita_Media_Item'
from item_vendas i
	join eventos e on e.id_evento = i.id_evento
where
	i.status_pagamento = 'confirmado'
    and year(i.data_pagamento) = '2025'
group by
	e.id_evento,
    e.nome_evento
)
select * from (
select
	rank() over(
    order by Receita_Total desc, 
	Receita_Media_Item desc
    ) as 'Posicao',
	ID_Evento,
    Nome_Evento,
    Receita_Total,
    Receita_Media_Item
from top5_eventos) t
where t.Posicao <=5;
