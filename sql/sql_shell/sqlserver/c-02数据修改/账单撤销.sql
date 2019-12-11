--账单撤销
SELECT SubmitState as 机票账单状态,TrainBillStatus as 火车票账单状态,HotelSubmitStatus as 酒店账单状态,BillNumber as 账单号,* 
FROM AccountStatement
WHERE (CompanyCode in (018362))
ORDER BY BillNumber DESC

--机票账单撤销
update AccountStatement set SubmitState=1 WHERE (CompanyCode in (018362)) and BillNumber='018362_20190526'
--火车票账单撤销
update AccountStatement set TrainBillStatus=1 WHERE (CompanyCode in (019398)) and BillNumber='019398_20160901'
--酒店账单撤销
update AccountStatement set HotelSubmitStatus=2 WHERE (CompanyCode in (019398)) and BillNumber='019398_20160901'

 