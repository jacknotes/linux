select custid AS �ֻ�Ա���,mobilephone,* from tbCusholderM where cmpid ='019486'
select cmpname AS �ֹ�˾ȫ��,* from tbcompanyM where cmpid ='019486'
select SettleMentManner AS �ֽ��㷽ʽ,* from HM_SetCompanySettleMentManner where CmpId='019486' and Type=1 and Status=1
select OriginalBillNumber AS ���˵���,NewModifyBillNumber,cmpid,custid,datetime,* from tbHtlcoupYf where coupno in ('PTW066123')
select HSLastPaymentDate,* from AccountStatement where CompanyCode='019486' order by BillNumber desc

update tbHtlcoupYf set cmpid='019486',OriginalBillNumber='019486_20180801',NewModifyBillNumber='019486_20180801',custid='D465988',pform='�½�(��˳)'
,custinfo='�Ϻ�Ⱥ�׷������޹�˾|�Ž���|15900957290',spersoninfo='�Ž���|15900957290|�Ž���|15900957290' where coupno in ('PTW066123')

