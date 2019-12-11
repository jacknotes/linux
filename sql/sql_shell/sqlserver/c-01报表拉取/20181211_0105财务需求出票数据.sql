select c.cmpcode as ��λ���,m.cmpname as ��λ����,c.datetime as ��Ʊ����,c.coupno as ���۵���
,case c.inf when 1 then '����' when 0 then '����' else '' end as ����
,c.ride+c.flightno as �����,begdate as ���ʱ��,c.tcode+c.ticketno as Ʊ��,c.pasname as �˻���,c.route as ����,c.totprice as ���ۼ�
from tbcash c
left join tbCompanyM m on m.cmpid=c.cmpcode
where c.cmpcode in 
('020359','017730','020278','017745','018591','019394','019471','019653','018661','020297','019550','015918','020362','019588','017290','016560','018781','018265','019259','017205','019331','017739','018156','016773','020027')
and datetime>='2018-06-01' and datetime<'2018-12-01'
order by c.cmpcode 