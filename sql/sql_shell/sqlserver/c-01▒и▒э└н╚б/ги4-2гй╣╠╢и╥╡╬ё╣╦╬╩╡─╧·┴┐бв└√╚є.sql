--��ȡ�̶�ҵ����ʵ�λ�ͻ�������������
IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select t1.cmpid as ��λ���,t1.cmpname as ��λ����
,(case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' else '' end) as ��λ����
,(CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END) as ����״̬
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as ������
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as �ͻ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as ά����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as ����ҵ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as ����ҵ�����
--,indate
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
where 
 --(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID)='����' --���ù���
 (select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID)='����ܿ'--���ι���
and CustomerType='A'
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid

--select * from #cmp
/*
--ע����
select cmpid,indate from tbCompanyM where cmpid in 
(Select ��λ��� from #cmp)
--�̶����
select CmpId,CreateDate from HM_CompanyCreditInfo where CmpId in 
(Select ��λ��� from #cmp)group by CmpId,CreateDate
order by CmpId desc
*/
IF OBJECT_ID('tempdb.dbo.#air') IS NOT NULL DROP TABLE #air
IF OBJECT_ID('tempdb.dbo.#hotel_y') IS NOT NULL DROP TABLE #hotel_y
IF OBJECT_ID('tempdb.dbo.#hotel_z') IS NOT NULL DROP TABLE #hotel_z
IF OBJECT_ID('tempdb.dbo.#travel') IS NOT NULL DROP TABLE #travel
IF OBJECT_ID('tempdb.dbo.#huiwu') IS NOT NULL DROP TABLE #huiwu
IF OBJECT_ID('tempdb.dbo.#train') IS NOT NULL DROP TABLE #train


--��Ʊ
select c.cmpcode
,SUM(ISNULL(c.totprice,0)-ISNULL(r.totprice,0)) as ��Ʊ����
,SUM(ISNULL(c.profit,0)+ISNULL(r.profit,0)) as ��Ʊ����
into #air
from tbcash c
left join tbReti r on r.reno=c.reti and r.status2<>4
where c.cmpcode in
(Select ��λ��� from #cmp)and (c.datetime>='2017-01-01' and c.datetime<'2018-07-01')
--and c.inf=1
group by c.cmpcode
 
--�Ƶ�Ԥ�� 
select cmpid,sum(price)Ԥ���Ƶ�����,sum(totprofit)Ԥ���Ƶ�����
into #hotel_y
from tbHtlcoupYf
where cmpid in 
(Select ��λ��� from #cmp)and (prdate>='2017-01-01' and prdate<'2018-07-01') and 
status !='-2'
group by cmpid

--�Ƶ��Ը�
select cmpid,sum(price)�Ը��Ƶ�����,sum(totprofit)�Ը��Ƶ�����
into #hotel_z
from tbHotelcoup
where cmpid in 
(Select ��λ��� from #cmp)and (datetime>='2017-01-01' and datetime<'2018-07-01') and 
status !='-2'
group by cmpid

--����
select cmpid,SUM(XsPrice) as ��������,SUM(Profit) as �������� 
into #travel
from tbTrvCoup 
where Cmpid in 
(Select ��λ��� from #cmp)and (OperDate>='2017-01-01' and OperDate<'2018-07-01')
group by Cmpid

--����
select cmpid,SUM(XsPrice) as ��������,SUM(Profit) as �������� 
into #huiwu
from tbConventionCoup 
where Cmpid in 
(Select ��λ��� from #cmp)and (OperDate>='2017-01-01' and OperDate<'2018-07-01')
group by Cmpid

--��Ʊ
select CmpId
,FLOOR(isnull(sum(RealPrice + trainU.Fuprice + PrintPrice),0)) -FLOOR(isnull(sum(trainU.RealPrice+r.Fee),0)) as ��Ʊ����
,FLOOR(isnull(Sum(trainU.Fuprice - CASE Tsource WHEN '������' THEN 5 when '�߲�����' then 1 ELSE 0 END),0))+ FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0))as ��Ʊ����
into #train
from tbTrainTicketInfo trainO
LEFT JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo
left join Train_ReturnTicket r on r.TickOrderDetailID = trainU.ID
where CmpId in 
(Select ��λ��� from #cmp)and (trainO.CreateDate>='2017-01-01' and trainO.CreateDate<'2018-07-01')
and (r.AuditTime >='2017-01-01' AND r.AuditTime<'2018-07-01')
and trainO.Isdisplay=0
group by CmpId

IF OBJECT_ID('tempdb.dbo.#hz') IS NOT NULL DROP TABLE #hz
select CompanyCode,COUNT(*) as hz
into #hz
from AccountStatement 
where AccountPeriodAir1>='2017-01-01' and AccountPeriodAir1<'2018-07-01'
group by CompanyCode



select Cmp.*,isnull(��Ʊ����,0)+isnull(Ԥ���Ƶ�����,0)+isnull(�Ը��Ƶ�����,0)+isnull(��������,0)+isnull(��������,0)+isnull(��Ʊ����,0) as ������
,(isnull(��Ʊ����,0)+isnull(Ԥ���Ƶ�����,0)+isnull(�Ը��Ƶ�����,0)+isnull(��������,0)+isnull(��������,0)+isnull(��Ʊ����,0))/hz.hz as �¾�����
,isnull(��Ʊ����,0)+isnull(Ԥ���Ƶ�����,0)+isnull(�Ը��Ƶ�����,0)+isnull(��������,0)+isnull(��������,0)+isnull(��Ʊ����,0) as ������
,(isnull(��Ʊ����,0)+isnull(Ԥ���Ƶ�����,0)+isnull(�Ը��Ƶ�����,0)+isnull(��������,0)+isnull(��������,0)+isnull(��Ʊ����,0))/hz.hz as �¾�����
,''as ë����,isnull(hz.hz,0) as �����·���
,��Ʊ����,��Ʊ����,Ԥ���Ƶ�����,Ԥ���Ƶ�����,�Ը��Ƶ�����,�Ը��Ƶ�����,��������,��������,��������,��������,��Ʊ����,��Ʊ���� 
from #cmp cmp
left join #air air on air.cmpcode=Cmp.��λ���
left join #hotel_y hotel_y on hotel_y.cmpid=Cmp.��λ���
left join #hotel_z hotel_z on hotel_z.cmpid=Cmp.��λ���
left join #travel travel on travel.cmpid=Cmp.��λ���
left join #huiwu huiwu on huiwu.cmpid=Cmp.��λ���
left join #train train on train.cmpid=Cmp.��λ���
left join #hz hz on hz.CompanyCode=Cmp.��λ���





--����
IF OBJECT_ID('tempdb.dbo.#air2') IS NOT NULL DROP TABLE #air2
IF OBJECT_ID('tempdb.dbo.#hotel2') IS NOT NULL DROP TABLE #hotel2

select custname as ����,mobilephone as �ֻ���,sum(ISNULL(t2.totprice,0)-ISNULL(t3.totprice,0)) as ��Ʊ����,SUM(ISNULL(t2.profit,0)+ISNULL(t3.profit,0)) as ��Ʊ����
into #air2
from tbCusholder t1
left join tbcash t2 on t1.custid=t2.custid
left join tbReti t3 on t3.reno=t2.reti
where t1.sales='������'
and (t2.datetime>='2017-01-01' and t2.datetime<'2018-07-01')
group by custname,mobilephone

select custname as ����,mobilephone as �ֻ���,sum(isnull(h1.price,0)) as �Ƶ�����,sum(isnull(h1.totprofit,0)) as �Ƶ�����
into #hotel2
from tbCusholder t1
left join tbHtlcoupYf h1 on h1.custid=t1.custid 
where t1.sales='������'
and (h1.prdate>='2017-01-01' and h1.prdate<'2018-07-01')
group by custname,mobilephone

select air2.*,Hotel2.�Ƶ�����,hotel2.�Ƶ����� 
from #air2 air2 
left join #hotel2 hotel2 on hotel2.����=air2.���� and hotel2.�ֻ���=air2.�ֻ���
