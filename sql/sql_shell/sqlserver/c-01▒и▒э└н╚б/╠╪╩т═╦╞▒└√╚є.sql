select r.reno as 退票单号,ExamineDate as 审核时间,r.profit as 利润,c.sales as 所属业务顾问,c.SpareTC as 操作业务顾问
,(case when sales=SpareTC then r.profit*1 when sales<>SpareTC then r.profit*0.5 else '' end)
from tbreti r
left join Emppwd p on p.empname=r.opername
left join tbcash c on c.reti=r.reno
where  r.totprice=0 
and (r.ExamineDate >='2017-10-01')
and p.dep in ('机票产品部')
and status2 not in (1,3,4)




