SELECT c.coupno,(SELECT TOP 1 price FROM ehomsom..tbItktTj tj WHERE its.Origin=tj.begcode AND its.Destination=tj.endcode AND tj.price<its.AdultPrice ORDER BY id desc) AS tjprice
 FROM topway..tbcash c 
LEFT JOIN homsomDB..Trv_DomesticTicketRecord r ON c.coupno=r.RecordNumber
LEFT JOIN homsomDB..Trv_PnrInfos p ON r.PnrInfoID=p.ID
LEFT JOIN homsomDB..Trv_ItktBookings i ON p.ItktBookingID=i.ID
left join homsomDB..Trv_ItktBookingSegs its on i.ID=its.ItktBookingID
left join homsomDB..Trv_LowerstPrices lp on its.ID=lp.ItktBookingSegID
where c.coupno in ( 'AS002110797')
 order by c.coupno