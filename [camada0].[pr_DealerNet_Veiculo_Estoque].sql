USE [stage]
GO

/****** Object:  StoredProcedure [camada0].[pr_DealerNet_Veiculo_Estoque]    Script Date: 26/09/2022 14:34:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [camada0].[pr_DealerNet_Veiculo_Estoque] AS BEGIN
	DROP TABLE IF EXISTS camada0.DealerNet_VeiculoEstoque;

	SELECT DISTINCT veiculoreserva_veiculocod
		INTO #veiculos_reservados
		FROM [Dealer].[DealerNetWF].dbo.veiculoreserva WITH (NOLOCK)
		WHERE veiculoreserva_status = 'aut'
			AND VeiculoReserva_DataInicial <= getdate()
			AND veiculoreserva_datafinal >= getdate();

	CREATE INDEX index_01 ON #veiculos_reservados (veiculoreserva_veiculocod);

	SELECT DISTINCT (Titulo_NotaFiscalCod)
	INTO #veiculos_pagos
	FROM [Dealer].[DealerNetWF].dbo.titulo WITH (NOLOCK)
	WHERE titulo_datapagamento IS NULL
		AND titulo_status <> 'can';

	CREATE INDEX indx_01 ON #veiculos_pagos (Titulo_NotaFiscalCod);

	SELECT veiculobloqueio_veiculocod
	INTO #veiculos_bloqueados
	FROM [Dealer].[DealerNetWF].dbo.veiculobloqueio WITH (NOLOCK)
	WHERE veiculobloqueio_status = 'aut'
		AND veiculobloqueio_datafinal > GETDATE() - 1
	GROUP BY veiculobloqueio_veiculocod;

	CREATE INDEX indx_01 ON #veiculos_bloqueados (veiculobloqueio_veiculocod);

	SELECT Proposta_VeiculoCod
		, proposta_codigo
		, Proposta_EmpresaCod
		, Proposta_DataCriacao
	INTO #veiculos_com_proposta
	FROM [Dealer].[DealerNetWF].dbo.Proposta WITH (NOLOCK)
	WHERE Proposta_Status NOT IN ('CAN', 'FAT', 'ped', 'dev')
		AND proposta_dataValidade > getdate() - 1
		AND Proposta_DataCriacao >= DateAdd(mm, DateDiff(mm, 0, GetDate()) - 1, 0)
	GROUP BY Proposta_VeiculoCod
		, proposta_codigo
		, Proposta_EmpresaCod
		, Proposta_DataCriacao;
	CREATE INDEX indx_01 ON #veiculos_com_proposta (
		Proposta_VeiculoCod
		, Proposta_EmpresaCod
		, proposta_codigo
		);

	SELECT Proposta_VeiculoCod
		, proposta_codigo
		, Proposta_EmpresaCod
		, Proposta_datacriacao
	INTO #veiculos_com_pedido
	FROM [Dealer].[DealerNetWF].dbo.Proposta WITH (NOLOCK)
	WHERE Proposta_Status IN ('ped') 
		AND Proposta_DataCriacao >= DateAdd(mm, DateDiff(mm, 0, GetDate()) - 3, 0) --foi alterado por solicitação Fabiana Didie 12/04/2021
	GROUP BY Proposta_VeiculoCod
		, proposta_codigo
		, Proposta_EmpresaCod
		, Proposta_DataCriacao;

	CREATE INDEX indx_01 ON #veiculos_com_pedido (
		Proposta_VeiculoCod
		, Proposta_EmpresaCod
		, proposta_codigo
		, Proposta_DataCriacao -- a pedido de davi //allyf
		);

	SELECT p1.Veiculo_Codigo
		, data_vigencia
		, veiculoprecousado_valorvenda
	INTO #preco_usado
	FROM (
		SELECT Veiculo_Codigo
			, max(VeiculoPrecoUsado_DataVigencia) AS data_vigencia
		FROM [Dealer].[DealerNetWF].dbo.VeiculoPrecoUsado WITH (NOLOCK)
		WHERE VeiculoPrecoUsado_Status = 'AUT'
		GROUP BY Veiculo_Codigo
		) p1
	INNER JOIN [Dealer].[DealerNetWF].dbo.VeiculoPrecoUsado vpu WITH (NOLOCK) ON (
			p1.veiculo_codigo = vpu.veiculo_codigo
			AND p1.data_vigencia = vpu.VeiculoPrecoUsado_DataVigencia
			)

	CREATE INDEX indx_01 ON #preco_usado (
		Veiculo_Codigo
		, data_vigencia
		, veiculoprecousado_valorvenda
		)

	SELECT mvp.ModeloVeiculo_Codigo
		, mvp.ModeloVeiculoPreco_AnoModelo
		, mvp.ModeloVeiculoPreco_Data
		, data
		, ModeloVeiculoPreco_ValorVenda
	INTO #preco_novo
	FROM (
		SELECT ModeloVeiculo_Codigo
			, ModeloVeiculoPreco_AnoModelo
			, max(ModeloVeiculoPreco_Data) AS data
		FROM [Dealer].[DealerNetWF].dbo.ModeloVeiculoPreco WITH (NOLOCK)
		WHERE ModeloVeiculoPreco_ValorVenda > 0
		GROUP BY ModeloVeiculo_Codigo
			, ModeloVeiculoPreco_AnoModelo
		) preco
	LEFT JOIN [Dealer].[DealerNetWF].dbo.modeloveiculopreco mvp WITH (NOLOCK) ON mvp.modeloveiculo_codigo = preco.ModeloVeiculo_Codigo
		AND preco.ModeloVeiculoPreco_AnoModelo = mvp.ModeloVeiculoPreco_AnoModelo
		AND preco.data = mvp.ModeloVeiculoPreco_Data

	CREATE INDEX indx_01 ON #preco_novo (
		ModeloVeiculo_Codigo
		, ModeloVeiculoPreco_AnoModelo
		)

	SELECT V.Veiculo_Codigo
		, GMOP.GrupoModeloOpcPreco_AnoModelo
		, SUM(GMOP.GrupoModeloOpcPreco_ValorVenda) AS preco_opc
	INTO #preco_opcional
	FROM [Dealer].[DealerNetWF].dbo.Veiculo V WITH (NOLOCK)
	JOIN [Dealer].[DealerNetWF].dbo.ModeloVeiculo MV WITH (NOLOCK) ON V.Veiculo_ModeloVeiculoCod = MV.ModeloVeiculo_Codigo
	JOIN [Dealer].[DealerNetWF].dbo.GrupoModelo GM WITH (NOLOCK) ON MV.ModeloVeiculo_GrupoModeloCod = GM.GrupoModelo_Codigo
	JOIN [Dealer].[DealerNetWF].dbo.VeiculoOpcional VO WITH (NOLOCK) ON V.Veiculo_Codigo = VO.Veiculo_Codigo
	JOIN [Dealer].[DealerNetWF].dbo.Opcional O WITH (NOLOCK) ON VO.VeiculoOpcional_OpcionalCod = O.Opcional_Codigo
	JOIN [Dealer].[DealerNetWF].dbo.GrupoModeloOpcPreco GMOP WITH (NOLOCK) ON GMOP.GrupoModelo_Codigo = GM.GrupoModelo_Codigo
		AND GMOP.GrupoModeloOpcPreco_OpcionalCod = O.Opcional_Codigo
		AND GMOP.GrupoModeloOpcPreco_Data = (
			SELECT MAX(GMOP1.GrupoModeloOpcPreco_Data)
			FROM [Dealer].[DealerNetWF].dbo.GrupoModeloOpcPreco AS GMOP1 WITH (NOLOCK)
			WHERE GMOP1.GrupoModelo_Codigo = GMOP.GrupoModelo_Codigo
				AND GMOP1.GrupoModeloOpcPreco_OpcionalCod = GMOP.GrupoModeloOpcPreco_OpcionalCod
				AND GMOP1.GrupoModeloOpcPreco_AnoModelo = GMOP.GrupoModeloOpcPreco_AnoModelo
			)
	GROUP BY V.Veiculo_Codigo
		, GMOP.GrupoModeloOpcPreco_AnoModelo

	CREATE INDEX indx_01 ON #preco_opcional (
		Veiculo_Codigo
		, GrupoModeloOpcPreco_AnoModelo
		);

-- =============================================
-- Author:		<Allyf Linek>
-- Create date: <23/07/2022>
-- Description:	<trazendo os dias do transtio cpv
-- =============================================


SELECT  veiculo_codigo, veiculomovimento_data1, veiculomovimento_data2, CASE WHEN Dias_Compra_Entrada < '0' THEN NULL ELSE Dias_Compra_Entrada END AS Dias_Compra_Entrada                                                                                      
INTO #CPV_DIASCE
FROM
(SELECT r1.veiculo_codigo, r1.veiculomovimento_data1, r2.veiculomovimento_data2, DATEDIFF(DAY, veiculomovimento_data1,veiculomovimento_data2) AS Dias_Compra_Entrada
FROM 
(SELECT DISTINCT veiculo_codigo AS veiculo_codigo, MAX(veiculomovimento_data) AS veiculomovimento_data1 
FROM 
(SELECT DISTINCT *
FROM dealer.dealernetwf.dbo.veiculoestoque ve
left join dealer.dealernetwf.dbo.veiculomovimento vm  WITH (NOLOCK) ON ve.VeiculoEstoque_VeiculoMovCodEntrada = vm.VeiculoMovimento_Codigo 
WHERE  veiculoestoque_estoquecod = '45') compra_usados
GROUP BY veiculo_codigo)  r1
LEFT JOIN
(SELECT DISTINCT veiculo_codigo AS veiculo_codigo, MAX(veiculomovimento_data) AS veiculomovimento_data2
FROM 
(SELECT DISTINCT *
from dealer.dealernetwf.dbo.veiculoestoque ve
left join dealer.dealernetwf.dbo.veiculomovimento vm WITH (NOLOCK) ON  ve.VeiculoEstoque_VeiculoMovCodEntrada = vm.VeiculoMovimento_Codigo 
WHERE  veiculoestoque_estoquecod in ('48','110')) entrada_recebido1
GROUP BY veiculo_codigo) r2   ON r1.veiculo_codigo = r2.veiculo_codigo) tot1;

	CREATE INDEX indx_01 ON #CPV_DIASCE (
	      veiculo_codigo
		, veiculomovimento_data1
		, veiculomovimento_data2
		, Dias_Compra_Entrada
		);
		
-- =============================================
-- Author:		<Allyf Linek>
-- Create date: <23/07/2022>
-- Description:	<trazendo os dias do deslocamento cpv
-- =============================================

SELECT  veiculo_codigo, veiculomovimento_data1, veiculomovimento_data2, CASE WHEN Dias_Entrada_Cpv < '0' THEN NULL ELSE Dias_Entrada_Cpv END AS Dias_Entrada_Cpv                                                                                          
INTO #CPV_DIASEC
FROM
(SELECT r1.veiculo_codigo, r1.veiculomovimento_data1, r2.veiculomovimento_data2, DATEDIFF(DAY, veiculomovimento_data1,veiculomovimento_data2) AS Dias_Entrada_Cpv
FROM 
(SELECT DISTINCT veiculo_codigo AS veiculo_codigo, MAX(veiculomovimento_data) AS veiculomovimento_data1 
FROM 
(SELECT DISTINCT *
FROM dealer.dealernetwf.dbo.veiculoestoque ve
left join dealer.dealernetwf.dbo.veiculomovimento vm  WITH (NOLOCK) ON ve.VeiculoEstoque_VeiculoMovCodEntrada = vm.VeiculoMovimento_Codigo 
WHERE  veiculoestoque_estoquecod in ('48','110')) entrada_recebido2
GROUP BY veiculo_codigo ) r1
LEFT JOIN
(SELECT DISTINCT veiculo_codigo AS veiculo_codigo, MAX(veiculomovimento_data) AS veiculomovimento_data2
FROM 
(SELECT DISTINCT *
from dealer.dealernetwf.dbo.veiculoestoque ve
left join dealer.dealernetwf.dbo.veiculomovimento vm WITH (NOLOCK) ON  ve.VeiculoEstoque_VeiculoMovCodEntrada = vm.VeiculoMovimento_Codigo 
WHERE  veiculoestoque_estoquecod = '40') cpv_entrada
GROUP BY veiculo_codigo) r2   ON r1.veiculo_codigo = r2.veiculo_codigo) tot2;

	CREATE INDEX indx_01 ON #CPV_DIASEC (
	      veiculo_codigo
		, veiculomovimento_data1
		, veiculomovimento_data2
		, Dias_Entrada_Cpv
		);

	SELECT 'DLR' AS SISTEMAS
		, ve.veiculoestoque_veiculocod AS VEICULO_CODIGO
		, est.ESTOQUE_CODIGO
		, VE.VEICULOESTOQUE_EMPRESACOD AS EMPRESA_CODIGO
		, (DATEDIFF(DAY, nf.notafiscal_dataemissao, GETDATE())) AS DIAS_ESTOQUE
		/*,RANK() OVER   
    (PARTITION BY (CAST(e.Empresa_MarcaCod as VARCHAR(10))+'.'+p.PessoaEndereco_EstadoCod )  
 , est.ESTOQUE_CODIGO ORDER BY (DATEDIFF(DAY,nf.notafiscal_dataemissao,GETDATE())) DESC) AS RANK */
		, CASE 
			WHEN isnull(Titulo_NotaFiscalCod, 0) = 0
				THEN 'S'
			ELSE 'N'
			END AS PAGO
		, nf.NotaFiscal_DataEmissao AS DATA_COMPRA
		, nf.notafiscal_codigo AS CodNF
		, nf.NotaFiscal_ValorTotal AS VALOR_COMPRA
		-------Thiago 12/10/2016 (Estava pegando de acordo com a Empresa ondo o veiculo estava e não a da Proposta)  
		, CASE 
			WHEN PProposta.Proposta_Codigo IS NOT NULL
				THEN PProposta.Proposta_EmpresaCod
			WHEN PPedido.Proposta_Codigo IS NOT NULL
				THEN PPedido.Proposta_EmpresaCod
			ELSE 0
			END AS EMPRESA_PROPOSTAPEDIDO
		--------  
		, isnull(PProposta.proposta_codigo, 0) AS PROPOSTA
		, PProposta.Proposta_DataCriacao AS  PROPOSTA_DATA
		, isnull(PPedido.proposta_codigo, 0) AS PEDIDO
		, PPedido.Proposta_DataCriacao AS PEDIDO_DATA
		, isnull(phist1.PropostaHistorico_UsuarioCod, (isnull(phist2.Propostahistorico_usuariocod, 0))) AS USUARIO_CODIGO
		, CASE 
			WHEN isnull(veiculobloqueio_veiculocod, 0) <> 0
				THEN 'BLOQUEADO'
			ELSE ''
			END AS BLOQUEIO
		, CASE 
			WHEN isnull(veiculoreserva_veiculocod, 0) <> 0
				THEN 'RESERVADO'
			ELSE ''
			END AS RESERVA
		--, isnull(precousado.veiculoprecousado_valorvenda,0)     AS Preco_Usado  
		--, isnull(preco_opc,0)            AS Preco_Opc  
		--, isnull(ModeloVeiculoPreco_ValorVenda,0)       AS Preco_Novo  
		--COR_DESCRICAO,   
		--COMBUSTIVEL_DESCRICAO,  
		--MARCA_DESCRICAO,   
		--FAMILIAVEICULO_DESCRICAO,  
		--MODELOVEICULO_DESCRICAO,   
		--VEICULO_KM,  
		--left(VEICULO_PLACA,7)           AS VEICULO_PLACA,  
		, v.VEICULO_CHASSI
		--VEICULOANO.VEICULOANO_EXIBICAO,  
		, (
			SELECT CASE 
					WHEN (Estoque_Tipo = 'VU')
						THEN isnull(precousado.veiculoprecousado_valorvenda, 0)
					ELSE (isnull(preco_opc, 0) + isnull(ModeloVeiculoPreco_ValorVenda, 0))
					END
			) AS VALOR_VENDA
		, getdate() AS DATA_RELATORIO
		, nf.notafiscal_pessoacod AS PESSOACOD
		, est.Estoque_Tipo AS EstoqueTipo
		, v.veiculo_placa
		, convert(varchar(50),'') as LocalVeiculoDescricao --lv.LocalVeiculo_Descricao LocalVeiculoDescricao    
		, CPVD1.Dias_Compra_Entrada
		, CPVD2.Dias_Entrada_Cpv
		--, pes.Pessoa_Nome as Fornecedor --11/02/2022
	INTO camada0.DealerNet_VeiculoEstoque
	FROM [Dealer].[DealerNetWF].dbo.VeiculoEstoque ve(NOLOCK)
	LEFT JOIN [Dealer].[DealerNetWF].dbo.veiculomovimento entrada(NOLOCK) ON ve.VeiculoEstoque_VeiculoMovCodEntrada = entrada.VeiculoMovimento_Codigo
	LEFT JOIN [Dealer].[DealerNetWF].dbo.veiculomovimento saida(NOLOCK) ON ve.VeiculoEstoque_VeiculoMovCodSaida = saida.VeiculoMovimento_Codigo
	----------Veiculo Comprado  
	LEFT JOIN [Dealer].[DealerNetWF].dbo.notafiscal nf WITH (NOLOCK) ON nf.notafiscal_codigo = ve.veiculoestoque_notafiscalcodcompra
	----------  
	LEFT JOIN [Dealer].[DealerNetWF].dbo.Estoque est(NOLOCK) ON est.Estoque_Codigo = ve.VeiculoEstoque_EstoqueCod
	LEFT JOIN [Dealer].[DealerNetWF].dbo.veiculo v(NOLOCK) ON v.Veiculo_Codigo = ve.VeiculoEstoque_VeiculoCod
	LEFT JOIN [Dealer].[DealerNetWF].dbo.ModeloVeiculo mv(NOLOCK) ON mv.ModeloVeiculo_Codigo = v.Veiculo_ModeloVeiculoCod
	LEFT JOIN [Dealer].[DealerNetWF].dbo.veiculoano ano(NOLOCK) ON ano.veiculoano_codigo = v.VeiculoAno_Codigo
	LEFT JOIN [Dealer].[DealerNetWF].dbo.Empresa e(NOLOCK) ON e.Empresa_Codigo = VE.VEICULOESTOQUE_EMPRESACOD
	LEFT JOIN [Dealer].[DealerNetWF].dbo.Pessoaendereco p(NOLOCK) ON e.Empresa_PessoaCod = p.Pessoa_Codigo
	/*LEFT join [Dealer].[DealerNetWF].dbo.VeiculoTransfLocal vtl WITH (NOLOCK) ON ve.VeiculoEstoque_VeiculoCod = vtl.Veiculo_Codigo
	LEFT JOIN [Dealer].[DealerNetWF].dbo.LocalVeiculo lv WITH (NOLOCK) ON vtl.LocalVeiculo_Codigo = lv.LocalVeiculo_Codigo */
	

	--left join [Dealer].[DealerNetWF].dbo.PESSOA pes (NOLOCK) on pes.pessoa_codigo = nf.notafiscal_pessoacod  --Ativei esse relacionamento para pegar a quem a aprvi comprou, solicitado por Caló 11/02/2022
	--LEFT JOIN FAMILIAVEICULO (NOLOCK) ON FAMILIAVEICULO_CODIGO = MV.MODELOVEICULO_FAMILIAVEICULOCOD_NOVOS  
	--LEFT JOIN MARCA (NOLOCK) ON MARCA_CODIGO = MV.MODELOVEICULO_MARCACOD  
	--LEFT JOIN COMBUSTIVEL (NOLOCK) ON COMBUSTIVEL_CODIGO = MV.MODELOVEICULO_COMBUSTIVELCOD  
	--LEFT JOIN COR (NOLOCK) ON COR_CODIGO = V.VEICULO_CORCODEXTERNA  
	--LEFT JOIN VEICULOANO (NOLOCK) ON V.VEICULOANO_CODIGO = VEICULOANO.VEICULOANO_CODIGO  
	LEFT JOIN #CPV_DIASEC CPVD2 ON veiculoestoque_veiculocod = CPVD2.veiculo_codigo 
	----------
	LEFT JOIN #CPV_DIASCE CPVD1 ON veiculoestoque_veiculocod = CPVD1.veiculo_codigo 
	-----------Veiculos Reservados  
	LEFT JOIN #veiculos_reservados reservado ON reservado.veiculoreserva_veiculocod = ve.veiculoestoque_veiculocod
	-----------Veiculos Pagos  
	LEFT JOIN #veiculos_pagos T ON (T.Titulo_NotaFiscalCod = ve.VeiculoEstoque_NotaFiscalCodCompra)
	-----------Veiculo Bloqueado  
	LEFT JOIN #veiculos_bloqueados VB ON vb.veiculobloqueio_veiculocod = veiculoestoque_veiculocod
	-----------Veiculo com Proposta  
	LEFT JOIN #veiculos_com_proposta PProposta ON (VeiculoEstoque_VeiculoCod = PProposta.Proposta_VeiculoCod)
	----------Veiculo com Pedido  
	
	LEFT JOIN #veiculos_com_pedido PPedido ON (VeiculoEstoque_VeiculoCod = PPedido.Proposta_VeiculoCod)
	----------Vendedor Direcionado  
	LEFT JOIN [Dealer].[DealerNetWF].dbo.PropostaHistorico phist1(NOLOCK) ON phist1.proposta_codigo = ppedido.proposta_codigo
		AND phist1.propostahistorico_codigo = 'cri'
	LEFT JOIN [Dealer].[DealerNetWF].dbo.PropostaHistorico phist2(NOLOCK) ON phist2.proposta_codigo = pproposta.proposta_codigo
		AND phist2.propostahistorico_codigo = 'cri'
	-----------Preco Usado  
	LEFT JOIN #preco_usado precousado ON precousado.Veiculo_Codigo = ve.veiculoestoque_veiculocod
	-----------Preço Novos  
	LEFT JOIN #preco_novo preconv ON preconv.modeloveiculo_codigo = v.veiculo_modeloveiculocod
		AND ano.veiculoano_modelo = preconv.ModeloVeiculoPreco_AnoModelo
	-----------Preco Opcional  
	LEFT JOIN #preco_opcional precoopc ON precoopc.veiculo_codigo = ve.veiculoestoque_veiculocod
		AND ano.veiculoano_modelo = precoopc.GrupoModeloOpcPreco_AnoModelo
	WHERE entrada.VeiculoMovimento_Data <= GETDATE()
		AND (
			saida.VeiculoMovimento_Data > GETDATE()
			OR saida.VeiculoMovimento_Data IS NULL
			)
		AND veiculoestoque_fisicamente = 1
		--and VEICULO_CHASSI = '3FAFP4WJ9HM143881'  

		
	select f.*
	into #transito
	from openquery([dealer],' 
	 /*codigo herdado da função [FN_EstoqueVeiculos] do banco DealernetWF*/

	 select  VeiculoEstoque.*
	 , Transito = CASE WHEN NotaFiscal.NotaFiscal_Codigo IS NULL THEN 0 ELSE CASE WHEN NotaFiscal.NotaFiscal_DataMovimento IS NULL THEN 1 ELSE 0 END END  
	 FROM VeiculoEstoque  
	 JOIN NotaFiscal Compra   ON Compra.NotaFiscal_Codigo     = VeiculoEstoque.VeiculoEstoque_NotaFiscalCodCompra  
			  AND Compra.NotaFiscal_Status     = ''EMI''
	 JOIN Veiculo      ON Veiculo.Veiculo_Codigo      = VeiculoEstoque.VeiculoEstoque_VeiculoCod  
	 JOIN VeiculoMovimento MovEntrada On MovEntrada.VeiculoMovimento_Codigo   = VeiculoEstoque.VeiculoEstoque_VeiculoMovCodEntrada  
			  And MovEntrada.VeiculoMovimento_Codigo   = ( select max(VeiculoMovimento_codigo)  
						   from VeiculoMovimento  
						   join Estoque ON (Estoque.Estoque_Codigo = VeiculoMovimento.VeiculoMovimento_EstoqueCod and Estoque_Tipo not in ( ''OV'',''OF''))  
						   --join    VeiculoEstoque ve on ve.VeiculoEstoque_VeiculoMovCodEntrada = VeiculoMovimento.VeiculoMovimento_Codigo  and VeiculoEstoque_Fisicamente = 1  
						   where Veiculo_Codigo = VeiculoEstoque.VeiculoEstoque_VeiculoCod  
						   AND  VeiculoMovimento_Data <= convert(date,getdate())  
						   AND  VeiculoMovimento_EmpresaCod = VeiculoEstoque_EmpresaCod   
						   AND  VeiculoMovimento_Status = ''AUT''  
						   AND  VeiculoMovimento_Movimento = ''E''
						   AND  VeiculoMovimento_EstoqueCod not in (114)
						   )  
  
	 LEFT JOIN NotaFiscal    ON NotaFiscal.NotaFiscal_Codigo      = MovEntrada.VeiculoMovimento_NotaFiscalCod  
			  AND ( NotaFiscal.NotaFiscal_DataMovimento IS NULL OR NotaFiscal.NotaFiscal_DataMovimento <= convert(date,getdate()) )  
  
	 LEFT JOIN VeiculoMovimento MovSai ON VeiculoEstoque.VeiculoEstoque_VeiculoMovCodSaida = MovSai.VeiculoMovimento_Codigo  
	 Where (  MovSai.VeiculoMovimento_Data > convert(date,getdate())  OR MovSai.VeiculoMovimento_Codigo IS NULL )  
	 ') f

	 alter table camada0.DealerNet_VeiculoEstoque add transito bit default(0)

	 update d set transito =1
	 from camada0.DealerNet_VeiculoEstoque d 
	 inner join #transito t on t.VeiculoEstoque_VeiculoCOd = d.VEICULO_CODIGO
	 where t.transito > 0

	--conforme reuniao dia 03-02-2021, remover estes chassis da toyota do BI devido à problemas no estoque dos mesmos.
	delete from camada0.DealerNet_VeiculoEstoque 
	where veiculo_chassi in ('9BRBL3HE8J0151762','9BRB29BT1K2209584' ,'9BRBD3HE6K0422316','9BRKC3F3XM8105423','9BRBY3BE4M4012459','9BRBY3BE9M4014207','9BRKC9F39M8115430','988611126JK179005' )
	--TOYOTA
	--9BRBL3HE8J0151762 --nao foi vendido (no DLR!)
	--9BRB29BT1K2209584 --nao foi vendido (no DLR!)
	--9BRBD3HE6K0422316 --nao foi vendido (no DLR!)
	--9BRKC3F3XM8105423 --ficha de segmento "inconclusiva"
	--9BRBY3BE4M4012459 --duas entradas e uma saída.
	--9BRBY3BE9M4014207 --problema de migração
	--9BRKC9F39M8115430 --problema de migração
	--FIAT:
	--988611126JK179005 


	--acordado com Caló que seria a KM do cadastro do veículo, caso não tivesse KM válida na Avaliação do Usado Recebido.
	alter table camada0.DealerNet_VeiculoEstoque add km int;
	update ve set km = case when av.AvaliacaoUsado_Kilometragem >  10 then av.AvaliacaoUsado_Kilometragem else v.Veiculo_KM end
	from camada0.DealerNet_VeiculoEstoque ve
	left join [Dealer].[DealerNetWF].dbo.AVALIACAOUSADO AV on AV.AvaliacaoUSado_NotaFiscalCod = ve.CodNF
													AND av.AvaliacaoUsado_Placa = ve.VEICULO_placa
	inner join [Dealer].[DealerNetWF].dbo.Veiculo v on v.Veiculo_Codigo = ve.veiculo_codigo;

	--adicionando a informação de local veiculo

	--adicionando a informação de Local do Veículo:
	select  v2.veiculo_codigo
	,lv.LocalVeiculo_Descricao as LocalVeiculoDescricao
	into #temp_local
	from (
		select veiculo_codigo
		, max(veiculoTransfLocal_DataHora) as MaiorData 
		from [Dealer].[DealerNetWF].dbo.VeiculoTransfLocal vtl WITH (NOLOCK) 
		--where veiculo_codigo = 269309
		group by veiculo_codigo 
	) f
	inner join [Dealer].[DealerNetWF].dbo.VeiculoTransfLocal v2 WITH (NOLOCK) on v2.veiculo_codigo = f.veiculo_codigo and v2.veiculoTransfLocal_DataHora = f.MaiorData
	inner JOIN [Dealer].[DealerNetWF].dbo.LocalVeiculo lv WITH (NOLOCK) ON v2.LocalVeiculo_Codigo = lv.LocalVeiculo_Codigo

	update ve set LocalVeiculoDescricao = left(t.LocalVeiculoDescricao,50)
	from camada0.DealerNet_VeiculoEstoque ve
	inner join #temp_local t on t.veiculo_codigo = ve.VEICULO_CODIGO
	
	--alter table camada0.DealerNet_VeiculoEstoque alter column LocalVeiculoDescricao varchar(50)



	--adicionando os valores de Fipe e AutoAvaliar:
	exec camada0.pr_AutoAvaliar_Avaliacoes_Fipe
END
GO


