/*
注：
owe改为(cash, cpay, bpay, tpay, vpay, epay, bank中有数值的值，视付款方式而决定，原值变为0)
*/
--账单中的出票数据
select cash,cpay,bpay,tpay,vpay,epay,bank,owe,status,opernum,oper2,dzhxDate from tbcash where cmpcode='019498' and OriginalBillNumber='019498_20180126'
--第一步
update tbcash set owe=bpay,status=0,opernum=0,oper2='',dzhxDate='1900-1-1' where cmpcode='019498' and OriginalBillNumber='019498_20180126'
--第二步
update tbcash set bpay=0 where cmpcode='019498' and OriginalBillNumber='019498_20180126'

--账单中的退票数据
select status2 from tbReti where cmpcode='019498' and OriginalBillNumber='019498_20180126'
--第三步
update tbReti set status2=8 where cmpcode='019498' and OriginalBillNumber='019498_20180126'

--账单中的核销状态
select SalesOrderState from AccountStatement where CompanyCode='019498' and BillNumber='019498_20180126'
--第四步
update AccountStatement set SalesOrderState=0 where CompanyCode='019498' and BillNumber='019498_20180126'

--酒店
select cash,cpay,bpay,tpay,vpay,owe,cwstatus,opernum,opername1,* from tbhtlyfchargeoff where coupid in (select id from tbHtlcoupYf where cmpid='019498' and OriginalBillNumber='019498_20180126')

update tbhtlyfchargeoff set owe=bpay,cwstatus=0,opernum=0,opername1='' where coupid in (select id from tbHtlcoupYf where cmpid='019498' and OriginalBillNumber='019498_20180126')

update tbhtlyfchargeoff set bpay=0 where coupid in (select id from tbHtlcoupYf where cmpid='019498' and OriginalBillNumber='019498_20180126')

select dzhxDate,* from tbHtlcoupYf where cmpid='019498' and OriginalBillNumber='019498_20180126'

update tbHtlcoupYf set dzhxDate='1900-1-1' where cmpid='019498' and OriginalBillNumber='019498_20180126'
