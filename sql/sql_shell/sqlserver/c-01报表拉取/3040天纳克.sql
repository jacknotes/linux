USE [Topway]
GO

/****** Object:  StoredProcedure [dbo].[sp_rpt_3040]    Script Date: 04/08/2019 14:46:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- ��Ρ
-- 2018-12-13
-- ��λ�ͻ��¾���Ӷ����
-- =============================================
CREATE PROCEDURE [dbo].[sp_rpt_3040] 
@cmpid varchar(100), 
@isxf int,
@sDate datetime,
@eDate datetime   
AS
BEGIN

--�з�Ӷ���޷�Ӷ�¾�����
--�ɱ��ֶ� ��Ʊʱ��� �Ƿ��з�Ӷ
if @isxf = 0
select convert(varchar(6),datetime,112) �·�,Convert(decimal(18,2),sum(amount),0) as ����,SUM(xfprice) as ��Ӷ,SUM(tax) ˰��,count(1) ����
,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS ƽ���ۿ���
FROM    V_TicketInfo
WHERE   ( cmpcode = '016448')        
		AND ( datetime BETWEEN '2019-03-01' AND '2019-03-31')
        AND ( reti = '' )
        AND ( inf = 0 )
        and xfprice=0
group by convert(varchar(6),datetime,112)
order by �·� 
else
select convert(varchar(6),datetime,112) �·�,Convert(decimal(18,2),sum(amount),0) as ����,SUM(xfprice) as ��Ӷ,SUM(tax) ˰��,count(1) ����
,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS ƽ���ۿ���
FROM    V_TicketInfo
WHERE   ( cmpcode = '016448' )
        
		AND ( datetime BETWEEN '2019-04-01' AND '2019-04-30')
        AND ( reti = '' )
        AND ( inf = 0 )
        and xfprice<>0
        and CostCenter='CA'
group by convert(varchar(6),datetime,112)
order by �·� 

END

GO


