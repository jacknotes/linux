
--1 ��˾��Ʊ����   ���	��Ʊ����	��λ���	���۵���	��Ӧ����Դ	��˾2����	·��	�������	��λ	Ʊ��	�ļ��ۺϼ�	��Ʊ����	���ù���
DECLARE @startdatetime VARCHAR(10)='2019-07-01'
DECLARE @enddatetime VARCHAR(10)='2019-07-30'
DECLARE @startbegdate VARCHAR(10)='2019-01-01'
DECLARE @endbegdate VARCHAR(10)='2019-10-01'
DECLARE @cmpid VARCHAR(20) ='020459'
DECLARE @inf VARCHAR(10)=0 --����/����
DECLARE @tickettype VARCHAR(20)='����' --����Ʊ/����/����/��������

if OBJECT_ID('tempdb..#ride') is not null drop table #ride
create table #ride( 
[datetime] VARCHAR(10),
cmpid VARCHAR(20) ,
coupno VARCHAR(50),
t_source VARCHAR(50),
ride  VARCHAR(10),
[route] VARCHAR(1000),
begdate  VARCHAR(20),
nclass VARCHAR(10),
ticketno  VARCHAR(50),
totsprice decimal(18,3),
reti  VARCHAR(20),
sales VARCHAR(20),)
insert into #ride(datetime,cmpid,coupno,t_source,ride,[route],begdate,nclass,ticketno,totsprice,reti,sales)
select convert(varchar(10),datetime,120) ��Ʊ����,cmpcode ��λ���,coupno ���۵���,t_source ��Ӧ����Դ,ride ��˾����,route ·��,convert(varchar(20),begdate,120) �������,nclass ��λ,
tcode+ticketno Ʊ��,sprice1+sprice2+sprice3+sprice4 �ļ��ۺϼ�,reti ��Ʊ����,sales ���ù���
from Topway..tbcash 
where [datetime]>=@startdatetime and [datetime]<=@enddatetime
and cmpcode=@cmpid
and begdate>=@startbegdate and begdate<=@endbegdate
and inf=@inf
and convert(varchar(4),tickettype) in (@tickettype) 

select * from #ride



--2 ��Ʊ����  ���	��Ӧ����Դ	��Ʊ����	��Ʊ�������	��Ʊ״̬	��Ʊ��	HSӦ�ս��	��Ʊԭ��	����״̬	ҵ�����	�����

DECLARE @startedatetime VARCHAR(10)
DECLARE @endedatetime VARCHAR(10) 
DECLARE @startExamineDate VARCHAR(10) 
DECLARE @endExamineDate VARCHAR(10) 
DECLARE @status VARCHAR(10)
DECLARE @inf VARCHAR(10)
DECLARE @t_source VARCHAR(50)
DECLARE @inf2 VARCHAR(20)
DECLARE @sales VARCHAR(20)
if OBJECT_ID('tempdb..#reti') is not null drop table #reti
create table #reti (t_source,reno,)

 



--��λ�ͻ����Ŷ�ȵ���
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SX_TotalCreditLine='260000'
where BillNumber='020852_20190701'

--�޸ĵ�������
select date,* from Topway..FinanceERP_ClientBankRealIncomeDetail
--update Topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-07-19'
where date='2019-07-22'and money='12234'

select date,* from Topway..FinanceERP_ClientBankRealIncomeDetail
--update Topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-07-19'
where date='2019-07-22'and money='370.66'

select date,* from Topway..FinanceERP_ClientBankRealIncomeDetail
--update Topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-07-19'
where date='2019-07-22'and money='1511.50'

select date,* from Topway..FinanceERP_ClientBankRealIncomeDetail
--update Topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-07-19'
where date='2019-07-22'and money='675'

--�޸������տ
select vpayinfo,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set vpayinfo='֧����'
where TrvId='30175' and Id='228802'

--��Ʊ
select t1.RecordNumber,t5.Name from homsomDB..Trv_DomesticTicketRecord t1
left join homsomDB..Trv_PnrInfos t2 on t2.ID=t1.PnrInfoID
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t2.ItktBookingID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='����'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.RecordNumber in 
('AS002575325',
'AS002576721',
'AS002576723',
'AS002580792',
'AS002582470',
'AS002587167',
'AS002590308',
'AS002591145',
'AS002592846',
'AS002595281',
'AS002597240',
'AS002597240',
'AS002597240',
'AS002600145',
'AS002601156',
'AS002601158',
'AS002601162',
'AS002601186',
'AS002601188',
'AS002601200',
'AS002602295',
'AS002602316',
'AS002602486',
'AS002605415',
'AS002605415',
'AS002605415',
'AS002606791',
'AS002606822',
'AS002606826',
'AS002608420',
'AS002608886',
'AS002608925',
'AS002610053',
'AS002613598',
'AS002613611',
'AS002613649',
'AS002613794',
'AS002616997',
'AS002621227',
'AS002623220',
'AS002625268',
'AS002626367',
'AS002626812',
'AS002627050',
'AS002627179',
'AS002627179',
'AS002628567',
'AS002630093',
'AS002631771',
'AS002631833',
'AS002637662',
'AS002639623',
'AS002640955',
'AS002644632',
'AS002645098',
'AS002646936',
'AS002647714',
'AS002647716',
'AS002651086',
'AS002651257',
'AS002471009')
and NodeType=110 and NodeID=111

--һ�� NodeType=110 and NodeID=110
--���� NodeType=110 and NodeID=111

--�Ƶ�
select t1.CoupNo,t5.Name from HotelOrderDB..HTL_Orders t1
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t1.OrderID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='����'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.CoupNo in 
('PTW085718')
and NodeType=110 and NodeID=110

/*
UC020410�����ҵ���޹�˾  ������Ա
��ƱԤ��Ȩ�ް��Ϊ��ȫ����λ
����Ԥ������Ҳ��Ϊ������Ԥ��
*/
select * from homsomDB..Trv_UPRanks where CompanyID='9C4B0B2E-9CCA-4F94-8929-A8EE00BB3B65'
select top 100 BookingType,* from homsomDB..Trv_BookingCollections where BookingType=3
select top 100 * from homsomDB..Trv_UPSettings where BookingCollectionID in(select ID from homsomDB..Trv_BookingCollections where BookingType=3)
select top 100 * from homsomDB..Trv_UPCollections_UnitPersons

--��ƱԤ��Ȩ�� ȫ��
--select * from homsomDB..Trv_UPRanks where CompanyID='9C4B0B2E-9CCA-4F94-8929-A8EE00BB3B65'

select UPRankID,UPSettingID,* from homsomDB..Trv_UnitPersons
--update homsomDB..Trv_UnitPersons set UPRankID='CFF6241A-BC14-422F-A011-AA0700FEA2E2'
where ID in(Select ID from homsomDB..Trv_Human
where IsDisplay=1
) and CompanyID=(Select ID from homsomDB..Trv_UnitCompanies
where Cmpid='020410')

--Ԥ������ ������Ԥ��
select BookingType,* from homsomDB..Trv_BookingCollections
--update homsomDB..Trv_BookingCollections set BookingType=3
where ID in(Select BookingCollectionID from homsomDB..Trv_UPSettings
where ID in(Select UPSettingID from homsomDB..Trv_UnitPersons
where CompanyID='9C4B0B2E-9CCA-4F94-8929-A8EE00BB3B65'))

--UC020932ɾ��Ա��
select * from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (Select ID from homsomDB..Trv_UnitPersons
where CompanyID=(Select  ID from homsomDB..Trv_UnitCompanies 
where Cmpid='020932')) and IsDisplay=1
and Name not in('��ܿ','������')

select * from Topway..tbCusholderM
--update Topway..tbCusholderM set EmployeeStatus=0
where cmpid='020932' and custname not in('��ܿ','������')

--�����������ύ
 select dsettleno,sdisct,* from Topway..tbcash 
 --update Topway..tbcash  set sdisct=0
 where dsettleno='56720'
 
 
--���ÿ����� A LIST"��Զ����"���ṩ2018��1��1��-2019��7��19�ճ������ڻ�Ʊ�ĳ��ÿ�����
select distinct cmpcode,pasname,idno 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-07-20'
and inf=0
and reti=''
and cmpcode in('016307',
'018176',
'018814',
'019939',
'019121',
'020758',
'018930',
'018766',
'018303',
'020651',
'018199',
'020161',
'019475',
'020263',
'017200',
'017449',
'020351',
'020784',
'019110',
'020701',
'018671',
'020338',
'018134',
'020727',
'018420',
'020602',
'020215',
'019658',
'020180',
'020095',
'020094',
'017480',
'020119',
'020087',
'019634',
'016348',
'020253',
'020695',
'016961',
'020235',
'019363',
'017939',
'020069',
'019764',
'016719',
'016310',
'017519',
'020771',
'020349',
'019827',
'018945',
'020476',
'018385',
'020234',
'018731',
'019640',
'019882',
'020387',
'017873',
'020486',
'019961',
'020729',
'016504',
'019656',
'020734',
'019484',
'019006',
'020155',
'016936',
'020157',
'019348',
'016492',
'019780',
'019638',
'018940',
'020679',
'018345',
'020462',
'020690',
'020148',
'018522',
'019021',
'020641',
'018341',
'018094',
'017223',
'018822',
'017930',
'017932',
'017776',
'020147',
'020384',
'020812',
'020243',
'018981',
'013184',
'018868',
'020763',
'017886',
'019919',
'020709',
'018259',
'020072',
'002045',
'020466',
'016239',
'020626',
'018929',
'017007',
'017921',
'020603',
'019670',
'016890',
'019901',
'017326',
'020132',
'019953',
'020228',
'020675',
'020684',
'019998',
'017146',
'020733',
'016294',
'020191',
'016635',
'019794',
'017559',
'020718',
'018281',
'018061',
'020536',
'020761',
'020820',
'020799',
'020293',
'020142',
'019842',
'017919',
'018925',
'019227',
'019347',
'019403',
'019609',
'019951',
'020033',
'020510',
'020801',
'019863',
'017655',
'017916',
'020341',
'017954',
'020419',
'019455',
'019817',
'016848',
'017543',
'016061',
'020674',
'018926')
order by cmpcode


