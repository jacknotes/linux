--更改支付方式（自付、垫付）国内订单
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from homsomDB..Trv_TktBookings
--update homsomDB..Trv_TktBookings set PayNo=TCPayNo,TCPayNo=null,PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate, TcPayDate=null
where ID in (select b.ItktBookingID from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS002359436','AS002352133','AS002339419','AS002323390','AS002277444','AS002277425','AS002277412'))
--出票支付信息
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set PayNo=TCPayNo,TCPayNo=null,PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate,dzhxDate=TcPayDate,TcPayDate=null,status=1,owe=0,vpay=totprice
where coupno in('AS001834923','AS001834924')
--支付信息详情
select payperson,* from topway..PayDetail
--update  topway..PayDetail set payperson=1 
where ysid in (select cast(b.ItktBookingID as varchar(40)) from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS001834923','AS001834924'))


--国际订单
--更改支付方式（自付、垫付)国际

select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set PayNo=TCPayNo,TCPayNo='',PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=null,CustomerPayDate=TcPayDate,dzhxDate=TcPayDate,TcPayDate='1900-01-01',status=1,owe=0,vpay=totprice
where coupno in ('AS002359436','AS002352133','AS002339419','AS002323390','AS002277444','AS002277425','AS002277412')


select PayStatus,AdvanceStatus,PayNo,TCPayNo,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET PayStatus=AdvanceStatus,PayNo=TCPayNo,CustomerPayWay=TcPayWay,CustomerPayDate=TcPayDate,AdvanceStatus=0,TCPayNo='',TcPayWay=0,TcPayDate=null
WHERE CoupNo in ('AS002359436','AS002352133','AS002339419','AS002323390','AS002277444','AS002277425','AS002277412')

