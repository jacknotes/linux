--佣金类型，销售单号，日期
select t1.coupno as 销售单号,t1.totprice as 销售价,t3.Name as 佣金类型,t1.datetime,f.OrderId 
from Topway..tbcash t1 
LEFT JOIN Topway..tbFiveCoupInfo f ON t1.coupno=f.CoupNo
LEFT JOIN homsomDB..Intl_BookingFares b ON f.OrderId=b.OrderId
left join homsomDB..Trv_IntlFlightNormalPolicies t3 on t3.ID=b.PolicyId
where reti='' and cmpcode='018734' and t1.datetime>='2018-08-03' and t1.datetime<'2018-12-31'
AND t1.inf=1 
ORDER BY t1.datetime 

--销量佣金类型
select sum(t1.totprice) as 销量,t3.Name as 佣金类型
from Topway..tbcash t1 
LEFT JOIN Topway..tbFiveCoupInfo f ON t1.coupno=f.CoupNo
LEFT JOIN homsomDB..Intl_BookingFares b ON f.OrderId=b.OrderId
left join homsomDB..Trv_IntlFlightNormalPolicies t3 on t3.ID=b.PolicyId
where reti='' and cmpcode='018734' and t1.datetime>='2018-08-03' and t1.datetime<'2018-12-31'
AND t1.inf=1
--ORDER BY t1.datetime 
group by t3.Name