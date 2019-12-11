--�˵�����������ѵ���ͼۺ�����Լ���ʱ�� 
SELECT c.coupno,lp.Price ��ͼ�,lp.DepartureTime,lp.ArrivalTime,ride+flightno �����
 FROM topway..tbcash c 
LEFT JOIN homsomDB..Trv_DomesticTicketRecord r ON c.coupno=r.RecordNumber
LEFT JOIN homsomDB..Trv_PnrInfos p ON r.PnrInfoID=p.ID
LEFT JOIN homsomDB..Trv_ItktBookings i ON p.ItktBookingID=i.ID
left join homsomDB..Trv_ItktBookingSegs its on i.ID=its.ItktBookingID
left join homsomDB..Trv_LowerstPrices lp on its.ID=lp.ItktBookingSegID
where coupno in ('AS002441956',
'AS002441958',
'AS002442002',
'AS002446783',
'AS002447233',
'AS002447249',
'AS002449221',
'AS002450642',
'AS002452530',
'AS002453370',
'AS002454809',
'AS002456621',
'AS002456958',
'AS002457522',
'AS002457749',
'AS002457752',
'AS002457795',
'AS002457808',
'AS002458000',
'AS002458000',
'AS002458000',
'AS002458000',
'AS002458013',
'AS002458013',
'AS002458013',
'AS002458013',
'AS002458043',
'AS002458043',
'AS002458043',
'AS002458043',
'AS002459270',
'AS002459285',
'AS002459814',
'AS002461330',
'AS002462812',
'AS002464501',
'AS002464503',
'AS002464824',
'AS002465317',
'AS002465802',
'AS002470425',
'AS002472999',
'AS002475150',
'AS002476320',
'AS002478104',
'AS002484987',
'AS002484989',
'AS002485532',
'AS002485534',
'AS002485538',
'AS002486243',
'AS002488051',
'AS002491857',
'AS002491859',
'AS002491949',
'AS002498129',
'AS002498132',
'AS002499502',
'AS002503970',
'AS002507841',
'AS002508230',
'AS002510776',
'AS002511084',
'AS002511088',
'AS002511213',
'AS002511543',
'AS002511594',
'AS002512121',
'AS002512123',
'AS002512251',
'AS002512511',
'AS002513191',
'AS002516407',
'AS002516545',
'AS002517944',
'AS002518294',
'AS002518963',
'AS002518967')
and lp.Price<>''
order by c.coupno


--�޸�UC�ţ���Ʊ��

select custid,ModifyBillNumber,OriginalBillNumber,cmpcode,pform,* from Topway..tbcash
--update  Topway..tbcash set custid='D644037',OriginalBillNumber='020776_20190501',cmpcode='020776',pform='�½�(����)'
where coupno in('AS002482699','AS002502896','AS002502895')

--UC020637ɾ�����ÿ�
select * from homsomDB..Trv_Human 
--update homsomDB..Trv_Human set IsDisplay=0
where id in (Select id from homsomDB..Trv_UnitPersons
where CompanyID=(Select id from homsomDB..Trv_UnitCompanies where Cmpid='020637'))
and IsDisplay=1 and Name not in('����','��ˬ')

select EmployeeStatus,* from Topway..tbCusholderM 
--update Topway..tbCusholderM  set EmployeeStatus=0
where cmpid='020637' and custid not in ('D617503','D617504') and EmployeeStatus=1

--�г̵�
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='���ӡ�����г̵�'
where coupno in('AS002465927','AS002453661')

select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='���ӡ�г̵�'
where coupno in('AS002488145')

--�����տ����
select Skstatus,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set Skstatus=2
where ConventionId='1429' and Id='2747'


--UC020758�Ͳ�ҽҩԱ����ǰԤ����Ʊ����ϸ����������Ʊ�ˣ��˻��ˣ��в�����ã����г̣��ۿ۲�λ��Ʊ���ܼۣ�����ʱ�䣬��Ʊʱ��
select DATEDIFF(DD,[datetime],begdate) ��ǰ��Ʊ����,[datetime] ��Ʊʱ��,begdate ���ʱ��,h.Name ��Ʊ��,pasname �˻���,Department ���� 
,[route] �г�,case when priceinfo=0 then 1 else price/priceinfo end �ۿ���,totprice Ʊ���ܼ�,reti ��Ʊ����,tickettype Ʊ����
from Topway..tbcash c
left join homsomDB..Trv_UnitPersons u on u.CustID=c.custid
left join homsomDB..Trv_Human h on h.ID=u.ID
where cmpcode='020758'
and inf=1
order by ��Ʊʱ��

