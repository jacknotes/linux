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
where hztype not in (0,4)
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid

--ά����
IF OBJECT_ID('tempdb.dbo.#whr') IS NOT NULL DROP TABLE #whr
select distinct ά���� 
into #whr
from #cmp1
where ��λ���<>''
and ά���� in ('����','������','Ҧ�ϻ�','�Ƽ���')

IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select * 
into #cmp
from #cmp1
where ά���� in ('����','������','Ҧ�ϻ�','�Ƽ���')
and ��λ����='���õ�λ�ͻ�'

--select * from #cmp

--��Ʊ
IF OBJECT_ID('tempdb.dbo.#jipiao_old') IS NOT NULL DROP TABLE #jipiao_old
select t1.ά����
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as ����
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as ë�� 
into #jipiao_old
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.��λ���
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where t1.indate<'2018-01-01'
and (t3.datetime>='2018-09-01' and t3.datetime<'2018-10-01')
and ��λ���<>''
group by t1.ά����
order by t1.ά����

IF OBJECT_ID('tempdb.dbo.#jipiao_new') IS NOT NULL DROP TABLE #jipiao_new
select t1.ά����
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as ����
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as ë�� 
into #jipiao_new
from #cmp t1
left join tbcash t3 on t3.cmpcode=t1.��λ���
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where t1.indate>='2018-01-01'
and (t3.datetime>='2018-09-01' and t3.datetime<'2018-10-01')
and ��λ���<>''
group by t1.ά����
order by t1.ά����


IF OBJECT_ID('tempdb.dbo.#ta') IS NOT NULL DROP TABLE #ta
IF OBJECT_ID('tempdb.dbo.#tb') IS NOT NULL DROP TABLE #tb
--�Ͽͻ�
select 
t1.ά����
,isnull(����,0) ta1
,isnull(ë��,0) ta2
into #ta
from #whr t1
left join #jipiao_old jo on jo.ά����=t1.ά���� 
order by t1.ά����
--�¿ͻ�
select 
t1.ά����
,isnull(����,0) tb1
,isnull(ë��,0) tb2
into #tb
from #whr t1
left join #jipiao_new jo on jo.ά����=t1.ά���� 
order by t1.ά����

--�Ƶ�
IF OBJECT_ID('tempdb.dbo.#hotel_old') IS NOT NULL DROP TABLE #hotel_old
select t1.ά����
,sum(h1.price) as �Ƶ�����
,sum(h1.totprofit) as �Ƶ�����
into #hotel_old
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.��λ��� and h1.status2<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where t1.indate<'2018-01-01' and
(h1.prdate>='2018-09-01' and h1.prdate<'2018-10-01') and 
status !='-2'
and ��λ���<>''
group by t1.ά����
order by t1.ά����

IF OBJECT_ID('tempdb.dbo.#hotel_new') IS NOT NULL DROP TABLE #hotel_new
select t1.ά����
,sum(h1.price) as �Ƶ�����
,sum(h1.totprofit) as �Ƶ�����
into #hotel_new
from #cmp t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.��λ��� and h1.status2<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where t1.indate>='2018-01-01' and
(h1.prdate>='2018-09-01' and h1.prdate<'2018-10-01') and 
status !='-2'
and ��λ���<>''
group by t1.ά����
order by t1.ά����


IF OBJECT_ID('tempdb.dbo.#ha') IS NOT NULL DROP TABLE #ha
IF OBJECT_ID('tempdb.dbo.#hb') IS NOT NULL DROP TABLE #hb
--�Ͽͻ�
select 
t1.ά����
,isnull(�Ƶ�����,0) ha1
,isnull(�Ƶ�����,0) ha2
into #ha
from #whr t1
left join #hotel_old jo on jo.ά����=t1.ά���� 
order by t1.ά����
--�¿ͻ�
select 
t1.ά����
,isnull(�Ƶ�����,0) hb1
,isnull(�Ƶ�����,0) hb2
into #hb
from #whr t1
left join #hotel_new jo on jo.ά����=t1.ά���� 
order by t1.ά����


--�Ƶ��Ը�
IF OBJECT_ID('tempdb.dbo.#hotel_old_y') IS NOT NULL DROP TABLE #hotel_old_y
select t1.ά����
,sum(h3.price) as �Ƶ�����
,sum(h3.totprofit) as �Ƶ�����
into #hotel_old_y
from #cmp t1
left join tbHotelcoup h3 on h3.cmpid=t1.��λ��� and h3.status<>-2
left join tbhtlyfchargeoff h4 on h4.coupid=h3.id
where t1.indate<'2018-01-01' and
(h3.datetime>='2018-09-01' and h3.datetime<'2018-10-01') and 
status !='-2'
and ��λ���<>''
group by t1.ά����
order by t1.ά����

IF OBJECT_ID('tempdb.dbo.#hotel_new_y') IS NOT NULL DROP TABLE #hotel_new_y
select t1.ά����
,sum(h3.price) as �Ƶ�����
,sum(h3.totprofit) as �Ƶ�����
into #hotel_new_y
from #cmp t1
left join tbHotelcoup h3 on h3.cmpid=t1.��λ��� and h3.status<>-2
left join tbhtlyfchargeoff h4 on h4.coupid=h3.id
where t1.indate>='2018-01-01' and
(h3.datetime>='2018-09-01' and h3.datetime<'2018-10-01') and 
status !='-2'
and ��λ���<>''
group by t1.ά����
order by t1.ά����

IF OBJECT_ID('tempdb.dbo.#za') IS NOT NULL DROP TABLE #za
IF OBJECT_ID('tempdb.dbo.#zb') IS NOT NULL DROP TABLE #zb
--�Ͽͻ�
select 
t1.ά����
,isnull(�Ƶ�����,0) za1
,isnull(�Ƶ�����,0) za2
into #za
from #whr t1
left join #hotel_old_y jo on jo.ά����=t1.ά���� 
order by t1.ά����
--�¿ͻ�
select 
t1.ά����
,isnull(�Ƶ�����,0) zb1
,isnull(�Ƶ�����,0) zb2
into #zb
from #whr t1
left join #hotel_new_y jo on jo.ά����=t1.ά���� 
order by t1.ά����


--����
IF OBJECT_ID('tempdb.dbo.#trv_old') IS NOT NULL DROP TABLE #trv_old
select t1.ά����
,SUM(l1.XsPrice) as ��������
,SUM(l1.Profit) as ��������
into #trv_old
from #cmp t1
left join tbTrvCoup l1 on l1.Cmpid=t1.��λ���
where t1.indate<'2018-01-01' and
 (l1.OperDate>='2018-09-01' and l1.OperDate<'2018-10-01')
and ��λ���<>''
group by t1.ά����
order by t1.ά����

IF OBJECT_ID('tempdb.dbo.#trv_new') IS NOT NULL DROP TABLE #trv_new
select t1.ά����
,SUM(l1.XsPrice) as ��������
,SUM(l1.Profit) as ��������
into #trv_new
from #cmp t1
left join tbTrvCoup l1 on l1.Cmpid=t1.��λ���
where t1.indate>='2018-01-01' and
 (l1.OperDate>='2018-09-01' and l1.OperDate<'2018-10-01')
and ��λ���<>''
group by t1.ά����
order by t1.ά����


IF OBJECT_ID('tempdb.dbo.#la') IS NOT NULL DROP TABLE #la
IF OBJECT_ID('tempdb.dbo.#lb') IS NOT NULL DROP TABLE #lb
--�Ͽͻ�
select 
t1.ά����
,isnull(��������,0) la1
,isnull(��������,0) la2
into #la
from #whr t1
left join #trv_old jo on jo.ά����=t1.ά���� 
order by t1.ά����
--�¿ͻ�
select 
t1.ά����
,isnull(��������,0) lb1
,isnull(��������,0) lb2
into #lb
from #whr t1
left join #trv_new jo on jo.ά����=t1.ά���� 
order by t1.ά����


--����
IF OBJECT_ID('tempdb.dbo.#con_old') IS NOT NULL DROP TABLE #con_old
select t1.ά����
,SUM(c1.XsPrice) as ��������
,SUM(c1.Profit) as ��������
into #con_old
from #cmp t1
left join tbConventionCoup c1 on c1.Cmpid=t1.��λ���
where t1.indate<'2018-01-01' and
 (c1.OperDate>='2018-09-01' and c1.OperDate<'2018-10-01')
and ��λ���<>''
group by t1.ά����
order by t1.ά����

IF OBJECT_ID('tempdb.dbo.#con_new') IS NOT NULL DROP TABLE #con_new
select t1.ά����
,SUM(c1.XsPrice) as ��������
,SUM(c1.Profit) as ��������
into #con_new
from #cmp t1
left join tbConventionCoup c1 on c1.Cmpid=t1.��λ���
where t1.indate>='2018-01-01' and
 (c1.OperDate>='2018-09-01' and c1.OperDate<'2018-10-01')
and ��λ���<>''
group by t1.ά����
order by t1.ά����


IF OBJECT_ID('tempdb.dbo.#ca') IS NOT NULL DROP TABLE #ca
IF OBJECT_ID('tempdb.dbo.#cb') IS NOT NULL DROP TABLE #cb
--�Ͽͻ�
select 
t1.ά����
,isnull(��������,0) ca1
,isnull(��������,0) ca2
into #ca
from #whr t1
left join #con_old jo on jo.ά����=t1.ά���� 
order by t1.ά����
--�¿ͻ�
select 
t1.ά����
,isnull(��������,0) cb1
,isnull(��������,0) cb2
into #cb
from #whr t1
left join #con_new jo on jo.ά����=t1.ά���� 
order by t1.ά����



