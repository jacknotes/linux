--���ÿ�ɾ��
--select * from homsomDB..Trv_UnitCompanies where Cmpid='017735'
--TMS
select IsDisplay from homsomDB..Trv_Human 
--update homsomDB..Trv_Human  set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons where CompanyID='DD1C99FB-BD51-424E-BA28-04A24040B9DF')
and IsDisplay=1
and Name not in ('���')
--ERP
select EmployeeStatus from Topway..tbCusholderM 
--update Topway..tbCusholderM set EmployeeStatus=0
where cmpid='017735'
and custname not in ('���')

--�г̵�','����Ʊ��
select info3, * from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno in('AS002344169','AS002332698')

--����Ԥ�㵥��Ϣ
select Sales,OperName,introducer,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Sales='��֮��',OperName='0481��֮��',introducer='��֮��-0481-��Ӫ��'
where ConventionId in 
('1317','1347','1327','1361','1354','1336','1346','1365',
'1352','1353','1311','1310','1341','1326','1271','1355','1359','1321',
'1349','1356','1386','1382','1380','1383','1381','1385')

----�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='Я�̹�����������'
where CoupNo='PTW079775'

select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='Ա���渶(�������п�)'
where CoupNo='PTW080098'

--����Ԥ�㵥��Ϣ
select Sales,OperName,introducer from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Sales='��֮��',OperName='0481��֮��',introducer='��֮��-0481-��Ӫ��'
where ConventionId='1384'

select totprice,totsprice,owe,profit,* from Topway..tbcash where coupno='AS002377747'

--ɾ����λԱ��
--select * from homsomDB..Trv_UnitCompanies where Cmpid='016888'

select IsDisplay from homsomDB..Trv_Human 
--update homsomDB..Trv_Human set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons 
where companyid='411D371B-E5C9-45BD-8886-BC9FBDC25091')
and Name not in ('�Ƽ�Ƽ����ְ��','֣������ְ��')

select EmployeeStatus from Topway..tbCusholderM
--update  Topway..tbCusholderM set EmployeeStatus=0
where cmpid='016888'
and custname not in ('�Ƽ�Ƽ����ְ��','֣������ְ��')

--�޸�UC��(����)
--select * from Topway..tbcash where cmpcode='000126' and datetime>'2019-04-11'
--select custid from Topway..tbCusholderM where cmpid='000126' and custname='�Ų�Ƽ'
--select * from Topway..AccountStatement where CompanyCode='000126' order by BillNumber desc
--select * from Topway..AccountStatement where CompanyCode='018720' order by BillNumber desc

select cmpcode,custid,ModifyBillNumber,OriginalBillNumber,pform,inf,* from Topway..tbcash 
--update Topway..tbcash  set cmpcode='000126',custid='D481444',OriginalBillNumber='000126_20190401'
where coupno='AS002320047'

   --�޸�UC�ţ�TMS)
  select  CompanyName,* from homsomDB..Trv_Passengers
  --update homsomDB..Trv_Passengers set CompanyName='�����������ó�ף��Ϻ������޹�˾'
  where ItktBookingID='2F0F8585-5FCC-4EE9-8CF1-AA100143943E'
  
 --����۲��
 select totsprice,profit,* from Topway..tbcash 
 --update Topway..tbcash  set totsprice='5376',profit='782'
 where coupno='AS002389837'
 
 --��Ʊ���۵�����
 select * 
 --delete
 from Topway..tbTrainTicketInfo where CoupNo='RS000022051'
 
 select * 
 --delete
 from Topway..tbTrainUser where TrainTicketNo=( 
 select id from Topway..tbTrainTicketInfo 
 where CoupNo='RS000022051')
 
 --��Ʊ��Ӧ����Դ/������Ϣ
 select Ptype,* from Topway..tbTrainTicketInfo where CoupNo in('RS000022076','RS000022077')

--�ؿ���ӡ 
select pstatus,prdate,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set pstatus=0,prdate='1900-01-01'
where CoupNo='-PTW079321'


