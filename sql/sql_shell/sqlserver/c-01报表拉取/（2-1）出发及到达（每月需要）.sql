select ride+flightno as 航班号,begdate as 起飞日期,SUBSTRING(route,1,CHARINDEX('-',route)-1) as 出发,REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) as 到达,tcode+ticketno as 票号,nclass as 舱位 
,t_source as 供应商来源
from tbcash
where ride='CZ'
and (datetime>='2017-09-16' and datetime<'2017-10-16')
and t_source in ('HSBSPETD')
and route like ('%-%')


--机场三字代码
SELECT sx,jccode,* FROM ehomsom..tbInfAirPortName
where country='中国'