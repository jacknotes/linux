--ҹ���б�
IF OBJECT_ID('tempdb.dbo.#emp') IS NOT NULL DROP TABLE #emp
IF OBJECT_ID('tempdb.dbo.#gn') IS NOT NULL DROP TABLE #gn
IF OBJECT_ID('tempdb.dbo.#gj') IS NOT NULL DROP TABLE #gj

SELECT ROW_NUMBER()OVER(ORDER BY t2.depOrder,t1.idnumber) idx,empname
INTO #emp 
from emppwd t1 LEFT JOIN dbo.EmpSysSetting t2 ON t1.team=t2.dep AND t2.ntype=2 where t1.team = '������Ӫʮ��' 
order by t2.depOrder,t1.idnumber 

select SpareTC,count(*) as ����
into #gn
from tbcash where 
(datetime BETWEEN '2018-02-01 00:00:00' AND '2018-02-28 23:59:59') 
and SpareTC in (select empname from #emp)
and inf=0
group by SpareTC

select SpareTC,count(*) as ����
into #gj
from tbcash where 
(datetime BETWEEN '2018-02-01 00:00:00' AND '2018-02-28 23:59:59') 
and SpareTC in (select empname from #emp)
and inf=1
group by SpareTC

select Emp.empname,gn.����,gj.���� from #emp emp
inner join #gn gn on gn.spareTC=Emp.empname
inner join #gj gj on gj.spareTC=Emp.empname
order by idx