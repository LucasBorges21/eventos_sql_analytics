/*
Arquivo: 07_faturas_atrasadas_faixa.sql
Objetivo: Agrupar faturas atrasadas por faixas de atraso (0–15, 16–30, 31–60, >60).
*/

select
	case
		when f.dias_em_atraso between 0 and 15 then 'Faixa 1'
        when f.dias_em_atraso between 16 and 30 then 'Faixa 2'
        when f.dias_em_atraso between 31 and 60 then 'Faixa 3'
		else 'Faixa 4'
        end as 'Faixa_Atraso',
	count(f.id_fatura) as 'Qtd_Faturas',
    round(avg(f.dias_em_atraso),2) as 'Media_Dias_Atraso'
from faturas f
group by
	'`Faixa_Atraso`';
