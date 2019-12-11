--结算账期表
select * from Topway..HM_CompanyAccountInfo 
--update Topway..HM_CompanyAccountInfo set PendDate='2018-12-31'
where CmpId='017275' and PendDate='2019-01-31 23:59:59.000'

select * from Topway..HM_CompanyAccountInfo 
--update Topway..HM_CompanyAccountInfo set PstartDate='2019-01-01'
where CmpId='017275' and PstartDate='2019-02-01 00:00:00.000'

--ERP结算方式
select status,senddate,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner  set status='-1',senddate='2018-11-30 00:00:00.000'
where Cmpid='017275' and SEndDate='2018-12-31 00:00:00.000' 

select status,sstartdate,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner  set status='1',sstartdate='2018-12-01 00:00:00.000'
where Cmpid='017275' and SStartDate='2019-02-01 00:00:00.000' 
--TMS结算方式
select enddate,status,* from homsomDB..Trv_UCSettleMentTypes 
--update homsomDB..Trv_UCSettleMentTypes set enddate='2018-11-30 23:59:59.000',status='-1'
where UnitCompanyID in
(select id from homsomDB..Trv_UnitCompanies where Cmpid='017275') and EndDate='2018-12-31 23:59:59.000'

select startdate,status,* from homsomDB..Trv_UCSettleMentTypes 
--update homsomDB..Trv_UCSettleMentTypes set startdate='2018-12-01 00:00:00.000',status='1'
where UnitCompanyID in
(select id from homsomDB..Trv_UnitCompanies where Cmpid='017275') and StartDate='2019-01-01 00:00:00.000'