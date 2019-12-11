--���ɿ˷�Ӷ����
/*
1 UC016448����3���ɱ����ġ�CA��RP��AM����
2 UC016713
3 UC018408
4 UC018541
5 UC020085
6 UC020273
7 UC020637 ����3�����ţ���CA��TCC��JV����
8 UC020643
9 UC020655
10 UC220665
11 UC020685
12 UC020742
*/

--�з�Ӷ
if  OBJECT_ID('tempdb..#fx') is not null drop table #fx
select cmpcode UC��,u.Name ��λ����,SUM(totprice) ����,count(1) ����,SUM(xfprice) ��Ӷ���
into #fx
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos t on t.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs s on t.ItktBookingSegID=s.ID
left join homsomDB..Trv_UnitCompanies  u on u.Cmpid=c.cmpcode
where --cmpcode in('016713','018408','018541','020085','020273','020643','020655','020665','020685','020742')
cmpcode='020637'
and Department='ca'
and inf=0
and reti=''
--and tickettype='����Ʊ'
and datetime>='2019-04-01'
and xfprice<>0
group by cmpcode,u.Name

--select * from #fx

--�޷�Ӷ
if  OBJECT_ID('tempdb..#wfx') is not null drop table #wfx
select cmpcode UC��,u.Name ��λ����,SUM(totprice) ����
into #wfx
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos t on t.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs s on t.ItktBookingSegID=s.ID
left join homsomDB..Trv_UnitCompanies  u on u.Cmpid=c.cmpcode
where --cmpcode in('016713','018408','018541','020085','020273','020643','020655','020665','020685','020742')
cmpcode='020637'
and Department='ca'
and inf=0
and reti=''
--and tickettype='����Ʊ'
and datetime>='2019-04-01'
and xfprice=0
and ride='mu'
and nclass in('U','F','J','Y')
group by cmpcode,u.Name

if  OBJECT_ID('tempdb..#wfx1') is not null drop table #wfx1
select cmpcode UC��,u.Name ��λ����,SUM(totprice) ����,count(1) ����
into #wfx1
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos t on t.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs s on t.ItktBookingSegID=s.ID
left join homsomDB..Trv_UnitCompanies  u on u.Cmpid=c.cmpcode
where --cmpcode in('016713','018408','018541','020085','020273','020643','020655','020665','020685','020742')
cmpcode='020637'
and Department='ca'
and inf=0
and reti=''
--and tickettype='����Ʊ'
and datetime>='2019-04-01'
and xfprice=0
group by cmpcode,u.Name

select f.UC��,f.��λ����,f.����,f.����,f.��Ӷ���,w1.����,w1.����,w.����
from #fx f
left join #wfx w on w.UC��=f.UC��
left join #wfx1 w1 on w1.UC��=f.UC��


--UC019808 ����2018������� ���ڹ����������������������Ϻ�����������������ռ�ȣ���������������������ռ�ȣ��Ϻ�����������������ռ�ȣ����Ϻ����Żݽ��
--���ڳ�Ʊ����

if OBJECT_ID('tempdb..#gncp') is not null drop table #gncp
select cmpcode UC��,SUM(totprice) ����������,COUNT(1)����������
--into #gncp
from Topway..tbcash 
where cmpcode='019808'
--and reti<>''
and ModifyBillNumber in ('019808_20180101','019808_20180201','019808_20180301','019808_20180401','019808_20180501','019808_20180601','019808_20180701','019808_20180801','019808_20180901','019808_20181001','019808_20181101','019808_20181201')
and inf=0
group by cmpcode


--select * from #tpf1  select * from #gncp
--select SUM(BillAmount) from Topway..AccountStatement where BillNumber in ('019808_20180101','019808_20180201','019808_20180301','019808_20180401','019808_20180501','019808_20180601','019808_20180701','019808_20180801','019808_20180901','019808_20181001','019808_20181101','019808_20181201')

--��Ʊ��
if OBJECT_ID('tempdb..#tpf1') is not null drop table #tpf1
select cmpcode UC��,sum(-totprice) ������Ʊ�� ,count(1)������Ʊ���� 
into #tpf1
from Topway..tbReti
where cmpcode='019808'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=0
group by cmpcode

--���ʳ�Ʊ����
if OBJECT_ID('tempdb..#gjcp') is not null drop table #gjcp
select cmpcode UC��,SUM(totprice) ����������,COUNT(1)����������
--into #gjcp
from Topway..tbcash 
where cmpcode='019808'
--and reti<>''
and ModifyBillNumber in ('019808_20180101','019808_20180201','019808_20180301','019808_20180401','019808_20180501','019808_20180601','019808_20180701','019808_20180801','019808_20180901','019808_20181001','019808_20181101','019808_20181201')
and inf=1
group by cmpcode

--select * from #tpf2

--��Ʊ��
if OBJECT_ID('tempdb..#tpf2') is not null drop table #tpf2
select cmpcode UC��,sum(-totprice) ������Ʊ��,count(1)������Ʊ����
into #tpf2
from Topway..tbReti
where cmpcode='019808'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
group by cmpcode

--���Ϻ�
if OBJECT_ID('tempdb..#dscp') is not null drop table #dscp
select cmpcode UC��,SUM(totprice) ���Ϻ�������,sum(coupon) ���Ϻ��Żݽ��,sum(convert(decimal(18,3),isnull(originalprice,0)))-sum(price)Э���Żݽ��,COUNT(1)���Ϻ�������
--into #dscp
from Topway..tbcash 
where cmpcode='019808'
--and reti<>''
and ModifyBillNumber in ('019808_20180101','019808_20180201','019808_20180301','019808_20180401','019808_20180501','019808_20180601','019808_20180701','019808_20180801','019808_20180901','019808_20181001','019808_20181101','019808_20181201')
and ride in('FM','MU')
--and originalprice<>''
group by cmpcode



--��Ʊ��
if OBJECT_ID('tempdb..#dsf1') is not null drop table #dsf1
select cmpcode UC��,sum(-totprice) ���Ϻ���Ʊ�� ,COUNT(1)���Ϻ���Ʊ����
into #dsf1
from Topway..tbReti
where cmpcode='019808'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and ride in('FM','MU')
group by cmpcode

--�Ϻ�
if OBJECT_ID('tempdb..#nhcp') is not null drop table #nhcp
select cmpcode UC��,SUM(totprice) �Ϻ�������,COUNT(1)�Ϻ�������
--into #nhcp
from Topway..tbcash 
where cmpcode='019808'
and ModifyBillNumber in ('019808_20180101','019808_20180201','019808_20180301','019808_20180401','019808_20180501','019808_20180601','019808_20180701','019808_20180801','019808_20180901','019808_20181001','019808_20181101','019808_20181201')

and ride in('cz')
group by cmpcode

--��Ʊ��
if OBJECT_ID('tempdb..#nsf1') is not null drop table #nsf1
select cmpcode UC��,sum(-totprice) �Ϻ���Ʊ�� ,COUNT(1)�Ϻ���Ʊ����
into #nsf1
from Topway..tbReti
where cmpcode='019808'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and ride in('cz')
group by cmpcode

--����
if OBJECT_ID('tempdb..#ghcp') is not null drop table #ghcp
select cmpcode UC��,SUM(totprice) ����������,COUNT(1)����������
--into #ghcp
from Topway..tbcash 
where cmpcode='019808'
--and reti<>''
and ModifyBillNumber in ('019808_20180101','019808_20180201','019808_20180301','019808_20180401','019808_20180501','019808_20180601','019808_20180701','019808_20180801','019808_20180901','019808_20181001','019808_20181101','019808_20181201')

and ride in('ca')
group by cmpcode

--��Ʊ��
if OBJECT_ID('tempdb..#gsf1') is not null drop table #gsf1
select cmpcode UC��,sum(price-totprice) ������Ʊ��,COUNT(1) ������Ʊ����
into #gsf1
from Topway..tbReti
where cmpcode='019808'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and ride in('ca')
group by cmpcode

