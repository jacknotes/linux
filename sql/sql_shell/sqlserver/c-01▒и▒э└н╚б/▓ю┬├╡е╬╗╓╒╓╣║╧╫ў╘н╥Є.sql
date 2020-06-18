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

select * from #cmp1

select cmpid,单位ID,cmpname,维护人 客户经理, 客户主管 售后主管,(case RebateStyle when 1 then '个人后返' when 0 then '单位后返' else '' end ) 返佣类型,[percent]/100 后返比列 
from #cmp1 cmp
left join homsomDB..Trv_FlightNormalPolicies f on f.UnitCompanyID=Cmp.单位ID
left join homsomDB..Trv_RebateRelations re on re.FlightNormalPolicyID=f.ID
where f.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'

/*
现需要拉取所有合作差旅单位中返佣类型为后返（单位后返/个人后返）的公司名单，所需字段如下：

UC号、单位名称、客户经理、售后主管、国内机票佣金（单位后返/个人年后返）、返佣比例或金额、国际机票佣金（单位后返/个人年后返）、返佣比例或金额。
*/
--返佣ID
--select * from homsomDB..Trv_Dictionaries where DictionaryType='4'
--select top 10 Cmpid,* from homsomDB..Trv_UnitCompanies 
--select * from #cmp1

--单位国内
IF OBJECT_ID('tempdb.dbo.#cmp2') IS NOT NULL DROP TABLE #cmp2
 select un.Cmpid ,un.Name
 into #cmp2
 from homsomDB..Trv_UnitCompanies un
 left join homsomDB..Trv_FlightNormalPolicies f1 on f1.UnitCompanyID=un.ID and f1.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 left join homsomDB..Trv_FlightTripartitePolicies f2 on f2.UnitCompanyID=un.ID and f2.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 left join homsomDB..Trv_FlightAdvancedPolicies f3 on f3.UnitCompanyID=un.ID and f3.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 where un.Type='A'
 and CooperativeStatus in ('1','2','3')

--国内机票正常线路
 
select Cmpid,(case RebateStyle when 1 then '个人后返' when 0 then '单位后返' else '' end ) 返佣类型,[percent]/100 后返比列
from  homsomDB..Trv_FlightNormalPolicies f
left join homsomDB..Trv_UnitCompanies un on un.ID=f.UnitCompanyID
left join homsomDB..Trv_RebateRelations re on re.FlightNormalPolicyID=f.ID
where f.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034' 
and CooperativeStatus in ('1','2','3')
and Type='A'
 
 --特殊线路
 select Cmpid,(case RebateStyle when 1 then '个人后返' when 0 then '单位后返' else '' end ) 返佣类型,[percent]/100 后返比列
from  homsomDB..Trv_FlightAdvancedPolicies f
left join homsomDB..Trv_UnitCompanies un on un.ID=f.UnitCompanyID
left join homsomDB..Trv_RebateRelations re on re.FlightNormalPolicyID=f.ID
where f.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
and CooperativeStatus in ('1','2','3')
and Type='A'
 

--国际
  select Cmpid,(case RebateStyle when 1 then '个人后返' when 0 then '单位后返' else '' end ) 返佣类型,[percent]/100 后返比列
from  homsomDB..Trv_IntlFlightNormalPolicies f
left join homsomDB..Trv_UnitCompanies un on un.ID=f.UnitCompanyID
left join homsomDB..Trv_IntlRebateRelations re on re.FlightNormalPolicyID=f.ID
where f.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
and CooperativeStatus in ('1','2','3')
and Type='A'
and Cmpid not in ('000003','000006')
 
 
 
 --select * from #cmp2
 
 select cmp2.Cmpid UC号,cmp2.Name 单位名称,'' 国内机票佣金,cmp1.维护人 运营经理,cmp1.客户主管 售后主管
 into #cmp3
 from #cmp2 cmp2
 inner join #cmp1 cmp1 on cmp1.Cmpid=cmp2.Cmpid
 where cmp2.Cmpid not in ('000003','000006')
 
 select * from #cmp3
 
 select UnitCompanyID,* from homsomDB..Trv_FlightNormalPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 select UnitCompanyID,* from homsomDB..Trv_FlightTripartitePolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 select UnitCompanyID,* from homsomDB..Trv_FlightAdvancedPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 SELECT * FROM homsomDB..Trv_RebateRelations where FlightNormalPolicyID in('13F5540F-18EB-4679-9860-4894BE5F5C7F','DE53A099-EDA9-4D28-894D-A48A0102E022')
 
 --国际
 select * from homsomDB..Trv_IntlFlightNormalPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 
 select status2,* from Topway..tbReti where reno='0431240'
