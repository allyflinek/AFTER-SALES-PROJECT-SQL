USE [DW]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_Datas]    Script Date: 25/09/2022 16:42:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--select * from sys.syslanguages where alias like 'Port%'
ALTER function [dbo].[fn_Datas]
(
	@FIRST_DATE		datetime,
	@LAST_DATE		datetime
)

/*
Função fn_Datas, adaptada de F_TABLE_DATE.

A função retorna datas no período compreendido entre os parâmetros 
@FIRST_DATE e @LAST_DATE, inclusive. O período válido é de 01/01/1754
até 31/12/9997. As colunas utilizadas mais frequentemente utilizadas 
tiveram seus nomes traduzidos.

Descrição original:
----------------------------------------------------------------------
This function returns a date table containing all dates
from @FIRST_DATE through @LAST_DATE inclusive.
@FIRST_DATE must be less than or equal to @LAST_DATE.
The valid date range is 1754-01-01 through 9997-12-31.
If any input parameters are invalid, the fuction will produce
an error.

The table returned by F_TABLE_DATE contains a date and
columns with many calculated attributes of that date.
It is designed to make it convenient to get various commonly
needed date attributes without having to program and test
the same logic in many applications.

F_TABLE_DATE is primarily intended to load a permanant
date table, but it can be used directly by an application
when the date range needed falls outside the range loaded
in a permanant table.

If F_TABLE_DATE is used to load a permanant table, the create
table code can be copied from this function.  For a permanent
date table, most columns should be indexed to produce the
best application performance.

*/

returns  @DATE table 
(
[idData]				[int]		not null 
	primary key clustered,
[data]					[datetime]	not null ,
[stringData] [varchar](10) not null,         	   -- Data em formato string dd/mm/aaaa
[dataSeguinte]				[datetime]	not null , -- Data do dia seguinte ao registro analisado
[ano]					[smallint]	not null , 
[anoTrimestre]				[int]	not null , -- Composição de ano e trimestre, ex.: 201504 para 4º trimestre de 2015
[anoMes]				[int]		not null , -- Composição de ano e mês, ex.: 201502 par fevereiro/2015
[anoDia]			[int]		not null ,     -- Composição de ano e dia, ex.: 201513 para 13/01/2015
[trimestre]				[tinyint]	not null ,
[semestre]      [tinyint] not null,
[bimestre]      [tinyint] not null,			   
[mes]					[tinyint]	not null , -- Número do mês do ano
[diaAno]				[smallint]	not null , -- Número do dia do ano
[semanaAno]        [tinyint] not null, 		   -- Número da semana do ano
[diaMes]				[smallint]	not null , -- Número do dia no mês
[diaSemana]				[tinyint]	not null , -- Número do dia da semana

[nomeAno]				[varchar] (4)	not null ,     -- Ano em formato varchar
[nomeAnoTrimestre]			[varchar] (25)	not null , -- Composição de ano e nome do trimestre, ex.: '2015 Q1' 
[nomeAnoMes]			[varchar] (25)	not null , 	   -- Composição de nome de ano e mês, ex.: 2015 jan
[nomeMesAno]             [varchar] (25) not null,      -- Composição do mês com ano, ex.: jan/2015 
[nomeCompletoAnoMes]			[varchar] (25)	not null , -- ex.: 2015 Setembro
[nomeTrimestre]				[varchar] (25)	not null , -- ex.: Q1, Q2
[nomeMes]				[varchar] (25)	not null ,     -- Nome do mês abreviado, ex.: 'jan', 'dez'
[nomeMesCompleto]			[varchar] (25)	not null , -- Nome do mês, ex.: 'Janeiro', 'Dezembro'
[nomeDiaCurto]			[varchar] (25)	not null ,	   -- Nome do dia abreviado, ex.: 'seg', 'sáb'
[nomeDiaSemana]				[varchar] (25)	not null , -- Nome completo do dia, ex.: 'segunda', 'sexta'


[inicioAno]				[datetime]	not null , -- Data de início do ano do registro
[fimAno]				[datetime]	not null , -- Data do final do ano do registro
[inicioTrimestre]		[datetime]	not null , -- Data do início do trimestre
[fimTrimestre]			[datetime]	not null , -- Data do final do trimestre
[inicioMes]				[datetime]	not null , -- Data do início do mês
[fimMes]				[datetime]	not null ,  -- Data do final do mês
[data_YYYYMMDD]		[varchar](25)	not null ,
[data_YYYYMD]			[varchar](25)	not null ,
[data_MMDDYYYY]		[varchar](25)	not null ,
[data_MDYYYY]			[varchar](25)	not null ,
[data_MMMDYYYY]		[varchar](25)	not null ,
[data_MMMMMMMMMDYYYY]		[varchar](25)	not null ,
[data_MMDDYY]			[varchar](25)	not null ,
[data_MDYY]			[varchar](25)	not null 

) 
as
begin
declare @cr	varchar(2)
select @cr = char(13)+Char(10)
declare @ErrorMessage		varchar(400)
declare @START_DATE		datetime
declare @END_DATE		datetime
declare @LOW_DATE	datetime

