
select  a.*, aa.placa as antigo, aa.datahoraavaliacao as antigo
from [camada1].[vw_AutoAvaliar] a 
right join 
(

select z.placa, z.datahoraavaliacao
from (
select max(datahoraavaliacao) as datahoraavaliacao, placa
from [camada1].[vw_AutoAvaliar]
where ordem = 1
group by placa) z 
) aa on a.placa = aa.placa and a.datahoraavaliacao = aa.datahoraavaliacao
where a.ordem = 1




select *
from [camada1].[vw_AutoAvaliar]
where ordem = 1

select max(datahoraavaliacao) as datahoraavaliacao, placa
into #teste02
from #teste01
group by placa



select 


select  t1.*, t2.datahoraavaliacao as datahoraantigo, t2.placa as placaantigo
from (select *
from [camada1].[vw_AutoAvaliar]
where ordem = 1) t1
right join ( select max(datahoraavaliacao) as datahoraavaliacao, placa

from [camada1].[vw_AutoAvaliar] where ordem = 1
group by placa) t2 on t2.datahoraavaliacao = t1.datahoraavaliacao and t2.placa = t1.placa

select * from #teste03

create view teste
as 
select  t1.*, t2.datahoraavaliacao as datahoraantigo, t2.placa as placaantigo
from (select *
from [camada1].[vw_AutoAvaliar]
where ordem = 1) t1
right join ( select max(datahoraavaliacao) as datahoraavaliacao, placa

from [camada1].[vw_AutoAvaliar] where ordem = 1
group by placa) t2 on t2.datahoraavaliacao = t1.datahoraavaliacao and t2.placa = t1.placa