--ƥ�䵥λ���Ʋ��ṩ���ÿ�����
select Cmpid,Name from homsomDB..Trv_UnitCompanies
where Cmpid in('016586',
'020834',
'020841',
'020844',
'020880',
'020901',
'020832',
'020835',
'020851',
'020857',
'020859',
'020862',
'020872',
'020876',
'020878',
'020882',
'020893',
'020894',
'020895',
'020897',
'020909',
'020911',
'020915',
'020068',
'020925',
'020829',
'020846',
'019707',
'020852',
'020866',
'020884',
'020885',
'020928',
'020931',
'020932',
'020833',
'020875',
'020910',
'020919')

select Cmpid UC��,h.Name ��������,LastName+'/'+FirstName+MiddleName Ӣ������,CredentialNo ֤����
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.id=h.ID
left join homsomDB..Trv_Credentials cr on cr.HumanID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where IsDisplay=1
and  Cmpid in('016586',
'020834',
'020841',
'020844',
'020880',
'020901',
'020832',
'020835',
'020851',
'020857',
'020859',
'020862',
'020872',
'020876',
'020878',
'020882',
'020893',
'020894',
'020895',
'020897',
'020909',
'020911',
'020915',
'020068',
'020925',
'020829',
'020846',
'019707',
'020852',
'020866',
'020884',
'020885',
'020928',
'020931',
'020932',
'020833',
'020875',
'020910',
'020919')
order by Cmpid

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002651003','AS002648301','AS002649462','AS002651403')

--�Ƶ������
select price,totprofit,yhprice,yjprice,sprice,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set price='-7786',totprofit='-2952'
where CoupNo='PTW087652'

select  totprice,owe,* from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set totprice='-7786',owe='-7786'
where coupid=(select id from Topway..tbHtlcoupYf 
where CoupNo='PTW087652')

--�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='�������ɹ������������޹�˾'
where CoupNo='PTW086849'

--����ѱ��� ���	�������Դ	��Ʊ����	���۵���	�����	��Ʊ����	��Ʊ����	�������	HSӦ�������	��������	���ù���
declare @startdatetime varchar(10)
declare @enddatetime varchar(10)
declare @startdatetime varchar(10)
declare @startdatetime varchar(10)
declare @startdatetime varchar(10)
declare @startdatetime varchar(10)
declare @startdatetime varchar(10)

select feiyonginfo �������Դ,t.datetime ��Ʊ����,t.coupno ���۵���,t.feiyong �����,ExamineDate ��Ʊ����,reno ��Ʊ����,t.sfeiyong �������,
t.feiyong-t.sfeiyong HSӦ�������,t.profit ��������,sales ���ù���
from Topway..tbReti t
left join Topway..tbcash c on c.reti=t.reno
where reno='9267694'
where t.datetime>=''
and t.datetime<=''
and ExamineDate>=''
and ExamineDate<=''
and t.inf=''
and feiyonginfo in()
and CONVERT(varchar(4),tickettype) in()


select reno,* from Topway..tbReti
where ExamineDate>='2019-07-01'
and sfeiyong>0


--ƥ�䶩����
select RecordNumber,t.TravelID from  homsomDB..Trv_DomesticTicketRecord d
LEFT JOIN homsomDB..Trv_PnrInfos p ON d.PnrInfoID=p.ID
LEFT JOIN homsomDB..Trv_ItktBookings i ON p.ItktBookingID=i.ID
LEFT JOIN homsomDB..Trv_Travels t ON i.TravelID=t.ID
where RecordNumber in ('AS002454235',
'AS002537500',
'AS002444775',
'AS002454237',
'AS002237869',
'AS002164933',
'AS002560404',
'AS002347101',
'AS002472079',
'AS002562702',
'AS002556527',
'AS002344125',
'AS002248875',
'AS002176461',
'AS002245300',
'AS002248879',
'AS002560408',
'AS002290641',
'AS002164935',
'AS002176494',
'AS002412358',
'AS002061197',
'AS001871606',
'AS002324188',
'AS002037020',
'AS002472081',
'AS002344127',
'AS002459908',
'AS002176492',
'AS002356879',
'AS002561327',
'AS002237920')
