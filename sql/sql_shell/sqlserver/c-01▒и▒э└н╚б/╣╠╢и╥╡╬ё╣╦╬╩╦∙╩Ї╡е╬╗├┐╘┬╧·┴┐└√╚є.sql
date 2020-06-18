--拉取固定业务顾问单位客户的销量、利润
IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select t1.cmpid as 单位编号,t1.cmpname as 单位名称
,(case CustomerType when 'A' then '差旅单位客户' when 'C' then '旅游单位客户' else '' end) as 单位类型
,(CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END) as 合作状态
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as 开发人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as 客户主管
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as 维护人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as 差旅业务顾问
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as 旅游业务顾问
--,indate
into #cmp 
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
where 
 (select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID)='丁慧敏' --差旅顾问
 --(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID)='周升芸'--旅游顾问
and CustomerType='A'
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid

--select * from #cmp
/*
--注册月
select cmpid,indate from tbCompanyM where cmpid in 
(Select 单位编号 from #cmp)
--固定额度
select CmpId,CreateDate from HM_CompanyCreditInfo where CmpId in 
(Select 单位编号 from #cmp)group by CmpId,CreateDate
order by CmpId desc
*/
IF OBJECT_ID('tempdb.dbo.#air') IS NOT NULL DROP TABLE #air
IF OBJECT_ID('tempdb.dbo.#hotel_y') IS NOT NULL DROP TABLE #hotel_y
IF OBJECT_ID('tempdb.dbo.#hotel_z') IS NOT NULL DROP TABLE #hotel_z
IF OBJECT_ID('tempdb.dbo.#travel') IS NOT NULL DROP TABLE #travel
IF OBJECT_ID('tempdb.dbo.#huiwu') IS NOT NULL DROP TABLE #huiwu
IF OBJECT_ID('tempdb.dbo.#train') IS NOT NULL DROP TABLE #train


