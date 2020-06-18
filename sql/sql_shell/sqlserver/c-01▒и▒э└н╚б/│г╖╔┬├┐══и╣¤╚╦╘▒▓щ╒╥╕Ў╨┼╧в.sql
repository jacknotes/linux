select name,t5.DepName,Code,* from homsomDB..Trv_UnitPersons t3 
inner join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID and t4.IsDisplay=1
inner join homsomDB.dbo.Trv_CompanyStructure t5 on t3.CompanyDptId=t5.id
where t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='018110') 

--UC��
select * from homsomdb..Trv_UnitCompanies
where  Cmpid='018781'

select * from homsomDB..Trv_UnitPersons 
where Companyid='7A7EC117-734A-4C43-9283-A384010E2CAB'

--���ű�
select * from homsomdb..Trv_CompanyStructure where id in (select CompanyDptId from homsomDB..Trv_UnitPersons t3 inner join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID 
where t4.IsDisplay=1 and t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='019550'))

SELECT t.���,t.�˿�����,*
--p.CustomItem [�Զ�����],reason.ReasonDescription
FROM [EDB2].[dbo].['018781$'] t
LEFT join homsomDB.dbo.Trv_DomesticTicketRecord rec ON t.���۵���=rec.recordNumber 
LEFT JOIN homsomDB..Trv_PnrInfos pnr ON rec.PnrinfoID=pnr.ID
LEFT JOIN homsomDB..Trv_TktBookings tkt ON pnr.ItktBookingID=tkt.ID 
LEFT JOIN homsomDB.dbo.Trv_itktBookings itk ON itk.ID=tkt.id
LEFT JOIN homsomDB..Trv_DeniedReason reason ON reason.ItktBookingID=itk.ID AND reason.ReasonType=1
LEFT JOIN homsomDB..Trv_Passengers p ON p.ItktBookingID = itk.ID  AND p.Name=t.�˿�����
--left join homsomDB..Trv_CompanyStructure dept on dept.CompanyId=
ORDER BY t.���

--�ɱ�����
select t4.Name,t5.Name as �ɱ�����,* from homsomDB..trv_unitpersons t3
left join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID and t4.IsDisplay=1
left join homsomDB..Trv_CostCenter t5 on t3.CompanyID=t5.CompanyID and t3.CostCenterID=t5.id
where t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='018821') 
order by t4.Name

select * from homsomDB..Trv_CostCenter where CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='018821') 

SELECT t.���,t.�˿�����,p.CustomItem [�Զ�����],reason.ReasonDescription
FROM [EDB2].[dbo].[018781_20160901] t
LEFT join homsomDB.dbo.Trv_DomesticTicketRecord rec ON t.���۵���=rec.recordNumber 
LEFT JOIN homsomDB..Trv_PnrInfos pnr ON rec.PnrinfoID=pnr.ID
LEFT JOIN homsomDB..Trv_TktBookings tkt ON pnr.ItktBookingID=tkt.ID 
LEFT JOIN homsomDB.dbo.Trv_itktBookings itk ON itk.ID=tkt.id
LEFT JOIN homsomDB..Trv_DeniedReason reason ON reason.ItktBookingID=itk.ID AND reason.ReasonType=1
LEFT JOIN homsomDB..Trv_Passengers p ON p.ItktBookingID = itk.ID  AND p.Name=t.�˿�����
ORDER BY t.���

--֧����ʽ������Ŀ��
SELECT Coup.���,Coup.���۵���,
--CASE trv.PayType WHEN 1 THEN '��˾��֧��' WHEN 2 THEN '�ͻ���֧��' ELSE ''END AS paytype0,
--CASE itk.CompanyPayType WHEN 0 THEN '��˾��֧��' WHEN 1 THEN '�ͻ���֧��' ELSE ''END AS paytype,
 itk.CompanyPayType,
tkt.Purpose [����Ŀ��]--,trvP.WorkingRemarks [��������],ctrvp.TravelReason [������������]

FROM [EDB2].[dbo].[019401-2016-08] coup
LEFT join homsomDB.dbo.Trv_DomesticTicketRecord rec ON Coup.���۵���=rec.recordNumber 
LEFT JOIN homsomDB..Trv_PnrInfos pnr ON rec.PnrinfoID=pnr.ID
LEFT JOIN homsomDB..Trv_TktBookings tkt ON pnr.ItktBookingID=tkt.ID 
LEFT JOIN homsomDB.dbo.Trv_itktBookings itk ON itk.ID=tkt.id
ORDER BY coup.���

select * FROM [EDB2].[dbo].[019401-2016-08]