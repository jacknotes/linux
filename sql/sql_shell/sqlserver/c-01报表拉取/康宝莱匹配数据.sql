--1.	授权码、Reason Code、最低票价、舱位级别（中文，而不是英文代码）。

--2.	当月出票当月退票的情况下，要显示销售单价。

--3.	当月出票次月退票的情况下，要显示销售单价、税收。

--4.	改期升舱的票，在“线路”一列中，在原票号后添加原票的销售单价。举例：“改期升舱 太原-上海虹桥781-2898636755  1080元”

--''
--' as coupno UNION ALL SELECT  '
IF OBJECT_ID('tempdb.dbo.#t') IS NOT NULL DROP TABLE #t
CREATE TABLE #t(
coupno varchar(100))
INSERT INTO #t(coupno)
--="UNION ALL Select '" &B2&"' as coupno"
Select 'AS002095735' as coupno
UNION ALL Select 'AS002096608' as coupno
UNION ALL Select 'AS002097161' as coupno
UNION ALL Select 'AS002097167' as coupno
UNION ALL Select 'AS002098159' as coupno
UNION ALL Select 'AS002099047' as coupno
UNION ALL Select 'AS002099055' as coupno
UNION ALL Select 'AS002099769' as coupno
UNION ALL Select 'AS002100525' as coupno
UNION ALL Select 'AS002100534' as coupno
UNION ALL Select 'AS002101590' as coupno
UNION ALL Select 'AS002101624' as coupno
UNION ALL Select 'AS002101657' as coupno
UNION ALL Select 'AS002102890' as coupno
UNION ALL Select 'AS002104162' as coupno
UNION ALL Select 'AS002104239' as coupno
UNION ALL Select 'AS002104241' as coupno
UNION ALL Select 'AS002106366' as coupno
UNION ALL Select 'AS002108376' as coupno
UNION ALL Select 'AS002109398' as coupno
UNION ALL Select 'AS002109793' as coupno
UNION ALL Select 'AS002110793' as coupno
UNION ALL Select 'AS002110797' as coupno
UNION ALL Select 'AS002112421' as coupno
UNION ALL Select 'AS002112949' as coupno
UNION ALL Select 'AS002112986' as coupno
UNION ALL Select 'AS002113497' as coupno
UNION ALL Select 'AS002113505' as coupno
UNION ALL Select 'AS002113842' as coupno
UNION ALL Select 'AS002113844' as coupno
UNION ALL Select 'AS002114448' as coupno
UNION ALL Select 'AS002116399' as coupno
UNION ALL Select 'AS002116405' as coupno
UNION ALL Select 'AS002116520' as coupno
UNION ALL Select 'AS002116528' as coupno
UNION ALL Select 'AS002117900' as coupno
UNION ALL Select 'AS002118056' as coupno
UNION ALL Select 'AS002118060' as coupno
UNION ALL Select 'AS002118062' as coupno
UNION ALL Select 'AS002119127' as coupno
UNION ALL Select 'AS002121652' as coupno
UNION ALL Select 'AS002121871' as coupno
UNION ALL Select 'AS002122465' as coupno
UNION ALL Select 'AS002122560' as coupno
UNION ALL Select 'AS002127263' as coupno
UNION ALL Select 'AS002127272' as coupno
UNION ALL Select 'AS002127293' as coupno
UNION ALL Select 'AS002127295' as coupno
UNION ALL Select 'AS002127504' as coupno
UNION ALL Select 'AS002127510' as coupno
UNION ALL Select 'AS002127563' as coupno
UNION ALL Select 'AS002127565' as coupno
UNION ALL Select 'AS002131764' as coupno
UNION ALL Select 'AS002131790' as coupno
UNION ALL Select 'AS002131792' as coupno
UNION ALL Select 'AS002131798' as coupno
UNION ALL Select 'AS002134797' as coupno
UNION ALL Select 'AS002135462' as coupno
UNION ALL Select 'AS002135466' as coupno
UNION ALL Select 'AS002138904' as coupno
UNION ALL Select 'AS002139052' as coupno
UNION ALL Select 'AS002140720' as coupno
UNION ALL Select 'AS002141312' as coupno
UNION ALL Select 'AS002141860' as coupno
UNION ALL Select 'AS002144691' as coupno
UNION ALL Select 'AS002144708' as coupno
UNION ALL Select 'AS002146064' as coupno
UNION ALL Select 'AS002146082' as coupno
UNION ALL Select 'AS002147098' as coupno
UNION ALL Select 'AS002147141' as coupno
UNION ALL Select 'AS002147486' as coupno
UNION ALL Select 'AS002147703' as coupno
UNION ALL Select 'AS002147729' as coupno
UNION ALL Select 'AS002147812' as coupno
UNION ALL Select 'AS002148658' as coupno
UNION ALL Select 'AS002148660' as coupno
UNION ALL Select 'AS002148672' as coupno
UNION ALL Select 'AS002148674' as coupno
UNION ALL Select 'AS002148691' as coupno
UNION ALL Select 'AS002148698' as coupno
UNION ALL Select 'AS002148700' as coupno
UNION ALL Select 'AS002148999' as coupno
UNION ALL Select 'AS002149848' as coupno
UNION ALL Select 'AS002150762' as coupno
UNION ALL Select 'AS002150896' as coupno
UNION ALL Select 'AS002071700' as coupno



select * from #t

--授权码
IF OBJECT_ID('tempdb.dbo.#t1') IS NOT NULL DROP TABLE #t1
SELECT c.coupno,AuthorizationCode 

