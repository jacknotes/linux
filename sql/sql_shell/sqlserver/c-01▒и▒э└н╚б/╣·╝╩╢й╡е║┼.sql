SELECT T2.[CoupNo],T1.OrderNo
  FROM [homsomDB].[dbo].[Intl_BookingOrders] T1
  INNER JOIN [Topway].[dbo].[tbFiveCoupInfo] T2 ON T1.Id=T2.OrderId
  where Id in(select OrderId from Topway..tbFiveCoupInfo where CoupNo in ('AS002119127','AS002134797','AS002138904','AS002139052','AS002147098','AS002147141','AS002147486','AS002150896','AS002164161','AS002165870','AS002075377'))
  
  
  
  