select ����������-������Ʊ�� as ����������,����������-������Ʊ���� as ����������,����������-������Ʊ�� as ����������,����������-������Ʊ���� as ����������,
���Ϻ�������-���Ϻ���Ʊ�� as ���Ϻ�������,���Ϻ��Żݽ��,'29860'as Э���Żݽ��,���Ϻ�������-���Ϻ���Ʊ���� as ���Ϻ�������,'' ռ��,����������-������Ʊ�� as ����������,����������,'' ռ��,
�Ϻ�������-�Ϻ���Ʊ�� as �Ϻ�������,�Ϻ�������-�Ϻ���Ʊ���� as �Ϻ�������,'' ռ��
from #gncp n
left join #tpf1 t1 on t1.UC��=n.UC��
left join #gjcp g on g.UC��=n.UC��
left join #tpf2 t2 on t2.UC��=n.UC��
left join #dscp d1 on d1.UC��=n.UC��
left join #dsf1 d2 on d2.UC��=n.UC��
left join #nhcp n1 on n1.UC��=n.UC��
left join #nsf1 n2 on n2.UC��=n.UC��
left join #ghcp g1 on g1.UC��=n.UC��
left join #gsf1 g2 on g2.UC��=n.UC��

/*
������Ҫ�˽��������UC���ڣ�����λ��Ʊ��������Ʊ����ռ�ȣ�����������ݣ����ṩ����֧�֡�

     UC016888��UC020748��UC020789��UC017735��UC017505

     ȫ�۾��ò����ϣ�U/F/P/J/C/D/I/W/Y
     �ۿ۾��òգ�B/M/E/H/K/L/N/R/S/Q

     ������2018.6.1��2019.5.31����һ�갴��һ����ȡ������һ�갴�պ���֮����ʼ��ȡ��лл��
����λ��Ʊ��������Ʊ����ռ�ȣ����
*/
select RegisterMonth,* from homsomDB..Trv_UnitCompanies where Cmpid in ('016888','020748','020789','017735','017505')

select cmpcode UC��,nclass ��λ,COUNT(1)����,SUM(totprice) ������� 
from Topway..tbcash 
where cmpcode in('016888','020748','020789','017735','017505')
and datetime>='2018-06-01'
and datetime<'2019-06-01'
and nclass in ('U','F','P','J','C','D','I','W','Y','B','M','E','H','K','L','N','R','S','Q')
group by cmpcode,nclass
order by UC��

select cmpcode UC��,COUNT(1)������,SUM(totprice) ��������� 
from Topway..tbcash 
where cmpcode in('016888','020748','020789','017735','017505')
and datetime>='2018-06-01'
and datetime<'2019-06-01'
--and nclass in ('U','F','P','J','C','D','I','W','Y','B','M','E','H','K','L','N','R','S','Q')
group by cmpcode


--UC019732�޸��˵�̧ͷ
select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement  set CompanyNameCN='���绯���տ�˹���Ϻ����������޹�˾'
where BillNumber='019732_20190621'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='017903_20190501'

--����Ʒר�ã��������Դ/�����Ϣ�����ʣ�
select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash  set feiyonginfo=''
where coupno='AS002580449'

--��Ʊ���۵���Ϊδ��
select bpay ,status,opernum,oper2,oth2,totprice,dzhxDate,owe
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
from Topway..tbcash where coupno in ('AS002442898',
'AS002443115',
'AS002443581',
'AS002443588',
'AS002446763',
'AS002446766',
'AS002447022',
'AS002447025',
'AS002449452',
'AS002449458',
'AS002452764',
'AS002452767',
'AS002452861',
'AS002460160',
'AS002460164',
'AS002460163',
'AS002460167',
'AS002460972',
'AS002461780',
'AS002466444',
'AS002467924',
'AS002468495',
'AS002470574',
'AS002470574',
'AS002470576',
'AS002470576',
'AS002471330',
'AS002471337',
'AS002477806',
'AS002477806',
'AS002477821',
'AS002477835',
'AS002477835',
'AS002478148',
'AS002478650',
'AS002479572',
'AS002480528',
'AS002480587',
'AS002484727',
'AS002484767',
'AS002484767',
'AS002484762',
'AS002484770',
'AS002488521',
'AS002488860',
'AS002489255',
'AS002496034',
'AS002496036',
'AS002496040',
'AS002496046',
'AS002497544',
'AS002497862',
'AS002499801',
'AS002502799',
'AS002503844',
'AS002503847',
'AS002504759',
'AS002506355',
'AS002506347',
'AS002506347',
'AS002506379',
'AS002506395',
'AS002506358',
'AS002506382',
'AS002506350',
'AS002506350',
'AS002506340',
'AS002506340',
'AS002506340',
'AS002506344',
'AS002506344',
'AS002506344',
'AS002507949',
'AS002509547',
'AS002510908',
'AS002512055',
'AS002514428',
'AS002517594')


