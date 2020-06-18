--UC019392删除常旅客名下成本中心
select  CostCenterID,* from homsomDB..Trv_UnitPersons 
--update homsomDB..Trv_UnitPersons  set CostCenterID=null
where CompanyID=(Select  ID from homsomDB..Trv_UnitCompanies 
where Cmpid='019392')

select* from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='019392' and IsDisplay=1


--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='018131_20190501'

--删除到账认领
select * 
--delete
from Topway..FinanceERP_ClientBankRealIncomeDetail where money='4553' and date='2019-05-23'

select * 
--delete
from Topway..FinanceERP_ClientBankRealIncomeDetail where money='3725.4' and date='2019-05-22'

--019392删除成本中心
--解除绑定
select CostCenterID,* from homsomDB..Trv_UnitPersons 
--update homsomDB..Trv_UnitPersons  set CostCenterID=null
where CostCenterID in (Select ID from homsomDB..Trv_CostCenter 
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='019392'))
--恢复单位ID
update homsomDB..Trv_UnitPersons set CompanyID='89B4A12D-49C8-4799-983A-A7DD00EA2FA1' where CustID='D611851'
update homsomDB..Trv_UnitPersons set CompanyID='8064A2D7-0C42-4EF5-BB3D-1B2DEE3C0730' where CustID='D619074'
update homsomDB..Trv_UnitPersons set CompanyID='77FDB9BE-2A54-419C-A43F-C93DF433CAE8' where CustID='D621109'
--删除成本中心
select CompanyID, * 
--delete
from homsomDB..Trv_CostCenter 
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='019392')

--019392插入成本中心
select * from homsomDB..Trv_CostCenter
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'700029','700029','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'700051','700051','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'700052','700052','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'700053','700053','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'700054','700054','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'700055','700055','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'700056','700056','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'700058','700058','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'700059','700059','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1402820.000000','1402820.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1402820.160000','1402820.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1402820.880000','1402820.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1403676.000000','1403676.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1403676.160000','1403676.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1403886 .000000','1403886 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1403886 .160000','1403886 .160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1404240.000000','1404240.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1404641.000000','1404641.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1404641.160000','1404641.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1405080.000000','1405080.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1405080.160000','1405080.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1405353.160000','1405353.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1405370.000000','1405370.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1405752 .000000','1405752 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1405889.880000','1405889.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1406041.000000','1406041.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1406312.000000','1406312.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1406312.160000','1406312.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1406312.880000','1406312.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1406920.000000','1406920.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1407134.000000','1407134.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'149591905.880000','149591905.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'149591306.880000','149591306.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'149591305.880000','149591305.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'149591304.880000','149591304.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'141593901.880000','141593901.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'141521301.880000','141521301.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'141435001.880000','141435001.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'141388101.880000','141388101.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'141338301.880000','141338301.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'141289901.880000','141289901.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'141253001.880000','141253001.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'141230003.880000','141230003.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140982201.880000','140982201.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140981401.880000','140981401.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140981301.880000','140981301.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140980802.880000','140980802.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140972503.880000','140972503.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140970101.880000','140970101.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140970001.880000','140970001.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140969201.880000','140969201.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140776204.880000','140776204.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140776201.880000','140776201.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140715703 .880000','140715703 .880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140584404.880000','140584404.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140584403.880000','140584403.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140537104.880000','140537104.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140524803.880000','140524803.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140523305.880000','140523305.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140523304.880000','140523304.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140523303.880000','140523303.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140461303.880000','140461303.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140448507.880000','140448507.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140429301.880000','140429301.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140404807.880000','140404807.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140213007.880000','140213007.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140208503.880000','140208503.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140208502.880000','140208502.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1495745.160000','1495745.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1415836 .000000','1415836 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1415837 .000000','1415837 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1415968 .000000','1415968 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1415987 .000000','1415987 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1416014 .000000','1416014 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1416043 .00000','1416043 .00000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1416139 .000000','1416139 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1416165 .000000','1416165 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1415793.160000','1415793.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140238204.880000','140238204.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140404806.880000','140404806.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'140213006.880000','140213006.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1407241.000000','1407241.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1407241.160000','1407241.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1407241.160100','1407241.160100','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1407378.000000','1407378.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1407378.160000','1407378.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1407524.000000','1407524.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1407524.16000','1407524.16000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1407524.880000','1407524.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1407623.880000','1407623.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1407962.000000','1407962.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1407964.000000','1407964.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1407964 .160000','1407964 .160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1408126 .000000','1408126 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1408241.000000','1408241.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1408241.160000','1408241.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1408757.160000','1408757.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1408816.880000','1408816.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1408916.160000','1408916.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1408916.880000','1408916.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1409052.000000','1409052.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1409052 .160000','1409052 .160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1409054. 880000','1409054. 880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1409189 .000000','1409189 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1409241.880000','1409241.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1409583.000000','1409583.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1409583.160000','1409583.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1409693.880000','1409693.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1409825 .000000','1409825 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1409825.160000','1409825.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1410088.000000','1410088.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1410211.000000','1410211.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1410315.000000','1410315.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1410362.000000','1410362.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1410415 .000000','1410415 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1410526.000000','1410526.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1410536.000000','1410536.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1410536.160000','1410536.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1410675.000000','1410675.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1410675 .160000','1410675 .160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1410817 .000000','1410817 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1410826.000000','1410826.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1410826.160000','1410826.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1410826.160100','1410826.160100','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1411022.880000','1411022.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1411066.000000','1411066.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1411069.000000','1411069.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1411069 .160000','1411069 .160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1411190.880000','1411190.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1411782.160000','1411782.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1411793.000000','1411793.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1411794.000000','1411794.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1411944.000000','1411944.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1411944 .160000','1411944 .160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1412129.000000','1412129.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1412129.160000','1412129.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1412289.880000','1412289.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1412290 .000000','1412290 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1412303.160000','1412303.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1412327 .000000','1412327 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1412384 .000000','1412384 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1412459.880000','1412459.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1412552 .000000','1412552 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1412746 .000000','1412746 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1412747 .000000','1412747 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1412915.000000','1412915.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1412995 .880000','1412995 .880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1413464.160000','1413464.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1413557 .000000','1413557 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1413630.000000','1413630.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1413680.160000','1413680.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1413704.00000','1413704.00000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1413704.160000','1413704.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1413705.160000','1413705.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1413712.880000','1413712.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1413724.000000','1413724.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1413754.880000','1413754.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1413947.000000','1413947.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414016 .000000','1414016 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414026.000000','1414026.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414026.160000','1414026.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414110 .000000','1414110 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414110 .160000','1414110 .160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414338.160000','1414338.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414339.000000','1414339.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414340.000000','1414340.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414467 .000000','1414467 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414490.000000','1414490.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414601.000000','1414601.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414705 .000000','1414705 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414840.000000','1414840.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414861 .000000','1414861 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414869.000000','1414869.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414937.000000','1414937.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1414965.000000','1414965.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1415302.000000','1415302.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1415333.160000','1415333.160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1415393 .160000','1415393 .160000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1415410 .000000','1415410 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1415413.000000','1415413.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1415426 .000000','1415426 .000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1415470.000000','1415470.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1415547.000000','1415547.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1415643.880000','1415643.880000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)
insert into Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyID,ParentId) values(NEWID(),GETDATE(),'1415681.000000','1415681.000000','','homsom',GETDATE(),'homsom',GETDATE(),'8733D8C2-EA46-4087-92AC-A541011086C4',null)


