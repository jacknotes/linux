USE [Topway]
GO
/****** Object:  StoredProcedure [dbo].[sp_rpt_3041]    Script Date: 05/07/2019 11:07:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- 王巍
-- 2018-12-14
-- 单位客户航程月均报表
-- =============================================
ALTER PROCEDURE [dbo].[sp_rpt_3041] 
@cmpid varchar(100), 
@route varchar(200),
@sDate datetime,
@eDate datetime   
AS
BEGIN

--可变字段 出票时间段 单位编号 航程
select convert(varchar(6),datetime,112) 月份,Convert(decimal(18,2),sum(price),0) as 销量,count(1) 张数
,Convert(decimal(18,2),sum(price)*1.0/count(1),0) as 平均票价
 ,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS 平均折扣率
FROM    topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
WHERE   cmpcode = '016448' 
and i3.cabintype like '经济舱'    
		AND ( datetime BETWEEN '2019-01-01' AND '2019-04-30')
        AND ( reti = '' )
        AND ( inf = 0 )
        and route ='重庆-上海虹桥'
        and CostCenter='ca'
group by convert(varchar(6),datetime,112)
order by 月份

END
