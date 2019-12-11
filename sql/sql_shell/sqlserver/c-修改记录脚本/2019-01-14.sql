--机票业务顾问信息

select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='汤凯杰',SpareTC='汤凯杰'
where coupno='AS001381069'

--12月份业务顾问国际机票张数

/*
1、国际机票张数=出票张数-退票张数-废票张数-改期张数-选位张数-纯利润张数
2、出票张数仅计算票类型为【电子票】、【婴儿票】、【团队定金】的数量，团队定金一个团仅可打印一张销售单，多打不计入。
3、如票类型为电子票，业务顾问误操作供应商来源为改期服务费、或行程为改期XXX，不计入出票张数。
4、退票按本月实际发生数量计算。如7月出票，9月发生退票，9月统计数量将扣减。

退票按本月实际发生计算（无论销售单出票日期在任何月份）
只要是废票，无论是否发生退票或者改期，一律算废票
票类型、航程、供应商来源任意一处有改期字眼，都算改期票
改期票发生退票，按退票算（改期票中没有退票）
*/


--第一步
IF OBJECT_ID('tempdb.dbo.#emp') IS NOT NULL DROP TABLE #emp
IF OBJECT_ID('tempdb.dbo.#gn') IS NOT NULL DROP TABLE #gn
IF OBJECT_ID('tempdb.dbo.#gn_gn') IS NOT NULL DROP TABLE #gn_gn
IF OBJECT_ID('tempdb.dbo.#gj') IS NOT NULL DROP TABLE #gj
IF OBJECT_ID('tempdb.dbo.#gj_gj') IS NOT NULL DROP TABLE #gj_gj
IF OBJECT_ID('tempdb.dbo.#r') IS NOT NULL DROP TABLE #r
IF OBJECT_ID('tempdb.dbo.#gj_zuofei') IS NOT NULL DROP TABLE #gj_zuofei
IF OBJECT_ID('tempdb.dbo.#gj_zuofei_gj') IS NOT NULL DROP TABLE #gj_zuofei_gj
IF OBJECT_ID('tempdb.dbo.#gj_gaiqi') IS NOT NULL DROP TABLE #gj_gaiqi
IF OBJECT_ID('tempdb.dbo.#gj_gaiqi_gj') IS NOT NULL DROP TABLE #gj_gaiqi_gj
IF OBJECT_ID('tempdb.dbo.#gj_xuanwei') IS NOT NULL DROP TABLE #gj_xuanwei
IF OBJECT_ID('tempdb.dbo.#gj_xuanwei_gj') IS NOT NULL DROP TABLE #gj_xuanwei_gj
IF OBJECT_ID('tempdb.dbo.#gj_chunlirun') IS NOT NULL DROP TABLE #gj_chunlirun
IF OBJECT_ID('tempdb.dbo.#gj_chunlirun_gj') IS NOT NULL DROP TABLE #gj_chunlirun_gj
--员工列表
SELECT ROW_NUMBER()OVER(ORDER BY t2.depOrder,t1.idnumber) idx,empname,team 
--INTO #emp 
from emppwd t1 LEFT JOIN dbo.EmpSysSetting t2 ON t1.team=t2.dep AND t2.ntype=2 where t1.dep = '运营部' and team like ('%差旅%') order by t2.depOrder,t1.idnumber 
--Get国内机票销量毛利报表
SELECT sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
INTO #gn
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-12-01 00:00:00' AND '2018-12-31 23:59:59') and sales<>''  and inf=0 and tickettype in ('电子票','婴儿票','团队定金')
GROUP BY sales,cmpcode  
UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit , SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-12-01 00:00:00' AND '2018-12-31 23:59:59') and SpareTC<>'' AND SpareTC<>sales and cmpcode<>''  and inf=0  and tickettype in ('电子票','婴儿票','团队定金')
GROUP BY SpareTC,cmpcode  ) T 
GROUP BY sales,cmpcode 
order by sales,cmpcode
--Get国际机票销量毛利报表
SELECT sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
INTO #gj
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-12-01 00:00:00' AND '2018-12-31 23:59:59') and sales<>''  and inf=1 and tickettype in ('电子票','婴儿票','团队定金')
GROUP BY sales,cmpcode  
UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-12-01 00:00:00' AND '2018-12-31 23:59:59') and SpareTC<>'' AND SpareTC<>sales and cmpcode<>''  and inf=1 and tickettype in ('电子票','婴儿票','团队定金')
GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
--Get退票毛利报表
SELECT sales,sum(Num) as Num, sum(totprice) as totprice,count(1) as pcs,sum(profit) as profit  ,inf
INTO #r
FROM (
	SELECT -sum(CASE WHEN tbcash.cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) as Num
	, sum(CASE WHEN tbcash.cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(tbReti.totprice,0)) as totprice
	, sales,count(*) as pcs ,sum(CASE WHEN tbcash.cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * tbreti.profit) as profit ,tbreti.inf
	FROM tbreti  
	LEFT join tbcash ON dbo.tbReti.reno = dbo.tbCash.reti and dbo.tbReti.ticketno = dbo.tbCash.ticketno 
	WHERE 
	--tbcash.datetime  BETWEEN '2018-05-01 00:00:00' AND '2018-05-31 23:59:59' and
	tbReti.ExamineDate BETWEEN '2018-12-01 00:00:00' AND '2018-12-31 23:59:59'
	AND  dbo.tbReti.status2 not in (3,4)  
	and tbcash.totprice>0
	and tbReti.coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+tbReti.ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type=1)   
	GROUP by sales,tbreti.inf  
	UNION all 
	SELECT -sum(0.5) as Num, sum(0.5 * isnull(tbReti.totprice,0)) as totprice,SpareTC as sales,count(*) as pcs 
	,sum(0.5 * tbreti.profit) as profit ,tbreti.inf
	FROM tbreti  left join tbcash ON dbo.tbReti.reno = dbo.tbCash.reti and dbo.tbReti.ticketno = dbo.tbCash.ticketno 
	WHERE 
	--tbcash.datetime  BETWEEN '2018-05-01 00:00:00' AND '2018-05-31 23:59:59' and
	tbReti.ExamineDate BETWEEN '2018-12-01 00:00:00' AND '2018-12-31 23:59:59'
	AND  dbo.tbReti.status2 not in (3,4)  
	and tbcash.totprice>0
	and tbReti.coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+tbcash.ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type=1) 
	AND SpareTC<>'' AND SpareTC<>sales and  tbcash.cmpcode<>''   
	GROUP by SpareTC,tbreti.inf )T  group by sales,inf order by sales
	
