select custid,* from tbCusholderM where cmpid ='020597'

select custid,* from tbCusholder where mobilephone='18664212838' 

select SettleMentManner,* from HM_SetCompanySettleMentManner where CmpId='020597'

select OriginalBillNumber,ModifyBillNumber,cmpcode,custid,datetime,* from tbcash where coupno in ('AS001946280','AS001947777','AS001947779','AS001947781')

select HSLastPaymentDate,* from AccountStatement where CompanyCode='020597' order by BillNumber desc

select * from tbcash where coupno in ('AS001946280','AS001947777','AS001947779','AS001947781')


update tbcash set cmpcode='',OriginalBillNumber='',ModifyBillNumber='',custid='D198041',pform='œ÷Ω·' where coupno in ('AS002113941')


--ÕÀ∆±
select cmpcode,custid from tbReti where coupno in ('AS001946280','AS001947777','AS001947779','AS001947781')

update tbReti set cmpcode='020597',ModifyBillNumber='',custid='D000023' where coupno in ('AS001946280','AS001947777','AS001947779','AS001947781')

