--机票销量、利润、张数
select t1.cmpcode as 单位编号,t3.cmpname as 单位名称
,case CustomerType when 'A' then '差旅单位客户' when 'C' then '旅游单位客户' else '' end as 单位类型,
CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END as 合作状态
,(select top 1t9.name from homsomDB..SSO_Users t9 left join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as 开发人
,(select top 1t9.name from homsomDB..SSO_Users t9 left join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as 客户主管
,(select top 1t9.name from homsomDB..SSO_Users t9 left join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as 差旅业务顾问
,(select top 1t9.name from homsomDB..SSO_Users t9 left join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as 旅游业务顾问
,SUM(ISNULL(t1.totprice,0)-ISNULL(t2.totprice,0))销量
,SUM(ISNULL(t1.profit,0)+ISNULL(t2.profit,0))毛利
,COUNT(1) as 张数
 from tbcash t1
--退票
left join tbreti t2 on t1.coupno=t2.coupno
--单位
left join tbCompanyM t3 on t1.cmpcode=t3.cmpid
--TMS
left join homsomdb..Trv_UnitCompanies t4 on t1.cmpcode=t4.Cmpid
--开发人
left join homsomDB..Trv_UnitCompies_Sales t5 on t4.ID=t5.UnitCompayID
--客户主管
left join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t4.ID=t6.UnitCompanyID
--旅游业务顾问
left join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t7.TrvUnitCompanyID=t4.ID
--差旅业务顾问
left join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t8.TktUnitCompanyID=t4.ID
--人员信息
left join homsomDB..SSO_Users t9 on
t9.ID=t5.EmployeeID and t9.ID=t6.EmployeeID and t9.ID=t8.TktTCID and t9.ID=t7.TrvTCID 
where t3.CustomerType='A' 
--and t1.inf=1 
--and (t1.datetime>='2016-10-01' and t1.datetime<'2016-11-01')
group by t1.cmpcode,t3.cmpname,CustomerType,hztype,t4.id
order by t1.cmpcode

--酒店销量、利润、间数
select cmpid,sum(price)销量,sum(totprofit)毛利,sum(pcs)间数 
from tbHtlcoupYf
where (prdate>='2016-10-01' and prdate<'2016-11-01')
and status !='-2'
group by cmpid


