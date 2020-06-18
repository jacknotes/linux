IF OBJECT_ID('tempdb.dbo.#XL') IS NOT NULL DROP TABLE #XL
CREATE TABLE #XL(
	航司 varchar(20),
	销量 decimal(18,2),
	利润 decimal(18,2),
	两舱销量 decimal(18,2),
	两舱利润 decimal(18,2),
	Y舱销量 decimal(18,2),
	Y舱利润 decimal(18,2)
)
insert into #XL(航司,销量,利润)(
select ride,SUM(totprice) ,SUM(profit-Mcost)  
from Topway..tbcash c
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and tickettype='电子票'
and inf=0
group by ride
)


insert into #XL(航司,两舱销量,两舱利润)  (
select ride,SUM(totprice),SUM(profit-Mcost) 
from Topway..tbcash c
left join ehomsom..tbInfCabincode t on t.code2=c.ride and c.nclass=t.cabin
and t.begdate<=c.begdate and t.enddate>=c.begdate
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and (cabintype like'%公务舱%' or cabintype like'%头等舱%')
and tickettype='电子票'
and inf=0
group by ride
)

insert into #XL(航司,Y舱销量,Y舱利润)  (
select ride,SUM(totprice),SUM(profit-Mcost) 
from Topway..tbcash c
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and tickettype='电子票'
and c.nclass='Y'
and inf=0
group by ride
)

select 航司,SUM(ISNULL(销量,0)) 销量, SUM(ISNULL(利润,0)) 利润,
SUM(ISNULL(两舱销量,0)) 两舱销量,--SUM(ISNULL(两舱销量,0))/SUM(ISNULL(销量,0)) 两舱销量占比,
SUM(ISNULL(两舱利润,0)) 两舱利润,--SUM(ISNULL(两舱利润,0))/SUM(ISNULL(利润,0)) 两舱利润占比,
SUM(ISNULL(Y舱销量,0))  Y舱销量,--SUM(ISNULL(Y舱销量,0))/SUM(ISNULL(销量,0)) Y舱销量占比,
SUM(ISNULL(Y舱利润,0))  Y舱利润--,SUM(ISNULL(Y舱利润,0))/SUM(ISNULL(利润,0)) Y舱利润占比
from #XL
WHERE 航司<>''
group by 航司
ORDER BY SUM(ISNULL(销量,0)) DESC
