--�밴ά����(5λ��Ӫ��������ȡ���Ͽͻ����������������󣨻�Ʊ���Ƶ꣩�����Ͽͻ���2017��1��1��Ϊ���ޣ�1��1��ǰΪ�Ͽͻ���

IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as ��λ���,t1.cmpname as ��λ����
,(case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' else '' end) as ��λ����
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
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid

--ά����
IF OBJECT_ID('tempdb.dbo.#whr') IS NOT NULL DROP TABLE #whr
select distinct ά���� 
into #whr
from #cmp1
where ��λ���<>''

IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select * 
into #cmp
from #cmp1
where #cmp1.��λ����='���õ�λ�ͻ�'

--select * from #cmp

--��Ʊ
IF OBJECT_ID('tempdb.dbo.#jipiao') IS NOT NULL DROP TABLE #jipiao
select t1.ά����
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as ����
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as ë�� 
into #jipiao
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.��λ���
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where (t3.datetime>='2016-01-01' and t3.datetime<'2017-01-01')
and ��λ���<>''
group by t1.ά����
order by t1.ά����





--�Ƶ�
IF OBJECT_ID('tempdb.dbo.#hotel') IS NOT NULL DROP TABLE #hotel
select t1.ά����
,sum(h1.price) as �Ƶ�����
,sum(h1.totprofit) as �Ƶ�����
into #hotel
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.��λ��� and h1.status2<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where (h1.prdate>='2016-01-01' and h1.prdate<'2017-01-01') and 
status !='-2'
and ��λ���<>''
group by t1.ά����
order by t1.ά����







--�Ƶ��Ը�
IF OBJECT_ID('tempdb.dbo.#hotel_y') IS NOT NULL DROP TABLE #hotel_y
select t1.ά����
,sum(h3.price) as �Ƶ�����
,sum(h3.totprofit) as �Ƶ�����
into #hotel_y
from #cmp t1
left join tbHotelcoup h3 on h3.cmpid=t1.��λ��� and h3.status<>-2
left join tbhtlyfchargeoff h4 on h4.coupid=h3.id
where (h3.datetime>='2016-01-01' and h3.datetime<'2017-01-01') and 
status !='-2'
and ��λ���<>''
group by t1.ά����
order by t1.ά����



select whr.ά����
,isnull(jipiao.����,0)+isnull(Hotel.�Ƶ�����,0)+isnull(hotel_y.�Ƶ�����,0) as ������
,isnull(jipiao.ë��,0)+isnull(Hotel.�Ƶ�����,0)+isnull(hotel_y.�Ƶ�����,0) as ������
from #whr whr
left join #jipiao jipiao on jipiao.ά����=whr.ά����
left join #hotel hotel on hotel.ά����=whr.ά����
left join #hotel_y hotel_y on hotel_y.ά����=whr.ά����




