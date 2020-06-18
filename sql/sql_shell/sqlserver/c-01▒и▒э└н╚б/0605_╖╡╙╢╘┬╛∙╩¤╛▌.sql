
--有返佣及无返佣月均数据
--可变字段 出票时间段 是否有返佣
select convert(varchar(6),datetime,112) m,sum(amount) as 销量,SUM(xfprice) as 返佣,SUM(tax) 税收,count(1) 张数
--,sum(amount)*1.0/count(1)
 ,AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS 平均折扣率
FROM    V_TicketInfo
WHERE   ( cmpcode = '016448' )
        
		AND ( datetime BETWEEN '2017-01-01' AND '2018-10-31' )
        AND ( reti = '' )
        AND ( inf = 0 )
        and xfprice<>0
group by convert(varchar(6),datetime,112)
order by m


--汇总
--UNION ALL
--select convert(varchar(4),datetime,112) m,SUM(xfprice),SUM(tax),sum(amount),count(1) num,--sum(amount)*1.0/count(1),
-- AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS zkpercent
--FROM    V_TicketInfo
--WHERE   ( cmpcode = '016448' )
       
--		AND ( datetime BETWEEN '2017-01-01' AND '2018-10-31' )
--        AND ( reti = '' )
--        AND ( inf = 0 )
--        and xfprice<>0
--group by convert(varchar(4),datetime,112)
--order by m
