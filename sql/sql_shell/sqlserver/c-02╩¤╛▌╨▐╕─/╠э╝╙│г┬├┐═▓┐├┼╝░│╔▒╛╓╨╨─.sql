select * from homsomDB..Trv_CompanyStructure where CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='017692')
select t3.UserName,t3.ID,* from homsomDB..Trv_UnitPersons t3 inner join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID where t4.IsDisplay=1 and t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='017692')
begin tran
update homsomDB..Trv_UnitPersons set CompanyDptId=t1.部门ID,CostCenterID=t1.成本中心ID 
--
from [EDB2].[dbo].['20160825001$'] t1 inner join homsomDB..Trv_UnitPersons t2 on t1.人员ID=t2.ID 
commit tran
rollback tran

select * from homsomDB..Trv_CostCenter where CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='017692')
update homsomDB..Trv_UnitPersons set CompanyDptId='' from [EDB2].[dbo].[Sheet5$] t1 inner join homsomDB..Trv_UnitPersons t2 on t1.人员ID=t2.ID 