declare	@start_no	int
declare	@end_no	int


-- Verify @FIRST_DATE is not null 
if @FIRST_DATE is null
	begin
	select @ErrorMessage = '@FIRST_DATE cannot be null'
	goto Error_Exit
	end

-- Verify @LAST_DATE is not null 
if @LAST_DATE is null
	begin
	select @ErrorMessage = '@LAST_DATE cannot be null'
	goto Error_Exit
	end

-- Verify @FIRST_DATE is not before 1754-01-01
IF  @FIRST_DATE < '17540101'	begin
	select @ErrorMessage =
		'@FIRST_DATE cannot before 1754-01-01'+
		', @FIRST_DATE = '+
		isnull(convert(varchar(40),@FIRST_DATE,121),'NULL')
	goto Error_Exit
	end

-- Verify @LAST_DATE is not after 9997-12-31
IF  @LAST_DATE > '99971231'	begin
	select @ErrorMessage =
		'@LAST_DATE cannot be after 9997-12-31'+
		', @LAST_DATE = '+
		isnull(convert(varchar(40),@LAST_DATE,121),'NULL')
	goto Error_Exit
	end

-- Verify @FIRST_DATE is not after @LAST_DATE
if @FIRST_DATE > @LAST_DATE
	begin
	select @ErrorMessage =
		'@FIRST_DATE cannot be after @LAST_DATE'+
		', @FIRST_DATE = '+
		isnull(convert(varchar(40),@FIRST_DATE,121),'NULL')+
		', @LAST_DATE = '+
		isnull(convert(varchar(40),@LAST_DATE,121),'NULL')
	goto Error_Exit
	end

-- Set @START_DATE = @FIRST_DATE at midnight
select @START_DATE	= dateadd(dd,datediff(dd,0,@FIRST_DATE),0)
-- Set @END_DATE = @LAST_DATE at midnight
select @END_DATE	= dateadd(dd,datediff(dd,0,@LAST_DATE),0)
-- Set @LOW_DATE = earliest possible SQL Server datetime
select @LOW_DATE	= convert(datetime,'17530101')

-- Find the number of day from 1753-01-01 to @START_DATE and @END_DATE
select	@start_no	= datediff(dd,@LOW_DATE,@START_DATE) ,
	@end_no	= datediff(dd,@LOW_DATE,@END_DATE)

-- Declare number tables
declare @num1 table (NUMBER int not null primary key clustered)
declare @num2 table (NUMBER int not null primary key clustered)
declare @num3 table (NUMBER int not null primary key clustered)

-- Declare table of ISO Week ranges
declare @ISO_WEEK table
(
[ISO_WEEK_YEAR] 		int		not null primary key clustered
,[ISO_WEEK_YEAR_START_DATE]	datetime	not null
,[ISO_WEEK_YEAR_END_DATE]	Datetime	not null
)

-- Find rows needed in number tables
declare	@rows_needed		int
declare	@rows_needed_root	int
select	@rows_needed		= @end_no - @start_no + 1
select  @rows_needed		=
		case
		when @rows_needed < 10
		then 10
		else @rows_needed
		end
select	@rows_needed_root	= convert(int,ceiling(sqrt(@rows_needed)))

