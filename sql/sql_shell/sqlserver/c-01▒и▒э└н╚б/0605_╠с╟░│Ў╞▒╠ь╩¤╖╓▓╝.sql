--分析图3－国内机票提前出票天数比例
declare @toybishu int,@totamount decimal(18,3)
SELECT    @toybishu=COUNT(*),@totamount=SUM(amount)
          FROM      tbcash
          WHERE     ( cmpcode = '016448' )
                    --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
					AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30' )
                    --AND ( reti = '' )
                    AND ( inf = 0 )


;with cte as (
SELECT  amount ,
        numdays ,
        totalbishu ,
        ( SELECT    SUM(amount) AS amount1
          FROM      tbcash
          WHERE     ( cmpcode = '016448' )
                    --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
					AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30' )

                    --AND ( reti = '' )
                    AND ( inf = 0 )
        ) AS total ,
        ( SELECT    COUNT(*) AS amount1
          FROM      tbcash
          WHERE     ( cmpcode = '016448' )
                    --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
					AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30' )
                    --AND ( reti = '' )
                    AND ( inf = 0 )
        ) AS zongbishu
FROM    ( SELECT    SUM(amount) AS amount ,
                    DATEDIFF(d, datetime, begdate) AS numdays ,
                    COUNT(*) AS totalbishu
          FROM      tbcash
          WHERE     ( cmpcode = '016448' )
                    --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
					AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30' )
                    --AND ( reti = '' )
                    AND ( inf = 0 )
          GROUP BY  DATEDIFF(d, datetime, begdate)
        ) DERIVEDTBL


) select case when numdays between 0 and 2 then 1
			when numdays between 3 and 6 then 2
			when numdays between 7 and 13 then 3
			when numdays between 14 and 20 then 4
			when numdays >20 then 5
			else 0 end as diffDay
,sum(amount) amount,sum(totalbishu) bishu,sum(amount) /@totamount as amountP
from cte
group by case when numdays between 0 and 2 then 1
			when numdays between 3 and 6 then 2
			when numdays between 7 and 13 then 3
			when numdays between 14 and 20 then 4
			when numdays >20 then 5
			else 0 end


SELECT  case when DATEDIFF(d, datetime, begdate) between 0 and 2 then 1
			when DATEDIFF(d, datetime, begdate) between 3 and 6 then 2
			when DATEDIFF(d, datetime, begdate) between 7 and 13 then 3
			when DATEDIFF(d, datetime, begdate) between 14 and 20 then 4
			when DATEDIFF(d, datetime, begdate) >20 then 5
			else 0 end AS Numdays ,
        AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS zkpercent
FROM    tbcash
WHERE   ( cmpcode = '016448' )
        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
		AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30' )
        --AND ( reti = '' )
        AND ( inf = 0 )
        --AND priceinfo > 0
        --AND price / priceinfo <= 1
GROUP BY 
case when DATEDIFF(d, datetime, begdate) between 0 and 2 then 1
			when DATEDIFF(d, datetime, begdate) between 3 and 6 then 2
			when DATEDIFF(d, datetime, begdate) between 7 and 13 then 3
			when DATEDIFF(d, datetime, begdate) between 14 and 20 then 4
			when DATEDIFF(d, datetime, begdate) >20 then 5
			else 0 end

select   sum( amount) amount,count(1) num,   1,  AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS zkpercent
FROM    tbcash
WHERE   ( cmpcode = '016448' )
        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
		AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30' )
        --AND ( reti = '' )
        AND ( inf = 0 )
        --AND priceinfo > 0
        --AND price / priceinfo <= 1


