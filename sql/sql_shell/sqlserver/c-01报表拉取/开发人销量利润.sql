
--请按开发人（谈嘉巍、沈正邦、马骏、胡启霏、王绅元、楼兆罡、范文涛、彭庆华、彭永飞、万方、姜从余），拉取客户的总销量、总利润（机票、酒店、旅游、会务、火车票）

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





--应收会计
IF OBJECT_ID('tempdb.dbo.#yskj') IS NOT NULL DROP TABLE #yskj
select CmpId,MaintainName 
into #yskj
from  HM_ThePreservationOfHumanInformation tp where MaintainType=2 and IsDisplay=1
--运营经理
IF OBJECT_ID('tempdb.dbo.#yyjl') IS NOT NULL DROP TABLE #yyjl
select CmpId,MaintainName 
into #yyjl
from  HM_ThePreservationOfHumanInformation tp where MaintainType=9 and IsDisplay=1

IF OBJECT_ID('tempdb.dbo.#p3') IS NOT NULL DROP TABLE #p3
select cmp1.*,yskj.MaintainName as 应收会计,yyjl.MaintainName as 运营经理 
into #p3
from #cmp1 cmp1
left join #yskj yskj on yskj.cmpid=cmp1.单位编号
left join #yyjl yyjl on yyjl.cmpid=cmp1.单位编号





--账单账期
IF OBJECT_ID('tempdb.dbo.#p4') IS NOT NULL DROP TABLE #p4
select CompanyCode,SettlementTypeAir 
into #p4
from AccountStatement where AccountPeriodAir1<=GETDATE() AND AccountPeriodAir2>=GETDATE()

IF OBJECT_ID('tempdb.dbo.#p5') IS NOT NULL DROP TABLE #p5
select CmpId,DuiZhang1,DuiZhang2
into #p5
from  HM_CompanyAccountInfo where PstartDate<=GETDATE() and PendDate>=GETDATE()

IF OBJECT_ID('tempdb.dbo.#p6') IS NOT NULL DROP TABLE #p6
select p3.*,p4.settlementtypeair,p5.duizhang1,p5.duizhang2 
into #p6
from #p3 p3
left join #p4 p4 on p4.companycode=p3.单位编号
left join #p5 p5 on p5.cmpid=p3.单位编号


IF OBJECT_ID('tempdb.dbo.#hz') IS NOT NULL DROP TABLE #hz
select CompanyCode,COUNT(*) as hz
into #hz
from AccountStatement 
where AccountPeriodAir1>='2018-01-01' and AccountPeriodAir1<'2018-10-01'
group by CompanyCode

IF OBJECT_ID('tempdb.dbo.#p7') IS NOT NULL DROP TABLE #p7
select 单位编号,单位名称,duizhang1 as 账单账期,duizhang2 as 结算账期,settlementtypeair as 结算方式,应收会计,差旅业务顾问,维护人,售后主管,运营经理,开发人,合作状态,isnull(hz.hz,0)as hz 
into #p7
from #p6 p6
left join #hz hz on hz.CompanyCode=p6.单位编号
where 单位编号<>''





--机票
IF OBJECT_ID('tempdb.dbo.#jipiao') IS NOT NULL DROP TABLE #jipiao
select t1.单位编号
,sum(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as 机票销量
,sum(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as 机票利润 
into #jipiao
from #p6 t1
left join tbcash t3 on t3.cmpcode=t1.单位编号
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where  (t3.datetime>='2018-01-01' and t3.datetime<'2018-10-01')
and 单位编号<>''
group by t1.单位编号




--酒店预付
IF OBJECT_ID('tempdb.dbo.#hotel') IS NOT NULL DROP TABLE #hotel
select t1.单位编号
,sum(h1.price) as 酒店销量
,sum(h1.totprofit) as 酒店利润
into #hotel
from #p6 t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.单位编号 and h1.status<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where 
(h1.prdate>='2018-01-01' and h1.prdate<'2018-10-01') and 
status !='-2'
and 单位编号<>''
group by t1.单位编号





--酒店自付
IF OBJECT_ID('tempdb.dbo.#hotel_y') IS NOT NULL DROP TABLE #hotel_y
select t1.单位编号
,sum(h3.price) as 酒店销量
,sum(h3.totprofit) as 酒店利润
into #hotel_y
from #p6 t1
left join tbHotelcoup h3 on h3.cmpid=t1.单位编号 and h3.status<>-2
left join tbhtlyfchargeoff h4 on h4.coupid=h3.id
where 
(h3.datetime>='2018-01-01' and h3.datetime<'2018-10-01') and 
status !='-2'
and 单位编号<>''
group by t1.单位编号







--旅游
IF OBJECT_ID('tempdb.dbo.#trv') IS NOT NULL DROP TABLE #trv
select t1.单位编号
,SUM(l1.XsPrice) as 旅游销量
,SUM(l1.Profit) as 旅游利润
into #trv
from #p6 t1
left join tbTrvCoup l1 on l1.Cmpid=t1.单位编号
where 
 (l1.OperDate>='2018-01-01' and l1.OperDate<'2018-10-01')
and 单位编号<>''
group by t1.单位编号





--会务
IF OBJECT_ID('tempdb.dbo.#con') IS NOT NULL DROP TABLE #con
select t1.单位编号
,SUM(c1.XsPrice) as 会务销量
,SUM(c1.Profit) as 会务利润
into #con
from #p6 t1
left join tbConventionCoup c1 on c1.Cmpid=t1.单位编号
where 
 (c1.OperDate>='2018-01-01' and c1.OperDate<'2018-10-01')
and 单位编号<>''
group by t1.单位编号





--火车票
IF OBJECT_ID('tempdb.dbo.#train') IS NOT NULL DROP TABLE #train
select t1.单位编号
,FLOOR(isnull(sum(RealPrice + trainU.Fuprice + PrintPrice),0)) -FLOOR(isnull(sum(trainU.RealPrice-r.Fee),0)) as 火车票销量
,FLOOR(isnull(Sum(trainU.Fuprice - CASE Tsource WHEN '铁友网' THEN 5 when '七彩阳光' then 1 ELSE 0 END),0))+ FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0))as 火车票利润
into #train
from #p6 t1
left join tbTrainTicketInfo trainO on trainO.CmpId=t1.单位编号
LEFT JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo
left join Train_ReturnTicket r on r.TickOrderDetailID = trainU.ID
where 
(trainO.CreateDate>='2018-01-01' and trainO.CreateDate<'2018-10-01')
and (r.AuditTime >='2018-01-01' AND r.AuditTime<'2018-10-01')
and trainO.Isdisplay=0
and 单位编号<>''
group by t1.单位编号

select p7.单位编号,p7.单位名称,合作状态,hz as 合作月份,差旅业务顾问,运营经理,维护人,售后主管
,isnull(机票销量,0)+ISNULL(hotel.酒店销量,0)+ISNULL(hotel_y.酒店销量,0) as 差旅销量
,isnull(机票利润,0)+ISNULL(hotel.酒店利润,0)+ISNULL(hotel_y.酒店利润,0) as 差旅销量
from #p7 p7
left join #jipiao jipiao on jipiao.单位编号=p7.单位编号
left join #hotel hotel on hotel.单位编号=p7.单位编号
left join #hotel_y hotel_y on hotel_y.单位编号=p7.单位编号
left join #trv trv on trv.单位编号=p7.单位编号
left join #con con on con.单位编号=p7.单位编号
left join #train train on train.单位编号=p7.单位编号


