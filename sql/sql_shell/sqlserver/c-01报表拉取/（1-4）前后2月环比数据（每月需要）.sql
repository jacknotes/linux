--机票销量、利润、张数

IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as 单位编号,t1.cmpname as 单位名称
,(case CustomerType when 'A' then '差旅单位客户' when 'C' then '旅游单位客户' else '' end) as 单位类型
,(CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END) as 合作状态
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as 开发人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as 客户主管
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as 维护人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as 差旅业务顾问
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as 旅游业务顾问
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




IF OBJECT_ID('tempdb.dbo.#wjr') IS NOT NULL DROP TABLE #wjr
select CmpId,MaintainName 
into #wjr
from  HM_ThePreservationOfHumanInformation tp where MaintainType=6 and IsDisplay=1
--运营经理
IF OBJECT_ID('tempdb.dbo.#yyjl') IS NOT NULL DROP TABLE #yyjl
select CmpId,MaintainName 
into #yyjl
from  HM_ThePreservationOfHumanInformation tp where MaintainType=9 and IsDisplay=1
IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select cmp1.*,wjr.MaintainName as 挖掘人,yyjl.MaintainName as 运营经理 
into #cmp
from #cmp1 cmp1
left join #wjr wjr on wjr.cmpid=cmp1.单位编号
left join #yyjl yyjl on yyjl.cmpid=cmp1.单位编号

--select * from #cmp where 单位编号<>''


--国内机票
IF OBJECT_ID('tempdb.dbo.#gnjp1') IS NOT NULL DROP TABLE #gnjp1
select t1.单位编号,t1.单位名称,t1.单位类型
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as 销量
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as 毛利 
,COUNT(*) as 张数
into #gnjp1
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.单位编号
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where (t3.datetime>='2018-05-01' and t3.datetime<'2018-06-01')
and 单位编号<>''
and t3.inf=0
group by t1.单位编号,t1.单位名称,t1.单位类型
order by t1.单位编号

IF OBJECT_ID('tempdb.dbo.#gnjp2') IS NOT NULL DROP TABLE #gnjp2
select t1.单位编号,t1.单位名称,t1.单位类型
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as 销量
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as 毛利 
,COUNT(*) as 张数
into #gnjp2
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.单位编号
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where (t3.datetime>='2018-06-01' and t3.datetime<'2018-07-01')
and 单位编号<>''
and t3.inf=0
group by t1.单位编号,t1.单位名称,t1.单位类型
order by t1.单位编号

--国际机票
IF OBJECT_ID('tempdb.dbo.#gjjp1') IS NOT NULL DROP TABLE #gjjp1
select t1.单位编号,t1.单位名称,t1.单位类型
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as 销量
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as 毛利 
,COUNT(*) as 张数
into #gjjp1
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.单位编号
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where (t3.datetime>='2018-05-01' and t3.datetime<'2018-06-01')
and 单位编号<>''
and t3.inf=1
group by t1.单位编号,t1.单位名称,t1.单位类型
order by t1.单位编号

IF OBJECT_ID('tempdb.dbo.#gjjp2') IS NOT NULL DROP TABLE #gjjp2
select t1.单位编号,t1.单位名称,t1.单位类型
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as 销量
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as 毛利 
,COUNT(*) as 张数
into #gjjp2
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.单位编号
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where (t3.datetime>='2018-06-01' and t3.datetime<'2018-07-01')
and 单位编号<>''
and t3.inf=1
group by t1.单位编号,t1.单位名称,t1.单位类型
order by t1.单位编号


--酒店
IF OBJECT_ID('tempdb.dbo.#jd1') IS NOT NULL DROP TABLE #jd1
select t1.单位编号
,sum(h1.price) as 酒店销量
,sum(h1.totprofit) as 酒店利润
,COUNT(*) as 张数
into #jd1
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.单位编号 and h1.status2<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where 
(h1.prdate>='2018-05-01' and h1.prdate<'2018-06-01') and 
status !='-2'
and 单位编号<>''
group by t1.单位编号
order by t1.单位编号

IF OBJECT_ID('tempdb.dbo.#jd2') IS NOT NULL DROP TABLE #jd2
select t1.单位编号
,sum(h1.price) as 酒店销量
,sum(h1.totprofit) as 酒店利润
,COUNT(*) as 张数
into #jd2
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.单位编号 and h1.status2<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where 
(h1.prdate>='2018-06-01' and h1.prdate<'2018-07-01') and 
status !='-2'
and 单位编号<>''
group by t1.单位编号
order by t1.单位编号


