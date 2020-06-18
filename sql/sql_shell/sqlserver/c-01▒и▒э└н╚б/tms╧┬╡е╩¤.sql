--��ͨTMS�ĵ�λ ���ù��� ��Ӫ���� �µ��� �е�¼���ĳ��ÿ�����

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
from topway..tbCompanyM t1
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
from  topway..HM_ThePreservationOfHumanInformation tp where MaintainType=6 and IsDisplay=1
--��Ӫ����
IF OBJECT_ID('tempdb.dbo.#yyjl') IS NOT NULL DROP TABLE #yyjl
select CmpId,MaintainName 
into #yyjl
from  topway..HM_ThePreservationOfHumanInformation tp where MaintainType=9 and IsDisplay=1

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
where ��λ���<>'' and ����״̬ not like ('%��ֹ%')

--select * from #p3

IF OBJECT_ID('tempdb.dbo.#up') IS NOT NULL DROP TABLE #up
select up.cmpid as ��λ���,up.Name as ��λ����,COUNT(*) as up
into #up
from homsomDB..Trv_UCSettings uc
inner join Trv_UnitCompanies up on up.UCSettingID=uc.ID
left join Trv_UnitPersons p on p.CompanyID=up.ID
left join Trv_Human h on h.ID=p.ID and IsDisplay=1
left join Trv_UPRanks k on k.ID=p.UPRankID
where Enabled=1
and h.Name is not null
and h.Name<>''
and UserName<>'' 
and UserName is not null
group by up.cmpid,up.Name
order by Cmpid


--��Ʊ�µ���-����
IF OBJECT_ID('tempdb.dbo.#a1') IS NOT NULL DROP TABLE #a1
select 
	ROW_NUMBER() over(order by uc.Cmpid) as ���к�,
	uc.Cmpid as ��λ���,uc.Name as ��λ����,COUNT(*) as �µ��� 
	into #a1
	from homsomDB..Trv_CompanyTravels t1
left join homsomDB..Trv_UnitCompanies uc on uc.ID=t1.UnitCompanyID
left join  homsomDB..Trv_ItktBookings t2 on t1.ID=t2.TravelID
left join homsomDB..Trv_TktBookings t3 on t2.ID=t3.ID
where t3.AdminStatus in (2,3,4,5) and t3.CreateDate>='2018-10-01' and t3.CreateDate<'2018-11-01'
AND BookingSource IN(1,5,10,11) 
group by uc.Cmpid,uc.Name

--�Ƶ��µ���-����
IF OBJECT_ID('tempdb.dbo.#h1') IS NOT NULL DROP TABLE #h1
select ROW_NUMBER() over(order by uc.Cmpid) as ���к�,
	uc.Cmpid as ��λ���,uc.Name as ��λ����,COUNT(*) as �µ��� 
	into #h1
	from homsomDB..Trv_UnitCompanies uc 	
left join [HotelOrderDB].[dbo].[HTL_Orders] a on a.CMPID=uc.Cmpid
where a.CreateDate>= '2018-10-01' and a.CreateDate<='2018-11-01'  and a.Status IN (40,92)
and Resource in (1,3)
group by uc.Cmpid,uc.Name




--��Ʊ�µ���-����
IF OBJECT_ID('tempdb.dbo.#a2') IS NOT NULL DROP TABLE #a2
select 
	ROW_NUMBER() over(order by uc.Cmpid) as ���к�,
	uc.Cmpid as ��λ���,uc.Name as ��λ����,COUNT(*) as �µ��� 
	into #a2
	from homsomDB..Trv_CompanyTravels t1
left join homsomDB..Trv_UnitCompanies uc on uc.ID=t1.UnitCompanyID
left join  homsomDB..Trv_ItktBookings t2 on t1.ID=t2.TravelID
left join homsomDB..Trv_TktBookings t3 on t2.ID=t3.ID
where t3.AdminStatus in (2,3,4,5) and t3.CreateDate>='2018-10-01' and t3.CreateDate<'2018-11-01'
--AND BookingSource IN(1,5,10,11) 
group by uc.Cmpid,uc.Name

--�Ƶ��µ���-����
IF OBJECT_ID('tempdb.dbo.#h2') IS NOT NULL DROP TABLE #h2
select ROW_NUMBER() over(order by uc.Cmpid) as ���к�,
	uc.Cmpid as ��λ���,uc.Name as ��λ����,COUNT(*) as �µ��� 
	into #h2
	from homsomDB..Trv_UnitCompanies uc 	
left join [HotelOrderDB].[dbo].[HTL_Orders] a on a.CMPID=uc.Cmpid
where a.CreateDate>= '2018-10-01' and a.CreateDate<='2018-11-01'  and a.Status IN (40,92)
--and Resource in (1,3)
group by uc.Cmpid,uc.Name

--΢�Ź�ע��
IF OBJECT_ID('tempdb.dbo.#wx') IS NOT NULL DROP TABLE #wx
SELECT T2.Name AS ��ҵ����,('UC'+T2.Cmpid) AS UC��,COUNT(1) AS ��ע�� 
into #wx
FROM dbo.Wechat_UserAssociation T1
LEFT JOIN  dbo.Trv_UnitCompanies T2 ON T1.CompanyId=T2.ID
GROUP BY T2.Name,T2.Cmpid


--����
IF OBJECT_ID('tempdb.dbo.#p4') IS NOT NULL DROP TABLE #p4
select p3.��λ���,p3.��λ����,p3.����ҵ�����,p3.��Ӫ����,isnull(up,0) as �˺���,isnull(a1.�µ���,0) as ��Ʊ�µ���,ISNULL(h1.�µ���,0) as �Ƶ��µ���,isnull(��ע��,0) as ΢�Ź�ע��
into #p4
from #p3 p3
inner join #up up on up.��λ���=p3.��λ���
left join #a1 a1 on a1.��λ���=up.��λ���
left join #h1 h1 on h1.��λ���=up.��λ���
left join #wx wx on wx.UC��='UC'+p3.��λ���
where p3.��λ��� not in ('000003','000006')
--and ��Ӫ����='������'
order by p3.��Ӫ����,p3.����ҵ�����,p3.��λ���

select ����ҵ�����,sum(΢�Ź�ע��)h from #p4
group by ����ҵ�����
order by h desc







--����
IF OBJECT_ID('tempdb.dbo.#p5') IS NOT NULL DROP TABLE #p5
select p3.��λ���,p3.��λ����,p3.����ҵ�����,p3.��Ӫ����,isnull(up,0) as �˺���,isnull(a2.�µ���,0) as ��Ʊ�µ���,ISNULL(h2.�µ���,0) as �Ƶ��µ���,isnull(��ע��,0) as ΢�Ź�ע��
into #p5
from #p3 p3
inner join #up up on up.��λ���=p3.��λ���
left join #a2 a2 on a2.��λ���=up.��λ���
left join #h2 h2 on h2.��λ���=up.��λ���
left join #wx wx on wx.UC��='UC'+p3.��λ���
where p3.��λ��� not in ('000003','000006')
--and ��Ӫ����='������'
order by p3.��Ӫ����,p3.����ҵ�����,p3.��λ���





IF OBJECT_ID('tempdb.dbo.#p10') IS NOT NULL DROP TABLE #p10
select p4.��λ���,p4.��λ����,p4.��Ʊ�µ���+p4.�Ƶ��µ��� as ���϶�����,p4.��Ʊ�µ���+p4.�Ƶ��µ���+p5.��Ʊ�µ���+p5.�Ƶ��µ��� as ȫ��������,p4.΢�Ź�ע��,p4.����ҵ�����,p4.��Ӫ����
into #p10
from #p4 p4
left join #p5 p5 on p5.��λ���=p4.��λ���









------------------------------


--11��

--��ͨTMS�ĵ�λ ���ù��� ��Ӫ���� �µ��� �е�¼���ĳ��ÿ�����





--��Ʊ�µ���-����
IF OBJECT_ID('tempdb.dbo.#a3') IS NOT NULL DROP TABLE #a3
select 
	ROW_NUMBER() over(order by uc.Cmpid) as ���к�,
	uc.Cmpid as ��λ���,uc.Name as ��λ����,COUNT(*) as �µ��� 
	into #a3
	from homsomDB..Trv_CompanyTravels t1
left join homsomDB..Trv_UnitCompanies uc on uc.ID=t1.UnitCompanyID
left join  homsomDB..Trv_ItktBookings t2 on t1.ID=t2.TravelID
left join homsomDB..Trv_TktBookings t3 on t2.ID=t3.ID
where t3.AdminStatus in (2,3,4,5) and t3.CreateDate>='2018-11-01' and t3.CreateDate<'2018-11-02'
AND BookingSource IN(1,5,10,11) 
group by uc.Cmpid,uc.Name

--�Ƶ��µ���-����
IF OBJECT_ID('tempdb.dbo.#h3') IS NOT NULL DROP TABLE #h3
select ROW_NUMBER() over(order by uc.Cmpid) as ���к�,
	uc.Cmpid as ��λ���,uc.Name as ��λ����,COUNT(*) as �µ��� 
	into #h3
	from homsomDB..Trv_UnitCompanies uc 	
left join [HotelOrderDB].[dbo].[HTL_Orders] a on a.CMPID=uc.Cmpid
where a.CreateDate>= '2018-11-01' and a.CreateDate<='2018-11-02'  and a.Status IN (40,92)
and Resource in (1,3)
group by uc.Cmpid,uc.Name




--��Ʊ�µ���-����
IF OBJECT_ID('tempdb.dbo.#a4') IS NOT NULL DROP TABLE #a4
select 
	ROW_NUMBER() over(order by uc.Cmpid) as ���к�,
	uc.Cmpid as ��λ���,uc.Name as ��λ����,COUNT(*) as �µ��� 
	into #a4
	from homsomDB..Trv_CompanyTravels t1
