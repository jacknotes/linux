--UC019688�Ϻ�����������޹�˾
select datetime as ��Ʊ����,begdate as �������,coupno as ���۵���,pasname as �˿�����,route as ��·,ride+flightno as �����,
tcode+ticketno as Ʊ��,price as ���۵���,tax as ˰��,fuprice as �����,totprice as ���ۼ�,reti as ��Ʊ����
from Topway..tbcash 
where cmpcode='019688'
and (datetime>='2018-01-01' and datetime<'2019-01-01')
and inf=1
--and tickettype='����Ʊ'
--and route not in('����','����')
--and t_source not in('����','����')
order by datetime

--�ؿ���ӡ
select Pstatus,PrintDate,* from Topway..HM_tbReti_tbReFundPayMent 
--update Topway..HM_tbReti_tbReFundPayMent  set Pstatus=0,PrintDate='1900-01-01'
where Id='703679'

--ɾ����������
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money in('24168','50129','1195') and date='2019-03-07'

--�г̵�
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno='AS002266755'

--�޸�����Ԥ�㵥
select Sales,OperName,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Sales='�ɳ���',OperName='0670�ɳ���'
where TrvId='029647'

--UC020202ԣ����ʳƷ���Ϻ������޹�˾
--����
select datetime as ��Ʊ����,begdate as �������,coupno as ���۵���,pasname as �˿�����,route as ��·,ride+flightno as �����,
tcode+ticketno as Ʊ��,price as ���۵���,tax as ˰��,fuprice as �����,totprice as ���ۼ�,reti as ��Ʊ����
from Topway..tbcash 
where cmpcode='020202'
and (datetime>='2018-01-01' and datetime<'2019-01-01')
and inf=0
--and tickettype='����Ʊ'
--and route not in('����','����')
--and t_source not in('����','����')
order by datetime

--����
select datetime as ��Ʊ����,begdate as �������,coupno as ���۵���,pasname as �˿�����,route as ��·,ride+flightno as �����,
tcode+ticketno as Ʊ��,price as ���۵���,tax as ˰��,fuprice as �����,totprice as ���ۼ�,reti as ��Ʊ����
from Topway..tbcash 
where cmpcode='020202'
and (datetime>='2018-01-01' and datetime<'2019-01-01')
and inf=1
--and tickettype='����Ʊ'
--and route not in('����','����')
--and t_source not in('����','����')
order by datetime

--����
select datetime as ��Ʊ����,begdate as �������,coupno as ���۵���,pasname as �˿�����,route as ��·,ride+flightno as �����,
tcode+ticketno as Ʊ��,price as ���۵���,tax as ˰��,fuprice as �����,totprice as ���ۼ�,reti as ��Ʊ����
from Topway..tbcash 
where cmpcode='020202'
and (datetime>='2018-01-01' and datetime<'2019-01-01')
and inf=-1
--and tickettype='����Ʊ'
--and route not in('����','����')
--and t_source not in('����','����')
order by datetime

--���������µ����пͻ�
select  Cmpid UC,Name ��˾���� from homsomDB..Trv_UnitCompanies 
where Cmpid in (select Cmpid from Topway..HM_AgreementCompanyTC where TcName='������' and isDisplay=0)
and CooperativeStatus in ('1','2','3')


select top 10 * from homsomDB..Trv_UnitCompanies
select top 10 * from homsomDB..SSO_Users where Name='������'

select * from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_TrvUnitCompanies_TrvTCs t on t.TrvUnitCompanyID=u.ID
left join homsomDB..SSO_Users s on s.ID=t.TrvTCID

--017680 ����Ϊ�Ϻ�������Ϣ�Ƽ����޹�˾
--select * from Topway..tbCompanyM where cmpid='017680'
--select * from homsomDB..Trv_UnitCompanies where Cmpid='017680'
select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement set CompanyNameCN='�Ϻ�������Ϣ�Ƽ����޹�˾'
where BillNumber='017680_20190301' 


