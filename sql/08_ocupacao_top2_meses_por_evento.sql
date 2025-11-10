/*
Arquivo: 08_ocupacao_top2_meses_por_evento.sql
Objetivo: Encontrar os 2 meses com maior taxa de ocupação para cada evento.
*/

with ocupacao_evento as (
select
	e.id_evento as 'ID_Evento',
    e.nome_evento as 'Nome_Evento',
    date_format(i.data_pagamento, '%Y/%m') as 'Ano_Mes',
    sum(i.quantidade) / e.capacidade as 'Taxa_Ocupacao_Mes'
from item_vendas i
	join eventos e on e.id_evento = i.id_evento
group by
	date_format(i.data_pagamento, '%Y/%m'),
    e.id_evento,
    e.nome_evento
)
select * from (
	select
		ID_Evento,
		Nome_Evento,
		Ano_Mes,
		Taxa_Ocupacao_Mes,
		rank() over(
		partition by Nome_Evento
		order by Taxa_Ocupacao_Mes desc
		) as 'Ranking_Mes'
	from ocupacao_evento) t
where t.Ranking_Mes <=2
order by t.ID_Evento;
