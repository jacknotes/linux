
--����
select datetime as ��Ʊ����,c.coupno as ���۵���,tcode+ticketno as Ʊ��,begdate as ���ʱ��,ride as ��˾,nclass as ��λ,c.route as ����,quota1+quota2+quota3+quota4 as �����
,SpareTC as ����ҵ�����,c.totprice as ���ۼ�,c.totsprice as �����,profit-Mcost as ��������,cmpcode as ��λ���, TicketOperationRemark as �˹���Ʊԭ��
from homsomDB..Trv_DomesticTicketRecord t1
left join tbcash c on c.coupno=t1.RecordNumber
where 
TicketOperationRemark like ('%��ֵ%')
and (c.datetime>='2018-03-01' and c.datetime<'2018-04-01')

--����
UNION ALL 
select datetime as ��Ʊ����,c.coupno as ���۵���,tcode+ticketno as Ʊ��,begdate as ���ʱ��,ride as ��˾,nclass as ��λ,c.route as ����,quota1+quota2+quota3+quota4 as �����
,SpareTC as ����ҵ�����,c.totprice as ���ۼ�,c.totsprice as �����,profit-Mcost as ��������,cmpcode as ��λ��� ,'' as �˹���Ʊԭ��
from tbFiveCoupInfo fo 
left join tbcash c on c.coupno=fo.CoupNo
where comment like ('%��ֵ%')
and c.datetime>='2018-03-01' and c.datetime<'2018-04-01'


