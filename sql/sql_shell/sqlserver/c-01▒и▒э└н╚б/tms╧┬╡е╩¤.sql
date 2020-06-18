--开通TMS的单位 差旅顾问 运营经理 下单数 有登录名的常旅客数量

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
from topway..tbCompanyM t1
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
from  topway..HM_ThePreservationOfHumanInformation tp where MaintainType=6 and IsDisplay=1
--运营经理
IF OBJECT_ID('tempdb.dbo.#yyjl') IS NOT NULL DROP TABLE #yyjl
select CmpId,MaintainName 
into #yyjl
from  topway..HM_ThePreservationOfHumanInformation tp where MaintainType=9 and IsDisplay=1

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
where 单位编号<>'' and 合作状态 not like ('%终止%')

--select * from #p3

IF OBJECT_ID('tempdb.dbo.#up') IS NOT NULL DROP TABLE #up
select up.cmpid as 单位编号,up.Name as 单位名称,COUNT(*) as up
into #up
from homsomDB..Trv_UCSettings uc
inner join Trv_UnitCompanies up on up.UCSettingID=uc.ID
left join Trv_UnitPersons p on p.CompanyID=up.ID
left join Trv_Human h on h.ID=p.ID and IsDisplay=1
left join Trv_UPRanks k on k.ID=p.UPRankID
where Enabled=1
and h.Name is not null
and h.Name<>''
and UserName<>'' 
and UserName is not null
group by up.cmpid,up.Name
order by Cmpid


--机票下单数-线上
IF OBJECT_ID('tempdb.dbo.#a1') IS NOT NULL DROP TABLE #a1
select 
	ROW_NUMBER() over(order by uc.Cmpid) as 序列号,
	uc.Cmpid as 单位编号,uc.Name as 单位名称,COUNT(*) as 下单数 
	into #a1
	from homsomDB..Trv_CompanyTravels t1
left join homsomDB..Trv_UnitCompanies uc on uc.ID=t1.UnitCompanyID
left join  homsomDB..Trv_ItktBookings t2 on t1.ID=t2.TravelID
left join homsomDB..Trv_TktBookings t3 on t2.ID=t3.ID
where t3.AdminStatus in (2,3,4,5) and t3.CreateDate>='2018-10-01' and t3.CreateDate<'2018-11-01'
AND BookingSource IN(1,5,10,11) 
group by uc.Cmpid,uc.Name

--酒店下单数-线上
IF OBJECT_ID('tempdb.dbo.#h1') IS NOT NULL DROP TABLE #h1
select ROW_NUMBER() over(order by uc.Cmpid) as 序列号,
	uc.Cmpid as 单位编号,uc.Name as 单位名称,COUNT(*) as 下单数 
	into #h1
	from homsomDB..Trv_UnitCompanies uc 	
left join [HotelOrderDB].[dbo].[HTL_Orders] a on a.CMPID=uc.Cmpid
where a.CreateDate>= '2018-10-01' and a.CreateDate<='2018-11-01'  and a.Status IN (40,92)
and Resource in (1,3)
group by uc.Cmpid,uc.Name




--机票下单数-线下
IF OBJECT_ID('tempdb.dbo.#a2') IS NOT NULL DROP TABLE #a2
select 
	ROW_NUMBER() over(order by uc.Cmpid) as 序列号,
	uc.Cmpid as 单位编号,uc.Name as 单位名称,COUNT(*) as 下单数 
	into #a2
	from homsomDB..Trv_CompanyTravels t1
left join homsomDB..Trv_UnitCompanies uc on uc.ID=t1.UnitCompanyID
left join  homsomDB..Trv_ItktBookings t2 on t1.ID=t2.TravelID
left join homsomDB..Trv_TktBookings t3 on t2.ID=t3.ID
where t3.AdminStatus in (2,3,4,5) and t3.CreateDate>='2018-10-01' and t3.CreateDate<'2018-11-01'
--AND BookingSource IN(1,5,10,11) 
group by uc.Cmpid,uc.Name

--酒店下单数-线下
IF OBJECT_ID('tempdb.dbo.#h2') IS NOT NULL DROP TABLE #h2
select ROW_NUMBER() over(order by uc.Cmpid) as 序列号,
	uc.Cmpid as 单位编号,uc.Name as 单位名称,COUNT(*) as 下单数 
	into #h2
	from homsomDB..Trv_UnitCompanies uc 	
left join [HotelOrderDB].[dbo].[HTL_Orders] a on a.CMPID=uc.Cmpid
where a.CreateDate>= '2018-10-01' and a.CreateDate<='2018-11-01'  and a.Status IN (40,92)
--and Resource in (1,3)
group by uc.Cmpid,uc.Name

