select OutStroke as �г�,TrainWebNo as ������,u.RealPrice as ��Ʊ�۸�,u.Fuprice as �����,u.PrintPrice as ��ӡ��,ISNULL(r.Fee,0) as ��Ʊ��
FROM Topway..tbTrainTicketInfo t
LEFT JOIN Topway..tbTrainUser u ON t.ID=u.TrainTicketNo
LEFT JOIN Topway..Train_ReturnTicket r ON u.ID=r.TickOrderDetailID
where CmpId='019358' and OutBegdate>='2018-01-01' and OutBegdate<'2019-01-01' --AND t.ID='10848'
order by TrainWebNo