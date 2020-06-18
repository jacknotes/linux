--重开打印
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='29707'

--单位客户授信额度调整
select SX_BaseCreditLine,SX_TomporaryCreditLine,SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SX_TomporaryCreditLine=10000
where BillNumber='020547_20190301'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='019695_20190201'

select top 10 trvYsId,ConventionYsId,* from Topway..tbcash  where trvYsId!=0

--重开打印
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='29174'

--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno='AS002315368'

select Name,AbbreviationName,* from homsomDB..Trv_Airport  
--update homsomDB..Trv_Airport set Name='班加罗尔机场',AbbreviationName='班加罗尔'
where Code='blr'

select * from homsomDB..Trv_Cities 
--update homsomDB..Trv_Cities set Name='班加罗尔'
where ID='36FC90B2-E920-A841-543E-88CC383B9152'

select * from homsomDB..Trv_Airport  where Code='hkg'
select * from homsomDB..Trv_Cities where ID='36FC90B2-E920-A841-543E-88CC383B9152'

--重开打印
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='29712'

select totprice,* from Topway..tbFiveCoupInfo 
--update Topway..tbFiveCoupInfo set totprice='20167'
where CoupNo='AS002321138'

--单位报销凭证和特殊票价
select distinct u.Cmpid,
(case when u.CertificateI=0 then '无' when u.CertificateI=1 then '行程单' when u.CertificateI=2 then '发票' else '' End) as 国际报销凭证,
(case when u.CertificateD=0 then '无' when u.CertificateD=1 then '行程单' when u.CertificateD=2 then '发票' else '' End) as 国内报销凭证,
(case when u.IsSepPrice=0 then '不可申请' when u.IsSepPrice=1 then '可以申请' else '' end) 是否有开通特殊票价
from Topway..tbcash  c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where u.Cmpid in('016132',
'016886',
'017056',
'017649',
'017682',
'018156',
'018161',
'018232',
'018281',
'018308',
'018343',
'018369',
'018395',
'018420',
'018428',
'018448',
'018451',
'018522',
'018626',
'018781',
'018793',
'018892',
'018940',
'019049',
'019058',
'019106',
'019231',
'019273',
'019331',
'019332',
'019360',
'019486',
'019506',
'019591',
'019592',
'019792',
'020065',
'020094')

select distinct CustomerType from  Topway..tbCompanyM 
select top 10 profit,Mcost,coupno,* from Topway..tbcash where Mcost>0 and datetime>'2018-01-01'
