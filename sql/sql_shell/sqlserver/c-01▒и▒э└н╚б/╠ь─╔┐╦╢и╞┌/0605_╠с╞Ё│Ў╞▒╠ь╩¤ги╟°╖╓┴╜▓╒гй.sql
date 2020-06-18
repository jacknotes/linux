--按提前出票天数，拉取销量，张数，销量占比，折扣率(区分经济舱和两舱)
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


--分析图3－国内机票提前出票天数比例
IF OBJECT_ID('tempdb.dbo.#p1') IS NOT NULL DROP TABLE #p1
declare @toybishu int,@totprice decimal(18,3)
SELECT    @toybishu=COUNT(*),@totprice=SUM(price)
          FROM      #v_ticketinfo
          WHERE     ( cmpcode = '016448' )
                    --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
					AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31' )
                    AND ( reti = '' )
                    AND ( inf = 0 )
                    and CostCenter='am'
                    and tickettype='电子票'
                    and cabintype like '%经济舱%'
                  --and (cabintype like '%头等舱%' or cabintype like '%公务舱%')


;with cte as (
SELECT  price ,
        numdays ,
        totalbishu ,
        ( SELECT    SUM(price) AS price1
          FROM      #v_ticketinfo
          WHERE     ( cmpcode = '016448' )
                    --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
					AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31' )

                    AND ( reti = '' )
                    AND ( inf = 0 )
                    and CostCenter='am'
                    and tickettype='电子票'
                    and cabintype like '%经济舱%'
                   --and (cabintype like '%头等舱%' or cabintype like '%公务舱%')
        ) AS total ,
        ( SELECT    COUNT(*) AS price1
          FROM      #v_ticketinfo
          WHERE     ( cmpcode = '016448' )
                    --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
					AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31' )
                    AND ( reti = '' )
                    AND ( inf = 0 )
                    and CostCenter='am'
                    and tickettype='电子票'
                   and cabintype like '%经济舱%'
                   --and (cabintype like '%头等舱%' or cabintype like '%公务舱%')
        ) AS zongbishu
FROM    ( SELECT    SUM(price) AS price ,
                    DATEDIFF(d, datetime, begdate) AS numdays ,
                    COUNT(*) AS totalbishu
          FROM      #v_ticketinfo
          WHERE     ( cmpcode = '016448' )
                    --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
					AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31' )
                    AND ( reti = '' )
                    AND ( inf = 0 )
                    and CostCenter='am'
                    and tickettype='电子票'
                   and cabintype like '%经济舱%'
                   --and (cabintype like '%头等舱%' or cabintype like '%公务舱%')
          GROUP BY  DATEDIFF(d, datetime, begdate)
        ) DERIVEDTBL


) select case when numdays between 0 and 2 then 1
			when numdays between 3 and 6 then 2
			when numdays between 7 and 13 then 3
			when numdays between 14 and 20 then 4
			when numdays >=21 then 5
			else 0 end as diffDay
,sum(price) price,sum(totalbishu) bishu,sum(price) /@totprice as priceP
into #p1
from cte
group by case when numdays between 0 and 2 then 1
			when numdays between 3 and 6 then 2
			when numdays between 7 and 13 then 3
			when numdays between 14 and 20 then 4
			when numdays >=21 then 5
			else 0 end

IF OBJECT_ID('tempdb.dbo.#p2') IS NOT NULL DROP TABLE #p2
SELECT  case when DATEDIFF(d, datetime, begdate) between 0 and 2 then 1
			when DATEDIFF(d, datetime, begdate) between 3 and 6 then 2
			when DATEDIFF(d, datetime, begdate) between 7 and 13 then 3
			when DATEDIFF(d, datetime, begdate) between 14 and 20 then 4
			when DATEDIFF(d, datetime, begdate) >=21 then 5
			else 0 end AS Numdays ,
        AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS zkpercent
        into #p2
FROM    #v_ticketinfo
WHERE   ( cmpcode = '016448' )
        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
		AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31' )
        AND ( reti = '' )
        AND ( inf = 0 )
      and tickettype='电子票'
      and CostCenter='am'
        and cabintype like '%经济舱%'
         --and (cabintype like '%头等舱%' or cabintype like '%公务舱%')
        --AND priceinfo > 0
        --AND price / priceinfo <= 1
GROUP BY 
case when DATEDIFF(d, datetime, begdate) between 0 and 2 then 1
			when DATEDIFF(d, datetime, begdate) between 3 and 6 then 2
			when DATEDIFF(d, datetime, begdate) between 7 and 13 then 3
			when DATEDIFF(d, datetime, begdate) between 14 and 20 then 4
			when DATEDIFF(d, datetime, begdate) >=21 then 5
			else 0 end
			order by Numdays
			
select case diffday when 1 then '00 to 02' when 2 then '03 to 06' when 3 then '07 to 13' when 4 then '14 to 20' when 5 then '21+' else '' end as 提前出票天数
,price as 销量,bishu as 张数,priceP as 销量占比,zkpercent as 平均折扣率 from #p1 p1
left join #p2 p2 on p2.numdays=p1.diffday
UNION ALL
select   '合计',sum( price) price,count(1) num,   1,  AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS zkpercent
FROM    #v_ticketinfo
WHERE   ( cmpcode = '016448' )
        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
		AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31' )
        AND ( reti = '' )
        AND ( inf = 0 )
        and tickettype='电子票'
        and CostCenter='am'
        and cabintype like '%经济舱%'
          --and (cabintype like '%头等舱%' or cabintype like '%公务舱%')
        --AND priceinfo > 0
        --AND price / priceinfo <= 1
        
        


