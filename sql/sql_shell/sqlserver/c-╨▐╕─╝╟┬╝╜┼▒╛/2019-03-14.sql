select cmpcode,* from Topway..tbcash where coupno='AS002314083'

--机票业务顾问信息
SELECT sales,SpareTC,* froM Topway..tbcash 
--UPDATE Topway..tbcash  SET sales='章志强',SpareTC='章志强'
WHERE coupno='AS002133875'

--结算价信息
select sprice1,route,pform,* FROM Topway..tbcash 
--update Topway..tbcash set route='PVG-HKG 退票费'
WHERE coupno='AS002314083'

--结算信息
select sprice1,route,pform,* FROM Topway..tbcash 
--update Topway..tbcash set route='PVG-HKG'
WHERE coupno='AS002314083' AND ticketno='3554297088'

--修改供应商
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='垫付施中行I'
where coupno='AS002311711'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='ZSBSPETI'
where coupno='AS002302422'

--单位客户授信额度调整
select SX_BaseCreditLine ,SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement set SX_TotalCreditLine=90000
where BillNumber='018113_20190301'

--修改UC号（机票）
select custid AS 现会员编号,* from topway..tbCusholderM where cmpid ='019539' and custname='柳静梅'
select custid,OriginalBillNumber,ModifyBillNumber,* from Topway..tbcash where cmpcode='019539'
select SettleMentManner AS 现结算方式,* from topway..HM_SetCompanySettleMentManner where CmpId='019539' and Type=0 and Status=1
select OriginalBillNumber AS 现账单号,ModifyBillNumber AS 现账单号,cmpcode,custid,datetime,* from topway..tbcash where coupno in ('AS002315886 ','AS002315886 ')
select HSLastPaymentDate,* from topway..AccountStatement where CompanyCode='019539' order by BillNumber desc
select Cmpname,* from Topway..tbFiveCoupInfo where CmpId='019539'and Ndate>'2019-03-01'
--修改UC号（ERP）
select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,pform,xfprice,* from Topway..tbcash
--update topway..tbcash set cmpcode='019539',OriginalBillNumber='019539_20190301',custid='D514200',pform='月结(汇涵)'
 where coupno in ('AS002315886')
 
 select CustId,CmpId,Cmpname,* from Topway..tbFiveCoupInfo 
  --update Topway..tbFiveCoupInfo set CustId='D514200',CmpId='019539',Cmpname='上海天祥质量技术服务有限公司'
  where CoupNo iN('AS002315886')
  
 /*修改UC号（TMS)
 SELECT T2.CoupNo,T1.OrderNo,*
  FROM homsomDB..Intl_BookingOrders T1
  INNER JOIN Topway..tbFiveCoupInfo T2 ON T1.Id=T2.OrderId
  where Id in(select OrderId from Topway..tbFiveCoupInfo where CoupNo in ('AS002315886'))*/
  
   --修改UC号（TMS)
  select CmpId,CompanyName,CustId,* from homsomDB..Intl_BookingOrders 
  --update homsomDB..Intl_BookingOrders set CmpId='020705',CustId='D632141',CompanyName='上海天祥质量技术服务有限公司'
  where OrderNo in ('IF00027480')
  
  select CmpId,CompanyName,CustId,* from homsomDB..Intl_BookingOrders 
  --update homsomDB..Intl_BookingOrders set CmpId='016888',CustId='D172032',CompanyName='上海天祥质量技术服务有限公司'
  where OrderNo='IF00027480'
  
  select CompanyName,* from homsomDB..Intl_BookingPassengers 
  --update homsomDB..Intl_BookingPassengers  set CompanyName='上海天祥质量技术服务有限公司'
  where BookingOrderId in(Select id from homsomdb..Intl_BookingOrders where OrderNo in ('IF00027480'))
  
  
  --会务收款单
  select Price,* from Topway..tbConventionKhSk 
  --update Topway..tbConventionKhSk set Price='34344.34'
  where ConventionId='1390'
  
  --修改结算价差额
  select totsprice,profit,* from Topway..tbcash 
  --update Topway..tbcash  set totsprice=6928,profit=2802
  where coupno='AS002310356'
  
  --2019年2月11日至2019年2月26日 备注含“冒退票”
  --票号、销售单号、供应商来源、退票单号、提交日期、审核日期、航空公司退票费、收客户退票金额、出票操作业务顾问、出票业务顾问、提交退票业务顾问、备注
 select  tcode+t.ticketno 票号,t.coupno 销售单号,t_source  供应商来源,reno 退票单号,edatetime 提交日期,ExamineDate 审核日期,
 scount2 航空公司退票费,rtprice 收客户退票金额,c.SpareTC 出票操作业务顾问,c.sales 出票业务顾问,opername 提交退票业务顾问,t.info 备注
 from Topway..tbReti t
 left join Topway..tbcash c on t.reno=c.reti
 where t.info like'%冒退票%'
 and ExamineDate>='2019-02-11'
 and ExamineDate<'2019-02-27'
 
 
 --重开打印权限
 select Pstatus,PrDate,* from Topway..tbConventionKhSk 
 --update Topway..tbConventionKhSk  set Pstatus=0,PrDate='1900-01-01'
 where ConventionId='1390' and Id='2589'
 
 select pstatus,prdate,* from Topway..tbSettlementApp 
 --update Topway..tbSettlementApp set pstatus=0,prdate='1900-01-01'
 where id='109726'
 
--火车票销售单作废
select * 
--delete
 from Topway..tbTrainTicketInfo where CoupNo in ('RS000020607','RS000020608','RS000020609')
select * 
--delete
from Topway..tbTrainUser where TrainTicketNo in (select ID from Topway..tbTrainTicketInfo where CoupNo in ('RS000020607','RS000020608','RS000020609'))

--打印权限
select Pstatus,PrDate,dzHxDate,* from Topway..tbTrvKhSk where Id='227155'