--��Ʊ
IF OBJECT_ID('tempdb.dbo.#train_old') IS NOT NULL DROP TABLE #train_old
select t1.ά����
,FLOOR(isnull(sum(RealPrice + trainU.Fuprice + PrintPrice),0)) -FLOOR(isnull(sum(trainU.RealPrice+r.Fee),0)) as ��Ʊ����
,FLOOR(isnull(Sum(trainU.Fuprice - CASE Tsource WHEN '������' THEN 5 when '�߲�����' then 1 ELSE 0 END),0))+ FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0))as ��Ʊ����
into #train_old
from #cmp t1
left join tbTrainTicketInfo trainO on trainO.CmpId=t1.��λ���
LEFT JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo
left join Train_ReturnTicket r on r.TickOrderDetailID = trainU.ID
where t1.indate<'2018-01-01' and
(trainO.CreateDate>='2018-09-01' and trainO.CreateDate<'2018-10-01')
and (r.AuditTime >='2018-09-01' AND r.AuditTime<'2018-10-01')
and trainO.Isdisplay=0
and ��λ���<>''
group by t1.ά����
order by t1.ά����

IF OBJECT_ID('tempdb.dbo.#train_new') IS NOT NULL DROP TABLE #train_new
select t1.ά����
,FLOOR(isnull(sum(RealPrice + trainU.Fuprice + PrintPrice),0)) -FLOOR(isnull(sum(trainU.RealPrice+r.Fee),0)) as ��Ʊ����
,FLOOR(isnull(Sum(trainU.Fuprice - CASE Tsource WHEN '������' THEN 5 when '�߲�����' then 1 ELSE 0 END),0))+ FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0))as ��Ʊ����
into #train_new
from #cmp t1
left join tbTrainTicketInfo trainO on trainO.CmpId=t1.��λ���
LEFT JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo
left join Train_ReturnTicket r on r.TickOrderDetailID = trainU.ID
where t1.indate>='2018-01-01' and
(trainO.CreateDate>='2018-09-01' and trainO.CreateDate<'2018-10-01')
and (r.AuditTime >='2018-09-01' AND r.AuditTime<'2018-10-01')
and trainO.Isdisplay=0
and ��λ���<>''
group by t1.ά����
order by t1.ά����


IF OBJECT_ID('tempdb.dbo.#fa') IS NOT NULL DROP TABLE #fa
IF OBJECT_ID('tempdb.dbo.#fb') IS NOT NULL DROP TABLE #fb
--�Ͽͻ�
select 
t1.ά����
,isnull(��Ʊ����,0) fa1
,isnull(��Ʊ����,0) fa2
into #fa
from #whr t1
left join #train_old jo on jo.ά����=t1.ά���� 
order by t1.ά����
--�¿ͻ�
select 
t1.ά����
,isnull(��Ʊ����,0) fb1
,isnull(��Ʊ����,0) fb2
into #fb
from #whr t1
left join #train_new jo on jo.ά����=t1.ά���� 
order by t1.ά����




select whr.ά����
,ta1+ha1+za1+la1+ca1+fa1 as �Ͽͻ�������
,ta2+ha2+za2+la2+ca2+fa2 as �Ͽͻ�������
,tb1+hb1+zb1+lb1+cb1+fb1 as �¿ͻ�������
,tb2+hb2+zb2+lb2+cb2+fb2 as �¿ͻ�������
,Ta.ta1 as �Ͽͻ���Ʊ����,Ta.ta2 as �Ͽͻ���Ʊ����
,tb.tb1 as �¿ͻ���Ʊ����,tb.tb2 as �¿ͻ���Ʊ����
,ha.ha1 as �Ͽͻ�Ԥ���Ƶ�����,ha.ha2 as �Ͽͻ�Ԥ���Ƶ�����
,hb.hb1 as �¿ͻ�Ԥ���Ƶ�����,hb.hb2 as �¿ͻ�Ԥ���Ƶ�����
,za.za1 as �Ͽͻ��Ը��Ƶ�����,za.za2 as �Ͽͻ��Ը��Ƶ�����
,zb.zb1 as �¿ͻ��Ը��Ƶ�����,zb.zb2 as �¿ͻ��Ը��Ƶ�����
,la.la1 as �Ͽͻ���������,la.la2 as �Ͽͻ���������
,lb.lb1 as �¿ͻ���������,lb.lb2 as �¿ͻ���������
,ca.ca1 as �Ͽͻ���������,ca.ca2 as �Ͽͻ���������
,cb.cb1 as �¿ͻ���������,cb.cb2 as �¿ͻ���������
,fa.fa1 as �Ͽͻ���Ʊ����,fa.fa2 as �Ͽͻ���Ʊ����
,fb.fb1 as �¿ͻ���Ʊ����,fb.fb2 as �¿ͻ���Ʊ����

from #whr whr
left join #ta ta on ta.ά����=whr.ά����
left join #tb tb on tb.ά����=whr.ά����
left join #ha ha on ha.ά����=whr.ά����
left join #hb hb on hb.ά����=whr.ά����
left join #za za on za.ά����=whr.ά����
left join #zb zb on zb.ά����=whr.ά����
left join #la la on la.ά����=whr.ά����
left join #lb lb on lb.ά����=whr.ά����
left join #ca ca on ca.ά����=whr.ά����
left join #cb cb on cb.ά����=whr.ά����
left join #fa fa on fa.ά����=whr.ά����
left join #fb fb on fb.ά����=whr.ά����


