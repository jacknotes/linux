select top 10 * from Topway..tbCompanyM 

--常旅客数量
--单位
select COUNT(*) from homsomDB..Trv_UnitPersons where UserName<>''

--唐旭东改成陈萍
select * from ApproveBase..App_DefineBase 
--update ApproveBase..App_DefineBase set Signer='0601'
where  Signer='0567'
select * from ApproveBase..HR_AskForLeave_Signer 
--update ApproveBase..HR_AskForLeave_Signer  set Signer='0601'
where  Signer='0567'

--会务收款单信息
select Pstatus,PrDate,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set Pstatus='0',PrDate='1900-01-01'
where ConventionId='1230' and Id='2488'

--更改支付方式（自付、垫付）
--核销
update Topway..tbcash set PayNo=TCPayNo,TCPayNo='',PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate, TcPayDate=''
where coupno in('AS001810652','AS001812250','AS001821986')

SELECT AdvanceStatus,PayStatus,PayNo,TCPayNo,CustomerPayWay,* FROM Topway..tbcash 
--update Topway..tbcash set AdvanceStatus=0
WHERE coupno IN('AS001812250','AS001810652')

select PayStatus,AdvanceStatus,* from Topway..tbFiveCoupInfo 
--update Topway..tbFiveCoupInfo set PayStatus=1
where CoupNo in ('AS001810652','AS001812250')

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


----国际支付信息变更
--select * from Topway..PayDetail
----UPDATE Topway..PayDetail SET payperson='1' 
--WHERE  ysid IN(SELECT CONVERT(nvarchar ,fiveno) as fno FROM Topway..tbFiveCoupInfo 
--WHERE CoupNo IN  ('AS001810652','AS001812250'))

--select top 10 ysid,* from Topway..PayDetail where ysid in('2060396')

------更新出票信息中的支付号
--update tbcash set PayNo=( select Pnum from PayDetail 
--where  PayDetail.ysid=tbcash.sixnoid  and PayDetail.Pnum is not null
--) where coupno IN  ('AS001810652','AS001812250')

--select sixnoid,* from Topway..tbcash where coupno IN  ('AS001810652','AS001812250')
--select ysid,Pnum from Topway..PayDetail where ysid in('2060396','2060475')


----更新国际销售单中支付号
--update tbFiveCoupInfo set PayNo=( select Pnum from PayDetail 
--where  CONVERT(nvarchar, tbFiveCoupInfo.fiveno)=PayDetail.ysid and PayDetail.Pnum is not null
--) where coupno IN  ('AS001810652','AS001812250')

--update tbFiveCoupInfo set PayNo=( select Pnum from PayDetail 
--where  CONVERT(nvarchar, tbFiveCoupInfo.fiveno)=PayDetail.ysid and PayDetail.Pnum is not null
--) where coupno IN  ('AS001810652','AS001812250')



--酒店
update [Topway].[dbo].[tbHtlcoupRefund] set AdvanceMethod=PayMethod,AdvanceStatus=PayStatus,AdvancePayNo=PayNo,AdvanceDate=PaySubmitDate, PayMethod=0,PayStatus=0,PayNo=null,PaySubmitDate=null  
where CoupNo='PTW037450';

 update [Topway].[dbo].[tbhtlyfchargeoff] set cwstatus=0,owe=vpay,vpay=0,opername1='',vpayinfo='',oth2=''
  where coupid in (select id  from [Topway].[dbo].tbHtlcoupYf where CoupNo='PTW037450');
  
  
  update [HotelOrderDB].[dbo].[HTL_Orders] set [AdvanceNumber]='0316',[AdvanceName]='周婧',[AdvanceStatus]=3,[AdvanceDate]=PayDate,PayStatus=0,PayDate=null
  where CoupNo='PTW037450';
  
  update [HotelOrderDB].[dbo].[HTL_OrderSettlements] set AdvancePayNo=PayNo,AdvanceMethod=PayMethod,PayMethod=null,PayNo=null 
  where OrderID in (select OrderID from [HotelOrderDB].[dbo].[HTL_Orders] where CoupNo='PTW037450');

