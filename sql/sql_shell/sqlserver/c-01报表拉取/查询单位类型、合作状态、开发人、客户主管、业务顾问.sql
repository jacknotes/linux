--��Ʊ��������������

IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select t1.cmpid as ��λ���,t1.cmpname as ��λ����
,(case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' else '' end) as ��λ����
,(CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END) as ����״̬
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as ������
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as �ͻ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as ά����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as ����ҵ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as ����ҵ�����
,indate
into #cmp 
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

select * from #cmp
where ��λ���<>''
and ������ in  ('̸��Ρ','������','��','������','����Ԫ','¥���','������','���컪','������','��','������')

--��Ʊ
select t1.������
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as ����
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as ë�� 
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.��λ���
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where t1.indate>='2017-01-01'
and (t3.datetime>='2017-05-01' and t3.datetime<'2017-06-01')
and ��λ���<>''
group by t1.������
order by t1.������

--�Ƶ�
select t1.������
,sum(h1.price) as �Ƶ�����
,sum(h1.totprofit) as �Ƶ�����
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.��λ��� and h1.status<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where t1.indate>='2017-01-01' and
(h1.prdate>='2017-05-01' and h1.prdate<'2017-06-01') and 
status !='-2'
and ��λ���<>''
group by t1.������
order by t1.������


--����
select t1.������
,SUM(l1.XsPrice) as ��������
,SUM(l1.Profit) as ��������
from #cmp t1
left join tbTrvCoup l1 on l1.Cmpid=t1.��λ���
where t1.indate>='2017-01-01' and
 (l1.OperDate>='2017-05-01' and l1.OperDate<'2017-06-01')
and ��λ���<>''
group by t1.������
order by t1.������


--����
select t1.������
,SUM(c1.XsPrice) as ��������
,SUM(c1.Profit) as ��������
from #cmp t1
left join tbConventionCoup c1 on c1.Cmpid=t1.��λ���
where t1.indate>='2017-01-01' and
 (c1.OperDate>='2017-05-01' and c1.OperDate<'2017-06-01')
and ��λ���<>''
group by t1.������
order by t1.������


--��Ʊ
select t1.������
,FLOOR(isnull(sum(RealPrice + trainU.Fuprice + PrintPrice),0)) -FLOOR(isnull(sum(trainU.RealPrice+r.Fee),0)) as ��Ʊ����
,FLOOR(isnull(Sum(trainU.Fuprice - CASE Tsource WHEN '������' THEN 5 when '�߲�����' then 1 ELSE 0 END),0))+ FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0))as ��Ʊ����
from #cmp t1
left join tbTrainTicketInfo trainO on trainO.CmpId=t1.��λ���
LEFT JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo
left join Train_ReturnTicket r on r.TickOrderDetailID = trainU.ID
where t1.indate>='2017-01-01' and
(trainO.CreateDate>='2017-05-01' and trainO.CreateDate<'2017-06-01')
and (r.AuditTime >='2017-05-01' AND r.AuditTime<'2017-06-01')
and trainO.Isdisplay=0
and ��λ���<>''
group by t1.������
order by t1.������


