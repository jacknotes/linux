select r.reno as ��Ʊ����,ExamineDate as ���ʱ��,r.profit as ����,c.sales as ����ҵ�����,c.SpareTC as ����ҵ�����
,(case when sales=SpareTC then r.profit*1 when sales<>SpareTC then r.profit*0.5 else '' end)
from tbreti r
left join Emppwd p on p.empname=r.opername
left join tbcash c on c.reti=r.reno
where  r.totprice=0 
and (r.ExamineDate >='2017-10-01')
and p.dep in ('��Ʊ��Ʒ��')
and status2 not in (1,3,4)




