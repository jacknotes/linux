--�鷳��ȡ2017��3�·�ע����ǰ������6����0���ѵĲ��ÿͻ���������Ҫ��������: UC����λ���ơ�����״̬��ע���¡������ˡ����ù��ʡ�ά���ˡ��ͻ�רԱ��Ӷ������


IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid ,t1.cmpname 
,(case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' else '' end) as type
,(CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END) as ����״̬
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as ������
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as �ͻ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as ά����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as ����ҵ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as ����ҵ�����
,indate
into #cmp1
from tbCompanyM t1
left join homsomdb..Trv_UnitCompanies t4 on t1.cmpid=t4.Cmpid
--������
left join homsomDB..Trv_UnitCompies_Sales t5 on t4.ID=t5.UnitCompayID
--�ͻ�����
left join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t4.ID=t6.UnitCompanyID
--ά����
left join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.UnitCompanyID=t4.ID
--����ҵ�����
left join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t7.TrvUnitCompanyID=t4.ID
--����ҵ�����
left join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t8.TktUnitCompanyID=t4.ID
--��Ա��Ϣ
left join homsomDB..SSO_Users t9 on
t9.ID=t5.EmployeeID and t9.ID=t6.EmployeeID and t9.ID=t8.TktTCID and t9.ID=t7.TrvTCID 
where indate<'2017-07-01'
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid




IF OBJECT_ID('tempdb.dbo.#p1') IS NOT NULL DROP TABLE #p1
select distinct cmpcode into #p1 from tbcash where (datetime>='2017-07-01' and datetime<'2018-01-01')
IF OBJECT_ID('tempdb.dbo.#p2') IS NOT NULL DROP TABLE #p2
select distinct cmpid into #p2 from tbHtlcoupYf where (prdate>='2017-07-01' and prdate<'2018-01-01' and status<>'-2')
IF OBJECT_ID('tempdb.dbo.#p3') IS NOT NULL DROP TABLE #p3
select distinct cmpid into #p3 from tbHotelcoup where (datetime>='2017-07-01' and datetime<'2018-01-01' and status<>'-2')
IF OBJECT_ID('tempdb.dbo.#p4') IS NOT NULL DROP TABLE #p4
select distinct cmpid into #p4 from tbTrvCoup where (OperDate>='2017-07-01' and OperDate<'2018-01-01')
IF OBJECT_ID('tempdb.dbo.#p5') IS NOT NULL DROP TABLE #p5
select distinct cmpid into #p5 from tbConventionCoup where (OperDate>='2017-07-01' and OperDate<'2018-01-01')
IF OBJECT_ID('tempdb.dbo.#p6') IS NOT NULL DROP TABLE #p6
select distinct cmpid into #p6 from tbTrainTicketInfo where (CreateDate>='2017-07-01' and CreateDate<'2018-01-01')

IF OBJECT_ID('tempdb.dbo.#p') IS NOT NULL DROP TABLE #p
CREATE TABLE #P(cmpid VARCHAR(100)) 
INSERT INTO #P(cmpid)
select * from #p1
UNION ALL select * from #p2
UNION ALL select * from #p3
UNION ALL select * from #p4
UNION ALL select * from #p5
UNION ALL select * from #p6





IF OBJECT_ID('tempdb.dbo.#ids') IS NOT NULL DROP TABLE #ids            
SELECT uc.id,uc.cmpid,uc.Name         
INTO #ids        
FROM  homsomDB.dbo.Trv_UnitCompanies uc 

IF OBJECT_ID('tempdb.dbo.#yjzc_gn') IS NOT NULL DROP TABLE #yjzc_gn
SELECT ids.Cmpid,ids.Name, p.Name AS name2,p.StartTime,p.EndTime
	
	,CASE reb.RebateStyle WHEN 1 THEN '��λ' +CASE RebateType WHEN 0 THEN 'ǰ��' WHEN 1 THEN '��' ELSE '' END +CAST(CONVERT(DECIMAL(10,1),reb.[Percent]) AS VARCHAR(10))+'%' 
							ELSE '' END [���ڻ�Ʊ��λ��Ӷ]
	,CASE reb.RebateStyle WHEN 0 THEN '����' +CASE RebateType WHEN 0 THEN 'ǰ��' WHEN 1 THEN '��' ELSE '' END +CAST(CONVERT(DECIMAL(10,1),reb.[Percent]) AS VARCHAR(10))+'%' 
							ELSE '' END [���ڻ�Ʊ���˷�Ӷ]	
	,CASE p.ServiceChargeType WHEN 0 THEN '�����:���Ż�Ʊ'+ CAST(CONVERT(DECIMAL(10,1),p.ServiceCharge) AS VARCHAR(10)) 
		WHEN 1 THEN '�����:����'+ CAST(CONVERT(DECIMAL(10,1),p.ServiceCharge) AS VARCHAR(10)) 
		WHEN 2 THEN '�����:���ۼ�'+ CAST(CONVERT(DECIMAL(10,1),p.ServiceCharge) AS VARCHAR(10))+'%' 
		WHEN 3 THEN '�޷����' ELSE CAST(p.ServiceChargeType AS varchar(100)) END AS [���ڷ����]
INTO #yjzc_gn
FROM #ids ids  
INNER JOIN homsomDB..Trv_FlightNormalPolicies  p ON ids.id=p.UnitCompanyID AND p.CountryType=1
LEFT JOIN homsomDB.dbo.Trv_RebateRelations reb ON p.id=reb.FlightNormalPolicyID
WHERE GETDATE() BETWEEN StartTime AND EndTime --��ǰ����
--WHERE GETDATE() < StartTime --δ��ʼ����
AND  p.Name='���ڻ�Ʊ������·'
ORDER BY ids.Cmpid

select cmp1.*,���ڻ�Ʊ��λ��Ӷ,���ڻ�Ʊ���˷�Ӷ,���ڷ���� from #cmp1 cmp1
left join #yjzc_gn yjzc_gn on yjzc_gn.cmpid=cmp1.cmpid
where cmp1.indate<'2017-07-01' and TYPE='���õ�λ�ͻ�'
and cmp1.cmpid not in (Select * from #p)
order by cmp1.cmpid