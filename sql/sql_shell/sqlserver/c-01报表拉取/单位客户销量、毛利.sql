--��Ʊ��������������
select t1.cmpcode as ��λ���,t3.cmpname as ��λ����
,case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' else '' end as ��λ����,
CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END as ����״̬
,(select top 1t9.name from homsomDB..SSO_Users t9 left join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as ������
,(select top 1t9.name from homsomDB..SSO_Users t9 left join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as �ͻ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 left join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as ����ҵ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 left join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as ����ҵ�����
,SUM(ISNULL(t1.totprice,0)-ISNULL(t2.totprice,0))����
,SUM(ISNULL(t1.profit,0)+ISNULL(t2.profit,0))ë��
,COUNT(1) as ����
 from tbcash t1
--��Ʊ
left join tbreti t2 on t1.coupno=t2.coupno
--��λ
left join tbCompanyM t3 on t1.cmpcode=t3.cmpid
--TMS
left join homsomdb..Trv_UnitCompanies t4 on t1.cmpcode=t4.Cmpid
--������
left join homsomDB..Trv_UnitCompies_Sales t5 on t4.ID=t5.UnitCompayID
--�ͻ�����
left join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t4.ID=t6.UnitCompanyID
--����ҵ�����
left join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t7.TrvUnitCompanyID=t4.ID
--����ҵ�����
left join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t8.TktUnitCompanyID=t4.ID
--��Ա��Ϣ
left join homsomDB..SSO_Users t9 on
t9.ID=t5.EmployeeID and t9.ID=t6.EmployeeID and t9.ID=t8.TktTCID and t9.ID=t7.TrvTCID 
where t3.CustomerType='A' 
--and t1.inf=1 
--and (t1.datetime>='2016-10-01' and t1.datetime<'2016-11-01')
group by t1.cmpcode,t3.cmpname,CustomerType,hztype,t4.id
order by t1.cmpcode

--�Ƶ����������󡢼���
select cmpid,sum(price)����,sum(totprofit)ë��,sum(pcs)���� 
from tbHtlcoupYf
where (prdate>='2016-10-01' and prdate<'2016-11-01')
and status !='-2'
group by cmpid


