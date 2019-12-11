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

select * from #cmp1

select cmpid,��λID,cmpname,ά���� �ͻ�����, �ͻ����� �ۺ�����,(case RebateStyle when 1 then '���˺�' when 0 then '��λ��' else '' end ) ��Ӷ����,[percent]/100 �󷵱��� 
from #cmp1 cmp
left join homsomDB..Trv_FlightNormalPolicies f on f.UnitCompanyID=Cmp.��λID
left join homsomDB..Trv_RebateRelations re on re.FlightNormalPolicyID=f.ID
where f.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'

/*
����Ҫ��ȡ���к������õ�λ�з�Ӷ����Ϊ�󷵣���λ��/���˺󷵣��Ĺ�˾�����������ֶ����£�

UC�š���λ���ơ��ͻ������ۺ����ܡ����ڻ�ƱӶ�𣨵�λ��/������󷵣�����Ӷ����������ʻ�ƱӶ�𣨵�λ��/������󷵣�����Ӷ�������
*/
--��ӶID
--select * from homsomDB..Trv_Dictionaries where DictionaryType='4'
--select top 10 Cmpid,* from homsomDB..Trv_UnitCompanies 
--select * from #cmp1

--��λ����
IF OBJECT_ID('tempdb.dbo.#cmp2') IS NOT NULL DROP TABLE #cmp2
 select un.Cmpid ,un.Name
 into #cmp2
 from homsomDB..Trv_UnitCompanies un
 left join homsomDB..Trv_FlightNormalPolicies f1 on f1.UnitCompanyID=un.ID and f1.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 left join homsomDB..Trv_FlightTripartitePolicies f2 on f2.UnitCompanyID=un.ID and f2.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 left join homsomDB..Trv_FlightAdvancedPolicies f3 on f3.UnitCompanyID=un.ID and f3.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 where un.Type='A'
 and CooperativeStatus in ('1','2','3')

--���ڻ�Ʊ������·
 
select Cmpid,(case RebateStyle when 1 then '���˺�' when 0 then '��λ��' else '' end ) ��Ӷ����,[percent]/100 �󷵱���
from  homsomDB..Trv_FlightNormalPolicies f
left join homsomDB..Trv_UnitCompanies un on un.ID=f.UnitCompanyID
left join homsomDB..Trv_RebateRelations re on re.FlightNormalPolicyID=f.ID
where f.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034' 
and CooperativeStatus in ('1','2','3')
and Type='A'
 
 --������·
 select Cmpid,(case RebateStyle when 1 then '���˺�' when 0 then '��λ��' else '' end ) ��Ӷ����,[percent]/100 �󷵱���
from  homsomDB..Trv_FlightAdvancedPolicies f
left join homsomDB..Trv_UnitCompanies un on un.ID=f.UnitCompanyID
left join homsomDB..Trv_RebateRelations re on re.FlightNormalPolicyID=f.ID
where f.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
and CooperativeStatus in ('1','2','3')
and Type='A'
 

--����
  select Cmpid,(case RebateStyle when 1 then '���˺�' when 0 then '��λ��' else '' end ) ��Ӷ����,[percent]/100 �󷵱���
from  homsomDB..Trv_IntlFlightNormalPolicies f
left join homsomDB..Trv_UnitCompanies un on un.ID=f.UnitCompanyID
left join homsomDB..Trv_IntlRebateRelations re on re.FlightNormalPolicyID=f.ID
where f.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
and CooperativeStatus in ('1','2','3')
and Type='A'
and Cmpid not in ('000003','000006')
 
 
 
 --select * from #cmp2
 
 select cmp2.Cmpid UC��,cmp2.Name ��λ����,'' ���ڻ�ƱӶ��,cmp1.ά���� ��Ӫ����,cmp1.�ͻ����� �ۺ�����
 into #cmp3
 from #cmp2 cmp2
 inner join #cmp1 cmp1 on cmp1.Cmpid=cmp2.Cmpid
 where cmp2.Cmpid not in ('000003','000006')
 
 select * from #cmp3
 
 select UnitCompanyID,* from homsomDB..Trv_FlightNormalPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 select UnitCompanyID,* from homsomDB..Trv_FlightTripartitePolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 select UnitCompanyID,* from homsomDB..Trv_FlightAdvancedPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 SELECT * FROM homsomDB..Trv_RebateRelations where FlightNormalPolicyID in('13F5540F-18EB-4679-9860-4894BE5F5C7F','DE53A099-EDA9-4D28-894D-A48A0102E022')
 
 --����
 select * from homsomDB..Trv_IntlFlightNormalPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 
 select status2,* from Topway..tbReti where reno='0431240'
