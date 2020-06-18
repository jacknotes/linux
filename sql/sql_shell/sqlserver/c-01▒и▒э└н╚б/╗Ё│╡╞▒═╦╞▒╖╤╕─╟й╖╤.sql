select OutStroke as 行程,TrainWebNo as 订单号,u.RealPrice as 车票价格,u.Fuprice as 服务费,u.PrintPrice as 打印费,ISNULL(r.Fee,0) as 退票费
FROM Topway..tbTrainTicketInfo t
LEFT JOIN Topway..tbTrainUser u ON t.ID=u.TrainTicketNo
LEFT JOIN Topway..Train_ReturnTicket r ON u.ID=r.TickOrderDetailID
where CmpId='019358' and OutBegdate>='2018-01-01' and OutBegdate<'2019-01-01' --AND t.ID='10848'
order by TrainWebNo