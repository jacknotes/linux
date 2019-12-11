--SELECT * FROM dbo.Trv_UnitCompanies WHERE Cmpid='020459'

SELECT 
--h.Name,t.TravelID,s.FlightClass,s.OriginName,s.DestinationName,s.Departing,s.Origin,s.Destination,s.Departing,s.Flight ,

ca.datetime as ��Ʊ����,ca.begdate as �������,ca.CoupNo AS ���۵���,ca.pasname AS �˿�����,h.Name as Ԥ��������,ca.route as �г�,ca.tcode+ca.ticketno as Ʊ��,ca.price/ca.priceinfo AS �ۿ���
,ca.price AS ���۵���,ca.tax AS ˰�� ,ca.fuprice AS �����,ca.totprice AS ���ۼ�,ca.reti AS ��Ʊ����,ca.Department AS ����,s.FlightClass AS ��λ,ca.ride+ca.flightno as �����,
CASE CONVERT(NVARCHAR(50),i.BookingSource) WHEN '1' THEN '����' WHEN '2' THEN '�ֹ�����'
 WHEN '3' THEN '�绰Ԥ��'
  WHEN '4' THEN '�հ׵���'
   WHEN '5' THEN 'APPԤ��'
    WHEN '10' THEN '΢��Ԥ��'
 WHEN '11' THEN 'Ԥ��'
 ELSE '����' end as ������Դ
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
AND ( s.FlightClass LIKE '%ͷ�Ȳ�%') --AND LEN(s.FlightClass)<=8
--AND ( s.FlightClass not LIKE '%�ۿ�%' and  s.FlightClass not LIKE '%�Ż�%'  and  s.FlightClass not LIKE '%�ؼ�%' )
--AND i.BookingSource=5
AND r.HandleStatus NOT IN(4,5)
ORDER BY ca.CoupNo desc