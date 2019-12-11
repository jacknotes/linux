drop table #ccc
select RebateStr,SUM(price) ����,COUNT(c.id) ���� ,sum(convert(decimal(8,2),originalprice)) ԭ����
into #ccc
from Topway..tbcash C
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos pn on pn.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ItktBookingID=pn.ItktBookingID and c.ride+C.flightno=it.Flight
--LEFT JOIN homsomDB..Trv_ItktBookingSegments_PnrInfos p ON p.ItktBookingSegID=it.ID
where
-- datetime>='2018-07-01'
--and datetime<'2019-01-01'
(ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and ride in ('MU','FM')
and cmpcode='020459'
and inf=0
and tickettype not in ('���ڷ�', '���շ�','��������')
group by RebateStr

select sum(����) ������,SUM(����) ������,SUM(ԭ����)�ۿ�ǰ������  from #ccc

--��ͻ�Э��

select SUM(����) �ϼ�,SUM(����) ����,SUM(ԭ����) �ۿ�ǰ����,(100-Discount)/100 �ۿ� from #ccc ccc
inner join homsomDB..Trv_FlightTripartitePolicies f on f.ID=ccc.RebateStr
group by Discount