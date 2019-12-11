select custid AS 现会员编号,mobilephone,* from tbCusholderM where cmpid ='019486'
select cmpname AS 现公司全称,* from tbcompanyM where cmpid ='019486'
select SettleMentManner AS 现结算方式,* from HM_SetCompanySettleMentManner where CmpId='019486' and Type=1 and Status=1
select OriginalBillNumber AS 现账单号,NewModifyBillNumber,cmpid,custid,datetime,* from tbHtlcoupYf where coupno in ('PTW066123')
select HSLastPaymentDate,* from AccountStatement where CompanyCode='019486' order by BillNumber desc

update tbHtlcoupYf set cmpid='019486',OriginalBillNumber='019486_20180801',NewModifyBillNumber='019486_20180801',custid='D465988',pform='月结(恒顺)'
,custinfo='上海群易服饰有限公司|张洁琼|15900957290',spersoninfo='张洁琼|15900957290|张洁琼|15900957290' where coupno in ('PTW066123')

