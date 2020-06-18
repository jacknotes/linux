--会务收款单信息
select Pstatus,PrDate,totprice,owe,totprice+InvoiceTax,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk set Pstatus=0,PrDate='1900-01-01'
where ConventionId='1403' and Id='2651'

--重开打印权限
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
 where TrvId='029736'
 
 select rtprice,* from Topway..tbReti where reno='0429727'
 select reti,* from Topway..tbcash where coupno='AS002303250'
 
 --单位客户授信额度调整
 select SX_BaseCreditLine,SX_TomporaryCreditLine,SX_TotalCreditLine,* from Topway..AccountStatement 
 --update Topway..AccountStatement set SX_TotalCreditLine=260000
 where BillNumber='020585_20190301'
 
 --旅游预算单信息单位改个人
 select Cmpid,Custinfo,CustomerType,* from Topway..tbTravelBudget 
 --update  Topway..tbTravelBudget  set Cmpid='',Custinfo='15921532592@秦赟@@@秦赟@15921532592@D176763',CustomerType='个人客户'
 where TrvId='029736'
 select * from Topway..tbTrvKhSk where TrvId='029736'
 select * from Topway..tbTrvJS where TrvId='029736'
 
 SELECT * FROM homsomDB..Trv_Cities
 
 --账单撤销
 select SubmitState,* from Topway..AccountStatement  
 --update  Topway..AccountStatement set SubmitState=1
 where BillNumber='019974_20190201'
 
 --修改销售价信息
 select price,totprice,owe,amount,* from Topway..tbcash 
 --update Topway..tbcash set price=0,totprice=0,owe=0,amount=0
 where coupno in ('AS002254813','AS002254814')
 
 --账单撤销
 select SubmitState,* from Topway..AccountStatement 
 --update Topway..AccountStatement set SubmitState=1
 where BillNumber='000126_20190201'
 
 --机票业务顾问信息
 select sales,SpareTC,* from Topway..tbcash  
 --update Topway..tbcash set sales='何洁',SpareTC='何洁'
 where coupno in ('AS002329545','AS002329552','AS002331249')