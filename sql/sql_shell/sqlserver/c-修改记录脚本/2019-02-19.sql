--�޸Ĺ�Ӧ����Դ
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='�渶ʩ����D'
where coupno='AS002251010'

--UC017275 2018��ĳ�Ʊ����
--����
select datetime as ��Ʊ����,begdate as �������,coupno as ���۵���,pasname as �˿�����,route as ��·,ride+flightno as �����,
tcode+ticketno as Ʊ��,price as ���۵���,tax as ˰��,xfprice as ǰ��,totprice as ���ۼ�,Department as ����,CostCenter as �ɱ�����,
nclass as ��λ,ProjectNo as ��Ŀ���
from Topway..tbcash 
where datetime>='2018-01-01' and datetime<'2019-01-01'
and reti=''
and cmpcode='017275'
and inf=0
and tickettype='����Ʊ'
order by datetime

--����
select datetime as ��Ʊ����,begdate as �������,coupno as ���۵���,pasname as �˿�����,route as ��·,ride+flightno as �����,
tcode+ticketno as Ʊ��,price as ���۵���,tax as ˰��,xfprice as ǰ��,totprice as ���ۼ�,Department as ����,CostCenter as �ɱ�����,
nclass as ��λ,ProjectNo as ��Ŀ���
from Topway..tbcash 
where datetime>='2018-01-01' and datetime<'2019-01-01'
and reti=''
and cmpcode='017275'
and inf=1
and tickettype='����Ʊ'
order by datetime

--�˸�
select datetime as ��Ʊ����,begdate as �������,coupno as ���۵���,pasname as �˿�����,route as ��·,ride+flightno as �����,
tcode+ticketno as Ʊ��,price as ���۵���,tax as ˰��,xfprice as ǰ��,totprice as ���ۼ�,Department as ����,CostCenter as �ɱ�����,
nclass as ��λ,ProjectNo as ��Ŀ���
from Topway..tbcash 
where datetime>='2018-01-01' and datetime<'2019-01-01'
and reti=''
and cmpcode='017275'
and inf=1
and tickettype='����Ʊ'
and ( t_source like ('%����%') or route like ('%����%') or t_source like ('%��Ʊ%') or route like ('%��Ʊ%'))
order by datetime

--�������Ϣ
select sprice1,xj1,tax,totprice,status,amount,owe,totprice,* from Topway..tbcash 
--update Topway..tbcash set amount=totprice,owe=totprice
where coupno='AS002252288'

--���������������Ʊ�����޹��ڻ�Ʊ������·���ں�����
select u.Cmpid as UC ,u.Name as ��λ���� from homsomDB..Trv_UnitCompanies u
left join Topway..tbCompanyM t on t.cmpid=u.Cmpid
where t.hztype  not in (0,4)
and u.ID not in (SELECT UnitCompanyID FROM homsomDB..Trv_FlightAdvancedPolicies WHERE   Name='���ڻ�Ʊ������·')
and u.IsSepPrice=1

SELECT  UnitCompanyID FROM homsomDB..Trv_FlightNormalPolicies 
select Name,UnitCompanyID,* from homsomdb..Trv_FlightTripartitePolicies

--��λ����֧��Ȩ��
select UPPayAuthId,*from homsomDB..Trv_UnitPersons
  --update homsomDB..Trv_UnitPersons set UPPayAuthId='24DF7569-2148-4D69-806F-751B3F777A2F'
  where CompanyID='BB6A117C-8F55-4992-AAD8-F279E6762775' 
  
--��Ʊ���۵�����
delete  from Topway..tbTrainTicketInfo where CoupNo in('RS000019522','RS000019518')
delete from Topway..tbTrainUser where TrainTicketNo in(select ID from Topway..tbTrainTicketInfo where CoupNo in('RS000019522','RS000019518'))

--�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='�����е������οƼ��ɷ����޹�˾'
where CoupNo='PTW076126'

select Signer,* from ApproveBase..App_DefineBase 
--update ApproveBase..App_DefineBase set Signer=0601
where Signer=0671

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020181_20190101' 

--�޸���Ʊ���ʱ��
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti set ExamineDate='1900-01-01'
where reno='0427503'