--select * from homsomDB..Trv_UnitCompanies where Cmpid='018623'
select IsDisplay from homsomDB..Trv_Human 
--update homsomDB..Trv_Human set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons 
where companyid='ED4D414A-3827-4B3D-8193-A314009ABA10')
and Name  in ('�����',
'��ӱ',
'�»�ƽ',
'������',
'�˺���',
'�·�',
'�Ž��',
'���Ƿ�',
'������',
'��С��',
'������',
'�ַɱ�',
'Ф��',
'��С��',
'�»���',
'��ѩԴ',
'������',
'�Ϲ�ʥ',
'������',
'�����',
'ռ��',
'л����',
'��С�',
'·����',
'�±�',
'��һ��(��ְ��',
'����ΰ',
'�ƽ���',
'����������ְ��',
'����',
'�����')

select EmployeeStatus from Topway..tbCusholderM
--update  Topway..tbCusholderM set EmployeeStatus=0
where cmpid='018623'
and custname  in ('�����',
'��ӱ',
'�»�ƽ',
'������',
'�˺���',
'�·�',
'�Ž��',
'���Ƿ�',
'������',
'��С��',
'������',
'�ַɱ�',
'Ф��',
'��С��',
'�»���',
'��ѩԴ',
'������',
'�Ϲ�ʥ',
'������',
'�����',
'ռ��',
'л����',
'��С�',
'·����',
'�±�',
'��һ��(��ְ��',
'����ΰ',
'�ƽ���',
'����������ְ��',
'����',
'�����')


/*--���������ŷ�����
select Department ����,SUM(price) ����˰����,count(*) ����,SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) ƽ���ۿ��� 
from Topway..V_TicketInfo where cmpcode='020459'
and ModifyBillNumber in ('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201')
and tickettype NOT IN ('���ڷ�', '���շ�','��������')
and inf=1
group by Department
order by ����˰���� desc

select SUM(price) �ϼƲ���˰����,count(*) ����,SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) �ϼ�ƽ���ۿ��� 
from Topway..V_TicketInfo where cmpcode='020459'
and ModifyBillNumber in ('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201')
and tickettype NOT IN ('���ڷ�', '���շ�','��������')
and inf=1
*/
/*
select * from homsomDB..Trv_UnitPersons u
left join homsomDB..Trv_Human h on h.ID=u.ID
where u.CompanyID=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='020459')
and h.Name='�¼���'
*/


DECLARE @CMPCODE VARCHAR(20)='020459'
DECLARE @CUSTID VARCHAR(20)=''
DECLARE @STARTMONTH VARCHAR(10)='2018-07'
DECLARE @ENDMONTH VARCHAR(10)='2018-12'

IF OBJECT_ID('TEMPDB..#TTMP') IS NOT NULL
DROP TABLE #TTMP
CREATE TABLE #TTMP (
	MONTHDATE VARCHAR(10),
	GNSALESAMOUNT DECIMAL(18,2),
	GNTAX DECIMAL(18,2),
	GNTPAMOUNT DECIMAL(18,2),
	GNGQAMOUNT DECIMAL(18,2),
	GNFWFAMOUNT DECIMAL(18,2),
	GJSALESAMOUNT DECIMAL(18,2),
	GJTAX DECIMAL(18,2),
	GJTPAMOUNT DECIMAL(18,2),
	GJGQAMOUNT DECIMAL(18,2),
	GJFWFAMOUNT DECIMAL(18,2),
	BXAMOUNT DECIMAL(18,2),
	GNCOUNT INT,
	GJCOUNT INT
)

