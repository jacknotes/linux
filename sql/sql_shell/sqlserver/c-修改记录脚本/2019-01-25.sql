--修改运营经理
select MaintainName,* from Topway..HM_ThePreservationOfHumanInformation 
--update Topway..HM_ThePreservationOfHumanInformation  set MaintainName='王靖雯'
where CmpId in ('019437','019773','018387','019841','020279') and IsDisplay=1 and MaintainType=9

--修改运营经理
select MaintainName,MaintainNumber,* from Topway..HM_ThePreservationOfHumanInformation 
--update Topway..HM_ThePreservationOfHumanInformation  set MaintainName='王静雯',MaintainNumber='0665'
where CmpId in ('019437','019773','018387','019841','020279') and IsDisplay=1 and MaintainType=9

--删除酒店销售单

select * from Topway..tbTrvJS where TrvId='029206' and JsPrice='23888'
delete from Topway..tbHtlcoupYf where CoupNo='PTW075468'

--改到账时间
select * 
--update topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-1-23'
from topway..FinanceERP_ClientBankRealIncomeDetail where money='196295.00' and date='2019-1-22'
 
--旅游结算单信息供应商名称更改
select GysSource,* from topway..tbTrvJS 
--update topway..tbTrvJS  set GysSource='安馒科技新卫士（国际）'
where TrvId='29000' and Id='143029'

--UC019788和UC019786合计销量
--机票
select SUM(totprice) as 合计销量 from topway..tbcash 
where cmpcode in ('019788','019786') and datetime>='2018-01-01' and datetime<'2019-01-01'
and reti=''

--酒店
select SUM(price) as 合计销量 from topway..tbHtlcoupYf 
where prdate>='2018-01-01' and prdate<'2019-01-01' and cmpid in('019788','019786')
--2018年度（即2018年1月1日-2018年12月31日）UC019788深圳寿力亚洲实业有限公司和UC019786苏州寿力气体设备有限公司两家公司合并计算销量（其中包括机票、酒店，机票退票除外）

--酒店销售单重开打印权限
select pstatus,prdate,* from topway..tbHtlcoupYf 
--update topway..tbHtlcoupYf set pstatus='0',prdate='1900-01-01'
where CoupNo='PTW075453'

--修改促销费
select disct,* from topway..tbcash  
--update topway..tbcash set disct='2200'
where coupno='AS002226288'

--机型新增查询
select * from ehomsom..tbPlanetype  where aname='32H'
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('124','空客','A320系列','A320','32H','150-180','窄体')

--（产品部专用）机票供应商来源
select t_source,* from topway..tbcash 
--update topway..tbcash set t_source='HSBSPETI'
where coupno='AS002218771'

--发票额度
select TrainServiceCharge,TrainSpecialInvoiceUsedAmount,TrainOrdinaryInvoiceUsedAmount,* from topway..AccountStatement 
--update topway..AccountStatement set TrainServiceCharge='0',TrainOrdinaryInvoiceUsedAmount='30'
where BillNumber='020507_20190101'
4 
--部门
select DeptCode,DeptName,* from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptCode='技术研发中心'
where DeptCode='技术部'
select DeptName,* from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptName='技术研发中心'
where ID='8'
select * from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptName='技术研发中心 系统运维组'
where ID='9'
select * from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptName='技术研发中心 软件开发组'
where ID='10'
select * from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptName='技术研发中心 软件维护组'
where ID='11'

--人员表
select Department,* from ApproveBase..HR_Employee 
--update ApproveBase..HR_Employee set DeptCode='技术研发中心',Department='技术研发中心'
where DeptCode='技术部'

--请假表

select * from ApproveBase..HR_AskForLeave_Signer 
---update ApproveBase..HR_AskForLeave_Signer set DeptCode='技术研发中心'
where DeptCode='技术部'
	

--促销申请单修改
select pstatus,prdate,CommissionStatus,* from topway..tbDisctCommission 
--update topway..tbDisctCommission  set pstatus='0',prdate='1900-01-01',CommissionStatus='0'
where id='56170'

--机型波音737MAX,所有库都需要更新
select * from ehomsom..tbPlanetype  where aname='7MA'
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('125','波音','737系列','737','7MA','150-180','窄体')

/*UC019333 2018年度数据
1、	以项目编号为准，看看每一个项目编号下面，每个月的费用是多少，年度的总费用是多少？
2、	以单个人员为准，看看每一个每个月的机票费用是多少，年度总计多少？
*/
--项目编号
select convert(varchar(6),datetime,112) 月份,ProjectNo as 项目编号,SUM(totprice) as '费用(销售价)' from Topway..tbcash 
where datetime>='2018-01-01' and datetime<'2019-01-01' and cmpcode='019333' and reti=''
group by ProjectNo,datetime

--单个人员
select convert(varchar(6),datetime,112) 月份,pasname as 乘客姓名,SUM(totprice) as '费用(销售价)' from Topway..tbcash 
where datetime>='2018-01-01' and datetime<'2019-01-01' and cmpcode='019333' and reti=''
group by pasname,datetime

--（业务顾问专用）旅游结算单供应商来源
select GysSource from Topway..tbTrvJS 
--update Topway..tbTrvJS set GysSource='上海硕风国旅（签证'
where TrvId='029347'

select GysSource from Topway..tbTrvJS 
--update Topway..tbTrvJS set GysSource='上海硕风国旅（签证'
where TrvId='029305'

--修改正常积点
select bpprice,* from Topway..tbcash 
--update Topway..tbcash set bpprice='30'
where coupno in('AS002139471','AS002155554')

select convert(varchar(6),ExamineDate,112) 月份,SUM(rtprice-profit-scount2) as 退票费 from Topway..tbReti 
where ExamineDate>='2018-01-01' and ExamineDate<'2019-01-01' and cmpcode='019333'   
AND NOT (totprice=0 AND ISNULL(operDep,'')='机票产品部')        
and status2 not in (1,3,4) --and len(cmpcode)=6        
and CASE WHEN coupno LIKE '000000%' OR coupno = 'AS000000000' OR trvYsId<>0 OR ConventionYsId<>0 THEN '' ELSE cmpcode END <>''
group by ExamineDate



--会务预算单信息
select Sales,OperName,ModifyName,introducer,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Sales='李一帆',OperName='0656李一帆',ModifyName='0656李一帆',introducer='李一帆-0581-运营部'
where ConventionId='955'


--销售价信息
select totprice,disct,* from Topway..tbcash 
--update Topway..tbcash set totprice='1025',disct='500'
where coupno='AS002170978'
select totprice,disct,* from Topway..tbcash 
--update Topway..tbcash set totprice='1105',disct='500'
where coupno='AS002170984'
select totprice,disct,* from Topway..tbcash 
--update Topway..tbcash set totprice='1235',disct='500'
where coupno='AS002204136'

--旅游收款单删除
delete
from Topway..tbTrvKhSk 
where TrvId='028950' and Id in('226697','226698')

/*
UC018309胜科（中国）投资有限公司   从2018年7月1日至今
请帮我们拉我们出过票的账单（酒店、火车票），火车票的地点与上海有关的，（例如：上海-长治|长治-上海|沈阳-上海|上海-沈阳等）
火车票：上海出发和到达上海（其中含上海站，上海虹桥站）
酒店：上海的酒店
*/
--火车票
select OutBegdate as 出发日期,t.CoupNo as 销售单号,t1.Name as 乘客姓名,OutStroke as 线路,OutTrainNo as 列车编号,TotUnitprice as 票价,t.TotPrice as 销售价,TotFuprice as 服务费,
t1.ReturnTicketID as 退票单号,CostCenter as 成本中心
 from Topway..tbTrainTicketInfo t
left join Topway..tbTrainUser t1 on t1.TrainTicketNo=t.ID
where OutBegdate>='2018-07-01' and OutStroke like'%上海%' and CmpId='018309'
order by OutBegdate

--酒店预付
select prdate as 预定时间,hotel as 酒店名称,CityName as 城市,price as 销售价,yhprice as 优惠金额,yf.nights*pcs as 间夜数,pasname as 入住人
from tbHtlcoupYf yf
inner join HotelOrderDB..HTL_Orders od on od.CoupNo=yf.CoupNo
inner join HotelOrderDB..HTL_OrderHotels oh on oh.OrderID=od.OrderID
inner join Emppwd d on d.empname=opername1
where prdate>='2018-07-01' 
and yf.status<>'-2' and CityName like'%上海%' and yf.cmpid='018309'
order by prdate

--酒店自付
select datetime as 预定时间,hotel as 酒店名称,CityName as 城市,price as 销售价,'' as 优惠金额,coup.nights*pcs as 间夜数,pasname as 入住人
from tbHotelcoup coup
inner join HotelOrderDB..HTL_Orders od on od.CoupNo=coup.CoupNo
inner join HotelOrderDB..HTL_OrderHotels oh on oh.OrderID=od.OrderID
inner join Emppwd d on d.empname=opername1
where datetime>='2018-07-01' and CityName like'%上海%' and coup.cmpid='018309'
and coup.status<>'-2'
order by datetime

select GysSource from Topway..tbTrvJS 
--update Topway..tbTrvJS set GysSource='上海硕风国旅（签证'
where TrvId='029258'

--TW团利润超30%，申请技术毕团

 
select Status,ModifyDate,* from topway..tbTravelBudget 
--update topway..tbTravelBudget set Status='14'
where trvid='28096'

/*修改UC号
原UC016448 现UC016713 AS002220450 AS002204208 AS002202607 AS002202584 AS002192940 AS002192876 AS002181643 AS002181572
*/
select custid AS 现会员编号,* from topway..tbCusholderM where cmpid ='016713'

select SettleMentManner AS 现结算方式,* from topway..HM_SetCompanySettleMentManner where CmpId='016713' and Type=0 and Status=1

select OriginalBillNumber AS 现账单号,ModifyBillNumber AS 现账单号,cmpcode,custid,datetime,* from topway..tbcash 
where coupno in ('AS002220450','AS002204208','AS002202607','AS002202584','AS002192940','AS002192876', 'AS002181643','AS002181572')

select HSLastPaymentDate,* from topway..AccountStatement where CompanyCode='016713' order by BillNumber desc

select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,pform,* from topway..tbcash
--update tbcash set cmpcode='016713',OriginalBillNumber='016448_20181226',ModifyBillNumber='NULL',custid='现会员编号',pform='月结(无锡金控))' 
where coupno in ('AS002220450','AS002204208','AS002202607','AS002202584','AS002192940','AS002192876', 'AS002181643','AS002181572')

/*修改UC号
原UC016448 现UC016713 AS002220450 AS002204208 AS002202607 AS002202584 AS002192940 AS002192876 AS002181643 AS002181572 闵娇
*/
select custid AS 现会员编号,* from topway..tbCusholderM where cmpid ='016713'

select SettleMentManner AS 现结算方式,* from topway..HM_SetCompanySettleMentManner where CmpId='016713' and Type=0 and Status=1

select OriginalBillNumber AS 现账单号,ModifyBillNumber AS 现账单号,cmpcode,custid,datetime,* from topway..tbcash 
where coupno in ('AS002220450','AS002204208','AS002202607','AS002202584','AS002192940','AS002192876', 'AS002181643','AS002181572')

select HSLastPaymentDate,* from topway..AccountStatement where CompanyCode='016713' order by BillNumber desc

select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,pform,* from topway..tbcash
--update tbcash set cmpcode='016713',OriginalBillNumber='016448_20181226',ModifyBillNumber='NULL',custid='D174912',pform='月结(无锡金控))' 
where coupno in ('AS002220450','AS002204208','AS002202607','AS002202584','AS002192940','AS002192876', 'AS002181643','AS002181572')

--行程单、特殊票价
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印中文行程单'
where coupno='AS002155795'

select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno='AS002206933'

--修改结算供应商来源
select GysSource from Topway..tbTrvJS 
--update Topway..tbTrvJS set GysSource='上海硕风国旅（签证)'
where TrvId='029305'

select GysSource from Topway..tbTrvJS 
--update Topway..tbTrvJS set GysSource='上海硕风国旅（签证)'
where TrvId='029347'
/*修改UC号
原UC016448 现UC016713 AS002220450 AS002204208 AS002202607 AS002202584 AS002192940 AS002192876 AS002181643 AS002181572 闵娇
*/
select custid AS 现会员编号,* from topway..tbCusholderM where cmpid ='016713'

select SettleMentManner AS 现结算方式,* from topway..HM_SetCompanySettleMentManner where CmpId='016713' and Type=0 and Status=1

select OriginalBillNumber ,ModifyBillNumber,cmpcode,custid,datetime,* from topway..tbcash 
where coupno in ('AS002220450','AS002204208','AS002202607','AS002202584','AS002192940','AS002192876', 'AS002181643','AS002181572')

select BillNumber as 现账单号 ,* from topway..AccountStatement where CompanyCode='016713' order by BillNumber desc

select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,pform,* from topway..tbcash
--update tbcash set cmpcode='016713',OriginalBillNumber='016713_20190101',ModifyBillNumber='NULL',custid='D174912',pform='月结(无锡金控))' 
where coupno in ('AS002220450','AS002204208','AS002202607','AS002202584','AS002192940','AS002192876', 'AS002181643','AS002181572')


--行程单、特殊票价
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印中文行程单'
where coupno='AS002155795'

select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno='AS002206933'

--修改结算供应商来源
select GysSource from Topway..tbTrvJS 
--update Topway..tbTrvJS set GysSource='上海硕风国旅（签证)'
where TrvId='029305'

select GysSource from Topway..tbTrvJS 
--update Topway..tbTrvJS set GysSource='上海硕风国旅（签证)'
where TrvId='029347'
