
SELECT
SUM(CASE WHEN ( DemandOrderSource = 2 ) THEN 1 ELSE 0 END) AS ������Ӫ�ύ����  ,
SUM(CASE WHEN ( DemandOrderSource = 1 AND CreatedUserGroupName LIKE '%������Ӫ%') THEN 1 ELSE 0 END) AS ������Ӫ�ύ����  ,
SUM(CASE WHEN ( DemandOrderSource = 1 AND CreatedUserGroupName NOT LIKE '%������Ӫ%') THEN 1 ELSE 0 END) AS �����ύ����  
FROM TravelRequirement_DemandOrder
WHERE CreationTime >= '2018-07-01 00:00:00' AND CreationTime <='2018-07-31 23:59:59'