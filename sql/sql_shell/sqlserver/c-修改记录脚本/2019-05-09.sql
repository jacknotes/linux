/*
拉取一份会务运营部-崔之阳 张广寒 周寅啸，2019年4月份完成毕团的数据EXECL表，具体包含以下各项：
1.毕团日期
2.预算单号
3.单位名称
4.供应商结算信息：供应商来源
*/
select c.OperDate,c.ConventionId,u.Name,j.GysSource,Sales,FinancialCharges
from Topway..tbConventionCoup c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.Cmpid
left join Topway..tbConventionJS j on j.ConventionId=c.ConventionId
where c.OperDate>='2019-04-01'
and c.OperDate<'2019-05-01'
and Sales in('崔之阳','张广寒','周寅啸')
and Status<>2
order by c.OperDate

--2019年1月1日前注册的单位客户为老客户

select Name from  homsomDB..Trv_UnitCompanies_KEYAccountManagers u 
left join Topway..SSO_Users s on s.ID=u.EmployeeID
where Name in ('王涛','汤慧祥','万虎林','姚迪华')
select  top 100 RegisterMonth,* from homsomDB..Trv_UnitCompanies


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
from topway..tbCompanyM t1
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

select* from #cmp1

--3月4月旅游销量和利润（老客户）

select  CONVERT(varchar(6),c.OperDate,112) 月份,Cmp.维护人,
sum(XsPrice) 销量,sum(Profit) 利润
from topway..tbTrvCoup c
left join #cmp1 cmp on Cmp.单位编号=c.Cmpid
where c.OperDate>='2019-03-01' and c.OperDate<'2019-05-01'
and Cmp.indate<'2019-01-01'
group by CONVERT(varchar(6),c.OperDate,112),Cmp.维护人

--select indate,* from Topway..tbCompanyM where cmpid='020271'
--select RegisterMonth,* from homsomDB..Trv_UnitCompanies where Cmpid='020271'

--2019年1-4月旅游销量和利润（老客户）

select  Cmp.维护人,
sum(XsPrice) 销量,sum(Profit) 利润
from topway..tbTrvCoup c
left join #cmp1 cmp on Cmp.单位编号=c.Cmpid
where c.OperDate>='2018-01-01' and c.OperDate<'2018-05-01'
and Cmp.indate<'2019-01-01'
group by Cmp.维护人


 /*   麻烦拉取4/1-4/30闭团的奖金数据：

1、销售新客户旅游会务。10月1日之前录入预算单计提利润      ，10月1日之后录入预算单计提利润。

2、 会务顾问计提利润中10月份录预算单的是否有。10月1日之前录入预算单计提利润，10月1日之后录入预算单计提利润。

*/
--旅游10月之后 新客户
select cmp1.开发人,SUM(DisCountProfit) as 计提利润 from tbTrvCoup c
inner join tbTravelBudget b on b.TrvId=c.TrvId
inner join #cmp1 cmp1 on cmp1.单位编号=c.Cmpid
where c.OperDate>='2019-04-01' and c.OperDate<'2019-05-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
and cmp1.indate>'2018-05-01'
group by cmp1.开发人
order by 计提利润 desc


--会务顾问10月之后 
select c.Sales  as 会务顾问,SUM(DisCountProfit) as 计提利润 from tbConventionCoup c
inner join tbConventionBudget b on b.ConventionId=c.ConventionId
inner join #cmp1 cmp1 on cmp1.单位编号=c.Cmpid
where c.OperDate>='2019-04-01' and c.OperDate<'2019-05-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
--and cmp1.indate>='2018-01-01'
group by c.Sales
order by 计提利润 desc

select c.Sales  as 会务顾问,c.TrvId,SUM(DisCountProfit) as 计提利润 from tbTrvCoup c
inner join tbTravelBudget b on b.TrvId=c.TrvId
inner join #cmp1 cmp1 on cmp1.单位编号=c.Cmpid
where c.OperDate>='2019-04-01' and c.OperDate<'2019-05-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
--and cmp1.indate>='2018-01-01'
group by c.Sales,c.TrvId
order by 计提利润 desc

