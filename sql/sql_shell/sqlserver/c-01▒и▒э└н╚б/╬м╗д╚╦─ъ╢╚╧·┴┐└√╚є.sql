--请按维护人(5位运营经理），拉取新老客户的总销量、总利润（机票、酒店），新老客户以2017年1月1日为界限（1月1日前为老客户）

IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp1
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

--维护人
IF OBJECT_ID('tempdb.dbo.#whr') IS NOT NULL DROP TABLE #whr
select distinct 维护人 
into #whr
from #cmp1
where 单位编号<>''

IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select * 
into #cmp
from #cmp1
where #cmp1.单位类型='差旅单位客户'

--select * from #cmp

--机票
IF OBJECT_ID('tempdb.dbo.#jipiao') IS NOT NULL DROP TABLE #jipiao
select t1.维护人
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as 销量
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as 毛利 
into #jipiao
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.单位编号
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where (t3.datetime>='2016-01-01' and t3.datetime<'2017-01-01')
and 单位编号<>''
group by t1.维护人
order by t1.维护人





--酒店
IF OBJECT_ID('tempdb.dbo.#hotel') IS NOT NULL DROP TABLE #hotel
select t1.维护人
,sum(h1.price) as 酒店销量
,sum(h1.totprofit) as 酒店利润
into #hotel
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.单位编号 and h1.status2<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where (h1.prdate>='2016-01-01' and h1.prdate<'2017-01-01') and 
status !='-2'
and 单位编号<>''
group by t1.维护人
order by t1.维护人







--酒店自付
IF OBJECT_ID('tempdb.dbo.#hotel_y') IS NOT NULL DROP TABLE #hotel_y
select t1.维护人
,sum(h3.price) as 酒店销量
,sum(h3.totprofit) as 酒店利润
into #hotel_y
from #cmp t1
left join tbHotelcoup h3 on h3.cmpid=t1.单位编号 and h3.status<>-2
left join tbhtlyfchargeoff h4 on h4.coupid=h3.id
where (h3.datetime>='2016-01-01' and h3.datetime<'2017-01-01') and 
status !='-2'
and 单位编号<>''
group by t1.维护人
order by t1.维护人



select whr.维护人
,isnull(jipiao.销量,0)+isnull(Hotel.酒店销量,0)+isnull(hotel_y.酒店销量,0) as 总销量
,isnull(jipiao.毛利,0)+isnull(Hotel.酒店利润,0)+isnull(hotel_y.酒店利润,0) as 总利润
from #whr whr
left join #jipiao jipiao on jipiao.维护人=whr.维护人
left join #hotel hotel on hotel.维护人=whr.维护人
left join #hotel_y hotel_y on hotel_y.维护人=whr.维护人




