SELECT n.ProcessPerson,n.ProcessPersonName,h.IsDisplay,
(SELECT h1.id FROM homsomDB..Trv_Human h1 INNER JOIN homsomDB..Trv_UnitPersons u1 ON u1.ID = h1.ID AND h1.name=n.ProcessPersonName AND h1.IsDisplay=1 AND u1.CompanyID='636613F1-2BB0-43F5-AF3C-A7C900D87177') name1
,h.Name,t.*,* 
--UPDATE workflow..Homsom_WF_Template_Node SET ProcessPerson=(SELECT TOP 1 h1.id FROM homsomDB..Trv_Human h1 INNER JOIN homsomDB..Trv_UnitPersons u1 ON u1.ID = h1.ID AND h1.name=n.ProcessPersonName AND h1.IsDisplay=1  AND u1.CompanyID='636613F1-2BB0-43F5-AF3C-A7C900D87177') 
FROM workflow..Homsom_WF_Template_Node n 
LEFT JOIN workflow..Homsom_WF_Template t ON n.TemplateID=t.TemplateID
LEFT JOIN homsomDB..Trv_Human  h ON n.ProcessPerson=h.ID
LEFT JOIN homsomDB..Trv_UnitPersons u ON h.id=u.ID
WHERE n.ProcessPerson<>'' 
AND t.CmpID='020028'
--AND n.TemplateID IN(
--SELECT TemplateID FROM workflow..Homsom_WF_Template WHERE TemplateName IN
--('��������ģ��-��ʢ-������','��������ģ��-�ῡ��-������','��������ģ��-Ҧ��-������','��������ģ��-½����-������','��������ģ��-�⿭-������',
--'��������ģ��-����-������','��������ģ��-������-������','��������ģ��-����-������','��������ģ��-ʯ�ݳ�-������','��������ģ��-���컪-������')
--) 
AND h.IsDisplay=0 order by t.templatename