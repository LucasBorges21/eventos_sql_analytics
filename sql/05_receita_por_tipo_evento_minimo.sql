/*
Arquivo: 05_receita_por_tipo_evento_minimo.sql
Objetivo: Somar receita por tipo de evento e aplicar filtro mínimo de valor.
*/

select
	e.tipo_evento as 'Tipo_Evento',
    sum(i.valor_total) as 'Receita_Confirmada'
from item_vendas i
	join eventos e on e.id_evento = i.id_evento
where
	year(i.data_pagamento) in ('2024', '2025')
    and i.status_pagamento = 'confirmado'
group by
	e.tipo_evento
having 
	sum(i.valor_total) > 250000;
