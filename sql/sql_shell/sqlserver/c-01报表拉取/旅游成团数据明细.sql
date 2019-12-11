SELECT (CASE WHEN ( DemandOrderSource =1) THEN '�����ύ' ELSE '��Ӫ�ύ' END) AS ��Դ,COUNT(Id)AS ���� FROM dbo.TravelRequirement_DemandOrder GROUP BY DemandOrderSource

SELECT OperationsName AS ��Ӫ����,sum(1)AS ������,
SUM(CASE WHEN ( DemandOrderStatus IN (1,2,3,4)) THEN 1 ELSE 0 END) AS ������  ,
SUM(CASE WHEN ( DemandOrderStatus =5 ) THEN 1 ELSE 0 END) AS ������  ,
SUM(CASE WHEN ( DemandOrderStatus =6) THEN 1 ELSE 0 END) AS �ѳ���  ,
SUM(CASE WHEN ( DemandOrderStatus =7) THEN 1 ELSE 0 END) AS δ���� 
FROM TravelRequirement_DemandOrder
where CreationTime>='2018-10-01' and CreationTime<'2018-10-31'
GROUP BY OperationsName

SELECT OperationsName AS ����,sum(1)AS ������ FROM (
SELECT T3.OperationsName,row_number() over(partition by T3.DemandOrderOrderNo order by T3.ID) as rownum FROM dbo.TravelRequirement_DemandOrder_OperatingOrder T1
LEFT JOIN dbo.TravelRequirement_Log T2 ON T1.Id=T2.OrderId AND T2.LogType=2 AND T2.LogContentDetail LIKE '%�ѳ���%'
LEFT JOIN dbo.TravelRequirement_DemandOrder T3 ON T1.DemandOrderId=T3.Id
WHERE T1.OperatingOrderStatus=4 AND T2.CreationTime>='2018-10-01 00:00:00' AND T2.CreationTime<='2018-10-31 23:59:59'
)N
WHERE N.rownum=1
GROUP BY OperationsName
