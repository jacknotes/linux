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
where hztype not in (0,4)
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid

--维护人
IF OBJECT_ID('tempdb.dbo.#whr') IS NOT NULL DROP TABLE #whr
select distinct 维护人 
into #whr
from #cmp1
where 单位编号<>''
and 维护人 in ('王涛','汤慧祥','姚迪华','黄嘉瑶')

IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select * 
into #cmp
from #cmp1
where 维护人 in ('王涛','汤慧祥','姚迪华','黄嘉瑶')
and 单位类型='差旅单位客户'

--select * from #cmp

--机票
IF OBJECT_ID('tempdb.dbo.#jipiao_old') IS NOT NULL DROP TABLE #jipiao_old
select t1.维护人
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as 销量
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as 毛利 
into #jipiao_old
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.单位编号
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where t1.indate<'2018-01-01'
and (t3.datetime>='2018-09-01' and t3.datetime<'2018-10-01')
and 单位编号<>''
group by t1.维护人
order by t1.维护人

IF OBJECT_ID('tempdb.dbo.#jipiao_new') IS NOT NULL DROP TABLE #jipiao_new
select t1.维护人
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as 销量
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as 毛利 
into #jipiao_new
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.单位编号
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where t1.indate>='2018-01-01'
and (t3.datetime>='2018-09-01' and t3.datetime<'2018-10-01')
and 单位编号<>''
group by t1.维护人
order by t1.维护人


IF OBJECT_ID('tempdb.dbo.#ta') IS NOT NULL DROP TABLE #ta
IF OBJECT_ID('tempdb.dbo.#tb') IS NOT NULL DROP TABLE #tb
--老客户
select 
t1.维护人
,isnull(销量,0) ta1
,isnull(毛利,0) ta2
into #ta
from #whr t1
left join #jipiao_old jo on jo.维护人=t1.维护人 
order by t1.维护人
--新客户
select 
t1.维护人
,isnull(销量,0) tb1
,isnull(毛利,0) tb2
into #tb
from #whr t1
left join #jipiao_new jo on jo.维护人=t1.维护人 
order by t1.维护人

--酒店
IF OBJECT_ID('tempdb.dbo.#hotel_old') IS NOT NULL DROP TABLE #hotel_old
select t1.维护人
,sum(h1.price) as 酒店销量
,sum(h1.totprofit) as 酒店利润
into #hotel_old
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.单位编号 and h1.status2<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where t1.indate<'2018-01-01' and
(h1.prdate>='2018-09-01' and h1.prdate<'2018-10-01') and 
status !='-2'
and 单位编号<>''
group by t1.维护人
order by t1.维护人

IF OBJECT_ID('tempdb.dbo.#hotel_new') IS NOT NULL DROP TABLE #hotel_new
select t1.维护人
,sum(h1.price) as 酒店销量
,sum(h1.totprofit) as 酒店利润
into #hotel_new
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.单位编号 and h1.status2<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where t1.indate>='2018-01-01' and
(h1.prdate>='2018-09-01' and h1.prdate<'2018-10-01') and 
status !='-2'
and 单位编号<>''
group by t1.维护人
order by t1.维护人


IF OBJECT_ID('tempdb.dbo.#ha') IS NOT NULL DROP TABLE #ha
IF OBJECT_ID('tempdb.dbo.#hb') IS NOT NULL DROP TABLE #hb
--老客户
select 
t1.维护人
,isnull(酒店销量,0) ha1
,isnull(酒店利润,0) ha2
into #ha
from #whr t1
left join #hotel_old jo on jo.维护人=t1.维护人 
order by t1.维护人
--新客户
select 
t1.维护人
,isnull(酒店销量,0) hb1
,isnull(酒店利润,0) hb2
into #hb
from #whr t1
left join #hotel_new jo on jo.维护人=t1.维护人 
order by t1.维护人


--酒店自付
IF OBJECT_ID('tempdb.dbo.#hotel_old_y') IS NOT NULL DROP TABLE #hotel_old_y
select t1.维护人
,sum(h3.price) as 酒店销量
,sum(h3.totprofit) as 酒店利润
into #hotel_old_y
from #cmp t1
left join tbHotelcoup h3 on h3.cmpid=t1.单位编号 and h3.status<>-2
left join tbhtlyfchargeoff h4 on h4.coupid=h3.id
where t1.indate<'2018-01-01' and
(h3.datetime>='2018-09-01' and h3.datetime<'2018-10-01') and 
status !='-2'
and 单位编号<>''
group by t1.维护人
order by t1.维护人

