/*
排名前20航线，区分经济舱和两舱

*/
IF OBJECT_ID('tempdb.dbo.#v_ticketinfo') IS NOT NULL DROP TABLE #v_ticketinfo
Select *,(SELECT TOP 1 i.cabintype 
	FROM ehomsom..tbInfCabincode i 
	WHERE	c.ride=i.code2 AND c.nclass=i.cabin 
										AND i.begdate<=c.begdate AND i.enddate>=c.begdate
	ORDER BY id DESC
	) AS cabinType 
into #v_ticketinfo
from v_ticketinfo c
where 	cmpcode = '016448'

--2.销量排名前20的航线
declare @totP decimal(18,3)
SELECT  

       @totP= SUM(c.price)
		
FROM #v_ticketinfo   c 

WHERE   ( cmpcode = '016448' )
        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
		--AND ( datetime BETWEEN '2018-01-01' AND '2018-09-30' )
		AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31' )
        AND ( reti = '' )
        AND c.inf IN ( 0 )
        --and CostCenter='am'
        --and ride in ('CZ')
       --and ISNULL(cabintype,'') LIKE '%经济舱%'
      and (ISNULL(cabintype,'')  LIKE '%头等舱%' OR ISNULL(cabintype,'') LIKE'%公务舱%')
        
        

;WITH cte AS (
SELECT  --CONVERT(VARCHAR(7),datetime,120) m
ROW_NUMBER()OVER(--PARTITION BY CONVERT(VARCHAR(7),datetime,120)
 ORDER BY SUM(c.price) DESC) AS idx
,c.route ,
        SUM(c.price) AS price ,
        COUNT(*) AS percount,
        SUM(c.price)/COUNT(*) as 平均票价,
		SUM(c.price)/@totP AS priceP,
		--AVG(DATEDIFF(d, datetime, begdate)) AS [平均出票天数]
		AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS [平均机票折扣率]
		
FROM    #v_ticketinfo c
WHERE   ( cmpcode = '016448' )
        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
		AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31' )
        AND ( reti = '' )
        AND c.inf IN ( 0 )
        --and CostCenter='am'
        --and ride in ('CZ')
        --and ISNULL(cabintype,'') LIKE '%经济舱%'
        --and ISNULL(cabintype,'经济舱') in ('经济舱')
        --and ISNULL(cabintype,'') in ('头等舱','公务舱')
        and (ISNULL(cabintype,'')  LIKE '%头等舱%' OR ISNULL(cabintype,'') LIKE'%公务舱%')
GROUP BY-- CONVERT(VARCHAR(7),datetime,120), 
c.route 
        --tbcash.inf
--ORDER BY m,price DESC; 
)
SELECT *
FROM cte
WHERE cte.idx<=20
 
ORDER BY cte.idx



--SELECT  
--        SUM(tbcash.price) AS price ,
--        COUNT(*) AS percount,
--		1 AS priceP,
--		--AVG(DATEDIFF(d, datetime, begdate)) AS [平均出票天数]
--		AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS [平均机票折扣率]
		
--FROM    tbcash
--WHERE   ( cmpcode = '020273' )
--        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
--		AND ( datetime BETWEEN '2018-01-01' AND '2018-05-31' )
--        AND ( reti = '' )
--        AND tbcash.inf IN ( 0 )