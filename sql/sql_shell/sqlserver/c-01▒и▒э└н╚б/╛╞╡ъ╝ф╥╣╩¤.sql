
IF OBJECT_ID('tempdb.dbo.#emp') IS NOT NULL DROP TABLE #emp
SELECT ROW_NUMBER()OVER(ORDER BY t2.depOrder,t1.idnumber) idx,empname,team,DATEDIFF(m, edateandtime, GETDATE()) as 入职月数
INTO #emp 
from emppwd t1 LEFT JOIN dbo.EmpSysSetting t2 ON t1.team=t2.dep AND t2.ntype=2 where t1.dep = '运营部' and team like ('%差旅%') order by t2.depOrder,t1.idnumber 

IF OBJECT_ID('tempdb.dbo.#t1') IS NOT NULL DROP TABLE #t1
select opername1,sum(nights*pcs) as np,sum(price) as price,sum(totprofit) as totprofit
into #t1
from tbHtlcoupYf 
where prdate>='2018-09-01' and prdate<CONVERT(varchar(20),DateAdd(day,1,'2018-09-27'),23)
and status<>-2
and (opername1 in (select empname from #emp) or ApplyPrintPeople in (select empname from #emp))
and opername1=ApplyPrintPeople
group by opername1



IF OBJECT_ID('tempdb.dbo.#t2') IS NOT NULL DROP TABLE #t2
select opername1,sum(nights*pcs)*0.5 as np,sum(price)*0.5 as price,sum(totprofit)*0.5 as totprofit
into #t2
from tbHtlcoupYf 
where prdate>='2018-09-01' and prdate<CONVERT(varchar(20),DateAdd(day,1,'2018-09-27'),23)
and status<>-2
and (opername1 in (select empname from #emp) or ApplyPrintPeople in (select empname from #emp))
and opername1<>ApplyPrintPeople
group by opername1


IF OBJECT_ID('tempdb.dbo.#t3') IS NOT NULL DROP TABLE #t3
select ApplyPrintPeople,sum(nights*pcs)*0.5 as np,sum(price)*0.5 as price,sum(totprofit)*0.5 as totprofit
into #t3
from tbHtlcoupYf 
where prdate>='2018-09-01' and prdate<CONVERT(varchar(20),DateAdd(day,1,'2018-09-27'),23)
and status<>-2
and (opername1 in (select empname from #emp) or ApplyPrintPeople in (select empname from #emp))
and opername1<>ApplyPrintPeople
group by ApplyPrintPeople

IF OBJECT_ID('tempdb.dbo.#t4') IS NOT NULL DROP TABLE #t4
select opername1,sum(nights*pcs) as adjusetPcs
into #t4 from tbHtlcoupYf 
where prdate>='2018-09-01' and prdate<CONVERT(varchar(20),DateAdd(day,1,'2018-09-27'),23)
and status<>-2 and pcs<0
and (opername1 in (select empname from #emp) or ApplyPrintPeople in (select empname from #emp))
group by opername1

IF OBJECT_ID('tempdb.dbo.#t5') IS NOT NULL DROP TABLE #t5
select opername1,sum(nights*pcs)*0.5 as adjusetPcs
into #t5 from tbHtlcoupYf 
where prdate>='2018-09-01' and prdate<CONVERT(varchar(20),DateAdd(day,1,'2018-09-27'),23)
and status<>-2 and pcs<0
and (opername1 in (select empname from #emp) or ApplyPrintPeople in (select empname from #emp))
and opername1<>ApplyPrintPeople
group by opername1

IF OBJECT_ID('tempdb.dbo.#t6') IS NOT NULL DROP TABLE #t6
select ApplyPrintPeople,sum(nights*pcs)*0.5 as adjusetPcs
into #t6
from tbHtlcoupYf 
where prdate>='2018-09-01' and prdate<CONVERT(varchar(20),DateAdd(day,1,'2018-09-27'),23)
and status<>-2 and pcs<0
and (opername1 in (select empname from #emp) or ApplyPrintPeople in (select empname from #emp))
and opername1<>ApplyPrintPeople
group by ApplyPrintPeople

--select idx,emp.empname as 差旅顾问,team as 所属小组,入职月数
--,isnull(t1.np,0)+ISNULL(t2.np,0)+ISNULL(t3.np,0) as 间夜
--,ISNULL(t4.adjusetPcs,0)+ISNULL(t5.adjusetPcs,0)+ISNULL(t6.adjusetPcs,0) as 调整间夜数
--,isnull(t1.price,0)+ISNULL(t2.price,0)+ISNULL(t3.price,0) as 销量
--,isnull(t1.totprofit,0)+ISNULL(t2.totprofit,0)+ISNULL(t3.totprofit,0) as 利润
--from #emp emp
--left join #t1 t1 on t1.opername1=Emp.empname 
--left join #t2 t2 on t2.opername1=Emp.empname 
--left join #t3 t3 on t3.ApplyPrintPeople=Emp.empname 
--left join #t4 t4 on t4.opername1=Emp.empname 
--left join #t5 t5 on t5.opername1=Emp.empname 
--left join #t6 t6 on t6.ApplyPrintPeople=Emp.empname 
--order by idx

--drop table #t1
--drop table #t2
--drop table #t3
--drop table #t4
--drop table #t5
--drop table #t6



--5036


--自付

IF OBJECT_ID('tempdb.dbo.#t11') IS NOT NULL DROP TABLE #t11
select opername1,sum(nights*pcs) as np,sum(price) as price,sum(totprofit) as totprofit
into #t11
from tbHotelcoup 
where bldate>='2018-09-01' and bldate<CONVERT(varchar(20),DateAdd(day,1,'2018-09-27'),23)
and (opername1 in (select empname from #emp) or Sales in (select empname from #emp))
and opername1=Sales
and status<>-2
group by opername1


IF OBJECT_ID('tempdb.dbo.#t12') IS NOT NULL DROP TABLE #t12
select opername1,sum(nights*pcs)*0.5 as np,sum(price)*0.5 as price,sum(totprofit)*0.5 as totprofit
into #t12
from tbHotelcoup 
where bldate>='2018-09-01' and bldate<CONVERT(varchar(20),DateAdd(day,1,'2018-09-27'),23)
and (opername1 in (select empname from #emp) or Sales in (select empname from #emp))
and opername1<>Sales
and status<>-2
group by opername1


IF OBJECT_ID('tempdb.dbo.#t13') IS NOT NULL DROP TABLE #t13
select Sales,sum(nights*pcs)*0.5 as np,sum(price)*0.5 as price,sum(totprofit)*0.5 as totprofit
into #t13
from tbHotelcoup 
where bldate>='2018-09-01' and bldate<CONVERT(varchar(20),DateAdd(day,1,'2018-09-27'),23)
and (opername1 in (select empname from #emp) or Sales in (select empname from #emp))
and opername1<>Sales
and status<>-2
group by Sales

IF OBJECT_ID('tempdb.dbo.#t14') IS NOT NULL DROP TABLE #t14
select opername1,sum(nights*pcs) as np 
into #t14
from tbHotelcoup 
where bldate>='2018-09-01' and bldate<CONVERT(varchar(20),DateAdd(day,1,'2018-09-27'),23)
and (opername1 in (select empname from #emp) or Sales in (select empname from #emp))
and opername1=Sales
and status<>-2 and pcs<0 
group by opername1


IF OBJECT_ID('tempdb.dbo.#t15') IS NOT NULL DROP TABLE #t15
select opername1,sum(nights*pcs)*0.5 as np 
into #t15
from tbHotelcoup 
where bldate>='2018-09-01' and bldate<CONVERT(varchar(20),DateAdd(day,1,'2018-09-27'),23)
and (opername1 in (select empname from #emp) or Sales in (select empname from #emp))
and opername1<>Sales
and status<>-2 and pcs<0 
group by opername1

IF OBJECT_ID('tempdb.dbo.#t16') IS NOT NULL DROP TABLE #t16
select Sales,sum(nights*pcs)*0.5 as np 
into #t16
from tbHotelcoup 
where bldate>='2018-09-01' and bldate<CONVERT(varchar(20),DateAdd(day,1,'2018-09-27'),23)
and (opername1 in (select empname from #emp) or Sales in (select empname from #emp))
and opername1<>Sales
and status<>-2 and pcs<0 
group by Sales


select idx,emp.empname as 差旅顾问,team as 所属小组,入职月数
,isnull(t1.np,0)+ISNULL(t2.np,0)+ISNULL(t3.np,0) as 预付间夜
,ISNULL(t4.adjusetPcs,0)+ISNULL(t5.adjusetPcs,0)+ISNULL(t6.adjusetPcs,0) as 预付调整间夜数
,isnull(t1.price,0)+ISNULL(t2.price,0)+ISNULL(t3.price,0) as 预付销量
,isnull(t1.totprofit,0)+ISNULL(t2.totprofit,0)+ISNULL(t3.totprofit,0) as 预付利润
,CONVERT(decimal(18,1),isnull(t11.np,0)+ISNULL(t12.np,0)+ISNULL(t13.np,0)) as 自付间夜数
,CONVERT(decimal(18,1),isnull(t14.np,0)+ISNULL(t15.np,0)+ISNULL(t16.np,0)) as 自付调整间夜数
,isnull(t11.price,0)+ISNULL(t12.price,0)+ISNULL(t13.price,0) as 自付销量
,isnull(t11.totprofit,0)+ISNULL(t12.totprofit,0)+ISNULL(t13.totprofit,0) as 自付利润
,isnull(t1.np,0)+ISNULL(t2.np,0)+ISNULL(t3.np,0)+CONVERT(decimal(18,1),isnull(t11.np,0)+ISNULL(t12.np,0)+ISNULL(t13.np,0)) as 总间夜数
,ISNULL(t4.adjusetPcs,0)+ISNULL(t5.adjusetPcs,0)+ISNULL(t6.adjusetPcs,0)+CONVERT(decimal(18,1),isnull(t14.np,0)+ISNULL(t15.np,0)+ISNULL(t16.np,0)) as 总调整间夜数
,isnull(t1.price,0)+ISNULL(t2.price,0)+ISNULL(t3.price,0)+isnull(t11.price,0)+ISNULL(t12.price,0)+ISNULL(t13.price,0) as 总销量
,isnull(t1.totprofit,0)+ISNULL(t2.totprofit,0)+ISNULL(t3.totprofit,0)+isnull(t11.totprofit,0)+ISNULL(t12.totprofit,0)+ISNULL(t13.totprofit,0)  as 总利润
from #emp emp
left join #t1 t1 on t1.opername1=Emp.empname 
left join #t2 t2 on t2.opername1=Emp.empname 
left join #t3 t3 on t3.ApplyPrintPeople=Emp.empname 
left join #t4 t4 on t4.opername1=Emp.empname 
left join #t5 t5 on t5.opername1=Emp.empname 
left join #t6 t6 on t6.ApplyPrintPeople=Emp.empname 
left join #t11 t11 on t11.opername1=Emp.empname 
left join #t12 t12 on t12.opername1=Emp.empname 
left join #t13 t13 on t13.sales=Emp.empname 
left join #t14 t14 on t14.opername1=Emp.empname 
left join #t15 t15 on t15.opername1=Emp.empname 
left join #t16 t16 on t16.sales=Emp.empname 
order by idx