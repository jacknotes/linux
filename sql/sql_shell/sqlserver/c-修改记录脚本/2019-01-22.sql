--̩˼��ó�׳˻�������
 select begdate as ����ʱ��,coupno as ���۵���,pasname as �˻���,route as �г�,SUM(totprice) as '����(��˰)' from Topway..tbcash where datetime>='2018-01-01' and datetime<'2019-01-01' and cmpcode='018821' and reti='' 
 group by pasname,coupno,route,begdate
 order by begdate
 
 --��λ���͡����㷽ʽ���˵���ʼ���ڡ������¡�ע����
select PstartDate,* from Topway..HM_CompanyAccountInfo 
 --update Topway..HM_CompanyAccountInfo set PstartDate='2019-01-21'
 where CmpId='020273' and Id='6824'
  select PendDate,Status,* from Topway..HM_CompanyAccountInfo 
 --update Topway..HM_CompanyAccountInfo set PendDate='2019-01-20 23:59:59.000',Status='-1'
 where CmpId='020273' and Id='6476'
 --y��
 select SettlementPeriodAir,AccountPeriodAir2,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SettlementPeriodAir='2019-01-01~2019-01-20',AccountPeriodAir2='2019-01-20'
where CompanyCode='020273' and BillNumber='020273_20190101'
 
 select SStartDate,* from Topway..HM_SetCompanySettleMentManner 
 --update Topway..HM_SetCompanySettleMentManner set SStartDate='2019-01-21',Status='1'
 where CmpId='020273' and Status='2'
 select SEndDate,* from Topway..HM_SetCompanySettleMentManner 
 --update Topway..HM_SetCompanySettleMentManner set SEndDate='2019-01-20',Status='-1'
 where CmpId='020273' and Status='1'
 
 SELECT StartDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
 --update homsomdb..Trv_UCSettleMentTypes set StartDate='2019-01-21',Status='1'
 WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '020273') and Status='2'
  SELECT EndDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
 --update homsomdb..Trv_UCSettleMentTypes set EndDate='2019-01-20 23:59:59.000',Status='-1'
 WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '020273') and Status='1'
 select * from Topway..AccountStatement where BillNumber like'%020273_2019%'
 --2019-01-21��ӵĳ����ÿ�
 SELECT 
ISNULL(c.Cmpid,'') AS ��λ���,
ISNULL(c.Name,'') AS ��λ����,
ISNULL(h.Name,'') AS ������,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS Ӣ����,
h.Mobile AS �ֻ�����,
ISNULL((SELECT TOP 1 empname FROM Topway..Emppwd WHERE idnumber=h.CreateBy),'') AS ���ù���,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS ��Ӫ����
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate>='2019-01-21' AND h.CreateDate<'2019-01-22' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT idnumber FROM Topway..Emppwd WHERE dep='��Ӫ��' AND idnumber NOT IN('00002','00003','0421'))
UNION ALL

SELECT 
ISNULL(c.Cmpid,'') AS ��λ���,
ISNULL(c.Name,'') AS ��λ����,
ISNULL(h.Name,'') AS ������,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS Ӣ����,
ISNULL(h.Mobile,'') AS �ֻ�����,
h.CreateBy AS ���ù���,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS ��Ӫ����
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate>='2019-01-21' AND h.CreateDate<'2019-01-22' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT empname FROM Topway..Emppwd WHERE dep='��Ӫ��' AND empname NOT IN('homsom','��˳����','��Ӫ��ѵ����'))

--�ڱ���Ʊ����12��20190122
select cmpcode as ��λ���,'' as ��λ����,datetime as ��Ʊ����,coupno as ���۵���,tickettype as ����,ride+flightno as �����,begdate as ���ʱ��,tcode+ticketno as Ʊ��,
pasname as �˻���,route as �г�,totprice as ���ۼ� from Topway..tbcash 
where cmpcode in('019799','001787','018042','019448','019465','016362','019788','019450','019778','019798','019808','018615')
and datetime>='2018-07-01' and datetime<'2019-01-01'
order by datetime

--����Ʒ��ר�ã���Ʊ��Ӧ����Դ������)

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002209008'
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS��������D'
where coupno='AS002200955'
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002208829'
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETI'
where coupno='AS002212642'
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS�����ֿ�D'
where coupno='AS002202962'
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS����������'
where coupno='AS002200937'
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS������������D'
where coupno='AS002201040'

--�Ƶ����۵���Ӧ����Դ
SELECT profitsource,* FROM Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='�����е������οƼ��ɷ����޹�˾'
where CoupNo='PTW075140'

--������Ʊ����
select DISTINCT OutBegdate AS ����,Name as �˿�����,OutStroke as �г�,t.OutGrade as ��λ,TrainWebNo as ������,u.RealPrice as ��Ʊ�۸�,u.Fuprice as �����,u.PrintPrice as ��ӡ��,ISNULL(r.Fee,0) as ��Ʊ��,
TotUnitprice as ȫ��,u.RealPrice/TotUnitprice as �ۿ���--,t1.CostCenter as �ɱ�����
FROM Topway..tbTrainTicketInfo t
LEFT JOIN Topway..tbTrainUser u ON t.ID=u.TrainTicketNo
LEFT JOIN Topway..Train_ReturnTicket r ON u.ID=r.TickOrderDetailID
--left join Topway..tbcash t1 on t1.idno=u.Idno
where CmpId='019358' and OutBegdate>='2018-01-01' and OutBegdate<'2019-01-01' --AND t.ID='10848'
--and t1.CostCenter is not null and t1.CostCenter <>'undefined'
order by TrainWebNo


 --�Ϻ�����2018����
 
 select  t2.rtprice as ��Ʊ��,tickettype,
 '' as ǩ֤��,'' as ��Ʊ���� ,t.coupno from Topway..tbcash t
 left join ehomsom..tbInfAirCompany t1 on t1.code2=t.ride
 left join Topway..tbReti t2 on t2.reno=t.reti
 where t.datetime>='2018-01-01' and t.datetime<'2019-01-01' and t.cmpcode='019358' and t.priceinfo>'0' 
 order by tickettype
 
 --ǩ֤��
  select  YujPrice as  ǩ֤�� from Topway..tbTravelBudget where TrvCpName like'%ǩ֤%'
  and Cmpid='019358' and StartDate>='2018-01-01' and EndDate<'2019-01-01'

--���ڷѣ����գ�
select v.coupno as ���۵���,v.pasname as �˿�����,

 v.totprice as ���ڷ�,v.tickettype,
 '' as ǩ֤��,'' as ��Ʊ����
from Topway..tbcash v
left join ehomsom..tbInfAirCompany t1 on t1.code2=v.ride
  left join Topway..tbReti t3 on t3.reno=v.reti
where (v.route like'%����%' or v.tickettype like'%����%') and v.cmpcode='019358' and v.datetime >='2018-01-01' and v.datetime<'2019-01-01' 


--UC018134�Ƶ�����
select datetime as Ԥ��ʱ��,pasname as ��������,hotel as �Ƶ�����,beg_date as ��סʱ��,end_date as ���ʱ��,roomtype as ����,nights as ��ס����,pcs as ����,price as �����ܼ�

from Topway..tbHtlcoupYf where datetime>='2018-01-01' and datetime<'2019-01-01' and cmpid='018134'

--��λ�ͻ����Ŷ�ȵ���
SELECT SX_BaseCreditLine,SX_TomporaryCreditLine, SX_TotalCreditLine,*
FROM Topway..AccountStatement
--update Topway..AccountStatement set SX_TotalCreditLine=210000
WHERE     (CompanyCode = '019792') AND (BillNumber = '019792_20190101')

select sum(sprice),cmpid from Topway..tbHtlcoupYf where cmpid='019792' and datetime>='2019-01-01'  
group by cmpid

select sum(totprice) from Topway..tbcash where cmpcode='019792' and datetime>='2019-01-01' 
group by cmpcode


--UC020530 �������ϸ
select coupno as ���۵���,datetime as ��Ʊʱ��,begdate as ���ʱ��,tcode+ticketno as Ʊ��,route as �г�,pasname as �˿�����,fuprice as �����,ride+flightno as �����,totprice as ���ۼ�,reti
from Topway..tbcash 
where cmpcode='020530' --and fuprice>'0' 
order by datetime

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where BillNumber='019791_20181121'

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='���໪',SpareTC='���໪'
where coupno='AS001411048'