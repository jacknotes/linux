select empname,idnumber,* from Topway..Emppwd 
--update Topway..Emppwd  set dep='�����з�����'
where dep='������' 

select * from ApproveBase..HR_Employee where DeptCode!=Department

select datetime ����,coupno,status,owe,totprice,pform,* from Topway..tbcash where status=1 and owe<>0 order by ���� desc


select bpay as ֧�����,status as �տ�״̬,opernum as ��������,oper2 as ������,oth2 as ��ע,totprice as ���ۼ�,dzhxDate as ����ʱ��,owe as Ƿ����
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
from Topway..tbcash where coupno in ('AS002520927','AS002492609','AS002407288','AS002404287')


--UC019294  UC017670 2018�꼯���ӹ�˾���ղ��÷���ͳ�Ʊ�
--��Ʊ����
if OBJECT_ID('tempdb..#cpfy') is not null drop table #cpfy
select cmpcode,SUM(totprice)/10000 ��Ʊ����
--into #cpfy
from Topway..tbcash 
where ModifyBillNumber in ('017670_20180101','017670_20180201','017670_20180301','017670_20180401','017670_20180501','017670_20180601',
'017670_20180701','017670_20180801','017670_20180901','017670_20181001','017670_20181101','017670_20181201',
'019294_20180101','019294_20180201','019294_20180301','019294_20180401','019294_20180501','019294_20180601',
'019294_20180701','019294_20180801','019294_20180901','019294_20181001','019294_20181101','019294_20181201')
--and ride  in('jd','Gs','Y8','8L','9H','gx','GT','PU','Uq','pn')
--and ride  in ('FM','MU')
--and ride  in ('CZ')
--and ride  in ('CA','ZH')
and inf=1
group by cmpcode

--��Ʊ����
if OBJECT_ID('tempdb..#tpfy') is not null drop table #tpfy
select cmpcode,sum(-totprice)/10000 ��Ʊ����
--into #tpfy
from Topway..tbReti 
where  ModifyBillNumber in ('017670_20180101','017670_20180201','017670_20180301','017670_20180401','017670_20180501','017670_20180601',
'017670_20180701','017670_20180801','017670_20180901','017670_20181001','017670_20181101','017670_20181201',
'019294_20180101','019294_20180201','019294_20180301','019294_20180401','019294_20180501','019294_20180601',
'019294_20180701','019294_20180801','019294_20180901','019294_20181001','019294_20181101','019294_20181201')
--and ride not in ('FM','MU')
--and ride not in ('CZ')
--and ride not in ('CA','ZH')
and inf=1
group by cmpcode

select ��Ʊ����+��Ʊ���� ���������   from #cpfy c
left join #tpfy t on c.cmpcode=t.cmpcode




select BillNumber �˵���,BillAmount ��Ʊ�˵���� from Topway..AccountStatement 
where BillNumber in ('017670_20180101','017670_20180201','017670_20180301','017670_20180401','017670_20180501','017670_20180601',
'017670_20180701','017670_20180801','017670_20180901','017670_20181001','017670_20181101','017670_20181201',
'019294_20180101','019294_20180201','019294_20180301','019294_20180401','019294_20180501','019294_20180601',
'019294_20180701','019294_20180801','019294_20180901','019294_20181001','019294_20181101','019294_20181201')
order by �˵���

--UC020866�Ϻ�������ʱװ���޹�˾ Ϊ����Ԥ�� ����������
if OBJECT_ID ('tempdb..#spr') is not null drop table #spr
select Cmpid,up.BookingCollectionID 
into #spr
from homsomDB..Trv_Human h 
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies  un on un.ID=u.CompanyID
left join homsomDB..Trv_UPSettings up on up.ID=u.UPSettingID
where Cmpid='020866' and h.Name in('������','л����')

if OBJECT_ID ('tempdb..#sp') is not null drop table #sp
select BookingCollectionID,un.ID 
into #sp
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons un on un.ID=h.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=un.CompanyID
left join #spr s on s.cmpid=u.Cmpid
where u.Cmpid='020866' 
and h.Name in('���',
'����',
'��ѩݼ',
'�Ƽλ�',
'��ٻ��',
'���S��',
'���ӿ�',
'������',
'������',
'��¶',
'����Ƽ',
'�տ���',
'�ּν�')

insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) select BookingCollectionID,ID from #sp


--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set  sales='������',SpareTC='������'
where coupno='AS001712967'

--�˵�����
select SubmitState,BillAmount,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020548_20190501'

--�г̵�
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno='AS002517163'


--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice-1,profit=profit+1
where coupno in('AS002537847','AS002540149')

select * from Topway..tbSettlementApp where id='113052'

/*
UC020410�����ҵ���޹�˾
2018.7--12�£�2019.1-5��
�Ƶ���������
*/
select CoupNo ���۵���,prdate Ԥ��ʱ��,end_date ���ʱ��,hotel �Ƶ�����,roomtype ����
,pasname ��ס��,nights ��ס����,pcs ������,price ���ۼ�
from Topway..tbHtlcoupYf
where cmpid='020410'
and prdate>='2018-07-01'
and prdate<'2019-06-01'
and  status!=-2
order by Ԥ��ʱ��


--�˻���ƥ�䳣�ÿ�
select distinct pasname,h.Name,idno  
from Topway..tbcash c
inner join homsomDB..Trv_Credentials cr on cr.CredentialNo=c.idno
inner join homsomDB..Trv_UnitPersons u on u.ID=cr.HumanID and CompanyID=(select id from homsomDB..Trv_UnitCompanies where Cmpid='020410')
inner join homsomDB..Trv_Human h on h.ID=cr.HumanID
where cmpcode='020410'

select pasname,COUNT(1)���� from Topway..tbcash where cmpcode='020410' group by pasname


--����֧����ʽ���Ը����渶��
--�����Ը�����渶
select AdvanceStatus,PayStatus,TCPayNo,PayNo,TcPayWay,CustomerPayWay,TcPayDate,CustomerPayDate,* from Topway..tbFiveCoupInfo      
--UPDATE Topway..tbFiveCoupInfo SET AdvanceStatus=PayStatus,TCPayNo=PayNo,TcPayWay=CustomerPayWay,TcPayDate=CustomerPayDate,PayStatus=0,PayNo=NULL,CustomerPayWay=0,CustomerPayDate=NULL
WHERE CoupNo='AS002360084'

--���³�Ʊ��Ϣ�е�֧����
select AdvanceStatus,PayStatus,TCPayNo,PayNo,TcPayWay,CustomerPayWay,TcPayDate,CustomerPayDate,dzhxDate,* from topway..tbcash
--update topway..tbcash set AdvanceStatus=PayStatus,TCPayNo=PayNo,TcPayWay=CustomerPayWay,TcPayDate=CustomerPayDate,PayStatus=0,PayNo=null,CustomerPayWay=0,CustomerPayDate=null
where coupno='AS002360084'

select * from ApproveBase..App_Content  where Value like '%2019050901872%'
