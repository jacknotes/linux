--��Ʊ��������������

IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as ��λ���,t1.cmpname as ��λ����
,(case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' else '' end) as ��λ����
,(CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END) as ����״̬
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as ������
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as �ͻ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as ά����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as ����ҵ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as ����ҵ�����
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




IF OBJECT_ID('tempdb.dbo.#wjr') IS NOT NULL DROP TABLE #wjr
select CmpId,MaintainName 
into #wjr
from  HM_ThePreservationOfHumanInformation tp where MaintainType=6 and IsDisplay=1
--��Ӫ����
IF OBJECT_ID('tempdb.dbo.#yyjl') IS NOT NULL DROP TABLE #yyjl
select CmpId,MaintainName 
into #yyjl
from  HM_ThePreservationOfHumanInformation tp where MaintainType=9 and IsDisplay=1
IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select cmp1.*,wjr.MaintainName as �ھ���,yyjl.MaintainName as ��Ӫ���� 
into #cmp
from #cmp1 cmp1
left join #wjr wjr on wjr.cmpid=cmp1.��λ���
left join #yyjl yyjl on yyjl.cmpid=cmp1.��λ���

--select * from #cmp where ��λ���<>''


--���ڻ�Ʊ
IF OBJECT_ID('tempdb.dbo.#gnjp1') IS NOT NULL DROP TABLE #gnjp1
select t1.��λ���,t1.��λ����,t1.��λ����
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as ����
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as ë�� 
,COUNT(*) as ����
into #gnjp1
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.��λ���
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where (t3.datetime>='2018-05-01' and t3.datetime<'2018-06-01')
and ��λ���<>''
and t3.inf=0
group by t1.��λ���,t1.��λ����,t1.��λ����
order by t1.��λ���

IF OBJECT_ID('tempdb.dbo.#gnjp2') IS NOT NULL DROP TABLE #gnjp2
select t1.��λ���,t1.��λ����,t1.��λ����
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as ����
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as ë�� 
,COUNT(*) as ����
into #gnjp2
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.��λ���
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where (t3.datetime>='2018-06-01' and t3.datetime<'2018-07-01')
and ��λ���<>''
and t3.inf=0
group by t1.��λ���,t1.��λ����,t1.��λ����
order by t1.��λ���

--���ʻ�Ʊ
IF OBJECT_ID('tempdb.dbo.#gjjp1') IS NOT NULL DROP TABLE #gjjp1
select t1.��λ���,t1.��λ����,t1.��λ����
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as ����
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as ë�� 
,COUNT(*) as ����
into #gjjp1
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.��λ���
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where (t3.datetime>='2018-05-01' and t3.datetime<'2018-06-01')
and ��λ���<>''
and t3.inf=1
group by t1.��λ���,t1.��λ����,t1.��λ����
order by t1.��λ���

IF OBJECT_ID('tempdb.dbo.#gjjp2') IS NOT NULL DROP TABLE #gjjp2
select t1.��λ���,t1.��λ����,t1.��λ����
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as ����
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as ë�� 
,COUNT(*) as ����
into #gjjp2
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.��λ���
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where (t3.datetime>='2018-06-01' and t3.datetime<'2018-07-01')
and ��λ���<>''
and t3.inf=1
group by t1.��λ���,t1.��λ����,t1.��λ����
order by t1.��λ���


--�Ƶ�
IF OBJECT_ID('tempdb.dbo.#jd1') IS NOT NULL DROP TABLE #jd1
select t1.��λ���
,sum(h1.price) as �Ƶ�����
,sum(h1.totprofit) as �Ƶ�����
,COUNT(*) as ����
into #jd1
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.��λ��� and h1.status2<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where 
(h1.prdate>='2018-05-01' and h1.prdate<'2018-06-01') and 
status !='-2'
and ��λ���<>''
group by t1.��λ���
order by t1.��λ���

IF OBJECT_ID('tempdb.dbo.#jd2') IS NOT NULL DROP TABLE #jd2
select t1.��λ���
,sum(h1.price) as �Ƶ�����
,sum(h1.totprofit) as �Ƶ�����
,COUNT(*) as ����
into #jd2
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.��λ��� and h1.status2<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where 
(h1.prdate>='2018-06-01' and h1.prdate<'2018-07-01') and 
status !='-2'
and ��λ���<>''
group by t1.��λ���
order by t1.��λ���


select Cmp.*
,(isnull(gnjp1.����,0)+isnull(gjjp1.����,0)) as '5�»�Ʊ������'
,(isnull(gnjp2.����,0)+isnull(gjjp2.����,0)) as '6�»�Ʊ������'
,isnull(cast(((isnull(gnjp2.����,0)+isnull(gjjp2.����,0))-(isnull(gnjp1.����,0)+isnull(gjjp1.����,0)))/ABS(nullif(isnull(gnjp1.����,0)+isnull(gjjp1.����,0),0))*100 as varchar(20))+'%','') as ����������
,(isnull(gnjp1.ë��,0)+isnull(gjjp1.ë��,0)) as '5�»�Ʊ������'
,(isnull(gnjp2.ë��,0)+isnull(gjjp2.ë��,0)) as '6�»�Ʊ������'
,isnull(cast(((isnull(gnjp2.ë��,0)+isnull(gjjp2.ë��,0))-(isnull(gnjp1.ë��,0)+isnull(gjjp1.ë��,0)))/ABS(nullif(isnull(gnjp1.ë��,0)+isnull(gjjp1.ë��,0),0))*100 as varchar(20))+'%','') as ���󻷱�
,isnull(gnjp1.����,0) as '5�¹��ڻ�Ʊ����'
,isnull(gnjp2.����,0) as '6�¹��ڻ�Ʊ����'
,isnull((case when gnjp1.����=0 then '' else cast((gnjp2.����-gnjp1.����)/ABS(gnjp1.����)*100 as varchar(20))+'%' end),'') as ���ڻ�Ʊ��������
,isnull(gnjp1.ë��,0) as '5�¹��ڻ�Ʊ����'
,isnull(gnjp2.ë��,0) as '6�¹��ڻ�Ʊ����'
,isnull((case when gnjp1.ë��=0 then '' else cast((gnjp2.ë��-gnjp1.ë��)/ABS(gnjp1.ë��)*100 as varchar(20))+'%' end),'') as ���ڻ�Ʊ���󻷱�
,isnull(gnjp1.����,0) as '5�¹��ڻ�Ʊ����'
,isnull(gnjp2.����,0) as '6�¹��ڻ�Ʊ����'
,(case when gnjp1.����=0 then '' else ((gnjp2.����-gnjp1.����)*1.0/gnjp1.����) end)  as ���ڻ�Ʊ��������
,isnull(gjjp1.����,0) as '5�¹��ʻ�Ʊ����'
,isnull(gjjp2.����,0) as '6�¹��ʻ�Ʊ����'
,isnull((case when gjjp1.����=0 then '' else cast((gjjp2.����-gjjp1.����)/ABS(gjjp1.����)*100 as varchar(20))+'%' end),'') as ���ʻ�Ʊ��������
,isnull(gjjp1.ë��,0) as '5�¹��ʻ�Ʊ����'
,isnull(gjjp2.ë��,0) as '6�¹��ʻ�Ʊ����'
,isnull((case when gjjp1.ë��=0 then '' else cast((gjjp2.ë��-gjjp1.ë��)/ABS(gjjp1.ë��)*100 as varchar(20))+'%' end),'') as ���ʻ�Ʊ���󻷱�
,isnull(gjjp1.����,0) as '5�¹��ʻ�Ʊ����'
,isnull(gjjp2.����,0) as '6�¹��ʻ�Ʊ����'
,(case when gjjp1.����=0 then '' else ((gjjp2.����-gjjp1.����)*1.0/gjjp1.����) end) as ���ʻ�Ʊ��������
,isnull(jd1.�Ƶ�����,0) as '5�¾Ƶ�����'
,isnull(jd2.�Ƶ�����,0) as '6�¾Ƶ�����'
,isnull((case when jd1.�Ƶ�����=0 then '' else cast((jd2.�Ƶ�����-jd1.�Ƶ�����)/ABS(jd1.�Ƶ�����)*100 as varchar(20))+'%' end),'') as �Ƶ���������
,isnull(jd1.�Ƶ�����,0) as '5�¾Ƶ�����'
,isnull(jd2.�Ƶ�����,0) as '6�¾Ƶ�����'
,isnull((case when jd1.�Ƶ�����=0 then '' else cast((jd2.�Ƶ�����-jd1.�Ƶ�����)/ABS(jd1.�Ƶ�����)*100 as varchar(20))+'%' end),'') as �Ƶ����󻷱�
,isnull(jd1.����,0) as '5�¾Ƶ����'
,isnull(jd2.����,0) as '6�¾Ƶ����'
,(case when jd1.����=0 then '' else ((jd2.����-jd1.����)*1.0/jd1.����) end) as �Ƶ��������
from #cmp cmp
left join #gnjp1 gnjp1 on gnjp1.��λ���=Cmp.��λ���
left join #gnjp2 gnjp2 on gnjp2.��λ���=Cmp.��λ���
left join #gjjp1 gjjp1 on gjjp1.��λ���=Cmp.��λ���
left join #gjjp2 gjjp2 on gjjp2.��λ���=Cmp.��λ���
left join #jd1 jd1 on jd1.��λ���=Cmp.��λ���
left join #jd2 jd2 on jd2.��λ���=Cmp.��λ��� 
order by ��λ���






