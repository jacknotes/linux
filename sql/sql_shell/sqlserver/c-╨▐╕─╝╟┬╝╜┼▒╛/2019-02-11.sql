--机票账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where BillNumber='020589_20190101'

--修改UC号（机票）
select custid AS 现会员编号,* from topway..tbCusholderM where cmpid ='020705'
select custid,OriginalBillNumber,ModifyBillNumber,* from Topway..tbcash where cmpcode='020705'
select SettleMentManner AS 现结算方式,* from topway..HM_SetCompanySettleMentManner where CmpId='020705' and Type=0 and Status=1
select OriginalBillNumber AS 现账单号,ModifyBillNumber AS 现账单号,cmpcode,custid,datetime,* from topway..tbcash where coupno in ('AS002239504','AS002239505')
select HSLastPaymentDate,* from topway..AccountStatement where CompanyCode='016888' order by BillNumber desc
--修改UC号（ERP）
select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,* from Topway..tbcash
--update topway..tbcash set cmpcode='020705',OriginalBillNumber='020705_20190201',ModifyBillNumber='020705_20190201',custid='D632141'
 where coupno in ('AS002239504','AS002239505')
 
 select CustId,CmpId,Cmpname,* from Topway..tbFiveCoupInfo 
  --update Topway..tbFiveCoupInfo set CustId='D632141',CmpId='020705',Cmpname='上海宇培速通物流有限公司'
  where CoupNo iN('AS002239504','AS002239505')
  
  select CustId,CmpId,Cmpname,* from Topway..tbFiveCoupInfo 
  --update Topway..tbFiveCoupInfo set CustId='D172032',CmpId='016888',Cmpname='三菱重工业（上海）有限公司'
  where CoupNo='AS002217693'
 /*修改UC号（TMS)
 SELECT T2.CoupNo,T1.OrderNo,*
  FROM homsomDB..Intl_BookingOrders T1
  INNER JOIN Topway..tbFiveCoupInfo T2 ON T1.Id=T2.OrderId
  where Id in(select OrderId from Topway..tbFiveCoupInfo where CoupNo in ('AS002217693'))*/
  
   --修改UC号（TMS)
  select CmpId,CompanyName,CustId,* from homsomDB..Intl_BookingOrders 
  --update homsomDB..Intl_BookingOrders set CmpId='020705',CustId='D632141',CompanyName='上海宇培速通物流有限公司'
  where OrderNo in ('IF00023521','IF00023523')
  
  select CmpId,CompanyName,CustId,* from homsomDB..Intl_BookingOrders 
  --update homsomDB..Intl_BookingOrders set CmpId='016888',CustId='D172032',CompanyName='三菱重工业（上海）有限公司'
  where OrderNo='IF00021957'
  
  select CompanyName,* from homsomDB..Intl_BookingPassengers 
  --update homsomDB..Intl_BookingPassengers  set CompanyName='上海宇培速通物流有限公司'
  where BookingOrderId in(Select id from homsomdb..Intl_BookingOrders where OrderNo in ('IF00023521','IF00023523'))
  
  select CompanyName,* from homsomDB..Intl_BookingPassengers 
  --update homsomDB..Intl_BookingPassengers  set CompanyName='三菱重工业（上海）有限公司'
  where BookingOrderId in(Select id from homsomdb..Intl_BookingOrders where OrderNo='IF00021957')
  
  
  
 
--重开打印权限
select prdate,pstatus,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set prdate='1900-01-01',pstatus='0'
where CoupNo='-PTW075586'

--关闭打印权限
select PrintDate,Pstatus,* from topway..HM_tbReti_tbReFundPayMent 
--update topway..HM_tbReti_tbReFundPayMent set PrintDate='2019-02-11',Pstatus='1'
where Id='703647'

--旅游预算单信息修改到单位名下

select Cmpid,CustomerType,Custinfo,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Cmpid='020016',Custinfo='13701908292@@UC@@盛威科(上海)油墨有限公司@13701908292@D536726'
where TrvId='029539'

--申请费来源

select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash set feiyonginfo='申请座位ZYI'
where coupno='AS002238417'