IF OBJECT_ID('tempdb.dbo.#XL') IS NOT NULL DROP TABLE #XL
CREATE TABLE #XL(
	��˾ varchar(20),
	���� decimal(18,2),
	���� decimal(18,2),
	�������� decimal(18,2),
	�������� decimal(18,2),
	Y������ decimal(18,2),
	Y������ decimal(18,2)
)
insert into #XL(��˾,����,����)(
select ride,SUM(totprice) ,SUM(profit-Mcost)  
from Topway..tbcash c
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and tickettype='����Ʊ'
and inf=0
group by ride
)


insert into #XL(��˾,��������,��������)  (
select ride,SUM(totprice),SUM(profit-Mcost) 
from Topway..tbcash c
left join ehomsom..tbInfCabincode t on t.code2=c.ride and c.nclass=t.cabin
and t.begdate<=c.begdate and t.enddate>=c.begdate
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and (cabintype like'%�����%' or cabintype like'%ͷ�Ȳ�%')
and tickettype='����Ʊ'
and inf=0
group by ride
)

insert into #XL(��˾,Y������,Y������)  (
select ride,SUM(totprice),SUM(profit-Mcost) 
from Topway..tbcash c
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and tickettype='����Ʊ'
and c.nclass='Y'
and inf=0
group by ride
)

select ��˾,SUM(ISNULL(����,0)) ����, SUM(ISNULL(����,0)) ����,
SUM(ISNULL(��������,0)) ��������,--SUM(ISNULL(��������,0))/SUM(ISNULL(����,0)) ��������ռ��,
SUM(ISNULL(��������,0)) ��������,--SUM(ISNULL(��������,0))/SUM(ISNULL(����,0)) ��������ռ��,
SUM(ISNULL(Y������,0))  Y������,--SUM(ISNULL(Y������,0))/SUM(ISNULL(����,0)) Y������ռ��,
SUM(ISNULL(Y������,0))  Y������--,SUM(ISNULL(Y������,0))/SUM(ISNULL(����,0)) Y������ռ��
from #XL
WHERE ��˾<>''
group by ��˾
ORDER BY SUM(ISNULL(����,0)) DESC
