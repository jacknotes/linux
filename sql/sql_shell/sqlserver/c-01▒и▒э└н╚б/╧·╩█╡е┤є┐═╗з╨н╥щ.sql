/*
select * from homsomDB..Trv_FlightTripartitePolicies
select top 100 RebateStr,* from homsomDB..Trv_ItktBookingSegs

���������ڻ�Ҫһ�����ݣ�
����2018.7--12�� ����ʹ�ô�ͻ�Э������ռ��    %�����ƽ�Լ      Ԫ
����������⣺����ռ��    %�����ƽ�Լ      Ԫ
*/
select RebateStr,SUM(price) ����,COUNT(c.id) ���� 
into #ccc
from Topway..tbcash C
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos pn on pn.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ItktBookingID=pn.ItktBookingID and c.ride+C.flightno=it.Flight
where
-- datetime>='2018-07-01'
--and datetime<'2019-01-01'
(ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and ride in ('MU','FM')
and cmpcode='020459'
and inf=0
and tickettype not in ('���ڷ�', '���շ�','��������')
group by RebateStr

select * from #ccc

--��ͻ�Э��

select SUM(����) �ϼ�,SUM(����) ����,(100-Discount)/100 �ۿ� from #ccc ccc
inner join homsomDB..Trv_FlightTripartitePolicies f on f.ID=ccc.RebateStr
group by Discount