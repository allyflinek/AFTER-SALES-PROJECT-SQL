USE [stage]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [camada2].[vw_AutoAvaliar] AS   

SELECT t1.[placa]
      ,t1.[Empresa_Codigo]
      ,t1.[avaliador]
      ,t1.[dataHoraAvaliacao2]
      ,t1.[tipoAvaliacao]
      ,t1.[direcionamento]
      ,t1.[kmAvaliacao]
      ,t1.[classificacaoAvaliacao]
      ,t1.[valorAvaliacao]
      ,t1.[valorTabelaFipe]
      ,t1.[custoPrevisto]
      ,t1.[valorFipeBI]
      ,t1.[codigoFipe]
      ,t1.[ordem]
      ,t1.[dataHoraAvaliacao]
FROM
(SELECT *
FROM   [camada1].[vw_AutoAvaliar] WHERE ORDEM = 1) t1
RIGHT JOIN 
(SELECT PLACA AS PLACA_OFF, MAX(DATAHORAAVALIACAO) AS DATAHORAAVALIACAO_OFF
FROM [camada1].[vw_AutoAvaliar] WHERE ORDEM = 1 GROUP BY PLACA) t2 ON t1.PLACA = t2.PLACA_OFF AND t2.DATAHORAAVALIACAO_OFF = t1.DATAHORAAVALIACAO


GO



