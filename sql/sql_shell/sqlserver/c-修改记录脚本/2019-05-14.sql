/*
����ȡ2019.1.1-5.13�����ʻ�Ʊ������Ʊ�����ݡ�
���ֶΣ���Ʊ���� �������� ���� ��λ ���� ����
���æ���ݷ����� SHA/PVG ����ռ�ȡ�����ռ�ȡ�����ռ�ȣ�����������������ռ�ȡ�����ռ�ȡ�����ռ��
*/
--��һ
if OBJECT_ID('tempdb..#by') is not null drop table #by
select coupno,convert(varchar(10),datetime,120) ��Ʊ����,begdate ��������,route ����,nclass ��λ����,sum(totprice) ����,sum(profit) ����,COUNT(1) ����
into #by
from Topway..tbcash 
where datetime>='2019-01-01'
and datetime<'2019-05-14'
and inf=1
and tickettype='����Ʊ'
and coupno not in ('AS000000000')
group by datetime,begdate,route,nclass,coupno
order by datetime

select SUM(����)�ϼ�����,SUM(����)�ϼ�����,SUM(����)�ϼ����� from #by


--���
if OBJECT_ID('tempdb..#be') is not null drop table #be
select coupno,datetime ��Ʊ����,begdate ��������,route ����,nclass ��λ����,sum(totprice) ����,sum(profit) ���� ,COUNT(1) ����
into #be
from Topway..tbcash 
where datetime>='2019-01-01'
and datetime<'2019-05-14'
and inf=1
and tickettype='����Ʊ'
and coupno not in ('AS000000000')
and ( route like 'SHA%' or route like 'pvg%')
group by datetime,begdate,route,nclass,coupno
order by datetime

select SUM(����)�ϼ�����,SUM(����)�ϼ�����,SUM(����)�ϼ����� from #be


--�˵�����
select SubmitState,HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set HotelSubmitStatus=3,SubmitState=1
where BillNumber='017602_20190401'

--�г̵�������Ʊ��
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='���ӡ�г̵�'
where coupno='AS002459422'

select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='���ӡ�г̵�'
where coupno in('AS002434253','AS002448892')

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='020589_20190401'


select tax,stax,totsprice,profit,Mcost,* from Topway..tbcash 
--update Topway..tbcash set totsprice=2650,profit=502
where coupno='AS002461494'

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=10839,profit=1629
where coupno='AS002466470'

--������㵥����

select Jstatus,* from topway..tbConventionJS
--update topway..tbConventionJS set Jstatus='0',Settleno='0',Pstatus='0',Pdatetime='1900-1-1' 
where Settleno='27201'

--��Ʊ���㵥��Ϣ����
select settleStatus,* from Topway..tbSettlementApp
--update Topway..tbSettlementApp set settleStatus='3' 
where id='111886'

select wstatus,settleno,* from Topway..tbcash
--update Topway..tbcash set wstatus='0',settleno='0' 
where settleno='111886'

select inf2,settleno,* from Topway..tbReti
--update Topway..tbReti set inf2='0',settleno='0' 
where settleno='111886'

select Status,* from Topway..Tab_WF_Instance
--update Topway..Tab_WF_Instance set Status='4' 
where BusinessID='111886'

select * 
--delete 
from  topway..Tab_WF_Instance_Node where InstanceID in (select id from topway..Tab_WF_Instance where BusinessID='111886') 
and Status='0'

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set SpareTC='��ޱ'
where coupno='AS001630693'

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set SpareTC='�����',sales='�����'
where coupno in('AS001630760','AS001630756')

--�г̵�������Ʊ��
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='���ӡ�����г̵�'
where coupno='AS002434294'

--����Ŷ�Ʊ
select Pasname,MobileList,Idno,CostCenter,pcs,Department,BirthPlace,* from topway..tbFiveCoupInfosub 
--update tbFiveCoupInfosub set Idno=Idno+',��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��',MobileList=MobileList+',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='29',Department='��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��',Pasname=Pasname+',�˿�2,�˿�3,�˿�4,�˿�5,�˿�6,�˿�7,�˿�8,�˿�9,�˿�10,�˿�11,�˿�12,�˿�13,�˿�14,�˿�15,�˿�16,�˿�17,�˿�18,�˿�19,�˿�20,�˿�21,�˿�22,�˿�23,�˿�24,�˿�25,�˿�26,�˿�27,�˿�28,�˿�29',BirthPlace='1982-01-03,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01'
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002471471')

--�ؿ���ӡ
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus=0,PrDate='1900-01-01'
where TrvId='29918'

--�޸�UC�ţ���Ʊ��
--select * from Topway..tbCusholder where custname='�ƻ�'

select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,pform,xfprice,* from Topway..tbcash
--update topway..tbcash set custid='D198516'
 where coupno in ('AS002450558','AS002450624','AS002450629')
 
 select CustId,CmpId,Cmpname,* from Topway..tbFiveCoupInfo 
  --update Topway..tbFiveCoupInfo set CustId='D198516'
  where CoupNo in ('AS002450558','AS002450624','AS002450629')
  
   --�޸�UC�ţ�TMS)
  select CmpId,CompanyName,CustId,* from homsomDB..Intl_BookingOrders 
  --update homsomDB..Intl_BookingOrders set CustId='D198516'
  where OrderNo in ('IF00033966','IF00033971','IF00033972')
  
  --����Ԥ�㵥��Ϣ ��λ�ĳɸ���
  --select * from Topway..tbCusholder where mobilephone='18602103956'
  
select CustomerType,* from topway..tbTravelBudget
--update topway..tbTravelBudget set custid='D198634',cmpid='',Custinfo='18602103956@��ܲ��@@@��ܲ��@18602103956@D198634' ,CustomerType='���˿ͻ�'
where trvid='30047'
  
--��λ��Ϣ

select  Cmpid,Address,un.Phone,COUNT(1) ���� from homsomDB..Trv_UnitCompanies un
left join homsomDB..Trv_UnitPersons u on un.ID=u.CompanyID
left join homsomDB..Trv_Human h on h.ID=u.ID
where IsDisplay=1 
and Cmpid in('018541',
'000126',
'018021',
'017753',
'017969',
'020342',
'020075',
'018897',
'019786',
'017977',
'019935',
'018743',
'020053',
'016713',
'020421',
'020548',
'018362',
'020324',
'017120',
'018941',
'019270',
'017762',
'017608',
'020646',
'020645',
'017012',
'020550',
'016655',
'020659',
'020524',
'020585',
'020650',
'019505',
'020350',
'020316',
'019360',
'019839',
'020541',
'000370',
'019106',
'020504',
'016336',
'016087',
'018002',
'017999',
'016457',
'020561',
'020360',
'017887',
'018482')
group by Address,un.Phone,Cmpid

--���ÿ�
select Cmpid,u.Name,CustID,h.Name,h.LastName+'/'+h.FirstName+MiddleName Ӣ����,(case cr.[type] when 1 then '���֤' when 2 then '����' else '����' end) ֤������,CredentialNo  
 from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons un on un.ID=h.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=un.CompanyID
left join homsomDB..Trv_Credentials cr on cr.HumanID=h.ID
where IsDisplay=1
and Cmpid in('018541',
'000126',
'018021',
'017753',
'017969',
'020342',
'020075',
'018897',
'019786',
'017977',
'019935',
'018743',
'020053',
'016713',
'020421',
'020548',
'018362',
'020324',
'017120',
'018941',
'019270',
'017762',
'017608',
'020646',
'020645',
'017012',
'020550',
'016655',
'020659',
'020524',
'020585',
'020650',
'019505',
'020350',
'020316',
'019360',
'019839',
'020541',
'000370',
'019106',
'020504',
'016336',
'016087',
'018002',
'017999',
'016457',
'020561',
'020360',
'017887',
'018482')
order by Cmpid
