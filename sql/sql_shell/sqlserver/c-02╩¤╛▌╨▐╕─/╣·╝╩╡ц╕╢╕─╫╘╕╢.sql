--更改支付方式（自付、垫付）
--核销
update Topway..tbcash set PayNo=TCPayNo,TCPayNo='',PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate, TcPayDate=''
where coupno in('AS001810652','AS001812250')

--国际
UPDATE Topway..tbFiveCoupInfo 
SET    PayStatus = AdvanceStatus ,
      		PayNo = TCPayNo ,
		CustomerPayWay= TcPayWay ,
		CustomerPayDate= TcPayDate ,
		AdvanceStatus =0,
		TCPayNo = NULL ,
		TcPayWay =0,
		TcPayDate = NULL
WHERE CoupNo in('AS001810652','AS001812250')

UPDATE Topway..tbFiveCoupInfo 
SET    PayStatus= AdvanceStatus ,
		PayNo= TCPayNo ,
		CustomerPayWay= TcPayWay ,
		CustomerPayDate= TcPayDate ,
		AdvanceStatus =0,
		TCPayNo = NULL ,
		TcPayWay =0,
		TcPayDate = NULL
WHERE CoupNo in('AS001810652','AS001812250')