--火车票销售单作废
delete  from Topway..tbTrainUser where TrainTicketNo in( select ID from Topway..tbTrainTicketInfo where CoupNo in('RS000019714','RS000019715'))
delete  from Topway..tbTrainTicketInfo where CoupNo in('RS000019714','RS000019715')

--机票业务顾问信息
select sales,SpareTC from Topway..tbcash 
--update Topway..tbcash  set sales='杜鹏媛',SpareTC='杜鹏媛'
where coupno='AS001438064'

--重开打印权限
select Pstatus,PrDate,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set Pstatus=0,PrDate='1900-01-01'
where ConventionId='967'

--国内订单支付信息
update homsomDB..Trv_TktBookings set PayNo=TCPayNo,TCPayNo='',PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate, TcPayDate=''
where ID in (select b.ItktBookingID from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber='AS001821986')
--出票支付信息
update Topway..tbcash set PayNo=TCPayNo,TCPayNo='',PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate, TcPayDate=''
where coupno='AS001821986'
--支付信息详情
update  topway..PayDetail set payperson=1 where ysid in (select cast(b.ItktBookingID as varchar(40)) from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber='AS001821986')



--修改操作顾问
select SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set SpareTC='何洁'
where coupno in ('AS001479875','AS001569919','AS001494117','AS001569917','AS001534316','AS001435161')

--已经垫付显示改未垫付
SELECT AdvanceStatus,PayStatus,* FROM Topway..tbcash 
--update Topway..tbcash set AdvanceStatus=0
WHERE coupno IN('AS001812250','AS001810652')


SELECT AdvanceStatus,PayStatus,* FROM Topway..tbcash 
--update Topway..tbcash set AdvanceStatus=0
WHERE coupno in('AS001446167')

--2019-02-21添加的常飞旅客
 SELECT 
ISNULL(c.Cmpid,'') AS 单位编号,
ISNULL(c.Name,'') AS 单位名称,
ISNULL(h.Name,'') AS 中文名,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS 英文名,
h.Mobile AS 手机号码,
ISNULL((SELECT TOP 1 empname FROM Topway..Emppwd WHERE idnumber=h.CreateBy),'') AS 差旅顾问,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS 运营经理
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate>='2019-02-21' AND h.CreateDate<'2019-02-22' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT idnumber FROM Topway..Emppwd WHERE dep='运营部' AND idnumber NOT IN('00002','00003','0421'))
UNION ALL

SELECT 
ISNULL(c.Cmpid,'') AS 单位编号,
ISNULL(c.Name,'') AS 单位名称,
ISNULL(h.Name,'') AS 中文名,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS 英文名,
ISNULL(h.Mobile,'') AS 手机号码,
h.CreateBy AS 差旅顾问,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS 运营经理
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate>='2019-02-21' AND h.CreateDate<'2019-02-22' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT empname FROM Topway..Emppwd WHERE dep='运营部' AND empname NOT IN('homsom','恒顺旅行','运营培训测试'))

--机票
SELECT t1.RecordNumber,t5.Name ,NodeID
FROM homsomDB..Trv_DomesticTicketRecord t1
left join homsomDB..Trv_PnrInfos t2 on t2.ID=t1.PnrInfoID
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t2.ItktBookingID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='审批'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.RecordNumber in 
('AS002220025',
'AS002220565',
'AS002221139',
'AS002224817',
'AS002228886',
'AS002228985',
'AS002228993',
'AS002229123',
'AS002229246',
'AS002229825',
'AS002230091',
'AS002230264',
'AS002230942',
'AS002231169',
'AS002231676',
'AS002231900',
'AS002231958',
'AS002233613',
'AS002233679',
'AS002233741',
'AS002233824',
'AS002234245',
'AS002236930',
'AS002237266',
'AS002237340',
'AS002237495',
'AS002239262',
'AS002240001',
'AS002240045',
'AS002240851',
'AS002240851',
'AS002240857',
'AS002240859',
'AS002240861',
'AS002241109',
'AS002241154',
'AS002241156',
'AS002241588',
'AS002241588',
'AS002246321',
'AS002246629',
'AS002246629',
'AS002247691',
'AS002247693',
'AS002247693',
'AS002247759',
'AS002250549',
'AS002250936',
'AS002251098',
'AS002252021',
'AS002252727',
'AS002252913',
'AS002252977',
'AS002253543',
'AS002253552',
'AS002253697',
'AS002199713') and NodeType=110 and NodeID=110

