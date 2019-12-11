

IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as ��λ���,t1.cmpname as ��λ����
,(case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' when 'F' then '����λ�ͻ�' else '' end) as ��λ����
,(CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END) as ����״̬
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as ������
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as �ͻ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as ά����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as ����ҵ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as ����ҵ�����
--,indate
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


IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select *
into #cmp
from #cmp1
where ��λ���<>''

select * from #cmp
order by ��λ���

--��Ʊ
IF OBJECT_ID('tempdb.dbo.#jipiao') IS NOT NULL DROP TABLE #jipiao
select t1.��λ���
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as tb1
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as tb2
into #jipiao
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.��λ���
left join tbreti t2 on t3.reti=t2.reno and t2.status2<>4
where  (t3.datetime>='2017-03-01' and t3.datetime<'2018-03-01')
and ��λ���<>''
group by t1.��λ���
order by t1.��λ���


--�Ƶ�ת��
IF OBJECT_ID('tempdb.dbo.#hotel') IS NOT NULL DROP TABLE #hotel
select t1.��λ���
,sum(h1.price) as hb1
,sum(h1.totprofit) as hb2
into #hotel
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.��λ��� and h1.status<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where 
(h1.prdate>='2017-03-01' and h1.prdate<'2018-03-01') and 
status !='-2'
and ��λ���<>''
group by t1.��λ���
order by t1.��λ���

--�Ƶ��Ը�
IF OBJECT_ID('tempdb.dbo.#hotel_y') IS NOT NULL DROP TABLE #hotel_y
select t1.��λ���
,sum(h3.price) as zb1
,sum(h3.totprofit) as zb2
into #hotel_y
from #cmp t1
left join tbHotelcoup h3 on h3.cmpid=t1.��λ��� and h3.status<>-2
left join tbhtlyfchargeoff h4 on h4.coupid=h3.id
where 
(h3.datetime>='2017-03-01' and h3.datetime<'2018-03-01') and 
status !='-2'
and ��λ���<>''
group by t1.��λ���
order by t1.��λ���

--�����·���
IF OBJECT_ID('tempdb.dbo.#hz') IS NOT NULL DROP TABLE #hz
select CompanyCode,COUNT(*) as hz
into #hz
from AccountStatement 
where AccountPeriodAir1>='2017-03-01' and AccountPeriodAir1<'2018-03-01'
group by CompanyCode


select cmp.*
,isnull(tb1,0)+isnull(hb1,0)+isnull(zb1,0) as �ͻ�������
,isnull(tb2,0)+isnull(hb2,0)+isnull(zb2,0) as �ͻ�������
,isnull(hz,0) as �����·���
from #cmp cmp
left join #jipiao tb on tb.��λ���=Cmp.��λ���
left join #hotel hb on hb.��λ���=Cmp.��λ���
left join #hotel_y zb on zb.��λ���=Cmp.��λ���
left join #hz hz on hz.CompanyCode=Cmp.��λ���
order by Cmp.��λ���

