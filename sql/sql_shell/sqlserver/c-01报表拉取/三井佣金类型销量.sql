--Ӷ�����ͣ����۵��ţ�����
select t1.coupno as ���۵���,t1.totprice as ���ۼ�,t3.Name as Ӷ������,t1.datetime,f.OrderId 
from Topway..tbcash t1 
LEFT JOIN Topway..tbFiveCoupInfo f ON t1.coupno=f.CoupNo
LEFT JOIN homsomDB..Intl_BookingFares b ON f.OrderId=b.OrderId
left join homsomDB..Trv_IntlFlightNormalPolicies t3 on t3.ID=b.PolicyId
where reti='' and cmpcode='018734' and t1.datetime>='2018-08-03' and t1.datetime<'2018-12-31'
AND t1.inf=1 
ORDER BY t1.datetime 

--����Ӷ������
select sum(t1.totprice) as ����,t3.Name as Ӷ������
from Topway..tbcash t1 
LEFT JOIN Topway..tbFiveCoupInfo f ON t1.coupno=f.CoupNo
LEFT JOIN homsomDB..Intl_BookingFares b ON f.OrderId=b.OrderId
left join homsomDB..Trv_IntlFlightNormalPolicies t3 on t3.ID=b.PolicyId
where reti='' and cmpcode='018734' and t1.datetime>='2018-08-03' and t1.datetime<'2018-12-31'
AND t1.inf=1
--ORDER BY t1.datetime 
group by t3.Name