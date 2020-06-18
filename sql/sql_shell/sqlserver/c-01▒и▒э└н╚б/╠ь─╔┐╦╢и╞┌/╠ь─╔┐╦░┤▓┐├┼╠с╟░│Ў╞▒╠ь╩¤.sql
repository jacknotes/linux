--分析图3－国内机票提前出票天数比例
IF OBJECT_ID('tempdb.dbo.#t1') IS NOT NULL DROP TABLE #t1
declare @toybishu int,@totprice decimal(18,3),@Department int
SELECT    @toybishu=COUNT(*),@totprice=SUM(price),@Department=@Department
          
          FROM      v_ticketinfo
          WHERE     ( cmpcode = '016448' )
                    --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
					AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
                    AND ( reti = '' )
                    AND ( inf = 0 )
                   


;with cte as (
SELECT Department,price ,
        numdays ,
        totalbishu ,
        ( SELECT    SUM(price) AS price1
          FROM      v_ticketinfo
          WHERE     ( cmpcode = '016448' )
                    --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
					AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )

                    AND ( reti = '' )
                    AND ( inf = 0 )
                   
        ) AS total ,
        ( SELECT    COUNT(*) AS price1
          FROM      v_ticketinfo
          WHERE     ( cmpcode = '016448' )
                    --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
					AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
                    AND ( reti = '' )
                    AND ( inf = 0 )
                    
        ) AS zongbishu
FROM    ( SELECT   Department, SUM(price) AS price ,
                    DATEDIFF(d, datetime, begdate) AS numdays ,
                    COUNT(*) AS totalbishu
          FROM      v_ticketinfo
          WHERE     ( cmpcode = '016448' )
                    --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
					AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
                    AND ( reti = '' )
                    AND ( inf = 0 )
                    
          GROUP BY  DATEDIFF(d, datetime, begdate),Department
        ) DERIVEDTBL


) select Department,case when numdays between 0 and 2 then 1
			when numdays between 3 and 6 then 2
			when numdays between 7 and 13 then 3
			when numdays between 14 and 20 then 4
			when numdays >20 then 5
			else 0 end as diffDay
,sum(price) price,sum(totalbishu) bishu,sum(price) /@totprice as priceP
into #t1
from cte
group by case when numdays between 0 and 2 then 1
			when numdays between 3 and 6 then 2
			when numdays between 7 and 13 then 3
			when numdays between 14 and 20 then 4
			when numdays >20 then 5
			else 0 end
			, Department
			order by Department,diffDay

IF OBJECT_ID('tempdb.dbo.#t2') IS NOT NULL DROP TABLE #t2
SELECT  Department,case when DATEDIFF(d, datetime, begdate) between 0 and 2 then 1
			when DATEDIFF(d, datetime, begdate) between 3 and 6 then 2
			when DATEDIFF(d, datetime, begdate) between 7 and 13 then 3
			when DATEDIFF(d, datetime, begdate) between 14 and 20 then 4
			when DATEDIFF(d, datetime, begdate) >20 then 5
			else 0 end AS Numdays ,
        AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS zkpercent
        into #t2
FROM    v_ticketinfo
WHERE   ( cmpcode = '016448' )
        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
		AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
        AND ( reti = '' )
        AND ( inf = 0 )
        
        --AND priceinfo > 0
        --AND price / priceinfo <= 1
GROUP BY 
case when DATEDIFF(d, datetime, begdate) between 0 and 2 then 1
			when DATEDIFF(d, datetime, begdate) between 3 and 6 then 2
			when DATEDIFF(d, datetime, begdate) between 7 and 13 then 3
			when DATEDIFF(d, datetime, begdate) between 14 and 20 then 4
			when DATEDIFF(d, datetime, begdate) >20 then 5
			else 0 end,Department
order by Department,Numdays



select t1.*,t2.zkpercent from #t1 t1
inner join #t2 t2 on t2.department=t1.department and t1.diffday=t2.numdays


--select   sum(price) price,count(1) num,   1,  AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS zkpercent
--FROM    v_ticketinfo
--WHERE   ( cmpcode = '016448' )
--        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
--		AND ( datetime BETWEEN '2017-12-26' AND '2018-03-25' )
--        AND ( reti = '' )
--        AND ( inf = 0 )
       
--        --AND priceinfo > 0
--        --AND price / priceinfo <= 1


