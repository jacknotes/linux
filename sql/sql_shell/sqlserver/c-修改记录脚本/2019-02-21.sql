--�޸Ľ�����
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice='2483',profit='254'
where coupno='AS002248853'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice='5460',profit='709'
where coupno='AS002248920'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice='16668',profit='958'
where coupno='AS002250141'

--ɾ��020690���ÿ�
update homsomDB..Trv_Human set IsDisplay=0
where ID in (
select a.ID from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID=(select ID from homsomDB..Trv_UnitCompanies where Cmpid='020690')
and IsDisplay=1 and a.ID not in ('4E0172E5-8669-4A37-87E8-C5D17368B226','19BC6228-6C33-41F2-B3D9-4801FC92F9B9','7236673D-E8AE-4475-9F47-6E09BE991B87'))

select  SUM(totprice),SUM(tax) from Topway..tbcash where cmpcode='019392' and ModifyBillNumber='019392_20180901' and inf=0
select  SUM(totprice) from Topway..tbReti where cmpcode='019392' and ModifyBillNumber='019392_20181001' and inf=0
select FlightOrdinaryInvoiceUsedAmount,* from Topway..AccountStatement where BillNumber='019392_20181001'


--���ۼ���Ϣ
select Mcost,profit,cmpcode,* from Topway..tbcash where coupno='AS002257180'
select Mcost,profit,cmpcode,* from Topway..tbcash where coupno='AS002257215'
select Mcost,profit,cmpcode,* from Topway..tbcash where coupno='AS002257312'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='019989_20190101'

select SubmitState,HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1,HotelSubmitStatus=2
where BillNumber='020158_20190101'

--�޸Ľ�����
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice='7114',profit='3799'
where coupno='AS002253079'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice='2049',profit='185'
where coupno='AS002253266'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice='6291',profit='627'
where coupno='AS002259695'

select * from ApproveBase..HR_AskForLeave_Signer
select * from ApproveBase..HR_Employee where EmployeeName='�ų�'

select route,t_source,tickettype,* from Topway..tbcash 
where cmpcode='019392' 
and datetime>='2018-01-01' and datetime<'2019-01-01' 
and ( t_source like '%����%' or t_source like'%����%' or tickettype like '%����%' or tickettype like'%����%')
and inf=0


--�˵�����
SELECT SubmitState,* FROM Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='019505_20190101'

--���������
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=8887,profit=306
where coupno='AS002260619'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=8887,profit=237
where coupno='AS002260847'

--�޸�UC��(��Ʊ)
select custid AS �ֻ�Ա���,* from topway..tbCusholderM where cmpid ='020617'
select custid,OriginalBillNumber,ModifyBillNumber,* from Topway..tbcash where cmpcode='020617' 
select SettleMentManner AS �ֽ��㷽ʽ,* from topway..HM_SetCompanySettleMentManner where CmpId='020617' and Type=0 and Status=1
select OriginalBillNumber AS ���˵���,ModifyBillNumber AS ���˵���,cmpcode,custid,datetime,* from topway..tbcash where coupno in ('AS002248864')
select HSLastPaymentDate,* from topway..AccountStatement where CompanyCode='020617' order by BillNumber desc

--�޸�UC�ţ�ERP��
select datetime,cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,* from Topway..tbcash
--update topway..tbcash set cmpcode='020617',OriginalBillNumber='020617_20190201',custid='D615400'
 where coupno in ('AS002248864','AS002248975','AS002250298')
 
 --����֧����ʽ���Ը����渶��
 --����
select PayStatus,PayNo,CustomerPayWay,CustomerPayDate from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET PayStatus=1, PayNo='�ֹ��޸�Ϊ��֧��',CustomerPayWay=4,CustomerPayDate=GETDATE() 
where coupno in ('AS002260528')

select PayStatus,PayNo,CustomerPayWay,CustomerPayDate from Topway..tbcash 
--UPDATE Topway..tbcash SET PayStatus=1, PayNo='�ֹ��޸�Ϊ��֧��',CustomerPayWay=4,CustomerPayDate=GETDATE() 
where coupno in ('AS002260528')
 
 select PayStatus,PayNo,CustomerPayWay,CustomerPayDate,* from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET PayStatus=1, PayNo='�ֹ��޸�Ϊ��֧��',CustomerPayWay=4,CustomerPayDate=GETDATE() 
where coupno in ('AS002235524')

select PayStatus,PayNo,CustomerPayWay,CustomerPayDate,* from Topway..tbcash 
--UPDATE Topway..tbcash SET PayStatus=1, PayNo='�ֹ��޸�Ϊ��֧��',CustomerPayWay=4,CustomerPayDate=GETDATE() 
where coupno in ('AS002235524')

 select PayStatus,PayNo,CustomerPayWay,CustomerPayDate,* from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET PayStatus=1, PayNo='�ֹ��޸�Ϊ��֧��',CustomerPayWay=4,CustomerPayDate=GETDATE() 
where coupno in ('AS001446167')

select PayStatus,PayNo,CustomerPayWay,CustomerPayDate,* from Topway..tbcash 
--UPDATE Topway..tbcash SET PayStatus=1, PayNo='�ֹ��޸�Ϊ��֧��',CustomerPayWay=4,CustomerPayDate=GETDATE() 
where coupno in ('AS001446167')
  
  --��Ʊ���۵�����
  delete from Topway..tbTrainUser where TrainTicketNo in( select ID from Topway..tbTrainTicketInfo where CoupNo='RS000019643')
  delete from Topway..tbTrainTicketInfo where CoupNo='RS000019643'
 