--微信关注数
IF OBJECT_ID('tempdb.dbo.#wx') IS NOT NULL DROP TABLE #wx
SELECT T2.Name AS 企业名称,('UC'+T2.Cmpid) AS UC号,COUNT(1) AS 关注数 
into #wx
FROM dbo.Wechat_UserAssociation T1
LEFT JOIN  dbo.Trv_UnitCompanies T2 ON T1.CompanyId=T2.ID
GROUP BY T2.Name,T2.Cmpid


--线上
IF OBJECT_ID('tempdb.dbo.#p4') IS NOT NULL DROP TABLE #p4
select p3.单位编号,p3.单位名称,p3.差旅业务顾问,p3.运营经理,isnull(up,0) as 账号数,isnull(a1.下单数,0) as 机票下单数,ISNULL(h1.下单数,0) as 酒店下单数,isnull(关注数,0) as 微信关注数
into #p4
from #p3 p3
inner join #up up on up.单位编号=p3.单位编号
left join #a1 a1 on a1.单位编号=up.单位编号
left join #h1 h1 on h1.单位编号=up.单位编号
left join #wx wx on wx.UC号='UC'+p3.单位编号
where p3.单位编号 not in ('000003','000006')
--and 运营经理='劳黎黎'
order by p3.运营经理,p3.差旅业务顾问,p3.单位编号

select 差旅业务顾问,sum(微信关注数)h from #p4
group by 差旅业务顾问
order by h desc







--线下
IF OBJECT_ID('tempdb.dbo.#p5') IS NOT NULL DROP TABLE #p5
select p3.单位编号,p3.单位名称,p3.差旅业务顾问,p3.运营经理,isnull(up,0) as 账号数,isnull(a2.下单数,0) as 机票下单数,ISNULL(h2.下单数,0) as 酒店下单数,isnull(关注数,0) as 微信关注数
into #p5
from #p3 p3
inner join #up up on up.单位编号=p3.单位编号
left join #a2 a2 on a2.单位编号=up.单位编号
left join #h2 h2 on h2.单位编号=up.单位编号
left join #wx wx on wx.UC号='UC'+p3.单位编号
where p3.单位编号 not in ('000003','000006')
--and 运营经理='劳黎黎'
order by p3.运营经理,p3.差旅业务顾问,p3.单位编号





IF OBJECT_ID('tempdb.dbo.#p10') IS NOT NULL DROP TABLE #p10
select p4.单位编号,p4.单位名称,p4.机票下单数+p4.酒店下单数 as 线上订单数,p4.机票下单数+p4.酒店下单数+p5.机票下单数+p5.酒店下单数 as 全部订单数,p4.微信关注数,p4.差旅业务顾问,p4.运营经理
into #p10
from #p4 p4
left join #p5 p5 on p5.单位编号=p4.单位编号









------------------------------


--11月

--开通TMS的单位 差旅顾问 运营经理 下单数 有登录名的常旅客数量





--机票下单数-线上
IF OBJECT_ID('tempdb.dbo.#a3') IS NOT NULL DROP TABLE #a3
select 
	ROW_NUMBER() over(order by uc.Cmpid) as 序列号,
	uc.Cmpid as 单位编号,uc.Name as 单位名称,COUNT(*) as 下单数 
	into #a3
	from homsomDB..Trv_CompanyTravels t1
left join homsomDB..Trv_UnitCompanies uc on uc.ID=t1.UnitCompanyID
left join  homsomDB..Trv_ItktBookings t2 on t1.ID=t2.TravelID
left join homsomDB..Trv_TktBookings t3 on t2.ID=t3.ID
where t3.AdminStatus in (2,3,4,5) and t3.CreateDate>='2018-11-01' and t3.CreateDate<'2018-11-02'
AND BookingSource IN(1,5,10,11) 
group by uc.Cmpid,uc.Name

--酒店下单数-线上
IF OBJECT_ID('tempdb.dbo.#h3') IS NOT NULL DROP TABLE #h3
select ROW_NUMBER() over(order by uc.Cmpid) as 序列号,
	uc.Cmpid as 单位编号,uc.Name as 单位名称,COUNT(*) as 下单数 
	into #h3
	from homsomDB..Trv_UnitCompanies uc 	
left join [HotelOrderDB].[dbo].[HTL_Orders] a on a.CMPID=uc.Cmpid
where a.CreateDate>= '2018-11-01' and a.CreateDate<='2018-11-02'  and a.Status IN (40,92)
and Resource in (1,3)
group by uc.Cmpid,uc.Name




