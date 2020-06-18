--订单号（国内）
SELECT t.TravelID,coupno FROM tbcash c
LEFT JOIN homsomDB..Trv_DomesticTicketRecord d ON c.coupno=d.RecordNumber
LEFT JOIN homsomDB..Trv_PnrInfos p ON d.PnrInfoID=p.ID
LEFT JOIN homsomDB..Trv_ItktBookings i ON p.ItktBookingID=i.ID
LEFT JOIN homsomDB..Trv_Travels t ON i.TravelID=t.ID
where coupno in ('AS002165900',	'AS002161391',	'AS002165336',	'AS002159334',	'AS001908134',	'AS001910752',	'AS001952463',	'AS001876445',	'AS001876372',	'AS001876449',	'AS002167185',	'AS002157707',	'AS002163959',	'AS002163957',	'AS002157378',	'AS002167424',	'AS002165021')

--国际---
SELECT b.OrderNo,* FROM tbcash c
LEFT JOIN dbo.tbFiveCoupInfo f ON c.coupno=f.CoupNo
LEFT JOIN homsomDB..Intl_BookingOrders b ON f.OrderId=b.Id
where