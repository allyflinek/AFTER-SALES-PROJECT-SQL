USE [stage]
GO
/****** Object:  StoredProcedure [camada3].[pr_metaPBIVeiculos]    Script Date: 04/08/2022 14:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [camada3].[pr_metaPBIVeiculos] as begin
--drop table if exists #MetaVN;
--drop table if exists #MetaUsados;
--drop table if exists #MetaVN;

select f.* into #MetaUsados
from [camada0].[Excel_METASPBI_MetaUsados] f

select f.* into #MetaVN
from [camada0].[Excel_METASPBI_MetaVN] f

select f.* into #MetaVNUF
from [camada0].[Excel_METASPBI_MetaVNUF] f where DIRETOR is not null;

select f.* into #MetaPesados
from camada0.Excel_METASPBI_MetaPesados f

--select * from dw.dbo.MetasEmpresa m
update dw.dbo.MetasEmpresa set MetaVendaUsados = 0, MetaCompraUsados=0,MetaEstoqueUsados=0,MetaVendaVarejo=0,MetaCompraVarejo=0,
MetaEstoqueVarejo=0,MetaVendaPesados=0,MetaCompraPesados=0,MetaEstoquePesados=0

merge dw.dbo.MetasEmpresa m
using (
	select e.idEmpresa, m.AnoMes
	,MetaVendas = m.QtdVenda/q.qtdEmpresas
	,MetaCompras =  m.QtdCompra/q.qtdEmpresas
	,MetaEstoque =  m.QtdEstoque/q.qtdEmpresas
	from #MetaUsados m
	inner join dw.dbo.vw_DimEmpresa e on e.Diretor_Usados = m.Diretor collate Latin1_general_CI_AI and e.Empresa_VendaVeiculoPadrao = 'Sim'
	inner join (select Diretor_Usados, COUNT(0)*1.0 as qtdEmpresas from dw.dbo.vw_DimEmpresa where Empresa_VendaVeiculoPadrao = 'Sim' group by Diretor_Usados) q on q.Diretor_Usados = m.diretor collate Latin1_general_CI_AI
) o on o.idEmpresa = m.idEmpresa and o.AnoMes = m.AnoMes
when matched then update set AnoMes = o.AnoMes
,MetaVendaUsados = o.MetaVendas
,MetaCompraUsados = o.MetaCompras
,MetaEstoqueUsados = o.MetaEstoque
when not matched then insert (idEmpresa,MetaVendaUsados, MetaCompraUsados, MetaEstoqueUsados, AnoMes)
                      values (o.idEmpresa,o.MetaVendas,o.MetaCompras,o.MetaEstoque,o.AnoMes);
--when not matched by source  then delete;

merge dw.dbo.MetasEmpresa m
using (
	select e.idEmpresa, m.AnoMes
	,MetaVendas = m.QtdVenda/q.qtdEmpresas
	,MetaCompras =  m.QtdCompra/q.qtdEmpresas
	,MetaEstoque =  m.QtdEstoque/q.qtdEmpresas
	from #MetaVN m
	inner join dw.dbo.vw_DimEmpresa e on e.Empresa_MarcaDescr = m.Marca collate Latin1_general_CI_AI and e.empresa_tipo = 'AUTOS' and e.Empresa_VendaVeiculoPadrao = 'Sim'
	inner join (select Empresa_MarcaDescr, COUNT(0)*1.0 as qtdEmpresas from dw.dbo.vw_DimEmpresa where Empresa_VendaVeiculoPadrao = 'Sim' AND Sistema <> 'SIS' group by Empresa_MarcaDescr) q on q.Empresa_MarcaDescr = m.Marca collate Latin1_general_CI_AI
) o on o.idEmpresa = m.idEmpresa and o.AnoMes = m.AnoMes
when matched then update set AnoMes = o.AnoMes
,MetaVendaVarejo = o.MetaVendas
,MetaCompraVarejo = o.MetaCompras
,MetaEstoqueVarejo = o.MetaEstoque
when not matched then insert (idEmpresa,MetaVendaVarejo, MetaCompraVarejo, MetaEstoqueVarejo, AnoMes)
                      values (o.idEmpresa,o.MetaVendas,o.[MetaCompras],o.[MetaEstoque],o.AnoMes);
--when not matched by source  then delete;

merge dw.dbo.MetasEmpresa m
using (
	select e.idEmpresa, m.AnoMes
	,MetaVendas = m.QtdVenda/q.qtdEmpresas
	,MetaCompras =  m.QtdCompra/q.qtdEmpresas
	,MetaEstoque =  m.QtdEstoque/q.qtdEmpresas
	from #MetaVN m
	inner join dw.dbo.vw_DimEmpresa e on e.Empresa_MarcaDescr = m.Marca collate Latin1_general_CI_AI and e.empresa_tipo = 'PREMIUM' and e.Empresa_VendaVeiculoPadrao = 'Sim'
	inner join (select Empresa_MarcaDescr, COUNT(0)*1.0 as qtdEmpresas from dw.dbo.vw_DimEmpresa where Empresa_VendaVeiculoPadrao = 'Sim' AND Sistema <> 'SIS' group by Empresa_MarcaDescr) q on q.Empresa_MarcaDescr = m.Marca collate Latin1_general_CI_AI
) o on o.idEmpresa = m.idEmpresa and o.AnoMes = m.AnoMes
when matched then update set AnoMes = o.AnoMes
,MetaVendaLUXO = o.MetaVendas
,MetaCompraLUXO = o.MetaCompras
,MetaEstoqueLUXO = o.MetaEstoque
when not matched then insert (idEmpresa,MetaVendaLUXO, MetaCompraLUXO, MetaEstoqueLUXO, AnoMes)
                      values (o.idEmpresa,o.MetaVendas,o.[MetaCompras],o.[MetaEstoque],o.AnoMes);
--when not matched by source  then delete;

merge dw.dbo.MetasEmpresa m
using (
	select e.idEmpresa, m.AnoMes
	,MetaVendas = m.QtdVenda/q.qtdEmpresas
	,MetaCompras =  m.QtdCompra/q.qtdEmpresas
	,MetaEstoque =  m.QtdEstoque/q.qtdEmpresas
	from #MetaPesados m
	inner join dw.dbo.vw_DimEmpresa e on e.Empresa_MarcaDescr = m.Empresa collate Latin1_general_CI_AI and e.Empresa_VendaVeiculoPadrao = 'Sim'
	inner join (select Empresa_MarcaDescr, COUNT(0)*1.0 as qtdEmpresas from dw.dbo.vw_DimEmpresa where Empresa_VendaVeiculoPadrao = 'Sim' group by Empresa_MarcaDescr) q on q.Empresa_MarcaDescr = m.Empresa collate Latin1_general_CI_AI
) o on o.idEmpresa = m.idEmpresa and o.AnoMes = m.AnoMes
when matched then update set AnoMes = o.AnoMes
,MetaVendaPesados = o.MetaVendas
,MetaCompraPesados = o.MetaCompras
,MetaEstoquePesados = o.MetaEstoque
when not matched then insert (idEmpresa,MetaVendaPesados, MetaCompraPesados, MetaEstoquePesados, AnoMes)
                      values (o.idEmpresa,o.MetaVendas,o.[MetaCompras],o.[MetaEstoque],o.AnoMes);




--meta de VN x Diretor
merge dw.dbo.MetasEmpresa m
using (
	select e.idEmpresa, m.AnoMes
	,MetaVendas = m.QtdVenda     /q.qtdEmpresas
	,MetaCompras =  m.QtdCompra  /q.qtdEmpresas
	,MetaEstoque =  m.QtdEstoque /q.qtdEmpresas
	,m.diretor
	from #MetaVNUF m
	inner join dw.dbo.vw_DimEmpresa e on e.Empresa_MarcaDescr = m.Marca collate Latin1_general_CI_AI 
		and e.empresa_tipo = 'AUTOS' 
		and e.Empresa_VendaVeiculoPadrao = 'Sim'
		and replace(e.Marca_DiretorNovos,'VOLKSWAGEN','VW') = replace(m.MARCA,'VOLKSWAGEN','VW') + ' (' + m.diretor + ')' collate Latin1_general_CI_AI
	inner join (select Marca_DiretorNovos 
				, COUNT(0)*1.0 as qtdEmpresas 
				from dw.dbo.vw_DimEmpresa where Empresa_VendaVeiculoPadrao = 'Sim' AND Sistema <> 'SIS' 
				group by Marca_DiretorNovos) q on q.Marca_DiretorNovos = replace(m.MARCA,'VOLKSWAGEN','VW') + ' (' + m.diretor + ')' collate Latin1_general_CI_AI
) o on o.idEmpresa = m.idEmpresa and o.AnoMes = m.AnoMes
when matched then update set AnoMes = o.AnoMes
,MetaVendaVarejo = o.MetaVendas
,MetaCompraVarejo = o.MetaCompras
,MetaEstoqueVarejo = o.MetaEstoque
when not matched then insert (idEmpresa,MetaVendaVarejo, MetaCompraVarejo, MetaEstoqueVarejo, AnoMes)
                      values (o.idEmpresa,o.MetaVendas,o.[MetaCompras],o.[MetaEstoque],o.AnoMes);
--when not matched by source  then delete;

end
GO
