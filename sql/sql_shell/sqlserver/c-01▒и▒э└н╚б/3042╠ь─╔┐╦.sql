USE [Topway]
GO

/****** Object:  StoredProcedure [dbo].[sp_rpt_3042]    Script Date: 04/08/2019 14:47:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 王巍
-- 2018-12-14
-- 单位客户航司月均报表
-- =============================================
CREATE PROCEDURE [dbo].[sp_rpt_3042] 
@cmpid varchar(100), 
@AirCompany varchar(100),
@sDate datetime,
@eDate datetime   
AS
BEGIN
--可变字段 出票时间段 单位编号 航司
if (@AirCompany ='FM' or @AirCompany='MU')
select convert(varchar(6),datetime,112) 月份,Convert(decimal(18,2),sum(amount),0) as 销量,
Convert(decimal(18,2),SUM(tax),0) 税收,count(1) 张数
,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS 平均折扣率
FROM    V_TicketInfo
WHERE   ( cmpcode = '016448')        
		AND ( datetime BETWEEN '2019-04-01' AND '2019-04-30' )
        AND ( reti = '' )
        AND ( inf = 0 )
        and ride in ('ho')
        and CostCenter='ca'
group by convert(varchar(6),datetime,112)
order by 月份
else
select convert(varchar(6),datetime,112) 月份,Convert(decimal(18,2),sum(amount),0) as 销量,
Convert(decimal(18,2),SUM(tax),0) 税收,count(1) 张数
,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS 平均折扣率
FROM    V_TicketInfo
WHERE   ( cmpcode = @cmpid or @cmpid='')        
		AND ( datetime BETWEEN @sDate AND @eDate )
        AND ( reti = '' )
        AND ( inf = 0 )
        and ride = @AirCompany
group by convert(varchar(6),datetime,112)
order by 月份
END

GO


