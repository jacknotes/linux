select datetime as ��Ʊ����,begdate as ���ʱ��,coupno as ���۵���,tcode+ticketno as Ʊ��,t2.route as ����,nclass as ��λ,ride+flightno as �����,cmpcode as ��λ���,quota1 as �����,totprice as ���ۼ�,t2.profit-Mcost as ��������,t2.sales as ����ҵ�����,t2.SpareTC as ����ҵ�����,t2.reti as ��Ʊ���� 
from homsomDB..Trv_DomesticTicketRecord t1
left join tbcash t2 on t2.coupno=t1.RecordNumber
where TicketOperationRemark like ('%ֱ��%') and t2.t_source='HSBSPETD'
and (t2.datetime>='2017-09-01' and t2.datetime<'2017-10-13')