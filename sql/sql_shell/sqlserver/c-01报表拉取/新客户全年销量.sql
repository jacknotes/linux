
--���г����۲��Ŀ����ˣ�̸��Ρ�����������������������Ԫ��¥��������Ρ������ɡ��򷽡�κ��巡�½�֣�Ϊ��λ����Ҫ��ȡ 
--�¿ͻ���ע����2017.07.01֮��Ϊ�¿ͻ���2017��7��1��-9��30������������ 

IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
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



--������
IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #kfr
select distinct ������ 
into #kfr
from #cmp1
where ��λ���<>''
and ������ in  ('̸��Ρ','������','��','������','����Ԫ','¥���','������','������','��','κ���','½��','��ɭȪ','�����','����һ','Ǯ�ѻ�')

IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select *
into #cmp
from #cmp1
where ��λ���<>''
and ������ in  ('̸��Ρ','������','��','������','����Ԫ','¥���','������','������','��','κ���','½��','��ɭȪ','�����','����һ','Ǯ�ѻ�')

--��Ʊ
IF OBJECT_ID('tempdb.dbo.#jipiao_new') IS NOT NULL DROP TABLE #jipiao_new
select t1.��λ���
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as ����
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as ����
into #jipiao_new
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.��λ���
left join tbreti t2 on t3.reti=t2.reno and t2.status2<>4
where t1.indate>='2017-01-01'
and (t3.datetime>='2017-01-01' and t3.datetime<'2018-01-01')
and ��λ���<>''
group by t1.��λ���
order by t1.��λ���



IF OBJECT_ID('tempdb.dbo.#tb') IS NOT NULL DROP TABLE #tb
select 
t1.��λ���
,isnull(����,0) tb1
,isnull(����,0) tb2
into #tb
from #cmp t1
left join #jipiao_new jo on jo.��λ���=t1.��λ��� 
order by t1.��λ���

--�Ƶ�ת��

IF OBJECT_ID('tempdb.dbo.#hotel_new') IS NOT NULL DROP TABLE #hotel_new
select t1.��λ���
,sum(h1.price) as �Ƶ�����
,sum(h1.totprofit) as �Ƶ�����
into #hotel_new
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.��λ��� and h1.status<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where t1.indate>='2017-01-01' and
(h1.prdate>='2017-01-01' and h1.prdate<'2018-01-01') and 
status !='-2'
and ��λ���<>''
group by t1.��λ���
order by t1.��λ���



IF OBJECT_ID('tempdb.dbo.#hb') IS NOT NULL DROP TABLE #hb
select 
t1.��λ���
,isnull(�Ƶ�����,0) hb1
,isnull(�Ƶ�����,0) hb2
into #hb
from #cmp t1
left join #hotel_new jo on jo.��λ���=t1.��λ��� 
order by t1.��λ���

--�Ƶ��Ը�


IF OBJECT_ID('tempdb.dbo.#hotel_new_y') IS NOT NULL DROP TABLE #hotel_new_y
select t1.��λ���
,sum(h3.price) as �Ƶ�����
,sum(h3.totprofit) as �Ƶ�����
into #hotel_new_y
from #cmp t1
left join tbHotelcoup h3 on h3.cmpid=t1.��λ��� and h3.status<>-2
left join tbhtlyfchargeoff h4 on h4.coupid=h3.id
where t1.indate>='2017-01-01' and
(h3.datetime>='2017-01-01' and h3.datetime<'2018-01-01') and 
status !='-2'
and ��λ���<>''
group by t1.��λ���
order by t1.��λ���



IF OBJECT_ID('tempdb.dbo.#zb') IS NOT NULL DROP TABLE #zb
select 
t1.��λ���
,isnull(�Ƶ�����,0) zb1
,isnull(�Ƶ�����,0) zb2
into #zb
from #cmp t1
left join #hotel_new_y jo on jo.��λ���=t1.��λ��� 
order by t1.��λ���



--����
IF OBJECT_ID('tempdb.dbo.#trv_new') IS NOT NULL DROP TABLE #trv_new
select t1.��λ���
,SUM(l1.XsPrice) as ��������
,SUM(l1.Profit) as ��������
into #trv_new
from #cmp t1
left join tbTrvCoup l1 on l1.Cmpid=t1.��λ���
where t1.indate>='2017-01-01' and
 (l1.OperDate>='2017-01-01' and l1.OperDate<'2018-01-01')