left join homsomDB..Trv_UnitCompanies uc on uc.ID=t1.UnitCompanyID
left join  homsomDB..Trv_ItktBookings t2 on t1.ID=t2.TravelID
left join homsomDB..Trv_TktBookings t3 on t2.ID=t3.ID
where t3.AdminStatus in (2,3,4,5) and t3.CreateDate>='2018-11-01' and t3.CreateDate<'2018-11-02'
--AND BookingSource IN(1,5,10,11) 
group by uc.Cmpid,uc.Name

--�Ƶ��µ���-����
IF OBJECT_ID('tempdb.dbo.#h4') IS NOT NULL DROP TABLE #h4
select ROW_NUMBER() over(order by uc.Cmpid) as ���к�,
	uc.Cmpid as ��λ���,uc.Name as ��λ����,COUNT(*) as �µ��� 
	into #h4
	from homsomDB..Trv_UnitCompanies uc 	
left join [HotelOrderDB].[dbo].[HTL_Orders] a on a.CMPID=uc.Cmpid
where a.CreateDate>= '2018-11-01' and a.CreateDate<='2018-11-02'  and a.Status IN (40,92)
--and Resource in (1,3)
group by uc.Cmpid,uc.Name

--΢�Ź�ע��
IF OBJECT_ID('tempdb.dbo.#wx2') IS NOT NULL DROP TABLE #wx2
SELECT T2.Name AS ��ҵ����,('UC'+T2.Cmpid) AS UC��,COUNT(1) AS ��ע�� 
into #wx2
FROM dbo.Wechat_UserAssociation T1
LEFT JOIN  dbo.Trv_UnitCompanies T2 ON T1.CompanyId=T2.ID
GROUP BY T2.Name,T2.Cmpid


--����
IF OBJECT_ID('tempdb.dbo.#p6') IS NOT NULL DROP TABLE #p6
select p3.��λ���,p3.��λ����,p3.����ҵ�����,p3.��Ӫ����,isnull(up,0) as �˺���,isnull(a3.�µ���,0) as ��Ʊ�µ���,ISNULL(h3.�µ���,0) as �Ƶ��µ���,isnull(��ע��,0) as ΢�Ź�ע��
into #p6
from #p3 p3
inner join #up up on up.��λ���=p3.��λ���
left join #a3 a3 on a3.��λ���=up.��λ���
left join #h3 h3 on h3.��λ���=up.��λ���
left join #wx2 wx2 on wx2.UC��='UC'+p3.��λ���
where p3.��λ��� not in ('000003','000006')
--and ��Ӫ����='������'
order by p3.��Ӫ����,p3.����ҵ�����,p3.��λ���





--����
IF OBJECT_ID('tempdb.dbo.#p7') IS NOT NULL DROP TABLE #p7
select p3.��λ���,p3.��λ����,p3.����ҵ�����,p3.��Ӫ����,isnull(up,0) as �˺���,isnull(a4.�µ���,0) as ��Ʊ�µ���,ISNULL(h4.�µ���,0) as �Ƶ��µ���,isnull(��ע��,0) as ΢�Ź�ע��
into #p7
from #p3 p3
inner join #up up on up.��λ���=p3.��λ���
left join #a4 a4 on a4.��λ���=up.��λ���
left join #h4 h4 on h4.��λ���=up.��λ���
left join #wx2 wx2 on wx2.UC��='UC'+p3.��λ���
where p3.��λ��� not in ('000003','000006')
--and ��Ӫ����='������'
order by p3.��Ӫ����,p3.����ҵ�����,p3.��λ���

IF OBJECT_ID('tempdb.dbo.#p11') IS NOT NULL DROP TABLE #p11
select p6.��λ���,p6.��λ����,p6.��Ʊ�µ���+p6.�Ƶ��µ��� as ���϶�����,p6.��Ʊ�µ���+p6.�Ƶ��µ���+p7.��Ʊ�µ���+p7.�Ƶ��µ��� as ȫ��������,p6.΢�Ź�ע��,p6.����ҵ�����,p6.��Ӫ����
into #p11
from #p6 p6
left join #p7 p7 on p7.��λ���=p6.��λ���



select p10.��λ���,p10.��λ����,p10.����ҵ�����,p10.��Ӫ����,p10.���϶����� as '10�����϶�����',p10.ȫ�������� as '10��ȫ��������',p11.���϶����� as '11��1�����϶�����'
,p11.ȫ�������� as '11��1��ȫ��������',p11.΢�Ź�ע�� 
from #p10 p10
left join #p11 p11 on p11.��λ���=p10.��λ���
where p10.ȫ��������<>0
order by ��Ӫ����,����ҵ�����,p10.ȫ�������� DESC


