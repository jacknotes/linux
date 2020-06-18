
--经济舱
select Department,SUM(price) as 销量,COUNT(*) as 张数,AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE price/priceinfo END) AS zkpercent,AVG(DATEDIFF(day,datetime,t1.begdate)) as 平均出票天数
from V_TicketInfo t1
left join ehomsom..tbInfCabincode t2 on t2.code2=t1.ride AND t2.cabin=t1.nclass  AND t2.begdate <= t1.datetime AND t2.enddate>=t1.datetime
where cmpcode in ('016448')
and datetime>='2018-01-01' and datetime<'2018-12-31'
AND t1.inf ='0'
and t1.reti=''
and t1.CostCenter='am'
and t1.tickettype='电子票'
and t2.cabintype LIKE'%经济舱%'
group by Department
order by 销量 desc

--两舱
select Department,SUM(price) as 销量,COUNT(*) as 张数,AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE price/priceinfo END) AS zkpercent,AVG(DATEDIFF(day,datetime,t1.begdate)) as 平均出票天数
from V_TicketInfo t1
left join ehomsom..tbInfCabincode t2 on t2.code2=t1.ride AND t2.cabin=t1.nclass  AND t2.begdate <= t1.datetime AND t2.enddate>=t1.datetime
where cmpcode in ('016448')
and datetime>='2018-07-01' and datetime<'2019-01-01'
AND t1.inf ='0'
and t1.reti=''
and t1.tickettype='电子票'
and t1.CostCenter='am'
and (t2.cabintype LIKE'%商务舱%' or t2.cabintype LIKE'%头等舱%')
group by Department
order by 销量 desc

--按人员
select pasname,SUM(price) as 销量,COUNT(*) as 张数,SUM(price)/COUNT(*) as 平均票价,AVG(DATEDIFF(day,datetime,t1.begdate)) as 平均出票天数,AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS zkpercent

from V_TicketInfo t1
left join ehomsom..tbInfCabincode t2 on t2.code2=t1.ride AND t2.cabin=t1.nclass  AND t2.begdate <= t1.datetime AND t2.enddate>=t1.datetime
where cmpcode in ('016448')
and datetime>='2018-07-01' and datetime<'2019-01-01'
AND t1.inf ='0'
and t1.reti=''
and t1.tickettype='电子票'
--and pasname='袁楚渝CHD'
--and t2.cabintype<>'经济舱'
group by pasname