--机票下单数-线下
IF OBJECT_ID('tempdb.dbo.#a4') IS NOT NULL DROP TABLE #a4
select 
	ROW_NUMBER() over(order by uc.Cmpid) as 序列号,
	uc.Cmpid as 单位编号,uc.Name as 单位名称,COUNT(*) as 下单数 
	into #a4
	from homsomDB..Trv_CompanyTravels t1
left join homsomDB..Trv_UnitCompanies uc on uc.ID=t1.UnitCompanyID
left join  homsomDB..Trv_ItktBookings t2 on t1.ID=t2.TravelID
left join homsomDB..Trv_TktBookings t3 on t2.ID=t3.ID
where t3.AdminStatus in (2,3,4,5) and t3.CreateDate>='2018-11-01' and t3.CreateDate<'2018-11-02'
--AND BookingSource IN(1,5,10,11) 
group by uc.Cmpid,uc.Name

--酒店下单数-线下
IF OBJECT_ID('tempdb.dbo.#h4') IS NOT NULL DROP TABLE #h4
select ROW_NUMBER() over(order by uc.Cmpid) as 序列号,
	uc.Cmpid as 单位编号,uc.Name as 单位名称,COUNT(*) as 下单数 
	into #h4
	from homsomDB..Trv_UnitCompanies uc 	
left join [HotelOrderDB].[dbo].[HTL_Orders] a on a.CMPID=uc.Cmpid
where a.CreateDate>= '2018-11-01' and a.CreateDate<='2018-11-02'  and a.Status IN (40,92)
--and Resource in (1,3)
group by uc.Cmpid,uc.Name

--微信关注数
IF OBJECT_ID('tempdb.dbo.#wx2') IS NOT NULL DROP TABLE #wx2
SELECT T2.Name AS 企业名称,('UC'+T2.Cmpid) AS UC号,COUNT(1) AS 关注数 
into #wx2
FROM dbo.Wechat_UserAssociation T1
LEFT JOIN  dbo.Trv_UnitCompanies T2 ON T1.CompanyId=T2.ID
GROUP BY T2.Name,T2.Cmpid


--线上
IF OBJECT_ID('tempdb.dbo.#p6') IS NOT NULL DROP TABLE #p6
select p3.单位编号,p3.单位名称,p3.差旅业务顾问,p3.运营经理,isnull(up,0) as 账号数,isnull(a3.下单数,0) as 机票下单数,ISNULL(h3.下单数,0) as 酒店下单数,isnull(关注数,0) as 微信关注数
into #p6
from #p3 p3
inner join #up up on up.单位编号=p3.单位编号
left join #a3 a3 on a3.单位编号=up.单位编号
left join #h3 h3 on h3.单位编号=up.单位编号
left join #wx2 wx2 on wx2.UC号='UC'+p3.单位编号
where p3.单位编号 not in ('000003','000006')
--and 运营经理='劳黎黎'
order by p3.运营经理,p3.差旅业务顾问,p3.单位编号





--线下
IF OBJECT_ID('tempdb.dbo.#p7') IS NOT NULL DROP TABLE #p7
select p3.单位编号,p3.单位名称,p3.差旅业务顾问,p3.运营经理,isnull(up,0) as 账号数,isnull(a4.下单数,0) as 机票下单数,ISNULL(h4.下单数,0) as 酒店下单数,isnull(关注数,0) as 微信关注数
into #p7
from #p3 p3
inner join #up up on up.单位编号=p3.单位编号
left join #a4 a4 on a4.单位编号=up.单位编号
left join #h4 h4 on h4.单位编号=up.单位编号
left join #wx2 wx2 on wx2.UC号='UC'+p3.单位编号
where p3.单位编号 not in ('000003','000006')
--and 运营经理='劳黎黎'
order by p3.运营经理,p3.差旅业务顾问,p3.单位编号

IF OBJECT_ID('tempdb.dbo.#p11') IS NOT NULL DROP TABLE #p11
select p6.单位编号,p6.单位名称,p6.机票下单数+p6.酒店下单数 as 线上订单数,p6.机票下单数+p6.酒店下单数+p7.机票下单数+p7.酒店下单数 as 全部订单数,p6.微信关注数,p6.差旅业务顾问,p6.运营经理
into #p11
from #p6 p6
left join #p7 p7 on p7.单位编号=p6.单位编号



select p10.单位编号,p10.单位名称,p10.差旅业务顾问,p10.运营经理,p10.线上订单数 as '10月线上订单数',p10.全部订单数 as '10月全部订单数',p11.线上订单数 as '11月1日线上订单数'
,p11.全部订单数 as '11月1日全部订单数',p11.微信关注数 
from #p10 p10
left join #p11 p11 on p11.单位编号=p10.单位编号
where p10.全部订单数<>0
order by 运营经理,差旅业务顾问,p10.全部订单数 DESC


