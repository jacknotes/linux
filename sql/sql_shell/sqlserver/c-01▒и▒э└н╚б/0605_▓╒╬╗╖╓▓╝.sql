
--2、2017.3-2018.2国内机票排名前10的航线（分经济舱、两舱），（数据汇总在一起）要求字段如下
if OBJECT_ID('tempdb.dbo.#t') is not null drop table #t
SELECT  ROW_NUMBER()OVER(
--PARTITION BY ISNULL(cabintype,'') 
ORDER BY SUM(tbcash.amount) DESC) AS idx
--,CONVERT(VARCHAR(7),datetime,120) M
,ISNULL(cabintype,'经济舱') cabintype,
        SUM(tbcash.amount) AS amount ,
        COUNT(*) AS percount,
		AVG(DATEDIFF(d, datetime, begdate)) AS [平均出票天数]
		,AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS [平均机票折扣率]
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
--WHERE ISNULL(cabintype,'')  IN ('头等舱','公务舱')
GROUP BY --CONVERT(VARCHAR(7),datetime,120), 
ISNULL(cabintype,'经济舱')
--tbcash.route 

declare @totAmount decimal(18,2)
select @totAmount=sum(amount) from #t
        
SELECT cte.cabintype,cte.amount,cte.percount, amount/@totAmount,cte.平均机票折扣率
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