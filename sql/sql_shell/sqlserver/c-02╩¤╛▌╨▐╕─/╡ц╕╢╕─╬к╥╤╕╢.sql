--����
UPDATE  homsomDB..Trv_tktBookings SET PayStatus=1,AdvanceStatus=0,TCPayNo='',TcPayWay=0,TcPayDate='1900-1-1',PayNo='����֧��,֧����δ֪',CustomerPayWay=4,CustomerPayDate='2018-05-08' WHERE ID IN(SELECT  Trv_tktBookings.ID
FROM    homsomDB..Trv_tktBookings
        LEFT JOIN Trv_PnrInfos ON Trv_tktBookings.ID = dbo.Trv_PnrInfos.ItktBookingID
        LEFT JOIN Trv_DomesticTicketRecord ON dbo.Trv_PnrInfos.ID = dbo.Trv_DomesticTicketRecord.PnrInfoID
WHERE   Trv_DomesticTicketRecord.RecordNumber IN ('AS001911097'))
UPDATE Topway..tbcash SET PayStatus=1, PayNo='����֧��,֧����δ֪',CustomerPayWay=4,CustomerPayDate=GETDATE() WHERE coupno IN ('AS001911097')
--����
UPDATE Topway..tbFiveCoupInfo SET PayStatus=1, PayNo='�ֹ��޸�Ϊ��֧��',CustomerPayWay=4,CustomerPayDate=GETDATE() where coupno in ('AS001717491','AS001717496','AS001717544')
UPDATE Topway..tbcash SET PayStatus=1, PayNo='�ֹ��޸�Ϊ��֧��',CustomerPayWay=4,CustomerPayDate=GETDATE() where coupno in ('AS001717491','AS001717496','AS001717544')

--�Զ�����
UPDATE  Topway..tbcash
SET     PayStatus = AdvanceStatus ,
        PayNo = TCPayNo ,
        CustomerPayWay = TcPayWay ,
        CustomerPayDate=TcPayDate,
        AdvanceStatus=0,
        TCPayNo='',
        TcPayWay=0,
        TcPayDate = NULL ,
        status=1,
        vpay=amount,
        vpayinf=CustomerPayWay,
        owe=0,
        dzhxDate=GETDATE(),
        oper2='ϵͳ�Զ�',
        datetime2=GETDATE()
WHERE   coupno IN ('AS001911097')
--����
SELECT *
  FROM [homsomDB].[dbo].[Trv_Insurance] 
  where InsuranceTicketRecordID in (select ID from [homsomDB].[dbo].Trv_InsuranceTicketRecord  where RecordNumber='AS001427714')
update [homsomDB].[dbo].[Trv_Insurance] set PayOrderID=AdvanceOrderID where InsuranceTicketRecordID in (select ID from [homsomDB].[dbo].Trv_InsuranceTicketRecord  where RecordNumber='AS000434535')
update [homsomDB].[dbo].[Trv_Insurance] set AdvanceOrderID = null where InsuranceTicketRecordID in (select ID from [homsomDB].[dbo].Trv_InsuranceTicketRecord  where RecordNumber='AS000434535')


--�ܾ���Ʊ��ȡ����Ʊ
update homsomDB..Trv_DomesticTicketRecord set HandleStatus='5' where RecordNumber='AS000339246'

 
 --�Ƶ�
 update [Topway].[dbo].tbHtlcoupRefund set PayStatus=3,PayMethod=4,PaySubmitDate=GETDATE(),PayNo='����֧��,֧����δ֪' where CoupNo in  ('PTW033916');
 
 update [HotelOrderDB].[dbo].[HTL_Orders] set PayStatus=3,PayDate=GETDATE() where CoupNo in ('PTW033916');
  
 update [HotelOrderDB].[dbo].HTL_OrderSettlements set PayMethod=4,PayNo='����֧��,֧����δ֪' where OrderID in (select OrderID from  [HotelOrderDB].[dbo].[HTL_Orders] where CoupNo in ('PTW033916'));