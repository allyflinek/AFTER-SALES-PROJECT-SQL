USE [stage]
GO

/****** Object:  StoredProcedure [camada0].[pr_Parvi_logistica_Orcamento]    Script Date: 27/09/2022 13:05:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [camada0].[Pr_DealerNet_Orcamento_teste]
AS
BEGIN 
    DECLARE @data DATE = '20210101';

	INSERT INTO camada0.DealerNet_Orcamento_teste 
	SELECT 'DLR' AS SISTEMA 
	,CONCAT('DLR','|',OficinaOrcamento_Codigo)                 AS ID_Origem 
    ,OficinaOrcamento_Codigo                                   AS Orcamento_Codigo
	,OficinaOrcamento_Empresacod                               AS Orcamento_Empresacod
	,OficinaOrcamento_Veiculocod                               AS Orcamento_Veiculocod
	,OficinaOrcamento_PessoacodCliente                         AS Orcamento_Pessoa_cod_cliente
	,OficinaOrcamento_Complementar                             AS Orcamento_Complementar
	,OficinaOrcamento_Observacao                               AS Orcamento_Observacao 
	,OficinaOrcamento_TipoOSCod                                AS Orcamento_TipoOSCod
	,CONVERT(DATE,OficinaOrcamento_Validade)                   AS Orcamento_Validade
	,OficinaOrcamento_Status                                   AS Orcamento_Status 
	,OficinaOracmento_KM                                       AS OficinaOrcamento_KM 
	,CONVERT(DATE,OficinaOrcamento_ProximoContato)             AS Orcamento_ProximoContato
	,OficinaOrcamento_OficinaOrcamentoCodOrigem                AS Orcamento_OrcamentoCodOrigem
    ,OficinaOrcamento_AtendimentoCod                           AS Orcamento_AtendimentoCod
	,CONVERT(DATE,ooh.OficinaOrcamentoHistorico_Data)          AS Orcamento_DataCriacao
	,CONVERT(DATETIME,ooh.OficinaOrcamentoHistorico_Data)      AS Orcamento_HoraCriacao
	 FROM [Dealer].[DealerNetWF].dbo.OficinaOrcamento oo
	 LEFT JOIN [Dealer].[DealerNetWF].[dbo].OficinaServico os              ON  os.OficinaServico_OficinaOrcamentoCod  = oo.OficinaOrcamento_Codigo
	 LEFT JOIN [Dealer].[DealerNetWF].[dbo].OficinaProduto op              ON  op.OficinaProduto_OficinaOrcamentoCod  = oo.OficinaOrcamento_Codigo
	 LEFT JOIN [Dealer].[DealerNetWF].[dbo].OficinaOrcamentoHistorico ooh  ON ooh.OficinaOrcamento_Codigo             = oo.OficinaOrcamento_Codigo WHERE oo.OficinaOrcamentoHistorico_Data >= @data and OficinaOrcamentoHistorico_Codigo = 'CRI'
	 LEFT JOIN [Dealer].[DealerNetWF].[dbo].