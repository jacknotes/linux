--预付


IF OBJECT_ID('tempdb.dbo.#emp') IS NOT NULL DROP TABLE #emp
SELECT ROW_NUMBER()OVER(ORDER BY t2.depOrder,t1.idnumber) idx,empname,team,DATEDIFF(m, edateandtime, GETDATE()) as 入职月数
INTO #emp 
from emppwd t1 LEFT JOIN dbo.EmpSysSetting t2 ON t1.team=t2.dep AND t2.ntype=2 where t1.dep = '运营部' and team like ('%差旅%') order by t2.depOrder,t1.idnumber 

IF OBJECT_ID('tempdb.dbo.#t1') IS NOT NULL DROP TABLE #t1
select opername1,sum(nights*pcs) as np,sum(price) as price,sum(totprofit) as totprofit
into #t1
from tbHtlcoupYf 
where prdate>='2018-08-01' and prdate<'2018-09-01'
and status<>-2
and (opername1 in (select empname from #emp) or ApplyPrintPeople in (select empname from #emp))
and opername1=ApplyPrintPeople
group by opername1



IF OBJECT_ID('tempdb.dbo.#t2') IS NOT NULL DROP TABLE #t2
select opername1,sum(nights*pcs)/2 as np,sum(price)/2 as price,sum(totprofit)/2 as totprofit
into #t2
from tbHtlcoupYf 
where prdate>='2018-08-01' and prdate<'2018-09-01'
and status<>-2
and (opername1 in (select empname from #emp) or ApplyPrintPeople in (select empname from #emp))
and opername1<>ApplyPrintPeople
group by opername1


IF OBJECT_ID('tempdb.dbo.#t3') IS NOT NULL DROP TABLE #t3
select ApplyPrintPeople,sum(nights*pcs)/2 as np,sum(price)/2 as price,sum(totprofit)/2 as totprofit
into #t3
from tbHtlcoupYf 
where prdate>='2018-08-01' and prdate<'2018-09-01'
and status<>-2
and (opername1 in (select empname from #emp) or ApplyPrintPeople in (select empname from #emp))
and opername1<>ApplyPrintPeople
group by ApplyPrintPeople





select emp.empname,team,入职月数
,isnull(t1.np,0)+ISNULL(t2.np,0)+ISNULL(t3.np,0) as 间夜
,isnull(t1.price,0)+ISNULL(t2.price,0)+ISNULL(t3.price,0) as 销量
,isnull(t1.totprofit,0)+ISNULL(t2.totprofit,0)+ISNULL(t3.totprofit,0) as 利润
from #emp emp
left join #t1 t1 on t1.opername1=Emp.empname 
left join #t2 t2 on t2.opername1=Emp.empname 
left join #t3 t3 on t3.ApplyPrintPeople=Emp.empname 



--自付

IF OBJECT_ID('tempdb.dbo.#t4') IS NOT NULL DROP TABLE #t4
select opername1,sum(nights*pcs) as np,sum(price) as price,sum(totprofit) as totprofit
into #t4
from tbHotelcoup 
where bldate>='2018-08-01' and bldate<'2018-09-01'
and (opername1 in (select empname from #emp) or Sales in (select empname from #emp))
and opername1=Sales
and status<>-2
group by opername1


IF OBJECT_ID('tempdb.dbo.#t5') IS NOT NULL DROP TABLE #t5
select opername1,sum(nights*pcs)/2 as np,sum(price)/2 as price,sum(totprofit)/2 as totprofit
into #t5
from tbHotelcoup 
where bldate>='2018-08-01' and bldate<'2018-09-01'
and (opername1 in (select empname from #emp) or Sales in (select empname from #emp))
and opername1<>Sales
and status<>-2
group by opername1


IF OBJECT_ID('tempdb.dbo.#t6') IS NOT NULL DROP TABLE #t6
select Sales,sum(nights*pcs)/2 as np,sum(price)/2 as price,sum(totprofit)/2 as totprofit
into #t6
from tbHotelcoup 
where bldate>='2018-08-01' and bldate<'2018-09-01'
and (opername1 in (select empname from #emp) or Sales in (select empname from #emp))
and opername1<>Sales
and status<>-2
group by Sales




select emp.empname,team,入职月数
,isnull(t4.np,0)+ISNULL(t5.np,0)+ISNULL(t6.np,0) as 间夜
,isnull(t4.price,0)+ISNULL(t5.price,0)+ISNULL(t6.price,0) as 销量
,isnull(t4.totprofit,0)+ISNULL(t5.totprofit,0)+ISNULL(t6.totprofit,0) as 利润
from #emp emp
left join #t4 t4 on t4.opername1=Emp.empname 
left join #t5 t5 on t5.opername1=Emp.empname 
left join #t6 t6 on t6.sales=Emp.empname 
