--�˵�����

SELECT SubmitState,* FROM topway..AccountStatement 
--update topway..AccountStatement set SubmitState='1'
WHERE CompanyCode = '019737' and BillNumber='019737_20181201'

--�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='����������ڳǹ��ʾƵ�'
where CoupNo='PTW075623'

--OA���ŵ���
select DeptCode,DeptName,* from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptCode='���۲�',DeptName='���۲�'
where DeptCode='�г����۲�'

--insert into ApproveBase..App_BaseDept values ('31','�г���','�г���')

--��Ա��
select Department,* from ApproveBase..HR_Employee 
--update ApproveBase..HR_Employee set DeptCode='���۲�',Department='���۲�'
where DeptCode='�г����۲�'

--��ٱ�

select * from ApproveBase..HR_AskForLeave_Signer 
---update ApproveBase..HR_AskForLeave_Signer set DeptCode='���۲�'
where DeptCode='�г����۲�'

--insert into ApproveBase..HR_AskForLeave_Signer values ('�г���','0102')

--ɾ����������
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='37585' and state='0'

--�ĵ���ʱ��
select date,* 
--update topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-01-24'
from topway..FinanceERP_ClientBankRealIncomeDetail where money='8990' and date='2019-01-25' and id='582A51B2-DF08-40CF-BAEE-5F437961359C'

--ɾ����������
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='21440' and date='2019-01-28'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='660' and date='2019-01-28'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='500' and date='2019-01-28' 
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='5856' and date='2019-01-28'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='4600' and date='2019-01-28'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='500' and date='2019-01-28' and id='7B9A3EAA-9B2C-4C81-96BC-8425CF3D111D'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='84614' and date='2019-01-28'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='42823' and date='2019-01-28' and id='8EF28C51-1B1F-4A36-8E36-F8ED8D911EFB'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='2000' and date='2019-01-28' and id='B5BEE19E-FC56-4CD1-9F9C-B15CF0FA7299'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='17470' and date='2019-01-28'

--2016��ĳ�Ʊ����

select coupno as ���۵���,datetime as ��Ʊ����,totprice as ���ۼ�,reti as ��Ʊ����,tcode+ticketno as Ʊ��,route  as �г�,ride+flightno as ����� from Topway..tbcash 
where custid='D181624' and datetime>='2016-01-01' and datetime<'2017-01-01'

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set SpareTC='��ӱ'
where coupno='AS001710067'

--��λ����
select indate,InDateA,* from Topway..tbcompanym 
--update Topway..tbcompanym set InDateA='2018-12-07 11:31:37.000'
where cmpid='020665'
select RegisterMonth,AdditionMonthA,* from homsomDB..Trv_UnitCompanies where Cmpid='020665'

--2019-01-25��ӵĳ����ÿ�
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
WHERE h.CreateDate>='2019-01-25' AND h.CreateDate<'2019-01-26' AND h.IsDisplay=1
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
WHERE h.CreateDate>='2019-01-25' AND h.CreateDate<'2019-01-26' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT empname FROM Topway..Emppwd WHERE dep='��Ӫ��' AND empname NOT IN('homsom','��˳����','��Ӫ��ѵ����'))

--���
select * from Topway..AccountStatement where CompanyCode='020643'--BillNumber='020643_20190101'

/*���㵥��Ϣ
1/28 �����ź�Ӧ�����㵥�ţ�108412��ԭ״̬�ѽ��㣬����ù����������������⣬�����Ͻ��㵥�ţ��Ȳ��ù��������������������ȡ��
*/
select * from topway..tbSettlementApp 
--update topway..tbSettlementApp set settleStatus='3'
where id='108412'
select * from topway..tbcash 
--update topway..tbcash set wstatus='0',settleno='0'
where settleno='108412'
select * from topway..tbReti 
--update topway..tbReti set inf2='0',settleno='0'
where settleno='108412'
select * from topway..Tab_WF_Instance 
--update topway..Tab_WF_Instance set Status='4'
where BusinessID='108412'
select * from topway..Tab_WF_Instance_Node 
where InstanceID in (select id from topway..Tab_WF_Instance where BusinessID='108412')
--delete from  topway..Tab_WF_Instance_Node where InstanceID in (select id from topway..Tab_WF_Instance where BusinessID='108412') and Status='0'

--�Ƶ����۵��ؿ���ӡȨ��
select pstatus,prdate,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set pstatus='0',prdate='1900-01-01'
where CoupNo='PTW075722'

--�޸��ֻ�����
select  Mobile,* from homsomDB..Trv_Human 
--update homsomDB..Trv_Human set Mobile='17321074979'
where ID='EB19BF9D-0D36-49D4-8E79-1D9DF1D47F98'

select Status,* from Topway..HM_CompanyAccountInfo 
--update Topway..HM_CompanyAccountInfo set Status='1'
where CmpId='020643' and Id='6820'

select Status,* from Topway..HM_CompanyAccountInfo 
--update Topway..HM_CompanyAccountInfo set Status='-1'
where CmpId='020643' and Id='6758'

--����Ʒר�ã��������Դ/�����Ϣ�����ʣ�
select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash  set feiyong='154',feiyonginfo='������λZYI'
where coupno='AS002222955'