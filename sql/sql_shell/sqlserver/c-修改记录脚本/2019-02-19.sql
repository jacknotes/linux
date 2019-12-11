--修改供应商来源
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='垫付施中行D'
where coupno='AS002251010'

--UC017275 2018年的出票数据
--国内
select datetime as 出票日期,begdate as 起飞日期,coupno as 销售单号,pasname as 乘客姓名,route as 线路,ride+flightno as 航班号,
tcode+ticketno as 票号,price as 销售单价,tax as 税收,xfprice as 前返,totprice as 销售价,Department as 部门,CostCenter as 成本中心,
nclass as 舱位,ProjectNo as 项目编号
from Topway..tbcash 
where datetime>='2018-01-01' and datetime<'2019-01-01'
and reti=''
and cmpcode='017275'
and inf=0
and tickettype='电子票'
order by datetime

--国际
select datetime as 出票日期,begdate as 起飞日期,coupno as 销售单号,pasname as 乘客姓名,route as 线路,ride+flightno as 航班号,
tcode+ticketno as 票号,price as 销售单价,tax as 税收,xfprice as 前返,totprice as 销售价,Department as 部门,CostCenter as 成本中心,
nclass as 舱位,ProjectNo as 项目编号
from Topway..tbcash 
where datetime>='2018-01-01' and datetime<'2019-01-01'
and reti=''
and cmpcode='017275'
and inf=1
and tickettype='电子票'
order by datetime

--退改
select datetime as 出票日期,begdate as 起飞日期,coupno as 销售单号,pasname as 乘客姓名,route as 线路,ride+flightno as 航班号,
tcode+ticketno as 票号,price as 销售单价,tax as 税收,xfprice as 前返,totprice as 销售价,Department as 部门,CostCenter as 成本中心,
nclass as 舱位,ProjectNo as 项目编号
from Topway..tbcash 
where datetime>='2018-01-01' and datetime<'2019-01-01'
and reti=''
and cmpcode='017275'
and inf=1
and tickettype='电子票'
and ( t_source like ('%改期%') or route like ('%改期%') or t_source like ('%退票%') or route like ('%退票%'))
order by datetime

--结算价信息
select sprice1,xj1,tax,totprice,status,amount,owe,totprice,* from Topway..tbcash 
--update Topway..tbcash set amount=totprice,owe=totprice
where coupno='AS002252288'

--可以申请国内特殊票价且无国内机票特殊线路（在合作）
select u.Cmpid as UC ,u.Name as 单位名称 from homsomDB..Trv_UnitCompanies u
left join Topway..tbCompanyM t on t.cmpid=u.Cmpid
where t.hztype  not in (0,4)
and u.ID not in (SELECT UnitCompanyID FROM homsomDB..Trv_FlightAdvancedPolicies WHERE   Name='国内机票特殊线路')
and u.IsSepPrice=1

SELECT  UnitCompanyID FROM homsomDB..Trv_FlightNormalPolicies 
select Name,UnitCompanyID,* from homsomdb..Trv_FlightTripartitePolicies

--单位顾问支付权限
select UPPayAuthId,*from homsomDB..Trv_UnitPersons
  --update homsomDB..Trv_UnitPersons set UPPayAuthId='24DF7569-2148-4D69-806F-751B3F777A2F'
  where CompanyID='BB6A117C-8F55-4992-AAD8-F279E6762775' 
  
--火车票销售单作废
delete  from Topway..tbTrainTicketInfo where CoupNo in('RS000019522','RS000019518')
delete from Topway..tbTrainUser where TrainTicketNo in(select ID from Topway..tbTrainTicketInfo where CoupNo in('RS000019522','RS000019518'))

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='深圳市道旅旅游科技股份有限公司'
where CoupNo='PTW076126'

select Signer,* from ApproveBase..App_DefineBase 
--update ApproveBase..App_DefineBase set Signer=0601
where Signer=0671

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020181_20190101' 

--修改退票审核时间
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti set ExamineDate='1900-01-01'
where reno='0427503'

