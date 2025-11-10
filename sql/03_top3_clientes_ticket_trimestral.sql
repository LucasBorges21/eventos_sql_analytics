/*
Arquivo: 03_top3_clientes_ticket_trimestral.sql
Objetivo: Identificar os 3 clientes com maior ticket médio por trimestre.
*/


with ranking_trimestre as (
	select
		concat(year(i.data_pagamento), '/', quarter(i.data_pagamento)) as 'ano_trimestre',
		c.id_cliente as 'id_cliente',
		c.nome as 'nome_cliente',
		round(avg(i.valor_total),2) as 'ticket_medio_trimestre'
	from item_vendas i
		join pedidos p on i.id_pedido = p.id_pedido
		join clientes c on c.id_cliente = p.id_cliente
	where
		i.status_pagamento = 'confirmado'
	group by
		concat(year(i.data_pagamento), '/', quarter(i.data_pagamento)),
		c.id_cliente,
		c.nome
)
select * from (
select
	ano_trimestre,
    id_cliente,
    nome_cliente,
    ticket_medio_trimestre,
    rank() over(
    partition by ano_trimestre
    order by ticket_medio_trimestre desc
    ) as 'posicao_trimestre'
from ranking_trimestre) t
where t.posicao_trimestre <=3;