select * from Topway..tbTrvCoup where TrvId='29704'


--会务10月之前 新客户
select cmp1.开发人,SUM(DisCountProfit)  as 计提利润 from tbConventionCoup c
inner join tbConventionBudget b on b.ConventionId=c.ConventionId
inner join #cmp1 cmp1 on cmp1.单位编号=c.Cmpid
where c.OperDate>='2019-04-01' and c.OperDate<'2019-05-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
and cmp1.indate>'2018-05-01'
group by cmp1.开发人
order by 计提利润 desc

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update  Topway..AccountStatement  set SubmitState=1
where BillNumber='020754_20190401'

--销售价信息
select price,totprice,owe,amount,profit,* from Topway..tbcash 
--update Topway..tbcash  set price=20,totprice='20',owe='20',amount='20',profit='18'
where coupno='AS002453151'

select price,totprice,owe,amount,profit,* from Topway..tbcash 
--update Topway..tbcash  set price=20,totprice='20',owe='20',amount='20',profit='18'
where coupno='AS002453251'

select price,totprice,owe,amount,profit,* from Topway..tbcash 
--update Topway..tbcash  set price=20,totprice='20',owe='20',amount='20',profit='18'
where coupno='AS002454899'

--会务预算单信息
select Sales,OperName,introducer,* from Topway..tbConventionBudget
--update  Topway..tbConventionBudget set Sales='崔之阳',OperName='0481崔之阳',introducer='崔之阳-0481-运营部'
where ConventionId in('1328','1337','1155','1338','1184','1250','1252','1398')

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='019143_20190401'

--select Departure,Destination,* from homsomdb..Trv_lineLimit where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F'

--update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure=''
--update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination=''

update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='LXA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='LXA'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='YUS') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='YUS'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='SIA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='SIA'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='KMG') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='KMG'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='SIA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='SIA'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='JZH') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='JZH'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='SIA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='SIA'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='JZH') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='JZH'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='CTU') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='CTU'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='SHA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='SHA'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='DLU') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='DLU'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='SHA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='SHA'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='LXA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='LXA'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='YUS') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='YUS'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='YBP') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='YBP'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='XNN') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='XNN'


update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='SIA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='SIA'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='SIA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='SIA'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='YUS') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='YUS'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='YBP') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='YBP'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='LXA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='LXA'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='SIA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='SIA'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='JZH') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='JZH'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='CTU') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='CTU'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='JZH') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='JZH'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='LXA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='LXA'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='SHA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='SHA'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='DLU') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='DLU'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='SHA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='SHA'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='XNN') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='XNN'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='KMG') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='KMG'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='YUS') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='YUS'


--UC016641更名为长濑（中国）有限公司
select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement  set CompanyNameCN='长濑（中国）有限公司'
where BillNumber='016641_20190501'

--删除多余机场
SELECT * 
--DELETE
FROM homsomDB..Trv_Airport WHERE Code='DXB' AND ID='D80BAFED-379D-3967-92DF-0A9721BA99E6'


--旅游结算单作废
select SettleStatus,* from Topway..tbTrvSettleApp
--update Topway..tbTrvSettleApp set SettleStatus='3' 
where Id='27180'

select * from topway..tbTrvJS
--update topway..tbTrvJS set Jstatus='0',Settleno='0',Pstatus='0',Pdatetime='1900-1-1' 
where Settleno='27180'

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='携程官网分销联盟'
where CoupNo='PTW081867'

select tcode,* from Topway..tbintercmp 
--update Topway..tbintercmp  set tcode=0
where id=96


--酒店销售单供应商来源

select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='携程官网分销联盟'
where CoupNo='PTW081927'

--旅游结算单信息
select * from Topway..tbTrvSettleApp
--update Topway..tbTrvSettleApp set SettleStatus='3' 
where Id='27201'

