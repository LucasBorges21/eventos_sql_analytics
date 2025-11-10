/*
Arquivo: 06_receita_uf_meio_pagamento_ranking.sql
Objetivo: Listar receita por estado e meio de pagamento com ranking por UF.
*/

with ranking_pagamentos_uf as (
	select
		c.estado as 'UF_Cliente',
		i.meio_pagamento as 'Meio_Pagamento',
		sum(i.valor_total) as 'Receita_Total'
	from item_vendas i
		join pedidos p on p.id_pedido = i.id_pedido
		join clientes c on c.id_cliente = p.id_cliente
	where
		i.status_pagamento = 'confirmado'
	group by
		c.estado,
		i.meio_pagamento
	)
select
	UF_Cliente,
    Meio_Pagamento,
    Receita_Total,
    rank() over(
    partition by UF_Cliente
    order by Receita_Total desc
    ) as 'Ranking_Pagamentos_UF'
from ranking_pagamentos_uf;
