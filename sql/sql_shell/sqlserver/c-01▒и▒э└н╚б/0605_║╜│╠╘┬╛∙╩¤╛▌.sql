--可变字段 出票时间段 单位编号 航程
select convert(varchar(6),datetime,112) m,sum(amount) as 销量,count(1) 张数
,sum(amount)*1.0/count(1)
 ,AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS 平均折扣率
FROM    V_TicketInfo
WHERE   ( cmpcode = '016448' )
        
		AND ( datetime BETWEEN '2017-01-01' AND '2018-10-31' )
        AND ( reti = '' )
        AND ( inf = 0 )
        and route in ('重庆-上海虹桥')
group by convert(varchar(6),datetime,112)
order by m