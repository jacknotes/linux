SELECT OperationsName AS ����,sum(1)AS ������,
SUM(CASE WHEN ( DemandOrderStatus IN (1,2,3)) THEN 1 ELSE 0 END) AS ������  ,
SUM(CASE WHEN ( DemandOrderStatus IN (4,5)) THEN 1 ELSE 0 END) AS ������  ,
SUM(CASE WHEN ( DemandOrderStatus =6) THEN 1 ELSE 0 END) AS �ѳ���  ,
SUM(CASE WHEN ( DemandOrderStatus =7) THEN 1 ELSE 0 END) AS δ���� 
FROM TravelRequirement_DemandOrder
WHERE CreationTime >= '2018-07-01 00:00:00' AND CreationTime <='2018-07-31 23:59:59'
GROUP BY OperationsName