and ��λ���<>''
group by t1.��λ���
order by t1.��λ���



IF OBJECT_ID('tempdb.dbo.#lb') IS NOT NULL DROP TABLE #lb
select 
t1.��λ���
,isnull(��������,0) lb1
,isnull(��������,0) lb2
into #lb
from #cmp t1
left join #trv_new jo on jo.��λ���=t1.��λ��� 
order by t1.��λ���


--����
IF OBJECT_ID('tempdb.dbo.#con_new') IS NOT NULL DROP TABLE #con_new
select t1.��λ���
,SUM(c1.XsPrice) as ��������
,SUM(c1.Profit) as ��������
into #con_new
from #cmp t1
left join tbConventionCoup c1 on c1.Cmpid=t1.��λ���
where t1.indate>='2017-01-01' and
 (c1.OperDate>='2017-01-01' and c1.OperDate<'2018-01-01')
and ��λ���<>''
group by t1.��λ���
order by t1.��λ���



IF OBJECT_ID('tempdb.dbo.#cb') IS NOT NULL DROP TABLE #cb
select 
t1.��λ���
,isnull(��������,0) cb1
,isnull(��������,0) cb2
into #cb
from #cmp t1
left join #con_new jo on jo.��λ���=t1.��λ��� 
order by t1.��λ���



--��Ʊ
IF OBJECT_ID('tempdb.dbo.#train_new') IS NOT NULL DROP TABLE #train_new
select t1.��λ���
,FLOOR(isnull(sum(RealPrice + trainU.Fuprice + PrintPrice),0)) -FLOOR(isnull(sum(trainU.RealPrice+r.Fee),0)) as ��Ʊ����
,FLOOR(isnull(Sum(trainU.Fuprice - CASE Tsource WHEN '������' THEN 5 when '�߲�����' then 1 ELSE 0 END),0))+ FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0))as ��Ʊ����
into #train_new
from #cmp t1
left join tbTrainTicketInfo trainO on trainO.CmpId=t1.��λ���
LEFT JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo
left join Train_ReturnTicket r on r.TickOrderDetailID = trainU.ID
where t1.indate>='2017-01-01' and
(trainO.CreateDate>='2017-01-01' and trainO.CreateDate<'2018-01-01')
and (r.AuditTime >='2017-01-01' AND r.AuditTime<'2018-01-01')
and trainO.Isdisplay=0
and ��λ���<>''
group by t1.��λ���
order by t1.��λ���



IF OBJECT_ID('tempdb.dbo.#fb') IS NOT NULL DROP TABLE #fb
select 
t1.��λ���
,isnull(��Ʊ����,0) fb1
,isnull(��Ʊ����,0) fb2
into #fb
from #cmp t1
left join #train_new jo on jo.��λ���=t1.��λ��� 
order by t1.��λ���

select cmp.��λ���
,tb1+hb1+zb1+lb1+cb1+fb1 as �¿ͻ�������
,tb2+hb2+zb2+lb2+cb2+fb2 as �¿ͻ�������
,tb.tb1 as �¿ͻ���Ʊ����,tb.tb2 as �¿ͻ���Ʊ����
,hb.hb1 as �¿ͻ�Ԥ���Ƶ�����,hb.hb2 as �¿ͻ�Ԥ���Ƶ�����
,zb.zb1 as �¿ͻ��Ը��Ƶ�����,zb.zb2 as �¿ͻ��Ը��Ƶ�����
,lb.lb1 as �¿ͻ���������,lb.lb2 as �¿ͻ���������
,cb.cb1 as �¿ͻ���������,cb.cb2 as �¿ͻ���������
,fb.fb1 as �¿ͻ���Ʊ����,fb.fb2 as �¿ͻ���Ʊ����
from #cmp cmp
left join #tb tb on tb.��λ���=cmp.��λ���
left join #hb hb on hb.��λ���=cmp.��λ���
left join #zb zb on zb.��λ���=cmp.��λ���
left join #lb lb on lb.��λ���=cmp.��λ���
left join #cb cb on cb.��λ���=cmp.��λ���
left join #fb fb on fb.��λ���=cmp.��λ���
where Cmp.indate>='2017-01-01'