-- Load number 0 to 16
insert into @num1 (NUMBER)
select NUMBER = 0 union all select  1 union all select  2 union all
select          3 union all select  4 union all select  5 union all
select          6 union all select  7 union all select  8 union all
select          9 union all select 10 union all select 11 union all
select         12 union all select 13 union all select 14 union all
select         15
order by
	1
-- Load table with numbers zero thru square root of the number of rows needed +1
insert into @num2 (NUMBER)
select
	NUMBER = a.NUMBER+(16*b.NUMBER)+(256*c.NUMBER)
from @num1 a 
cross join @num1 b cross join @num1 c
where a.NUMBER+(16*b.NUMBER)+(256*c.NUMBER) < @rows_needed_root
order by 1

-- Load table with the number of rows needed for the date range
insert into @num3 (NUMBER)
select
	NUMBER = a.NUMBER+(@rows_needed_root*b.NUMBER)
from @num2 a
cross join @num2 b
where a.NUMBER+(@rows_needed_root*b.NUMBER) < @rows_needed
order by 1

declare	@iso_start_year	int
declare	@iso_end_year	int

select	@iso_start_year	= datepart(year,dateadd(year,-1,@start_date))
select	@iso_end_year	= datepart(year,dateadd(year,1,@end_date))

-- Load table with start and end dates for ISO week years
insert into @ISO_WEEK
	(
	[ISO_WEEK_YEAR],
	[ISO_WEEK_YEAR_START_DATE],
	[ISO_WEEK_YEAR_END_DATE]
	)
select
	[ISO_WEEK_YEAR] = a.NUMBER,
	[0ISO_WEEK_YEAR_START_DATE]	= dateadd(dd,(datediff(dd,@LOW_DATE,dateadd(day,3,dateadd(year,a.[NUMBER]-1900,0)))/7)*7,@LOW_DATE)
  ,[ISO_WEEK_YEAR_END_DATE]	= dateadd(dd,-1,dateadd(dd,(datediff(dd,@LOW_DATE,dateadd(day,3,dateadd(year,a.[NUMBER]+1-1900,0)))/7)*7,@LOW_DATE))
from
	(
	select
		NUMBER = NUMBER+@iso_start_year
	from @num3
	where NUMBER+@iso_start_year <= @iso_end_year
	) a
order by a.NUMBER



