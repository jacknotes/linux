
SELECT
SUM(CASE WHEN ( DemandOrderSource = 2 ) THEN 1 ELSE 0 END) AS 旅游运营提交数量  ,
SUM(CASE WHEN ( DemandOrderSource = 1 AND CreatedUserGroupName LIKE '%差旅运营%') THEN 1 ELSE 0 END) AS 差旅运营提交数量  ,
SUM(CASE WHEN ( DemandOrderSource = 1 AND CreatedUserGroupName NOT LIKE '%差旅运营%') THEN 1 ELSE 0 END) AS 销售提交数量  
FROM TravelRequirement_DemandOrder
WHERE CreationTime >= '2018-07-01 00:00:00' AND CreationTime <='2018-07-31 23:59:59'