USE [stage]
GO

/****** Object:  View [camada2].[vw_Orcamento_Teste]    Script Date: 28/09/2022 10:37:20 *****hjj*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [camada2].[vw_Orcamento_Teste]
AS
SELECT [SISTEMA]
      ,[ID_Origem]
      ,[Empresa_Codigo]
      ,[Orcamento_Codigo]
      ,[Veiculo_Codigo]
      ,[Chassi]
      ,[Usuario_Codigo]
      ,[Cliente_Codigo]
      ,[Observacao]
      ,[OS_Codigo]
      ,[TipoOS_Codigo]
	,[Sigla_OS]
	,[Descricao_OS]
      ,[Orcamento_Status]
      ,[KM]
      ,[Data_Validade]
      ,[Data_ProximoContato]
      ,[CodigoDeOrigem]
      ,[Atendimento_Codigo]
      ,[DataCriacao]
      ,[HoraCriacao]
      ,[Valor_Servico]
      ,[Produto_Valor]
      ,[Oficina_Valortotal]
      ,[Orcamento_Complementar]
--	,case when DATEDIFF(DAY, [DataCriacao], ISNULL([Data_Validade], GETDATE())) < 0 then 0 
--	 else DATEDIFF(DAY, [DataCriacao], ISNULL([Data_Validade], GETDATE())) end as TempoDuracao_Orcamento
	  ,DATEDIFF(DAY, [DataCriacao],  GETDATE()) AS TempoDuracao_Orcamento
	
  FROM [camada1].[vw_Orcamento_Teste]

GO


