
--�밴�����ˣ�̸��Ρ�����������������������Ԫ��¥��������Ρ����컪�������ɡ��򷽡������ࣩ����ȡ�ͻ����������������󣨻�Ʊ���Ƶꡢ���Ρ����񡢻�Ʊ��

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





--Ӧ�ջ��
IF OBJECT_ID('tempdb.dbo.#yskj') IS NOT NULL DROP TABLE #yskj
select CmpId,MaintainName 
into #yskj
from  HM_ThePreservationOfHumanInformation tp where MaintainType=2 and IsDisplay=1
--��Ӫ����
IF OBJECT_ID('tempdb.dbo.#yyjl') IS NOT NULL DROP TABLE #yyjl
select CmpId,MaintainName 
into #yyjl
from  HM_ThePreservationOfHumanInformation tp where MaintainType=9 and IsDisplay=1

IF OBJECT_ID('tempdb.dbo.#p3') IS NOT NULL DROP TABLE #p3
select cmp1.*,yskj.MaintainName as Ӧ�ջ��,yyjl.MaintainName as ��Ӫ���� 
into #p3
from #cmp1 cmp1
left join #yskj yskj on yskj.cmpid=cmp1.��λ���
left join #yyjl yyjl on yyjl.cmpid=cmp1.��λ���





--�˵�����
IF OBJECT_ID('tempdb.dbo.#p4') IS NOT NULL DROP TABLE #p4
select CompanyCode,SettlementTypeAir 
into #p4
from AccountStatement where AccountPeriodAir1<=GETDATE() AND AccountPeriodAir2>=GETDATE()

IF OBJECT_ID('tempdb.dbo.#p5') IS NOT NULL DROP TABLE #p5
select CmpId,DuiZhang1,DuiZhang2
into #p5
from  HM_CompanyAccountInfo where PstartDate<=GETDATE() and PendDate>=GETDATE()

IF OBJECT_ID('tempdb.dbo.#p6') IS NOT NULL DROP TABLE #p6
select p3.*,p4.settlementtypeair,p5.duizhang1,p5.duizhang2 
into #p6
from #p3 p3
left join #p4 p4 on p4.companycode=p3.��λ���
left join #p5 p5 on p5.cmpid=p3.��λ���


IF OBJECT_ID('tempdb.dbo.#hz') IS NOT NULL DROP TABLE #hz
select CompanyCode,COUNT(*) as hz
into #hz
from AccountStatement 
where AccountPeriodAir1>='2018-01-01' and AccountPeriodAir1<'2018-10-01'
group by CompanyCode

IF OBJECT_ID('tempdb.dbo.#p7') IS NOT NULL DROP TABLE #p7
select ��λ���,��λ����,duizhang1 as �˵�����,duizhang2 as ��������,settlementtypeair as ���㷽ʽ,Ӧ�ջ��,����ҵ�����,ά����,�ۺ�����,��Ӫ����,������,����״̬,isnull(hz.hz,0)as hz 
into #p7
from #p6 p6
left join #hz hz on hz.CompanyCode=p6.��λ���
where ��λ���<>''





