USE [dw]
GO

/****** Object:  View [dbo].[vw_VeiculoEstoque]    Script Date: 04/10/2022 08:45:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER view [dbo].[vw_VeiculoEstoque] as --with schemabinding as   
select    
 v.id
,v.sistema
,v.idOrigem
,v.dataFechamento
,v.idEmpresa
,v.idEstoqueVeiculo
,v.IdVeiculo
,v.idPessoa
,v.idUsuario
,v.idEmpresaPropostaPedido
,v.data_compra
,v.dias_estoque
,v.status
,v.CodNF
,v.Usuario_Codigo
,v.proposta
,v.proposta_data
,v.pedido
,v.pedido_data
,v.bloqueio
,v.reserva
,v.transito
,v.km
,v.valor_venda
,v.valor_compra
,v.Pago
,v.UltimaDataFechamentoMes
,v.UltimaDataFechamentoTrimestre
,v.UltimaDataFechamentoAno
,v.UltimaDataFechamentoPeriodoAnalise
,v.LocalVeiculoDescricao  
,FaixaEstoque = case when v.dias_estoque between 0 and 30 then '0 a 30'  
     when v.dias_estoque between 31 and 90 then '31 a 90'  
     when v.dias_estoque between 91 and 120 then '91 a 120'  
     when v.dias_estoque between 121 and 149 then '121 a 149'  
	 when v.dias_estoque between 150 and 180 then '150 a 180'
     when v.dias_estoque > 180 then '> 180'  
     else '-'  
     end  
,FaixaEstoque_Numero = case when v.dias_estoque between 0 and 30 then 1  
     when v.dias_estoque between 31 and 90 then 2  
     when v.dias_estoque between 91 and 120 then 3  
     when v.dias_estoque between 121 and 149 then 4  
	 when v.dias_estoque between 150 and 180 then 5
     when v.dias_estoque > 180 then 6  
     else 7  
     end  
,FaixaEstoqueValor = case when v.valor_compra between 0 and 50999 then '0 a 50mil'  
     when v.valor_compra between 51000 and 75999 then '51mil a 75mil'
     when v.valor_compra between 76000 and 100999 then '76mil a 100mil'  
     when v.valor_compra between 101000 and 150999 then '101mil a 150mil'  
     when v.valor_compra between 151000 and 200999 then '151mil a 200mil'  
     --when v.valor_compra > 201000 then '> 201mil'
	 when v.valor_compra > 200999 then '> 201mil'  
     else '-'  
     end  
,FaixaEstoqueValorOrdem = case when v.valor_compra between 0 and 50999 then 1  
     when v.valor_compra between 51000 and 75999 then 2  
     when v.valor_compra between 76000 and 100999 then 3
	 when v.valor_compra between 101000 and 150999 then 4  
     when v.valor_compra between 151000 and 200999 then 5  
     --when v.valor_compra > 201000 then 5  
	 when v.valor_compra > 200999 then 6  
     else 7  
     end  
,empc.EmpresaCompra  
,v.avaliador
,v.valorAvaliacao
,v.valorTabelaFipe
,v.custoPrevisto
,v.segmento_veiculo_resumido
,v.TME_TRANSITO 
,V.TME_DESLOCAMENTO
from dbo.VeiculoEstoque v  
left join dbo.vw_empresaCompraVeiculoEstoque empc on empc.idVeiculoEstoque = v.id  

GO


