--撤销闭团及闭团相关信息（旅游）
select Status,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Status='14'
where TrvId='29527'

--保险小数差调整
select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash set sprice1='2',totsprice='2'
where coupno='AS002242444'

--修改退票状态
select cmpcode,status2,* from Topway..tbReti 
--update Topway..tbReti set status2='3'
where reno='0426131'

--火车票销售单作废
delete from Topway..tbTrainTicketInfo where CoupNo='RS000019450'
delete from Topway..tbTrainUser where TrainTicketNo=(select ID from Topway..tbTrainTicketInfo where CoupNo='RS000019450')

--修改UC020554注册日
select indate,indateA,* from Topway..tbCompanyM 
--update Topway..tbCompanyM  set indate='2019-01-03 11:50:00.000'
where cmpid='020554'
select RegisterMonth,AdditionMonthA,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set RegisterMonth='01 03 2019 11:50AM'
where Cmpid='020554'

--修改新增月
select indate,depdate0,* from Topway..tbCompanyM 
--update Topway..tbCompanyM  set depdate0='2019-02-03 11:50:00.000'
where cmpid='020554'
select RegisterMonth,AdditionMonthA,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set AdditionMonthA='02 03 2019 11:50AM'
where Cmpid='020554'


--增加机型
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('129','空客','A319系列','A319','31A','124-142','窄体')
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('130','空客','A330系列','A330','33N','295-335','宽体')
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('131','空客','A320系列','A320','31E','148-160','窄体')

--修改UC号（机票）
select custid AS 现会员编号,* from topway..tbCusholderM where cmpid ='019885' and mobilephone='13281011110'
select custid,OriginalBillNumber,ModifyBillNumber,* from Topway..tbcash where cmpcode='019885'
select SettleMentManner AS 现结算方式,* from topway..HM_SetCompanySettleMentManner where CmpId='019885' and Type=0 and Status=1
select OriginalBillNumber AS 现账单号,ModifyBillNumber AS 现账单号,cmpcode,custid,datetime,* from topway..tbcash where coupno in ('AS002250645')
select HSLastPaymentDate,* from topway..AccountStatement where CompanyCode='019885' order by BillNumber desc

--修改UC号（ERP）
select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,* from Topway..tbcash
--update topway..tbcash set cmpcode='',OriginalBillNumber='',ModifyBillNumber=''
 where coupno in ('AS002250645')
 
 --国内公里数


--结算差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='12220',profit='547'
where coupno='AS002250774'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='10605',profit='1130'
where coupno='AS002248992'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where BillNumber='018734_20190101'

--打印
select PrDate,Pstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set PrDate='1900-01-01',Pstatus='0'
where TrvId='029465' and price='7854'

--打印
select Pstatus,PrintDate,* from topway..HM_tbReti_tbReFundPayMent 
--update topway..HM_tbReti_tbReFundPayMent set Pstatus='1',PrintDate='2019-02-18'
where Id='703647'

--账单撤销
select HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set HotelSubmitStatus=2
where BillNumber in('017275_20181116','017275_20181216')

select * from topway..tmpdata