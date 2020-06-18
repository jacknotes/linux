
select CustomerType,* from Topway..tbCompanyM  where cmpid='020554'
select * from Topway..HM_CompanyAccountInfo 
where CmpId='020554'


select Type,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set Type='a'
where CmpId='020554'

select Status,* from topway..HM_SetCompanySettleMentManner 
--update topway..HM_SetCompanySettleMentManner set SStartDate='2019-01-01',Status='1'
where CmpId='020554' and SStartDate='2019-02-01'

select Status,* from topway..HM_SetCompanySettleMentManner 
--update topway..HM_SetCompanySettleMentManner set SEndDate='2018-12-31',Status='-1'
where CmpId='020554' and SEndDate='2019-01-31'

select Status,* from homsomDB..Trv_UCSettleMentTypes 
--update homsomDB..Trv_UCSettleMentTypes set StartDate='2019-01-01',Status='1'
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '020554') and StartDate='2019-02-01'

select Status,* from homsomDB..Trv_UCSettleMentTypes 
--update homsomDB..Trv_UCSettleMentTypes set EndDate='2018-12-31',Status='-1'
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '020554') and EndDate='2019-01-31 23:59:59.000'