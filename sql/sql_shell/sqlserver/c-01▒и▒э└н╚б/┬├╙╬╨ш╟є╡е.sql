SELECT OperationsName AS 姓名,sum(1)AS 需求单数,
SUM(CASE WHEN ( DemandOrderStatus IN (1,2,3)) THEN 1 ELSE 0 END) AS 处理中  ,
SUM(CASE WHEN ( DemandOrderStatus IN (4,5)) THEN 1 ELSE 0 END) AS 待成团  ,
SUM(CASE WHEN ( DemandOrderStatus =6) THEN 1 ELSE 0 END) AS 已成团  ,
SUM(CASE WHEN ( DemandOrderStatus =7) THEN 1 ELSE 0 END) AS 未成团 
FROM TravelRequirement_DemandOrder
WHERE CreationTime >= '2018-07-01 00:00:00' AND CreationTime <='2018-07-31 23:59:59'
GROUP BY OperationsName