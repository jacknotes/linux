SELECT (CASE WHEN ( DemandOrderSource =1) THEN '销售提交' ELSE '运营提交' END) AS 来源,COUNT(Id)AS 数量 FROM dbo.TravelRequirement_DemandOrder GROUP BY DemandOrderSource

SELECT OperationsName AS 运营名称,sum(1)AS 总数量,
SUM(CASE WHEN ( DemandOrderStatus IN (1,2,3,4)) THEN 1 ELSE 0 END) AS 处理中  ,
SUM(CASE WHEN ( DemandOrderStatus =5 ) THEN 1 ELSE 0 END) AS 待成团  ,
SUM(CASE WHEN ( DemandOrderStatus =6) THEN 1 ELSE 0 END) AS 已成团  ,
SUM(CASE WHEN ( DemandOrderStatus =7) THEN 1 ELSE 0 END) AS 未成团 
FROM TravelRequirement_DemandOrder
where CreationTime>='2018-10-01' and CreationTime<'2018-10-31'
GROUP BY OperationsName

SELECT OperationsName AS 姓名,sum(1)AS 成团数 FROM (
SELECT T3.OperationsName,row_number() over(partition by T3.DemandOrderOrderNo order by T3.ID) as rownum FROM dbo.TravelRequirement_DemandOrder_OperatingOrder T1
LEFT JOIN dbo.TravelRequirement_Log T2 ON T1.Id=T2.OrderId AND T2.LogType=2 AND T2.LogContentDetail LIKE '%已成团%'
LEFT JOIN dbo.TravelRequirement_DemandOrder T3 ON T1.DemandOrderId=T3.Id
WHERE T1.OperatingOrderStatus=4 AND T2.CreationTime>='2018-10-01 00:00:00' AND T2.CreationTime<='2018-10-31 23:59:59'
)N
WHERE N.rownum=1
GROUP BY OperationsName
