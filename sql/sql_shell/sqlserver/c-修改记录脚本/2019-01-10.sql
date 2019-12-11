
select sum(fuprice) as 服务费合计 from Topway..tbcash where cmpcode='020459' and datetime<'2018-12-31'

select * from Topway..tbCompanyM where cmpname like'康宝%%'


--火车票销售价信息,修改销售单价和合计价

SELECT TotSprice,TotPrice,* FROM topway..tbTrainTicketInfo 
--update topway..tbTrainTicketInfo  set TotSprice='335',TotPrice='355'
WHERE (CoupNo='RS000018597')
SELECT RealPrice,* FROM topway..tbTrainUser 
--update topway..tbTrainUser set RealPrice='335'
WHERE TrainTicketNo IN (SELECT ID FROM topway..tbTrainTicketInfo WHERE CoupNo='RS000018597')

SELECT TotSprice,TotPrice,* FROM topway..tbTrainTicketInfo 
--update topway..tbTrainTicketInfo  set TotSprice='139.5',TotPrice='159.5'
WHERE (CoupNo='RS000018591')
SELECT RealPrice,* FROM topway..tbTrainUser 
--update topway..tbTrainUser set RealPrice='139.5'
WHERE TrainTicketNo IN (SELECT ID FROM topway..tbTrainTicketInfo WHERE CoupNo='RS000018591')

SELECT TotSprice,TotPrice,* FROM topway..tbTrainTicketInfo 
--update topway..tbTrainTicketInfo  set TotSprice='139.5',TotPrice='159.5'
WHERE (CoupNo='RS000018592')
SELECT RealPrice,* FROM topway..tbTrainUser 
--update topway..tbTrainUser set RealPrice='139.5'
WHERE TrainTicketNo IN (SELECT ID FROM topway..tbTrainTicketInfo WHERE CoupNo='RS000018592')

--旅游退款单信息

select * from Topway..tbTrvKhTk 
--update Topway..tbTrvKhTk  set AcountInfo='赵一清||==||上海浦东发展银行上海分行||==||970200018288'
where TrvId='029176'

--账单撤销

select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where CompanyCode='019693' and BillNumber='019693_20181201'

--撤销闭团及闭团相关信息（旅游）

select Status,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Status='12'
where TrvId='29234'
--delete from Topway..tbTrvCoup where TrvId='29234'

--重新开下打印权限

select Prname,SettleStatus,* from Topway..tbTrvSettleApp 
--update Topway..tbTrvSettleApp set Prname='',SettleStatus='1'
where Id='26574'

--撤销闭团及闭团相关信息（旅游）

select ModifyDate,* from Topway..tbTravelBudget  
--update Topway..tbTravelBudget set ModifyDate='2018-12-31 10:11:44.000'
where TrvId='29234'
select OperDate,* from Topway..tbTrvCoup  
--update Topway..tbTrvCoup set OperDate='2018-12-31 10:20:28.267'
where TrvId='29234'

--行程单、特殊票价

select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='需打印行程单'
where coupno in('AS002163653','AS002163760')

--机票业务顾问信息

select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='杜鹏媛'
where coupno='AS001373287'

select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set SpareTC='蒋燕华'
where coupno='AS001374859'

--酒店销售单作废

select status,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set status='1'
where CoupNo='ptw074198'

--结算价差额

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='3622',profit='-2'
where coupno='AS002188401'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='3622',profit='-2'
where coupno='AS002188417'

--财务到账认领状态

select state from topway..FinanceERP_ClientBankRealIncomeDetail 
--update topway..FinanceERP_ClientBankRealIncomeDetail set state='5'
where money='10950' and id='92F9CD53-DC4A-4212-B5A0-9363768D4629' 

/*
1、单位客户，所以单位国内、国际常旅客名单
要求客户状态：合作
报表要素：单位编号、单位名称、中文名字、英文名字（Last/First Middle）、身份证、护照及其他证件（有多个证件的可以分几列）
*/
IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select t1.cmpid as 单位编号,t1.cmpname as 单位名称
,(case CustomerType when 'A' then '差旅单位客户' when 'C' then '旅游单位客户' else '' end) as 单位类型
,(CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END) as 合作状态
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as 开发人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as 客户主管
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as 维护人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as 差旅业务顾问
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as 旅游业务顾问
,indate
--into #cmp 
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
t9.ID=t5.EmployeeID and t9.ID=t6.EmployeeID and t9.ID=t8.TktTCID and t9.ID=t7.TrvTCID  where t1.cmpid<>00003 and t1.cmpid<>00006 and t1.cmpid<>'' and hztype in('1','2','3')
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid

--按成本中心销量折扣率

select CostCenter as 成本中心,SUM(totprice) as 销量,COUNT(*) as 张数,SUM(price)/COUNT(*) as 平均票价,AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS 折扣率
from topway..V_TicketInfo 
where cmpcode in ('017020')
and datetime>='2018-01-01' and datetime<'2018-12-01' and reti=''
group by CostCenter
order by CostCenter



-- UC019401上海卓思智能科技股份有限公司消费明细

select v.datetime as 出票日期,v.begdate as 起飞日期,v.coupno as 销售单号,v.pasname as 乘客姓名,v.tcode+v.ticketno as 票号,v.route as 行程,v.price as 销售单价,v.tax as 税收,v.ride+v.flightno as 航班号 
,v.Department as 部门,v.reti as 退票单号,t.ProjectNo as 项目编号
from Topway..V_TicketInfo v
left join Topway..tbcash t on t.pasname=v.pasname and t.coupno=v.coupno and t.price=v.price
where v.cmpcode='019401' and v.datetime>='2018-01-01' and v.datetime<'2019-01-01' and v.pasname in('王继鹤','王珺','赵伊坡','陆青清','尹小山','张宾','余金芳','张光','周宇','姜彬','唐文','厉伟南','刘鹏','顾春华')
order by v.datetime

--酒店消费单重开打印

select pstatus,prdate,* from topway..tbHtlcoupYf 
--update topway..tbHtlcoupYf set pstatus='0',prdate='1900-01-01'
where CoupNo in('ptw074015','ptw074016')

--多付款单、退票付款申请单修改/作废

select IsEnable,* from topway..tbExtraPayment 
--update topway..tbExtraPayment set IsEnable='0'
where Id='51554'