--第二步	 
--get作废列表(并且 totprice>0)
SELECT sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
INTO #gj_zuofei
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy 
FROM tbcash 
LEFT join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
INNER JOIN (SELECT coupno,ticketno FROM dbo.tbinvalid WHERE type in (0,1)) Inv ON inv.coupno=tbcash.coupno AND inv.ticketno LIKE '%'+tbcash.tcode+'-'+tbcash.ticketno+'%' 
WHERE dbo.tbcash.totprice>0 and (datetime BETWEEN '2018-12-01 00:00:00' AND '2018-12-31 23:59:59') and sales<>''  and inf=1 GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid INNER JOIN (SELECT coupno,ticketno FROM dbo.tbinvalid WHERE type=1) Inv ON inv.coupno=tbcash.coupno AND inv.ticketno LIKE '%'+tbcash.tcode+'-'+tbcash.ticketno+'%'  where  (datetime BETWEEN '2018-05-01 00:00:00' AND '2018-05-31 23:59:59') and SpareTC<>'' AND SpareTC<>sales and cmpcode<>''  and inf=1 GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
/*
--（只拉国际机票可不执行）
--get国内作废列表(并且 totprice>0)
SELECT sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
INTO #gn_zuofei
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy 
FROM tbcash 
LEFT join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
INNER JOIN (SELECT coupno,ticketno FROM dbo.tbinvalid WHERE type in (0,1)) Inv ON inv.coupno=tbcash.coupno AND inv.ticketno LIKE '%'+tbcash.tcode+'-'+tbcash.ticketno+'%' 
WHERE dbo.tbcash.totprice>0 and (datetime BETWEEN '2018-05-01 00:00:00' AND '2018-05-31 23:59:59') and sales<>''  and inf=0 GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid INNER JOIN (SELECT coupno,ticketno FROM dbo.tbinvalid WHERE type=1) Inv ON inv.coupno=tbcash.coupno AND inv.ticketno LIKE '%'+tbcash.tcode+'-'+tbcash.ticketno+'%'  where  (datetime BETWEEN '2018-05-01 00:00:00' AND '2018-05-31 23:59:59') and SpareTC<>'' AND SpareTC<>sales and cmpcode<>''  and inf=0 GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
*/
--第三步
--国际改期张数
select sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
into #gj_gaiqi
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-12-01 00:00:00' AND '2018-12-31 23:59:59') and sales<>''  and inf=1 and reti='' and tickettype in ('电子票','婴儿票','团队定金') and (route like ('%改期%') or  t_source like ('%改期%')) and route not like ('%选位%') and coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid where  (datetime BETWEEN '2018-05-01 00:00:00' AND '2018-05-31 23:59:59') and SpareTC<>'' AND SpareTC<>sales   and inf=1 and reti='' and tickettype in ('电子票','婴儿票','团队定金') and (route like ('%改期%') or  t_source like ('%改期%')) and route not like ('%选位%') GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
/*
--国内改期张数（只拉国际机票可不执行）
select sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
into #gn_gaiqi
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-05-01 00:00:00' AND '2018-05-31 23:59:59') and sales<>''  and inf=0 and reti='' and tickettype in ('电子票','婴儿票','团队定金') and (route like ('%改期%') or  t_source like ('%改期%')) and route not like ('%选位%') and coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid where  (datetime BETWEEN '2018-05-01 00:00:00' AND '2018-05-31 23:59:59') and SpareTC<>'' AND SpareTC<>sales   and inf=0 and reti='' and tickettype in ('电子票','婴儿票','团队定金') and (route like ('%改期%') or  t_source like ('%改期%')) and route not like ('%选位%') GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
*/
--第四步
--国际选位张数
select sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
into #gj_xuanwei
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-12-01 00:00:00' AND '2018-12-31 23:59:59') and sales<>''  and inf=1 and reti='' and tickettype in ('电子票','婴儿票','团队定金') and route like ('%选位%') and coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid where  (datetime BETWEEN '2018-05-01 00:00:00' AND '2018-05-31 23:59:59') and SpareTC<>'' AND SpareTC<>sales   and inf=1 and reti='' and tickettype in ('电子票','婴儿票','团队定金') and route like ('%选位%')   GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
/*
--国内选位张数（只拉国际机票可不执行）
select sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
into #gn_xuanwei
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-05-01 00:00:00' AND '2018-05-31 23:59:59') and sales<>''  and inf=0 and reti='' and tickettype in ('电子票','婴儿票','团队定金') and route like ('%选位%') and coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid where  (datetime BETWEEN '2018-05-01 00:00:00' AND '2018-05-31 23:59:59') and SpareTC<>'' AND SpareTC<>sales   and inf=0 and reti='' and tickettype in ('电子票','婴儿票','团队定金') and route like ('%选位%')  GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
*/
--第五步
--国际纯利润I张数
select sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
into #gj_chunlirun
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-12-01 00:00:00' AND '2018-12-31 23:59:59') and sales<>''  and inf=1 and reti='' and tickettype in ('电子票','婴儿票','团队定金') and t_source like ('%纯利润I%') and coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid where  (datetime BETWEEN '2018-05-01 00:00:00' AND '2018-05-31 23:59:59') and SpareTC<>'' AND SpareTC<>sales   and inf=1 and reti='' and tickettype in ('电子票','婴儿票','团队定金') and t_source like ('%纯利润I%')   GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
/*
--国内纯利润I张数（只拉国际机票可不执行）
select sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
into #gn_chunlirun
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-05-01 00:00:00' AND '2018-05-31 23:59:59') and sales<>''  and inf=0 and reti='' and tickettype in ('电子票','婴儿票','团队定金') and t_source like ('%纯利润I%') and coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid where  (datetime BETWEEN '2018-05-01 00:00:00' AND '2018-05-31 23:59:59') and SpareTC<>'' AND SpareTC<>sales   and inf=0 and reti='' and tickettype in ('电子票','婴儿票','团队定金') and t_source like ('%纯利润I%')  GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
*/

