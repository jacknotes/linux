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
 (select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID)='������' --���ù���
 --(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID)='����ܿ'--���ι���
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
select c.cmpcode,MONTH(c.datetime) as �·�
,SUM(ISNULL(c.totprice,0)-ISNULL(r.totprice,0)) as ��Ʊ����
,SUM(ISNULL(c.profit,0)+ISNULL(r.profit,0)) as ��Ʊ����
into #air
from tbcash c
left join tbReti r on r.reno=c.reti and r.status2<>4
where c.cmpcode in
(Select ��λ��� from #cmp)and (c.datetime>='2018-04-01' and c.datetime<'2018-08-01')
--and c.inf=1
group by c.cmpcode,MONTH(c.datetime)


 
--�Ƶ�Ԥ�� 
select cmpid,MONTH(prdate) as �·�,sum(price)Ԥ���Ƶ�����,sum(totprofit)Ԥ���Ƶ�����
into #hotel_y
from tbHtlcoupYf
where cmpid in 
(Select ��λ��� from #cmp)and (prdate>='2018-04-01' and prdate<'2018-08-01') and 
status !='-2'
group by cmpid,MONTH(prdate)

--�Ƶ��Ը�
select cmpid,MONTH(datetime) as �·�,sum(price)�Ը��Ƶ�����,sum(totprofit)�Ը��Ƶ�����
into #hotel_z
from tbHotelcoup
where cmpid in 
(Select ��λ��� from #cmp)and (datetime>='2018-04-01' and datetime<'2018-08-01') and 
status !='-2'
group by cmpid,MONTH(datetime)

--����
select cmpid,MONTH(OperDate) as �·�,SUM(XsPrice) as ��������,SUM(Profit) as �������� 
into #travel
from tbTrvCoup 
where Cmpid in 
(Select ��λ��� from #cmp)and (OperDate>='2018-04-01' and OperDate<'2018-08-01')
group by Cmpid,MONTH(OperDate)

--����
select cmpid,MONTH(OperDate) as �·�,SUM(XsPrice) as ��������,SUM(Profit) as �������� 
into #huiwu
from tbConventionCoup 
where Cmpid in 
(Select ��λ��� from #cmp)and (OperDate>='2018-04-01' and OperDate<'2018-08-01')
group by Cmpid,MONTH(OperDate)

--��Ʊ
select CmpId,MONTH(trainO.CreateDate) as �·�
,FLOOR(isnull(sum(RealPrice + trainU.Fuprice + PrintPrice),0)) -FLOOR(isnull(sum(trainU.RealPrice+r.Fee),0)) as ��Ʊ����
,FLOOR(isnull(Sum(trainU.Fuprice - CASE Tsource WHEN '������' THEN 5 when '�߲�����' then 1 ELSE 0 END),0))+ FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0))as ��Ʊ����
into #train
from tbTrainTicketInfo trainO
LEFT JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo
left join Train_ReturnTicket r on r.TickOrderDetailID = trainU.ID
where CmpId in 
(Select ��λ��� from #cmp)and (trainO.CreateDate>='2018-04-01' and trainO.CreateDate<'2018-08-01')
and (r.AuditTime >='2018-04-01' AND r.AuditTime<'2018-08-01')
and trainO.Isdisplay=0
group by CmpId,MONTH(trainO.CreateDate)

--IF OBJECT_ID('tempdb.dbo.#hz') IS NOT NULL DROP TABLE #hz
--select CompanyCode,COUNT(*) as hz
--into #hz
--from AccountStatement 
--where AccountPeriodAir1>='2018-04-01' and AccountPeriodAir1<'2018-08-01'
--group by CompanyCode


IF OBJECT_ID('tempdb.dbo.#pz') IS NOT NULL DROP TABLE #pz
select Cmp.*,air.�·�,isnull(��Ʊ����,0)+isnull(Ԥ���Ƶ�����,0)+isnull(�Ը��Ƶ�����,0)+isnull(��������,0)+isnull(��������,0)+isnull(��Ʊ����,0) as ������
--,(isnull(��Ʊ����,0)+isnull(Ԥ���Ƶ�����,0)+isnull(�Ը��Ƶ�����,0)+isnull(��������,0)+isnull(��������,0)+isnull(��Ʊ����,0))/hz.hz as �¾�����
,isnull(��Ʊ����,0)+isnull(Ԥ���Ƶ�����,0)+isnull(�Ը��Ƶ�����,0)+isnull(��������,0)+isnull(��������,0)+isnull(��Ʊ����,0) as ������
--,(isnull(��Ʊ����,0)+isnull(Ԥ���Ƶ�����,0)+isnull(�Ը��Ƶ�����,0)+isnull(��������,0)+isnull(��������,0)+isnull(��Ʊ����,0))/hz.hz as �¾�����
--,''as ë����,isnull(hz.hz,0) as �����·���
,��Ʊ����,��Ʊ����,Ԥ���Ƶ�����,Ԥ���Ƶ�����,�Ը��Ƶ�����,�Ը��Ƶ�����,��������,��������,��������,��������,��Ʊ����,��Ʊ���� 
into #pz
from #cmp cmp
left join #air air on air.cmpcode=Cmp.��λ���
left join #hotel_y hotel_y on hotel_y.cmpid=Cmp.��λ��� and hotel_y.�·�=air.�·�
left join #hotel_z hotel_z on hotel_z.cmpid=Cmp.��λ��� and hotel_z.�·�=air.�·�
left join #travel travel on travel.cmpid=Cmp.��λ��� and travel.�·�=air.�·�
left join #huiwu huiwu on huiwu.cmpid=Cmp.��λ��� and huiwu.�·�=air.�·�
left join #train train on train.cmpid=Cmp.��λ��� and Train.�·�=air.�·�
--left join #hz hz on hz.CompanyCode=Cmp.��λ���
order by ��λ���,air.�·�

IF OBJECT_ID('tempdb.dbo.#pz2') IS NOT NULL DROP TABLE #pz2
select ��λ���,��λ����,�·�,isnull(������,0) as ����
into #pz2
from #pz

IF OBJECT_ID('tempdb.dbo.#pz3') IS NOT NULL DROP TABLE #pz3
select ��λ���,��λ����,�·�,isnull(������,0) as ����
into #pz3
from #pz


IF OBJECT_ID('tempdb.dbo.#pz4') IS NOT NULL DROP TABLE #pz4
SELECT * 
into #pz4
FROM #pz2 
AS P
PIVOT 
(
    SUM(����) FOR 
    p.�·� IN ([4],[5],[6],[7])
) AS T1
order by ��λ����
IF OBJECT_ID('tempdb.dbo.#pz5') IS NOT NULL DROP TABLE #pz5
SELECT * 
into #pz5
FROM #pz3 
AS P
PIVOT 
(
    SUM(����) FOR 
    p.�·� IN ([4],[5],[6],[7])
) AS T1
order by ��λ����

select pz4.��λ���,pz4.��λ����
,isnull(pz4.[4],0) as [4������]
,isnull(pz5.[4],0) as [4������]
,isnull(pz4.[5],0) as [5������] 
,isnull(pz5.[5],0) as [5������]
,isnull(pz4.[6],0) as [6������] 
,isnull(pz5.[6],0) as [6������] 
,isnull(pz4.[7],0) as [7������] 
,isnull(pz5.[7],0) as [7������] 
from #pz4 pz4
inner join #pz5 pz5 on pz5.��λ���=pz4.��λ���
