/*
��λ��ţ�UC020778
��Ʊ���ڣ�2019.5.28-2019.6.13
��Ʊ���ͣ�����+����
���Ҫ�󣺳˻�������	֤��
*/
select distinct pasname �˻�������,idno ֤��
from Topway..tbcash
where cmpcode='020778'
and datetime>='2019-05-28'
and datetime<'2019-06-14'
and inf<>-1

/*UC020459
���æ��ȡ�ù�˾5�¹���Ʊ�͹���ͷ�ȡ�����յ�����
���۵��� ������ ��Ʊ���� ������� Ԥ���� �˿����� ��· ����� ���ʱ�� Ʊ�� ȫ�� �ۿ��� ���۵���˰�� ����� ���ۼ� ��Ʊ���� ���� ��Ȩ�� ��ͼ� δѡ����ͼ�ԭ�� ��λ�ȼ�
*/
select top 100 * from homsomDB..Trv_DomesticTicketRecord
select top 100 * from homsomDB..Trv_Travels
select top 100 * from homsomDB..Trv_ItktBookings


select c.coupno ���۵���,t.TravelID ������,datetime ��Ʊ����,begdate �������,h.Name Ԥ����,c.route ��·,ride+flightno �����,
begdate ���ʱ��,tcode+ticketno Ʊ��,c.tax ���۵���˰��,fuprice �����,
totprice ���ۼ�,reti ��Ʊ����,Department ����,AuthorizationCode ��Ȩ�� ,nclass ��λ�ȼ�,CabinClass
--,isnull(l.Price,'') ��ͼ�,isnull(UnChoosedReason,'') δѡ����ͼ�ԭ��
from Topway..tbcash c
left join homsomDB..Trv_UnitPersons u on u.CustID=c.custid
left join homsomDB..Trv_Human h on h.ID=u.ID
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos p on d.PnrInfoID=p.ID
left join homsomDB..Trv_ItktBookings i on i.ID=p.ItktBookingID
left join homsomDB..Trv_Travels t on i.TravelID=t.ID
left join homsomDB..Trv_TktBookings tk on p.ItktBookingID=tk.ID
--left join homsomDB..Trv_ItktBookingSegs s on s.ItktBookingID=p.ItktBookingID
--left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=s.ID
where cmpcode='020459'
and datetime>='2019-05-01'
and datetime<'2019-06-01'
and inf=0
--and (CabinClass like '%ͷ��%' or CabinClass like '%����%')
and CabinClass not like'%����%'
order by datetime

select top 100 AuthorizationCode,* from homsomDB..Intl_BookingOrders
select top 100* from homsomDB..Trv_LowerstPrices

select c.coupno ���۵���,b.OrderNo ������,datetime ��Ʊ����,begdate �������,h.Name Ԥ����,c.route ��·,ride+flightno �����,
begdate ���ʱ��,tcode+ticketno Ʊ��,c.tax ���۵���˰��,fuprice �����,
c.totprice ���ۼ�,reti ��Ʊ����,Department ����,AuthorizationCode ��Ȩ�� ,nclass ��λ�ȼ�
--,isnull(l.Price,'') ��ͼ�--,isnull(UnChoosedReason,'') δѡ����ͼ�ԭ��
from Topway..tbcash c
left join homsomDB..Trv_UnitPersons u on u.CustID=c.custid
left join homsomDB..Trv_Human h on h.ID=u.ID
left join Topway..tbFiveCoupInfo f on f.CoupNo=c.coupno
left join homsomDB..Intl_BookingOrders b on b.Id=f.OrderId
where cmpcode='020459'
and datetime>='2019-05-01'
and datetime<'2019-06-01'
and inf=1
order by datetime


--�г̵�
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno='AS002467098'

/*
��Ʊ����2018.7.1-2019.6.9�����ڻ�Ʊ����ƾ֤ĿǰΪ����Ʊ���������ˡ�FM MU�������ݡ�
��Ҫ�ֶΣ�UC�š�������������������ѽ���Ʊ���������������/���������İٷֱȣ������ֶ������иߵ��ͣ�

�������Һ����ʼ���ӵ����������ڱ���ƾ֤Ϊ��Ʊ��ȥ�����������������ֽ��Լ�����Ʊ�۹رյĿͻ�
��˾���ƣ�
���ù��ʣ�
��Ӫ����
���������
����������
���������ʣ�
��UC�����еĳ��ÿ�������
��UC��2018��6��1��-2019��5��31�ճ������ڻ�Ʊ�ĳ��ÿ�������
��UC��2017��6��1��-2019��5��31�ճ������ڻ�Ʊ�ĳ��ÿ�������
��˾MU��FM�Ĺ���S V T Z�ճ�Ʊ����վ����������ռ��
*/

