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