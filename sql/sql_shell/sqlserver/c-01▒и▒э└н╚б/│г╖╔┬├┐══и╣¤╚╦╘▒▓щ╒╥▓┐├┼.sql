select name,t5.DepName,Code,* from homsomDB..Trv_UnitPersons t3 
inner join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID and t4.IsDisplay=1
inner join homsomDB.dbo.Trv_CompanyStructure t5 on t3.CompanyDptId=t5.id
where t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='018781') 

--UC表
select * from homsomdb..Trv_UnitCompanies
where  Cmpid='018781'

select * from homsomDB..Trv_UnitPersons 
where 

--部门表
select * from homsomdb..Trv_CompanyStructure where id in (select CompanyDptId from homsomDB..Trv_UnitPersons t3 inner join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID 
where t4.IsDisplay=1 and t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='019550'))

--成本中心
select t3.Name,* from homsomDB..trv_unitpersons t3
inner join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID and t4.IsDisplay=1
inner join homsomDB..Trv_CostCenter t5 on t3.CompanyID=t5.CompanyID
where t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='018781') 

select * from homsomDB..Trv_CostCenter where CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='018781') 

