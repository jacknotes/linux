
--国内客户自付转垫付 开始-----------------------
SELECT  Trv_tktBookings.ID, homsomDB..Trv_DomesticTicketRecord.RecordNumber,Trv_tktBookings.PayStatus,PayNo,CustomerPayWay,CustomerPayDate,AdvanceStatus,TCPayNo,TcPayWay,TcPayDate
FROM    homsomDB..Trv_tktBookings
        LEFT JOIN homsomDB..Trv_PnrInfos ON homsomDB..Trv_tktBookings.ID = homsomDB..Trv_PnrInfos.ItktBookingID
        LEFT JOIN homsomDB..Trv_DomesticTicketRecord ON homsomDB..Trv_PnrInfos.ID = homsomDB..Trv_DomesticTicketRecord.PnrInfoID
WHERE   Trv_DomesticTicketRecord.RecordNumber IN ('AS002216887','AS002216908')



SELECT payperson,* FROM Topway..PayDetail WHERE payperson='1' AND ysid =CONVERT(NVARCHAR(100),(SELECT  Trv_tktBookings.ID
FROM    homsomDB..Trv_tktBookings
        LEFT JOIN homsomDB..Trv_PnrInfos ON homsomDB..Trv_tktBookings.ID = homsomDB..Trv_PnrInfos.ItktBookingID
        LEFT JOIN homsomDB..Trv_DomesticTicketRecord ON homsomDB..Trv_PnrInfos.ID = homsomDB..Trv_DomesticTicketRecord.PnrInfoID
WHERE   Trv_DomesticTicketRecord.RecordNumber IN  ('AS002216887')))
SELECT  PayStatus,PayNo,CustomerPayWay,CustomerPayDate,AdvanceStatus,TCPayNo,TcPayWay,TcPayDate,* FROM Topway..tbcash WHERE coupno IN  ('AS002216887','AS002216908')



--更新trv_tktbookings
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
        WHERE   Trv_DomesticTicketRecord.RecordNumber IN  ('AS002216887','AS002216908') )

--更新tbcash 取消自动核销数据
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
WHERE   coupno IN ('AS002216887','AS002216908')



--更新支付表
UPDATE Topway..PayDetail SET payperson='2' WHERE ID IN(SELECT ID FROM Topway..PayDetail WHERE payperson='1' AND ysid in (SELECT CONVERT(NVARCHAR(100),Trv_tktBookings.ID)
FROM    homsomDB..Trv_tktBookings
        LEFT JOIN homsomDB..Trv_PnrInfos ON homsomDB..Trv_tktBookings.ID = homsomDB..Trv_PnrInfos.ItktBookingID
        LEFT JOIN homsomDB..Trv_DomesticTicketRecord ON homsomDB..Trv_PnrInfos.ID = homsomDB..Trv_DomesticTicketRecord.PnrInfoID
WHERE   Trv_DomesticTicketRecord.RecordNumber IN  ('AS002216887','AS002216908')))

UPDATE Topway..PayDetail SET payperson='2' WHERE ID IN(SELECT ID FROM Topway..PayDetail WHERE payperson='1' AND ysid in (SELECT CONVERT(NVARCHAR(100),Trv_tktBookings.ID)
FROM    homsomDB..Trv_tktBookings
        LEFT JOIN homsomDB..Trv_PnrInfos ON homsomDB..Trv_tktBookings.ID = homsomDB..Trv_PnrInfos.ItktBookingID
        LEFT JOIN homsomDB..Trv_DomesticTicketRecord ON homsomDB..Trv_PnrInfos.ID = homsomDB..Trv_DomesticTicketRecord.PnrInfoID
WHERE   Trv_DomesticTicketRecord.RecordNumber IN  ('AS002216887','AS002216908')))


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
WHERE CoupNo IN ('AS002216887')

UPDATE Topway..tbFiveCoupInfo 
SET    AdvanceStatus = PayStatus ,
		TCPayNo = PayNo ,
		TcPayWay = CustomerPayWay ,
		TcPayDate = CustomerPayDate ,
		PayStatus = 0 ,
		PayNo = NULL ,
		CustomerPayWay = 0 ,
		CustomerPayDate = NULL
WHERE CoupNo IN ('AS002216908')

--国际支付信息变更
UPDATE Topway..PayDetail SET payperson='2' WHERE payperson='1' 
AND ysid IN(SELECT CONVERT(nvarchar ,fiveno) as fno FROM Topway..tbFiveCoupInfo 
WHERE CoupNo IN  ('AS002216887','AS002216908'))

--更新出票信息中的支付号
update tbcash set TCPayNo=( select Pnum from PayDetail 
where  tbcash.sixnoid=PayDetail.ysid and PayDetail.Pnum is not null
) where coupno IN  ('AS002216887','AS002216908')


--更新国际销售单中支付号
update tbFiveCoupInfo set TCPayNo=( select Pnum from PayDetail 
where  CONVERT(nvarchar, tbFiveCoupInfo.fiveno)=PayDetail.ysid and PayDetail.Pnum is not null
) where coupno IN  ('AS002216887','AS002216908')

select * from tbFiveCoupInfo where coupno IN ('AS001140481')

--酒店
update [Topway].[dbo].[tbHtlcoupRefund] set AdvanceMethod=PayMethod,AdvanceStatus=PayStatus,AdvancePayNo=PayNo,AdvanceDate=PaySubmitDate, PayMethod=0,PayStatus=0,PayNo=null,PaySubmitDate=null  
where CoupNo='PTW037450';

 update [Topway].[dbo].[tbhtlyfchargeoff] set cwstatus=0,owe=vpay,vpay=0,opername1='',vpayinfo='',oth2=''
  where coupid in (select id  from [Topway].[dbo].tbHtlcoupYf where CoupNo='PTW037450');
  
  
  update [HotelOrderDB].[dbo].[HTL_Orders] set [AdvanceNumber]='0316',[AdvanceName]='周婧',[AdvanceStatus]=3,[AdvanceDate]=PayDate,PayStatus=0,PayDate=null
  where CoupNo='PTW037450';
  
  update [HotelOrderDB].[dbo].[HTL_OrderSettlements] set AdvancePayNo=PayNo,AdvanceMethod=PayMethod,PayMethod=null,PayNo=null 
  where OrderID in (select OrderID from [HotelOrderDB].[dbo].[HTL_Orders] where CoupNo='PTW037450');
