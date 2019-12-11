SELECT  t.TravelID,* FROM tbcash c
INNER JOIN homsomDB..Trv_DomesticTicketRecord d ON c.coupno=d.RecordNumber
INNER JOIN homsomDB..Trv_PnrInfos p ON d.PnrInfoID=p.ID
INNER JOIN homsomDB..Trv_ItktBookings i ON p.ItktBookingID=i.ID
INNER JOIN homsomDB..Trv_Travels t ON i.TravelID=t.ID
WHERE