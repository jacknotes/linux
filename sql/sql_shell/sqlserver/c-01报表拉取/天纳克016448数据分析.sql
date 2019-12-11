
IF OBJECT_ID('tempdb.dbo.#t1') IS NOT NULL DROP TABLE #t1
select Department,pasname,SUM(price) as 销量,COUNT(*) as 张数,SUM(price)/COUNT(*) as 平均票价,AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS zkpercent
,AVG(DATEDIFF(day,datetime,begdate)) as 平均出票天数
into #t1
from V_TicketInfo where cmpcode in ('016448')
and datetime>='2018-01-01' and datetime<'2018-10-01'
and inf=1
group by Department,pasname
order by Department

IF OBJECT_ID('tempdb.dbo.#p') IS NOT NULL DROP TABLE #p
select Department,pasname,sum(price) as xl,COUNT(*) as zs
into #p
from tbcash 
where cmpcode in ('016448')
and datetime>='2018-01-01' and datetime<'2018-10-01'
and inf=1
group by Department,pasname
order by Department



IF OBJECT_ID('tempdb.dbo.#gq') IS NOT NULL DROP TABLE #gq
select Department,pasname,sum(price)as xl,COUNT(*) as zs
into #gq
from tbcash 
where cmpcode in ('016448')
and (tickettype like ('%改期%') or t_source like ('%改期%') or route like ('%改期%'))
and datetime>='2018-01-01' and datetime<'2018-10-01'
and inf=1
group by Department,pasname
order by Department


IF OBJECT_ID('tempdb.dbo.#rt') IS NOT NULL DROP TABLE #rt
select Department,pasname,sum(r.rtprice)as xl,COUNT(*) as zs
into #rt
from tbcash c
left join tbReti r on r.reno=c.reti and r.status2 not in (1,3,4)
where c.cmpcode in ('016448')
and reti<>''
and c.datetime>='2018-01-01' and c.datetime<'2018-10-01'
and c.inf=1
group by Department,pasname
order by Department


select t1.*,isnull(gq.zs,0),isnull(gq.xl,0),isnull(rt.zs,0),isnull(rt.xl,0) from #p p 
left join #gq gq on gq.department=p.department and gq.pasname=p.pasname
left join #rt rt on rt.department=p.department and rt.pasname=p.pasname
left join #t1 t1 on t1.Department=p.department and t1.pasname=p.pasname
