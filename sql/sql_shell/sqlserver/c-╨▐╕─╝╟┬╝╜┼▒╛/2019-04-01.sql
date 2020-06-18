--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='丁琳',SpareTC='丁琳'
where coupno in('AS002288996','AS002289073',
'AS002289189','AS002294028','AS002336983')

select * from Topway..tbTravelBudget where TrvId='29360'
select * from Topway..tbTrvCoup where TrvId='29360'

--改发票抬头
select * from Topway..CompanyInvoiceInfoDetail where InvoicesTitle='上海宇培实业（集团）有限公司'
update Topway..CompanyInvoiceInfoDetail set InvoicesTitle='上海宇培实业（集团）有限公司',TaxIdentiNum='91310000679334524W',BankAccount='32443908010084455',BankName='上海农村商业银行七宝支行',ContactTel=' 021-33282273',TaxRegAddr='上海市闵行区申昆路1899号' 
where InvoicesTitle='技术部神圣化'

select * from Topway..CompanyInvoiceInfoDetail where InvoicesTitle='上海长濑贸易有限公司'
select * from Topway..CompanyInvoiceInfoDetail
--update Topway..CompanyInvoiceInfoDetail set InvoicesTitle='上海长濑贸易有限公司',TaxIdentiNum='91310115607377824L',BankAccount='',BankName='',ContactTel='',TaxRegAddr='' 
where InvoicesTitle='技术部神圣化'--7779

--（产品专用）保险结算价信息
select sprice1,totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=2
where coupno in('AS002330982','AS002334597','AS002335477','AS002341327')

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=31090,profit=3557
where coupno='AS002357648'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=2645,profit=1018
where coupno='AS002358223'


IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as 单位编号,t1.cmpname as 单位名称
,(case CustomerType when 'A' then '差旅单位客户' when 'C' then '旅游单位客户' else '' end) as 单位类型
,(CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END) as 合作状态
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as 开发人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as 客户主管
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as 维护人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as 差旅业务顾问
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as 旅游业务顾问
,indate
into #cmp1
from tbCompanyM t1
left join homsomdb..Trv_UnitCompanies t4 on t1.cmpid=t4.Cmpid
--开发人
left join homsomDB..Trv_UnitCompies_Sales t5 on t4.ID=t5.UnitCompayID
--客户主管
left join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t4.ID=t6.UnitCompanyID
--维护人
left join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.UnitCompanyID=t4.ID
--旅游业务顾问
left join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t7.TrvUnitCompanyID=t4.ID
--差旅业务顾问
left join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t8.TktUnitCompanyID=t4.ID
--人员信息
left join homsomDB..SSO_Users t9 on
t9.ID=t5.EmployeeID and t9.ID=t6.EmployeeID and t9.ID=t8.TktTCID and t9.ID=t7.TrvTCID 
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid


select c.ticketno,cm.indate,cm.单位编号,cm.开发人 from #cmp1 cm
left join Topway..tbcash c on cm.单位编号=c.cmpcode
where ticketno in('3541111931',
'3542740508',
'3542740507',
'5378191302',
'5378191302',
'3542738722',
'3543691117',
'3405979932',
'3570265325',
'3404419500',
'3405979932',
'3570265325',
'3570264714',
'2061820751',
'3407694445',
'3405976593',
'3407696238',
'3541109354',
'3571075671',
'3571077102',
'3571077107',
'3572376770')

--注册日期 
select indate,cmpid from Topway..tbCompanyM where cmpid in ('017505','017505','017920','017189')

