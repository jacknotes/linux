/*
����ǰ20���ߣ����־��òպ�����

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

--2.��������ǰ20�ĺ���
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
       --and ISNULL(cabintype,'') LIKE '%���ò�%'
      and (ISNULL(cabintype,'')  LIKE '%ͷ�Ȳ�%' OR ISNULL(cabintype,'') LIKE'%�����%')
        
        

;WITH cte AS (
SELECT  --CONVERT(VARCHAR(7),datetime,120) m
ROW_NUMBER()OVER(--PARTITION BY CONVERT(VARCHAR(7),datetime,120)
 ORDER BY SUM(c.price) DESC) AS idx
,c.route ,
        SUM(c.price) AS price ,
        COUNT(*) AS percount,
        SUM(c.price)/COUNT(*) as ƽ��Ʊ��,
		SUM(c.price)/@totP AS priceP,
		--AVG(DATEDIFF(d, datetime, begdate)) AS [ƽ����Ʊ����]
		AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS [ƽ����Ʊ�ۿ���]
		
FROM    #v_ticketinfo c
WHERE   ( cmpcode = '016448' )
        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
		AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31' )
        AND ( reti = '' )
        AND c.inf IN ( 0 )
        --and CostCenter='am'
        --and ride in ('CZ')
        --and ISNULL(cabintype,'') LIKE '%���ò�%'
        --and ISNULL(cabintype,'���ò�') in ('���ò�')
        --and ISNULL(cabintype,'') in ('ͷ�Ȳ�','�����')
        and (ISNULL(cabintype,'')  LIKE '%ͷ�Ȳ�%' OR ISNULL(cabintype,'') LIKE'%�����%')
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
--		--AVG(DATEDIFF(d, datetime, begdate)) AS [ƽ����Ʊ����]
--		AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS [ƽ����Ʊ�ۿ���]
		
--FROM    tbcash
--WHERE   ( cmpcode = '020273' )
--        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
--		AND ( datetime BETWEEN '2018-01-01' AND '2018-05-31' )
--        AND ( reti = '' )
--        AND tbcash.inf IN ( 0 )