-- Load Date table
insert into @DATE
select
	[idData] = a.[DATE_ID]
	,[data]	= a.[DATE] 
  ,[stringData] = convert(varchar(10), a.[DATE], 103)
  ,[dataSeguinte]	= dateadd(day,1,a.[DATE]) 
  ,[ano]			= datepart(year,a.[DATE]) 
  ,[anoTrimestre]		= (10*datepart(year,a.[DATE]))+datepart(quarter,a.[DATE]) 
  ,[anoMes]		= (100*datepart(year,a.[DATE]))+datepart(month,a.[DATE]) 
  ,[anoDia]		= (1000*datepart(year,a.[DATE]))+ datediff(dd,dateadd(yy,datediff(yy,0,a.[DATE]),0),a.[DATE])+1 
  ,[trimestre]		= datepart(quarter,a.[DATE]) 
  ,[semestre] = CASE WHEN datepart(quarter, a.[DATE]) IN (1,2) THEN 1 ELSE 2 END 
  ,[bimestre] = CEILING(datepart(month, a.[DATE])/2.0)
  ,[mes] = datepart(month,a.[DATE]) 
  ,[diaAno]	= datediff(dd,dateadd(yy,datediff(yy,0,a.[DATE]),0),a.[DATE])+1 
  ,[semanaAno] = CEILING((datediff(dd,dateadd(yy,datediff(yy,0,a.[DATE]),0),a.[DATE])+1)/7.0) 
  ,[diaMes]	= datepart(day,a.[DATE]) 
  ,[diaSemana]= (datediff(dd,'17530107',a.[DATE])%7)+1  
  ,[nomeAno]= datename(year,a.[DATE]) 
  ,[nomeAnoTrimestre]	=	datename(year,a.[DATE])+' Q'+datename(quarter,a.[DATE]) 
  ,[nomeAnoMes]	= datename(year,a.[DATE])+' '+ dbo.fn_NomeMes(a.[DATE])
  ,[nomeMesAno] = dbo.fn_NomeMes(a.[DATE]) + '/' + datename(year, a.[DATE]) 
  ,[nomeCompletoAnoMes]	=	datename(year,a.[DATE])+' '+dbo.fn_nomeMesExtenso(a.[DATE])
  ,[nomeTrimestre] = 'Q'+datename(quarter,a.[DATE]) 
  ,[nomeMes]= left(datename(month,a.[DATE]),3) 
  ,[nomeMesCompleto] = dbo.fn_nomeMesExtenso(a.[DATE])
  ,[nomeDiaCurto]	= left(datename(weekday,a.[DATE]),3) 
  ,[nomeDiaSemana]	= dbo.fn_diaDaSemana(a.[DATE])
  ,[inicioAno]	= dateadd(year,datediff(year,0,a.[DATE]),0) 
  ,[fimAno]	=	dateadd(day,-1,dateadd(year,datediff(year,0,a.[DATE])+1,0)) 
  ,[inicioTrimestre]	= dateadd(quarter,datediff(quarter,0,a.[DATE]),0) 
  ,[fimTrimestre]	= dateadd(day,-1,dateadd(quarter,datediff(quarter,0,a.[DATE])+1,0)) 
  ,[inicioMes]= dateadd(month,datediff(month,0,a.[DATE]),0) 
  ,[fimMes]	= dateadd(day,-1,dateadd(month,datediff(month,0,a.[DATE])+1,0))
  ,[data_YYYYMMDD]	= convert(char(25),a.[DATE],111) 
  ,[data_YYYYMD]		= convert(varchar(10),convert(varchar(4),year(a.[DATE]))+'/'+ convert(varchar(2),month(a.[DATE]))+'/'+ convert(varchar(2),day(a.[DATE])))
  ,[data_MMDDYYYY]	= convert(char(10),a.[DATE],101) 
  ,[data_MDYYYY]		= convert(varchar(10),convert(varchar(2),month(a.[DATE]))+'/'+convert(varchar(2),day(a.[DATE]))+'/'+ convert(varchar(4),year(a.[DATE])))
  ,[data_MMMDYYYY]		= convert(varchar(12),left(datename(month,a.[DATE]),3)+' '+	convert(varchar(2),day(a.[DATE]))+', '+	convert(varchar(4),year(a.[DATE])))
  ,[data_MMMMMMMMMDYYYY]	= convert(varchar(18),	datename(month,a.[DATE])+' '+	convert(varchar(2),day(a.[DATE]))+', '+	convert(varchar(4),year(a.[DATE])))
  ,[data_MMDDYY]	=	convert(char(8),a.[DATE],1) 
  ,[data_MDYY]	= convert(varchar(8),convert(varchar(2),month(a.[DATE]))+'/'+convert(varchar(2),day(a.[DATE]))+'/'+right(convert(varchar(4),year(a.[DATE])),2))
from
	(
	-- Derived table is all dates needed for date range
	select	top 100 percent
		[DATE_ID]	= aa.[NUMBER],
		[DATE]		=
			dateadd(dd,aa.[NUMBER],@LOW_DATE)
	from
		(
		select
			NUMBER = NUMBER+@start_no 
		from
			@num3
		where
			NUMBER+@start_no <= @end_no
		) aa
	order by
		aa.[NUMBER]
	) a
	join
	-- Match each date to the proper ISO week year
	@ISO_WEEK b
	on a.[DATE] between 
		b.[ISO_WEEK_YEAR_START_DATE] and 
		b.[ISO_WEEK_YEAR_END_DATE]

order by
	a.[DATE_ID]

return

Error_Exit:

-- Return a pseudo error message by trying to
-- convert an error message string to an int.
-- This method is used because the error displays
-- the string it was trying to convert, and so the
-- calling application sees a formatted error message.

declare @error int

set @error = convert(int,@cr+@cr+
'*******************************************************************'+@cr+
'* Error in function F_TABLE_DATE:'+@cr+'* '+
isnull(@ErrorMessage,'Unknown Error')+@cr+
'*******************************************************************'+@cr+@cr)

return

end



GO

SELECT * FROM DW.DBO.FN_DATAS(
	@FIRST_DATE		datetime,
	@LAST_DATE		datetime
)
