--�Ƶ����۵����� �����ܼ������Ϊ20
select sprice,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set sprice=20
where CoupNo='PTW078737'

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash where coupno='AS002339560'

--�˹���Ʊԭ�򣨺���ֱ�ӡ����֣�
select datetime as ��Ʊ����,begdate as ���ʱ��,coupno as ���۵���,tcode+ticketno as Ʊ��,t2.route as ����,nclass as ��λ,ride+flightno as �����,cmpcode as ��λ���,quota1 as �����,totprice as ���ۼ�,t2.profit-Mcost as ��������,t2.sales as ����ҵ�����,t2.SpareTC as ����ҵ�����,t2.reti as ��Ʊ���� 
from homsomDB..Trv_DomesticTicketRecord t1
left join topway..tbcash t2 on t2.coupno=t1.RecordNumber
where TicketOperationRemark like ('%ֱ��%') and t2.t_source='HSBSPETD'
and nclass='B'
and ride='EU'

--���в��õ�λ�ͻ��Ĺ��ڱ���ƾ֤
IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as ��λ���,t1.cmpname as ��λ����
,(case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' else '' end) as ��λ����
,(CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END) as ����״̬
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as ������
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as �ۺ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as ά����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as ����ҵ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as ����ҵ�����
,case t4.CertificateI when 0 then '��' when 1 then '�г̵�' when 2 then '��Ʊ' else '' end as ���ʱ���ƾ֤,case t4.CertificateD when 0 then '��' when 1 then '�г̵�' when 2 then '��Ʊ' else '' end as ���ڱ���ƾ֤
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
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate,t4.CertificateI,t4.CertificateD
order by t1.cmpid


select * from #cmp1

--�ھ���
IF OBJECT_ID('tempdb.dbo.#wjr') IS NOT NULL DROP TABLE #wjr
select CmpId,MaintainName 
into #wjr
from  HM_ThePreservationOfHumanInformation tp where MaintainType=6 and IsDisplay=1
--��Ӫ����
IF OBJECT_ID('tempdb.dbo.#yyjl') IS NOT NULL DROP TABLE #yyjl
select CmpId,MaintainName 
into #yyjl
from  HM_ThePreservationOfHumanInformation tp where MaintainType=9 and IsDisplay=1

select cmp1.*,wjr.MaintainName as �ھ���,yyjl.MaintainName as ��Ӫ���� from #cmp1 cmp1
left join #wjr wjr on wjr.cmpid=cmp1.��λ���
left join #yyjl yyjl on yyjl.cmpid=cmp1.��λ���
where ��λ����='���õ�λ�ͻ�'
and cmp1.��λ���<>'000003'
and cmp1.��λ���<>'000006'


--��λ�ͻ����Ŷ�ȵ���
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement set SX_TotalCreditLine=240000
where BillNumber='017940_20190301'

--����Ԥ�㵥��Ϣ
select Sales,OperName,introducer,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Sales='��֮��',OperName='0481��֮��',introducer='��֮��-0481-��Ӫ��'
where ConventionId in ('1323',
'1308',
'1345',
'1340',
'1307',
'1358',
'1316',
'1309',
'1305',
'1306',
'1344',
'1331',
'1372',
'1232',
'1366',
'1313',
'1315',
'1314',
'1351',
'1079',
'1332',
'1138',
'938',
'1096',
'1260',
'1246',
'1330',
'1061',
'1239',
'1334',
'1247',
'1120',
'1122',
'1063',
'1216',
'1141',
'1093',
'1073',
'1270')

--����Ԥ�㵥
select Sales,OperName,introducer,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Sales='��֮��',OperName='0481��֮��',introducer='��֮��-0481-��Ӫ��'
where ConventionId='1242'

select co.Name,c.DepName,* from homsomDB..Trv_UnitPersons u
left join homsomDB..Trv_Human h  on u.id=h.ID
left join homsomDB..Trv_CompanyStructure c on u.CompanyDptId=c.ID
left join homsomDB..Trv_CostCenter co on u.CostCenterID=co.ID
where u.CompanyID=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='019234')
and co.Name='�Ϻ�����Ļ��������޹�˾'

select * from homsomDB..Trv_UnitCompanies where Cmpid='019234'

--�޸ĳɱ����ĺͲ���
update homsomDB..Trv_UnitPersons set CostCenterID=(select top 1 a.ID from homsomDB..Trv_CostCenter  a left join homsomDB..Trv_UnitPersons b on a.ID=b.CostCenterID where b.CompanyID='C83C1A4F-59CD-49A2-BE9A-A4B20114A73A' and a.Name='�Ϻ�����Ļ��������޹�˾') where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='Ҷ����' and up.companyid='C83C1A4F-59CD-49A2-BE9A-A4B20114A73A')