

IF OBJECT_ID('tempdb.dbo.#emp') IS NOT NULL DROP TABLE #emp
SELECT ROW_NUMBER()OVER(ORDER BY t2.depOrder,t1.idnumber) idx,empname,team
INTO #emp 
from emppwd t1 LEFT JOIN dbo.EmpSysSetting t2 ON t1.team=t2.dep AND t2.ntype=2 where t1.dep = '��Ӫ��' order by t2.depOrder,t1.idnumber 



IF OBJECT_ID('tempdb.dbo.#a') IS NOT NULL DROP TABLE #a
select team as С��
,SpareTC as ����ҵ�����,datetime as ��Ʊ����,coupno as ���۵���,tcode+ticketno as Ʊ��,begdate as ���ʱ��,ride as ��˾,nclass as ��λ,TicketOperationRemark as �˹���Ʊԭ��,cmpcode as ��λ���,c.route as ����,quota1+quota2+quota3+quota4 as �����
,totprice as ���ۼ�,totsprice as �����,profit-Mcost as ��������,reti as ��Ʊ
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
select team as С��
,SpareTC as ����ҵ�����,datetime as ��Ʊ����,coupno as ���۵���,tcode+ticketno as Ʊ��,begdate as ���ʱ��,ride as ��˾,nclass as ��λ,TicketOperationRemark as �˹���Ʊԭ��,cmpcode as ��λ���,c.route as ����,quota1+quota2+quota3+quota4 as �����
,totprice as ���ۼ�,totsprice as �����,profit-Mcost as ��������,reti as ��Ʊ
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



