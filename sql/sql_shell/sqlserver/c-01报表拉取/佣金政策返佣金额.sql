/*����Ҫ��ȡ���к������õ�λ�з�Ӷ����Ϊ�󷵣���λ��/���˺󷵣��Ĺ�˾�����������ֶ����£�

UC�š���λ���ơ��ͻ������ۺ����ܡ����ڻ�ƱӶ�𣨵�λ��/������󷵣�����Ӷ����������ʻ�ƱӶ�𣨵�λ��/������󷵣�����Ӷ��������
���������ĵ�λ
*/


IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid ,t4.ID as ��λID,t1.cmpname 
,(case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' else '' end) as type
,(CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END) as ����״̬
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as ������
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as �ͻ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as ά����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as ����ҵ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as ����ҵ�����
,t4.TerminateReason as ��ֹ����ԭ��
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
where hztype in ('1','2','3') and t1.cmpid not in ('000003','000006')
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate,t4.TerminateReason
order by t1.cmpid

--select * from #cmp1 where cmpid='019604'

--���ڻ�Ʊ������·

--select ID,Name,* from homsomDB..Trv_Dictionaries where Name like '%��%'

-- select * from homsomDB..Trv_Dictionaries where DictionaryType='4' 
-- select ID,* from homsomDB..Trv_FlightNormalPolicies where CommissionTypeID in(select ID from homsomDB..Trv_Dictionaries where Name like '%��%')
-- select UnitCompanyID,* from homsomDB..Trv_FlightTripartitePolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
-- select UnitCompanyID,* from homsomDB..Trv_FlightAdvancedPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
select ID,* from homsomDB..Trv_IntlFlightNormalPolicies where CommissionTypeID in(select ID from homsomDB..Trv_Dictionaries where Name like '%��%')
 
 if OBJECT_ID ('tempdb..#fyje') is not null drop TABLE #fyje
 SELECT UN.Cmpid,D.Name,[Percent] ��Ӷ���л���
 into #fyje
 FROM homsomDB..Trv_RebateRelations  re
 left join homsomDB..Trv_FlightNormalPolicies f1 on f1.ID=re.FlightNormalPolicyID and f1.EndTime>'2019-05-10'
 left join homsomDB..Trv_FlightTripartitePolicies f2 on f2.ID=re.FlightNormalPolicyID and f2.EndTime>'2019-05-10'
 left join homsomDB..Trv_FlightAdvancedPolicies f3 on f3.ID=re.FlightNormalPolicyID  and f3.EndTime>'2019-05-10'
 left join homsomDB..Trv_Dictionaries d on (d.ID=f1.CommissionTypeID or d.ID=f2.CommissionTypeID or d.ID=f3.CommissionTypeID)
 left join homsomDB..Trv_UnitCompanies un on (un.ID=f1.UnitCompanyID or un.ID=f2.UnitCompanyID or un.ID=f3.UnitCompanyID)
 where d.Name like '%��%'
 and un.CooperativeStatus in ('1','2','3')
 and un.Type='A'
 AND [Percent]!=0
 AND d.Name NOT IN ('��λ��+���˺�')
 
 --select * from #fyje
 
 select distinct f.cmpid uc ,cmp.cmpname ��λ����, cmp.TYPE ��λ����, cmp.����״̬,cmp.�ͻ����� �ۺ�����,cmp.ά���� ��Ӫ����,
 f.name ��Ӷ����,f.��Ӷ���л���
 from #fyje f
 left join #cmp1 cmp on Cmp.cmpid=f.cmpid
 
 
 
 --����
 
 select ID,* from homsomDB..Trv_IntlFlightNormalPolicies where CommissionTypeID in(select ID from homsomDB..Trv_Dictionaries where Name like '%��%')
 
 if OBJECT_ID('tempdb..#gjfyje1') is not null drop table #gjfyje1
  SELECT UN.Cmpid,D.Name,[Percent] ��Ӷ���л���
 into #gjfyje1
 FROM homsomDB..Trv_IntlRebateRelations  re
 left join homsomDB..Trv_IntlFlightNormalPolicies f1 on f1.ID=re.FlightNormalPolicyID and f1.EndTime>'2019-04-11'
 left join homsomDB..Trv_Dictionaries d on d.ID=f1.CommissionTypeID 
 left join homsomDB..Trv_UnitCompanies un on un.ID=f1.UnitCompanyID
 where d.Name like '%��%'
 and un.CooperativeStatus in ('1','2','3')
 and un.Type='A'
 AND [Percent]!=0
 AND d.Name not IN ('��λ��+���˺�')
 
 SELECT UN.Cmpid,D.Name,[Percent] ��Ӷ���л���
 --into #gjfyje1
 FROM homsomDB..Trv_IntlRebateRelations  re
 left join homsomDB..Trv_IntlFlightNormalPolicies f1 on f1.ID=re.FlightNormalPolicyID and f1.EndTime>'2019-05-10'
 left join homsomDB..Trv_Dictionaries d on d.ID=f1.CommissionTypeID 
 left join homsomDB..Trv_UnitCompanies un on un.ID=f1.UnitCompanyID
 where d.Name like '%��%'
 and un.CooperativeStatus in ('1','2','3')
 and un.Type='A'
 AND [Percent]!=0
 AND d.Name IN ('��λ��+���˺�')
 
 --select * from #gjfyje1
 
 select distinct f.cmpid uc ,cmp.cmpname ��λ����, cmp.TYPE ��λ����, cmp.����״̬,cmp.�ͻ����� �ۺ�����,cmp.ά���� ��Ӫ����,
 f.name ��Ӷ����,f.��Ӷ���л���
 from #gjfyje1 f
 left join #cmp1 cmp on Cmp.cmpid=f.cmpid
 where f.cmpid not in ('000006')