--���ڻ�Ʊ����
INSERT INTO #TTMP(MONTHDATE,GNSALESAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) �·�,SUM(price) ���ڻ�Ʊ���� FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype NOT IN ('���ڷ�', '���շ�','��������')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--���ڻ�Ʊ˰��
INSERT INTO #TTMP(MONTHDATE,GNTAX)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) �·�,SUM(tax) ���ڻ�Ʊ˰�� FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype NOT IN ('���ڷ�', '���շ�','��������')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--���ڻ�Ʊ��Ʊ�ܽ��
INSERT INTO #TTMP(MONTHDATE,GNTPAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) �·�,SUM(-T1.totprice) ���ڻ�Ʊ��Ʊ�ܽ�� FROM Topway..tbReti T1 WITH (NOLOCK)
INNER JOIN Topway..tbcash T2 WITH (NOLOCK) ON T1.reno=T2.reti 
WHERE T1.cmpcode = @CMPCODE
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND T2.inf=0
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--���ڻ�Ʊ������������
INSERT INTO #TTMP(MONTHDATE,GNGQAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) �·�,SUM(totprice) ���ڻ�Ʊ������������ FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype IN ('���ڷ�', '���շ�','��������')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--���ڻ�Ʊ���������
INSERT INTO #TTMP(MONTHDATE,GNFWFAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) �·�,SUM(fuprice) ���ڻ�Ʊ��������� FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype not IN ('���ڷ�', '���շ�','��������')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--���ʻ�Ʊ����
INSERT INTO #TTMP(MONTHDATE,GJSALESAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) �·�,SUM(price) ���ʻ�Ʊ���� FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=1
AND T1.tickettype NOT IN ('���ڷ�', '���շ�','��������')
AND T1.route NOT LIKE '%����%' 
AND T1.route NOT LIKE '%����%'
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--���ʻ�Ʊ˰��
INSERT INTO #TTMP(MONTHDATE,GJTAX)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) �·�,SUM(tax) ���ʻ�Ʊ˰�� FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=1
AND T1.tickettype NOT IN ('���ڷ�', '���շ�','��������')
AND T1.route NOT LIKE '%����%' 
AND T1.route NOT LIKE '%����%'
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--���ʻ�Ʊ��Ʊ�ܽ��
INSERT INTO #TTMP(MONTHDATE,GJTPAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) �·�,SUM(-T1.totprice) ���ʻ�Ʊ��Ʊ�ܽ�� FROM Topway..tbReti T1 WITH (NOLOCK)
INNER JOIN Topway..tbcash T2 WITH (NOLOCK) ON T1.reno=T2.reti 
WHERE T1.cmpcode = @CMPCODE
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND T2.inf=1
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--���ʻ�Ʊ������������
INSERT INTO #TTMP(MONTHDATE,GJGQAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) �·�,SUM(totprice) ���ʻ�Ʊ������������ FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=1
AND (T1.tickettype IN ('���ڷ�', '���շ�','��������') OR T1.route  LIKE '%����%' OR T1.route LIKE '%����%')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--���ʻ�Ʊ���������
INSERT INTO #TTMP(MONTHDATE,GJFWFAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) �·�,SUM(fuprice) ���ʻ�Ʊ��������� FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=1
AND (T1.tickettype not IN ('���ڷ�', '���շ�','��������') OR T1.route  LIKE '%����%' OR T1.route LIKE '%����%')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--��������
INSERT INTO #TTMP(MONTHDATE,BXAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) �·�,SUM(totprice) �������� FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=-1
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--���ڻ�Ʊ����
INSERT INTO #TTMP(MONTHDATE,GNCOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) �·�, COUNT(ID) ���ڻ�Ʊ���� FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype IN ('����Ʊ','���ڷ�', '���շ�','��������')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND ISNULL(T1.reti,'')='' 
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber



--���ʻ�Ʊ����
INSERT INTO #TTMP(MONTHDATE,GJCOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) �·�,COUNT(ID) ���ʻ�Ʊ���� FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=1
AND (T1.tickettype IN ('����Ʊ','���ڷ�', '���շ�','��������') OR T1.route  LIKE '%����%' OR T1.route LIKE '%����%')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND ISNULL(T1.reti,'')='' 
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--��һ��SHEET
SELECT MONTHDATE �·�,
	SUM(ISNULL(GNSALESAMOUNT,0)) ���ڻ�Ʊ����,--���ڻ�Ʊ����
	SUM(ISNULL(GNTAX,0)) ���ڻ�Ʊ˰��,--���ڻ�Ʊ˰��
	SUM(ISNULL(GNTPAMOUNT,0)) ���ڻ�Ʊ��Ʊ�ܽ��,--���ڻ�Ʊ��Ʊ�ܽ��
	SUM(ISNULL(GNGQAMOUNT,0)) ���ڻ�Ʊ������������,--���ڻ�Ʊ������������
	SUM(ISNULL(GNFWFAMOUNT,0)) ���ڻ�Ʊ���������,
	SUM(ISNULL(GNSALESAMOUNT,0))+SUM(ISNULL(GNTAX,0))+SUM(ISNULL(GNTPAMOUNT,0))+SUM(ISNULL(GNGQAMOUNT,0))+SUM(ISNULL(GNFWFAMOUNT,0)) ���ڻ�Ʊ�ϼ�,--���ڻ�Ʊ�ϼ�
	SUM(ISNULL(GJSALESAMOUNT,0)) ���ʻ�Ʊ����,--���ʻ�Ʊ����
	SUM(ISNULL(GJTAX,0)) ���ʻ�Ʊ˰��,--���ʻ�Ʊ˰��
	SUM(ISNULL(GJTPAMOUNT,0)) ���ʻ�Ʊ��Ʊ�ܽ��,--���ʻ�Ʊ��Ʊ�ܽ��
	SUM(ISNULL(GJGQAMOUNT,0)) ���ʻ�Ʊ������������,--���ʻ�Ʊ������������
	SUM(ISNULL(GJFWFAMOUNT,0)) ���ʻ�Ʊ���������,
	SUM(ISNULL(GJSALESAMOUNT,0)) +SUM(ISNULL(GJTAX,0)) +SUM(ISNULL(GJTPAMOUNT,0)) +	SUM(ISNULL(GJGQAMOUNT,0))+SUM(ISNULL(GJFWFAMOUNT,0)) ���ʻ�Ʊ�ϼ�,--���ʻ�Ʊ�ϼ�
	SUM(ISNULL(BXAMOUNT,0)) ��������,--��������
	---TOTALAMOUNT START
	SUM(ISNULL(GNSALESAMOUNT,0))+SUM(ISNULL(GNTAX,0))+SUM(ISNULL(GNTPAMOUNT,0))+SUM(ISNULL(GNGQAMOUNT,0)) 
	+SUM(ISNULL(GJSALESAMOUNT,0)) +SUM(ISNULL(GJTAX,0)) +SUM(ISNULL(GJTPAMOUNT,0)) +	SUM(ISNULL(GJGQAMOUNT,0)) 
	+SUM(ISNULL(BXAMOUNT,0)) ������,--������
	---TOTALAMOUNT END
	SUM(ISNULL(GNCOUNT,0)) ���ڻ�Ʊ����,--���ڻ�Ʊ����
	SUM(ISNULL(GJCOUNT,0)) ���ʻ�Ʊ����,--���ʻ�Ʊ����
	SUM(ISNULL(GNCOUNT,0)) + SUM(ISNULL(GJCOUNT,0)) ��Ʊ������--��Ʊ������
FROM #TTMP
GROUP BY MONTHDATE

--�ڶ���SHEET
SELECT  T1.[route] �г�,SUM(totprice) ���ڻ�Ʊ����,COUNT(ID) ���ڻ�Ʊ���� ,SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) ���ò�ƽ���ۿ���
FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype NOT IN ('���ڷ�', '���շ�','��������')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.[route] ORDER BY ���ڻ�Ʊ���� DESC

SELECT TOP 10 T1.[route] �г�,SUM(totprice) ���ʻ�Ʊ����,COUNT(ID) ���ʻ�Ʊ���� ,SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) ���ò�ƽ���ۿ���
FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=1
AND T1.tickettype NOT IN ('���ڷ�', '���շ�','��������')
AND T1.route NOT LIKE '%����%' 
AND T1.route NOT LIKE '%����%'
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.[route] ORDER BY ���ʻ�Ʊ���� DESC

--������SHEET
IF OBJECT_ID('TEMPDB..#TTTHIRD') IS NOT NULL
DROP TABLE #TTTHIRD
SELECT DAYSFLAG,SUM(totprice) �ϼ�����,SUM(price) ����˰����,COUNT(1) �ϼ�����,SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) ���ò�ƽ���ۿ��� INTO #TTTHIRD  FROM (
SELECT --T1.coupno,
CASE WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 0 AND 2 THEN 1
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 3 AND 4 THEN 2
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 5 AND 6 THEN 3
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 7 AND 8 THEN 4
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 9 AND 10 THEN 5
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 11 AND 12 THEN 6
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 13 AND 14 THEN 7
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) >14 THEN 8 END DAYSFLAG,
totprice,price,priceinfo 
FROM Topway..tbcash T1 WITH (NOLOCK)
--INNER JOIN ehomsom..tbInfCabincode T2 WITH (NOLOCK) ON T1.ride=T2.code2 AND T1.nclass=T2.cabin
WHERE T1.cmpcode = @CMPCODE
--AND T2.begdate<=T1.[datetime] AND T2.enddate>=T1.[datetime]
--AND ((T2.flightbegdate<=T1.begdate AND T2.flightenddate>=T1.begdate) OR
--(T2.flightbegdate2<=T1.begdate AND T2.flightenddate2>=T1.begdate) OR
--(T2.flightbegdate3<=T1.begdate AND T2.flightenddate3>=T1.begdate) OR
--(T2.flightbegdate4<=T1.begdate AND T2.flightenddate4>=T1.begdate))
--AND T2.cabintype like '%���ò�%'
AND T1.inf=0
AND T1.tickettype NOT IN ('���ڷ�', '���շ�','��������')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
) T
GROUP BY DAYSFLAG

