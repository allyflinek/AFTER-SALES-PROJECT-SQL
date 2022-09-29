USE [stage]
GO

/****** Object:  View [camada3].[vw_Veiculo_Estoque]    Script Date: 28/09/2022 21:17:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER view [camada3].[vw_Veiculo_Estoque] as     
select      
 e.idEmpresa
,ev.idEstoqueVeiculo  
,vec.IdVeiculo  
,v.idOrigem  
,v.SISTEMAS as SISTEMA  
,v.DATA_COMPRA  
,v.STATUS  
,v.DIAS_ESTOQUE  
,v.CodNF  
--,v.EMPRESA_PROPOSTAPEDIDO  
,v.USUARIO_CODIGO 
,v.PROPOSTA  
,case when v.PROPOSTA_DATA  < '2016-01-01' then '2000-01-01' else PROPOSTA_DATA end PROPOSTA_DATA
,v.PEDIDO  
,case when v.PEDIDO_DATA < '2016-01-01' then '2000-01-01' else PEDIDO_DATA end PEDIDO_DATA
--,v.USUARIO_CODIGO  
,u.idUsuario  
,v.BLOQUEIO  
,v.RESERVA  
--,v.PESSOACOD  
,p.idPessoa  
,v.transito  
,emp2.idEmpresa as idEmpresaPropostaPedido  
,v.km  
,v.valor_venda  
,v.valor_compra  
,v.PAGO  
,v.LocalVeiculoDescricao
,avaliador = convert(varchar(10),aa.avaliador)--aa.avaliador
,valorAvaliacao = convert(float,aa.valorAvaliacao)--aa.valorAvaliacao
,valorTabelaFipe = convert(float,aa.valorTabelaFipe)--aa.valorTabelaFipe
,custoPrevisto = convert(float,aa.custoPrevisto)--aa.custoPrevisto
,segmento_veiculo_resumido = case when vec.Veiculo_Marca in ('FENDT','VALTRA','MASSEY FERGUSON') 
	And (vec.Veiculo_DescModelo like '%PULVERIZADOR%'
		or vec.Veiculo_DescModelo like '%COLHEITADEIRA%'
		or vec.Veiculo_DescModelo like '%COLHETADEIRA%'
		or vec.Veiculo_DescModelo like '%COLHEDORA%'
		or vec.Veiculo_DescModelo like '%PLANTADORA%'
		or vec.Veiculo_DescModelo like '%PLANTADEIRA%'
		or vec.Veiculo_DescModelo like '%PLANTADOURA%'
		or vec.Veiculo_DescModelo like '%ENFADADORA DE FENO%')  Then 'Trator'
		else vec.Veiculo_Segmento End
,v.TME_TRANSITO
,v.TME_DESLOCAMENTO
from [camada2].vw_veiculo_estoque v    
left join dw.dbo.Empresa e on e.Empresa_Codigo = v.Empresa_Codigo and e.Sistema = v.Sistemas    
left join dw.dbo.Veiculo vec on vec.Sistema = v.SISTEMAS and vec.Veiculo_Chassi = v.CHASSIS    
LEFT JOIN dw.dbo.EstoqueVeiculo ev ON ev.sistema = v.sistemas   
 AND   
  (  
  (ev.Estoque_Codigo = v.estoque_codigo and v.sistemas = 'DLR')  
 or  
  (ev.Estoque_Codigo = v.estoque_codigo and ev.Estoque_Tipo = case when v.ESTOQUETIPO = 'P' then 'VN' 
																else v.ESTOQUETIPO end and v.sistemas = 'NBS')  
  )  
left join dw.dbo.Pessoa p on p.Sistema = v.SISTEMAS and p.Pessoa_Codigo = v.PESSOACOD  
left join dw.dbo.Usuario u on u.Sistema = v.SISTEMAS and convert(varchar(25),u.Usuario_Codigo) = v.USUARIO_CODIGO    
left join dw.dbo.Empresa emp2 on emp2.Sistema = v.SISTEMAS and emp2.Empresa_Codigo = v.EMPRESA_PROPOSTAPEDIDO   
left join [camada2].[vw_AutoAvaliar] aa on vec.Veiculo_Placa = convert(varchar(20),aa.placa) and aa.ordem = 1

--(select za.placa from (select max(datahoraavaliacao) as dth, placa from camada1.vw_AutoAvaliar group by placa) za ) and aa.ordem = 1 




--convert(varchar(20),aa.placa) /*and aa.Empresa_Codigo = v.EMPRESA_CODIGO*/ and aa.ordem = 1 

--select top 10 * from [camada1].[vw_AutoAvaliar]
  
GO