--机票
select c.cmpcode,MONTH(c.datetime) as 月份
,SUM(ISNULL(c.totprice,0)-ISNULL(r.totprice,0)) as 机票销量
,SUM(ISNULL(c.profit,0)+ISNULL(r.profit,0)) as 机票利润
into #air
from tbcash c
left join tbReti r on r.reno=c.reti and r.status2<>4
where c.cmpcode in
(Select 单位编号 from #cmp)and (c.datetime>='2018-04-01' and c.datetime<'2018-08-01')
--and c.inf=1
group by c.cmpcode,MONTH(c.datetime)


 
--酒店预付 
select cmpid,MONTH(prdate) as 月份,sum(price)预付酒店销量,sum(totprofit)预付酒店利润
into #hotel_y
from tbHtlcoupYf
where cmpid in 
(Select 单位编号 from #cmp)and (prdate>='2018-04-01' and prdate<'2018-08-01') and 
status !='-2'
group by cmpid,MONTH(prdate)

--酒店自付
select cmpid,MONTH(datetime) as 月份,sum(price)自付酒店销量,sum(totprofit)自付酒店利润
into #hotel_z
from tbHotelcoup
where cmpid in 
(Select 单位编号 from #cmp)and (datetime>='2018-04-01' and datetime<'2018-08-01') and 
status !='-2'
group by cmpid,MONTH(datetime)

--旅游
select cmpid,MONTH(OperDate) as 月份,SUM(XsPrice) as 旅游销量,SUM(Profit) as 旅游利润 
into #travel
from tbTrvCoup 
where Cmpid in 
(Select 单位编号 from #cmp)and (OperDate>='2018-04-01' and OperDate<'2018-08-01')
group by Cmpid,MONTH(OperDate)

--会务
select cmpid,MONTH(OperDate) as 月份,SUM(XsPrice) as 会务销量,SUM(Profit) as 会务利润 
into #huiwu
from tbConventionCoup 
where Cmpid in 
(Select 单位编号 from #cmp)and (OperDate>='2018-04-01' and OperDate<'2018-08-01')
group by Cmpid,MONTH(OperDate)

--火车票
select CmpId,MONTH(trainO.CreateDate) as 月份
,FLOOR(isnull(sum(RealPrice + trainU.Fuprice + PrintPrice),0)) -FLOOR(isnull(sum(trainU.RealPrice+r.Fee),0)) as 火车票销量
,FLOOR(isnull(Sum(trainU.Fuprice - CASE Tsource WHEN '铁友网' THEN 5 when '七彩阳光' then 1 ELSE 0 END),0))+ FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0))as 火车票利润
into #train
from tbTrainTicketInfo trainO
LEFT JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo
left join Train_ReturnTicket r on r.TickOrderDetailID = trainU.ID
where CmpId in 
(Select 单位编号 from #cmp)and (trainO.CreateDate>='2018-04-01' and trainO.CreateDate<'2018-08-01')
and (r.AuditTime >='2018-04-01' AND r.AuditTime<'2018-08-01')
and trainO.Isdisplay=0
group by CmpId,MONTH(trainO.CreateDate)

--IF OBJECT_ID('tempdb.dbo.#hz') IS NOT NULL DROP TABLE #hz
--select CompanyCode,COUNT(*) as hz
--into #hz
--from AccountStatement 
--where AccountPeriodAir1>='2018-04-01' and AccountPeriodAir1<'2018-08-01'
--group by CompanyCode


IF OBJECT_ID('tempdb.dbo.#pz') IS NOT NULL DROP TABLE #pz
select Cmp.*,air.月份,isnull(机票销量,0)+isnull(预付酒店销量,0)+isnull(自付酒店销量,0)+isnull(旅游销量,0)+isnull(会务销量,0)+isnull(火车票销量,0) as 总销量
--,(isnull(机票销量,0)+isnull(预付酒店销量,0)+isnull(自付酒店销量,0)+isnull(旅游销量,0)+isnull(会务销量,0)+isnull(火车票销量,0))/hz.hz as 月均销量
,isnull(机票利润,0)+isnull(预付酒店利润,0)+isnull(自付酒店利润,0)+isnull(旅游利润,0)+isnull(会务利润,0)+isnull(火车票利润,0) as 总利润
--,(isnull(机票利润,0)+isnull(预付酒店利润,0)+isnull(自付酒店利润,0)+isnull(旅游利润,0)+isnull(会务利润,0)+isnull(火车票利润,0))/hz.hz as 月均利润
--,''as 毛利率,isnull(hz.hz,0) as 合作月份数
,机票销量,机票利润,预付酒店销量,预付酒店利润,自付酒店销量,自付酒店利润,旅游销量,旅游利润,会务销量,会务利润,火车票销量,火车票利润 
into #pz
from #cmp cmp
left join #air air on air.cmpcode=Cmp.单位编号
left join #hotel_y hotel_y on hotel_y.cmpid=Cmp.单位编号 and hotel_y.月份=air.月份
left join #hotel_z hotel_z on hotel_z.cmpid=Cmp.单位编号 and hotel_z.月份=air.月份
left join #travel travel on travel.cmpid=Cmp.单位编号 and travel.月份=air.月份
left join #huiwu huiwu on huiwu.cmpid=Cmp.单位编号 and huiwu.月份=air.月份
left join #train train on train.cmpid=Cmp.单位编号 and Train.月份=air.月份
--left join #hz hz on hz.CompanyCode=Cmp.单位编号
order by 单位编号,air.月份

IF OBJECT_ID('tempdb.dbo.#pz2') IS NOT NULL DROP TABLE #pz2
select 单位编号,单位名称,月份,isnull(总销量,0) as 销量
into #pz2
from #pz

IF OBJECT_ID('tempdb.dbo.#pz3') IS NOT NULL DROP TABLE #pz3
select 单位编号,单位名称,月份,isnull(总利润,0) as 利润
into #pz3
from #pz


IF OBJECT_ID('tempdb.dbo.#pz4') IS NOT NULL DROP TABLE #pz4
SELECT * 
into #pz4
FROM #pz2 
AS P
PIVOT 
(
    SUM(销量) FOR 
    p.月份 IN ([4],[5],[6],[7])
) AS T1
order by 单位名称
IF OBJECT_ID('tempdb.dbo.#pz5') IS NOT NULL DROP TABLE #pz5
SELECT * 
into #pz5
FROM #pz3 
AS P
PIVOT 
(
    SUM(利润) FOR 
    p.月份 IN ([4],[5],[6],[7])
) AS T1
order by 单位名称

select pz4.单位编号,pz4.单位名称
,isnull(pz4.[4],0) as [4月销量]
,isnull(pz5.[4],0) as [4月利润]
,isnull(pz4.[5],0) as [5月销量] 
,isnull(pz5.[5],0) as [5月利润]
,isnull(pz4.[6],0) as [6月销量] 
,isnull(pz5.[6],0) as [6月利润] 
,isnull(pz4.[7],0) as [7月销量] 
,isnull(pz5.[7],0) as [7月利润] 
from #pz4 pz4
inner join #pz5 pz5 on pz5.单位编号=pz4.单位编号
