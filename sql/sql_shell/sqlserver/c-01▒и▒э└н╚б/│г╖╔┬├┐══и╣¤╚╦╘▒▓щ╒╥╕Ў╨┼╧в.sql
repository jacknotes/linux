select name,t5.DepName,Code,* from homsomDB..Trv_UnitPersons t3 
inner join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID and t4.IsDisplay=1
inner join homsomDB.dbo.Trv_CompanyStructure t5 on t3.CompanyDptId=t5.id
where t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='018110') 

--UC表
select * from homsomdb..Trv_UnitCompanies
where  Cmpid='018781'

select * from homsomDB..Trv_UnitPersons 
where Companyid='7A7EC117-734A-4C43-9283-A384010E2CAB'

--部门表
select * from homsomdb..Trv_CompanyStructure where id in (select CompanyDptId from homsomDB..Trv_UnitPersons t3 inner join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID 
where t4.IsDisplay=1 and t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='019550'))

SELECT t.序号,t.乘客姓名,*
--p.CustomItem [自定义项],reason.ReasonDescription
FROM [EDB2].[dbo].['018781$'] t
LEFT join homsomDB.dbo.Trv_DomesticTicketRecord rec ON t.销售单号=rec.recordNumber 
LEFT JOIN homsomDB..Trv_PnrInfos pnr ON rec.PnrinfoID=pnr.ID
LEFT JOIN homsomDB..Trv_TktBookings tkt ON pnr.ItktBookingID=tkt.ID 
LEFT JOIN homsomDB.dbo.Trv_itktBookings itk ON itk.ID=tkt.id
LEFT JOIN homsomDB..Trv_DeniedReason reason ON reason.ItktBookingID=itk.ID AND reason.ReasonType=1
LEFT JOIN homsomDB..Trv_Passengers p ON p.ItktBookingID = itk.ID  AND p.Name=t.乘客姓名
--left join homsomDB..Trv_CompanyStructure dept on dept.CompanyId=
ORDER BY t.序号

--成本中心
select t4.Name,t5.Name as 成本中心,* from homsomDB..trv_unitpersons t3
left join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID and t4.IsDisplay=1
left join homsomDB..Trv_CostCenter t5 on t3.CompanyID=t5.CompanyID and t3.CostCenterID=t5.id
where t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='018821') 
order by t4.Name

select * from homsomDB..Trv_CostCenter where CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='018821') 

SELECT t.序号,t.乘客姓名,p.CustomItem [自定义项],reason.ReasonDescription
FROM [EDB2].[dbo].[018781_20160901] t
LEFT join homsomDB.dbo.Trv_DomesticTicketRecord rec ON t.销售单号=rec.recordNumber 
LEFT JOIN homsomDB..Trv_PnrInfos pnr ON rec.PnrinfoID=pnr.ID
LEFT JOIN homsomDB..Trv_TktBookings tkt ON pnr.ItktBookingID=tkt.ID 
LEFT JOIN homsomDB.dbo.Trv_itktBookings itk ON itk.ID=tkt.id
LEFT JOIN homsomDB..Trv_DeniedReason reason ON reason.ItktBookingID=itk.ID AND reason.ReasonType=1
LEFT JOIN homsomDB..Trv_Passengers p ON p.ItktBookingID = itk.ID  AND p.Name=t.乘客姓名
ORDER BY t.序号

--支付方式、差旅目的
SELECT Coup.序号,Coup.销售单号,
--CASE trv.PayType WHEN 1 THEN '公司方支付' WHEN 2 THEN '客户方支付' ELSE ''END AS paytype0,
--CASE itk.CompanyPayType WHEN 0 THEN '公司方支付' WHEN 1 THEN '客户方支付' ELSE ''END AS paytype,
 itk.CompanyPayType,
tkt.Purpose [差旅目的]--,trvP.WorkingRemarks [工作事项],ctrvp.TravelReason [出差申请理由]

FROM [EDB2].[dbo].[019401-2016-08] coup
LEFT join homsomDB.dbo.Trv_DomesticTicketRecord rec ON Coup.销售单号=rec.recordNumber 
LEFT JOIN homsomDB..Trv_PnrInfos pnr ON rec.PnrinfoID=pnr.ID
LEFT JOIN homsomDB..Trv_TktBookings tkt ON pnr.ItktBookingID=tkt.ID 
LEFT JOIN homsomDB.dbo.Trv_itktBookings itk ON itk.ID=tkt.id
ORDER BY coup.序号

select * FROM [EDB2].[dbo].[019401-2016-08]