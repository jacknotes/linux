--��Ʊ�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where BillNumber='020589_20190101'

--�޸�UC�ţ���Ʊ��
select custid AS �ֻ�Ա���,* from topway..tbCusholderM where cmpid ='020705'
select custid,OriginalBillNumber,ModifyBillNumber,* from Topway..tbcash where cmpcode='020705'
select SettleMentManner AS �ֽ��㷽ʽ,* from topway..HM_SetCompanySettleMentManner where CmpId='020705' and Type=0 and Status=1
select OriginalBillNumber AS ���˵���,ModifyBillNumber AS ���˵���,cmpcode,custid,datetime,* from topway..tbcash where coupno in ('AS002239504','AS002239505')
select HSLastPaymentDate,* from topway..AccountStatement where CompanyCode='016888' order by BillNumber desc
--�޸�UC�ţ�ERP��
select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,* from Topway..tbcash
--update topway..tbcash set cmpcode='020705',OriginalBillNumber='020705_20190201',ModifyBillNumber='020705_20190201',custid='D632141'
 where coupno in ('AS002239504','AS002239505')
 
 select CustId,CmpId,Cmpname,* from Topway..tbFiveCoupInfo 
  --update Topway..tbFiveCoupInfo set CustId='D632141',CmpId='020705',Cmpname='�Ϻ�������ͨ�������޹�˾'
  where CoupNo iN('AS002239504','AS002239505')
  
  select CustId,CmpId,Cmpname,* from Topway..tbFiveCoupInfo 
  --update Topway..tbFiveCoupInfo set CustId='D172032',CmpId='016888',Cmpname='�����ع�ҵ���Ϻ������޹�˾'
  where CoupNo='AS002217693'
 /*�޸�UC�ţ�TMS)
 SELECT T2.CoupNo,T1.OrderNo,*
  FROM homsomDB..Intl_BookingOrders T1
  INNER JOIN Topway..tbFiveCoupInfo T2 ON T1.Id=T2.OrderId
  where Id in(select OrderId from Topway..tbFiveCoupInfo where CoupNo in ('AS002217693'))*/
  
   --�޸�UC�ţ�TMS)
  select CmpId,CompanyName,CustId,* from homsomDB..Intl_BookingOrders 
  --update homsomDB..Intl_BookingOrders set CmpId='020705',CustId='D632141',CompanyName='�Ϻ�������ͨ�������޹�˾'
  where OrderNo in ('IF00023521','IF00023523')
  
  select CmpId,CompanyName,CustId,* from homsomDB..Intl_BookingOrders 
  --update homsomDB..Intl_BookingOrders set CmpId='016888',CustId='D172032',CompanyName='�����ع�ҵ���Ϻ������޹�˾'
  where OrderNo='IF00021957'
  
  select CompanyName,* from homsomDB..Intl_BookingPassengers 
  --update homsomDB..Intl_BookingPassengers  set CompanyName='�Ϻ�������ͨ�������޹�˾'
  where BookingOrderId in(Select id from homsomdb..Intl_BookingOrders where OrderNo in ('IF00023521','IF00023523'))
  
  select CompanyName,* from homsomDB..Intl_BookingPassengers 
  --update homsomDB..Intl_BookingPassengers  set CompanyName='�����ع�ҵ���Ϻ������޹�˾'
  where BookingOrderId in(Select id from homsomdb..Intl_BookingOrders where OrderNo='IF00021957')
  
  
  
 
--�ؿ���ӡȨ��
select prdate,pstatus,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set prdate='1900-01-01',pstatus='0'
where CoupNo='-PTW075586'

--�رմ�ӡȨ��
select PrintDate,Pstatus,* from topway..HM_tbReti_tbReFundPayMent 
--update topway..HM_tbReti_tbReFundPayMent set PrintDate='2019-02-11',Pstatus='1'
where Id='703647'

--����Ԥ�㵥��Ϣ�޸ĵ���λ����

select Cmpid,CustomerType,Custinfo,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Cmpid='020016',Custinfo='13701908292@@UC@@ʢ����(�Ϻ�)��ī���޹�˾@13701908292@D536726'
where TrvId='029539'

--�������Դ

select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash set feiyonginfo='������λZYI'
where coupno='AS002238417'