DECLARE @TOTALTHIRDAMOUNT DECIMAL(18,2) 
DECLARE @TOTALTHIRDCOUNT DECIMAL(18,2)  
SELECT @TOTALTHIRDAMOUNT=SUM(�ϼ�����) FROM #TTTHIRD
SELECT @TOTALTHIRDCOUNT=SUM(�ϼ�����) FROM #TTTHIRD

SELECT @TOTALTHIRDAMOUNT ������,@TOTALTHIRDCOUNT ������,DAYSFLAG, 
�ϼ�����,����˰����,�ϼ�����/@TOTALTHIRDAMOUNT ��������,�ϼ�����,�ϼ�����/@TOTALTHIRDCOUNT ��������, ���ò�ƽ���ۿ��� FROM #TTTHIRD


--������SHEET
IF OBJECT_ID('TEMPDB..#TTFOURTH') IS NOT NULL
DROP TABLE #TTFOURTH
SELECT T2.airname,T1.ride,SUM(totprice) �ϼ�����,COUNT(1) �ϼ����� INTO #TTFOURTH FROM Topway..tbcash T1 WITH (NOLOCK)
INNER JOIN ehomsom..tbInfAirCompany T2 WITH (NOLOCK) ON T1.ride=T2.code2
WHERE T1.cmpcode = @CMPCODE
AND T1.inf<>-1
AND T1.tickettype NOT IN ('���ڷ�', '���շ�','��������')
AND T1.route NOT LIKE '%����%' 
AND T1.route NOT LIKE '%����%'
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T2.airname,T1.ride

DECLARE @TOTALFOURTHAMOUNT DECIMAL(18,2) 
DECLARE @TOTALFOURTHCOUNT DECIMAL(18,2)  
SELECT @TOTALFOURTHAMOUNT=SUM(�ϼ�����) FROM #TTFOURTH
SELECT @TOTALFOURTHCOUNT=SUM(�ϼ�����) FROM #TTFOURTH

SELECT @TOTALFOURTHAMOUNT ������,@TOTALFOURTHCOUNT ������,airname ��˾����,ride ��˾������,
�ϼ�����,�ϼ�����/@TOTALFOURTHAMOUNT ��������,�ϼ�����,�ϼ�����/@TOTALFOURTHCOUNT �������� FROM #TTFOURTH
ORDER BY �ϼ����� DESC



--������SHEET
IF OBJECT_ID('TEMPDB..#TTFIFTH') IS NOT NULL
DROP TABLE #TTFIFTH
SELECT T2.airname,T1.ride,SUM(totprice) �ϼ�����,COUNT(1) �ϼ����� INTO #TTFIFTH FROM Topway..tbcash T1 WITH (NOLOCK)
INNER JOIN ehomsom..tbInfAirCompany T2 WITH (NOLOCK) ON T1.ride=T2.code2
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype NOT IN ('���ڷ�', '���շ�','��������')
AND T1.route NOT LIKE '%����%' 
AND T1.route NOT LIKE '%����%'
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T2.airname,T1.ride

DECLARE @TOTALFIFTHAMOUNT DECIMAL(18,2) 
DECLARE @TOTALFIFTHCOUNT DECIMAL(18,2)  
SELECT @TOTALFIFTHAMOUNT=SUM(�ϼ�����) FROM #TTFIFTH
SELECT @TOTALFIFTHCOUNT=SUM(�ϼ�����) FROM #TTFIFTH

SELECT @TOTALFIFTHAMOUNT ������,@TOTALFIFTHCOUNT ������,airname ��˾����,ride ��˾������,
�ϼ�����,�ϼ�����/@TOTALFIFTHAMOUNT ��������,�ϼ�����,�ϼ�����/@TOTALFIFTHCOUNT �������� FROM #TTFIFTH
ORDER BY �ϼ����� DESC

