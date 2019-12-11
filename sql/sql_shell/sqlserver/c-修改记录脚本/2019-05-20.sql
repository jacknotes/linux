--基础数据
select top 40 c.Code,c.Name,a.Name from homsomDB..Trv_Cities c
left join homsomDB..Trv_Airport a on a.CityID=c.ID
order by a.Name


select* from homsomDB..Trv_Airport where CityID in(select ID from homsomDB..Trv_Cities where ParentID='308554BB-A5BE-40E4-B308-C0697B4476A5')
select * from homsomDB..Trv_Airport where Code='SWA'
select * from homsomDB..Trv_Cities where ID='308554BB-A5BE-40E4-B308-C0697B4476A5'
select * from homsomDB..Trv_Cities where ProvinceID='FF674289-7400-4D30-A09F-7BDC4168CB59'
select * from homsomDB..Trv_Cities where ParentID='308554BB-A5BE-40E4-B308-C0697B4476A5'

--UC019830  和通汽车投资有限公司  客户表示需要拉取 4.8号之前导入的常旅客名单 
select h.Name,case  when LastName='' then '' when LastName<>'' then  LastName+'/'+FirstName+MiddleName else '' end as 英文姓名,Mobile,h.CreateDate from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='019830'
and IsDisplay=1
and h.CreateDate<'2019-04-08'
order by CreateDate

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber in('020455_20190401','020521_20190401','020769_20190401')

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='016262_20190301'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='杜鹏媛' ,SpareTC='杜鹏媛'
where coupno='AS001642025'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=2348,profit=19
where coupno='AS002469896'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=1384,profit=108
where coupno='AS002473365'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=1765,profit=45
where coupno='AS002475275'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=1954,profit=63
where coupno='AS002476478'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=2348,profit=112
where coupno='AS002477613'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=1954,profit=705
where coupno='AS002478882'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=6413,profit=942
where coupno='AS002479791'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=9120,profit=1306
where coupno='AS002482618'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=9120,profit=106
where coupno='AS002482622'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=2347,profit=262
where coupno='AS002483910'


--改成未审核
select state,* from Topway..FinanceERP_ClientBankRealIncomeDetail 
--update Topway..FinanceERP_ClientBankRealIncomeDetail  set state=5
where money='7635' and date='2019-05-10'

select Payee,* 
--update topway..AccountStatementItem set Payee=''
from topway..AccountStatementItem where PKeyBill in 
(select PKey from topway..AccountStatement where CompanyCode='016290' and BillNumber='016290_20190401')
and ReceivedAmount='7635'


--select amount,totprice,totsprice,tax,profit,* from Topway..tbcash where coupno='AS002482661'

select t_amount,totprice,totsprice,tottax,totprofit,* from Topway..tbFiveCoupInfo 
--update Topway..tbFiveCoupInfo set t_amount='300',totprice='300',totsprice='20',tottax=0,totprofit=280
where CoupNo='AS002482661'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=3928,profit=638
where coupno='AS002481920'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=18797,profit=1947
where coupno='AS002479959'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=3822,profit=211
where coupno='AS002481266'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=2148,profit=256
where coupno='AS002480168'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=3497,profit=470
where coupno='AS002481531'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=5557,profit='-1'
where coupno='AS002477998'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=30768,profit=4859
where coupno='AS002481848'

--UC020837 删除员工
select IsDisplay,* from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons
where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='020837'))
and IsDisplay=1
and id not in ('D7CF6623-36EB-4449-947A-AA5300B3C37C','A1D88075-0792-4C62-9935-0CD089F41EF6','5DD5A941-2B0F-453A-8958-AA5300B3241C','0066D387-7CAD-46EC-BEAA-AA5300B2BA26')
and Name  not in ('徐璐')

select * from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=1
where ID in(Select ID from homsomDB..Trv_UnitPersons
where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='020837'))
and Name  in ('徐璐')

select EmployeeStatus,* from Topway..tbCusholderM
--update Topway..tbCusholderM set EmployeeStatus=0
where cmpid='020837'

--单位客户授信额度调整
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SX_TotalCreditLine=230000
where BillNumber='020476_20190501'

--会务预算单信息
select ConventionCpName,StartDate,EndDate,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set ConventionCpName='中德安联日本东京3日纯会务',StartDate='2019-06-15',EndDate='2019-06-17'
where ConventionId='1412'

--机票业务顾问信息
select SpareTC,* from Topway..tbcash 
--update  Topway..tbcash set SpareTC='刘璐'
where coupno in('AS002482836','AS002482847')

--旅游收款单信息
select Skstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Skstatus=2
where TrvId='29937' and Id in('228054','227897')

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='019658_20190301'