--账单撤销
select HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement set HotelSubmitStatus='2'
where BillNumber='020592_20190101'


--夜班列表
IF OBJECT_ID('tempdb.dbo.#emp') IS NOT NULL DROP TABLE #emp
IF OBJECT_ID('tempdb.dbo.#gn') IS NOT NULL DROP TABLE #gn
IF OBJECT_ID('tempdb.dbo.#gj') IS NOT NULL DROP TABLE #gj

SELECT ROW_NUMBER()OVER(ORDER BY t2.depOrder,t1.idnumber) idx,empname
--INTO #emp 
from emppwd t1 
LEFT JOIN dbo.EmpSysSetting t2 ON t1.team=t2.dep AND t2.ntype=2 where t1.team = '差旅运营十组' 
order by t2.depOrder,t1.idnumber 

select SpareTC,count(*) as 国内
--into #gn
from tbcash where 
(datetime BETWEEN '2019-01-01 00:00:00' AND '2019-01-31 23:59:59') 
and SpareTC in (select empname from #emp)
and inf=0
group by SpareTC

select SpareTC,count(*) as 国际
--into #gj
from tbcash where 
(datetime BETWEEN '2019-01-01 00:00:00' AND '2019-01-31 23:59:59') 
and SpareTC in (select empname from #emp)
and inf=1
group by SpareTC

select Emp.empname,gn.国内,gj.国际 from #emp emp
inner join #gn gn on gn.spareTC=Emp.empname
inner join #gj gj on gj.spareTC=Emp.empname
order by idx

select * from Topway..Emppwd where empname='侯彬'
select * from Topway ..EmpSysSetting where dep='差旅运营十组'

select coupno,totprice,* from Topway..tbcash 
where SpareTC='王敏' and datetime BETWEEN '2019-01-01 00:00:00' AND '2019-01-31 23:59:59'