select Cmp.*
,(isnull(gnjp1.销量,0)+isnull(gjjp1.销量,0)) as '5月机票总销量'
,(isnull(gnjp2.销量,0)+isnull(gjjp2.销量,0)) as '6月机票总销量'
,isnull(cast(((isnull(gnjp2.销量,0)+isnull(gjjp2.销量,0))-(isnull(gnjp1.销量,0)+isnull(gjjp1.销量,0)))/ABS(nullif(isnull(gnjp1.销量,0)+isnull(gjjp1.销量,0),0))*100 as varchar(20))+'%','') as 总销量环比
,(isnull(gnjp1.毛利,0)+isnull(gjjp1.毛利,0)) as '5月机票总利润'
,(isnull(gnjp2.毛利,0)+isnull(gjjp2.毛利,0)) as '6月机票总利润'
,isnull(cast(((isnull(gnjp2.毛利,0)+isnull(gjjp2.毛利,0))-(isnull(gnjp1.毛利,0)+isnull(gjjp1.毛利,0)))/ABS(nullif(isnull(gnjp1.毛利,0)+isnull(gjjp1.毛利,0),0))*100 as varchar(20))+'%','') as 利润环比
,isnull(gnjp1.销量,0) as '5月国内机票销量'
,isnull(gnjp2.销量,0) as '6月国内机票销量'
,isnull((case when gnjp1.销量=0 then '' else cast((gnjp2.销量-gnjp1.销量)/ABS(gnjp1.销量)*100 as varchar(20))+'%' end),'') as 国内机票销量环比
,isnull(gnjp1.毛利,0) as '5月国内机票利润'
,isnull(gnjp2.毛利,0) as '6月国内机票利润'
,isnull((case when gnjp1.毛利=0 then '' else cast((gnjp2.毛利-gnjp1.毛利)/ABS(gnjp1.毛利)*100 as varchar(20))+'%' end),'') as 国内机票利润环比
,isnull(gnjp1.张数,0) as '5月国内机票张数'
,isnull(gnjp2.张数,0) as '6月国内机票张数'
,(case when gnjp1.张数=0 then '' else ((gnjp2.张数-gnjp1.张数)*1.0/gnjp1.张数) end)  as 国内机票张数环比
,isnull(gjjp1.销量,0) as '5月国际机票销量'
,isnull(gjjp2.销量,0) as '6月国际机票销量'
,isnull((case when gjjp1.销量=0 then '' else cast((gjjp2.销量-gjjp1.销量)/ABS(gjjp1.销量)*100 as varchar(20))+'%' end),'') as 国际机票销量环比
,isnull(gjjp1.毛利,0) as '5月国际机票利润'
,isnull(gjjp2.毛利,0) as '6月国际机票利润'
,isnull((case when gjjp1.毛利=0 then '' else cast((gjjp2.毛利-gjjp1.毛利)/ABS(gjjp1.毛利)*100 as varchar(20))+'%' end),'') as 国际机票利润环比
,isnull(gjjp1.张数,0) as '5月国际机票张数'
,isnull(gjjp2.张数,0) as '6月国际机票张数'
,(case when gjjp1.张数=0 then '' else ((gjjp2.张数-gjjp1.张数)*1.0/gjjp1.张数) end) as 国际机票张数环比
,isnull(jd1.酒店销量,0) as '5月酒店销量'
,isnull(jd2.酒店销量,0) as '6月酒店销量'
,isnull((case when jd1.酒店销量=0 then '' else cast((jd2.酒店销量-jd1.酒店销量)/ABS(jd1.酒店销量)*100 as varchar(20))+'%' end),'') as 酒店销量环比
,isnull(jd1.酒店利润,0) as '5月酒店利润'
,isnull(jd2.酒店利润,0) as '6月酒店利润'
,isnull((case when jd1.酒店利润=0 then '' else cast((jd2.酒店利润-jd1.酒店利润)/ABS(jd1.酒店利润)*100 as varchar(20))+'%' end),'') as 酒店利润环比
,isnull(jd1.张数,0) as '5月酒店间数'
,isnull(jd2.张数,0) as '6月酒店间数'
,(case when jd1.张数=0 then '' else ((jd2.张数-jd1.张数)*1.0/jd1.张数) end) as 酒店间数环比
from #cmp cmp
left join #gnjp1 gnjp1 on gnjp1.单位编号=Cmp.单位编号
left join #gnjp2 gnjp2 on gnjp2.单位编号=Cmp.单位编号
left join #gjjp1 gjjp1 on gjjp1.单位编号=Cmp.单位编号
left join #gjjp2 gjjp2 on gjjp2.单位编号=Cmp.单位编号
left join #jd1 jd1 on jd1.单位编号=Cmp.单位编号
left join #jd2 jd2 on jd2.单位编号=Cmp.单位编号 
order by 单位编号