/*
请根据UC号拉取出票数据：
出票日期：2019.5.1-2019.5.31
客票类型：国内+国际
*/
select distinct cmpcode,pasname,idno from Topway..tbcash with (nolock)
where datetime>='2019-05-01'
and datetime<'2019-06-01'
and inf=1
and cmpcode in('020027',
'018080',
'020305',
'016709',
'019436',
'017888',
'020260',
'020724',
'016588',
'017202',
'017649',
'017399',
'020146',
'020741',
'020355',
'017996',
'018809',
'019360',
'016426',
'020315',
'020723',
'018125',
'016402',
'017012',
'018400',
'018326',
'016337',
'020249',
'020063',
'020698',
'016087',
'016346',
'019158',
'019219',
'020200',
'018627',
'017056',
'017920',
'019261',
'019972',
'020507',
'016834',
'020053',
'020545',
'017415',
'016531',
'019557',
'016515',
'019987',
'019159',
'020324',
'020342',
'016352',
'018131',
'020183',
'019997',
'017762',
'020571',
'016490',
'018591',
'017947',
'018570',
'019845',
'019539',
'014412',
'015717',
'016572',
'016696',
'016777',
'016883',
'017173',
'017273',
'017525',
'017670',
'018064',
'018108',
'018294',
'018314',
'018574',
'018661',
'018827',
'018939',
'019143',
'019245',
'019294',
'019349',
'019362',
'019409',
'019423',
'019473',
'019483',
'019513',
'019591',
'019637',
'019651',
'019654',
'019796',
'019798',
'019822',
'019948',
'019996',
'020020',
'020051',
'020158',
'020220',
'020262',
'020297',
'020310',
'020350',
'020370',
'020441',
'020504',
'020511',
'020521',
'020530',
'020541',
'020588',
'020589',
'020614',
'020659',
'020677',
'020708',
'020711',
'020719',
'020730',
'020731',
'019556',
'000126',
'001787',
'015828',
'016179',
'016465',
'016477',
'016556',
'016564',
'016602',
'016655',
'016689',
'016712',
'016751',
'016991',
'017120',
'017125',
'017153',
'017193',
'017275',
'017339',
'017376',
'017423',
'017491',
'017506',
'017642',
'017674',
'017739',
'017745',
'017850',
'017865',
'017887',
'017969',
'017988',
'018021',
'018156',
'018257',
'018309',
'018362',
'018397',
'018443',
'018449',
'018615',
'018642',
'018677',
'018793',
'018821',
'018897',
'019089',
'019112',
'019197',
'019226',
'019242',
'019256',
'019259',
'019270',
'019325',
'019392',
'019404',
'019505',
'019550',
'019619',
'019641',
'019663',
'019717',
'019839',
'019897',
'019925',
'019935',
'019944',
'019956',
'019975',
'019976',
'019978',
'020017',
'020036',
'020039',
'020154',
'020165',
'020176',
'020287',
'020348',
'020359',
'020506',
'020592',
'020640',
'020717',
'007638',
'009005',
'016262',
'016267',
'016284',
'016287',
'016309',
'016339',
'016344',
'016354',
'016362',
'016379',
'016420',
'016500',
'016525',
'016610',
'016617',
'016640',
'016670',
'016707',
'016773',
'016795',
'016826',
'016858',
'016859',
'016884',
'017016',
'017088',
'017101',
'017122',
'017128',
'017135',
'017154',
'017191',
'017258',
'017283',
'017300',
'017319',
'017368',
'017392',
'017454',
'017474',
'017493',
'017504',
'017549',
'017569',
'017577',
'017579',
'017663',
'017667',
'017680',
'017754',
'017786',
'017800',
'017822',
'017872',
'017893',
'017914',
'017924',
'017931',
'017944',
'017956',
'017957',
'017980',
'017985',
'018017',
'018103',
'018116',
'018141',
'018161',
'018220',
'018232',
'018271',
'018283',
'018296',
'018367',
'018382',
'018395',
'018412',
'018415',
'018418',
'018451',
'018480',
'018486',
'018537',
'018539',
'018546',
'018560',
'018567',
'018580',
'018633',
'018652',
'018676',
'018690',
'018714',
'018724',
'018743',
'018751',
'018816',
'018886',
'018892',
'018902',
'018911',
'018937',
'018938',
'018943',
'018964',
'018989',
'019049',
'019072',
'019097',
'019145',
'019183',
'019212',
'019234',
'019235',
'019252',
'019273',
'019284',
'019290',
'019333',
'019366',
'019420',
'019429',
'019435',
'019448',
'019461',
'019462',
'019463',
'019502',
'019520',
'019524',
'019540',
'019580',
'019583',
'019584',
'019603',
'019628',
'019629',
'019679',
'019712',
'019727',
'019731',
'019735',
'019760',
'019771',
'019784',
'019788',
'019812',
'019843',
'019855',
'019908',
'019943',
'019969',
'019979',
'019982',
'019983',
'019992',
'020001',
'020015',
'020022',
'020028',
'020038',
'020045',
'020061',
'020062',
'020107',
'020110',
'020111',
'020112',
'020113',
'020115',
'020118',
'020124',
'020128',
'020130',
'020138',
'020174',
'020181',
'020187',
'020192',
'020195',
'020199',
'020207',
'020212',
'020214',
'020218',
'020221',
'020224',
'020238',
'020241',
'020261',
'020264',
'020266',
'020269',
'020272',
'020282',
'020283',
'020289',
'020296',
'020298',
'020302',
'020304',
'020312',
'020314',
'020327',
'020334',
'020335',
'020346',
'020360',
'020364',
'020366',
'020371',
'020401',
'020405',
'020413',
'020430',
'020447',
'020453',
'020455',
'020470',
'020475',
'020483',
'020490',
'020491',
'020497',
'020508',
'020514',
'020538',
'020547',
'020553',
'020556',
'020567',
'020570',
'020579',
'020583',
'020591',
'020594',
'020598',
'020617',
'020630',
'020639',
'020649',
'020656',
'020664',
'020680',
'020694',
'020699',
'020720',
'020753',
'020756',
'020774',
'020778')
order by cmpcode

