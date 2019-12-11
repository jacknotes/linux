use homsomDB

exec sp_rpt_9999 '019259' 

select id from Trv_UnitCompanies where Cmpid='019259'

--������Ч��
select cr.CredentialNo,cr.ExpirDate from Trv_Credentials cr
left join Trv_Human h on h.ID=cr.HumanID
left join Trv_UnitPersons up on up.ID=h.ID
WHERE up.CompanyID in (select id from Trv_UnitCompanies where Cmpid='019259') 
and cr.Type=2


--����--��Ʊ
IF OBJECT_ID('tempdb.dbo.#sp') IS NOT NULL DROP TABLE #sp
SELECT h.Name,LastName,FirstName,MiddleName,h.Mobile,h.Email,t2.TemplateName,up.VettingTemplateID
into #sp
FROM Trv_UnitPersons up
INNER JOIN Trv_Human h ON up.id=h.ID  AND h.IsDisplay=1
left join homsomDB..Trv_VettingTemplate_UnitCompany  t1 on t1.VettingTemplateID=up.VettingTemplateID
left JOIN homsomDB..Trv_VettingTemplates t2 ON t1.VettingTemplateID=t2.ID
WHERE up.CompanyID in (select id from Trv_UnitCompanies where Cmpid='019259') 

--select * from #sp

--����--�Ƶ�
IF OBJECT_ID('tempdb.dbo.#sp2') IS NOT NULL DROP TABLE #sp2
SELECT h.Name,LastName,FirstName,MiddleName,h.Mobile,h.Email,t2.TemplateName,up.HotelVettingTemplateID
into #sp2
FROM Trv_UnitPersons up
INNER JOIN Trv_Human h ON up.id=h.ID  AND h.IsDisplay=1
left join homsomDB..Trv_VettingTemplateHotel_UnitCompany  t1 on t1.VettingTemplateHotelID=up.HotelVettingTemplateID
left JOIN homsomDB..Trv_VettingTemplates_Hotel t2 ON t1.VettingTemplateHotelID=t2.ID
WHERE up.CompanyID in (select id from Trv_UnitCompanies where Cmpid='019259') 


--select * from #sp2

--BU
select h.Name,LastName,FirstName,MiddleName,h.Mobile,h.Email,bu.UnderName
from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_CompanyUndercover bu on bu.ID=p.CompanyUnderId
INNER JOIN Trv_Human h ON p.id=h.ID AND p.CompanyID in (select id from Trv_UnitCompanies where Cmpid='019259') AND h.IsDisplay=1


IF OBJECT_ID('tempdb.dbo.#n') IS NOT NULL DROP TABLE #n
select h.Name,LastName,h.CreateDate,*
--into #n
from homsomDB..Trv_UnitPersons p
left join Trv_Human h on h.ID=p.ID and IsDisplay=1
left join Trv_CompanyStructure s on s.ID=p.CompanyDptId
where p.CompanyID in (select id from Trv_UnitCompanies where Cmpid='019259')
and h.Name is not null

--����ƴ��
SELECT *,CASE WHEN name<>'' and name NOT LIKE '%[0-9a-zA-Z]%' and left(name,2) not in (SELECT name FROM [EDB2].[dbo].[Compound surname]) THEN Topway.dbo.fn_GetQuanPin(STUFF(name,2,0,'/')) 
WHEN left(name,2)  in (SELECT name FROM [EDB2].[dbo].[Compound surname]) THEN Topway.dbo.fn_GetQuanPin(STUFF(name,3,0,'/'))
ELSE name END	
FROM #n


--ERP
select * from Topway..tbCusPas p
left join topway..tbCusPasSub s on s.cusmenId=p.CusmenId
where  cmpid='019259'

--ְλ����
IF OBJECT_ID('tempdb.dbo.#zj') IS NOT NULL DROP TABLE #zj
select h.Name,h.LastName,r.Name as ְλ����
into #zj
FROM homsomDB..Trv_Human H 	
INNER JOIN homsomDB..Trv_UnitPersons UP ON H.id=UP.ID AND IsDisplay=1 --AND up.companyid in (select id from Trv_UnitCompanies where Cmpid='019808')
left join  Trv_UPRanks R on r.CompanyID=UP.CompanyID and UP.UPRankID=r.ID
where up.CompanyID in (select id from Trv_UnitCompanies where Cmpid='019259')

--ϵͳ��ɫ
IF OBJECT_ID('tempdb.dbo.#js') IS NOT NULL DROP TABLE #js
SELECT h.Name,h.LastName,r.Name as ϵͳ��ɫ
into #js
FROM homsomDB..Trv_Human h 
inner join  homsomDB..Trv_UnitPersons up ON up.id=h.id AND h.IsDisplay=1
left JOIN Trv_UPRoles R ON  up.CompanyID=r.UnitCompanyID and up.UPRoleID=r.ID
where up.CompanyID in (select id from Trv_UnitCompanies where Cmpid='019259')

--Ԥ������
IF OBJECT_ID('tempdb.dbo.#yd') IS NOT NULL DROP TABLE #yd
SELECT h.Name,h.LastName,(case BookingType when 0 then '����Ԥ��' when 1 then '����Ԥ��' when 2 then 'Ϊ����Ԥ��' when 3 then '����Ԥ��' else '' end) as Ԥ������
into #yd
FROM homsomDB..Trv_Human h 
inner join  homsomDB..Trv_UnitPersons up ON up.id=h.id AND h.IsDisplay=1
INNER JOIN homsomDB..Trv_UPSettings sett ON sett.ID=UP.UPSettingID  AND h.IsDisplay=1
INNER JOIN Trv_BookingCollections bookCo ON sett.BookingCollectionID=bookCo.ID
where up.CompanyID in (select id from Trv_UnitCompanies where Cmpid='019259')

select zj.name,zj.lastname,ְλ����,ϵͳ��ɫ,Ԥ������,sp.templatename,sp2.templatename from #zj zj
inner join #js js on js.name=zj.name
inner join #yd yd on yd.name=zj.name
inner join #sp sp on sp.name=zj.name
inner join #sp2 sp2 on sp2.name=zj.name
