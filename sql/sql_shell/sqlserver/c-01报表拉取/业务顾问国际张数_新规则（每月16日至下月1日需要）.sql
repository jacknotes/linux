
/*
1�����ʻ�Ʊ����=��Ʊ����-��Ʊ����-��Ʊ����-��������-ѡλ����-����������
2����Ʊ����������Ʊ����Ϊ������Ʊ������Ӥ��Ʊ�������ŶӶ��𡿵��������ŶӶ���һ���Ž��ɴ�ӡһ�����۵�����򲻼��롣
3����Ʊ����Ϊ����Ʊ��ҵ������������Ӧ����ԴΪ���ڷ���ѡ����г�Ϊ����XXX���������Ʊ������
4����Ʊ������ʵ�ʷ����������㡣��7�³�Ʊ��9�·�����Ʊ��9��ͳ���������ۼ���

��Ʊ������ʵ�ʷ������㣨�������۵���Ʊ�������κ��·ݣ�
ֻҪ�Ƿ�Ʊ�������Ƿ�����Ʊ���߸��ڣ�һ�����Ʊ
Ʊ���͡����̡���Ӧ����Դ����һ���и������ۣ��������Ʊ
����Ʊ������Ʊ������Ʊ�㣨����Ʊ��û����Ʊ��
*/


--��һ��
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
--Ա���б�
SELECT ROW_NUMBER()OVER(ORDER BY t2.depOrder,t1.idnumber) idx,empname,team 
INTO #emp 
from emppwd t1 LEFT JOIN dbo.EmpSysSetting t2 ON t1.team=t2.dep AND t2.ntype=2 where t1.dep = '��Ӫ��' and team like ('%����%') order by t2.depOrder,t1.idnumber 
--Get���ڻ�Ʊ����ë������
SELECT sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
INTO #gn
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and sales<>''  and inf=0 and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���')
GROUP BY sales,cmpcode  
UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit , SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and SpareTC<>'' AND SpareTC<>sales and cmpcode<>''  and inf=0  and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���')
GROUP BY SpareTC,cmpcode  ) T 
GROUP BY sales,cmpcode 
order by sales,cmpcode
--Get���ʻ�Ʊ����ë������
SELECT sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
INTO #gj
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and sales<>''  and inf=1 and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���')
GROUP BY sales,cmpcode  
UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and SpareTC<>'' AND SpareTC<>sales and cmpcode<>''  and inf=1 and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���')
GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
--Get��Ʊë������
SELECT sales,sum(Num) as Num, sum(totprice) as totprice,count(1) as pcs,sum(profit) as profit  ,inf
INTO #r
FROM (
	SELECT -sum(CASE WHEN tbcash.cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) as Num
	, sum(CASE WHEN tbcash.cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(tbReti.totprice,0)) as totprice
	, sales,count(*) as pcs ,sum(CASE WHEN tbcash.cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * tbreti.profit) as profit ,tbreti.inf
	FROM tbreti  
	LEFT join tbcash ON dbo.tbReti.reno = dbo.tbCash.reti and dbo.tbReti.ticketno = dbo.tbCash.ticketno 
	WHERE 
	--tbcash.datetime  BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59' and
	tbReti.ExamineDate BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59'
	AND  dbo.tbReti.status2 not in (3,4)  
	and tbcash.totprice>0
	and tbReti.coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+tbReti.ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type=1)   
	GROUP by sales,tbreti.inf  
	UNION all 
	SELECT -sum(0.5) as Num, sum(0.5 * isnull(tbReti.totprice,0)) as totprice,SpareTC as sales,count(*) as pcs 
	,sum(0.5 * tbreti.profit) as profit ,tbreti.inf
	FROM tbreti  left join tbcash ON dbo.tbReti.reno = dbo.tbCash.reti and dbo.tbReti.ticketno = dbo.tbCash.ticketno 
	WHERE 
	--tbcash.datetime  BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59' and
	tbReti.ExamineDate BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59'
	AND  dbo.tbReti.status2 not in (3,4)  
	and tbcash.totprice>0
	and tbReti.coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+tbcash.ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type=1) 
	AND SpareTC<>'' AND SpareTC<>sales and  tbcash.cmpcode<>''   
	GROUP by SpareTC,tbreti.inf )T  group by sales,inf order by sales
	
--�ڶ���	 
--get�����б�(���� totprice>0)
SELECT sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
INTO #gj_zuofei
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy 
FROM tbcash 
LEFT join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
INNER JOIN (SELECT coupno,ticketno FROM dbo.tbinvalid WHERE type in (0,1)) Inv ON inv.coupno=tbcash.coupno AND inv.ticketno LIKE '%'+tbcash.tcode+'-'+tbcash.ticketno+'%' 
WHERE dbo.tbcash.totprice>0 and (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and sales<>''  and inf=1 GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid INNER JOIN (SELECT coupno,ticketno FROM dbo.tbinvalid WHERE type=1) Inv ON inv.coupno=tbcash.coupno AND inv.ticketno LIKE '%'+tbcash.tcode+'-'+tbcash.ticketno+'%'  where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and SpareTC<>'' AND SpareTC<>sales and cmpcode<>''  and inf=1 GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
/*
--��ֻ�����ʻ�Ʊ�ɲ�ִ�У�
--get���������б�(���� totprice>0)
SELECT sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
INTO #gn_zuofei
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy 
FROM tbcash 
LEFT join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
INNER JOIN (SELECT coupno,ticketno FROM dbo.tbinvalid WHERE type in (0,1)) Inv ON inv.coupno=tbcash.coupno AND inv.ticketno LIKE '%'+tbcash.tcode+'-'+tbcash.ticketno+'%' 
WHERE dbo.tbcash.totprice>0 and (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and sales<>''  and inf=0 GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid INNER JOIN (SELECT coupno,ticketno FROM dbo.tbinvalid WHERE type=1) Inv ON inv.coupno=tbcash.coupno AND inv.ticketno LIKE '%'+tbcash.tcode+'-'+tbcash.ticketno+'%'  where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and SpareTC<>'' AND SpareTC<>sales and cmpcode<>''  and inf=0 GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
*/
--������
--���ʸ�������
select sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
into #gj_gaiqi
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and sales<>''  and inf=1 and reti='' and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���') and (route like ('%����%') or  t_source like ('%����%')) and route not like ('%ѡλ%') and coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and SpareTC<>'' AND SpareTC<>sales   and inf=1 and reti='' and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���') and (route like ('%����%') or  t_source like ('%����%')) and route not like ('%ѡλ%') GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
/*
--���ڸ���������ֻ�����ʻ�Ʊ�ɲ�ִ�У�
select sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
into #gn_gaiqi
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and sales<>''  and inf=0 and reti='' and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���') and (route like ('%����%') or  t_source like ('%����%')) and route not like ('%ѡλ%') and coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and SpareTC<>'' AND SpareTC<>sales   and inf=0 and reti='' and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���') and (route like ('%����%') or  t_source like ('%����%')) and route not like ('%ѡλ%') GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
*/
--���Ĳ�
--����ѡλ����
select sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
into #gj_xuanwei
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and sales<>''  and inf=1 and reti='' and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���') and route like ('%ѡλ%') and coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and SpareTC<>'' AND SpareTC<>sales   and inf=1 and reti='' and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���') and route like ('%ѡλ%')   GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
/*
--����ѡλ������ֻ�����ʻ�Ʊ�ɲ�ִ�У�
select sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
into #gn_xuanwei
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and sales<>''  and inf=0 and reti='' and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���') and route like ('%ѡλ%') and coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and SpareTC<>'' AND SpareTC<>sales   and inf=0 and reti='' and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���') and route like ('%ѡλ%')  GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
*/
--���岽
--���ʴ�����I����
select sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
into #gj_chunlirun
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and sales<>''  and inf=1 and reti='' and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���') and t_source like ('%������I%') and coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and SpareTC<>'' AND SpareTC<>sales   and inf=1 and reti='' and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���') and t_source like ('%������I%')   GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
/*
--���ڴ�����I������ֻ�����ʻ�Ʊ�ɲ�ִ�У�
select sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
into #gn_chunlirun
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and sales<>''  and inf=0 and reti='' and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���') and route like ('%������I%') and coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and SpareTC<>'' AND SpareTC<>sales   and inf=0 and reti='' and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���') and route like ('%������I%')  GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode
*/


--������
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
--��ֻ�����ʻ�Ʊ�ɲ�ִ�У�
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
--���߲�
--����
SELECT emp.team,emp.empname,isnull((gj.Num),0) [��������],isnull((r1.Num),0) [��Ʊ����],-ISNULL(gj_zuofei.Num,0) [��������],-ISNULL(gj_gaiqi.Num,0) [��������],-ISNULL(gj_xuanwei.Num,0)[ѡλ����],-ISNULL(gj_chunlirun.Num,0)[����������],ISNULL(gj.Num,0)+ISNULL(r1.Num,0)-ISNULL(gj_zuofei.Num,0)-ISNULL(gj_gaiqi.Num,0)-ISNULL(gj_xuanwei.Num,0)-ISNULL(gj_chunlirun.Num,0) [����-��Ʊ-����-����-ѡλ-������I]
--����
--SELECT emp.empname,isnull((gn.Num),0) [��������],isnull((r0.Num),0) [��Ʊ����],-ISNULL(gn_zuofei.Num,0) [��������],-ISNULL(gn_gaiqi.Num,0) [��������],-ISNULL(gn_xuanwei.Num,0)[ѡλ����],-ISNULL(gn_chunlirun.Num,0)[����������],ISNULL(gn.Num,0)+ISNULL(r0.Num,0)-ISNULL(gn_zuofei.Num,0)-ISNULL(gn_gaiqi.Num,0)-ISNULL(gn_xuanwei.Num,0)-ISNULL(gn_chunlirun.Num,0) [����-��Ʊ-����-����-ѡλ-������I]
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




--���²�ִ��
--��Ʊ��ϸ
select sales as ����ҵ�����,SpareTC as ����ҵ�����,datetime as ��Ʊʱ��,coupno as ���۵���,tcode+ticketno as Ʊ��,t_source as ��Ӧ����Դ,route as ����
,tickettype as Ʊ����,totprice as ���ۼۺ�˰,totsprice as ����ۺ�˰,tax as ˰��,Mcost as �ʽ����,profit as ���� 
from tbcash 
left join #emp emp on emp.empname=tbcash.sales
where  datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59'
and inf=1
and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���')
--and reti=''
--and (route not like ('%����%') and tickettype not like ('%����%'))
--and coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
and totprice>0
order by Emp.idx

--��Ʊ��ϸ
select sales as ����ҵ�����,SpareTC as ����ҵ�����,c.datetime as ��Ʊʱ��,c.coupno as ���۵���,tcode+c.ticketno as Ʊ��,t_source as ��Ӧ����Դ,c.route as ����
,tickettype as Ʊ����,c.totprice as ���ۼۺ�˰,totsprice as ����ۺ�˰,tax as ˰��,Mcost as �ʽ����,c.profit as ���� 
from tbcash c
left join tbReti r on r.reno=c.reti
left join #emp emp on emp.empname=c.sales
where  
--c.datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59' and 
r.ExamineDate BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59'
and c.inf=1
and reti<>''
--and c.route not like ('%����%') and tickettype not like ('%����%') or t_source not like ('%����%')
and r.status2 not in (3,4) 
and c.coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+c.ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
and c.totprice>0
order by Emp.idx

--������ϸ
select c.sales as ����ҵ�����,SpareTC as ����ҵ�����,datetime as ��Ʊʱ��,c.coupno as ���۵���,tcode+c.ticketno as Ʊ��,t_source as ��Ӧ����Դ,route as ����
,tickettype as Ʊ����,totprice as ���ۼۺ�˰,totsprice as ����ۺ�˰,tax as ˰��,Mcost as �ʽ����,profit as ���� 
from tbcash c
left join #emp emp on emp.empname=c.sales
INNER JOIN (SELECT coupno,ticketno FROM dbo.tbinvalid WHERE type=1) Inv ON inv.coupno=c.coupno AND inv.ticketno LIKE '%'+c.tcode+'-'+c.ticketno+'%' 
where  datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59'
and inf=1
--and reti=''
--and (route not like ('%����%') and tickettype not like ('%����%') or t_source like ('%����%'))
--and c.coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type=1) and tcode+'-'+c.ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type=1)
and totprice>0
order by Emp.idx




--������ϸ
select sales as ����ҵ�����,SpareTC as ����ҵ�����,datetime as ��Ʊʱ��,coupno as ���۵���,tcode+ticketno as Ʊ��,t_source as ��Ӧ����Դ,route as ����
,tickettype as Ʊ����,totprice as ���ۼۺ�˰,totsprice as ����ۺ�˰,tax as ˰��,Mcost as �ʽ����,profit as ����
from tbcash c
left join #emp emp on emp.empname=c.sales
where  datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59'
and inf=1
and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���')
and (route like ('%����%') or  t_source like ('%����%'))
and route not like ('%ѡλ%')
and totprice>0
and reti=''
and coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
order by Emp.idx

--ѡλ��ϸ
select sales as ����ҵ�����,SpareTC as ����ҵ�����,datetime as ��Ʊʱ��,coupno as ���۵���,tcode+ticketno as Ʊ��,t_source as ��Ӧ����Դ,route as ����
,tickettype as Ʊ����,totprice as ���ۼۺ�˰,totsprice as ����ۺ�˰,tax as ˰��,Mcost as �ʽ����,profit as ����
from tbcash c
left join #emp emp on emp.empname=c.sales
where  datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59'
and inf=1
and tickettype in ('����Ʊ','Ӥ��Ʊ','�ŶӶ���')
and route like ('%ѡλ%')
and totprice>0
and reti=''
and coupno not in (SELECT coupno FROM dbo.tbinvalid WHERE type in (0,1)) and tcode+'-'+ticketno not in (SELECT ticketno FROM dbo.tbinvalid WHERE type in (0,1))
order by Emp.idx














SELECT sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy 
FROM tbcash 
LEFT join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
INNER JOIN (SELECT coupno,ticketno FROM dbo.tbinvalid WHERE type=1) Inv ON inv.coupno=tbcash.coupno AND inv.ticketno LIKE '%'+tbcash.tcode+'-'+tbcash.ticketno+'%' 
WHERE dbo.tbcash.totprice>0 and (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and sales<>''  and inf=1 GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid INNER JOIN (SELECT coupno,ticketno FROM dbo.tbinvalid WHERE type=1) Inv ON inv.coupno=tbcash.coupno AND inv.ticketno LIKE '%'+tbcash.tcode+'-'+tbcash.ticketno+'%'  where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and SpareTC<>'' AND SpareTC<>sales and cmpcode<>''  and inf=1 GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode

--SELECT sales,SpareTC,datetime,tbcash.coupno,tbcash.ticketno,tbcash.status,dbo.tbcash.profit,dbo.tbcash.totprice,tbcash.totsprice,inv.*
--FROM tbcash 
--LEFT join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
--INNER JOIN (SELECT coupno,ticketno FROM dbo.tbinvalid WHERE type=1) Inv ON inv.coupno=tbcash.coupno AND inv.ticketno LIKE '%'+tbcash.tcode+'-'+tbcash.ticketno+'%' 
--WHERE dbo.tbcash.totprice>0 and (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and sales<>''  and inf=1
--ORDER BY sales




--SELECT sales,cmpcode,SUM(Num) Num,SUM(totprice) totprice,SUM(Mcost) Mcost,SUM(price) AS price, SUM(profit) AS profit, SUM(Subsidy) AS Subsidy  
--FROM ( SELECT sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0  WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END) AS Num,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * totprice) AS totprice,sum(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * Mcost) as Mcost,SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * price) AS price,  SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * profit)  AS profit, SUM(CASE WHEN cmpcode<>''and SpareTC<>'' AND SpareTC<>sales THEN 0.50 else 1 END * isnull(Subsidies,0))  AS Subsidy 
--FROM tbcash 
--LEFT join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
--INNER JOIN (SELECT coupno,ticketno FROM dbo.tbinvalid WHERE type=1) Inv ON inv.coupno=tbcash.coupno AND inv.ticketno LIKE '%'+tbcash.tcode+'-'+tbcash.ticketno+'%' 
--WHERE dbo.tbcash.totprice>0 and (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and sales<>''  and inf=1 GROUP BY sales,cmpcode  UNION ALL SELECT SpareTC AS sales,cmpcode,SUM(CASE WHEN totprice=0 THEN 0 ELSE 0.50 END) AS Num,SUM(0.50 * totprice) AS totprice,sum(0.50 * Mcost) as Mcost,SUM(0.50 * price) AS price,  SUM(0.50 * profit)  AS profit, SUM(0.50 * isnull(Subsidies,0))  AS Subsidy FROM tbcash left join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid INNER JOIN (SELECT coupno,ticketno FROM dbo.tbinvalid WHERE type=1) Inv ON inv.coupno=tbcash.coupno AND inv.ticketno LIKE '%'+tbcash.tcode+'-'+tbcash.ticketno+'%'  where  (datetime BETWEEN '2018-06-01 00:00:00' AND '2017-01-28 23:59:59') and SpareTC<>'' AND SpareTC<>sales and cmpcode<>''  and inf=1 GROUP BY SpareTC,cmpcode  ) T GROUP BY sales,cmpcode order by sales,cmpcode

SELECT sales,SpareTC,datetime,tbcash.coupno,tbcash.ticketno,tbcash.status,dbo.tbcash.profit,dbo.tbcash.totprice,tbcash.totsprice,inv.*
FROM tbcash 
LEFT join tbCompanyM on tbcash.cmpcode=tbCompanyM.cmpid 
INNER JOIN (SELECT coupno,ticketno FROM dbo.tbinvalid WHERE type=1) Inv ON inv.coupno=tbcash.coupno AND inv.ticketno LIKE '%'+tbcash.tcode+'-'+tbcash.ticketno+'%' 
WHERE dbo.tbcash.totprice>0 and (datetime BETWEEN '2018-06-01 00:00:00' AND '2018-06-30 23:59:59') and sales<>''  and inf=1
ORDER BY sales