--�˵�����
select HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set HotelSubmitStatus=2
where BillNumber='018004_20190501'

--�Ƶ����۵�����
select status,* from Topway..tbHtlcoupYf 
--update  Topway..tbHtlcoupYf  set status=-2
where CoupNo='PTW085356'

--UC020554ɾ����λԱ��
select * from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
 where id in (Select ID from homsomDB..Trv_UnitPersons 
 where companyid=(Select  ID from homsomDB..Trv_UnitCompanies 
 where Cmpid='020554')) and IsDisplay=1
 and Name not in ('������','�����')
 
 select * from Topway..tbCusholderM
 --update Topway..tbCusholderM set EmployeeStatus=0
 where cmpid='020554'
 and custname not in ('������','�����')
 
 --��Ʊҵ�������Ϣ
 select sales,SpareTC,* from Topway..tbcash 
 --update Topway..tbcash  set SpareTC='�ź���'
 where coupno='AS002521203'
 
 
 --����۲��
 select totsprice,profit,* from Topway..tbcash 
 --update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
 where coupno in('AS002579001','AS002578016','AS002580827','AS002578585','AS002579189')
 
 --��������
 select CommissionStatus,appdate,appName,* from Topway..tbDisctCommission 
 --update Topway..tbDisctCommission  set appdate='1900-01-01',appName=null
 where id='56626'
 
 select dsettleno,sdisct,* from Topway..tbcash 
 --update Topway..tbcash  set dsettleno='56626',sdisct=0
 where dsettleno='56626'
 
 
 --�ؿ���ӡ
 select pstatus,prdate,settleStatus,* from Topway..tbSettlementApp 
 --update Topway..tbSettlementApp  set pstatus=0,prdate='1900-01-01'
 where id in ('113540','113542','113548')
 
  --�ؿ���ӡ
 select Pstatus,PrDate,SettleStatus,PrName,* from Topway..tbConventionSettleApp 
 --update Topway..tbConventionSettleApp  set SettleStatus=1,Pstatus=0,PrDate='1900-01-01'
 where Id in('3942','3943')
 
 select pstatus,prdate,HXQM,* from Topway..tbHtlSettlementApp 
 --update Topway..tbHtlSettlementApp  set HXQM=''
 where id='26072'
 
 select Pstatus,PrDate,PrName,SettleStatus,* from Topway..tbTrvSettleApp 
 --update Topway..tbTrvSettleApp  set Pstatus=0,PrDate='1900-01-01',PrName='',SettleStatus=1
 where Id='27578'
 
 /*
UC018362 ����˹��������ϵͳ���Ϻ������޹�˾
2018��ȫ��
�ֶ�Ҫ����Ա��Ϣ ���� ������ Ŀ�ĵ� ��λ�ȼ� ���ۼ۸�
*/
select top 100 * from homsomDB..Trv_ItktBookingSegs

SELECT coupno ���۵���,pasname �˻���,convert(varchar(10),datetime,120) ��Ʊ����,begdate �������,Arriving ��������,c.route �г�,nclass ��λ�ȼ�,totprice ���ۼ� ,reti ��Ʊ����
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos t on t.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs s on t.ItktBookingSegID=s.ID
where cmpcode='018362'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf!=-1
order by ��Ʊ����

--�ؿ���ӡ
select Pstatus,Pdatetime,* from Topway..tbTrvJS 
--update Topway..tbTrvJS  set Pstatus=0,Pdatetime='1900-01-01'
where TrvId in('27578')

--�Ƶ���㵥����
select settleStatus,* from Topway..tbHtlSettlementApp 
--update Topway..tbHtlSettlementApp  set settleStatus=3
where id='26073'

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set SpareTC='����'
where coupno='AS002582725'

select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set SpareTC='����'
where coupno='AS002520367'