--第六步
SELECT sales,SUM(num) AS Num
INTO #gn_gn
FROM #gn
GROUP BY sales
SELECT sales,SUM(num) AS Num
INTO #gj_gj
FROM #gj
GROUP BY sales
SELECT sales,SUM(num) AS Num
INTO #gj_zuofei_gj
FROM #gj_zuofei
GROUP BY sales
SELECT sales,SUM(num) AS Num
INTO #gj_gaiqi_gj
FROM #gj_gaiqi
GROUP BY sales
SELECT sales,SUM(num) AS Num
INTO #gj_xuanwei_gj
FROM #gj_xuanwei
GROUP BY sales
SELECT sales,SUM(num) AS Num
INTO #gj_chunlirun_gj
FROM #gj_chunlirun
GROUP BY sales
/*
--（只拉国际机票可不执行）
SELECT sales,SUM(num) AS Num
INTO #gn_zuofei_gn
FROM #gn_zuofei
GROUP BY sales
SELECT sales,SUM(num) AS Num
INTO #gn_gaiqi_gn
FROM #gn_gaiqi
GROUP BY sales
SELECT sales,SUM(num) AS Num
INTO #gn_xuanwei_gn
FROM #gn_xuanwei
GROUP BY sales
*/
--第七步
--国际
IF OBJECT_ID('tempdb.dbo.#table_all') IS NOT NULL DROP TABLE #table_all
SELECT emp.team,emp.empname,isnull((gj.Num),0) [国际张数],isnull((r1.Num),0) [退票张数],-ISNULL(gj_zuofei.Num,0) [作废张数],-ISNULL(gj_gaiqi.Num,0) [改期张数],-ISNULL(gj_xuanwei.Num,0)[选位张数],-ISNULL(gj_chunlirun.Num,0)[纯利润张数],ISNULL(gj.Num,0)+ISNULL(r1.Num,0)-ISNULL(gj_zuofei.Num,0)-ISNULL(gj_gaiqi.Num,0)-ISNULL(gj_xuanwei.Num,0)-ISNULL(gj_chunlirun.Num,0) [国际-退票-作废-改期-选位-纯利润I]
--国内
--SELECT emp.empname,isnull((gn.Num),0) [国内张数],isnull((r0.Num),0) [退票张数],-ISNULL(gn_zuofei.Num,0) [作废张数],-ISNULL(gn_gaiqi.Num,0) [改期张数],-ISNULL(gn_xuanwei.Num,0)[选位张数],-ISNULL(gn_chunlirun.Num,0)[纯利润张数],ISNULL(gn.Num,0)+ISNULL(r0.Num,0)-ISNULL(gn_zuofei.Num,0)-ISNULL(gn_gaiqi.Num,0)-ISNULL(gn_xuanwei.Num,0)-ISNULL(gn_chunlirun.Num,0) [国内-退票-作废-改期-选位-纯利润I]
into #table_all
FROM #emp emp
LEFT JOIN #gn_gn gn ON emp.empname=gn.sales
LEFT JOIN #gj_gj gj ON emp.empname=gj.sales
LEFT JOIN #r r0 ON emp.empname=r0.sales AND r0.inf=0
LEFT JOIN #r r1 ON emp.empname=r1.sales AND r1.inf=1
LEFT JOIN #gj_zuofei_gj gj_zuofei ON emp.empname=gj_zuofei.sales
left join #gj_gaiqi_gj gj_gaiqi ON emp.empname=gj_gaiqi.sales
left join #gj_xuanwei_gj gj_xuanwei ON emp.empname=gj_xuanwei.sales
left join #gj_chunlirun_gj gj_chunlirun ON emp.empname=gj_chunlirun.sales
--left join #gn_zuofei_gn gn_zuofei ON emp.empname=gn_zuofei.sales
--left join #gn_gaiqi_gn gn_gaiqi ON emp.empname=gn_gaiqi.sales
--left join #gn_xuanwei_gn gn_xuanwei ON emp.empname=gn_xuanwei.sales
LEFT JOIN (SELECT sales, SUM(num) num FROM #r GROUP BY sales) r ON emp.empname=r.sales
ORDER BY emp.idx

select * from #table_all
where team in ('差旅运营一组')
UNION ALL 
select team,'',sum([国际张数]),SUM([退票张数]),SUM([作废张数]),SUM([改期张数]),sum([选位张数]),SUM([纯利润张数]),sum([国际-退票-作废-改期-选位-纯利润I]) from #table_all
where team in ('差旅运营一组')
group by team
UNION ALL 
select * from #table_all
where team in ('差旅运营二组')
UNION ALL 
select team,'',sum([国际张数]),SUM([退票张数]),SUM([作废张数]),SUM([改期张数]),sum([选位张数]),SUM([纯利润张数]),sum([国际-退票-作废-改期-选位-纯利润I]) from #table_all
where team in ('差旅运营二组')
group by team
UNION ALL 
select * from #table_all
where team in ('差旅运营三组')
UNION ALL 
select team,'',sum([国际张数]),SUM([退票张数]),SUM([作废张数]),SUM([改期张数]),sum([选位张数]),SUM([纯利润张数]),sum([国际-退票-作废-改期-选位-纯利润I]) from #table_all
where team in ('差旅运营三组')
group by team
UNION ALL 
select * from #table_all
where team in ('差旅运营四组')
UNION ALL 
select team,'',sum([国际张数]),SUM([退票张数]),SUM([作废张数]),SUM([改期张数]),sum([选位张数]),SUM([纯利润张数]),sum([国际-退票-作废-改期-选位-纯利润I]) from #table_all
where team in ('差旅运营四组')
group by team
UNION ALL 
select * from #table_all
where team in ('差旅运营十组')
UNION ALL 
select team,'',sum([国际张数]),SUM([退票张数]),SUM([作废张数]),SUM([改期张数]),sum([选位张数]),SUM([纯利润张数]),sum([国际-退票-作废-改期-选位-纯利润I]) from #table_all
where team in ('差旅运营十组')
group by team
UNION ALL 
select '','',sum([国际张数]),SUM([退票张数]),SUM([作废张数]),SUM([改期张数]),sum([选位张数]),SUM([纯利润张数]),sum([国际-退票-作废-改期-选位-纯利润I]) from #table_all

--12/1至今康宝莱出票（CZ）

select coupno as 销售单号,datetime as 出票日期,begdate as 起飞日期, pasname as 乘机人,totprice as 销售价,reti as 退票单号,nclass as 舱位码,route as 行程,ride from Topway..tbcash 

where datetime>='2018-12-01' and ride='cz' and cmpcode='020459' order by datetime

--（产品专用）申请费来源/金额信息（国际）

select feiyonginfo,feiyong,* from Topway..tbcash 
--update Topway..tbcash  set feiyong='283'
where coupno='AS002185309'

--到账麻烦到账日期帮我修改为1.13
select * from topway..FinanceERP_ClientBankRealIncomeDetail 
--update topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-01-13'
where money='10505' and date='2019-01-14'