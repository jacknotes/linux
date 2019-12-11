select ID,* from homsomDB..Trv_Cities
select CityID,* from homsomDB..Trv_Airport

--修改供应商来源
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETI'
where coupno='AS002244697'

--修改结算差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=7002,profit=70
where coupno='AS002258255'

--单位类型、结算方式、账单开始日期、新增月、注册月

--修改注册月,单位类型
select indate,CustomerType,* from Topway..tbCompanyM 
--update Topway..tbCompanyM  set indate='2019-02-20 16:35:22.000'
where cmpid='019483'

select RegisterMonth,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies  set RegisterMonth='02 20 2019  4:35PM'
where Cmpid='019483'

--结算方式
--ERP
select PstartDate,PendDate,* from Topway..HM_CompanyAccountInfo 
--update Topway..HM_CompanyAccountInfo  set PstartDate='2019-02-01'
where CmpId='019483'
select SStartDate,Status,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SStartDate='2019-02-01',Status=1
where CmpId='019483' and Id in('19088','19089')

select SEndDate,Status,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SEndDate='2019-01-31',Status='-1'
where CmpId='019483' and Id in('16795','16794')

--TMS
SELECT StartDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes  set StartDate='2019-02-01',Status=1
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '019483') and ID in ('9A0A3139-855A-4DB9-BA52-A9FA0099E204','1A199C8B-D1F1-41F7-9DD6-A9FA0099E233')

SELECT EndDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set EndDate='2019-01-31',Status='-1'
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '019483') and ID in ('F10069EF-5829-4F0B-AB6C-A90700EE1075','1B07EF2D-A984-4CB7-B982-A90700EE10C0')

select * from Topway..AccountStatement where CompanyCode='019483' order by BillNumber desc

--修改额度
SELECT SX_BaseCreditLine,SX_TomporaryCreditLine, SX_TotalCreditLine
FROM Topway..AccountStatement
--update Topway..AccountStatement set SX_BaseCreditLine=30000,SX_TomporaryCreditLine=30000,SX_TotalCreditLine=30000
WHERE     (CompanyCode ='019483') AND (BillNumber = '019483_20190201')

--单位客户、个人客户信息
select custid,inf,* from Topway..tbcash 
--update Topway..tbcash  set custid='D636048'
where coupno in ('AS002256387','AS002252480','AS002248750','AS002248664','AS002243319','AS002242832')

select Customer,Person,Tel,sperson,CustId,* from Topway..tbFiveCoupInfo 
--update Topway..tbFiveCoupInfo set Customer='刘丽婷',Person='刘丽婷|13795393066',Tel='13795393066|',sperson='刘丽婷',CustId='D636048'
where CoupNo in('AS002256387','AS002252480','AS002248750','AS002248664','AS002243319','AS002242832')

select Recipients,Applicant,ApplicantMobile,CustId,* from homsomDB..Intl_BookingOrders 
--update homsomDB..Intl_BookingOrders  set Recipients='刘丽婷',Applicant='刘丽婷',ApplicantMobile='13795393066',CustId='D636048'
where SalesOrderNo in('AS002256387','AS002252480','AS002248750','AS002248664','AS002243319','AS002242832')


--更新联系人
select * from [homsomDB].[dbo].[Intl_Contacts]
--update  [homsomDB].[dbo].[Intl_Contacts] set Email='saliu@agility.com',Mobile='13795393066',Name='刘丽婷'
where BookingOrderId in 
(
select Id from homsomDB..Intl_BookingOrders 
where SalesOrderNo in('AS002256387','AS002252480','AS002248750','AS002248664','AS002243319','AS002242832')
)

--更新配送信息
select* from homsomDB..Intl_BookingOrders
--update homsomDB..Intl_BookingOrders set Tel='13795393066'
where SalesOrderNo in('AS002256387','AS002252480','AS002248750','AS002248664','AS002243319','AS002242832')


select * from homsomDB..Trv_Human where Mobile='13795393066'
select * from homsomDB..Trv_UnitPersons where ID='04F8896D-02A2-440C-A074-A9F90114CDFA'

--删除常旅客
--ERP常旅客
select * from Topway..tbCusholderM 
where cmpid='020614' 
and custid not in(select custid from Topway..tbCusholderM where cmpid='020614' and custname in('邹萍','高扬君'))

--TMS常旅客
select IsDisplay,* from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
--update homsomDB..Trv_Human  set IsDisplay=0
where b.companyid ='BF865F57-F52A-4C54-9473-A97E0095A04B'
and Name not  in('邹萍','高扬君')

select IsDisplay,* from  homsomDB..Trv_Human  --set IsDisplay=0
where companyid ='BF865F57-F52A-4C54-9473-A97E0095A04B'
and Name  in('邹萍','高扬君')


--------删除员工脚本
update homsomDB..Trv_Human set IsDisplay=0
where ID in (
select a.ID from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID=(select ID from homsomDB..Trv_UnitCompanies where Cmpid='000003')
and IsDisplay=1 and Name in ('','')
)

--退票付款单修改/作废
select Status,* from Topway..HM_tbReti_tbReFundPayMent 
--update Topway..HM_tbReti_tbReFundPayMent  set Status=4
where Id='703638'

--申请技术闭团
select Status,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Status=14
where  TrvId='29263'

--旅游结算信息
select beg_date,end_date,nights,price,sprice,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set end_date='2019-03-10',nights=1,price='124203',sprice='124203'
where CoupNo='PTW076457'

select Settleno,JsPrice,* from topway..tbTrvJS 
--update topway..tbTrvJS  set JsPrice='124203'
where TrvId='029360' and Id='144228'

--火车票销售单作废
delete from Topway..tbTrainTicketInfo where CoupNo='RS000019451'
delete from Topway..tbTrainUser where TrainTicketNo in(Select ID from Topway..tbTrainTicketInfo where CoupNo='RS000019451')

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='刘璐',SpareTC='刘璐'
where coupno='AS001430017'