--������SHEET
IF OBJECT_ID('TEMPDB..#TTSIXTH') IS NOT NULL
DROP TABLE #TTSIXTH
SELECT T2.airname,T1.ride,SUM(totprice) �ϼ�����,COUNT(1) �ϼ����� INTO #TTSIXTH FROM Topway..tbcash T1 WITH (NOLOCK)
INNER JOIN ehomsom..tbInfAirCompany T2 WITH (NOLOCK) ON T1.ride=T2.code2
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=1
AND T1.tickettype NOT IN ('���ڷ�', '���շ�','��������')
AND T1.route NOT LIKE '%����%' 
AND T1.route NOT LIKE '%����%'
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T2.airname,T1.ride

DECLARE @TOTALSIXTHAMOUNT DECIMAL(18,2) 
DECLARE @TOTALSIXTHCOUNT DECIMAL(18,2)  
SELECT @TOTALSIXTHAMOUNT=SUM(�ϼ�����) FROM #TTSIXTH
SELECT @TOTALSIXTHCOUNT=SUM(�ϼ�����) FROM #TTSIXTH

SELECT @TOTALSIXTHAMOUNT ������,@TOTALSIXTHCOUNT ������,airname ��˾����,ride ��˾������,
�ϼ�����,�ϼ�����/@TOTALSIXTHAMOUNT ��������,�ϼ�����,�ϼ�����/@TOTALSIXTHCOUNT �������� FROM #TTSIXTH
ORDER BY �ϼ����� DESC


--������SHEET
IF OBJECT_ID('TEMPDB..#TTSEVENTH') IS NOT NULL
DROP TABLE #TTSEVENTH
SELECT CABINFLAG,SUM(price) �ϼ���������˰,SUM(CAST(priceinfo AS DECIMAL)) �ϼ�ȫ�۲���˰,COUNT(1) �ϼ����� INTO #TTSEVENTH  FROM (
SELECT --T1.coupno,
CASE WHEN price/CAST(priceinfo AS DECIMAL) >1 THEN 1
	WHEN price/CAST(priceinfo AS DECIMAL) =1 THEN 2
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.95 AND price/CAST(priceinfo AS DECIMAL) <1 THEN 3
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.90 AND price/CAST(priceinfo AS DECIMAL) <0.95 THEN 4
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.85 AND price/CAST(priceinfo AS DECIMAL) <0.90 THEN 5
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.80 AND price/CAST(priceinfo AS DECIMAL) <0.85 THEN 6
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.75 AND price/CAST(priceinfo AS DECIMAL) <0.80 THEN 7
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.70 AND price/CAST(priceinfo AS DECIMAL) <0.75 THEN 8
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.65 AND price/CAST(priceinfo AS DECIMAL) <0.70 THEN 9
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.60 AND price/CAST(priceinfo AS DECIMAL) <0.65 THEN 10
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.55 AND price/CAST(priceinfo AS DECIMAL) <0.60 THEN 11
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.50 AND price/CAST(priceinfo AS DECIMAL) <0.55 THEN 12
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.45 AND price/CAST(priceinfo AS DECIMAL) <0.50 THEN 13
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.40 AND price/CAST(priceinfo AS DECIMAL) <0.45 THEN 14
	WHEN price/CAST(priceinfo AS DECIMAL) <0.40 THEN 15 END CABINFLAG,
totprice,price,priceinfo 
FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype NOT IN ('���ڷ�', '���շ�','��������')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
) T
GROUP BY CABINFLAG

DECLARE @TOTALSEVENTHAMOUNT DECIMAL(18,2) 
DECLARE @TOTALSEVENTHCOUNT DECIMAL(18,2)  
DECLARE @TOTALSEVENTHFULLAMOUNT DECIMAL(18,2)  
SELECT @TOTALSEVENTHAMOUNT=SUM(�ϼ���������˰) FROM #TTSEVENTH
SELECT @TOTALSEVENTHCOUNT=SUM(�ϼ�����) FROM #TTSEVENTH
SELECT @TOTALSEVENTHFULLAMOUNT=SUM(�ϼ�ȫ�۲���˰) FROM #TTSEVENTH

SELECT @TOTALSEVENTHAMOUNT/@TOTALSEVENTHFULLAMOUNT ƽ���ۿ���,@TOTALSEVENTHAMOUNT ������,@TOTALSEVENTHCOUNT ������,CABINFLAG, 
�ϼ���������˰,�ϼ���������˰/@TOTALSEVENTHAMOUNT ��������,�ϼ�����,�ϼ�����/@TOTALSEVENTHCOUNT �������� FROM #TTSEVENTH
