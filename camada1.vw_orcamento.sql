USE [stage]
GO

/****** Object:  View [camada1].[vw_Orcamento_Teste]    Script Date: 28/09/2022 10:30:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [camada1].[vw_Orcamento_Teste]
AS




SELECT
	   o.[SISTEMA]                       AS SISTEMA
      ,o.[ID_Origem]                     AS ID_Origem
      ,o.[Orcamento_Empresacod]          AS Empresa_Codigo
      ,o.[Orcamento_Codigo]              AS Orcamento_Codigo
      ,o.[Orcamento_Veiculocod]          AS Veiculo_Codigo 
	  ,v.[Veiculo_Chassi]                AS Chassi
      ,o.[Orcamento_UsuarioCod]          AS Usuario_Codigo
      ,o.[Orcamento_Pessoa_cod_cliente]  AS Cliente_Codigo
      ,o.[Orcamento_Observacao]          AS Observacao
      ,o.[OficinaServico_OScod]          AS OS_Codigo
      ,o.[Orcamento_TipoOSCod]           AS TipoOS_Codigo
	  ,tp.[TipoOS_Sigla]                 AS Sigla_OS
	  ,tp.[TipoOS_Descricao]             AS Descricao_OS
      ,o.[Orcamento_Status]              AS Orcamento_Status
      ,o.[OficinaOrcamento_KM]           AS KM
      ,o.[Orcamento_Validade]            AS Data_Validade
      ,o.[Orcamento_ProximoContato]      AS Data_ProximoContato
      ,o.[Orcamento_OrcamentoCodOrigem]  AS CodigoDeOrigem
      ,o.[Orcamento_AtendimentoCod]      AS Atendimento_Codigo
      ,o.[Orcamento_DataCriacao]         AS DataCriacao
      ,o.[Orcamento_HoraCriacao]         AS HoraCriacao
      ,o.[OficinaServico_Valor]          AS Valor_Servico
      ,o.[OficinaProduto_Valor]          AS Produto_Valor
	  ,(o.OficinaServico_Valor 
	  + o.OficinaProduto_Valor)          AS Oficina_Valortotal
      ,o.[Orcamento_Complementar]        AS Orcamento_Complementar 
	--  ,os.OS_Numero                      AS OS_Numero
	  FROM camada0.DealerNet_Orcamento_teste o
	--  LEFT JOIN DW.dbo.OS os                     ON os.OS_Codigo        = o.Orcamento_Codigo --AND os.idEmpresa = o.Orcamento_Veiculocod
	  LEFT JOIN camada0.DealerNet_TipoOS tp         ON tp.TipoOS_Codigo   = o.Orcamento_TipoOSCod
	  RIGHT JOIN (SELECT 
	   MAX(Orcamento_Codigo) AS ORCAMENTO_COD
	  ,Orcamento_Veiculocod  AS ORCAMENTO_VEICULOCOD
	  FROM   camada0.DealerNet_Orcamento_teste
	  GROUP BY Orcamento_Veiculocod) Z              ON Z.ORCAMENTO_COD    = O.Orcamento_Codigo
	  LEFT JOIN DW.dbo.Veiculo v                    ON v.Veiculo_Codigo   = o.Orcamento_veiculocod  where v.Sistema = 'dlr';
GO


