select sum(fuprice) from tbcash 
where cmpcode='018110' and datetime>='2017-01-01' and datetime<'2018-07-01'

select SUM(fwprice) from tbHtlcoupYf
where cmpid='018110' and prdate>='2017-01-01' and prdate<'2018-07-01' and status<>-2

select sum(isnull(c.totprice,0)-isnull(r.totprice,0)) from tbcash c 
left join tbReti r on r.reno=c.reti
where c.cmpcode='018110' and c.datetime>='2017-01-01' and c.datetime<'2018-07-01'

select SUM(price) from tbHtlcoupYf
where cmpid='018110' and prdate>='2017-01-01' and prdate<'2018-07-01' and status<>-2


IF OBJECT_ID('tempdb.dbo.#yh') IS NOT NULL DROP TABLE yh
SELECT (s.Fare-s.FaceValue) AS '协议优惠',p.ItktBookingID,s.FaceValue,s.Fare 
into #yh
FROM homsomDB..Trv_ITktSeats s 
LEFT JOIN homsomDB..Trv_PnrInfos p ON s.PnrInfoID=p.ID
LEFT JOIN homsomDB..Trv_ItktBookings i ON p.ItktBookingID=i.ID
LEFT JOIN homsomDB..Trv_CompanyTravels c ON i.TravelID=c.ID
LEFT JOIN homsomDB..Trv_TktBookings t ON i.ID=t.ID
WHERE s.FaceValue<>s.Fare AND c.UnitCompanyID IN (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid = '016448')
AND s.CreateDate BETWEEN '2017-01-01' AND '2018-07-01'  AND t.TicketSourceType=1 AND (s.Fare-s.FaceValue)>=0
ORDER BY s.CreateDate desc

select SUM(协议优惠) from #yh yh


（homsomDB..Trv_CompanyTravels）UnitCompanyID IN (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid = '016448') 