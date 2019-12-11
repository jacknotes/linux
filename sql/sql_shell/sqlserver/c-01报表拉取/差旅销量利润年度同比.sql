IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as 单位编号,t1.cmpname as 单位名称
,(case CustomerType when 'A' then '差旅单位客户' when 'C' then '旅游单位客户' else '' end) as 单位类型
,(CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END) as 合作状态
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as 开发人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as 客户主管
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as 维护人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as 差旅业务顾问
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as 旅游业务顾问
,indate as 注册月
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


IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select *
into #cmp
from #cmp1
where 单位编号<>''
and 注册月<'2017-01-01'

select * from #cmp
order by 单位编号
--2017
--机票
IF OBJECT_ID('tempdb.dbo.#jipiao1') IS NOT NULL DROP TABLE #jipiao1
select t1.单位编号
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as tb1
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as tb2
into #jipiao1
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.单位编号
left join tbreti t2 on t3.reti=t2.reno and t2.status2<>4
where  (t3.datetime>='2017-01-01' and t3.datetime<'2018-01-01')
and 注册月<'2017-01-01'
group by t1.单位编号
order by t1.单位编号


--酒店转付
IF OBJECT_ID('tempdb.dbo.#hotel1') IS NOT NULL DROP TABLE #hotel1
select t1.单位编号
,sum(h1.price) as hb1
,sum(h1.totprofit) as hb2
into #hotel1
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.单位编号 and h1.status<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where 
(h1.prdate>='2017-01-01' and h1.prdate<'2018-01-01') and 
status !='-2'
and 注册月<'2017-01-01'
group by t1.单位编号
order by t1.单位编号

--酒店自付
IF OBJECT_ID('tempdb.dbo.#hotel_y1') IS NOT NULL DROP TABLE #hotel_y1
select t1.单位编号
,sum(h3.price) as zb1
,sum(h3.totprofit) as zb2
into #hotel_y1
from #cmp t1
left join tbHotelcoup h3 on h3.cmpid=t1.单位编号 and h3.status<>-2
left join tbhtlyfchargeoff h4 on h4.coupid=h3.id
where 
(h3.datetime>='2017-01-01' and h3.datetime<'2018-01-01') and 
status !='-2'
and 注册月<'2017-01-01'
group by t1.单位编号
order by t1.单位编号

--2016
--机票
IF OBJECT_ID('tempdb.dbo.#jipiao2') IS NOT NULL DROP TABLE #jipiao2
select t1.单位编号
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as tb3
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as tb4
into #jipiao2
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.单位编号
left join tbreti t2 on t3.reti=t2.reno and t2.status2<>4
where  (t3.datetime>='2016-01-01' and t3.datetime<'2017-01-01')
and 注册月<'2017-01-01'
group by t1.单位编号
order by t1.单位编号


--酒店转付
IF OBJECT_ID('tempdb.dbo.#hotel2') IS NOT NULL DROP TABLE #hotel2
select t1.单位编号
,sum(h1.price) as hb3
,sum(h1.totprofit) as hb4
into #hotel2
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.单位编号 and h1.status<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where 
(h1.prdate>='2016-01-01' and h1.prdate<'2017-01-01') and 
status !='-2'
and 注册月<'2017-01-01'
group by t1.单位编号
order by t1.单位编号

--酒店自付
IF OBJECT_ID('tempdb.dbo.#hotel_y2') IS NOT NULL DROP TABLE #hotel_y2
select t1.单位编号
,sum(h3.price) as zb3
,sum(h3.totprofit) as zb4
into #hotel_y2
from #cmp t1
left join tbHotelcoup h3 on h3.cmpid=t1.单位编号 and h3.status<>-2
left join tbhtlyfchargeoff h4 on h4.coupid=h3.id
where 
(h3.datetime>='2017-01-01' and h3.datetime<'2018-01-01') and 
status !='-2'
and 注册月<'2017-01-01'
group by t1.单位编号
order by t1.单位编号



--汇总
select cmp.*
,isnull(tb3,0)+isnull(hb3,0)+isnull(zb3,0) as '2016客户总销量'
,isnull(tb1,0)+isnull(hb1,0)+isnull(zb1,0) as '2017客户总销量'
,isnull(cast(((isnull(tb1,0)+isnull(hb1,0)+isnull(zb1,0))-(isnull(tb3,0)+isnull(hb3,0)+isnull(zb3,0)))/nullif(isnull(tb3,0)+isnull(hb3,0)+isnull(zb3,0),0)*100 as varchar(20))+'%',0) as 销量同比
,isnull(tb4,0)+isnull(hb4,0)+isnull(zb4,0) as '2016客户总利润'
,isnull(tb2,0)+isnull(hb2,0)+isnull(zb2,0) as '2017客户总利润'
,isnull(cast(((isnull(tb2,0)+isnull(hb2,0)+isnull(zb2,0))-(isnull(tb4,0)+isnull(hb4,0)+isnull(zb4,0)))/nullif(isnull(tb4,0)+isnull(hb4,0)+isnull(zb4,0),0)*100 as varchar(20))+'%',0) as 利润同比
from #cmp cmp
left join #jipiao1 tb1 on tb1.单位编号=Cmp.单位编号
left join #hotel1 hb1 on hb1.单位编号=Cmp.单位编号
left join #hotel_y1 zb1 on zb1.单位编号=Cmp.单位编号
left join #jipiao2 tb2 on tb2.单位编号=Cmp.单位编号
left join #hotel2 hb2 on hb2.单位编号=Cmp.单位编号
left join #hotel_y2 zb2 on zb2.单位编号=Cmp.单位编号
order by Cmp.单位编号