--UC020866 上海依迪索时装有限公司 他人预订导入
if OBJECT_ID ('tempdb..#spr') is not null drop table #spr
select Cmpid,up.BookingCollectionID 
into #spr
from homsomDB..Trv_Human h 
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies  un on un.ID=u.CompanyID
left join homsomDB..Trv_UPSettings up on up.ID=u.UPSettingID
where Cmpid='020866' and h.Name in('张昵','吴湄倩','姚思琪')

if OBJECT_ID ('tempdb..#sp') is not null drop table #sp
select BookingCollectionID,un.ID 
into #sp
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons un on un.ID=h.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=un.CompanyID
left join #spr s on s.cmpid=u.Cmpid
where u.Cmpid='020866' 
and h.Name in('江舟',
'游解',
'裘思悦',
'项海静',
'唐成喜',
'郭学芳',
'李晓露',
'胡文秋',
'周江',
'孙绩骅',
'郑舜国',
'张雨欣',
'赵爱雯',
'丁迪',
'朱纳',
'骆叶',
'徐杰',
'戴曾琦',
'郑欣欣',
'蒋祺',
'李琳娜',
'丁孙浩',
'罗晔君',
'黄鹂',
'邹丽丽',
'张昵',
'刘玲',
'韩咪咪',
'金玉丽',
'钟翠香',
'陈月月',
'苏珊',
'齐凌卉',
'梁康华',
'郑亚男',
'徐婷婷',
'徐雨佳',
'朱燕萍',
'魏欣欣',
'牟蕾颖',
'关洪美',
'陈汶',
'吴湄倩',
'金琳佳',
'姚思琪',
'彭凤',
'沈少卿',
'高思昀',
'刘相宜',
'周梦笑',
'王思岩',
'王晶晶',
'吴晓溪',
'王雷',
'孙默语',
'赵紫玉',
'童晓雪',
'段娜',
'韩易勇',
'李沫',
'闫媛媛')


insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) select BookingCollectionID,ID from #sp


--UC020866 上海依迪索时装有限公司 他人预订导入
if OBJECT_ID ('tempdb..#spr') is not null drop table #spr
select Cmpid,up.BookingCollectionID 
into #spr
from homsomDB..Trv_Human h 
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies  un on un.ID=u.CompanyID
left join homsomDB..Trv_UPSettings up on up.ID=u.UPSettingID
where Cmpid='020866' and h.Name in('梁安琪','谢素蓉')

