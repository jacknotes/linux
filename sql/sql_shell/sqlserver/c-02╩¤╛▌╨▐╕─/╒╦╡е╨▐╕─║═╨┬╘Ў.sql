--修改注册月，结算方式
select indate,CustomerType,sform,* from Topway..tbCompanyM 
--update Topway..tbCompanyM  set indate='2019-02-27',sform='月结(中行)'
where cmpid='017661'
select RegisterMonth,Type,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set RegisterMonth='02  27 2019 12:00AM',Type='A'
where Cmpid='017661'

--新增2月账期
select PstartDate,* from topway..HM_CompanyAccountInfo 
--update topway..HM_CompanyAccountInfo set PstartDate='2019-02-01'
where CmpId='017661' and Id='6848'

select PendDate,* from topway..HM_CompanyAccountInfo 
--update topway..HM_CompanyAccountInfo set PendDate='2019-01-31 23:59:59.000'
where CmpId='017661' and Id='5323'

--结算方式
--ERP
select SEndDate,Status,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SEndDate='2019-01-31',Status=-1
where CmpId='017661' and Id in('9970','9969')
select SStartDate,Status,* from Topway..HM_SetCompanySettleMentManner
--update  Topway..HM_SetCompanySettleMentManner set SStartDate='2019-02-01',Status=1
where CmpId='017661' and Id in('19111','19110')
--TMS

SELECT EndDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set EndDate='2019-01-31 23:59:59.000',Status=-1
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '017661') 
and ID in('97531C7A-4E3D-4904-A492-A4410103FB6C','A7235427-FE0A-48E1-A110-A4410103FB89')

SELECT StartDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes  set StartDate='2019-02-01',Status=1
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '017661')
and ID in ('B6CCB797-C1E6-4552-9CD9-AA0100C4A7A5','983444B3-45B3-436A-963B-AA0100C4A7CB')

--额度
select SX_BaseCreditLine,SX_TomporaryCreditLine,SX_TotalCreditLine from Topway..AccountStatement 
--update Topway..AccountStatement set SX_BaseCreditLine=30000,SX_TomporaryCreditLine=30000,SX_TotalCreditLine=30000
where BillNumber='017661_20190201'