--�˵�����
select SubmitState,* from Topway..AccountStatement
--update Topway..AccountStatement set SubmitState=1
where BillNumber='016588_20190526'

select * from Topway..FinanceERP_ClientBankRealIncomeDetail where date='2019-07-09' and money='1000'

/*
���ҿ���016448���ʻ�Ʊ��������ֻҪ������˰��
2017.07.01-2018.06.30
2018.07.01-2019.06.30
*/
select sum(��������˰-isnull(��Ʊ��,0)) ��������˰ from (
select SUM(price) ��������˰,reti from Topway..tbcash 
where cmpcode='016448'
and datetime>='2017-07-01'
and datetime<'2018-07-01'
and inf=1
group by reti) t1
left join (
select SUM(totprice) ��Ʊ��,reno from Topway..tbReti
where cmpcode='016448'
and datetime>='2017-07-01'
and datetime<'2018-07-01'
and inf=1
group by reno
)  t2 on t1.reti=t2.reno

select sum(��������˰-isnull(��Ʊ��,0))��������˰ from (
select SUM(price) ��������˰,reti from Topway..tbcash 
where cmpcode='016448'
and datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=1
group by reti) t1
left join (
select SUM(totprice) ��Ʊ��,reno from Topway..tbReti
where cmpcode='016448'
and datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=1
group by reno
)  t2 on t1.reti=t2.reno


--�޸�OAǩ����
select Signer,* from ApproveBase..App_DefineBase 
--update ApproveBase..App_DefineBase  set Signer='0601'
where Signer='601'

select * from ApproveBase..App_DefineBase where Signer='601'
select * from ApproveBase..App_Content where AppID='APP201907120002'
select Signer,* from ApproveBase..App_DefineBase 
--update ApproveBase..App_DefineBase  set Signer='0602'
where AppNo in('WF0118','WF0123','WF0124','WF0148','WF0194') and Seq=1

--�޸Ļ�ƱԤ��Ȩ��
select UPRankID,* from homsomDB..Trv_UnitPersons 
--update homsomDB..Trv_UnitPersons  set UPRankID='EEFB7FC3-E12E-426F-BBE9-AA8500EB243B'
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='020777')
and ID in(Select ID from homsomDB..Trv_Human where Name in('�ڸ�',
'��ͮ',
'����',
'Ĳ��',
'��ӱ',
'����',
'���',
'��ׯ',
'��ΰ��',
'Ϳ����',
'ʩ�г�',
'��˫��',
'Ф˼ǿ',
'����',
'�¾�',
'��ï��',
'����',
'������',
'����',
'����',
'ף����') and IsDisplay=1)

select UPRankID,* from homsomDB..Trv_UnitPersons 
--update homsomDB..Trv_UnitPersons  set UPRankID='FEAC5608-702F-493D-A18E-AA8500EB0FA5'
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='020777')
and ID in(Select ID from homsomDB..Trv_Human where Name not in('�ڸ�',
'��ͮ',
'����',
'Ĳ��',
'��ӱ',
'����',
'���',
'��ׯ',
'��ΰ��',
'Ϳ����',
'ʩ�г�',
'��˫��',
'Ф˼ǿ',
'����',
'�¾�',
'��ï��',
'����',
'������',
'����',
'����',
'ף����') and IsDisplay=1)

--����Ʒ��ר�ã���Ʊ��Ӧ����Դ�����ʣ�
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='�ֽ�渶'
where coupno in('AS002517582','AS002517581')

--�ؿ���ӡ
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate-'1900-01-01'
where TrvId='30217' and Id='228744'

select * from ApproveBase..App_Agent where AgentID='601'

--����֧����ʽ���Ը����渶��
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,vpayinf,amount,* from Topway..tbcash 
--update Topway..tbcash set TCPayNo=PayNo,PayNo='',AdvanceStatus=PayStatus,PayStatus=0,TcPayWay=CustomerPayWay,CustomerPayWay=0,TcPayDate=CustomerPayDate,dzhxDate='1900-01-01',CustomerPayDate='1900-01-01',status=0,owe=totprice,vpay=0,vpayinf=''
where coupno in ('AS002607776','AS002607772')


select PayStatus,AdvanceStatus,PayNo,TCPayNo,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET AdvanceStatus=PayStatus,TCPayNo=PayNo,TcPayWay=CustomerPayWay,TcPayDate=CustomerPayDate,PayStatus=0,PayNo='',CustomerPayWay=0,CustomerPayDate=null
WHERE CoupNo in ('AS002607776','AS002607772')

--�����տ��Ϣ
select Price,totprice,owe,Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Price='36973',totprice='36973',owe='36973',Pstatus=0,PrDate='1900-01-01'
where TrvId='30413'

--�����տ��Ϣ
select Skstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Skstatus=2
where TrvId='29995' and Id='228720'

--���ν��㵥��Ϣ
select beg_date,end_date,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set beg_date='2019-08-02',end_date='2019-08-04'
where CoupNo='PTW086460'

--�Ƶ����֧��˵��
 select cwstatus,owe,vpay,opername1,vpayinfo,oth2,totprice,operdate1,vpayinfo,* from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set vpayinfo='֧����'
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo in('PTW084499','PTW084219'))

--�����տ������ע
select oth2,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set oth2=''
where ConventionId='1444'

--�����տ������ע
select oth2,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set oth2=''
where TrvId='30217'

--��ͨ���ù��ʼ�Ч����
select IsJoinRank,* from Topway..Emppwd 
--update Topway..Emppwd  set IsJoinRank='1'
where idnumber='����'


select c.coupno,route,CityName1,CityName2,b.Sort,bo.Sort
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where datetime>='2019-07-01'
and inf=1
order by b.Sort,bo.Sort

select tickettype,route,reti,begdate,cmpcode,trvYsId,ConventionYsId,* from Topway..tbcash where coupno in('AS002601445',
'AS002628290',
'AS002623774',
'AS002628292',
'AS002601448',
'AS002601441',
'AS002601442',
'AS002601442',
'AS002610403',
'AS002628291',
'AS002601447',
'AS002617826',
'AS002615958',
'AS002628294')
select OrderId,* from Topway..tbFiveCoupInfo where CoupNo in('AS002601445',
'AS002628290',
'AS002623774',
'AS002628292',
'AS002601448',
'AS002601441',
'AS002601442',
'AS002601442',
'AS002610403',
'AS002628291',
'AS002601447',
'AS002617826',
'AS002615958',
'AS002628294')
