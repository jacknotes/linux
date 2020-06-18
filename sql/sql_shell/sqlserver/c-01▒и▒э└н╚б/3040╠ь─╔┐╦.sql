USE [Topway]
GO

/****** Object:  StoredProcedure [dbo].[sp_rpt_3040]    Script Date: 04/08/2019 14:46:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 王巍
-- 2018-12-13
-- 单位客户月均返佣报表
-- =============================================
CREATE PROCEDURE [dbo].[sp_rpt_3040] 
@cmpid varchar(100), 
@isxf int,
@sDate datetime,
@eDate datetime   
AS
BEGIN

--有返佣及无返佣月均数据
--可变字段 出票时间段 是否有返佣
if @isxf = 0
select convert(varchar(6),datetime,112) 月份,Convert(decimal(18,2),sum(amount),0) as 销量,SUM(xfprice) as 返佣,SUM(tax) 税收,count(1) 张数
,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS 平均折扣率
FROM    V_TicketInfo
WHERE   ( cmpcode = '016448')        
		AND ( datetime BETWEEN '2019-03-01' AND '2019-03-31')
        AND ( reti = '' )
        AND ( inf = 0 )
        and xfprice=0
group by convert(varchar(6),datetime,112)
order by 月份 
else
select convert(varchar(6),datetime,112) 月份,Convert(decimal(18,2),sum(amount),0) as 销量,SUM(xfprice) as 返佣,SUM(tax) 税收,count(1) 张数
,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS 平均折扣率
FROM    V_TicketInfo
WHERE   ( cmpcode = '016448' )
        
		AND ( datetime BETWEEN '2019-04-01' AND '2019-04-30')
        AND ( reti = '' )
        AND ( inf = 0 )
        and xfprice<>0
        and CostCenter='CA'
group by convert(varchar(6),datetime,112)
order by 月份 

END

GO


