--����ǰ��Ʊ��������ȡ����������������ռ�ȣ��ۿ���(���־��òպ�����)
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


--����ͼ3�����ڻ�Ʊ��ǰ��Ʊ��������
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
                    and tickettype='����Ʊ'
                    and cabintype like '%���ò�%'
                  --and (cabintype like '%ͷ�Ȳ�%' or cabintype like '%�����%')


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
                    and tickettype='����Ʊ'
                    and cabintype like '%���ò�%'
                   --and (cabintype like '%ͷ�Ȳ�%' or cabintype like '%�����%')
        ) AS total ,
        ( SELECT    COUNT(*) AS price1
          FROM      #v_ticketinfo
          WHERE     ( cmpcode = '016448' )
                    --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
					AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31' )
                    AND ( reti = '' )
                    AND ( inf = 0 )
                    and CostCenter='am'
                    and tickettype='����Ʊ'
                   and cabintype like '%���ò�%'
                   --and (cabintype like '%ͷ�Ȳ�%' or cabintype like '%�����%')
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
                    and tickettype='����Ʊ'
                   and cabintype like '%���ò�%'
                   --and (cabintype like '%ͷ�Ȳ�%' or cabintype like '%�����%')
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
      and tickettype='����Ʊ'
      and CostCenter='am'
        and cabintype like '%���ò�%'
         --and (cabintype like '%ͷ�Ȳ�%' or cabintype like '%�����%')
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
			
select case diffday when 1 then '00 to 02' when 2 then '03 to 06' when 3 then '07 to 13' when 4 then '14 to 20' when 5 then '21+' else '' end as ��ǰ��Ʊ����
,price as ����,bishu as ����,priceP as ����ռ��,zkpercent as ƽ���ۿ��� from #p1 p1
left join #p2 p2 on p2.numdays=p1.diffday
UNION ALL
select   '�ϼ�',sum( price) price,count(1) num,   1,  AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS zkpercent
FROM    #v_ticketinfo
WHERE   ( cmpcode = '016448' )
        --AND ( datetime BETWEEN '2017-01-01' AND '2017-12-31' )
		AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31' )
        AND ( reti = '' )
        AND ( inf = 0 )
        and tickettype='����Ʊ'
        and CostCenter='am'
        and cabintype like '%���ò�%'
          --and (cabintype like '%ͷ�Ȳ�%' or cabintype like '%�����%')
        --AND priceinfo > 0
        --AND price / priceinfo <= 1
        
        


