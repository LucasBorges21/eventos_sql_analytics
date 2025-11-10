/*
Arquivo: 11_clientes_dormientes_180d.sql
Objetivo: Identificar clientes com mais de 180 dias sem realizar nova compra (clientes dormentes).
*/

with clientes_dormentes as (
select
	c.id_cliente as 'ID_Cliente',
    c.nome as 'Nome_Cliente',
    c.estado as 'UF',
    c.canal_aquisicao as 'Canal_Aquisicao',
	max(i.data_pagamento) as 'Ultima_Compra',
    datediff(curdate(), max(i.data_pagamento)) as 'Dias_Desde_Ultima_Compra'
from item_vendas i
	join pedidos p on p.id_pedido = i.id_pedido
    join clientes c on c.id_cliente = p.id_cliente
where
	i.data_pagamento is not null
group by
	c.id_cliente,
    c.nome,
    c.estado,
    c.canal_aquisicao
)
select
	ID_Cliente,
    Nome_Cliente,
    UF,
    Canal_Aquisicao,
    Ultima_Compra,
    Dias_Desde_Ultima_Compra
from clientes_dormentes
where Dias_Desde_Ultima_Compra > 180;
