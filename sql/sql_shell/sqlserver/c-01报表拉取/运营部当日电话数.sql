SELECT  count(*)
FROM         RecPhone
WHERE     SYSTEMTIM BETWEEN (select convert(nvarchar(10),getdate(),120)) AND (select convert(nvarchar(10),getdate()+1,120)) and AGENT between '100' and '400' and DIRECTION='0'SELECT d,COUNT(1) AS [呼入次数]from(SELECT convert(nvarchar(10),SYSTEMTIM,120) d,AGENT,COUNT(1) AS [呼入次数]from RecPhone where  dialup='#' and DIRECTION='0' and systemtim between '2014-07-01' and '2016-01-01' and AGENT between '100' and '313' and AGENT !='117' GROUP BY convert(nvarchar(10),SYSTEMTIM,120),AGENT)t
GROUP BY d
ORDER BY d

SELECT d,COUNT(1) AS [呼入次数]from(SELECT convert(nvarchar(10),SYSTEMTIM,120) d,AGENT,COUNT(1) AS [呼入次数]from RecPhone where  dialup='#' and DIRECTION='0' and systemtim>='2014-07-01' and AGENT between '330' and '400' or AGENT ='117' GROUP BY convert(nvarchar(10),SYSTEMTIM,120),AGENT)t
GROUP BY d
ORDER BY d
