
select t1.pasname as �˻���,datetime as ��Ʊ����,begdate as ���ʱ��,t1.route as ����,ride+flightno as �����,recno as PNR,t5.Arriving as ����ʱ��
from tbcash t1
left join homsomDB..Trv_DomesticTicketRecord t2 on t2.RecordNumber=t1.coupno
left join homsomDB..Trv_PnrInfos t3 on t3.ID=t2.PnrInfoID
left join homsomDB..Trv_ItktBookingSegments_PnrInfos t4 on t4.PnrInfoID=t3.ID
left join homsomDB..Trv_ItktBookingSegs t5 on t5.ID=t4.ItktBookingSegID
where t1.cmpcode='020316'
and t1.datetime>='2018-06-01'
and inf=0

UNION ALL
select t1.pasname as �˻���,datetime as ��Ʊ����,begdate as ���ʱ��,t1.route as ����,ride+flightno as �����,recno as PNR,EndDate as ����ʱ��
from tbcash t1
where t1.cmpcode='020316'
and t1.datetime>='2018-06-01'
and inf=1