IF OBJECT_ID('tempdb.dbo.#hotel_new_y') IS NOT NULL DROP TABLE #hotel_new_y
select t1.维护人
,sum(h3.price) as 酒店销量
,sum(h3.totprofit) as 酒店利润
into #hotel_new_y
from #cmp t1
left join tbHotelcoup h3 on h3.cmpid=t1.单位编号 and h3.status<>-2
left join tbhtlyfchargeoff h4 on h4.coupid=h3.id
where t1.indate>='2018-01-01' and
(h3.datetime>='2018-09-01' and h3.datetime<'2018-10-01') and 
status !='-2'
and 单位编号<>''
group by t1.维护人
order by t1.维护人

IF OBJECT_ID('tempdb.dbo.#za') IS NOT NULL DROP TABLE #za
IF OBJECT_ID('tempdb.dbo.#zb') IS NOT NULL DROP TABLE #zb
--老客户
select 
t1.维护人
,isnull(酒店销量,0) za1
,isnull(酒店利润,0) za2
into #za
from #whr t1
left join #hotel_old_y jo on jo.维护人=t1.维护人 
order by t1.维护人
--新客户
select 
t1.维护人
,isnull(酒店销量,0) zb1
,isnull(酒店利润,0) zb2
into #zb
from #whr t1
left join #hotel_new_y jo on jo.维护人=t1.维护人 
order by t1.维护人


--旅游
IF OBJECT_ID('tempdb.dbo.#trv_old') IS NOT NULL DROP TABLE #trv_old
select t1.维护人
,SUM(l1.XsPrice) as 旅游销量
,SUM(l1.Profit) as 旅游利润
into #trv_old
from #cmp t1
left join tbTrvCoup l1 on l1.Cmpid=t1.单位编号
where t1.indate<'2018-01-01' and
 (l1.OperDate>='2018-09-01' and l1.OperDate<'2018-10-01')
and 单位编号<>''
group by t1.维护人
order by t1.维护人

IF OBJECT_ID('tempdb.dbo.#trv_new') IS NOT NULL DROP TABLE #trv_new
select t1.维护人
,SUM(l1.XsPrice) as 旅游销量
,SUM(l1.Profit) as 旅游利润
into #trv_new
from #cmp t1
left join tbTrvCoup l1 on l1.Cmpid=t1.单位编号
where t1.indate>='2018-01-01' and
 (l1.OperDate>='2018-09-01' and l1.OperDate<'2018-10-01')
and 单位编号<>''
group by t1.维护人
order by t1.维护人


IF OBJECT_ID('tempdb.dbo.#la') IS NOT NULL DROP TABLE #la
IF OBJECT_ID('tempdb.dbo.#lb') IS NOT NULL DROP TABLE #lb
--老客户
select 
t1.维护人
,isnull(旅游销量,0) la1
,isnull(旅游利润,0) la2
into #la
from #whr t1
left join #trv_old jo on jo.维护人=t1.维护人 
order by t1.维护人
--新客户
select 
t1.维护人
,isnull(旅游销量,0) lb1
,isnull(旅游利润,0) lb2
into #lb
from #whr t1
left join #trv_new jo on jo.维护人=t1.维护人 
order by t1.维护人


--会务
IF OBJECT_ID('tempdb.dbo.#con_old') IS NOT NULL DROP TABLE #con_old
select t1.维护人
,SUM(c1.XsPrice) as 会务销量
,SUM(c1.Profit) as 会务利润
into #con_old
from #cmp t1
left join tbConventionCoup c1 on c1.Cmpid=t1.单位编号
where t1.indate<'2018-01-01' and
 (c1.OperDate>='2018-09-01' and c1.OperDate<'2018-10-01')
and 单位编号<>''
group by t1.维护人
order by t1.维护人

IF OBJECT_ID('tempdb.dbo.#con_new') IS NOT NULL DROP TABLE #con_new
select t1.维护人
,SUM(c1.XsPrice) as 会务销量
,SUM(c1.Profit) as 会务利润
into #con_new
from #cmp t1
left join tbConventionCoup c1 on c1.Cmpid=t1.单位编号
where t1.indate>='2018-01-01' and
 (c1.OperDate>='2018-09-01' and c1.OperDate<'2018-10-01')
and 单位编号<>''
group by t1.维护人
order by t1.维护人


IF OBJECT_ID('tempdb.dbo.#ca') IS NOT NULL DROP TABLE #ca
IF OBJECT_ID('tempdb.dbo.#cb') IS NOT NULL DROP TABLE #cb
--老客户
select 
t1.维护人
,isnull(会务销量,0) ca1
,isnull(会务利润,0) ca2
into #ca
from #whr t1
left join #con_old jo on jo.维护人=t1.维护人 
order by t1.维护人
--新客户
select 
t1.维护人
,isnull(会务销量,0) cb1
,isnull(会务利润,0) cb2
into #cb
from #whr t1
left join #con_new jo on jo.维护人=t1.维护人 
order by t1.维护人



