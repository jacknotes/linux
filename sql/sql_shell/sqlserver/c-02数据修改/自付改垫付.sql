
--国内客户自付转垫付 开始-----------------------
SELECT  Trv_tktBookings.ID, homsomDB..Trv_DomesticTicketRecord.RecordNumber,Trv_tktBookings.PayStatus,PayNo,CustomerPayWay,CustomerPayDate,AdvanceStatus,TCPayNo,TcPayWay,TcPayDate
FROM    homsomDB..Trv_tktBookings
        LEFT JOIN homsomDB..Trv_PnrInfos ON homsomDB..Trv_tktBookings.ID = homsomDB..Trv_PnrInfos.ItktBookingID
        LEFT JOIN homsomDB..Trv_DomesticTicketRecord ON homsomDB..Trv_PnrInfos.ID = homsomDB..Trv_DomesticTicketRecord.PnrInfoID
WHERE   Trv_DomesticTicketRecord.RecordNumber IN ('as002471581')



SELECT payperson,* FROM Topway..PayDetail WHERE payperson='1' AND ysid =CONVERT(NVARCHAR(100),(SELECT  Trv_tktBookings.ID
FROM    homsomDB..Trv_tktBookings
        LEFT JOIN homsomDB..Trv_PnrInfos ON homsomDB..Trv_tktBookings.ID = homsomDB..Trv_PnrInfos.ItktBookingID
        LEFT JOIN homsomDB..Trv_DomesticTicketRecord ON homsomDB..Trv_PnrInfos.ID = homsomDB..Trv_DomesticTicketRecord.PnrInfoID
WHERE   Trv_DomesticTicketRecord.RecordNumber IN ('as002471581')))
SELECT  PayStatus,PayNo,CustomerPayWay,CustomerPayDate,AdvanceStatus,TCPayNo,TcPayWay,TcPayDate,* FROM Topway..tbcash WHERE coupno IN ('as002471581')

select * from Topway..tbFiveCoupInfo where CoupNo in ('as002471581')
select * from Topway..tbcash where coupno in ('as002471581')
--更新trv_tktbookings国内
UPDATE  homsomDB..Trv_TktBookings
SET     AdvanceStatus = PayStatus ,
        TCPayNo = PayNo ,
        TcPayWay = CustomerPayWay ,
        TcPayDate = CustomerPayDate ,
        PayStatus = 0 ,
        PayNo = NULL ,
        CustomerPayWay = 0 ,
        CustomerPayDate = NULL
WHERE   id IN (
        SELECT  Trv_tktBookings.ID
        FROM    homsomDB..Trv_tktBookings
                LEFT JOIN homsomDB..Trv_PnrInfos ON homsomDB..Trv_tktBookings.ID = homsomDB..Trv_PnrInfos.ItktBookingID
                LEFT JOIN homsomDB..Trv_DomesticTicketRecord ON homsomDB..Trv_PnrInfos.ID = homsomDB..Trv_DomesticTicketRecord.PnrInfoID
        WHERE   Trv_DomesticTicketRecord.RecordNumber IN ('as002471581') )
select * from homsomDB..Trv_DomesticTicketRecord where RecordNumber='as002471581'
select * from Topway..tbFiveCoupInfo where CoupNo='as002471581'
--更新tbcash 取消自动核销数据，自付改垫付
UPDATE  Topway..tbcash
SET     AdvanceStatus = PayStatus ,
        TCPayNo = PayNo ,
        TcPayWay = CustomerPayWay ,
        TcPayDate = CustomerPayDate ,
        PayStatus = 0 ,
        PayNo = NULL ,
        CustomerPayWay = 0 ,
        CustomerPayDate = NULL,
        status=0,
        vpay=0,
        vpayinf='',
        owe=vpay,
        dzhxDate='1900-01-01',
        oper2='',
        datetime2='1900-01-01'
WHERE   coupno IN ('AS001868466')


--更新支付表
UPDATE Topway..PayDetail SET payperson='2' WHERE ID IN(SELECT ID FROM Topway..PayDetail WHERE payperson='1' AND ysid in (SELECT  CONVERT(NVARCHAR(100),Trv_tktBookings.ID)
FROM    homsomDB..Trv_tktBookings
        LEFT JOIN homsomDB..Trv_PnrInfos ON homsomDB..Trv_tktBookings.ID = homsomDB..Trv_PnrInfos.ItktBookingID
        LEFT JOIN homsomDB..Trv_DomesticTicketRecord ON homsomDB..Trv_PnrInfos.ID = homsomDB..Trv_DomesticTicketRecord.PnrInfoID
WHERE   Trv_DomesticTicketRecord.RecordNumber IN ('AS001868466')))



--国际自付变更垫付        
UPDATE Topway..tbFiveCoupInfo 
SET    AdvanceStatus = PayStatus ,
		TCPayNo = PayNo ,
		TcPayWay = CustomerPayWay ,
		TcPayDate = CustomerPayDate ,
		PayStatus = 0 ,
		PayNo = NULL ,
		CustomerPayWay = 0 ,
		CustomerPayDate = NULL
WHERE CoupNo IN ('AS001868466')

--国际支付信息变更


UPDATE Topway..PayDetail SET payperson='2' WHERE payperson='1' 
AND ysid IN(SELECT CONVERT(NVARCHAR(50) ,p.Id) as fno FROM Topway..tbFiveCoupInfo f
INNER JOIN homsomDB..Intl_OrderPays p ON f.OrderId=p.OrderId
WHERE CoupNo IN ('AS001868466 '))


--更新出票信息中的支付号
update tbcash set TCPayNo=( select Pnum from PayDetail 
where  tbcash.sixnoid=PayDetail.ysid and PayDetail.Pnum is not null
) where coupno IN ('AS001868466 ')
--更新国际销售单中支付号
update tbFiveCoupInfo set TCPayNo=( select Pnum from PayDetail 
where  CONVERT(nvarchar, tbFiveCoupInfo.fiveno)=PayDetail.ysid and PayDetail.Pnum is not null
) where coupno IN ('AS001868466 ')

select * from tbFiveCoupInfo where coupno IN ('AS000423690','AS000423724')