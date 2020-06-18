/*
 
����Ҫ���Ǹ��������ͻ�������ȥ�����æ�ṩ������ͨ����Ʊ�ۡ��ĵ�λ���ݵ���������Ӧ���������Ӫ����лл��
 
 UC��  ��λ����     �����    �Ƿ�������   MU������F ��J ��Y����   MU������Y����������  ���ù���  ��Ӫ����  �ͻ�����
 
��ע����ǩ���������ĵ�λȥ����
������  15:46:21
B M E K L N R S V T Z H

select * FROM [homsomdb].[dbo].[Trv_UCSettings]
  where BindAccidentInsurance is not null and BindAccidentInsurance <>''
*/

IF OBJECT_ID('tempdb.dbo.#company') IS NOT NULL DROP TABLE #company
SELECT 
u.Cmpid,
u.Name,
CASE WHEN ISNULL(BindAccidentInsurance,'')='' THEN '��' ELSE '��' END �Ƿ�������
INTO #company
FROM homsomDB..Trv_UnitCompanies u 
LEFT JOIN homsomDB..Trv_UCSettings s ON u.UCSettingID=s.ID
WHERE 
IsSepPrice=0 --����
AND CooperativeStatus NOT IN(0,4) AND u.Type='A'

IF OBJECT_ID('tempdb.dbo.#xlgaocang') IS NOT NULL DROP TABLE #xlgaocang
SELECT 
cmpcode,SUM(totprice) AS totprice,SUM(price+tax) AS pricetax 
INTO #xlgaocang
FROM tbcash WHERE datetime BETWEEN '2019-01-01' AND '2019-06-30' AND cmpcode<>'' 
AND nclass IN('F','J','Y') AND cmpcode IN(SELECT cmpid FROM #company) AND inf IN('0')
GROUP BY cmpcode

IF OBJECT_ID('tempdb.dbo.#xldicang') IS NOT NULL DROP TABLE #xldicang
SELECT  cmpcode,SUM(totprice) AS totprice,SUM(price+tax) AS pricetax 
INTO #xldicang
FROM tbcash WHERE datetime BETWEEN '2019-01-01' AND '2019-06-30' AND cmpcode<>'' 
AND nclass IN('B','M','E','K','L','N','R','S','V','T','Z','H') AND cmpcode IN(SELECT cmpid FROM #company) AND inf IN('0')
GROUP BY cmpcode



IF OBJECT_ID('tempdb.dbo.#Final') IS NOT NULL DROP TABLE #Final
SELECT 'UC'+c.Cmpid AS '��λ���',
c.Name AS '��λ����',
c.�Ƿ�������,
CONVERT(DECIMAL(18,1),ISNULL(g.totprice,0)) AS '�߲�����',
CONVERT(DECIMAL(18,1),ISNULL(d.totprice,0))  AS '�Ͳ�����',
t.TcName AS ���ù���,
h.MaintainName AS ��Ӫ����,
h1.MaintainName AS �ͻ�����,
i.GroupName AS С���� 
INTO #Final
FROM #company c
LEFT JOIN #xlgaocang g ON c.Cmpid=g.cmpcode
LEFT JOIN #xldicang d ON c.Cmpid=d.cmpcode
LEFT JOIN dbo.HM_AgreementCompanyTC t ON c.Cmpid=t.Cmpid AND t.isDisplay=0 AND t.TcType=0
LEFT JOIN dbo.HM_ThePreservationOfHumanInformation h ON c.Cmpid=h.Cmpid AND h.IsDisplay=1 AND h.MaintainType=9
LEFT JOIN dbo.HM_ThePreservationOfHumanInformation h1 ON c.Cmpid=h1.Cmpid AND h1.IsDisplay=1 AND h1.MaintainType=1
LEFT JOIN dbo.Emppwd e ON t.TcName=e.empname
LEFT JOIN dbo.HM_TCGroupInfo i ON e.groupid=i.Pkey
ORDER BY i.GroupName

--��ǩ���������ĵ�λ
if OBJECT_ID('tempdb..#zq') is not null drop table #zq
select top 2172 convert(varchar(10),NewEndTime,120) ����,NewEndTime,Cmpid 
into #zq
from homsomDB..Trv_FlightTripartitePolicies t
left join homsomDB..Trv_UnitCompanies u on u.ID=t.UnitCompanyID
where (t.Name like '%����%' or t.Name like '%����%' or t.Name like '%sme%' )
and u.Type='a' and u.CooperativeStatus not in ('0','4')
order by ���� desc

SELECT * FROM #Final f WHERE f.��λ��� NOT IN(select 'UC'+x.CmpId from ehomsom..tbCompanyXY x 
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=x.CmpId
where x.Type=1 and IsSelfRv=1 and CooperativeStatus not in ('0','4')
and u.Type='A') 