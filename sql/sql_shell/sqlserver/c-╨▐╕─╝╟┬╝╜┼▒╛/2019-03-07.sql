--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='018734_20190101'

--UC020748三菱重工（常熟）机械有限公司
select * from topway..HM_SetCompanySettleMentManner where CmpId='020748'

select PstartDate,Status,* from Topway..HM_CompanyAccountInfo 
--update Topway..HM_CompanyAccountInfo set PstartDate='2019-03-16'
where CmpId='020748' and Id=6864

select * from Topway..AccountStatement where CompanyCode='020748'
SELECT * FROM homsomdb..Trv_UCSettleMentTypes WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '020748')

--支付方式改成微信支付

select cwstatus,owe,vpay,opername1,vpayinfo,oth2 from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set vpayinfo='微信'
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo='PTW077047')

select * from Topway..tbHtlcoupYf where CoupNo='PTW077047'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='020413_20190201'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=6721,profit=309
where coupno='AS002297052'
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=2320,profit=319
where coupno='AS002292685'

--修改退票状态
select status2,* from Topway..tbReti 
--update Topway..tbReti set status2=7
where reno in ('0347185','0344737','0344735')

--修改供应商来源
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETI'
where coupno='AS002287141'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HS易商大金D'
where coupno='AS002286644'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HS易商德凯达D'
where coupno='AS002293134'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno='AS002291562'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno='AS002283778'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno='AS002289461'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno='AS002292736'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno='AS002283912'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETI'
where coupno='AS002292031'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno='AS002291240'

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='员工垫付（王贞中行卡）'
where CoupNo='PTW077409'

--机票销售单改为未付
select bpay,status,opernum,oper2,oth2,totprice,dzhxDate,owe from Topway..tbcash
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
where coupno in ('AS002169758',
'AS002177580',
'AS002177995',
'AS002178148',
'AS002178210',
'AS002185299',
'AS002212785',
'AS002224440',
'AS002228582',
'AS002228592',
'AS002228592',
'AS002228588',
'AS002228588',
'AS002228596',
'AS002228585',
'AS002228599',
'AS002228591',
'AS002228591',
'AS002228595',
'AS002228595')

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update  Topway..tbcash set SpareTC='吴玲申'
where coupno in('AS001469828','AS001469830')