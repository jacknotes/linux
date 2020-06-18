

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

--select * from #cmp1 where indate>='2018-01-01'

--旅游10月之后 新客户
select cmp1.开发人,SUM(DisCountProfit) as 计提利润 from tbTrvCoup c
inner join tbTravelBudget b on b.TrvId=c.TrvId
inner join #cmp1 cmp1 on cmp1.单位编号=c.Cmpid
where c.OperDate>='2019-03-01' and c.OperDate<'2019-04-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
and cmp1.indate>'2018-04-01'
group by cmp1.开发人
order by 计提利润 desc


--会务10月之后 新客户
select c.Sales  as 会务顾问,SUM(Profit) as 计提利润 from tbConventionCoup c
inner join tbConventionBudget b on b.ConventionId=c.ConventionId
inner join #cmp1 cmp1 on cmp1.单位编号=c.Cmpid
where c.OperDate>='2019-03-01' and c.OperDate<'2019-04-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
--and cmp1.indate>='2018-01-01'
group by c.Sales
order by 计提利润 desc

--会务10月之前 新客户
select cmp1.开发人,SUM(DisCountProfit)  as 计提利润 from tbConventionCoup c
inner join tbConventionBudget b on b.ConventionId=c.ConventionId
inner join #cmp1 cmp1 on cmp1.单位编号=c.Cmpid
where c.OperDate>='2019-03-01' and c.OperDate<'2019-04-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
and cmp1.indate>'2018-04-01'
group by cmp1.开发人
order by 计提利润 desc

--最低价   提醒的最低价航班的起降时间
SELECT c.coupno,lp.Price 最低价,lp.DepartureTime,lp.ArrivalTime,lp.Flight
 FROM topway..tbcash c 
LEFT JOIN homsomDB..Trv_DomesticTicketRecord r ON c.coupno=r.RecordNumber
LEFT JOIN homsomDB..Trv_PnrInfos p ON r.PnrInfoID=p.ID
LEFT JOIN homsomDB..Trv_ItktBookings i ON p.ItktBookingID=i.ID
left join homsomDB..Trv_ItktBookingSegs its on i.ID=its.ItktBookingID
left join homsomDB..Trv_LowerstPrices lp on its.ID=lp.ItktBookingSegID
where c.coupno='AS002352363'
order by c.coupno

--到账改成未阅
select haschecked,* from FinanceERP_ClientBankRealIncomeDetail 
--update FinanceERP_ClientBankRealIncomeDetail set haschecked=0
where date='2019-03-28' and money='950'

--核销
select status,owe,CustomerPayWay,* from Topway..tbcash 
--update Topway..tbcash set status=1
where coupno='AS002372155'

--PC端 国内

select sum(price) 销量,COUNT(*) 张数 from Topway..tbcash  c
left join homsomDB..Trv_ItktBookings i on c.BaokuID=i.ID
where ModifyBillNumber in ('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201')
and cmpcode='020459'
and i.BookingSource='1'
--and i.BookingSource in ('5','10','11')
--and i.BookingSource in ('2','3','4')
and inf=0
and tickettype='电子票'


/*
CZ HO MF
2018-01-01至2019-03-31
先以单位得销量为排序，再以乘机人得乘机次数排序
航司 单位名称 乘机人 证件类型 证件号 乘机次数
*/
--销量汇总
IF OBJECT_ID('tempdb.dbo.#cmp2') IS NOT NULL DROP TABLE #cz1
SELECT cmpcode 单位编号CZ,SUM(totprice) 销量 
into #cz1
FROM Topway..V_TicketInfo 
WHERE ride='CZ'
AND tickettype='电子票'
and datetime>='2018-01-01'
and datetime<'2019-04-01'
group by cmpcode
order by 销量 desc

IF OBJECT_ID('tempdb.dbo.#cmp2') IS NOT NULL DROP TABLE #ho1
SELECT cmpcode 单位编号HO,SUM(totprice) 销量 
into #ho1
FROM Topway..V_TicketInfo 
WHERE ride='HO'
AND tickettype='电子票'
and datetime>='2018-01-01'
and datetime<'2019-04-01'
group by cmpcode
order by 销量 desc

IF OBJECT_ID('tempdb.dbo.#cmp2') IS NOT NULL DROP TABLE #mf1
SELECT cmpcode 单位编号MF,SUM(totprice) 销量 
into #mf1
FROM Topway..V_TicketInfo 
WHERE ride='MF'
AND tickettype='电子票'
and datetime>='2018-01-01'
and datetime<'2019-04-01'
group by cmpcode
order by 销量 desc

