SELECT c.Cmpid,c.Name FROM homsomDB..Trv_UnitCompanies c 
LEFT JOIN homsomDB..Trv_VettingTemplate_UnitCompany v ON c.ID=v.UnitCompanyID
LEFT JOIN homsomDB..Trv_VettingTemplates t ON v.VettingTemplateID=t.ID
LEFT JOIN workflow..Homsom_WF_Template_Node n ON t.TemplateID=n.TemplateID
WHERE ISNULL(n.ProcessPerson_Standby,'')<>'' --AND c.Cmpid='000003'
 GROUP BY c.Cmpid,c.Name