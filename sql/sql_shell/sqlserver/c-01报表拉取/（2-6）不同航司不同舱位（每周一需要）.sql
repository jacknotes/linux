

IF OBJECT_ID('tempdb.dbo.#emp') IS NOT NULL DROP TABLE #emp
SELECT ROW_NUMBER()OVER(ORDER BY t2.depOrder,t1.idnumber) idx,empname,team
INTO #emp 
from emppwd t1 LEFT JOIN dbo.EmpSysSetting t2 ON t1.team=t2.dep AND t2.ntype=2 where t1.dep = '运营部' order by t2.depOrder,t1.idnumber 



IF OBJECT_ID('tempdb.dbo.#a') IS NOT NULL DROP TABLE #a
select team as 小组
,SpareTC as 操作业务顾问,datetime as 出票日期,coupno as 销售单号,tcode+ticketno as 票号,begdate as 起飞时间,ride as 航司,nclass as 舱位,TicketOperationRemark as 人工出票原因,cmpcode as 单位编号,c.route as 航程,quota1+quota2+quota3+quota4 as 定额费
,totprice as 销售价,totsprice as 结算价,profit-Mcost as 销售利润,reti as 退票
into #a
from tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join #emp emp on Emp.empname=c.SpareTC
where (datetime>='2018-07-01' and datetime<'2018-08-01')
and t_source like ('%HS%') and inf=0
--and trvYsId=0 and ConventionYsId=0
and 
((ride='HO' and nclass in ('A','U','H','Q','V','W','S','T','Z','E')) OR
(ride='SC' AND nclass IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
(ride='RY' AND nclass IN ('M','L','K','N','Q','V','T','R','U')) OR
(ride='ZH' AND nclass IN ('M','U','H','Q','V','W','S','E')) OR
(ride='CZ' AND nclass IN ('V','E','L','A','U','H','M','B','C','Z')) OR
(ride='HU' AND nclass IN ('Q')) OR
(ride='KY' AND nclass IN ('D')) OR
(ride='JD' AND nclass IN ('W')) OR
(ride='UQ' AND nclass IN ('Q')) OR
(ride='GJ' AND nclass IN ('X')) OR
(ride='JR' AND nclass IN ('P')) OR
(ride='3U' AND nclass IN ('W','G','S','L','E','V','R','K','N')) OR
(ride='GS' AND nclass IN ('Q'))
)
order by Emp.idx

IF OBJECT_ID('tempdb.dbo.#a2') IS NOT NULL DROP TABLE #a2
select team as 小组
,SpareTC as 操作业务顾问,datetime as 出票日期,coupno as 销售单号,tcode+ticketno as 票号,begdate as 起飞时间,ride as 航司,nclass as 舱位,TicketOperationRemark as 人工出票原因,cmpcode as 单位编号,c.route as 航程,quota1+quota2+quota3+quota4 as 定额费
,totprice as 销售价,totsprice as 结算价,profit-Mcost as 销售利润,reti as 退票
into #a2
from tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join #emp emp on Emp.empname=c.SpareTC
where 
t_source like ('%HS%') and inf=0
--and trvYsId=0 and ConventionYsId=0
and 
((ride='HO' and nclass in ('A','U','H','Q','V','W','S','T','Z','E')) OR
(ride='SC' AND nclass IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
(ride='RY' AND nclass IN ('M','L','K','N','Q','V','T','R','U')) OR
(ride='ZH' AND nclass IN ('M','U','H','Q','V','W','S','E')) OR
(ride='CZ' AND nclass IN ('V','E','L','A','U','H','M','B','C','Z')) OR
(ride='HU' AND nclass IN ('Q')) OR
(ride='KY' AND nclass IN ('D')) OR
(ride='JD' AND nclass IN ('W')) OR
(ride='UQ' AND nclass IN ('Q')) OR
(ride='GJ' AND nclass IN ('X')) OR
(ride='JR' AND nclass IN ('P')) OR
(ride='3U' AND nclass IN ('W','G','S','L','E','V','R','K','N')) OR
(ride='GS' AND nclass IN ('Q'))
)
order by Emp.idx



--后返航司
IF OBJECT_ID('tempdb.dbo.#hf') IS NOT NULL DROP TABLE #hf
select team,empname,COUNT(*) as 后返张数
into #hf
from #emp emp
left join #a a on emp.empname=a.操作业务顾问
where ((航司='HO' and 舱位 in ('A','U','H','Q','V','W','S','T','Z','E')) OR
(航司='SC' AND 舱位 IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
(航司='RY' AND 舱位 IN ('M','L','K','N','Q','V','T','R','U')) OR
(航司='ZH' AND 舱位 IN ('M','U','H','Q','V','W','S','E')) OR
(航司='CZ' AND 舱位 IN ('V','E','L','A','U','H','M','B','C','Z')) OR
(航司='3U' AND 舱位 IN ('G','S','L','E','V','R','K','N'))
)
and 人工出票原因 like ('%直加%')
group by team,empname,idx
order by idx

--前返航司
IF OBJECT_ID('tempdb.dbo.#qf') IS NOT NULL DROP TABLE #qf
select team,empname,COUNT(*) as 前返张数
into #qf
from #emp emp
left join #a a on emp.empname=a.操作业务顾问
where ((航司='HU' AND 舱位 IN ('Q')) OR
(航司='KY' AND 舱位 IN ('D')) OR
(航司='JD' AND 舱位 IN ('W')) OR
(航司='UQ' AND 舱位 IN ('Q')) OR
(航司='GJ' AND 舱位 IN ('X')) OR
(航司='JR' AND 舱位 IN ('P')) OR
(航司='3U' AND 舱位 IN ('W')) OR
(航司='GS' AND 舱位 IN ('Q'))
)
--and 人工出票原因 like ('%直加%')
group by team,empname,idx
order by idx

--非直加
IF OBJECT_ID('tempdb.dbo.#fzj') IS NOT NULL DROP TABLE #fzj
select team,empname,COUNT(*) as 非直加张数
into #fzj
from #emp emp
left join #a a on emp.empname=a.操作业务顾问
where ((航司='HO' and 舱位 in ('A','U','H','Q','V','W','S','T','Z','E')) OR
(航司='SC' AND 舱位 IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
(航司='RY' AND 舱位 IN ('M','L','K','N','Q','V','T','R','U')) OR
(航司='ZH' AND 舱位 IN ('M','U','H','Q','V','W','S','E')) OR
(航司='CZ' AND 舱位 IN ('V','E','L','A','U','H','M','B','C','Z')) OR
(航司='3U' AND 舱位 IN ('G','S','L','E','V','R','K','N'))
)
and 人工出票原因 not like ('%直加%')
group by team,empname,idx
order by idx




--后返退票
IF OBJECT_ID('tempdb.dbo.#hft') IS NOT NULL DROP TABLE #hft
select team,empname,COUNT(*) as 后返退票张数
into #hft
from #emp emp
left join #a2 a2 on emp.empname=a2.操作业务顾问
left join tbReti r on r.reno=a2.退票
where ((航司='HO' and 舱位 in ('A','U','H','Q','V','W','S','T','Z','E')) OR
(航司='SC' AND 舱位 IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
(航司='RY' AND 舱位 IN ('M','L','K','N','Q','V','T','R','U')) OR
(航司='ZH' AND 舱位 IN ('M','U','H','Q','V','W','S','E')) OR
(航司='CZ' AND 舱位 IN ('V','E','L','A','U','H','M','B','C','Z')) OR
(航司='3U' AND 舱位 IN ('G','S','L','E','V','R','K','N'))
)
and 人工出票原因 like ('%直加%')
and 退票<>''
and r.status2 not in (1,3,4)
and (r.ExamineDate>='2018-07-01' and ExamineDate<'2018-08-01')
group by team,empname,idx
order by idx

--前返退票
IF OBJECT_ID('tempdb.dbo.#qft') IS NOT NULL DROP TABLE #qft
select team,empname,COUNT(*) as 前返退票张数
into #qft
from #emp emp
left join #a2 a2 on emp.empname=a2.操作业务顾问
left join tbReti r on r.reno=a2.退票
where ((航司='HU' AND 舱位 IN ('Q')) OR
(航司='KY' AND 舱位 IN ('D')) OR
(航司='JD' AND 舱位 IN ('W')) OR
(航司='UQ' AND 舱位 IN ('Q')) OR
(航司='GJ' AND 舱位 IN ('X')) OR
(航司='JR' AND 舱位 IN ('P')) OR
(航司='3U' AND 舱位 IN ('W')) or
(航司='GS' AND 舱位 IN ('Q'))
)
--and 人工出票原因 like ('%直加%')
and 退票<>''
and r.status2 not in (1,3,4)
and (r.ExamineDate>='2018-07-01' and ExamineDate<'2018-08-01')
group by team,empname,idx
order by idx


IF OBJECT_ID('tempdb.dbo.#b1') IS NOT NULL DROP TABLE #b1
select Emp.team as 小组,Emp.empname as 业务顾问,isnull(前返张数,0) as 直加前返张数,isnull(后返张数,0) as 直加后返张数
,isnull(前返退票张数,0) as 直加前返退票张数,isnull(后返退票张数,0) as 直加后返退票张数
,isnull(前返张数,0)+isnull(后返张数,0)-isnull(前返退票张数,0)-isnull(后返退票张数,0) as 直加计数,isnull(后返张数,0)-ISNULL(后返退票张数,0) as [后返张数-后返退票张数] 
into #b1
from #emp emp 
left join #hf hf on Emp.empname=hf.empname
left join #qf qf on Emp.empname=qf.empname
left join #fzj fzj on Emp.empname=fzj.empname
left join #hft hft on Emp.empname=hft.empname
left join #qft qft on Emp.empname=qft.empname
where Emp.team='差旅运营一组'




IF OBJECT_ID('tempdb.dbo.#b2') IS NOT NULL DROP TABLE #b2
select Emp.team as 小组,Emp.empname as 业务顾问,isnull(前返张数,0) as 直加前返张数,isnull(后返张数,0) as 直加后返张数
,isnull(前返退票张数,0) as 直加前返退票张数,isnull(后返退票张数,0) as 直加后返退票张数
,isnull(前返张数,0)+isnull(后返张数,0)-isnull(前返退票张数,0)-isnull(后返退票张数,0) as 直加计数,isnull(后返张数,0)-ISNULL(后返退票张数,0) as [后返张数-后返退票张数] 
into #b2
from #emp emp 
left join #hf hf on Emp.empname=hf.empname
left join #qf qf on Emp.empname=qf.empname
left join #fzj fzj on Emp.empname=fzj.empname
left join #hft hft on Emp.empname=hft.empname
left join #qft qft on Emp.empname=qft.empname
where Emp.team='差旅运营二组'

IF OBJECT_ID('tempdb.dbo.#b3') IS NOT NULL DROP TABLE #b3
select Emp.team as 小组,Emp.empname as 业务顾问,isnull(前返张数,0) as 直加前返张数,isnull(后返张数,0) as 直加后返张数
,isnull(前返退票张数,0) as 直加前返退票张数,isnull(后返退票张数,0) as 直加后返退票张数
,isnull(前返张数,0)+isnull(后返张数,0)-isnull(前返退票张数,0)-isnull(后返退票张数,0) as 直加计数,isnull(后返张数,0)-ISNULL(后返退票张数,0) as [后返张数-后返退票张数] 
into #b3
from #emp emp 
left join #hf hf on Emp.empname=hf.empname
left join #qf qf on Emp.empname=qf.empname
left join #fzj fzj on Emp.empname=fzj.empname
left join #hft hft on Emp.empname=hft.empname
left join #qft qft on Emp.empname=qft.empname
where Emp.team='差旅运营三组'

IF OBJECT_ID('tempdb.dbo.#b4') IS NOT NULL DROP TABLE #b4
select Emp.team as 小组,Emp.empname as 业务顾问,isnull(前返张数,0) as 直加前返张数,isnull(后返张数,0) as 直加后返张数
,isnull(前返退票张数,0) as 直加前返退票张数,isnull(后返退票张数,0) as 直加后返退票张数
,isnull(前返张数,0)+isnull(后返张数,0)-isnull(前返退票张数,0)-isnull(后返退票张数,0) as 直加计数,isnull(后返张数,0)-ISNULL(后返退票张数,0) as [后返张数-后返退票张数]
into #b4
from #emp emp 
left join #hf hf on Emp.empname=hf.empname
left join #qf qf on Emp.empname=qf.empname
left join #fzj fzj on Emp.empname=fzj.empname
left join #hft hft on Emp.empname=hft.empname
left join #qft qft on Emp.empname=qft.empname
where Emp.team='差旅运营四组'

IF OBJECT_ID('tempdb.dbo.#b5') IS NOT NULL DROP TABLE #b5
select Emp.team as 小组,Emp.empname as 业务顾问,isnull(前返张数,0) as 直加前返张数,isnull(后返张数,0) as 直加后返张数
,isnull(前返退票张数,0) as 直加前返退票张数,isnull(后返退票张数,0) as 直加后返退票张数
,isnull(前返张数,0)+isnull(后返张数,0)-isnull(前返退票张数,0)-isnull(后返退票张数,0) as 直加计数,isnull(后返张数,0)-ISNULL(后返退票张数,0) as [后返张数-后返退票张数] 
into #b5
from #emp emp 
left join #hf hf on Emp.empname=hf.empname
left join #qf qf on Emp.empname=qf.empname
left join #fzj fzj on Emp.empname=fzj.empname
left join #hft hft on Emp.empname=hft.empname
left join #qft qft on Emp.empname=qft.empname
where Emp.team='差旅运营十组'

IF OBJECT_ID('tempdb.dbo.#c1') IS NOT NULL DROP TABLE #c1
select 小组,'' as t1,SUM(直加前返张数)t2,SUM(直加后返张数)t3,SUM(直加前返退票张数)t4,SUM(直加后返退票张数)t5,SUM(直加计数)t6,SUM([后返张数-后返退票张数])t7 
into #c1
from #b1
group by 小组
IF OBJECT_ID('tempdb.dbo.#c2') IS NOT NULL DROP TABLE #c2
select 小组,'' as t1,SUM(直加前返张数)t2,SUM(直加后返张数)t3,SUM(直加前返退票张数)t4,SUM(直加后返退票张数)t5,SUM(直加计数)t6,SUM([后返张数-后返退票张数])t7 
into #c2
from #b2
group by 小组
IF OBJECT_ID('tempdb.dbo.#c3') IS NOT NULL DROP TABLE #c3
select 小组,'' as t1,SUM(直加前返张数)t2,SUM(直加后返张数)t3,SUM(直加前返退票张数)t4,SUM(直加后返退票张数)t5,SUM(直加计数)t6,SUM([后返张数-后返退票张数])t7 
into #c3
from #b3
group by 小组
IF OBJECT_ID('tempdb.dbo.#c4') IS NOT NULL DROP TABLE #c4
select 小组,'' as t1,SUM(直加前返张数)t2,SUM(直加后返张数)t3,SUM(直加前返退票张数)t4,SUM(直加后返退票张数)t5,SUM(直加计数)t6,SUM([后返张数-后返退票张数])t7 
into #c4
from #b4
group by 小组
IF OBJECT_ID('tempdb.dbo.#c5') IS NOT NULL DROP TABLE #c5
select 小组,'' as t1,SUM(直加前返张数)t2,SUM(直加后返张数)t3,SUM(直加前返退票张数)t4,SUM(直加后返退票张数)t5,SUM(直加计数)t6,SUM([后返张数-后返退票张数])t7 
into #c5
from #b5
group by 小组



IF OBJECT_ID('tempdb.dbo.#b') IS NOT NULL DROP TABLE #b
select Emp.team as 小组,Emp.empname as 业务顾问,isnull(前返张数,0) as 直加前返张数,isnull(后返张数,0) as 直加后返张数
,isnull(前返退票张数,0) as 直加前返退票张数,isnull(后返退票张数,0) as 直加后返退票张数
,isnull(前返张数,0)+isnull(后返张数,0)-isnull(前返退票张数,0)-isnull(后返退票张数,0) as 直加计数,isnull(后返张数,0)-isnull(后返退票张数,0) as [后返张数-后返退票张数] 
into #b
from #emp emp 
left join #hf hf on Emp.empname=hf.empname
left join #qf qf on Emp.empname=qf.empname
left join #fzj fzj on Emp.empname=fzj.empname
left join #hft hft on Emp.empname=hft.empname
left join #qft qft on Emp.empname=qft.empname
where Emp.team in ('差旅运营一组','差旅运营二组','差旅运营三组','差旅运营四组','差旅运营十组')


IF OBJECT_ID('tempdb.dbo.#c') IS NOT NULL DROP TABLE #c
select ''as t,'' as t1,SUM(直加前返张数)t2,SUM(直加后返张数)t3,SUM(直加前返退票张数)t4,SUM(直加后返退票张数)t5,SUM(直加计数)t6,SUM([后返张数-后返退票张数])t7 
into #c
from #b

update #c1 set  小组='差旅运营一组合计'
update #c2 set  小组='差旅运营二组合计'
update #c3 set  小组='差旅运营三组合计'
update #c4 set  小组='差旅运营四组合计'
update #c5 set  小组='差旅运营十组合计'



--汇总统计
select * from #b1 
UNION ALL select * from #c1
UNION ALL select * from #b2
UNION ALL select * from #c2
UNION ALL select * from #b3
UNION ALL select * from #c3
UNION ALL select * from #b4
UNION ALL select * from #c4
UNION ALL select * from #b5
UNION ALL select * from #c5
UNION ALL select * from #c
UNION ALL
select * from #c1 
UNION ALL select * from #c2
UNION ALL select * from #c3
UNION ALL select * from #c4
UNION ALL select * from #c5


--航司统计
--后返航司
IF OBJECT_ID('tempdb.dbo.#hfhs') IS NOT NULL DROP TABLE #hfhs
select 航司,COUNT(*) as 出票张数
into #hfhs
from #emp emp
left join #a a on emp.empname=a.操作业务顾问
where ((航司='HO' and 舱位 in ('A','U','H','Q','V','W','S','T','Z','E')) OR
(航司='SC' AND 舱位 IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
(航司='RY' AND 舱位 IN ('M','L','K','N','Q','V','T','R','U')) OR
(航司='ZH' AND 舱位 IN ('M','U','H','Q','V','W','S','E')) OR
(航司='CZ' AND 舱位 IN ('V','E','L','A','U','H','M','B','C','Z')) OR
(航司='3U' AND 舱位 IN ('G','S','L','E','V','R','K','N'))
)
and 人工出票原因 like ('%直加%')
group by 航司


--前返航司
IF OBJECT_ID('tempdb.dbo.#qfhs') IS NOT NULL DROP TABLE #qfhs
select 航司,COUNT(*) as 出票张数
into #qfhs
from #emp emp
left join #a a on emp.empname=a.操作业务顾问
where ((航司='HU' AND 舱位 IN ('Q')) OR
(航司='KY' AND 舱位 IN ('D')) OR
(航司='JD' AND 舱位 IN ('W')) OR
(航司='UQ' AND 舱位 IN ('Q')) OR
(航司='GJ' AND 舱位 IN ('X')) OR
(航司='JR' AND 舱位 IN ('P')) OR
(航司='3U' AND 舱位 IN ('W')) or
(航司='GS' AND 舱位 IN ('Q'))
)
--and 人工出票原因 like ('%直加%')
group by 航司


--后返退票
IF OBJECT_ID('tempdb.dbo.#hfhst') IS NOT NULL DROP TABLE #hfhst
select 航司,COUNT(*) as 退票张数
into #hfhst
from #emp emp
left join #a2 a2 on emp.empname=a2.操作业务顾问
left join tbReti r on r.reno=a2.退票
where ((航司='HO' and 舱位 in ('A','U','H','Q','V','W','S','T','Z','E')) OR
(航司='SC' AND 舱位 IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
(航司='RY' AND 舱位 IN ('M','L','K','N','Q','V','T','R','U')) OR
(航司='ZH' AND 舱位 IN ('M','U','H','Q','V','W','S','E')) OR
(航司='CZ' AND 舱位 IN ('V','E','L','A','U','H','M','B','C','Z')) OR
(航司='3U' AND 舱位 IN ('G','S','L','E','V','R','K','N'))
)
and 人工出票原因 like ('%直加%')
and 退票<>''
and r.status2 not in (1,3,4)
and (r.ExamineDate>='2018-07-01' and ExamineDate<'2018-08-01')
group by 航司


--前返退票
IF OBJECT_ID('tempdb.dbo.#qfhst') IS NOT NULL DROP TABLE #qfhst
select 航司,COUNT(*) as 退票张数
into #qfhst
from #emp emp
left join #a2 a2 on emp.empname=a2.操作业务顾问
left join tbReti r on r.reno=a2.退票
where ((航司='HU' AND 舱位 IN ('Q')) OR
(航司='KY' AND 舱位 IN ('D')) OR
(航司='JD' AND 舱位 IN ('W')) OR
(航司='UQ' AND 舱位 IN ('Q')) OR
(航司='GJ' AND 舱位 IN ('X')) OR
(航司='JR' AND 舱位 IN ('P')) OR
(航司='3U' AND 舱位 IN ('W')) or
(航司='GS' AND 舱位 IN ('Q'))
)
--and 人工出票原因 like ('%直加%')
and 退票<>''
and r.status2 not in (1,3,4)
and (r.ExamineDate>='2018-07-01' and ExamineDate<'2018-08-01')
group by 航司


--航司
IF OBJECT_ID('tempdb.dbo.#h1') IS NOT NULL DROP TABLE #h1
select DISTINCT ride 
into #h1
from tbcash where ride in ('HO','SC','RY','ZH','CZ')
or (ride in ('3U') and nclass IN ('G','S','L','E','V','R','K','N'))
IF OBJECT_ID('tempdb.dbo.#h2') IS NOT NULL DROP TABLE #h2
select DISTINCT ride 
into #h2
from tbcash where ride in ('HU','KY','JD','UQ','GJ','JR','GS')
or (ride in ('3U') and nclass IN ('W'))

--航司汇总
select h1.ride as 后返航司,出票张数,退票张数 
from #h1 h1 
left join #hfhs hfhs on h1.ride=hfhs.航司
left join #hfhst hfhst on hfhst.航司=hfhs.航司

select h2.ride as 前返航司,出票张数,退票张数 
from #h2 h2 
left join #qfhs qfhs on h2.ride=qfhs.航司
left join #qfhst qfhst on qfhst.航司=qfhs.航司




--明细
select * from #a
where 销售单号 not in (select 销售单号
from  #a a 
where ((航司='HO' and 舱位 in ('A','U','H','Q','V','W','S','T','Z','E')) OR
(航司='SC' AND 舱位 IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
(航司='RY' AND 舱位 IN ('M','L','K','N','Q','V','T','R','U')) OR
(航司='ZH' AND 舱位 IN ('M','U','H','Q','V','W','S','E')) OR
(航司='CZ' AND 舱位 IN ('V','E','L','A','U','H','M','B','C','Z')) OR
(航司='3U' AND 舱位 IN ('G','S','L','E','V','R','K','N'))
)
and 人工出票原因 not like ('%直加%')
)
select a2.* from #a2 a2
inner join tbReti r on r.reno=a2.退票
where a2.退票<>'' and r.status2 not in (1,3,4)
and (r.ExamineDate>='2018-07-01' and r.ExamineDate<'2018-08-01')
and 人工出票原因 like ('%直加%')



