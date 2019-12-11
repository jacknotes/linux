select c.cmpcode as ��λ���,m.cmpname as ��λ����,datetime as ��Ʊ����,coupno as ���۵���
,case INF when 1 then '����' when 0 then '����' else '' end as ����
,ride+flightno as �����,begdate as ���ʱ��,tcode+ticketno as Ʊ��,pasname as �˻���,route as ����,totprice as ���ۼ�
from tbcash c
left join tbCompanyM m on c.cmpcode=m.cmpid
where cmpcode in 
('019941','019959','019807','019792','019787','019784','019944','016756','018326','019983','019805','019802','018886','019886','019508','016448','018202','016511','017275','016712','017012','020016','016602','017996','015828','016400','019845','018038','018463','017020','018021','018362','000370','017454','017408')
and datetime>='2018-02-01' and datetime<'2018-08-01'


select sum(totprice) as ���ۼ�
from tbcash c
left join tbCompanyM m on c.cmpcode=m.cmpid
where cmpcode in 
('000370')
and datetime>='2018-02-01' and datetime<'2018-08-01'