USE [dw]
GO

/****** Object:  View [dbo].[vw_dataFechamentoVeiculoEstoque]    Script Date: 03/10/2022 10:58:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER view [dbo].[vw_dataFechamentoVeiculoEstoque] as 

SELECT z.*, SUBSTRING(z.Fechamento_para_MesAno_BI2,1,6) AS Fechamento_para_MesAno_BI
FROM
(
SELECT *, case when concat(c.Fechamento_para_MesAno_BIBB, SUBSTRING(convert(varchar(10),c.ano),3,4)) = 'Aug/22' then 'Ago/22' 
               when concat(c.Fechamento_para_MesAno_BIBB, SUBSTRING(convert(varchar(10),c.ano),3,4)) = 'Aug/21' then 'Ago/21' 
			   when concat(c.Fechamento_para_MesAno_BIBB, SUBSTRING(convert(varchar(10),c.ano),3,4)) = 'Aug/23' then 'Ago/23'
			   when concat(c.Fechamento_para_MesAno_BIBB, SUBSTRING(convert(varchar(10),c.ano),3,4)) = 'Apr/21' then 'Abr/21' 
               when concat(c.Fechamento_para_MesAno_BIBB, SUBSTRING(convert(varchar(10),c.ano),3,4)) = 'Apr/22' then 'Abr/22' 
			   when concat(c.Fechamento_para_MesAno_BIBB, SUBSTRING(convert(varchar(10),c.ano),3,4)) = 'Apr/23' then 'Abr/23'
			   when concat(c.Fechamento_para_MesAno_BIBB, SUBSTRING(convert(varchar(10),c.ano),3,4)) = 'Sep/21' then 'Set/21' 
               when concat(c.Fechamento_para_MesAno_BIBB, SUBSTRING(convert(varchar(10),c.ano),3,4)) = 'Sep/22' then 'Set/22' 
			   when concat(c.Fechamento_para_MesAno_BIBB, SUBSTRING(convert(varchar(10),c.ano),3,4)) = 'Sep/23' then 'Set/23'
			   when concat(c.Fechamento_para_MesAno_BIBB, SUBSTRING(convert(varchar(10),c.ano),3,4)) = 'Dec/21' then 'Dez/21' 
               when concat(c.Fechamento_para_MesAno_BIBB, SUBSTRING(convert(varchar(10),c.ano),3,4)) = 'Dec/22' then 'Dez/22' 
			   when concat(c.Fechamento_para_MesAno_BIBB, SUBSTRING(convert(varchar(10),c.ano),3,4)) = 'Dec/23' then 'Dez/23'
else concat(c.Fechamento_para_MesAno_BIBB, SUBSTRING(convert(varchar(10),c.ano),3,4)) end  AS Fechamento_para_MesAno_BI2
FROM 
(
SELECT *, case when b.Fechamento_para_MesAno = b.Fechamento_para_MesAno and b.diaMes = 1 then substring(REPLACE(CONVERT(VARCHAR(20),dateadd(day,-1,b.datafechamento),7),' ','/'),1,4) else b.Fechamento_para_MesAno end as Fechamento_para_MesAno_BIBB
FROM
(
SELECT *, Fechamento_para_MesAno = concat(substring(a.nomemesano,1,4),SUBSTRING(a.nomemesano,7,2))
FROM
(
select distinct DataFechamento 
,d.diaAno
,d.diaMes
,d.diaSemana
,d.anoMes
,d.mes
,d.nomeAnoMes
--,d.nomeAnoTrimestre
,d.nomeMes
,d.nomeMesAno
,semestre = concat('S',d.semestre)
,trimestre = concat('T',d.trimestre)
,bimestre =concat('B',d.bimestre)
,d.ano
,data2 = format(d.data,'dd/MM/yy')
,case when d.data = (select max(dataFechamento) from VeiculoEstoque) then 'Data fechamento Atual' else 'Data Fechamento Anterior' end as PosicaoDataFechamento
from VeiculoEstoque ve
inner join Datas d on d.data = ve.dataFechamento ) a ) b ) c ) z





GO


