/*
Arquivo: 09_receita_por_vendedor_min_pedidos.sql
Objetivo: Classificar vendedores por receita com filtro mínimo de volume de pedidos.
*/

select
	v.id_vendedor as 'ID_Vendedor',
    v.nome as 'Nome_Vendedor',
    count(p.id_pedido) as 'Qtd_Pedidos_Ganhos',
    sum(i.valor_total) as 'Receita_Confirmada'
from item_vendas i
	join pedidos p on p.id_pedido = i.id_pedido
    join vendedores v on p.id_vendedor = v.id_vendedor
where
	p.status_pedido = 'ganho'
    and year(i.data_pagamento) in (2024, 2025)
group by
	v.id_vendedor,
    v.nome
having 
	count(p.id_pedido) >= 1100
order by
	sum(i.valor_total) desc;