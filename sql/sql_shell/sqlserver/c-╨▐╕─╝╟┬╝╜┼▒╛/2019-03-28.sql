--��˾������ë��
--IF OBJECT_ID('tempdb.dbo.#ZXL') IS NOT NULL DROP TABLE #ZXL
select ride ��˾����,SUM(totprice) ����,SUM(profit-Mcost) ë���� 
--INTO #ZXL
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and tickettype='����Ʊ'
and inf=0
group by ride
order by ���� desc


--IF OBJECT_ID('tempdb.dbo.#XL') IS NOT NULL DROP TABLE #XL
select ride ��˾����,SUM(totprice) ����,SUM(profit-Mcost) ë���� 
--INTO #XL
from Topway..tbcash c
left join ehomsom..tbInfCabincode t on t.code2=c.ride and c.nclass=t.cabin
and t.begdate<=c.begdate and t.enddate>=c.begdate
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and (nclass='Y' or cabintype like'%�����%' or cabintype like'%ͷ�Ȳ�%')
and tickettype='����Ʊ'
and inf=0
group by ride
order by ���� desc

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=1386,profit=51
where coupno='AS002353301'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=5366,profit=299
where coupno='AS002353452'


--UC018266�Ϻ���������ҽҩ���޹�˾ 1.ע���ո�Ϊ��2019.03.28 2.��λ���͸�Ϊ�����ε�λ�ͻ� 3.���㷽ʽ��Ϊ���ֽ�
--ע����,���οͻ�
select indate,CustomerType,* from Topway..tbCompanyM 
--update Topway..tbCompanyM  set indate='2019-03-28'
where cmpid='018266'

select RegisterMonth,Type,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set RegisterMonth='03 28 2019 12:00PM',Type='C'
where Cmpid='018266'

--���㷽ʽ
--select * from Topway..AccountStatement where CompanyCode='018266' order by BillNumber desc

select PendDate,Status,* from Topway..HM_CompanyAccountInfo 
--update Topway..HM_CompanyAccountInfo set PendDate='2019-02-28',Status='-1'
where CmpId='018266' and Id='4593'

select SEndDate,Status,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SEndDate='2019-02-28',Status=-1
where CmpId='018266' and Status=1

select SStartDate,Status,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SStartDate='2019-03-01',Status=1
where CmpId='018266' and Status=2

SELECT EndDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set EndDate='2019-02-28',Status=-1
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '018266') 
and Status=1

SELECT StartDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set StartDate='2019-03-01',Status=1
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '018266') 
and Status=2

--���˸�δ��
select haschecked,*  from Topway..FinanceERP_ClientBankRealIncomeDetail 
--update Topway..FinanceERP_ClientBankRealIncomeDetail set haschecked=0
where date='2019-03-26' and money='1500'

--�޸Ļ�����
select Name,AbbreviationName,EnglishName,* from homsomDB..Trv_Airport 
--update homsomDB..Trv_Airport set Name='��������(���ж�Ī��������)',EnglishName='Bologna Guglielmo Marconi Airport',AbbreviationName='��������'
where Code='BLQ'