--火车票
IF OBJECT_ID('tempdb.dbo.#train_old') IS NOT NULL DROP TABLE #train_old
select t1.维护人
,FLOOR(isnull(sum(RealPrice + trainU.Fuprice + PrintPrice),0)) -FLOOR(isnull(sum(trainU.RealPrice+r.Fee),0)) as 火车票销量
,FLOOR(isnull(Sum(trainU.Fuprice - CASE Tsource WHEN '铁友网' THEN 5 when '七彩阳光' then 1 ELSE 0 END),0))+ FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0))as 火车票利润
into #train_old
from #cmp t1
left join tbTrainTicketInfo trainO on trainO.CmpId=t1.单位编号
LEFT JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo
left join Train_ReturnTicket r on r.TickOrderDetailID = trainU.ID
where t1.indate<'2018-01-01' and
(trainO.CreateDate>='2018-09-01' and trainO.CreateDate<'2018-10-01')
and (r.AuditTime >='2018-09-01' AND r.AuditTime<'2018-10-01')
and trainO.Isdisplay=0
and 单位编号<>''
group by t1.维护人
order by t1.维护人

IF OBJECT_ID('tempdb.dbo.#train_new') IS NOT NULL DROP TABLE #train_new
select t1.维护人
,FLOOR(isnull(sum(RealPrice + trainU.Fuprice + PrintPrice),0)) -FLOOR(isnull(sum(trainU.RealPrice+r.Fee),0)) as 火车票销量
,FLOOR(isnull(Sum(trainU.Fuprice - CASE Tsource WHEN '铁友网' THEN 5 when '七彩阳光' then 1 ELSE 0 END),0))+ FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0))as 火车票利润
into #train_new
from #cmp t1
left join tbTrainTicketInfo trainO on trainO.CmpId=t1.单位编号
LEFT JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo
left join Train_ReturnTicket r on r.TickOrderDetailID = trainU.ID
where t1.indate>='2018-01-01' and
(trainO.CreateDate>='2018-09-01' and trainO.CreateDate<'2018-10-01')
and (r.AuditTime >='2018-09-01' AND r.AuditTime<'2018-10-01')
and trainO.Isdisplay=0
and 单位编号<>''
group by t1.维护人
order by t1.维护人


IF OBJECT_ID('tempdb.dbo.#fa') IS NOT NULL DROP TABLE #fa
IF OBJECT_ID('tempdb.dbo.#fb') IS NOT NULL DROP TABLE #fb
--老客户
select 
t1.维护人
,isnull(火车票销量,0) fa1
,isnull(火车票利润,0) fa2
into #fa
from #whr t1
left join #train_old jo on jo.维护人=t1.维护人 
order by t1.维护人
--新客户
select 
t1.维护人
,isnull(火车票销量,0) fb1
,isnull(火车票利润,0) fb2
into #fb
from #whr t1
left join #train_new jo on jo.维护人=t1.维护人 
order by t1.维护人




select whr.维护人
,ta1+ha1+za1+la1+ca1+fa1 as 老客户总销量
,ta2+ha2+za2+la2+ca2+fa2 as 老客户总利润
,tb1+hb1+zb1+lb1+cb1+fb1 as 新客户总销量
,tb2+hb2+zb2+lb2+cb2+fb2 as 新客户总利润
,Ta.ta1 as 老客户机票销量,Ta.ta2 as 老客户机票利润
,tb.tb1 as 新客户机票销量,tb.tb2 as 新客户机票利润
,ha.ha1 as 老客户预付酒店销量,ha.ha2 as 老客户预付酒店利润
,hb.hb1 as 新客户预付酒店销量,hb.hb2 as 新客户预付酒店利润
,za.za1 as 老客户自付酒店销量,za.za2 as 老客户自付酒店利润
,zb.zb1 as 新客户自付酒店销量,zb.zb2 as 新客户自付酒店利润
,la.la1 as 老客户旅游销量,la.la2 as 老客户旅游利润
,lb.lb1 as 新客户旅游销量,lb.lb2 as 新客户旅游利润
,ca.ca1 as 老客户会务销量,ca.ca2 as 老客户会务利润
,cb.cb1 as 新客户会务销量,cb.cb2 as 新客户会务利润
,fa.fa1 as 老客户火车票销量,fa.fa2 as 老客户火车票利润
,fb.fb1 as 新客户火车票销量,fb.fb2 as 新客户火车票利润

from #whr whr
left join #ta ta on ta.维护人=whr.维护人
left join #tb tb on tb.维护人=whr.维护人
left join #ha ha on ha.维护人=whr.维护人
left join #hb hb on hb.维护人=whr.维护人
left join #za za on za.维护人=whr.维护人
left join #zb zb on zb.维护人=whr.维护人
left join #la la on la.维护人=whr.维护人
left join #lb lb on lb.维护人=whr.维护人
left join #ca ca on ca.维护人=whr.维护人
left join #cb cb on cb.维护人=whr.维护人
left join #fa fa on fa.维护人=whr.维护人
left join #fb fb on fb.维护人=whr.维护人


