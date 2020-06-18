
--删除到账认领
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='金额' and date='到账时间'

--改到账时间
select * from topway..FinanceERP_ClientBankRealIncomeDetail 
--update topway..FinanceERP_ClientBankRealIncomeDetail set date='新的到账时间'
 where money='金额' and date='到账时间'


--机票销售单改为未付
select bpay,status,opernum,oper2,oth2,totprice,dzhxDate,owe,vpay,vpayinf,dzhxDate
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1',vpay=0,vpayinf=''
from Topway..tbcash where coupno in ('AS002560329','AS002560365','AS002560425','AS002560371','AS002560554','AS002560343')

--旅游收款单改为未付
select bpay as 支付金额,cwstatus as 收款状态,opernum as 核销次数,opername1 as 核销人,oth2 as 备注,totprice as 销售价, dzHxDate as 核销时间,owe as 欠款金额
--update Topway..tbTrvKhSk set bpay=0,cwstatus=0,opernum=0,opername1='',owe=totprice,dzHxDate='1900-1-1'
from Topway..tbTrvKhSk 
where TrvId='预算单号' and Id='流水号'


--到账认领改为未阅
select state 
--update topway..FinanceERP_ClientBankRealIncomeDetail set haschecked=0
from topway..FinanceERP_ClientBankRealIncomeDetail where money='金额' and date='到账时间'

--到账未审核
select state 
--update topway..FinanceERP_ClientBankRealIncomeDetail set state=5
from topway..FinanceERP_ClientBankRealIncomeDetail where money='金额' and date='到账时间'


--删除到账审核人

select Payee,* 
--update topway..AccountStatementItem set Payee=''
from topway..AccountStatementItem where PKeyBill in 
(select PKey from topway..AccountStatement where CompanyCode='单位编号' and BillNumber='账单号')
and ReceivedAmount='金额'

--删除特殊结算单号
delete FROM topway..tbSettlementAppInception WHERE id='43119'
delete FROM topway..tbcashInception WHERE settleno='43119'

 --酒店销售单改为未付
 
 select cwstatus,owe,vpay,opername1,vpayinfo,oth2,totprice,operdate1,* from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set cwstatus=0,owe=totprice,opername1='',operdate1='1900-01-01'
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo='PTW075117')