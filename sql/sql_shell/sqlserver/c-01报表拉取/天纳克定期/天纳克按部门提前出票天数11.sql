
--���ò�
select Department,SUM(price) as ����,COUNT(*) as ����,AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE price/priceinfo END) AS zkpercent,AVG(DATEDIFF(day,datetime,t1.begdate)) as ƽ����Ʊ����
from V_TicketInfo t1
left join ehomsom..tbInfCabincode t2 on t2.code2=t1.ride AND t2.cabin=t1.nclass  AND t2.begdate <= t1.datetime AND t2.enddate>=t1.datetime
where cmpcode in ('016448')
and datetime>='2018-01-01' and datetime<'2018-12-31'
AND t1.inf ='0'
and t1.reti=''
and t1.CostCenter='am'
and t1.tickettype='����Ʊ'
and t2.cabintype LIKE'%���ò�%'
group by Department
order by ���� desc

--����
select Department,SUM(price) as ����,COUNT(*) as ����,AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE price/priceinfo END) AS zkpercent,AVG(DATEDIFF(day,datetime,t1.begdate)) as ƽ����Ʊ����
from V_TicketInfo t1
left join ehomsom..tbInfCabincode t2 on t2.code2=t1.ride AND t2.cabin=t1.nclass  AND t2.begdate <= t1.datetime AND t2.enddate>=t1.datetime
where cmpcode in ('016448')
and datetime>='2018-07-01' and datetime<'2019-01-01'
AND t1.inf ='0'
and t1.reti=''
and t1.tickettype='����Ʊ'
and t1.CostCenter='am'
and (t2.cabintype LIKE'%�����%' or t2.cabintype LIKE'%ͷ�Ȳ�%')
group by Department
order by ���� desc

--����Ա
select pasname,SUM(price) as ����,COUNT(*) as ����,SUM(price)/COUNT(*) as ƽ��Ʊ��,AVG(DATEDIFF(day,datetime,t1.begdate)) as ƽ����Ʊ����,AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS zkpercent

from V_TicketInfo t1
left join ehomsom..tbInfCabincode t2 on t2.code2=t1.ride AND t2.cabin=t1.nclass  AND t2.begdate <= t1.datetime AND t2.enddate>=t1.datetime
where cmpcode in ('016448')
and datetime>='2018-07-01' and datetime<'2019-01-01'
AND t1.inf ='0'
and t1.reti=''
and t1.tickettype='����Ʊ'
--and pasname='Ԭ����CHD'
--and t2.cabintype<>'���ò�'
group by pasname
