
select datetime as ��Ʊ����,begdate  as �������,coupno as ���۵���,pasname as �˿�����,route as ��·,flightno as �����,priceinfo as ȫ��,
'' as �ۿ���,price as ���۵���,tax as ˰��,fuprice as �����,totprice as ���ۼ�,reti as ��Ʊ����,CostCenter as �ɱ�����,ProjectNo as ��Ŀ���,
m.custname as Ԥ����
from Topway ..tbcash c
left join Topway ..tbCusholderM m on m.custid=c.custid
 where cmpcode='020237' and datetime >='2018-11-21' and datetime <'2018-12-20'
order by datetime 


select custname as Ԥ����,custid

 from Topway ..tbCusholderM m
 
