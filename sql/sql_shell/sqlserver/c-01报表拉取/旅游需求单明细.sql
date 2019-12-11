SELECT  Customers AS �ͻ����� ,
        Contacts AS �ͻ���ϵ�� ,
        ContactNumber AS �ͻ���ϵ�绰 ,
        DomesticNumber AS �������� ,
        DepartureNumber AS ��������,
        (CASE WHEN ( DemandOrderType =1) THEN 'С��' ELSE '��' END) AS ����,
        CreatedUserName AS �ύ��,
        T2.team AS �ύ����,
        T1.OperationsName AS �������ι���,
        T1.OperationGroup AS ������,
        (CASE WHEN ( T1.DemandOrderStatus IN (1,2,3)) THEN '������' WHEN ( T1.DemandOrderStatus IN (4,5)) THEN '������' WHEN ( T1.DemandOrderStatus IN (6)) THEN '�ѳ���' ELSE 'δ����' END) AS ״̬,
        T1.CreationTime AS �ύ����
FROM    dbo.TravelRequirement_DemandOrder T1
LEFT JOIN dbo.Emppwd T2 ON T1.CreatedUserNum=T2.idnumber
WHERE   CreationTime >= '2018-06-01 00:00:00'
        AND CreationTime <= '2018-10-16 23:59:59';