if OBJECT_ID ('tempdb..#sp') is not null drop table #sp
select BookingCollectionID,un.ID 
into #sp
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons un on un.ID=h.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=un.CompanyID
left join #spr s on s.cmpid=u.Cmpid
where u.Cmpid='020866' 
and h.Name in('韩冬清',
'杨杰英',
'利民',
'刘运村',
'钟泽鸿',
'陈瑞意',
'邓俊荣',
'杨春丽',
'胡林',
'朱梦诗',
'莫靖婷',
'季竞明',
'文嘉莉',
'郑晨',
'梁安琪',
'肖晓蕾',
'梁美妮',
'谢素蓉',
'曾瑞海',
'温汝驰',
'马泽标',
'周瑶',
'罗嘉欣',
'卓思敏')

insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) select BookingCollectionID,ID from #sp



--（产品部专用）机票供应商来源（国内）
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno in('AS002505112','AS002505114','AS002505134','AS002505136','AS002506067',
'AS002506434','AS002510650','AS002511092','AS002511766')

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETI'
where coupno in('AS002510824')

--修改退票审核日期
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti  set ExamineDate='2019-05-30'
where reno in ('0436534','0436535')

--火车票销售单作废
select * 
--delete
from Topway..tbTrainUser where TrainTicketNo in(select ID from Topway..tbTrainTicketInfo 
where CoupNo in('RS000024972','RS000024973','RS000024974','RS000024975'))

select * 
--delete
from Topway..tbTrainTicketInfo 
where CoupNo in('RS000024972','RS000024973','RS000024974','RS000024975')

--火车票销售单作废
select * 
--delete
from Topway..tbTrainUser where TrainTicketNo in(select ID from Topway..tbTrainTicketInfo 
where CoupNo in('RS000024964','RS000024965','RS000024966','RS000024967'))

select * 
--delete
from Topway..tbTrainTicketInfo 
where CoupNo in('RS000024964','RS000024965','RS000024966','RS000024967')

select * 
--delete
from Topway..tbTrainUser where TrainTicketNo in(select ID from Topway..tbTrainTicketInfo 
where CoupNo in('RS000024968','RS000024969','RS000024970','RS000024971'))

select * 
--delete
from Topway..tbTrainTicketInfo 
where CoupNo in('RS000024968','RS000024969','RS000024970','RS000024971')

select Signer,* from ApproveBase..HR_AskForLeave_Signer 
--update ApproveBase..HR_AskForLeave_Signer  set Signer=0019
where DeptCode='市场部'


--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update  Topway..tbcash  set sales='黄怡丽',SpareTC='黄怡丽'
where coupno='AS001684416'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='018781_20190501'

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='携程官网分销联盟'
where CoupNo in('PTW083650','PTW083781')

select IsJoinRank,* from Topway..Emppwd 
--update Topway..Emppwd set IsJoinRank=1
where idnumber in ('0733')


--UC019836迪安汽车部件（天津）有限公司广州分公司
select convert(varchar(7),datetime,120) 月份,ride 航司,route 行程,sum(totprice)销量,COUNT(1)张数,sum(fuprice) 合计服务费,sum(tax) 合计税收
from Topway..tbcash 
where cmpcode='019836'
--and datetime>='2017-05-01'
--and datetime<'2018-09-01'
and inf=0
group by ride,route,convert(varchar(7),datetime,120)
order by 月份

select convert(varchar(7),datetime,120) 月份,ride 航司,route 行程,sum(totprice)销量,COUNT(1)张数,sum(fuprice) 合计服务费,sum(tax) 合计税收
from Topway..tbcash 
where cmpcode='019836'
--and datetime>='2017-05-01'
--and datetime<'2018-09-01'
and inf=1
group by ride,route,convert(varchar(7),datetime,120)
order by 月份