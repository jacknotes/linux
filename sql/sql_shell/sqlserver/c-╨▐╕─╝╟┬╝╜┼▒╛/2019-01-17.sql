--�˵�����
SELECT SubmitState,* FROM topway..AccountStatement 
--update topway..AccountStatement set SubmitState='1'
WHERE (CompanyCode = '018735') and BillNumber='018735_20181101'

--����ɾ����Ӧ�̽�����Ϣ�С���������ʿ��һ��
select * from Topway..tbConventionBudget where ConventionId='1009'
--delete  Topway..tbConventionJS where ConventionId='1009' and Id='12463'

--�����տ��Ϣ
select Skstatus,* from  topway..tbTrvKhSk 
--update topway..tbTrvKhSk set Skstatus='2'
where TrvId='029447' and Id='226757'

--����Ʒ��ר�ã��޸���Ʊ״̬�����ڣ�
select opername,operDep,* from Topway..tbReti 
--update Topway..tbreti ,operDep=''
where reno in ('0425863','0425860','0425372','0425373','0422076','0422077')

--�Ѿ����
select status2,* from Topway..tbreti 
--update Topway..tbreti set status2='2'
where reno in ('0425863','0425860')

--��λ���͡����㷽ʽ���˵���ʼ���ڡ������¡�ע����
select * from Topway..AccountStatement where CompanyCode='017134' order by BillNumber desc
SELECT * FROM homsomdb..Trv_UCSettleMentTypes WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '017134') order by StartDate desc 
--erp
select Status,SEndDate,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set Status='-1',SEndDate='2018-12-31'
where CmpId='017134' and Status='1'
select Status,SStartDate,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set Status='1',SStartDate='2019-01-01'
where CmpId='017134' and Status='2'
--tms
SELECT * FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set EndDate='2018-12-31',Status='-1'
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '017134') and EndDate='2019-01-31 23:59:59.000'
SELECT * FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set StartDate='2019-01-01',Status='1'
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '017134') and StartDate='2019-02-01 00:00:00.000'

--������
SELECT c.cmpcode AS ��λ���,c.coupno AS ���۵���,s.Origin+s.Destination AS ���ж�,ISNULL(g.Kilometres,0) AS ������,c.datetime AS ��Ʊ���� FROM tbcash c 
LEFT JOIN homsomDB..Trv_DomesticTicketRecord r ON c.coupno=r.RecordNumber
LEFT JOIN homsomDB..Trv_PnrInfos p ON r.PnrInfoID=p.ID
LEFT JOIN homsomDB..Trv_ItktBookingSegments_PnrInfos t ON p.ID=t.PnrInfoID
LEFT JOIN homsomDB..Trv_ItktBookingSegs s ON t.ItktBookingSegID=s.ID
LEFT JOIN Topway..tbmileage g ON s.Origin=g.CityFromCode AND s.Destination=g.CityToCode
WHERE 
cmpcode='018080' AND datetime BETWEEN '2018-01-01' AND '2018-12-31' AND inf=0 AND coupno<>'as000000000' 
AND c.tickettype='����Ʊ' AND c.reti=''
--AND coupno='AS002089273'
ORDER BY c.datetime desc

--�ؿ���ӡȨ��
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus='0',PrDate='1900-01-01'
where TrvId='029447' and Id='226802'

--�ؿ���ӡȨ��
select PrintDate,Pstatus,* from topway..HM_tbReti_tbReFundPayMent
--update topway..HM_tbReti_tbReFundPayMent set PrintDate='1900-01-01',Pstatus='0'
 WHERE     (Id IN ('703619', '703620'))
 --�ؿ���ӡȨ��
 select pstatus,prdate,* from Topway..tbDisctCommission 
 --update Topway..tbDisctCommission set pstatus='0',prdate='1900-01-01'
 where id='56129'
 
 --Ԥ����Ա����
 select uc.Name, h.name,LastName+'/'+firstname+' '+MiddleName as ename,cr.Type,cr.CredentialNo
from homsomdb..Trv_UnitPersons up
left join homsomdb..Trv_Human h on h.ID=up.ID
left join homsomdb..Trv_Credentials cr on cr.HumanID=h.ID
left join homsomdb..Trv_UnitCompanies uc on uc.ID=up.CompanyID
where uc.CooperativeStatus in('1','2','3')
and uc.Cmpid in ('019234')
  and IsDisplay=1 

SELECT h.Name,h.Mobile FROM homsomDB..Trv_UPCollections_UnitPersons  up
left join homsomDB..Trv_Human h on h.ID=up.UnitPersonID
WHERE UPCollectionID='AA53871E-1086-4E90-954A-CFDF436FDF73' and h.IsDisplay='1'

SELECT *FROM homsomDB..Trv_UPCollections_UnitPersons 
WHERE UPCollectionID='AA53871E-1086-4E90-954A-CFDF436FDF73' 

--������
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='3320',profit='251'
where coupno='AS002210569'
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='13074',profit='2056'
where coupno='AS002209299'
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='4883',profit='447'
where coupno='AS002211180'

--����Ʒ��ר�ã��޸���Ʊ״̬�����ʣ�
select opername,operDep,* from Topway..tbReti 
--update Topway..tbReti set opername='����Ƽ'operDep=''
where reno in ('9265718','9265294','9265295','9265289','9265290','9265646')

--�˿��״̬�޸�
select dzhxDate,status2,* from topway..tbReti 
--update topway..tbReti set dzhxDate='1900-01-01',status2='6'
where reno in ('0426098','0426100')

--�˵�����
select TrainBillStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement set TrainBillStatus='1'
where CompanyCode='019822' and BillNumber='019822_20181201'

