select ride+flightno as �����,begdate as �������,SUBSTRING(route,1,CHARINDEX('-',route)-1) as ����,REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) as ����,tcode+ticketno as Ʊ��,nclass as ��λ 
,t_source as ��Ӧ����Դ
from tbcash
where ride='CZ'
and (datetime>='2017-09-16' and datetime<'2017-10-16')
and t_source in ('HSBSPETD')
and route like ('%-%')


--�������ִ���
SELECT sx,jccode,* FROM ehomsom..tbInfAirPortName
where country='�й�'