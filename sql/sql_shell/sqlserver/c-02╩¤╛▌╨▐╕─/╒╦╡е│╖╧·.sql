--�˵�����
SELECT SubmitState as ��Ʊ�˵�״̬,TrainBillStatus as ��Ʊ�˵�״̬,HotelSubmitStatus as �Ƶ��˵�״̬,BillNumber as �˵���,* 
FROM AccountStatement
WHERE (CompanyCode in (018362))
ORDER BY BillNumber DESC

--��Ʊ�˵�����
update AccountStatement set SubmitState=1 WHERE (CompanyCode in (018362)) and BillNumber='018362_20190526'
--��Ʊ�˵�����
update AccountStatement set TrainBillStatus=1 WHERE (CompanyCode in (019398)) and BillNumber='019398_20160901'
--�Ƶ��˵�����
update AccountStatement set HotelSubmitStatus=2 WHERE (CompanyCode in (019398)) and BillNumber='019398_20160901'

 