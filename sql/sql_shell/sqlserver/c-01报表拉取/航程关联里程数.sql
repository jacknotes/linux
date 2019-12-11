
--国内
IF OBJECT_ID('tempdb.dbo.#mileage') IS NOT NULL DROP TABLE #mileage
select DISTINCT rtrim(cityfrom)+'-'+rtrim(cityto) route,mileage,kilometres 
--into #mileage
from tbmileage

IF OBJECT_ID('tempdb.dbo.#tbcash1') IS NOT NULL DROP TABLE #tbcash1
select coupno as 销售单号,ride+flightno as 航班号,datetime as 出票日期
,case SUBSTRING(route,1,CHARINDEX('-',route)-1) when '上海浦东' then '上海' when '上海虹桥' then '上海' when '北京首都' then '北京' when '北京南苑' then '北京' when '西安咸阳' then '西安' 
when '遵义新舟' then '遵义' when '揭阳' then '汕头' when '武汉天河' then '武汉' when '景洪' then '西双版纳' when '乌兰察布集宁' then '乌兰察布' when '德宏' then '芒市' when '思茅' then '普洱' when '梅县' then '梅州'
else SUBSTRING(route,1,CHARINDEX('-',route)-1) end as 出发
,case REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) when '上海浦东' then '上海' when '上海虹桥' then '上海' when '北京首都' then '北京' when '北京南苑' then '北京' when '西安咸阳' then '西安' 
when '遵义新舟' then '遵义' when '揭阳' then '汕头' when '武汉天河' then '武汉' when '景洪' then '西双版纳' when '乌兰察布集宁' then '乌兰察布' when '德宏' then '芒市' when '思茅' then '普洱' when '梅县' then '梅州'
else  REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) end as 到达
,route as 行程
,t_source as 供应商来源
into #tbcash1
from tbcash c
where cmpcode='019392'
and (datetime>='2018-01-01' and datetime<'2019-01-01')
and inf=0
and route like ('%-%')
and reti=''
and tickettype='电子票'
order by datetime

IF OBJECT_ID('tempdb.dbo.#tbcash') IS NOT NULL DROP TABLE #tbcash
select *,出发+'-'+到达 as route2,到达+'-'+出发 as route3
into #tbcash
from #tbcash1


IF OBJECT_ID('tempdb.dbo.#tt') IS NOT NULL DROP TABLE #tt
select 销售单号,tbcash.行程,出票日期,mileage,kilometres
into #tt
from #tbcash tbcash
left join #mileage mileage on mileage.route=tbcash.route2 or mileage.route=tbcash.route3

select * from #tt
where kilometres is null



--select * from tbmileage where cityfrom='普洱' or cityto='普洱'
--select * from tbmileage where cityfrom='普洱' and cityto='昆明'

--国际出票信息
select coupno as 销售单号,pasname 乘机人,tcode+ticketno 票号,ride+flightno 航班,REPLACE(route,'-','') 行程
into #test
from Topway..tbcash 
where cmpcode='016485' 
and (datetime>='2018-01-01' and datetime<'2019-01-01') 
and reti=''
and tickettype not in ('改期费', '升舱费','改期升舱')
and route not like'%改期%'
and route not like'%升舱%'
and route not like'%退票%'
and inf=1 

--拆分行程
select 销售单号,乘机人,票号,航班,SUBSTRING(行程,1,3)行程1, SUBSTRING(行程,4,3)行程2, SUBSTRING(行程,7,3)行程3, SUBSTRING(行程,10,3)行程4
into #test1
from #test 

--行程1
select * 
into #xc1
from #test1 test
inner join Topway..tbmileage t on (t.CityFromCode=行程1 and t.CityToCode=行程2)

--行程2
select * 
into #xc2
from #test1 test
inner join Topway..tbmileage t on (t.CityFromCode=行程2 and t.CityToCode=行程3)

--行程3
select * 
into #xc3
from #test1 test
inner join Topway..tbmileage t on (t.CityFromCode=行程3 and t.CityToCode=行程4)

--汇总
select xc1.乘机人,xc1.航班,xc1.票号,xc1.mileage+isnull(xc2.mileage,0)+isnull(xc3.mileage,0) 英里,
xc1.kilometres+isnull(xc2.kilometres,0)+isnull(xc3.kilometres,0)公里  from #xc1 xc1
left join #xc2 xc2 on xc2.销售单号=xc1.销售单号 and xc2.票号=xc1.票号 and xc2.乘机人=xc1.乘机人
left join #xc3 xc3 on xc3.销售单号=xc1.销售单号 and xc3.票号=xc1.票号 and xc3.乘机人=xc1.乘机人
order by 英里