SELECT  Customers AS 客户名称 ,
        Contacts AS 客户联系人 ,
        ContactNumber AS 客户联系电话 ,
        DomesticNumber AS 国内人数 ,
        DepartureNumber AS 出境人数,
        (CASE WHEN ( DemandOrderType =1) THEN '小单' ELSE '大单' END) AS 类型,
        CreatedUserName AS 提交人,
        T2.team AS 提交部门,
        T1.OperationsName AS 处理旅游顾问,
        T1.OperationGroup AS 处理部门,
        (CASE WHEN ( T1.DemandOrderStatus IN (1,2,3)) THEN '处理中' WHEN ( T1.DemandOrderStatus IN (4,5)) THEN '待成团' WHEN ( T1.DemandOrderStatus IN (6)) THEN '已成团' ELSE '未成团' END) AS 状态,
        T1.CreationTime AS 提交日期
FROM    dbo.TravelRequirement_DemandOrder T1
LEFT JOIN dbo.Emppwd T2 ON T1.CreatedUserNum=T2.idnumber
WHERE   CreationTime >= '2018-06-01 00:00:00'
        AND CreationTime <= '2018-10-16 23:59:59';