--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='020237_20190401'

select tax,stax,totsprice,profit,owe,* from Topway..tbcash where coupno='AS002508687'

--����֧����ʽ���Ը����渶��

select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set TCPayNo=PayNo,PayNo='',AdvanceStatus=PayStatus,PayStatus=0,TcPayWay=CustomerPayWay,CustomerPayWay=0,TcPayDate=CustomerPayDate,dzhxDate=CustomerPayDate,CustomerPayDate='1900-01-01'
where coupno in ('AS002508645')

select PayStatus,AdvanceStatus,PayNo,TCPayNo,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET AdvanceStatus=PayStatus,TCPayNo=PayNo,TcPayWay=CustomerPayWay,TcPayDate=CustomerPayDate,PayStatus=0,PayNo='',CustomerPayWay=0,CustomerPayDate=null
WHERE CoupNo in ('AS002508645')

--��λ�ͻ����Ŷ�ȵ���
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement set SX_TotalCreditLine=150000
where BillNumber='020594_20190501'


select PayNo,AdvanceStatus,* from Topway..tbcash where coupno='AS002500549'
--����֧����ʽ���Ը����渶��

select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set TCPayNo=PayNo,PayNo='',AdvanceStatus=PayStatus,PayStatus=0,TcPayWay=CustomerPayWay,CustomerPayWay=0,TcPayDate=CustomerPayDate,CustomerPayDate='1900-01-01'
where coupno in ('AS002500549')

select PayStatus,AdvanceStatus,PayNo,TCPayNo,PayNo,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,PayStatus,* from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET AdvanceStatus=PayStatus,TCPayNo=PayNo,TcPayWay=CustomerPayWay,TcPayDate=CustomerPayDate,PayStatus=0,PayNo='',CustomerPayWay=0,CustomerPayDate=null
WHERE CoupNo in ('AS002500549')


--����״̬
select dzhxDate,status,owe,vpay,amount,* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='1900-01-01',status=0,owe=amount,vpay=0
where coupno in ('AS002508645')

--�����Ը��ĵ渶
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set TCPayNo=PayNo,PayNo='',AdvanceStatus=PayStatus,PayStatus=0,TcPayWay=CustomerPayWay,CustomerPayWay=0,TcPayDate=CustomerPayDate,CustomerPayDate='1900-01-01'
where coupno in ('���۵���')

select PayStatus,AdvanceStatus,PayNo,TCPayNo,PayNo,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,PayStatus,* from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET AdvanceStatus=PayStatus,TCPayNo=PayNo,TcPayWay=CustomerPayWay,TcPayDate=CustomerPayDate,PayStatus=0,PayNo='',CustomerPayWay=0,CustomerPayDate=null
WHERE CoupNo in ('���۵���')

--����ʱ�����
select dzhxDate,status,owe,vpay,amount,oper2* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='1900-01-01'
where coupno in ('AS002500549','AS002500550')

--��Ʊ���۵���Ϊδ��
select opernum,oper2,oth2 from Topway..tbcash
--update Topway..tbcash set opernum=0,oper2='',dzhxDate='1900-1-1'
 where coupno in ('AS002500549','AS002500550')

--�����տ��Ϣ
select Pstatus,PrDate,Price+InvoiceTax,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set Pstatus=1,PrDate='2019-05-31'
where ConventionId='1168' and Id='2360'



--�г̵�
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno='AS002476157'


--UC017505ɾ����λԱ��
select * from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (Select ID from homsomDB..Trv_UnitPersons
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017505'))
and IsDisplay=1
and Name not in ('���','����','�ߵ�','������','�º���','�ܺ�')

--UC017505ɾ����λԱ��
select EmployeeStatus,* from Topway..tbCusholderM 
--update Topway..tbCusholderM  set EmployeeStatus=0
where cmpid='017505' 
and custname not in ('���','����','�ߵ�','������','�º���','�ܺ�')

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020272_20190401'

--UC019837 2017.5-2018.8���ڵϰ��������չ�˾���ʼ����ڳ�Ʊ����
select ride ��˾,route �г�,sum(totprice)����,COUNT(1)����,sum(fuprice) �ϼƷ����,sum(tax) �ϼ�˰��
from Topway..tbcash 
where cmpcode='019837'
and datetime>='2017-05-01'
and datetime<'2018-09-01'
and inf=0
group by ride,route
order by ��˾ desc

select ride ��˾,route �г�,sum(totprice)����,COUNT(1)����,sum(fuprice) �ϼƷ����,sum(tax) �ϼ�˰��
from Topway..tbcash 
where cmpcode='019837'
and datetime>='2017-05-01'
and datetime<'2018-09-01'
and inf=1
group by ride,route
order by ��˾ desc

--ɾ����������
select * 
--delete
from Topway..FinanceERP_ClientBankRealIncomeDetail where money='12984' and date='2019-05-29'


--ɾ����������
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='78790' and date='2019-05-30' and state=0

delete from Topway..FinanceERP_ClientBankRealIncomeDetail where money='7710' and date='2019-05-30' and state=0
delete from Topway..FinanceERP_ClientBankRealIncomeDetail where money='72475' and date='2019-05-30' and state=0
delete from Topway..FinanceERP_ClientBankRealIncomeDetail where money='78790' and date='2019-05-30' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='18995' and date='2019-05-30' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='46087' and date='2019-05-30' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='110306' and date='2019-05-30' and id='9EEEB39D-83EC-4C30-9ECF-7C4464B53463'
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='4645' and date='2019-05-30' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='30' and date='2019-05-30' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='2085' and date='2019-05-30' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='5779' and date='2019-05-30' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='27662' and date='2019-05-30' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='174197' and date='2019-05-30' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='2710' and date='2019-05-30' and id='6713FF15-DC38-409A-A541-56D71E34E177'
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='24526' and date='2019-05-30' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='23060' and date='2019-05-30' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='78335' and date='2019-05-30' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='18086' and date='2019-05-31' and state=0
select *from Topway..FinanceERP_ClientBankRealIncomeDetail where money='47171.5' and date='2019-05-31' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='102543' and date='2019-05-31' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='27268' and date='2019-05-31' and id='E1BFF163-0BF3-425A-AC36-48891464EBB1'
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='2994' and date='2019-05-31' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='106089' and date='2019-05-31' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='32113' and date='2019-05-31' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='7334' and date='2019-05-31' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='40000' and date='2019-05-31' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='746' and date='2019-05-31' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='157227' and date='2019-05-31' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='1330' and date='2019-05-31' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='1430' and date='2019-05-31' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='33660' and date='2019-05-31' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='63959' and date='2019-05-31' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='6880' and date='2019-05-31' and state=0
select * from Topway..FinanceERP_ClientBankRealIncomeDetail where money='22547' and date='2019-05-31' and state=0