--��λ��ϸ
if OBJECT_ID('tempdb..#dwmx') is not null drop table #dwmx
select u.Cmpid UC��,u.Name ��λ����,s1.Name ���ù���,s2.Name ��Ӫ����
into #dwmx
from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_TktUnitCompanies_TktTCs t on t.TktUnitCompanyID=u.ID
left join Topway..HM_ThePreservationOfHumanInformation h on h.CmpId=u.Cmpid and IsDisplay=1 and MaintainType=9
left join homsomDB..SSO_Users s1 on s1.ID=t.TktTCID
left join homsomDB..SSO_Users s2 on s2.UserID=h.MaintainNumber
where CertificateD=2
and CooperativeStatus in ('1','3')
and IsSepPrice=1
and u.Type='A'

--������ϸ
if OBJECT_ID('tempdb..#xlmx') is not null drop table #xlmx
select cmpcode,SUM(totprice) ��������1,SUM(profit) ����������1,SUM(profit) /SUM(totprice) ���������� 
into #xlmx
from Topway..tbcash
where cmpcode in(Select UC�� from  #dwmx )
and inf=0
and datetime>='2018-07-01'
and datetime<'2019-07-01'
group by cmpcode

--���г��ÿ�����
if OBJECT_ID('tempdb..#clrs') is not null drop table #clrs
select Cmpid,SUM(1)���г��ÿ�����
into #clrs
from homsomDB..Trv_Human h 
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid in (Select UC�� from  #dwmx )
and IsDisplay=1
group by Cmpid

--��UC��2018��6��1��-2019��5��31�ճ������ڻ�Ʊ�ĳ��ÿ�����
if OBJECT_ID('tempdb..#cprs') is not null drop table #cprs
select cmpcode,pasname,idno,COUNT(1)���� 
into #cprs
from Topway..tbcash 
where cmpcode in(Select UC�� from  #dwmx)
and datetime>='2018-06-01'
and datetime<'2019-06-01'
and inf=0
group by cmpcode,pasname,idno

if OBJECT_ID('tempdb..#cprs2') is not null drop table #cprs2
select cmpcode,COUNT(1)���ÿ�����1 into #cprs2 from #cprs group by cmpcode

--��UC��2017��6��1��-2019��5��31�ճ������ڻ�Ʊ�ĳ��ÿ�����
if OBJECT_ID('tempdb..#cprs1') is not null drop table #cprs1
select cmpcode,pasname,idno,COUNT(1)���� 
into #cprs1
from Topway..tbcash 
where cmpcode in(Select UC�� from  #dwmx)
and datetime>='2017-06-01'
and datetime<'2019-06-01'
and inf=0
group by cmpcode,pasname,idno

if OBJECT_ID('tempdb..#cprs3') is not null drop table #cprs3
select cmpcode,COUNT(1)���ÿ�����2 into #cprs3 from #cprs1 group by cmpcode

--��˾MU��FM�Ĺ���S V T Z�ճ�Ʊ����վ����������ռ��
if OBJECT_ID('tempdb..#xlzb') is not null drop table #xlzb
select c.cmpcode,SUM(c.totprice) ��������2,SUM(c.totprice)/sum(m.��������1) ����������ռ��
into #xlzb
from Topway..tbcash c
left join #xlmx m on m.cmpcode=c.cmpcode
where c.cmpcode in(Select UC�� from  #dwmx )
and inf=0
and datetime>='2018-07-01'
and datetime<'2019-07-01'
and c.ride in('FM','MU')
and c.nclass in ('s','v','t','z')
group by c.cmpcode

select dw.UC��,��λ����,���ù���,��Ӫ����,isnull(��������1,0) ��������1,isnull(����������1,0) ����������1,isnull(����������,0) ����������,
isnull(���г��ÿ�����,0) ���г��ÿ�����,isnull(���ÿ�����1,0) ���ÿ�����1,isnull(���ÿ�����2,0) ���ÿ�����2,isnull(��������2,0) ��������2,isnull(����������ռ��,0) ����������ռ��
from #dwmx dw
left join #xlmx xl on dw.UC��=xl.cmpcode
left join #clrs cl on cl.Cmpid=dw.UC��
left join #cprs2 cp on cp.cmpcode=dw.UC��
left join #cprs3 cp1 on  cp1.cmpcode=dw.UC��
left join #xlzb zb on  zb.cmpcode=dw.UC��
where dw.UC�� not in ('000003')
order by dw.UC��



--����Ʒר�ã����ս������Ϣ
select sprice1,totsprice,profit,totprice,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=2.2,totsprice=2.2
where coupno in ('AS002525174','AS002525706','AS002525705',
'AS002532250','AS002542863','AS002545040','AS002549740','AS002549898',
'AS002549899','AS002549911','AS002549912','AS002550471','AS002550478',
'AS002552613','AS002552614')

select sprice1,totsprice,profit,totprice,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=2.2,totsprice=2.2
where coupno in ('AS002520739','AS002533850')

select sprice1,totsprice,profit,totprice,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=3.9,totsprice=3.9
where coupno in ('AS002519869','AS002519871','AS002520369','AS002520368')

select sprice1,totsprice,profit,totprice,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=3.9,totsprice=3.9
where coupno in ('AS002522337','AS002522328','AS002522307','AS002523407',
'AS002525785','AS002527856','AS002528027','AS002528194','AS002528839','AS002528840',
'AS002529350','AS002534336','AS002535150','AS002539378','AS002539426','AS002540086',
'AS002540106','AS002540137','AS002540176','AS002540460','AS002543115','AS002543426',
'AS002546104','AS002546115','AS002547420','AS002547436','AS002550617','AS002551362',
'AS002551364','AS002552387','AS002554345','AS002556000','AS002556367','AS002556453')

--����Ʒ��ר�ã��������Ϣ�����ʣ�
select pasname,* from Topway..tbcash 
where tcode+ticketno='1157355670355'


--�������ż����������Ϣ������
select Status,* from Topway..tbConventionBudget where ConventionId='1413'

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set SpareTC='���໪'
where coupno='AS001709343'

--��Ʊ���ۼ���Ϣ
select TotFuprice,TotPrice,TotPrintPrice,TotSprice,TotUnitprice,* from Topway..tbTrainTicketInfo 
--update Topway..tbTrainTicketInfo  set TotFuprice=0,TotPrice=TotPrice-15
where CoupNo in('RS000024581','RS000024582','RS000024583','RS000024584')

select Fuprice,* from Topway..tbTrainUser
--update  Topway..tbTrainUser set Fuprice=0
where TrainTicketNo in(select ID  from Topway..tbTrainTicketInfo 
where CoupNo in('RS000024581','RS000024582','RS000024583','RS000024584'))

--�����տ��Ϣ
select Skstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Skstatus=2
where TrvId='29795' and Id='228120'

--���ν��㵥��Ϣ
select GysSource,* from Topway..tbTrvJS 
--update Topway..tbTrvJS  set GysSource='ͨ��'
where TrvId='30188'

--�����տ��Ϣ ��λ
select Pstatus,PrDate,Price,totprice,owe,InvoiceTax,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set InvoiceTax=770
where ConventionId='1440' and Id='2778'

--�ؿ���ӡ
select Pstatus,PrDate,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set Pstatus=0,PrDate='1900-01-01'
where ConventionId='1440' and Id='2778'

--����۽�λ
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002555459','AS002555460','AS002556191')

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice-1,profit=profit+1
where coupno in('AS002556192')

--�˵�����
select HotelSubmitStatus,* from Topway..AccountStatement  
--update Topway..AccountStatement   set HotelSubmitStatus=1
where BillNumber='018309_20190501'

select * from ApproveBase..App_Content where AppID='APP201906140019'

select * from ApproveBase..App_DefineBase 

select * from ApproveBase..HR_AskForLeave_Signer


--����Ʒר�ã��������Դ/�����Ϣ������
SELECT feiyong,feiyonginfo,profit,* FROM Topway..tbcash 
--update Topway..tbcash  set feiyonginfo=''
WHERE coupno='AS002559355'

SELECT feiyong,feiyonginfo,profit,* FROM Topway..tbcash 
--update Topway..tbcash  set feiyonginfo='������λZYI'
WHERE coupno='AS002556101'


--ɾ����Ŀ���
select Code,* 
--delete
from homsomDB..Trv_Customizations 
where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019392') 
and Code='140970001.88000'


select empname,idnumber from Topway..Emppwd where dep in('������','�����з�����') and idnumber not in ('00000','00001')