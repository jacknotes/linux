/*
020273
020273
020273
020273
020273
020273

*/

--2.��������ǰ20�ĺ���
declare @totP decimal(18,3)
SELECT  

       @totP= SUM(tbcash.amount)
		
FROM    tbcash
WHERE   ( cmpcode = '016448' )
        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
		AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30' )
        --AND ( reti = '' )
        AND tbcash.inf IN ( 1 )

;WITH cte AS (
SELECT  --CONVERT(VARCHAR(7),datetime,120) m
ROW_NUMBER()OVER(--PARTITION BY CONVERT(VARCHAR(7),datetime,120)
 ORDER BY SUM(tbcash.amount) DESC) AS idx
,tbcash.route ,
        SUM(tbcash.amount) AS amount ,
        COUNT(*) AS percount,
		SUM(tbcash.amount)/@totP AS amountP,
		--AVG(DATEDIFF(d, datetime, begdate)) AS [ƽ����Ʊ����]
		AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS [ƽ����Ʊ�ۿ���]
		
FROM    tbcash
WHERE   ( cmpcode = '016448' )
        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
		AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30' )
        --AND ( reti = '' )
        AND tbcash.inf IN ( 1 )
GROUP BY-- CONVERT(VARCHAR(7),datetime,120), 
tbcash.route 
        --tbcash.inf
--ORDER BY m,amount DESC; 
)
SELECT *
FROM cte
WHERE cte.idx<=20
ORDER BY cte.idx



--SELECT  
--        SUM(tbcash.amount) AS amount ,
--        COUNT(*) AS percount,
--		1 AS amountP,
--		--AVG(DATEDIFF(d, datetime, begdate)) AS [ƽ����Ʊ����]
--		AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS [ƽ����Ʊ�ۿ���]
		
--FROM    tbcash
--WHERE   ( cmpcode = '020273' )
--        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
--		AND ( datetime BETWEEN '2018-01-01' AND '2018-05-31' )
--        AND ( reti = '' )
--        AND tbcash.inf IN ( 0 )