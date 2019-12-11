
IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid ,t1.cmpname 
,(case CustomerType when 'A' then '差旅单位客户' when 'C' then '旅游单位客户' else '' end) as type
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
--where indate<'2017-09-01'
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid




--有消费
IF OBJECT_ID('tempdb.dbo.#p4') IS NOT NULL DROP TABLE #p4
select distinct cmpid into #p4 from tbTrvCoup where (OperDate>='2017-01-01' and OperDate<'2019-01-01')
IF OBJECT_ID('tempdb.dbo.#p5') IS NOT NULL DROP TABLE #p5
select distinct cmpid into #p5 from tbConventionCoup where (OperDate>='2017-01-01' and OperDate<'2019-01-01')


IF OBJECT_ID('tempdb.dbo.#p') IS NOT NULL DROP TABLE #p
CREATE TABLE #P(cmpid VARCHAR(100)) 
INSERT INTO #P(cmpid)
select * from #p4
UNION ALL select * from #p5


select cmp1.* from #cmp1 cmp1
where  cmp1.cmpid  in (Select * from #p)
and cmpid<>''
order by cmp1.cmpid






--无消费
IF OBJECT_ID('tempdb.dbo.#p6') IS NOT NULL DROP TABLE #p6
select distinct cmpid into #p6 from tbTravelBudget where (OperDate>='2016-01-01' and OperDate<'2018-01-01') and Status<>2
IF OBJECT_ID('tempdb.dbo.#p7') IS NOT NULL DROP TABLE #p7
select distinct cmpid into #p7 from tbConventionBudget where (OperDate>='2016-01-01' and OperDate<'2018-01-01') and Status<>2


IF OBJECT_ID('tempdb.dbo.#p2') IS NOT NULL DROP TABLE #p2
CREATE TABLE #P2(cmpid VARCHAR(100)) 
INSERT INTO #P2(cmpid)
select * from #p6
UNION ALL select * from #p7


select cmp1.*,m.custname,m.mobilephone from #cmp1 cmp1
left join tbCusholderM m on m.cmpid=cmp1.cmpid and m.custtype1 in (3,4)
where  cmp1.cmpid not  in (Select * from #p2)
order by cmp1.cmpid



