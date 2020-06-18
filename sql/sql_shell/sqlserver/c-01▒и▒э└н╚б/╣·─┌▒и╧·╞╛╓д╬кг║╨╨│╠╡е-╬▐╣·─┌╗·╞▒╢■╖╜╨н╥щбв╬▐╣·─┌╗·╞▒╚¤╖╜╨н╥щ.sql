/*
符合以下要求：
1.国内报销凭证为：行程单
2.无国内机票二方协议、无国内机票三方协议
 
需要信息：
UC、单位名称、合作状态、维护人、运营经理、售后主管、服务费（国内机票正常线路
*/


IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as 单位编号,t1.cmpname as 单位名称
,(case CustomerType when 'A' then '差旅单位客户' when 'C' then '旅游单位客户' else '' end) as 单位类型
,(CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END) as 合作状态
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as 开发人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as 售后主管
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
where hztype not in (0,4)
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid


select * from #cmp1


--挖掘人
IF OBJECT_ID('tempdb.dbo.#wjr') IS NOT NULL DROP TABLE #wjr
select CmpId,MaintainName 
into #wjr
from  HM_ThePreservationOfHumanInformation tp where MaintainType=6 and IsDisplay=1
--运营经理
IF OBJECT_ID('tempdb.dbo.#yyjl') IS NOT NULL DROP TABLE #yyjl
select CmpId,MaintainName 
into #yyjl
from  HM_ThePreservationOfHumanInformation tp where MaintainType=9 and IsDisplay=1

IF OBJECT_ID('tempdb.dbo.#p2') IS NOT NULL DROP TABLE #p2
select cmp1.*,wjr.MaintainName as 挖掘人,yyjl.MaintainName as 运营经理 
into #p2
from #cmp1 cmp1
left join #wjr wjr on wjr.cmpid=cmp1.单位编号
left join #yyjl yyjl on yyjl.cmpid=cmp1.单位编号


select p2.*,fp.ServiceCharge from #p2 p2
left join homsomDB..Trv_UnitCompanies up on up.Cmpid=p2.单位编号
inner join homsomDB..Trv_FlightNormalPolicies fp on fp.UnitCompanyID=up.ID and fp.Name in ('国内机票正常线路')
where CertificateD=1
and up.ID not in (select UnitCompanyID from homsomDB..Trv_FlightTripartitePolicies)
and EndTime>=GETDATE()



select * from homsomDB..Trv_FlightAdvancedPolicies fp


