
--ɾ����������
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='���' and date='����ʱ��'

--�ĵ���ʱ��
select * from topway..FinanceERP_ClientBankRealIncomeDetail 
--update topway..FinanceERP_ClientBankRealIncomeDetail set date='�µĵ���ʱ��'
 where money='���' and date='����ʱ��'


--��Ʊ���۵���Ϊδ��
select bpay,status,opernum,oper2,oth2,totprice,dzhxDate,owe,vpay,vpayinf,dzhxDate
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1',vpay=0,vpayinf=''
from Topway..tbcash where coupno in ('AS002560329','AS002560365','AS002560425','AS002560371','AS002560554','AS002560343')

--�����տ��Ϊδ��
select bpay as ֧�����,cwstatus as �տ�״̬,opernum as ��������,opername1 as ������,oth2 as ��ע,totprice as ���ۼ�, dzHxDate as ����ʱ��,owe as Ƿ����
--update Topway..tbTrvKhSk set bpay=0,cwstatus=0,opernum=0,opername1='',owe=totprice,dzHxDate='1900-1-1'
from Topway..tbTrvKhSk 
where TrvId='Ԥ�㵥��' and Id='��ˮ��'


--���������Ϊδ��
select state 
--update topway..FinanceERP_ClientBankRealIncomeDetail set haschecked=0
from topway..FinanceERP_ClientBankRealIncomeDetail where money='���' and date='����ʱ��'

--����δ���
select state 
--update topway..FinanceERP_ClientBankRealIncomeDetail set state=5
from topway..FinanceERP_ClientBankRealIncomeDetail where money='���' and date='����ʱ��'


--ɾ�����������

select Payee,* 
--update topway..AccountStatementItem set Payee=''
from topway..AccountStatementItem where PKeyBill in 
(select PKey from topway..AccountStatement where CompanyCode='��λ���' and BillNumber='�˵���')
and ReceivedAmount='���'

--ɾ��������㵥��
delete FROM topway..tbSettlementAppInception WHERE id='43119'
delete FROM topway..tbcashInception WHERE settleno='43119'

 --�Ƶ����۵���Ϊδ��
 
 select cwstatus,owe,vpay,opername1,vpayinfo,oth2,totprice,operdate1,* from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set cwstatus=0,owe=totprice,opername1='',operdate1='1900-01-01'
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo='PTW075117')