--1�����ɿˣ�UC016448��2018ȫ�꣬���Ϻ�Y�ճ�88�ۻ�Ʊ��ϸ��ȥ�˸ģ�
select datetime ��Ʊ����,begdate �������,coupno ���۵���,pasname �˻���,c.route �г�,tcode+ticketno Ʊ��,ride+flightno �����
,priceinfo ȫ��,price/priceinfo �ۿ���,originalprice ԭ��,price ���۵���,coupon �Żݽ��,tax ˰��,xfprice ǰ�����
, totprice ���ۼ�,DATEDIFF(DD,datetime,begdate)��ǰ��Ʊ����,CostCenter �ɱ�����,nclass ��λ
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs t on t.ItktBookingID=p.ItktBookingID
--left join homsomDB..Trv_RebateRelations r on t.RebateStr=r.FlightNormalPolicyID 
where cmpcode='016448' --and [Percent]=3
and datetime>='2018-01-01' and datetime<'2019-01-01' AND c.inf=0 AND c.tickettype='����Ʊ' AND c.originalprice>c.price AND c.ride IN('FM','MU') and reti=''
AND  CONVERT(DECIMAL(18,2),c.price/c.originalprice)=0.88

--2�����ɿ� (UC016448) 2018ȫ�꣬���ڻ�Ʊǰ��3%���л�Ʊ��ϸ��ȥ�˸ģ� 
select  datetime ��Ʊ����,begdate �������,coupno ���۵���,pasname �˻���,c.route �г�,tcode+ticketno Ʊ��,ride+flightno �����
,priceinfo ȫ��,'' �ۿ���,originalprice ԭ��,c.price ���۵���,coupon �Żݽ��,tax ˰��,xfprice ǰ�����
, totprice ���ۼ�,DATEDIFF(DD,datetime,begdate)��ǰ��Ʊ����,CostCenter �ɱ�����,nclass ��λ from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs t on t.ItktBookingID=p.ItktBookingID
left join homsomDB..Trv_RebateRelations r on t.RebateStr=r.FlightNormalPolicyID 
where cmpcode='016448' and [Percent]=3
and datetime>='2018-01-01' and datetime<'2019-01-01' AND c.inf=0 AND c.tickettype='����Ʊ'  and reti=''
order by datetime


select * from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs t on t.ItktBookingID=p.ItktBookingID
left join homsomDB..Trv_RebateRelations r on t.RebateStr=r.ID 
where cmpcode='016448' and [Percent]=3
and datetime>='2018-01-01' and datetime<'2019-01-01'


/*
UC018309
UC019392
UC019394
UC016588
UC015828
UC019358
UC020758
UC018431
2019��5��1��-5��31���ڼ䣬���ڻ�Ʊ�����ʻ�Ʊ���յ����ѽ��
*/
--����
select cmpcode,SUM(totprice) ���ѽ�� from Topway..tbcash 
where cmpcode in('018309','019392','019394','016588','015828','019358','020758','018431')
and datetime>='2019-05-01' and datetime<'2019-06-01'
and inf=0 
and (CabinClass like('%ͷ�Ȳ�%') or CabinClass like('%�����%'))
group by cmpcode

--����
select cmpcode,SUM(totprice)���ѽ�� from Topway..tbcash c
left join #cabin ca on ca.cabin=c.nclass
where cmpcode in('018309','019392','019394','016588','015828','019358','020758','018431')
and datetime>='2019-05-01' and datetime<'2019-06-01'
and (CabinName like('%ͷ�Ȳ�%') or CabinName like('%�����%'))
and inf=1 
group by cmpcode


if OBJECT_ID('tempdb..#cabin') is not null  drop table #cabin
select distinct CabinName,Cabin 
into #cabin
from homsomDB..Intl_BookingLegs 
where CabinName<>''

select * from #cabin

/*
������ڣ�2019��3��10����2019��5��31��    ��ע����SME��
 
Ҫ�أ�Ʊ�š����۵��š���Ӧ����Դ����Ʊ���š��ύ���ڡ�������ڡ����չ�˾��Ʊ�ѡ��տͻ���Ʊ����Ʊ����ҵ����ʡ���Ʊҵ����ʡ��ύ��Ʊҵ����ʡ���ע
*/
select  tcode+c.ticketno Ʊ��,t.coupno ���۵���,t_source ��Ӧ����Դ,reno ��Ʊ����,edatetime �ύ����
,ExamineDate �������,scount2 ���չ�˾��Ʊ��,rtprice �տͻ���Ʊ���,c.SpareTC ��Ʊ����ҵ�����,
c.sales ��Ʊҵ����� ,opername �ύ��Ʊҵ�����,t.info
from Topway..tbReti t
left join Topway..tbcash c on c.reti=t.reno
where ExamineDate>='2019-03-10' and ExamineDate<'2019-06-01'
and t.info like'%SME%'
order by �������

/*
���æ�ṩ������ͨ����Ʊ�ۡ��ĵ�λ���ݵ���������Ӧ���������Ӫ����лл��
 
 UC��  ��λ����     �����    �Ƿ�������   MU������F ��J ��Y����   MU������Y����������  ���ù���  ��Ӫ����  �ͻ�����
 
��ע����ǩ���������ĵ�λȥ����
*/
select u.Cmpid,u.Name,IsSepPrice ��������Ʊ��, * 
from homsomDB..Trv_UnitCompanies u 
left join ehomsom..tbCompanyXY t on  t.CmpId=u.Cmpid 
left join homsomDB..Trv_FlightTripartitePolicies f on f.UnitCompanyID=u.ID 
where t.[Type]<>1 and IsSelfRv=0 

 select * FROM [homsomdb].[dbo].[Trv_UCSettings]
  where BindAccidentInsurance is not null and BindAccidentInsurance <>''


--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002523101','AS002523606','AS002523635','AS002524053','AS002527323','AS002529247')

--�ؿ���ӡȨ��
select prdate,pstatus,HXQM,* from topway..tbHtlSettlementApp 
--update topway..tbHtlSettlementApp  set prdate='1900-01-01',pstatus=0,HXQM=''
where id='25953'

/*
���æ��ȡ���Ϻ��չ����ߣ��������ڣ�2019��01��-5��31�գ�
Ʊ��ۣ�����˰�գ�����1000���ϵ���س�Ʊ������ϸ
*/
select cmpcode,coupno,datetime,begdate,pasname,route,tcode+ticketno,
ride+flightno,price,totprice,tax 
from Topway..tbcash 
where datetime>='2019-01-01'
and datetime<'2019-06-01'
and inf=0
and price>1000
and ride='HU'
order by datetime

--�г̵�
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno in('AS002465927','AS002453661','AS002495360','AS002486224','AS002486225','AS002486482','AS002486625','AS002486939')

--��Ʊ��
--select pasname,* from Topway..tbcash where coupno='AS002509343'
update Topway..tbcash set pasname='TANG/XINGJUANMS',tcode='235',ticketno='2384017495' where coupno='AS002509343' and pasname='�˿�0'
update Topway..tbcash set pasname='LI/YINGMS',tcode='235',ticketno='2384017497' where coupno='AS002509343' and pasname='�˿�1'
update Topway..tbcash set pasname='WANG/FANGMS',tcode='235',ticketno='2384017499' where coupno='AS002509343' and pasname='�˿�2'
update Topway..tbcash set pasname='YIN/GUIHUAMS',tcode='235',ticketno='2384017501' where coupno='AS002509343' and pasname='�˿�3'
update Topway..tbcash set pasname='ZHANG/XINYUNMS',tcode='235',ticketno='2384017503' where coupno='AS002509343' and pasname='�˿�4'
update Topway..tbcash set pasname='SHEN/FANGMS',tcode='235',ticketno='2384017505' where coupno='AS002509343' and pasname='�˿�5'
update Topway..tbcash set pasname='ZHOU/HONGMS',tcode='235',ticketno='2384017507' where coupno='AS002509343' and pasname='�˿�6'
update Topway..tbcash set pasname='ZHANG/RUIFANGMS',tcode='235',ticketno='2384017509' where coupno='AS002509343' and pasname='�˿�7'
update Topway..tbcash set pasname='HE/HONGXINGMR',tcode='235',ticketno='2384017511' where coupno='AS002509343' and pasname='�˿�8'
update Topway..tbcash set pasname='YANG/JIEMR',tcode='235',ticketno='2384017513' where coupno='AS002509343' and pasname='�˿�9'
update Topway..tbcash set pasname='CHEN/GANGMR',tcode='235',ticketno='2384017515' where coupno='AS002509343' and pasname='�˿�10'
update Topway..tbcash set pasname='CAO/XILAIMR',tcode='235',ticketno='2384017517' where coupno='AS002509343' and pasname='�˿�11'
update Topway..tbcash set pasname='ZHI/WUPINGMS',tcode='235',ticketno='2384017519' where coupno='AS002509343' and pasname='�˿�12'
update Topway..tbcash set pasname='LIU/JINGSONGMR',tcode='235',ticketno='2384017521' where coupno='AS002509343' and pasname='�˿�13'
