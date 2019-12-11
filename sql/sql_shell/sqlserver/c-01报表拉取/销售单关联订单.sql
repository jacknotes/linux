
--国际
select Price,* from Topway..PayDetail where ysid in (select CONVERT(nvarchar, fiveno) from Topway..tbFiveCoupInfo where CoupNo in ('AS001334156','AS001334128'))

--国内
select a.RecordNumber,d.TravelID from homsomDB..Trv_DomesticTicketRecord as a
left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID
left join homsomDB..Trv_ItktBookings as c on b.ItktBookingID=c.ID
left join homsomDB..Trv_Travels as d on c.TravelID=d.ID
where a.RecordNumber='AS002018130'

