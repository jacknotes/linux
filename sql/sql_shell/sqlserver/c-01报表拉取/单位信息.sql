IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as ��λ���,t1.cmpname as ��λ����
,(case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' else '' end) as ��λ����
,(CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END) as ����״̬
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as ������
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as �ۺ�����
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
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid





--�ھ���
IF OBJECT_ID('tempdb.dbo.#yskj') IS NOT NULL DROP TABLE #yskj
select CmpId,MaintainName 
into #yskj
from  HM_ThePreservationOfHumanInformation tp where MaintainType=2 and IsDisplay=1
--��Ӫ����
IF OBJECT_ID('tempdb.dbo.#yyjl') IS NOT NULL DROP TABLE #yyjl
select CmpId,MaintainName 
into #yyjl
from  HM_ThePreservationOfHumanInformation tp where MaintainType=9 and IsDisplay=1

IF OBJECT_ID('tempdb.dbo.#p3') IS NOT NULL DROP TABLE #p3
select cmp1.*,yskj.MaintainName as Ӧ�ջ��,yyjl.MaintainName as ��Ӫ���� 
into #p3
from #cmp1 cmp1
left join #yskj yskj on yskj.cmpid=cmp1.��λ���
left join #yyjl yyjl on yyjl.cmpid=cmp1.��λ���

--IF OBJECT_ID('tempdb.dbo.#p3') IS NOT NULL DROP TABLE #p3
--select * 
--into #p3
--from #p2
--where ��λ���<>'' and ����״̬ not like ('%��ֹ%')




--�˵�����
--IF OBJECT_ID('tempdb.dbo.#p4') IS NOT NULL DROP TABLE #p4
--select CompanyCode,SettlementTypeAir 
--into #p4
--from AccountStatement where AccountPeriodAir1<=GETDATE() AND AccountPeriodAir2>=GETDATE()


------------��������
IF OBJECT_ID('tempdb.dbo.#p4') IS NOT NULL DROP TABLE #p4
SELECT     CmpId,SettleMentManner
into #p4
FROM         HM_SetCompanySettleMentManner
WHERE     SStartDate<=GETDATE() AND SEndDate>=GETDATE() and Type=0 and Status=1
-------------


IF OBJECT_ID('tempdb.dbo.#p5') IS NOT NULL DROP TABLE #p5
select CmpId,DuiZhang1,DuiZhang2
into #p5
from  HM_CompanyAccountInfo where PstartDate<=GETDATE() and PendDate>=GETDATE()

IF OBJECT_ID('tempdb.dbo.#p6') IS NOT NULL DROP TABLE #p6
select p3.*,p4.SettleMentManner,p5.duizhang1,p5.duizhang2 
into #p6
from #p3 p3
left join #p4 p4 on p4.cmpid=p3.��λ���
left join #p5 p5 on p5.cmpid=p3.��λ���

select ��λ���,��λ����,duizhang1 as �˵�����,duizhang2 as ��������,SettleMentManner as ���㷽ʽ,Ӧ�ջ��,����ҵ�����,ά����,�ۺ�����,��Ӫ����,������,����״̬ 
from #p6
where ��λ���<>''


