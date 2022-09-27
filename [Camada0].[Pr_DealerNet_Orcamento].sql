USE [stage]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [camada0].[Pr_DealerNet_Orcamento_teste]
AS
BEGIN 
    DECLARE @data DATE = '20210101';

	--INSERT INTO camada0.DealerNet_Orcamento_teste 
	 SELECT 'DLR' AS SISTEMA 
	,CONCAT('DLR','|',oo.OficinaOrcamento_Codigo)                 AS ID_Origem 
    ,oo.OficinaOrcamento_Codigo                                   AS Orcamento_Codigo
	,oo.OficinaOrcamento_Empresacod                               AS Orcamento_Empresacod
	,oo.OficinaOrcamento_Veiculocod                               AS Orcamento_Veiculocod
	,oo.OficinaOrcamento_PessoacodCliente                         AS Orcamento_Pessoa_cod_cliente
	,oo.OficinaOrcamento_Complementar                             AS Orcamento_Complementar
	,oo.OficinaOrcamento_Observacao                               AS Orcamento_Observacao 
	,oo.OficinaOrcamento_TipoOSCod                                AS Orcamento_TipoOSCod
	,CONVERT(DATE,oo.OficinaOrcamento_Validade)                   AS Orcamento_Validade
	,oo.OficinaOrcamento_Status                                   AS Orcamento_Status 
	,oo.OficinaOracmento_KM                                       AS OficinaOrcamento_KM 
	,CONVERT(DATE,oo.OficinaOrcamento_ProximoContato)             AS Orcamento_ProximoContato
	,oo.OficinaOrcamento_OficinaOrcamentoCodOrigem                AS Orcamento_OrcamentoCodOrigem
    ,oo.OficinaOrcamento_AtendimentoCod                           AS Orcamento_AtendimentoCod
	,CONVERT(DATE,ooh.OficinaOrcamentoHistorico_Data)             AS Orcamento_DataCriacao
	,CONVERT(DATETIME,ooh.OficinaOrcamentoHistorico_Data)         AS Orcamento_HoraCriacao
	,CONVERT(FLOAT, OficinaServico_Valor)                         AS OficinaServico_Valor
	,CONVERT(FLOAT, OficinaProduto_Valor)                         AS OficinaProduto_Valor
	INTO camada0.DealerNet_Orcamento_teste
	 FROM [Dealer].[DealerNetWF].dbo.OficinaOrcamento oo WITH (NOLOCK)
	 LEFT JOIN (SELECT OficinaServico_OficinaOrcamentoCod
	                 ,OficinaServico_Cod
					 ,SUM(OficinaServico_Horas/CONVERT(FLOAT,3600) * OficinaServico_ValorUnitario) AS OficinaServico_Valor
		        FROM[Dealer].[DealerNetWF].[dbo].OficinaServico 
			    GROUP BY OficinaServico_OficinaOrcamentoCod, OficinaServico_Cod) os  WITH (NOLOCK) ON  os.OficinaServico_OficinaOrcamentoCod  = oo.OficinaOrcamento_Codigo
	 LEFT JOIN (SELECT OficinaProduto_OficinaOrcamentoCod
	                  ,SUM(OficinaProduto_QtdePedida * OficinaProduto_ValorUnitario)               AS OficinaProduto_Valor
		        FROM [Dealer].[DealerNetWF].[dbo].OficinaProduto 
				GROUP BY OficinaProduto_OficinaOrcamentoCod) op                      WITH (NOLOCK) ON  op.OficinaProduto_OficinaOrcamentoCod  = oo.OficinaOrcamento_Codigo
	 LEFT JOIN [Dealer].[DealerNetWF].[dbo].OficinaOrcamentoHistorico ooh            WITH (NOLOCK) ON ooh.OficinaOrcamento_Codigo             = oo.OficinaOrcamento_Codigo (WHERE oo.OficinaOrcamentoHistorico_Data >= @data and OficinaOrcamentoHistorico_Codigo = 'CRI')
	END 
	GO