--更改支付方式（自付、垫付）
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from homsomDB..Trv_TktBookings
--update homsomDB..Trv_TktBookings set TCPayNo=PayNo,PayNo=null,AdvanceStatus=PayStatus,PayStatus=0,TcPayWay=CustomerPayWay,CustomerPayWay=0,TcPayDate=CustomerPayDate, CustomerPayDate=null
where ID in (select b.ItktBookingID from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS002359568'))
--出票支付信息
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set TCPayNo=PayNo,PayNo=null,AdvanceStatus=PayStatus,PayStatus=0,TcPayWay=CustomerPayWay,CustomerPayWay=0,TcPayDate=CustomerPayDate,CustomerPayDate=null
where coupno in('AS002359568')

--修改闭团时间
select OperDate,* from Topway..tbTrvCoup 
--update Topway..tbTrvCoup set OperDate='2019-03-30'
where TrvId='29577'

select ModifyDate,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set ModifyDate='2019-03-30'
where TrvId='29577'

--修改供应商来源
select t_source,* from Topway..tbcash  
--update Topway..tbcash  set t_source='ZSBSPETI'
where coupno='AS002337323'

--销售单匹配舱位
SELECT c.coupno,(SELECT TOP 1 i.cabintype 
	FROM ehomsom..tbInfCabincode i 
	WHERE	c.ride=i.code2 AND c.nclass=i.cabin 
										AND i.begdate<=c.begdate AND i.enddate>=c.begdate
	ORDER BY id DESC
	) AS cabinType
fROM Topway..tbcash  c
where c.coupno in
('AS002285373',
'AS002286001',
'AS002288988',
'AS002289455',
'AS002290418',
'AS002290503',
'AS002290565',
'AS002295121',
'AS002295137',
'AS002295921',
'AS002296004',
'AS002300678',
'AS002304883',
'AS002314273',
'AS002314332',
'AS002316778',
'AS002328750',
'AS002328832',
'AS002330040',
'AS002331183',
'AS002331187',
'AS002337714',
'AS002343291',
'AS002347575',
'AS002351469',
'AS002351476',
'AS002351482',
'AS002352456',
'AS002352456',
'AS002354256',
'AS002354262',
'AS002355933',
'AS002355937',
'AS002356067',
'AS002356524',
'AS002357258',
'AS002358853',
'AS002360940',
'AS002360942')

--酒店销售单匹配差旅目的
SELECT    CoupNo,Purpose
FROM     HotelOrderDB..HTL_Orders
where coupno in
('PTW077149',
'PTW077194',
'PTW077485',
'PTW077591',
'PTW077685',
'PTW077822',
'PTW078025',
'PTW078125',
'PTW078196',
'PTW078230',
'PTW078337',
'PTW078543',
'PTW078541',
'PTW078563',
'PTW078756',
'PTW078752',
'PTW078761',
'PTW078885')

 --旅游收款单信息
 select Skstatus,* from Topway..tbTrvKhSk 
 --update Topway..tbTrvKhSk  set Skstatus=2
 where TrvId='29784' and Id='227527'
 
 --修改退票信息
 select opername, * from Topway..tbReti 
 --update Topway..tbReti  set opername='吴玲申'
 where reno in('0430499','0430497')
 
 --结算价差额
 select totsprice,profit,* from Topway..tbcash 
 --update Topway..tbcash  set totsprice=21704,profit=5211
 where coupno='AS002360948'
 
 --修改退票审核日期
 select ExamineDate,* from Topway..tbReti 
 --update Topway..tbReti set ExamineDate='2019-03-26'
 where reno in ('0430497','0430499')
 
 --账单信息
 --select * from Topway..HM_CompanyAccountInfo where CmpId='020721'
 --select * from Topway..AccountStatement where CompanyCode='020721' order by BillNumber desc
 
 select SEndDate,* from Topway..HM_SetCompanySettleMentManner 
 --update Topway..HM_SetCompanySettleMentManner set SEndDate='2019-03-31',Status=-1
 where CmpId='020721' and Status=1
 
  select SStartDate,* from Topway..HM_SetCompanySettleMentManner 
 --update Topway..HM_SetCompanySettleMentManner set SStartDate='2019-04-01',Status=1
 where CmpId='020721' and Status=2
 
 SELECT EndDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
 --update homsomdb..Trv_UCSettleMentTypes set EndDate='2019-03-31',Status=-1
 WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '020721') and Status=1
 
  SELECT StartDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
 --update homsomdb..Trv_UCSettleMentTypes set StartDate='2019-04-01',Status=1
 WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '020721') and Status=2
 
 --修改退票审核日期
 select ExamineDate,* from Topway..tbReti 
 --update Topway..tbReti set ExamineDate='2019-3-25'
 where reno='0430444'
 
  select ExamineDate,* from Topway..tbReti 
 --update Topway..tbReti set ExamineDate='2019-3-29'
 where reno='0430829'
 
 
 --账单撤销
 select TrainBillStatus,* from Topway..AccountStatement 
 --update Topway..AccountStatement set TrainBillStatus=1
 where BillNumber in('020261_20190301','019442_20190301')
 