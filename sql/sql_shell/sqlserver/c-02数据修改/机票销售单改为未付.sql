/*
ע��
owe��Ϊ(cash, cpay, bpay, tpay, vpay, epay, bank������ֵ��ֵ���Ӹ��ʽ��������ԭֵ��Ϊ0)
*/
--�˵��еĳ�Ʊ����
select cash,cpay,bpay,tpay,vpay,epay,bank,owe,status,opernum,oper2,dzhxDate from tbcash where cmpcode='019498' and OriginalBillNumber='019498_20180126'
--��һ��
update tbcash set owe=bpay,status=0,opernum=0,oper2='',dzhxDate='1900-1-1' where cmpcode='019498' and OriginalBillNumber='019498_20180126'
--�ڶ���
update tbcash set bpay=0 where cmpcode='019498' and OriginalBillNumber='019498_20180126'

--�˵��е���Ʊ����
select status2 from tbReti where cmpcode='019498' and OriginalBillNumber='019498_20180126'
--������
update tbReti set status2=8 where cmpcode='019498' and OriginalBillNumber='019498_20180126'

--�˵��еĺ���״̬
select SalesOrderState from AccountStatement where CompanyCode='019498' and BillNumber='019498_20180126'
--���Ĳ�
update AccountStatement set SalesOrderState=0 where CompanyCode='019498' and BillNumber='019498_20180126'

--�Ƶ�
select cash,cpay,bpay,tpay,vpay,owe,cwstatus,opernum,opername1,* from tbhtlyfchargeoff where coupid in (select id from tbHtlcoupYf where cmpid='019498' and OriginalBillNumber='019498_20180126')

update tbhtlyfchargeoff set owe=bpay,cwstatus=0,opernum=0,opername1='' where coupid in (select id from tbHtlcoupYf where cmpid='019498' and OriginalBillNumber='019498_20180126')

update tbhtlyfchargeoff set bpay=0 where coupid in (select id from tbHtlcoupYf where cmpid='019498' and OriginalBillNumber='019498_20180126')

select dzhxDate,* from tbHtlcoupYf where cmpid='019498' and OriginalBillNumber='019498_20180126'

update tbHtlcoupYf set dzhxDate='1900-1-1' where cmpid='019498' and OriginalBillNumber='019498_20180126'
