--���۵��ĳ�δ��
select bpay,status,opernum,oper2,* from Topway..tbcash 
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
where coupno='AS002241763'

--�˵�����
select SubmitState,* from Topway..AccountStatement
--update Topway..AccountStatement set SubmitState=1
 where BillNumber='020730_20190201'
 
 --�ؿ���ӡ
 select Pstatus,PrDate,* from Topway..tbTrvKhSk 
 --update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
 where TrvId='29759' and Id='227304'
 
 --ɾ��Ա���ű� TMS
select * from  homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (
select a.ID from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='020297')
and IsDisplay=1 )



--ɾ��Ա���ű�ERP
select * from Topway..tbCusholderM 
--update Topway..tbCusholderM  set EmployeeStatus=0
where cmpid='020297'

--�ึ�����뵥�ؿ���ӡ
select PrintTime,CustDate,CustId,CustStat,* from Topway..tbExtraPayment 
--update Topway..tbExtraPayment set PrintTime='',CustDate='',CustId='',CustStat=''
where Id='51596'


--����������
SELECT isnull(Department,'') ����,SUM(totprice-tax) ���ڻ�Ʊ���� 
FROM Topway..tbcash 
WHERE cmpcode = '020459'
AND inf=1
AND tickettype NOT IN ('���ڷ�', '���շ�','��������')
--AND ISNULL(ModifyBillNumber,'') <> ''
and datetime>='2018-07-01'
and datetime<'2019-01-01'
--AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
--AND CAST(SUBSTRING(T1.ModifyBillNumber,8,6)+'01' AS DATETIME)>=CAST(@STARTMONTH+'-01' AS DATETIME)
--AND CAST(SUBSTRING(T1.ModifyBillNumber,8,6)+'01' AS DATETIME)<=CAST(@ENDMONTH+'-01' AS DATETIME)
--and T1.CostCenter='CA'
GROUP BY Department
order by ���ڻ�Ʊ���� desc


--��ƱԱ��Ԥ����Ϊ����
select top 10 BookingSource, * from homsomDB..Trv_ItktBookings 

--PC�� ����
select sum(price) ����,COUNT(*) ���� from Topway..tbcash  c
left join homsomDB..Trv_ItktBookings i on c.BaokuID=i.ID
where datetime>='2018-07-01'
and datetime<'2019-01-01'
and cmpcode='020459'
--and i.BookingSource='1'
--and i.BookingSource in ('5','10','11')
and i.BookingSource in ('2','3','4')
and inf=0

--PC�� ����
select sum(price) ����,COUNT(*) ���� from Topway..tbcash  c
left join homsomDB..Intl_BookingOrders i on c.recno=i.PNR
where datetime>='2018-07-01'
and datetime<'2019-01-01'
and cmpcode='020459'
and i.BookingSource='1'
--and i.BookingSource in ('5','10','11')
--and i.BookingSource in ('2','3','4')
and inf=1




--UC016713�����½ᣨ���У�4/26��ʼ
select sform,sform1,* from Topway..tbCompanyM 
--update Topway..tbCompanyM  set sform='�½�(����)',sform1='�½�(����)'
where cmpid='016713'

--select * from Topway..HM_CompanyAccountInfo where CmpId='016713'
select SettleMentManner,SEndDate,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner  set SEndDate='2019-04-25'
where CmpId='016713' and Status=2 and SettleMentManner='�½�(�������)'

select SettleMentManner,SStartDate,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SStartDate='2019-04-26'
where CmpId='016713' and Status=2 and SettleMentManner='�½�(����)'


SELECT EndDate,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes  set EndDate='2019-04-25'
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '016713') and Status=2 and CreateBy='0626'

SELECT StartDate,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes  set StartDate='2019-04-26'
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '016713') and Status=2 and CreateBy='0175'

--�Ƶ����۵�����
select price,sprice,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set price='-1400',sprice='-1400'
where CoupNo='PTW078652'

--�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='�������ɹ������������޹�˾'
where CoupNo='PTW078378'

--��λ�ͻ����Ŷ�ȵ���
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement set SX_TotalCreditLine='360000'
where BillNumber='020585_20190301'