---�Ƶ����ݱ��Ԥ��
select  convert(varchar(6),prdate,112) as �·�,hotel as �Ƶ�����,CityName as ����,sum(yf.nights*pcs) as ���ܼ�ҹ��,sum(price) as ���ܽ�� 
from tbHtlcoupYf yf
inner join HotelOrderDB..HTL_Orders od on od.CoupNo=yf.CoupNo
inner join HotelOrderDB..HTL_OrderHotels oh on oh.OrderID=od.OrderID
inner join Emppwd d on d.empname=opername1
where prdate>='2018-01-01' and prdate<'2019-01-01'
and yf.status<>'-2'
group by convert(varchar(6),prdate,112),hotel,CityName
Order by convert(varchar(6),prdate,112)

--�Ƶ����ݱ���Ը�
select convert(varchar(6),datetime,112) as �·�,hotel as �Ƶ�����,CityName as ����,sum(coup.nights*pcs) as ���ܼ�ҹ��,sum(price) as ���ܽ�� 
from tbHotelcoup coup
inner join HotelOrderDB..HTL_Orders od on od.CoupNo=coup.CoupNo
inner join HotelOrderDB..HTL_OrderHotels oh on oh.OrderID=od.OrderID
inner join Emppwd d on d.empname=opername1
where datetime>='2018-01-01' and datetime<'2019-01-01'
and coup.status<>'-2'
group by convert(varchar(6),datetime,112),hotel,CityName
Order by convert(varchar(6),datetime,112)

--�޸���Ʊ�������
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti set ExamineDate='2019-01-14 15:24:57.030'
where reno='0425860'

--����ɾ��
delete topway..FinanceERP_ClientBankRealIncomeDetail where money='54417.81' and id='1A78199F-8EF5-4644-9B9D-5DB26AC83F79'
 
--��λ���͡����㷽ʽ���˵���ʼ���ڡ������¡�ע����
select * from Topway..AccountStatement where CompanyCode='020643' order by BillNumber desc
SELECT * FROM homsomdb..Trv_UCSettleMentTypes WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '020643') order by StartDate desc 
--���½�������
select PstartDate,* from topway..HM_CompanyAccountInfo 
--update topway..HM_CompanyAccountInfo set PstartDate='2019-01-21 00:00:00.000'
where CmpId='020643' and Id='6820'
select PendDate,* from topway..HM_CompanyAccountInfo 
--update topway..HM_CompanyAccountInfo set PendDate='2019-01-20 23:59:59.000'
where CmpId='020643' and Id='6758'
select SettlementPeriodAir,AccountPeriodAir2,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SettlementPeriodAir='2019-01-01~2019-01-20',AccountPeriodAir2='2019-01-20'
where CompanyCode='020643' and BillNumber='020643_20190101'

--�Ƶ����۵���Ӧ����Դ

select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='�����е������οƼ��ɷ����޹�˾'
where CoupNo='PTW075060'

--��������

select disct,bpprice,* from Topway..tbcash where coupno='AS002143887'
select Top 10* from Topway..tbDisctCommission 

--�¾��������¾�����
--�󱸹���APPLE
select cmpcode as ��λ���,SUM(totprice) as ����,SUM(profit) as ���� from Topway..tbcash 
where cmpcode in ('020295','020441','020262','020439','016883','020640') 
and datetime>='2018-10-01' and datetime<'2019-01-01' and reti=''
group by cmpcode
--�󱸹������Ʒ�
select cmpcode as ��λ���,SUM(totprice) as ����,SUM(profit) as ���� from Topway..tbcash 
where cmpcode in ('020566  ','020514','020461','020532','020567','020614') 
and datetime>='2018-10-01' and datetime<'2019-01-01' and reti=''
group by cmpcode
--�󱸹���TETE
select cmpcode as ��λ���,SUM(totprice) as ����,SUM(profit) as ���� from Topway..tbcash 
where cmpcode in ('018482','020552','020560','020561','020565','020432','020656','020699') 
and datetime>='2018-10-01' and datetime<'2019-01-01' and reti=''
group by cmpcode

select cmpcode as ��λ���,SUM(totprice) as ����,SUM(profit) as ���� from Topway..tbcash 
where cmpcode in ('020699') 
and datetime>='2018-10-01' and datetime<'2019-01-01' and reti=''
group by cmpcode

--���������������� 
--CAN and CDG
select coupno as ���۵���,tcode+ticketno as Ʊ��,recno as PNR,begdate as ��������,route as �г�, sales as �������ù��� from Topway..tbcash 
where datetime>='2018-01-01' and datetime<'2019-01-17' 
and (route like'%CAN%' and route like'%CDG%')
 and ride in('AF','KL') 
 and inf=1 and reti=''
 order by datetime
 --CAN or CDG
 select coupno as ���۵���,tcode+ticketno as Ʊ��,recno as PNR,begdate as ��������,route as �г�, sales as �������ù��� from Topway..tbcash 
where datetime>='2018-01-01' and datetime<'2019-01-17' 
and (route like'%CAN%' or route like'%CDG%')
 and ride in('AF','KL') 
 and inf=1 and reti=''
 order by datetime
 
 --18��ĳ�Ʊ����
 select cmpcode as UC,coupno as ���۵���,tcode+ticketno as Ʊ��,route as �г�,nclass as ��λ,totsprice-tax as �ļ��ۺϼ�,sales as �������ù��� from Topway..tbcash 
 where inf=1 and ride='SK'
 and reti='' and datetime>='2018-01-01' and datetime<'2019-01-01' 
 order by coupno