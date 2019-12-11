
--��λ��Ϣ
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
IF OBJECT_ID('tempdb.dbo.#wjr') IS NOT NULL DROP TABLE #wjr
select CmpId,MaintainName 
into #wjr
from  HM_ThePreservationOfHumanInformation tp where MaintainType=6 and IsDisplay=1
--��Ӫ����
IF OBJECT_ID('tempdb.dbo.#yyjl') IS NOT NULL DROP TABLE #yyjl
select CmpId,MaintainName 
into #yyjl
from  HM_ThePreservationOfHumanInformation tp where MaintainType=9 and IsDisplay=1

IF OBJECT_ID('tempdb.dbo.#p2') IS NOT NULL DROP TABLE #p2
select cmp1.*,wjr.MaintainName as �ھ���,yyjl.MaintainName as ��Ӫ���� 
into #p2
from #cmp1 cmp1
left join #wjr wjr on wjr.cmpid=cmp1.��λ���
left join #yyjl yyjl on yyjl.cmpid=cmp1.��λ���

IF OBJECT_ID('tempdb.dbo.#p3') IS NOT NULL DROP TABLE #p3
select * 
into #p3
from #p2
where ��λ���<>'' and ����״̬ not like ('%��ֹ%') and ��λ����='���õ�λ�ͻ�'


select * from #p3

IF OBJECT_ID('tempdb.dbo.#p4') IS NOT NULL DROP TABLE #p4
SELECT u.cmpid as ��λ���,u.Name as ��λ����,����ҵ�����,��Ӫ����,
case uc.Enabled when 1 then '��' else '��' end as �Ƿ�ͨTMS
--,IsFreeInsurance
--,BindAccidentIntInsurance
into #p4
FROM homsomDB..Trv_UCSettings uc
left join homsomDB..Trv_UnitCompanies u on u.UCSettingID=uc.ID
inner join #p3 p3 on p3.��λ���=u.Cmpid
WHERE 
--IsFreeInsurance=1 --�Ƿ����ͱ���0��1��
 u.Cmpid<>'000003'

select * from #p4







--�����µ���
IF OBJECT_ID('tempdb.dbo.#p5') IS NOT NULL DROP TABLE #p5
SELECT u.Cmpid,u.Name
,case uc.Enabled when 1 then '��' else '��' end as �Ƿ�ͨTMS
,COUNT(*) as �����µ���
into #p5
FROM homsomDB..Trv_CompanyTravels t1
left join homsomDB..Trv_ItktBookings t2 on t2.TravelID=t1.ID
left join homsomDB..Trv_TktBookings t3 on t3.ID=t2.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=t1.UnitCompanyID
left join homsomDB..Trv_UCSettings uc on u.UCSettingID=uc.ID
where t3.CreateDate>='2018-06-01' and t3.CreateDate<'2018-07-01'
and BookingSource in (1,5)
group by u.Cmpid,u.Name,uc.Enabled

--�����µ���
IF OBJECT_ID('tempdb.dbo.#p6') IS NOT NULL DROP TABLE #p6
SELECT u.Cmpid,u.Name
,case uc.Enabled when 1 then '��' else '��' end as �Ƿ�ͨTMS
,COUNT(*) as �����µ���
into #p6
FROM homsomDB..Trv_CompanyTravels t1
left join homsomDB..Trv_ItktBookings t2 on t2.TravelID=t1.ID
left join homsomDB..Trv_TktBookings t3 on t3.ID=t2.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=t1.UnitCompanyID
left join homsomDB..Trv_UCSettings uc on u.UCSettingID=uc.ID
where t3.CreateDate>='2018-06-01' and t3.CreateDate<'2018-07-01'
and BookingSource in (2,3,4)
group by u.Cmpid,u.Name,uc.Enabled


select p4.*,isnull(p5.�����µ���,0)�����µ���,isnull(p6.�����µ���,0)�����µ��� from #p4 p4
left join #p5 p5 on p5.cmpid=p4.��λ���
left join #p6 p6 on p6.cmpid=p4.��λ���



IF OBJECT_ID('tempdb.dbo.#p5') IS NOT NULL DROP TABLE #p5
select c.InsuranceCategory,a.companyname,a.Name,d.CreateDate,e.TravelID,*
--into #p5
from 
homsomDB..Trv_ItktBookings  as b
left join homsomDB..Trv_Passengers  as a on b.ID=a.ItktBookingID
left join homsomDB..Trv_Insurance as c  on a.ID=c.PassengerID
left join homsomDB..Trv_TktBookings as d on d.ID=b.ID
left join homsomDB..Trv_Travels e on e.ID=b.TravelID
where b.TravelID in 
(select ID from homsomDB..Trv_CompanyTravels  where UnitCompanyID in (select id from homsomDB..Trv_UnitCompanies where Cmpid in (
select ��λ��� from #p4)))
and d.CreateDate>='2018-06-01'
and d.AdminStatus=5
--and c.InsuranceCategory <>'����������'
order by c.InsuranceCategory

select * from #p5


select p5.*,p3.����ҵ�����,p3.��Ӫ���� from #p5 p5
inner join #p3 p3 on p3.��λ����=p5.companyname
order by CreateDate

