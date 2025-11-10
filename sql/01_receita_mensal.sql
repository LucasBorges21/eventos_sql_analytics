/*
Arquivo: 01_receita_mensal.sql
Objetivo: Calcular receita mensal considerando pedidos ganhos e pagamentos confirmados.
*/

with calculo_receita_mensal as(
	select	
		date_format(i.data_pagamento, '%Y/%m') as 'ano_mes',
		sum(i.valor_total) as 'receita_mes',
		year(i.data_pagamento) as 'ano'
	from item_vendas i
		join pedidos p on p.id_pedido = i.id_pedido
	where
		p.status_pedido = 'ganho'
		and i.status_pagamento = 'confirmado'
	group by
		date_format(i.data_pagamento, '%Y/%m'), ano
)
select
	ano_mes,
    receita_mes,
    rank() over(
    partition by ano
    order by receita_mes desc    
    ) as 'desempenho_mes'
from calculo_receita_mensal
order by ano_mes asc;