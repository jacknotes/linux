
--单位信息
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
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid




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

IF OBJECT_ID('tempdb.dbo.#p3') IS NOT NULL DROP TABLE #p3
select * 
into #p3
from #p2
where 单位编号<>'' and 合作状态 not like ('%终止%') and 单位类型='差旅单位客户'


select * from #p3

IF OBJECT_ID('tempdb.dbo.#p4') IS NOT NULL DROP TABLE #p4
SELECT u.cmpid as 单位编号,u.Name as 单位名称,差旅业务顾问,运营经理,
case uc.Enabled when 1 then '是' else '否' end as 是否开通TMS
--,IsFreeInsurance
--,BindAccidentIntInsurance
into #p4
FROM homsomDB..Trv_UCSettings uc
left join homsomDB..Trv_UnitCompanies u on u.UCSettingID=uc.ID
inner join #p3 p3 on p3.单位编号=u.Cmpid
WHERE 
--IsFreeInsurance=1 --是否赠送保险0否1是
 u.Cmpid<>'000003'

select * from #p4







--线上下单数
IF OBJECT_ID('tempdb.dbo.#p5') IS NOT NULL DROP TABLE #p5
SELECT u.Cmpid,u.Name
,case uc.Enabled when 1 then '是' else '否' end as 是否开通TMS
,COUNT(*) as 线上下单数
into #p5
FROM homsomDB..Trv_CompanyTravels t1
left join homsomDB..Trv_ItktBookings t2 on t2.TravelID=t1.ID
left join homsomDB..Trv_TktBookings t3 on t3.ID=t2.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=t1.UnitCompanyID
left join homsomDB..Trv_UCSettings uc on u.UCSettingID=uc.ID
where t3.CreateDate>='2018-06-01' and t3.CreateDate<'2018-07-01'
and BookingSource in (1,5)
group by u.Cmpid,u.Name,uc.Enabled

--线下下单数
IF OBJECT_ID('tempdb.dbo.#p6') IS NOT NULL DROP TABLE #p6
SELECT u.Cmpid,u.Name
,case uc.Enabled when 1 then '是' else '否' end as 是否开通TMS
,COUNT(*) as 线下下单数
into #p6
FROM homsomDB..Trv_CompanyTravels t1
left join homsomDB..Trv_ItktBookings t2 on t2.TravelID=t1.ID
left join homsomDB..Trv_TktBookings t3 on t3.ID=t2.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=t1.UnitCompanyID
left join homsomDB..Trv_UCSettings uc on u.UCSettingID=uc.ID
where t3.CreateDate>='2018-06-01' and t3.CreateDate<'2018-07-01'
and BookingSource in (2,3,4)
group by u.Cmpid,u.Name,uc.Enabled


select p4.*,isnull(p5.线上下单数,0)线上下单数,isnull(p6.线下下单数,0)线下下单数 from #p4 p4
left join #p5 p5 on p5.cmpid=p4.单位编号
left join #p6 p6 on p6.cmpid=p4.单位编号



IF OBJECT_ID('tempdb.dbo.#p5') IS NOT NULL DROP TABLE #p5
select c.InsuranceCategory,a.companyname,a.Name,d.CreateDate,e.TravelID,*
--into #p5
from 
homsomDB..Trv_ItktBookings  as b
left join homsomDB..Trv_Passengers  as a on b.ID=a.ItktBookingID
left join homsomDB..Trv_Insurance as c  on a.ID=c.PassengerID
left join homsomDB..Trv_TktBookings as d on d.ID=b.ID
left join homsomDB..Trv_Travels e on e.ID=b.TravelID
where b.TravelID in 
(select ID from homsomDB..Trv_CompanyTravels  where UnitCompanyID in (select id from homsomDB..Trv_UnitCompanies where Cmpid in (
select 单位编号 from #p4)))
and d.CreateDate>='2018-06-01'
and d.AdminStatus=5
--and c.InsuranceCategory <>'航空延误险'
order by c.InsuranceCategory

select * from #p5


select p5.*,p3.差旅业务顾问,p3.运营经理 from #p5 p5
inner join #p3 p3 on p3.单位名称=p5.companyname
order by CreateDate