FROM topway..tbcash c 
LEFT JOIN homsomDB..Trv_DomesticTicketRecord r ON c.coupno=r.RecordNumber
LEFT JOIN homsomDB..Trv_PnrInfos p ON r.PnrInfoID=p.ID
LEFT JOIN homsomDB..Trv_tktBookings i ON p.ItktBookingID=i.ID
where c.coupno in 
(select * from #t)

--最低票价
--SELECT c.coupon,(SELECT TOP 1 price FROM ehomsom..tbItktTj tj WHERE its.Origin=tj.begcode AND its.Destination=tj.endcode AND tj.price<its.AdultPrice ORDER BY id desc) AS tjprice
-- FROM topway..tbcash c 
--LEFT JOIN homsomDB..Trv_DomesticTicketRecord r ON c.coupno=r.RecordNumber
--LEFT JOIN homsomDB..Trv_PnrInfos p ON r.PnrInfoID=p.ID
--LEFT JOIN homsomDB..Trv_ItktBookings i ON p.ItktBookingID=i.ID
--left join homsomDB..Trv_ItktBookingSegs its on i.ID=its.ItktBookingID
--left join homsomDB..Trv_LowerstPrices lp on its.ID=lp.ItktBookingSegID
--where c.coupno in 
--(select * from #t)


--Reasoncode,最低票价
--IF OBJECT_ID('tempdb.dbo.#t2') IS NOT NULL DROP TABLE #t2
--SELECT coupno,ReasonDescription,(SELECT TOP 1 price FROM ehomsom..tbItktTj tj WHERE its.Origin=tj.begcode AND its.Destination=tj.endcode AND tj.price<its.AdultPrice ORDER BY id desc) AS tjprice 
--into #t2
--FROM topway..tbcash c 
--LEFT JOIN homsomDB..Trv_DomesticTicketRecord r ON c.coupno=r.RecordNumber
--LEFT JOIN homsomDB..Trv_PnrInfos p ON r.PnrInfoID=p.ID
--left join homsomDB..Trv_DeniedReason d on d.ItktBookingID=p.ItktBookingID
--left join homsomDB..Trv_ItktBookingSegs its on its.ItktBookingID=p.ItktBookingID
--left join homsomDB..Trv_LowerstPrices ls on ls.ItktBookingSegID=its.ID
--where coupno in 
--(select * from #t)

--最低票价
IF OBJECT_ID('tempdb.dbo.#t2') IS NOT NULL DROP TABLE #t2
 select t2.RecordNumber,Price 
 --into #t2 
 FROM [homsomDB].[dbo].[Trv_LowerstPrices] t3 
inner join  [homsomDB].[dbo].[Trv_ItktBookingSegs] t4 on t3.ItktBookingSegID = t4.ID
inner join [homsomDB].[dbo].[Trv_PnrInfos] t1 on  t1.ItktBookingID =t4.ItktBookingID  
 inner join  [homsomDB].[dbo].[Trv_DomesticTicketRecord] t2 on t2.[PnrInfoID]=t1.id
  where t2.RecordNumber in ('AS002110797')



--Reasoncode
IF OBJECT_ID('tempdb.dbo.#t4') IS NOT NULL DROP TABLE #t4
 select RecordNumber,ReasonDescription  
 --into #t4
 FROM [homsomDB].[dbo].[Trv_DeniedReason] t1 
 inner join  [homsomDB].[dbo].[Trv_PnrInfos] t2  on t1.ItktBookingID =t2.ItktBookingID 
 inner join  [homsomDB].[dbo].[Trv_DomesticTicketRecord] t3 on t2.id=t3.[PnrInfoID] where reasontype = 1 
  and RecordNumber in ('AS002056458')



--舱位
IF OBJECT_ID('tempdb.dbo.#t3') IS NOT NULL DROP TABLE #t3
SELECT c.coupno,(SELECT TOP 1 i.cabintype 
	FROM ehomsom..tbInfCabincode i 
	WHERE	c.ride=i.code2 AND c.nclass=i.cabin 
										AND i.begdate<=c.begdate AND i.enddate>=c.begdate
	ORDER BY id DESC
	) AS cabinType,ride,nclass
	--into #t3
fROM Topway..tbcash  c
where c.coupno in
(select * from #t)


select DISTINCT t.coupno,t1.AuthorizationCode,t4.ReasonDescription,t2.Price,t3.cabinType from #t t
LEFT join #t1 t1 on t1.coupno=t.coupno
LEFT join #t2 t2 on t2.RecordNumber=t.coupno and t1.coupno=t2.RecordNumber
LEFT join #t3 t3 on t3.coupno=t.coupno and t1.coupno=t3.coupno and t2.RecordNumber=t3.coupno
left join #t4 t4 on t4.RecordNumber=t.coupno and t1.coupno=t4.RecordNumber and t2.RecordNumber=t4.RecordNumber and t3.coupno=t4.RecordNumber


--订单号
SELECT  c.coupno,t.TravelID FROM tbcash c
INNER JOIN homsomDB..Trv_DomesticTicketRecord d ON c.coupno=d.RecordNumber
INNER JOIN homsomDB..Trv_PnrInfos p ON d.PnrInfoID=p.ID
INNER JOIN homsomDB..Trv_ItktBookings i ON p.ItktBookingID=i.ID
INNER JOIN homsomDB..Trv_Travels t ON i.TravelID=t.ID
WHERE c.coupno='AS002110797'
--in (select * from #t)