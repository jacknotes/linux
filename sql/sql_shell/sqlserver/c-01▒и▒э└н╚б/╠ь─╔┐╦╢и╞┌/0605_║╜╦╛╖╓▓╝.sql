/*
uc020273
UC020273
UC020273
UC020273
UC020273
UC020273

*/
--
--分仓

select cabintype,begdate,* from ehomsom..tbInfCabincode


--2.航司分布

declare @totP decimal(18,3)
SELECT  

       @totP= SUM(v_ticketinfo.price)
		
FROM    v_ticketinfo 
inner join ehomsom..tbInfCabincode t2 on t2.begdate=v_ticketinfo.datetime
WHERE   ( cmpcode = '016448' )
        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
		AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31' )
        AND ( reti = '' )
        AND v_ticketinfo.inf IN ( 0 ) 
       and inf=0
       and CostCenter='ca'
        and (t2.cabintype like'%公务舱%' or t2.cabintype like'%头等舱%')
        --and t2.cabintype like'%经济舱%'
      
;WITH cte AS (
SELECT  --CONVERT(VARCHAR(7),datetime,120) m
ROW_NUMBER()OVER(--PARTITION BY CONVERT(VARCHAR(7),datetime,120)
 ORDER BY SUM(v_ticketinfo.price) DESC) AS idx
,case when v_ticketinfo.ride ='FM' then 'MU' else v_ticketinfo.ride end as ride,
        SUM(v_ticketinfo.price) AS price ,
        COUNT(*) AS percount,
		SUM(v_ticketinfo.price)/@totP AS priceP,
		--AVG(DATEDIFF(d, datetime, begdate)) AS [平均出票天数]
		AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS [平均机票折扣率]
		
FROM    v_ticketinfo
inner join ehomsom..tbInfCabincode t2 on t2.begdate=v_ticketinfo.datetime
WHERE   ( cmpcode = '016448' )
        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
		AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31' )
        AND ( reti = '' )
        AND v_ticketinfo.inf IN ( 0 )
        and inf=0
        and CostCenter='ca'
       and (t2.cabintype like'%公务舱%' or t2.cabintype like'%头等舱%')
        --and t2.cabintype like'%经济舱%'
GROUP BY-- CONVERT(VARCHAR(7),datetime,120), 
case when v_ticketinfo.ride ='FM' then 'MU' else v_ticketinfo.ride end
        --v_ticketinfo.inf
--ORDER BY m,price DESC; 
)
SELECT *
FROM cte
--WHERE cte.idx<=20
ORDER BY cte.idx



