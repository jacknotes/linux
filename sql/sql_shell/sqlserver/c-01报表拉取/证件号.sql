SELECT * FROM homsomDB..Trv_Human h
LEFT JOIN homsomDB..Trv_UnitPersons u ON h.ID=u.ID
LEFT JOIN homsomDB..Trv_Credentials c ON h.ID=c.HumanID
WHERE h.IsDisplay=1 AND u.CompanyID='019358'

select CredentialNo,t.Name as 姓名,t.FirstName+t.MiddleName+t.LastName as 英文名字 from homsomDB..Trv_Credentials c
left join homsomDB..Trv_Human t on t.ID=c.HumanID 
left join homsomDB..Trv_CompanyTravels c1 on c1.UnitCompanyID=t.companyid 
where c1.UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '019358')
order by CredentialNo

select t.name,CredentialNo,t.FirstName+t.MiddleName+t.LastName as 英文名,t.Mobile,t.Email from homsomDB..Trv_Human t
left join homsomDB..Trv_UnitCompanies t1 on t.ID=t.companyid
left join homsomDB..Trv_Credentials c on t.ID=c.HumanID
left join homsomDB..Trv_UnitCompanies u on u.ID=t.companyid
where u.Cmpid='019358' and(t.Name<>'' or t.FirstName+t.MiddleName+t.LastName<>'' )


Select * from Topway..tbCompanyM where cmpid='019358'
select * from homsomDB..Trv_UnitCompanies where Cmpid='019358'