--�󷵺�˾
IF OBJECT_ID('tempdb.dbo.#hf') IS NOT NULL DROP TABLE #hf
select team,empname,COUNT(*) as ������
into #hf
from #emp emp
left join #a a on emp.empname=a.����ҵ�����
where ((��˾='HO' and ��λ in ('A','U','H','Q','V','W','S','T','Z','E')) OR
(��˾='SC' AND ��λ IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
(��˾='RY' AND ��λ IN ('M','L','K','N','Q','V','T','R','U')) OR
(��˾='ZH' AND ��λ IN ('M','U','H','Q','V','W','S','E')) OR
(��˾='CZ' AND ��λ IN ('V','E','L','A','U','H','M','B','C','Z')) OR
(��˾='3U' AND ��λ IN ('G','S','L','E','V','R','K','N'))
)
and �˹���Ʊԭ�� like ('%ֱ��%')
group by team,empname,idx
order by idx

--ǰ����˾
IF OBJECT_ID('tempdb.dbo.#qf') IS NOT NULL DROP TABLE #qf
select team,empname,COUNT(*) as ǰ������
into #qf
from #emp emp
left join #a a on emp.empname=a.����ҵ�����
where ((��˾='HU' AND ��λ IN ('Q')) OR
(��˾='KY' AND ��λ IN ('D')) OR
(��˾='JD' AND ��λ IN ('W')) OR
(��˾='UQ' AND ��λ IN ('Q')) OR
(��˾='GJ' AND ��λ IN ('X')) OR
(��˾='JR' AND ��λ IN ('P')) OR
(��˾='3U' AND ��λ IN ('W')) OR
(��˾='GS' AND ��λ IN ('Q'))
)
--and �˹���Ʊԭ�� like ('%ֱ��%')
group by team,empname,idx
order by idx

--��ֱ��
IF OBJECT_ID('tempdb.dbo.#fzj') IS NOT NULL DROP TABLE #fzj
select team,empname,COUNT(*) as ��ֱ������
into #fzj
from #emp emp
left join #a a on emp.empname=a.����ҵ�����
where ((��˾='HO' and ��λ in ('A','U','H','Q','V','W','S','T','Z','E')) OR
(��˾='SC' AND ��λ IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
(��˾='RY' AND ��λ IN ('M','L','K','N','Q','V','T','R','U')) OR
(��˾='ZH' AND ��λ IN ('M','U','H','Q','V','W','S','E')) OR
(��˾='CZ' AND ��λ IN ('V','E','L','A','U','H','M','B','C','Z')) OR
(��˾='3U' AND ��λ IN ('G','S','L','E','V','R','K','N'))
)
and �˹���Ʊԭ�� not like ('%ֱ��%')
group by team,empname,idx
order by idx




--����Ʊ
IF OBJECT_ID('tempdb.dbo.#hft') IS NOT NULL DROP TABLE #hft
select team,empname,COUNT(*) as ����Ʊ����
into #hft
from #emp emp
left join #a2 a2 on emp.empname=a2.����ҵ�����
left join tbReti r on r.reno=a2.��Ʊ
where ((��˾='HO' and ��λ in ('A','U','H','Q','V','W','S','T','Z','E')) OR
(��˾='SC' AND ��λ IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
(��˾='RY' AND ��λ IN ('M','L','K','N','Q','V','T','R','U')) OR
(��˾='ZH' AND ��λ IN ('M','U','H','Q','V','W','S','E')) OR
(��˾='CZ' AND ��λ IN ('V','E','L','A','U','H','M','B','C','Z')) OR
(��˾='3U' AND ��λ IN ('G','S','L','E','V','R','K','N'))
)
and �˹���Ʊԭ�� like ('%ֱ��%')
and ��Ʊ<>''
and r.status2 not in (1,3,4)
and (r.ExamineDate>='2018-07-01' and ExamineDate<'2018-08-01')
group by team,empname,idx
order by idx

--ǰ����Ʊ
IF OBJECT_ID('tempdb.dbo.#qft') IS NOT NULL DROP TABLE #qft
select team,empname,COUNT(*) as ǰ����Ʊ����
into #qft
from #emp emp
left join #a2 a2 on emp.empname=a2.����ҵ�����
left join tbReti r on r.reno=a2.��Ʊ
where ((��˾='HU' AND ��λ IN ('Q')) OR
(��˾='KY' AND ��λ IN ('D')) OR
(��˾='JD' AND ��λ IN ('W')) OR
(��˾='UQ' AND ��λ IN ('Q')) OR
(��˾='GJ' AND ��λ IN ('X')) OR
(��˾='JR' AND ��λ IN ('P')) OR
(��˾='3U' AND ��λ IN ('W')) or
(��˾='GS' AND ��λ IN ('Q'))
)
--and �˹���Ʊԭ�� like ('%ֱ��%')
and ��Ʊ<>''
and r.status2 not in (1,3,4)
and (r.ExamineDate>='2018-07-01' and ExamineDate<'2018-08-01')
group by team,empname,idx
order by idx


IF OBJECT_ID('tempdb.dbo.#b1') IS NOT NULL DROP TABLE #b1
select Emp.team as С��,Emp.empname as ҵ�����,isnull(ǰ������,0) as ֱ��ǰ������,isnull(������,0) as ֱ�Ӻ�����
,isnull(ǰ����Ʊ����,0) as ֱ��ǰ����Ʊ����,isnull(����Ʊ����,0) as ֱ�Ӻ���Ʊ����
,isnull(ǰ������,0)+isnull(������,0)-isnull(ǰ����Ʊ����,0)-isnull(����Ʊ����,0) as ֱ�Ӽ���,isnull(������,0)-ISNULL(����Ʊ����,0) as [������-����Ʊ����] 
into #b1
from #emp emp 
left join #hf hf on Emp.empname=hf.empname
left join #qf qf on Emp.empname=qf.empname
left join #fzj fzj on Emp.empname=fzj.empname
left join #hft hft on Emp.empname=hft.empname
left join #qft qft on Emp.empname=qft.empname
where Emp.team='������Ӫһ��'




IF OBJECT_ID('tempdb.dbo.#b2') IS NOT NULL DROP TABLE #b2
select Emp.team as С��,Emp.empname as ҵ�����,isnull(ǰ������,0) as ֱ��ǰ������,isnull(������,0) as ֱ�Ӻ�����
,isnull(ǰ����Ʊ����,0) as ֱ��ǰ����Ʊ����,isnull(����Ʊ����,0) as ֱ�Ӻ���Ʊ����
,isnull(ǰ������,0)+isnull(������,0)-isnull(ǰ����Ʊ����,0)-isnull(����Ʊ����,0) as ֱ�Ӽ���,isnull(������,0)-ISNULL(����Ʊ����,0) as [������-����Ʊ����] 
into #b2
from #emp emp 
left join #hf hf on Emp.empname=hf.empname
left join #qf qf on Emp.empname=qf.empname
left join #fzj fzj on Emp.empname=fzj.empname
left join #hft hft on Emp.empname=hft.empname
left join #qft qft on Emp.empname=qft.empname
where Emp.team='������Ӫ����'

IF OBJECT_ID('tempdb.dbo.#b3') IS NOT NULL DROP TABLE #b3
select Emp.team as С��,Emp.empname as ҵ�����,isnull(ǰ������,0) as ֱ��ǰ������,isnull(������,0) as ֱ�Ӻ�����
,isnull(ǰ����Ʊ����,0) as ֱ��ǰ����Ʊ����,isnull(����Ʊ����,0) as ֱ�Ӻ���Ʊ����
,isnull(ǰ������,0)+isnull(������,0)-isnull(ǰ����Ʊ����,0)-isnull(����Ʊ����,0) as ֱ�Ӽ���,isnull(������,0)-ISNULL(����Ʊ����,0) as [������-����Ʊ����] 
into #b3
from #emp emp 
left join #hf hf on Emp.empname=hf.empname
left join #qf qf on Emp.empname=qf.empname
left join #fzj fzj on Emp.empname=fzj.empname
left join #hft hft on Emp.empname=hft.empname
left join #qft qft on Emp.empname=qft.empname
where Emp.team='������Ӫ����'

IF OBJECT_ID('tempdb.dbo.#b4') IS NOT NULL DROP TABLE #b4
select Emp.team as С��,Emp.empname as ҵ�����,isnull(ǰ������,0) as ֱ��ǰ������,isnull(������,0) as ֱ�Ӻ�����
,isnull(ǰ����Ʊ����,0) as ֱ��ǰ����Ʊ����,isnull(����Ʊ����,0) as ֱ�Ӻ���Ʊ����
,isnull(ǰ������,0)+isnull(������,0)-isnull(ǰ����Ʊ����,0)-isnull(����Ʊ����,0) as ֱ�Ӽ���,isnull(������,0)-ISNULL(����Ʊ����,0) as [������-����Ʊ����]
into #b4
from #emp emp 
left join #hf hf on Emp.empname=hf.empname
left join #qf qf on Emp.empname=qf.empname
left join #fzj fzj on Emp.empname=fzj.empname
left join #hft hft on Emp.empname=hft.empname
left join #qft qft on Emp.empname=qft.empname
where Emp.team='������Ӫ����'

IF OBJECT_ID('tempdb.dbo.#b5') IS NOT NULL DROP TABLE #b5
select Emp.team as С��,Emp.empname as ҵ�����,isnull(ǰ������,0) as ֱ��ǰ������,isnull(������,0) as ֱ�Ӻ�����
,isnull(ǰ����Ʊ����,0) as ֱ��ǰ����Ʊ����,isnull(����Ʊ����,0) as ֱ�Ӻ���Ʊ����
,isnull(ǰ������,0)+isnull(������,0)-isnull(ǰ����Ʊ����,0)-isnull(����Ʊ����,0) as ֱ�Ӽ���,isnull(������,0)-ISNULL(����Ʊ����,0) as [������-����Ʊ����] 
into #b5
from #emp emp 
left join #hf hf on Emp.empname=hf.empname
left join #qf qf on Emp.empname=qf.empname
left join #fzj fzj on Emp.empname=fzj.empname
left join #hft hft on Emp.empname=hft.empname
left join #qft qft on Emp.empname=qft.empname
where Emp.team='������Ӫʮ��'

IF OBJECT_ID('tempdb.dbo.#c1') IS NOT NULL DROP TABLE #c1
select С��,'' as t1,SUM(ֱ��ǰ������)t2,SUM(ֱ�Ӻ�����)t3,SUM(ֱ��ǰ����Ʊ����)t4,SUM(ֱ�Ӻ���Ʊ����)t5,SUM(ֱ�Ӽ���)t6,SUM([������-����Ʊ����])t7 
into #c1
from #b1
group by С��
IF OBJECT_ID('tempdb.dbo.#c2') IS NOT NULL DROP TABLE #c2
select С��,'' as t1,SUM(ֱ��ǰ������)t2,SUM(ֱ�Ӻ�����)t3,SUM(ֱ��ǰ����Ʊ����)t4,SUM(ֱ�Ӻ���Ʊ����)t5,SUM(ֱ�Ӽ���)t6,SUM([������-����Ʊ����])t7 
into #c2
from #b2
group by С��
IF OBJECT_ID('tempdb.dbo.#c3') IS NOT NULL DROP TABLE #c3
select С��,'' as t1,SUM(ֱ��ǰ������)t2,SUM(ֱ�Ӻ�����)t3,SUM(ֱ��ǰ����Ʊ����)t4,SUM(ֱ�Ӻ���Ʊ����)t5,SUM(ֱ�Ӽ���)t6,SUM([������-����Ʊ����])t7 
into #c3
from #b3
group by С��
IF OBJECT_ID('tempdb.dbo.#c4') IS NOT NULL DROP TABLE #c4
select С��,'' as t1,SUM(ֱ��ǰ������)t2,SUM(ֱ�Ӻ�����)t3,SUM(ֱ��ǰ����Ʊ����)t4,SUM(ֱ�Ӻ���Ʊ����)t5,SUM(ֱ�Ӽ���)t6,SUM([������-����Ʊ����])t7 
into #c4
from #b4
group by С��
IF OBJECT_ID('tempdb.dbo.#c5') IS NOT NULL DROP TABLE #c5
select С��,'' as t1,SUM(ֱ��ǰ������)t2,SUM(ֱ�Ӻ�����)t3,SUM(ֱ��ǰ����Ʊ����)t4,SUM(ֱ�Ӻ���Ʊ����)t5,SUM(ֱ�Ӽ���)t6,SUM([������-����Ʊ����])t7 
into #c5
from #b5
group by С��



IF OBJECT_ID('tempdb.dbo.#b') IS NOT NULL DROP TABLE #b
select Emp.team as С��,Emp.empname as ҵ�����,isnull(ǰ������,0) as ֱ��ǰ������,isnull(������,0) as ֱ�Ӻ�����
,isnull(ǰ����Ʊ����,0) as ֱ��ǰ����Ʊ����,isnull(����Ʊ����,0) as ֱ�Ӻ���Ʊ����
,isnull(ǰ������,0)+isnull(������,0)-isnull(ǰ����Ʊ����,0)-isnull(����Ʊ����,0) as ֱ�Ӽ���,isnull(������,0)-isnull(����Ʊ����,0) as [������-����Ʊ����] 
into #b
from #emp emp 
left join #hf hf on Emp.empname=hf.empname
left join #qf qf on Emp.empname=qf.empname
left join #fzj fzj on Emp.empname=fzj.empname
left join #hft hft on Emp.empname=hft.empname
left join #qft qft on Emp.empname=qft.empname
where Emp.team in ('������Ӫһ��','������Ӫ����','������Ӫ����','������Ӫ����','������Ӫʮ��')


IF OBJECT_ID('tempdb.dbo.#c') IS NOT NULL DROP TABLE #c
select ''as t,'' as t1,SUM(ֱ��ǰ������)t2,SUM(ֱ�Ӻ�����)t3,SUM(ֱ��ǰ����Ʊ����)t4,SUM(ֱ�Ӻ���Ʊ����)t5,SUM(ֱ�Ӽ���)t6,SUM([������-����Ʊ����])t7 
into #c
from #b

update #c1 set  С��='������Ӫһ��ϼ�'
update #c2 set  С��='������Ӫ����ϼ�'
update #c3 set  С��='������Ӫ����ϼ�'
update #c4 set  С��='������Ӫ����ϼ�'
update #c5 set  С��='������Ӫʮ��ϼ�'



--����ͳ��
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


--��˾ͳ��
--�󷵺�˾
IF OBJECT_ID('tempdb.dbo.#hfhs') IS NOT NULL DROP TABLE #hfhs
select ��˾,COUNT(*) as ��Ʊ����
into #hfhs
from #emp emp
left join #a a on emp.empname=a.����ҵ�����
where ((��˾='HO' and ��λ in ('A','U','H','Q','V','W','S','T','Z','E')) OR
(��˾='SC' AND ��λ IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
(��˾='RY' AND ��λ IN ('M','L','K','N','Q','V','T','R','U')) OR
(��˾='ZH' AND ��λ IN ('M','U','H','Q','V','W','S','E')) OR
(��˾='CZ' AND ��λ IN ('V','E','L','A','U','H','M','B','C','Z')) OR
(��˾='3U' AND ��λ IN ('G','S','L','E','V','R','K','N'))
)
and �˹���Ʊԭ�� like ('%ֱ��%')
group by ��˾


--ǰ����˾
IF OBJECT_ID('tempdb.dbo.#qfhs') IS NOT NULL DROP TABLE #qfhs
select ��˾,COUNT(*) as ��Ʊ����
into #qfhs
from #emp emp
left join #a a on emp.empname=a.����ҵ�����
where ((��˾='HU' AND ��λ IN ('Q')) OR
(��˾='KY' AND ��λ IN ('D')) OR
(��˾='JD' AND ��λ IN ('W')) OR
(��˾='UQ' AND ��λ IN ('Q')) OR
(��˾='GJ' AND ��λ IN ('X')) OR
(��˾='JR' AND ��λ IN ('P')) OR
(��˾='3U' AND ��λ IN ('W')) or
(��˾='GS' AND ��λ IN ('Q'))
)
--and �˹���Ʊԭ�� like ('%ֱ��%')
group by ��˾


--����Ʊ
IF OBJECT_ID('tempdb.dbo.#hfhst') IS NOT NULL DROP TABLE #hfhst
select ��˾,COUNT(*) as ��Ʊ����
into #hfhst
from #emp emp
left join #a2 a2 on emp.empname=a2.����ҵ�����
left join tbReti r on r.reno=a2.��Ʊ
where ((��˾='HO' and ��λ in ('A','U','H','Q','V','W','S','T','Z','E')) OR
(��˾='SC' AND ��λ IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
(��˾='RY' AND ��λ IN ('M','L','K','N','Q','V','T','R','U')) OR
(��˾='ZH' AND ��λ IN ('M','U','H','Q','V','W','S','E')) OR
(��˾='CZ' AND ��λ IN ('V','E','L','A','U','H','M','B','C','Z')) OR
(��˾='3U' AND ��λ IN ('G','S','L','E','V','R','K','N'))
)
and �˹���Ʊԭ�� like ('%ֱ��%')
and ��Ʊ<>''
and r.status2 not in (1,3,4)
and (r.ExamineDate>='2018-07-01' and ExamineDate<'2018-08-01')
group by ��˾


--ǰ����Ʊ
IF OBJECT_ID('tempdb.dbo.#qfhst') IS NOT NULL DROP TABLE #qfhst
select ��˾,COUNT(*) as ��Ʊ����
into #qfhst
from #emp emp
left join #a2 a2 on emp.empname=a2.����ҵ�����
left join tbReti r on r.reno=a2.��Ʊ
where ((��˾='HU' AND ��λ IN ('Q')) OR
(��˾='KY' AND ��λ IN ('D')) OR
(��˾='JD' AND ��λ IN ('W')) OR
(��˾='UQ' AND ��λ IN ('Q')) OR
(��˾='GJ' AND ��λ IN ('X')) OR
(��˾='JR' AND ��λ IN ('P')) OR
(��˾='3U' AND ��λ IN ('W')) or
(��˾='GS' AND ��λ IN ('Q'))
)
--and �˹���Ʊԭ�� like ('%ֱ��%')
and ��Ʊ<>''
and r.status2 not in (1,3,4)
and (r.ExamineDate>='2018-07-01' and ExamineDate<'2018-08-01')
group by ��˾


--��˾
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

--��˾����
select h1.ride as �󷵺�˾,��Ʊ����,��Ʊ���� 
from #h1 h1 
left join #hfhs hfhs on h1.ride=hfhs.��˾
left join #hfhst hfhst on hfhst.��˾=hfhs.��˾

select h2.ride as ǰ����˾,��Ʊ����,��Ʊ���� 
from #h2 h2 
left join #qfhs qfhs on h2.ride=qfhs.��˾
left join #qfhst qfhst on qfhst.��˾=qfhs.��˾




--��ϸ
select * from #a
where ���۵��� not in (select ���۵���
from  #a a 
where ((��˾='HO' and ��λ in ('A','U','H','Q','V','W','S','T','Z','E')) OR
(��˾='SC' AND ��λ IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
(��˾='RY' AND ��λ IN ('M','L','K','N','Q','V','T','R','U')) OR
(��˾='ZH' AND ��λ IN ('M','U','H','Q','V','W','S','E')) OR
(��˾='CZ' AND ��λ IN ('V','E','L','A','U','H','M','B','C','Z')) OR
(��˾='3U' AND ��λ IN ('G','S','L','E','V','R','K','N'))
)
and �˹���Ʊԭ�� not like ('%ֱ��%')
)
select a2.* from #a2 a2
inner join tbReti r on r.reno=a2.��Ʊ
where a2.��Ʊ<>'' and r.status2 not in (1,3,4)
and (r.ExamineDate>='2018-07-01' and r.ExamineDate<'2018-08-01')
and �˹���Ʊԭ�� like ('%ֱ��%')



