
select datetime as 出票日期,begdate  as 起飞日期,coupno as 销售单号,pasname as 乘客姓名,route as 线路,flightno as 航班号,priceinfo as 全价,
'' as 折扣率,price as 销售单价,tax as 税收,fuprice as 服务费,totprice as 销售价,reti as 退票单号,CostCenter as 成本中心,ProjectNo as 项目编号,
m.custname as 预订人
from Topway ..tbcash c
left join Topway ..tbCusholderM m on m.custid=c.custid
 where cmpcode='020237' and datetime >='2018-11-21' and datetime <'2018-12-20'
order by datetime 


select custname as 预订人,custid

 from Topway ..tbCusholderM m
 
