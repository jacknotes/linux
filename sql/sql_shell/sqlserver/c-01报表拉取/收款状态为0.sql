select datetime as 出票日期,coupno as 销售单号,totprice as 销售价,sales as 所属业务顾问
from Topway..tbcash where pform='月结' and status=0  --and trvYsId<>'0' or ConventionYsId<>'0' 
and  datetime>'2016-01-01' and datetime<'2019-01-01'
order by datetime