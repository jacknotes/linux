/*
 
现需要我们各组引导客户冲量进去。请帮忙提供“不开通特殊票价”的单位数据单独发给对应各组差旅运营经理，谢谢！
 
 UC号  单位名称     服务费    是否捆绑保险   MU近半年F ，J ，Y销量   MU近半年Y舱以下销量  差旅顾问  运营经理  客户经理
 
备注：自签二方三方的单位去除掉
陈永林  15:46:21
B M E K L N R S V T Z H

select * FROM [homsomdb].[dbo].[Trv_UCSettings]
  where BindAccidentInsurance is not null and BindAccidentInsurance <>''
*/

IF OBJECT_ID('tempdb.dbo.#company') IS NOT NULL DROP TABLE #company
SELECT 
u.Cmpid,
u.Name,
CASE WHEN ISNULL(BindAccidentInsurance,'')='' THEN '否' ELSE '是' END 是否捆绑保险
INTO #company
FROM homsomDB..Trv_UnitCompanies u 
LEFT JOIN homsomDB..Trv_UCSettings s ON u.UCSettingID=s.ID
WHERE 
IsSepPrice=0 --国内
AND CooperativeStatus NOT IN(0,4) AND u.Type='A'

IF OBJECT_ID('tempdb.dbo.#xlgaocang') IS NOT NULL DROP TABLE #xlgaocang
SELECT 
cmpcode,SUM(totprice) AS totprice,SUM(price+tax) AS pricetax 
INTO #xlgaocang
FROM tbcash WHERE datetime BETWEEN '2019-01-01' AND '2019-06-30' AND cmpcode<>'' 
AND nclass IN('F','J','Y') AND cmpcode IN(SELECT cmpid FROM #company) AND inf IN('0')
GROUP BY cmpcode

IF OBJECT_ID('tempdb.dbo.#xldicang') IS NOT NULL DROP TABLE #xldicang
SELECT  cmpcode,SUM(totprice) AS totprice,SUM(price+tax) AS pricetax 
INTO #xldicang
FROM tbcash WHERE datetime BETWEEN '2019-01-01' AND '2019-06-30' AND cmpcode<>'' 
AND nclass IN('B','M','E','K','L','N','R','S','V','T','Z','H') AND cmpcode IN(SELECT cmpid FROM #company) AND inf IN('0')
GROUP BY cmpcode



IF OBJECT_ID('tempdb.dbo.#Final') IS NOT NULL DROP TABLE #Final
SELECT 'UC'+c.Cmpid AS '单位编号',
c.Name AS '单位名称',
c.是否捆绑保险,
CONVERT(DECIMAL(18,1),ISNULL(g.totprice,0)) AS '高仓销量',
CONVERT(DECIMAL(18,1),ISNULL(d.totprice,0))  AS '低舱销量',
t.TcName AS 差旅顾问,
h.MaintainName AS 运营经理,
h1.MaintainName AS 客户经理,
i.GroupName AS 小组名 
INTO #Final
FROM #company c
LEFT JOIN #xlgaocang g ON c.Cmpid=g.cmpcode
LEFT JOIN #xldicang d ON c.Cmpid=d.cmpcode
LEFT JOIN dbo.HM_AgreementCompanyTC t ON c.Cmpid=t.Cmpid AND t.isDisplay=0 AND t.TcType=0
LEFT JOIN dbo.HM_ThePreservationOfHumanInformation h ON c.Cmpid=h.Cmpid AND h.IsDisplay=1 AND h.MaintainType=9
LEFT JOIN dbo.HM_ThePreservationOfHumanInformation h1 ON c.Cmpid=h1.Cmpid AND h1.IsDisplay=1 AND h1.MaintainType=1
LEFT JOIN dbo.Emppwd e ON t.TcName=e.empname
LEFT JOIN dbo.HM_TCGroupInfo i ON e.groupid=i.Pkey
ORDER BY i.GroupName

--自签二方三方的单位
if OBJECT_ID('tempdb..#zq') is not null drop table #zq
select top 2172 convert(varchar(10),NewEndTime,120) 日期,NewEndTime,Cmpid 
into #zq
from homsomDB..Trv_FlightTripartitePolicies t
left join homsomDB..Trv_UnitCompanies u on u.ID=t.UnitCompanyID
where (t.Name like '%两方%' or t.Name like '%三方%' or t.Name like '%sme%' )
and u.Type='a' and u.CooperativeStatus not in ('0','4')
order by 日期 desc

SELECT * FROM #Final f WHERE f.单位编号 NOT IN(select 'UC'+x.CmpId from ehomsom..tbCompanyXY x 
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=x.CmpId
where x.Type=1 and IsSelfRv=1 and CooperativeStatus not in ('0','4')
and u.Type='A') 