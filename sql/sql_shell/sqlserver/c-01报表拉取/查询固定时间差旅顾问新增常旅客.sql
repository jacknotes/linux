--2019-01-21��ӵĳ����ÿ�
 SELECT 
ISNULL(c.Cmpid,'') AS ��λ���,
ISNULL(c.Name,'') AS ��λ����,
ISNULL(h.Name,'') AS ������,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS Ӣ����,
h.Mobile AS �ֻ�����,
ISNULL((SELECT TOP 1 empname FROM Topway..Emppwd WHERE idnumber=h.CreateBy),'') AS ���ù���,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS ��Ӫ����
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate>='2019-02-13' AND h.CreateDate<'2019-02-14' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT idnumber FROM Topway..Emppwd WHERE dep='��Ӫ��' AND idnumber NOT IN('00002','00003','0421'))
UNION ALL

SELECT 
ISNULL(c.Cmpid,'') AS ��λ���,
ISNULL(c.Name,'') AS ��λ����,
ISNULL(h.Name,'') AS ������,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS Ӣ����,
ISNULL(h.Mobile,'') AS �ֻ�����,
h.CreateBy AS ���ù���,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS ��Ӫ����
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate>='2019-02-13' AND h.CreateDate<'2019-02-14' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT empname FROM Topway..Emppwd WHERE dep='��Ӫ��' AND empname NOT IN('homsom','��˳����','��Ӫ��ѵ����'))


