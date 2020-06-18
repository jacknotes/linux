
select t3.ride+t3.flightno as 航司,count(*) as 机票张数
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as 机票销量
from tbcash t3
left join tbreti t2 on t3.coupno=t2.coupno
where t3.datetime>='2018-12-01' and t3.datetime<'2019-01-01' and t3.ride+t3.flightno in('SC1168','SC4602','SC4664','SC4666','SC4606','SC3072','SC4864','SC4866','SC4950','SC4942','SC8715','SC1191') 
group by t3.ride+t3.flightno

select priceinfo,totprice,tax,* from Topway..tbcash where ride+flightno='SC4666' and  datetime>='2018-12-01' and datetime<'2019-01-01'