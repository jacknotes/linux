insert into tbcusholderM(cmpid,custid,ccustid,custname,custtype1,male,username,phone,mobilephone,personemail,CardId,custtype,homeadd,joindate) 
select cmpid,CustID,CustID,h.Name,
CASE
WHEN u.Type='��ͨԱ��' THEN ''
WHEN u.Type='������' THEN '3'
WHEN u.Type='������' THEN '4'
WHEN u.Type='�߹�' THEN '5'
ELSE 2 end
,
CASE 
WHEN h.Gender=1 THEN '��'
WHEN h.Gender=0 THEN 'Ů'
ELSE '��' end
,'',h.Telephone,h.Mobile,h.Email,'',u.CustomerType,'�ֹ���������' ,h.CreateDate
FROM homsomDB..Trv_UnitPersons u
INNER JOIN homsomDB..Trv_Human h ON u.id =h.ID
INNER JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID
WHERE Cmpid='019851' AND h.IsDisplay=1 