select isnull(un.Name,'') 单位名称,cz.销量 CZ销量,ho.销量 HO销量,mf.销量 MF销量 from #cz1 cz
left join homsomDB..Trv_UnitCompanies un on un.Cmpid=cz.单位编号CZ
left join #ho1 ho on ho.单位编号HO=cz.单位编号CZ
left join #mf1 mf on mf.单位编号MF=cz.单位编号CZ
order by CZ销量 desc 

--乘机人得乘机次数
select ride,un.Name,pasname,(case PassportType when '1' then '身份证' when '2' then '护照'
 when '3' then '学生证'  when '4' then '军人证'  when '5' then '回乡证'  when '6' then '外国人永久居留证'
  when '7' then '港澳通行证'  when '8' then '台湾通行证' when '9' then '国际海员证' when '10' then '台胞证'
  else '其他' end) 证件类型,
C.idno,COUNT(pasname) 乘机次数
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies un on un.Cmpid=c.cmpcode
left join homsomDB..Trv_Credentials cr on cr.CredentialNo=c.idno
where tickettype='电子票'
and datetime>='2018-01-01'
and datetime<'2019-04-01'
and reti<>''
and ride in ('CZ','HO','MF')
group by PassportType,C.idno,ride,un.Name,pasname
order by 乘机次数 desc

/*
CZ HO MF
2018-01-01至2019-03-31
先以单位得销量为排序，再以乘机人得乘机次数排序
航司 单位名称 乘机人 证件类型 证件号 乘机次数
*/
--CZ
SELECT cmpcode,ride,SUM(totprice) AS totprice INTO #cmpV FROM tbcash WHERE ride IN('CZ') AND 
datetime>='2018-01-01' AND datetime<'2019-04-01' AND inf=0 AND tickettype='电子票' AND cmpcode<>''
GROUP BY cmpcode,ride

SELECT cmpcode,ride,pasname,idno,COUNT(pasname) AS num INTO #perV FROM tbcash WHERE ride IN('CZ') AND 
datetime>='2018-01-01' AND datetime<'2019-04-01' AND inf=0 AND tickettype='电子票' AND cmpcode<>''
GROUP BY cmpcode,ride,pasname,idno

SELECT c.*,p.pasname,p.idno,p.num FROM #perV p
LEFT JOIN #cmpV c ON p.cmpcode=c.cmpcode AND p.ride=c.ride
ORDER BY c.totprice,p.num DESC

--HO
SELECT cmpcode,ride,SUM(totprice) AS totprice INTO #cmpV1 FROM tbcash WHERE ride IN('HO') AND 
datetime>='2018-01-01' AND datetime<'2019-04-01' AND inf=0 AND tickettype='电子票' AND cmpcode<>''
GROUP BY cmpcode,ride

SELECT cmpcode,ride,pasname,idno,COUNT(pasname) AS num INTO #perV1 FROM tbcash WHERE ride IN('HO') AND 
datetime>='2018-01-01' AND datetime<'2019-04-01' AND inf=0 AND tickettype='电子票' AND cmpcode<>''
GROUP BY cmpcode,ride,pasname,idno

SELECT c.*,p.pasname,p.idno,p.num FROM #perV1 p
LEFT JOIN #cmpV1 c ON p.cmpcode=c.cmpcode AND p.ride=c.ride
ORDER BY c.totprice,p.num DESC

--mf
SELECT cmpcode,ride,SUM(totprice) AS totprice INTO #cmpmf FROM tbcash WHERE ride IN('mf') AND 
datetime>='2018-01-01' AND datetime<'2019-04-01' AND inf=0 AND tickettype='电子票' AND cmpcode<>''
GROUP BY cmpcode,ride

SELECT cmpcode,ride,pasname,idno,COUNT(pasname) AS num INTO #permf FROM tbcash WHERE ride IN('mf') AND 
datetime>='2018-01-01' AND datetime<'2019-04-01' AND inf=0 AND tickettype='电子票' AND cmpcode<>''
GROUP BY cmpcode,ride,pasname,idno

SELECT c.*,p.pasname,p.idno,p.num FROM #permf p
LEFT JOIN #cmpmf c ON p.cmpcode=c.cmpcode AND p.ride=c.ride
ORDER BY c.totprice,p.num DESC


--更改支付方式（自付、垫付）
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set TCPayNo=PayNo,PayNo=null,AdvanceStatus=PayStatus,PayStatus=0,TcPayWay=CustomerPayWay,CustomerPayWay=0,TcPayDate=CustomerPayDate,CustomerPayDate='1900-01-01'
where coupno in('AS002376475','AS002376476')

select PayStatus,AdvanceStatus,PayNo,TCPayNo,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET AdvanceStatus=PayStatus,TCPayNo=PayNo,TcPayWay=CustomerPayWay,TcPayDate=CustomerPayDate,PayStatus=0,PayNo=NULL,CustomerPayWay=0,CustomerPayDate='1900-01-01'
WHERE coupno in('AS002376475','AS002376476')

