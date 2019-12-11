


SELECT VettingTemplateID,TemplateName
FROM homsomDB..Trv_VettingTemplate_UnitCompany  t1
INNER JOIN homsomDB..Trv_VettingTemplates t2 ON t1.VettingTemplateID=t2.ID
WHERE UnitCompanyID in (SELECT id FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019270')

SELECT VettingTemplateHotelID,TemplateName
FROM homsomDB..Trv_VettingTemplateHotel_UnitCompany  t1
INNER JOIN homsomDB..Trv_VettingTemplates_Hotel t2 ON t1.VettingTemplateHotelID=t2.ID
WHERE UnitCompanyID in (SELECT id FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019270')