IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as ��λ���,t1.cmpname as ��λ����
,(case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' else '' end) as ��λ����
,(CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END) as ����״̬
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as ������
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as �ۺ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as ά����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as ����ҵ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as ����ҵ�����
,indate,t4.IsSepPrice,t4.IsIntlSpecialPrice
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
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate,t4.IsSepPrice,t4.IsIntlSpecialPrice
order by t1.cmpid





--�ھ���
IF OBJECT_ID('tempdb.dbo.#wjr') IS NOT NULL DROP TABLE #wjr
select CmpId,MaintainName 
into #wjr
from  HM_ThePreservationOfHumanInformation tp where MaintainType=6 and IsDisplay=1
--��Ӫ����
IF OBJECT_ID('tempdb.dbo.#yyjl') IS NOT NULL DROP TABLE #yyjl
select CmpId,MaintainName 
into #yyjl
from  HM_ThePreservationOfHumanInformation tp where MaintainType=9 and IsDisplay=1

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



--������������λ
select DISTINCT Cmpid 
from homsomDB..Trv_FlightTripartitePolicies t1
left join homsomDB..Trv_UnitCompanies t2 on t2.ID=t1.UnitCompanyID
where t1.Name not like ('%SME%')

--������ֹ��������������
select ��λ��� from #p3 where ��λ��� not in (select DISTINCT Cmpid 
from homsomDB..Trv_FlightTripartitePolicies t1
left join homsomDB..Trv_UnitCompanies t2 on t2.ID=t1.UnitCompanyID
where t1.Name not like ('%SME%'))


IF OBJECT_ID('tempdb.dbo.#p4') IS NOT NULL DROP TABLE #p4
select cmpcode,pasname,idno,COUNT(*) as ����
into #p4
from tbcash c
where tickettype ='����Ʊ'
--and (p3.IsSepPrice=1 or p3.IsIntlSpecialPrice=1)
and inf=0
and datetime>='2018-01-01' and datetime<'2018-09-01'
and (cmpcode in (select ��λ��� from #p3 where ��λ��� not in (select DISTINCT Cmpid 
from homsomDB..Trv_FlightTripartitePolicies t1
left join homsomDB..Trv_UnitCompanies t2 on t2.ID=t1.UnitCompanyID
where t1.Name not like ('%SME%'))) or cmpcode='')
--and ride in ('MU','FM')
group by cmpcode,pasname,idno
order by cmpcode,pasname

select cmpcode as ��λ���,m.Name,pasname as �˻���,idno as ֤����,���� 
from #p4 p4
left join homsomdb..Trv_UnitCompanies m on m.cmpid=p4.cmpcode
where (m.IsSepPrice=1 or m.IsIntlSpecialPrice=1 or cmpcode='')
and right(pasname,3)<>'CHD'
	and right(pasname,2)<>'MS'
	and right(pasname,2)<>'MR'
	and right(pasname,3)<>'INF'
	order by ���� desc
	

IF OBJECT_ID('tempdb.dbo.#p5') IS NOT NULL DROP TABLE #p5
select cmpcode,pasname,idno,nclass,COUNT(*) as ����
into #p5
from tbcash 
where tickettype ='����Ʊ'
and inf=0
and datetime>='2017-08-01' and datetime<'2018-08-01'
and cmpcode in (select ��λ��� from #p3 where ��λ��� not in (select DISTINCT Cmpid 
from homsomDB..Trv_FlightTripartitePolicies t1
left join homsomDB..Trv_UnitCompanies t2 on t2.ID=t1.UnitCompanyID
where t1.Name not like ('%SME%')))
--and ride in ('MU','FM')
group by cmpcode,pasname,idno,nclass
order by cmpcode,pasname

select cmpcode as ��λ���,pasname as �˻���,idno as ֤����,nclass as ��λ,���� from #p5






