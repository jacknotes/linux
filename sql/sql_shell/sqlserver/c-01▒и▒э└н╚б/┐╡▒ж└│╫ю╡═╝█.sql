  select Price,
  (select top 1 RecordNumber from [homsomDB].[dbo].[Trv_DomesticTicketRecord] a , [homsomDB].[dbo].[Trv_PnrInfos] b , [homsomDB].[dbo].[Trv_ItktBookingSegs] c
 where a.PnrInfoID=b.ID and b.ItktBookingID=c.ItktBookingID and d.ItktBookingSegID=c.ID ) as coupno
  FROM [homsomDB].[dbo].[Trv_LowerstPrices] d where ItktBookingSegID in 
  (
 select ID FROM [homsomDB].[dbo].[Trv_ItktBookingSegs] where ItktBookingID in 
 (
 select ItktBookingID FROM [homsomDB].[dbo].[Trv_PnrInfos] where ID in
 (
  select [PnrInfoID]  from [homsomDB].[dbo].[Trv_DomesticTicketRecord] where RecordNumber in (    'AS002095735' ,
 'AS002096608' ,
 'AS002097161' ,
 'AS002097167' ,
 'AS002099047' ,
 'AS002099055' ,
 'AS002099769' ,
 'AS002100525' ,
 'AS002100534' ,
 'AS002101590' ,
 'AS002101624' ,
 'AS002101657' ,
 'AS002104162' ,
 'AS002106366' ,
 'AS002108376' ,
 'AS002109793' ,
 'AS002110793' ,
 'AS002110797' ,
 'AS002112421' ,
 'AS002112949' ,
 'AS002112986' ,
 'AS002113842' ,
 'AS002113844' ,
 'AS002114448' ,
 'AS002116399' ,
 'AS002116405' ,
 'AS002116520' ,
 'AS002116528' ,
 'AS002117900' ,
 'AS002118060' ,
 'AS002118062' ,
 'AS002122465' ,
 'AS002127263' ,
 'AS002127272' ,
 'AS002127293' ,
 'AS002127295' ,
 'AS002127504' ,
 'AS002127510' ,
 'AS002127563' ,
 'AS002127565' ,
 'AS002131764' ,
 'AS002131790' ,
 'AS002131792' ,
 'AS002131798' ,
 'AS002135466' ,
 'AS002140720' ,
 'AS002144691' ,
 'AS002147703' ,
 'AS002147729' ,
 'AS002148658' ,
 'AS002148660' ,
 'AS002148691' ,
 'AS002148700' ,
 'AS002150762' ,
 'AS002071700'
)
 )
 )
 )