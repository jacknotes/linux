--SELECT * FROM dbo.Trv_UnitCompanies WHERE Cmpid='020459'

SELECT 
--h.Name,t.TravelID,s.FlightClass,s.OriginName,s.DestinationName,s.Departing,s.Origin,s.Destination,s.Departing,s.Flight ,

ca.datetime as 出票日期,ca.begdate as 起飞日期,ca.CoupNo AS 销售单号,ca.pasname AS 乘客姓名,h.Name as 预订人姓名,ca.route as 行程,ca.tcode+ca.ticketno as 票号,ca.price/ca.priceinfo AS 折扣率
,ca.price AS 销售单价,ca.tax AS 税收 ,ca.fuprice AS 服务费,ca.totprice AS 销售价,ca.reti AS 退票单号,ca.Department AS 部门,s.FlightClass AS 舱位,ca.ride+ca.flightno as 航班号,
CASE CONVERT(NVARCHAR(50),i.BookingSource) WHEN '1' THEN '网单' WHEN '2' THEN '手工导单'
 WHEN '3' THEN '电话预订'
  WHEN '4' THEN '空白导单'
   WHEN '5' THEN 'APP预订'
    WHEN '10' THEN '微信预订'
 WHEN '11' THEN '预订'
 ELSE '其他' end as 订单来源
FROM dbo.Trv_CompanyTravels c
LEFT JOIN dbo.Trv_Travels t ON c.ID=t.ID
LEFT JOIN dbo.Trv_ItktBookings i ON t.ID=i.TravelID
LEFT JOIN dbo.Trv_TktBookings b ON i.ID=b.ID
LEFT JOIN dbo.Trv_ItktBookingSegs s ON i.id=s.ItktBookingID
LEFT JOIN dbo.Trv_UnitPersons u ON t.CreateBy=u.CustID
LEFT JOIN dbo.Trv_Human h ON u.ID=h.id
--LEFT JOIN homsomDB..Trv_PnrInfos p ON i.ID=p.ItktBookingID
LEFT JOIN homsomDB..Trv_ItktBookingSegments_PnrInfos sp ON sp.ItktBookingSegID=s.ID
LEFT JOIN homsomDB..Trv_DomesticTicketRecord r ON sp.PnrInfoID=r.PnrInfoID
INNER JOIN Topway..tbcash ca ON r.RecordNumber=ca.coupno
WHERE b.AdminStatus NOT IN(6,7,8) AND c.UnitCompanyID='3C9C507C-FB07-432B-B047-A912010A9C3D'
AND ( s.FlightClass LIKE '%头等舱%') --AND LEN(s.FlightClass)<=8
--AND ( s.FlightClass not LIKE '%折扣%' and  s.FlightClass not LIKE '%优惠%'  and  s.FlightClass not LIKE '%特价%' )
--AND i.BookingSource=5
AND r.HandleStatus NOT IN(4,5)
ORDER BY ca.CoupNo desc