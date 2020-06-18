exec sp_rpt_9999 '019830' 

select id from Trv_UnitCompanies where Cmpid='018294'

--护照有效期
select cr.CredentialNo,cr.ExpirDate from Trv_Credentials cr
left join Trv_Human h on h.ID=cr.HumanID
left join Trv_UnitPersons up on up.ID=h.ID
WHERE up.CompanyID in (select id from Trv_UnitCompanies where Cmpid='018309') 
and cr.Type=2


--审批--机票
IF OBJECT_ID('tempdb.dbo.#sp') IS NOT NULL DROP TABLE #sp
SELECT h.ID,h.Name,LastName,FirstName,MiddleName,h.Mobile,h.Email,t2.TemplateName,up.VettingTemplateID
into #sp
FROM Trv_UnitPersons up
INNER JOIN Trv_Human h ON up.id=h.ID  AND h.IsDisplay=1
left join homsomDB..Trv_VettingTemplate_UnitCompany  t1 on t1.VettingTemplateID=up.VettingTemplateID
left JOIN homsomDB..Trv_VettingTemplates t2 ON t1.VettingTemplateID=t2.ID
WHERE up.CompanyID in (select id from Trv_UnitCompanies where Cmpid='018309') 

--select * from #sp

--审批--酒店
IF OBJECT_ID('tempdb.dbo.#sp2') IS NOT NULL DROP TABLE #sp2
SELECT h.id,h.Name,LastName,FirstName,MiddleName,h.Mobile,h.Email,t2.TemplateName,up.HotelVettingTemplateID
into #sp2
FROM Trv_UnitPersons up
INNER JOIN Trv_Human h ON up.id=h.ID  AND h.IsDisplay=1
left join homsomDB..Trv_VettingTemplateHotel_UnitCompany  t1 on t1.VettingTemplateHotelID=up.HotelVettingTemplateID
left JOIN homsomDB..Trv_VettingTemplates_Hotel t2 ON t1.VettingTemplateHotelID=t2.ID
WHERE up.CompanyID in (select id from Trv_UnitCompanies where Cmpid='019830') 


--select * from #sp2
--审批--火车票
IF OBJECT_ID('tempdb.dbo.#sp2') IS NOT NULL DROP TABLE #sp2
SELECT h.id,h.Name,LastName,FirstName,MiddleName,h.Mobile,h.Email,t2.TemplateName,up.TrainVettingTemplateID
into #sp2
FROM Trv_UnitPersons up
INNER JOIN Trv_Human h ON up.id=h.ID  AND h.IsDisplay=1
left join homsomDB..Trv_VettingTemplateTrain_UnitCompany  t1 on t1.VettingTemplateTrainID=up.HotelVettingTemplateID
left JOIN homsomDB..Trv_VettingTemplates_Train t2 ON t1.VettingTemplateTrainID=t2.ID
WHERE up.CompanyID in (select id from Trv_UnitCompanies where Cmpid='018309') 

--BU
IF OBJECT_ID('tempdb.dbo.#b') IS NOT NULL DROP TABLE #b
select h.id,h.Name,LastName,FirstName,MiddleName,h.Mobile,h.Email,bu.UnderName
into #b
from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_CompanyUndercover bu on bu.ID=p.CompanyUnderId
INNER JOIN Trv_Human h ON p.id=h.ID AND p.CompanyID in (select id from Trv_UnitCompanies where Cmpid='018294') AND h.IsDisplay=1


IF OBJECT_ID('tempdb.dbo.#n') IS NOT NULL DROP TABLE #n
select h.id,h.Name,LastName,h.CreateDate
into #n
from homsomDB..Trv_UnitPersons p
left join Trv_Human h on h.ID=p.ID and IsDisplay=1
left join Trv_CompanyStructure s on s.ID=p.CompanyDptId
where p.CompanyID in (select id from Trv_UnitCompanies where Cmpid='018294')
and h.Name is not null

--翻译拼音
SELECT *,CASE WHEN name<>'' and name NOT LIKE '%[0-9a-zA-Z]%' and left(name,2) not in (SELECT name FROM [EDB2].[dbo].[Compound surname]) THEN Topway.dbo.fn_GetQuanPin(STUFF(name,2,0,'/')) 
WHEN left(name,2)  in (SELECT name FROM [EDB2].[dbo].[Compound surname]) THEN Topway.dbo.fn_GetQuanPin(STUFF(name,3,0,'/'))
ELSE name END	
FROM #n


--ERP
select * from Topway..tbCusPas p
left join topway..tbCusPasSub s on s.cusmenId=p.CusmenId
where  cmpid='018294'

--职位级别
IF OBJECT_ID('tempdb.dbo.#zj') IS NOT NULL DROP TABLE #zj
select h.ID,h.Name,h.LastName,r.Name as 职位级别
into #zj
FROM homsomDB..Trv_Human H 	
INNER JOIN homsomDB..Trv_UnitPersons UP ON H.id=UP.ID AND IsDisplay=1 --AND up.companyid in (select id from Trv_UnitCompanies where Cmpid='019808')
left join  Trv_UPRanks R on r.CompanyID=UP.CompanyID and UP.UPRankID=r.ID
where up.CompanyID in (select id from Trv_UnitCompanies where Cmpid='018294')

--系统角色
IF OBJECT_ID('tempdb.dbo.#js') IS NOT NULL DROP TABLE #js
SELECT h.id,h.Name,h.LastName,r.Name as 系统角色
into #js
FROM homsomDB..Trv_Human h 
inner join  homsomDB..Trv_UnitPersons up ON up.id=h.id AND h.IsDisplay=1
left JOIN Trv_UPRoles R ON  up.CompanyID=r.UnitCompanyID and up.UPRoleID=r.ID
where up.CompanyID in (select id from Trv_UnitCompanies where Cmpid='018294')

--预订类型
IF OBJECT_ID('tempdb.dbo.#yd') IS NOT NULL DROP TABLE #yd
SELECT h.id,h.Name,h.LastName,(case BookingType when 0 then '不可预订' when 1 then '自身预订' when 2 then '为他人预订' when 3 then '所有预订' else '' end) as 预订类型
into #yd
FROM homsomDB..Trv_Human h 
inner join  homsomDB..Trv_UnitPersons up ON up.id=h.id AND h.IsDisplay=1
INNER JOIN homsomDB..Trv_UPSettings sett ON sett.ID=UP.UPSettingID  AND h.IsDisplay=1
INNER JOIN Trv_BookingCollections bookCo ON sett.BookingCollectionID=bookCo.ID
where up.CompanyID in (select id from Trv_UnitCompanies where Cmpid='018294')

select h.id,zj.name,zj.lastname,职位级别,系统角色,预订类型,sp.templatename,sp2.templatename,b.UnderName
from Trv_Human h
left join #zj zj on h.ID=zj.id
left join #js js on js.id=h.ID
left join #yd yd on yd.id=h.ID
inner join #sp sp on sp.id=h.ID
inner join #sp2 sp2 on sp2.id=h.id
inner join #b b on b.id=h.id
