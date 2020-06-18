--机票销量、利润、张数

IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select t1.cmpid as 单位编号,t1.cmpname as 单位名称
,(case CustomerType when 'A' then '差旅单位客户' when 'C' then '旅游单位客户' else '' end) as 单位类型
,(CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END) as 合作状态
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as 开发人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as 客户主管
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as 维护人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as 差旅业务顾问
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as 旅游业务顾问
,indate
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
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid

select * from #cmp
where 单位编号<>''
and 开发人 in  ('谈嘉巍','沈正邦','马骏','胡启霏','王绅元','楼兆罡','范文涛','彭庆华','彭永飞','万方','姜从余')

--机票
select t1.开发人
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as 销量
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as 毛利 
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.单位编号
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where t1.indate>='2017-01-01'
and (t3.datetime>='2017-05-01' and t3.datetime<'2017-06-01')
and 单位编号<>''
group by t1.开发人
order by t1.开发人

--酒店
select t1.开发人
,sum(h1.price) as 酒店销量
,sum(h1.totprofit) as 酒店利润
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.单位编号 and h1.status<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where t1.indate>='2017-01-01' and
(h1.prdate>='2017-05-01' and h1.prdate<'2017-06-01') and 
status !='-2'
and 单位编号<>''
group by t1.开发人
order by t1.开发人


--旅游
select t1.开发人
,SUM(l1.XsPrice) as 旅游销量
,SUM(l1.Profit) as 旅游利润
from #cmp t1
left join tbTrvCoup l1 on l1.Cmpid=t1.单位编号
where t1.indate>='2017-01-01' and
 (l1.OperDate>='2017-05-01' and l1.OperDate<'2017-06-01')
and 单位编号<>''
group by t1.开发人
order by t1.开发人


--会务
select t1.开发人
,SUM(c1.XsPrice) as 旅游销量
,SUM(c1.Profit) as 旅游利润
from #cmp t1
left join tbConventionCoup c1 on c1.Cmpid=t1.单位编号
where t1.indate>='2017-01-01' and
 (c1.OperDate>='2017-05-01' and c1.OperDate<'2017-06-01')
and 单位编号<>''
group by t1.开发人
order by t1.开发人


--火车票
select t1.开发人
,FLOOR(isnull(sum(RealPrice + trainU.Fuprice + PrintPrice),0)) -FLOOR(isnull(sum(trainU.RealPrice+r.Fee),0)) as 火车票销量
,FLOOR(isnull(Sum(trainU.Fuprice - CASE Tsource WHEN '铁友网' THEN 5 when '七彩阳光' then 1 ELSE 0 END),0))+ FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0))as 火车票利润
from #cmp t1
left join tbTrainTicketInfo trainO on trainO.CmpId=t1.单位编号
LEFT JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo
left join Train_ReturnTicket r on r.TickOrderDetailID = trainU.ID
where t1.indate>='2017-01-01' and
(trainO.CreateDate>='2017-05-01' and trainO.CreateDate<'2017-06-01')
and (r.AuditTime >='2017-05-01' AND r.AuditTime<'2017-06-01')
and trainO.Isdisplay=0
and 单位编号<>''
group by t1.开发人
order by t1.开发人


