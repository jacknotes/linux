IF OBJECT_ID('tempdb.dbo.#t') IS NOT NULL DROP TABLE #t
select datetime,coupno 
INTO #t
from Topway..tbcash where cmpcode='020459' and datetime>='2018-12-01'


--Reasoncode
IF OBJECT_ID('tempdb.dbo.#t') IS NOT NULL DROP TABLE #t7
 select RecordNumber,ReasonDescription  
 into #t7
 FROM [homsomDB].[dbo].[Trv_DeniedReason] t1 
 inner join  [homsomDB].[dbo].[Trv_PnrInfos] t2  on t1.ItktBookingID =t2.ItktBookingID 
 inner join  [homsomDB].[dbo].[Trv_DomesticTicketRecord] t3 on t2.id=t3.[PnrInfoID] where reasontype = 1 
 and RecordNumber in (select coupno from #t)

--×îµÍÆ±¼Û
 select t2.RecordNumber,c.datetime,t3.Price,ReasonDescription
 FROM [homsomDB].[dbo].[Trv_LowerstPrices] t3 
inner join  [homsomDB].[dbo].[Trv_ItktBookingSegs] t4 on t3.ItktBookingSegID = t4.ID
inner join [homsomDB].[dbo].[Trv_PnrInfos] t1 on  t1.ItktBookingID =t4.ItktBookingID  
 inner join  [homsomDB].[dbo].[Trv_DomesticTicketRecord] t2 on t2.[PnrInfoID]=t1.id
 left join Topway ..tbcash c on c.coupno=t2.RecordNumber
 left join #t7 tt on tt.RecordNumber=t2.RecordNumber
 where t2.RecordNumber in (select coupno from #t)
 
 order by datetime