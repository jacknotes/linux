SELECT UnitCompanyID,* FROM homsomdb..Trv_Memos
--update homsomdb..Trv_Memos set UnitCompanyID=null
WHERE UnitCompanyID in (select id from homsomdb..Trv_UnitCompanies where Cmpid='018178')
and ID in('0535A70A-F608-4D5F-ACE4-AA3E00E81432')

update homsomdb..Trv_Memos set UnitCompanyID = NULL 
WHERE UnitCompanyID in (select id from homsomdb..Trv_UnitCompanies where Cmpid='017795') and id='E5550029-C7C8-48A2-BA40-A8EB011E9172'
