--删除酒店销售单

select Jstatus,* from Topway..tbTrvJS 
--update Topway..tbTrvJS set Jstatus='4'
where TrvId='029206' and JsPrice='23888'
delete from Topway..tbHtlcoupYf where CoupNo='PTW075468'

--修改运营经理
select MaintainName,MaintainNumber,* from Topway..HM_ThePreservationOfHumanInformation 
--update Topway..HM_ThePreservationOfHumanInformation  set MaintainName='王静雯',MaintainNumber='0665'
where CmpId in ('019437','019773','018387','019841','020279') and IsDisplay=1 and MaintainType=9

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

--酒店销售单重开打印权限
select pstatus,prdate,* from topway..tbHtlcoupYf 
--update topway..tbHtlcoupYf set pstatus='0',prdate='1900-01-01'
where CoupNo='PTW075453'

--修改促销费
select disct,* from topway..tbcash  
--update topway..tbcash set disct='2200'
where coupno='AS002226288'

--发票额度
select TrainServiceCharge,TrainSpecialInvoiceUsedAmount,TrainOrdinaryInvoiceUsedAmount,* from topway..AccountStatement 
--update topway..AccountStatement set TrainServiceCharge='0',TrainOrdinaryInvoiceUsedAmount='30'
where BillNumber='020507_20190101'

--（产品部专用）机票供应商来源
select t_source,* from topway..tbcash 
--update topway..tbcash set t_source='HSBSPETI'
where coupno='AS002218771'

--机型新增查询
select * from ehomsom..tbPlanetype  where aname='32H'
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('124','空客','A320系列','A320','32H','150-180','窄体')

--公司部门修改
--部门
select DeptCode,DeptName,* from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptCode='技术研发中心'
where DeptCode='技术研发中心'
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

--有后返金额订单
select sum(bpprice) as 总后返金额,COUNT(*) as 退票张数 from topway..tbcash 
where bpprice>'0' and datetime >='2018-01-01' and datetime<'2019-01-01' and fuprice>bpprice and reti<>''