--一级 NodeType=110 and NodeID=110
--二级 NodeType=110 and NodeID=111

--酒店
SELECT CoupNo,t5.Name FROM HotelOrderDB..HTL_Orders t1
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t1.OrderID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='审批'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.CoupNo in 
( 'PTW075924') and NodeType=110 and NodeID=111

--修改废票结算价
select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=10,totsprice=10
where coupno='AS000000000' and tcode+ticketno='0573551681671'

--合计销量
select BillAmount,HBillAmount,TrainBillMoney, * from Topway..AccountStatement 
where BillNumber in('019392_20180301')

--国内机票销量
select SUM(price) from Topway..tbcash where ModifyBillNumber in('019392_20180301')
and inf=0
AND tickettype NOT IN ('改期费', '升舱费','改期升舱')

--税收
select SUM(tax) from Topway..tbcash where ModifyBillNumber in('019392_20180301')
and inf=0
AND tickettype NOT IN ('改期费', '升舱费','改期升舱')

--退票
select SUM(totprice) from Topway..tbReti where ModifyBillNumber in('019392_20180301') and inf=0

--改期升舱
select SUM(totprice) from Topway..tbcash 
where ModifyBillNumber in('019392_20180301') and inf=0
and (tickettype like'%改期%' or tickettype like'升舱')


--国际机票销量
select SUM(price) from Topway..tbcash where ModifyBillNumber in('019392_20180301')
and inf=1
AND tickettype NOT IN ('改期费', '升舱费','改期升舱')

--国际税收
select SUM(tax) from Topway..tbcash where ModifyBillNumber in('019392_20180301')
and inf=1
AND tickettype NOT IN ('改期费', '升舱费','改期升舱')

--国际退票
select SUM(totprice) from Topway..tbReti where ModifyBillNumber in('019392_20180301') and inf=1

--国际改期升舱
select SUM(totprice) from Topway..tbcash 
where ModifyBillNumber in('019392_20180301') and inf=1
and (tickettype like'%改期%' or tickettype like'%升舱%' or route like'%改期%' or route like'%升舱%' or t_source like'%改期%' or t_source like'%升舱%'  )

--修改UC号（机票）
select custid AS 现会员编号,* from topway..tbCusholderM where cmpid ='018541' and custid='D564307'
select custid AS 现会员编号,* from topway..tbCusholderM where cmpid ='016448'
select custid,OriginalBillNumber,ModifyBillNumber,* from Topway..tbcash where cmpcode='016448'
select SettleMentManner AS 现结算方式,* from topway..HM_SetCompanySettleMentManner where CmpId='016448' and Type=0 and Status=1
select OriginalBillNumber AS 现账单号,ModifyBillNumber AS 现账单号,cmpcode,custid,datetime,* from topway..tbcash where coupno in ('AS002259048','AS002259013')
select HSLastPaymentDate,* from topway..AccountStatement where CompanyCode='016448' order by BillNumber desc
--修改UC号（ERP）

select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,Department,CostCenter,pform,* from Topway..tbcash
--update topway..tbcash set cmpcode='016448',OriginalBillNumber='016448_20190126',custid='D168021',Department='技术中心',CostCenter='CA',pform='月结(微浮建行)'
 where coupno in ('AS002259048','AS002259013')
 
 --会务预算单信息
 select Sales,OperName,* from Topway..tbConventionBudget 
 --update Topway..tbConventionBudget  set Sales='唐镇涛',OperName='0598唐镇涛'
 where ConventionId in('1042','1047','1048','1049','1187','1233','1261','1262','1263')