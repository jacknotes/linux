--��ͼ�   ���ѵ���ͼۺ������ʱ��
SELECT c.coupno,isnull(lp.Price,'') ��ͼ�,isnull(lp.DepartureTime,'') �������,isnull(lp.ArrivalTime,'') ��������,isnull(lp.Flight,'') �����
 FROM topway..tbcash c 
LEFT JOIN homsomDB..Trv_DomesticTicketRecord r ON c.coupno=r.RecordNumber
LEFT JOIN homsomDB..Trv_ItktBookingSegments_PnrInfos p on p.PnrInfoID=r.PnrInfoID
left join homsomDB..Trv_LowerstPrices lp on p.ItktBookingSegID=lp.ItktBookingSegID
where c.coupno in ('���۵���')
and isnull(lp.Price,'')<>0
order by c.coupno


SELECT c.coupno,isnull(lp.Price,'') ��ͼ�,isnull(lp.DepartureTime,'') �������,isnull(lp.ArrivalTime,'') ��������,isnull(lp.Flight,'') �����
 FROM topway..tbcash c 
inner JOIN homsomDB..Trv_DomesticTicketRecord r ON c.coupno=r.RecordNumber
inner JOIN homsomDB..Trv_PnrInfos p ON r.PnrInfoID=p.ID
inner  join homsomDB..Trv_ItktBookingSegs its on p.ItktBookingID=its.ItktBookingID
inner  join homsomDB..Trv_LowerstPrices lp on its.ID=lp.ItktBookingSegID
where c.coupno in ('AS002435233')

select top 100 * from homsomDB..Trv_DomesticTicketRecord