--��Ʊ
IF OBJECT_ID('tempdb.dbo.#jipiao') IS NOT NULL DROP TABLE #jipiao
select t1.��λ���
,sum(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as ��Ʊ����
,sum(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as ��Ʊ���� 
into #jipiao
from #p6 t1
left join tbcash t3 on t3.cmpcode=t1.��λ���
left join tbreti t2 on t3.coupno=t2.coupno and t2.status2<>4
where  (t3.datetime>='2018-01-01' and t3.datetime<'2018-10-01')
and ��λ���<>''
group by t1.��λ���




--�Ƶ�Ԥ��
IF OBJECT_ID('tempdb.dbo.#hotel') IS NOT NULL DROP TABLE #hotel
select t1.��λ���
,sum(h1.price) as �Ƶ�����
,sum(h1.totprofit) as �Ƶ�����
into #hotel
from #p6 t1
left join tbHtlcoupYf h1 on h1.cmpid=t1.��λ��� and h1.status<>-2
left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
where 
(h1.prdate>='2018-01-01' and h1.prdate<'2018-10-01') and 
status !='-2'
and ��λ���<>''
group by t1.��λ���





--�Ƶ��Ը�
IF OBJECT_ID('tempdb.dbo.#hotel_y') IS NOT NULL DROP TABLE #hotel_y
select t1.��λ���
,sum(h3.price) as �Ƶ�����
,sum(h3.totprofit) as �Ƶ�����
into #hotel_y
from #p6 t1
left join tbHotelcoup h3 on h3.cmpid=t1.��λ��� and h3.status<>-2
left join tbhtlyfchargeoff h4 on h4.coupid=h3.id
where 
(h3.datetime>='2018-01-01' and h3.datetime<'2018-10-01') and 
status !='-2'
and ��λ���<>''
group by t1.��λ���







--����
IF OBJECT_ID('tempdb.dbo.#trv') IS NOT NULL DROP TABLE #trv
select t1.��λ���
,SUM(l1.XsPrice) as ��������
,SUM(l1.Profit) as ��������
into #trv
from #p6 t1
left join tbTrvCoup l1 on l1.Cmpid=t1.��λ���
where 
 (l1.OperDate>='2018-01-01' and l1.OperDate<'2018-10-01')
and ��λ���<>''
group by t1.��λ���





--����
IF OBJECT_ID('tempdb.dbo.#con') IS NOT NULL DROP TABLE #con
select t1.��λ���
,SUM(c1.XsPrice) as ��������
,SUM(c1.Profit) as ��������
into #con
from #p6 t1
left join tbConventionCoup c1 on c1.Cmpid=t1.��λ���
where 
 (c1.OperDate>='2018-01-01' and c1.OperDate<'2018-10-01')
and ��λ���<>''
group by t1.��λ���





--��Ʊ
IF OBJECT_ID('tempdb.dbo.#train') IS NOT NULL DROP TABLE #train
select t1.��λ���
,FLOOR(isnull(sum(RealPrice + trainU.Fuprice + PrintPrice),0)) -FLOOR(isnull(sum(trainU.RealPrice-r.Fee),0)) as ��Ʊ����
,FLOOR(isnull(Sum(trainU.Fuprice - CASE Tsource WHEN '������' THEN 5 when '�߲�����' then 1 ELSE 0 END),0))+ FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0))as ��Ʊ����
into #train
from #p6 t1
left join tbTrainTicketInfo trainO on trainO.CmpId=t1.��λ���
LEFT JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo
left join Train_ReturnTicket r on r.TickOrderDetailID = trainU.ID
where 
(trainO.CreateDate>='2018-01-01' and trainO.CreateDate<'2018-10-01')
and (r.AuditTime >='2018-01-01' AND r.AuditTime<'2018-10-01')
and trainO.Isdisplay=0
and ��λ���<>''
group by t1.��λ���

select p7.��λ���,p7.��λ����,����״̬,hz as �����·�,����ҵ�����,��Ӫ����,ά����,�ۺ�����
,isnull(��Ʊ����,0)+ISNULL(hotel.�Ƶ�����,0)+ISNULL(hotel_y.�Ƶ�����,0) as ��������
,isnull(��Ʊ����,0)+ISNULL(hotel.�Ƶ�����,0)+ISNULL(hotel_y.�Ƶ�����,0) as ��������
from #p7 p7
left join #jipiao jipiao on jipiao.��λ���=p7.��λ���
left join #hotel hotel on hotel.��λ���=p7.��λ���
left join #hotel_y hotel_y on hotel_y.��λ���=p7.��λ���
left join #trv trv on trv.��λ���=p7.��λ���
left join #con con on con.��λ���=p7.��λ���
left join #train train on train.��λ���=p7.��λ���


