
--2��2017.3-2018.2���ڻ�Ʊ����ǰ10�ĺ��ߣ��־��òա����գ��������ݻ�����һ��Ҫ���ֶ�����
if OBJECT_ID('tempdb.dbo.#t') is not null drop table #t
SELECT  ROW_NUMBER()OVER(
--PARTITION BY ISNULL(cabintype,'') 
ORDER BY SUM(tbcash.amount) DESC) AS idx
--,CONVERT(VARCHAR(7),datetime,120) M
,ISNULL(cabintype,'���ò�') cabintype,
        SUM(tbcash.amount) AS amount ,
        COUNT(*) AS percount,
		AVG(DATEDIFF(d, datetime, begdate)) AS [ƽ����Ʊ����]
		,AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS [ƽ����Ʊ�ۿ���]
into #t
--SELECT DISTINCT cabinType		
FROM    (
SELECT * --,CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END
,(SELECT TOP 1 i.cabintype 
	FROM ehomsom..tbInfCabincode i 
	WHERE	tbcash.ride=i.code2 AND tbcash.nclass=i.cabin 
										AND i.begdate<=tbcash.begdate AND i.enddate>=tbcash.begdate
	ORDER BY id DESC
	) AS cabinType
FROM tbcash
WHERE   ( cmpcode = '020273' )
        AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
		--AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30' )
        --AND ( reti = '' )
        AND tbcash.inf IN ( 0 )
--ORDER BY cabinType
) tbcash
--WHERE ISNULL(cabintype,'')  IN ('ͷ�Ȳ�','�����')
GROUP BY --CONVERT(VARCHAR(7),datetime,120), 
ISNULL(cabintype,'���ò�')
--tbcash.route 

declare @totAmount decimal(18,2)
select @totAmount=sum(amount) from #t
        
SELECT cte.cabintype,cte.amount,cte.percount, amount/@totAmount,cte.ƽ����Ʊ�ۿ���
FROM #t cte

select sum(amount),sum(percount)
from #t


SELECT avg(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END)
FROM tbcash
WHERE   ( cmpcode = '020273' )
        AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
		--AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30' )
        --AND ( reti = '' )
        AND tbcash.inf IN ( 0 )