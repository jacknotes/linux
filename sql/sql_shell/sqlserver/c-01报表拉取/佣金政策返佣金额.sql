/*现需要拉取所有合作差旅单位中返佣类型为后返（单位后返/个人后返）的公司名单，所需字段如下：

UC号、单位名称、客户经理、售后主管、国内机票佣金（单位后返/个人年后返）、返佣比例或金额、国际机票佣金（单位后返/个人年后返）、返佣比例或金额
符合条件的单位
*/


IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid ,t4.ID as 单位ID,t1.cmpname 
,(case CustomerType when 'A' then '差旅单位客户' when 'C' then '旅游单位客户' else '' end) as type
,(CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END) as 合作状态
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as 开发人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as 客户主管
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as 维护人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as 差旅业务顾问
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as 旅游业务顾问
,t4.TerminateReason as 终止合作原因
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
where hztype in ('1','2','3') and t1.cmpid not in ('000003','000006')
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate,t4.TerminateReason
order by t1.cmpid

--select * from #cmp1 where cmpid='019604'

--国内机票正常线路

--select ID,Name,* from homsomDB..Trv_Dictionaries where Name like '%后返%'

-- select * from homsomDB..Trv_Dictionaries where DictionaryType='4' 
-- select ID,* from homsomDB..Trv_FlightNormalPolicies where CommissionTypeID in(select ID from homsomDB..Trv_Dictionaries where Name like '%后返%')
-- select UnitCompanyID,* from homsomDB..Trv_FlightTripartitePolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
-- select UnitCompanyID,* from homsomDB..Trv_FlightAdvancedPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
select ID,* from homsomDB..Trv_IntlFlightNormalPolicies where CommissionTypeID in(select ID from homsomDB..Trv_Dictionaries where Name like '%后返%')
 
 if OBJECT_ID ('tempdb..#fyje') is not null drop TABLE #fyje
 SELECT UN.Cmpid,D.Name,[Percent] 返佣比列或金额
 into #fyje
 FROM homsomDB..Trv_RebateRelations  re
 left join homsomDB..Trv_FlightNormalPolicies f1 on f1.ID=re.FlightNormalPolicyID and f1.EndTime>'2019-05-10'
 left join homsomDB..Trv_FlightTripartitePolicies f2 on f2.ID=re.FlightNormalPolicyID and f2.EndTime>'2019-05-10'
 left join homsomDB..Trv_FlightAdvancedPolicies f3 on f3.ID=re.FlightNormalPolicyID  and f3.EndTime>'2019-05-10'
 left join homsomDB..Trv_Dictionaries d on (d.ID=f1.CommissionTypeID or d.ID=f2.CommissionTypeID or d.ID=f3.CommissionTypeID)
 left join homsomDB..Trv_UnitCompanies un on (un.ID=f1.UnitCompanyID or un.ID=f2.UnitCompanyID or un.ID=f3.UnitCompanyID)
 where d.Name like '%后返%'
 and un.CooperativeStatus in ('1','2','3')
 and un.Type='A'
 AND [Percent]!=0
 AND d.Name NOT IN ('单位后返+个人后返')
 
 --select * from #fyje
 
 select distinct f.cmpid uc ,cmp.cmpname 单位名称, cmp.TYPE 单位类型, cmp.合作状态,cmp.客户主管 售后主管,cmp.维护人 运营经理,
 f.name 返佣类型,f.返佣比列或金额
 from #fyje f
 left join #cmp1 cmp on Cmp.cmpid=f.cmpid
 
 
 
 --国际
 
 select ID,* from homsomDB..Trv_IntlFlightNormalPolicies where CommissionTypeID in(select ID from homsomDB..Trv_Dictionaries where Name like '%后返%')
 
 if OBJECT_ID('tempdb..#gjfyje1') is not null drop table #gjfyje1
  SELECT UN.Cmpid,D.Name,[Percent] 返佣比列或金额
 into #gjfyje1
 FROM homsomDB..Trv_IntlRebateRelations  re
 left join homsomDB..Trv_IntlFlightNormalPolicies f1 on f1.ID=re.FlightNormalPolicyID and f1.EndTime>'2019-04-11'
 left join homsomDB..Trv_Dictionaries d on d.ID=f1.CommissionTypeID 
 left join homsomDB..Trv_UnitCompanies un on un.ID=f1.UnitCompanyID
 where d.Name like '%后返%'
 and un.CooperativeStatus in ('1','2','3')
 and un.Type='A'
 AND [Percent]!=0
 AND d.Name not IN ('单位后返+个人后返')
 
 SELECT UN.Cmpid,D.Name,[Percent] 返佣比列或金额
 --into #gjfyje1
 FROM homsomDB..Trv_IntlRebateRelations  re
 left join homsomDB..Trv_IntlFlightNormalPolicies f1 on f1.ID=re.FlightNormalPolicyID and f1.EndTime>'2019-05-10'
 left join homsomDB..Trv_Dictionaries d on d.ID=f1.CommissionTypeID 
 left join homsomDB..Trv_UnitCompanies un on un.ID=f1.UnitCompanyID
 where d.Name like '%后返%'
 and un.CooperativeStatus in ('1','2','3')
 and un.Type='A'
 AND [Percent]!=0
 AND d.Name IN ('单位后返+个人后返')
 
 --select * from #gjfyje1
 
 select distinct f.cmpid uc ,cmp.cmpname 单位名称, cmp.TYPE 单位类型, cmp.合作状态,cmp.客户主管 售后主管,cmp.维护人 运营经理,
 f.name 返佣类型,f.返佣比列或金额
 from #gjfyje1 f
 left join #cmp1 cmp on Cmp.cmpid=f.cmpid
 where f.cmpid not in ('000006')