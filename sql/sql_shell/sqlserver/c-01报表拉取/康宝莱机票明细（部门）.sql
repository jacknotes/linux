
--��������ϸ
select datetime as ��Ʊ����,begdate as �������,t1.coupno as ���۵���,t1.pasname as �˿�����,t1.route as ��·,tair as ��˾,flightno as �����,t1.tcode+t1.ticketno as Ʊ��,t1.priceinfo as ȫ��,t1.price as ���۵���,
tax as ˰��,fuprice as �����,t1.totprice as ���ۼ�,t1.reti as ��Ʊ����,nclass as ��λ,t5.DepName as ����
from tbcash t1
left join homsomdb..Trv_CompanyStructure t5 on t5.ID in (select CompanyDptId from homsomDB..Trv_UnitPersons t3 inner join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID 
where t4.IsDisplay=1 and t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='020459'))
left join tbConventionJS t2 on t2.Id=t1.ConventionYsId
where t1.cmpcode='020459'and datetime>='2018-01-01' and datetime<'2018-12-27' 
order by t1.datetime

--����
select DepName,* from homsomdb..Trv_CompanyStructure where id in (select CompanyDptId from homsomDB..Trv_UnitPersons t3 inner join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID 
where t4.IsDisplay=1 and t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='020459'))


select Department ����,SUM(price) ��������˰  from Topway..V_TicketInfo 
where cmpcode='020459'
and (ModifyBillNumber in ('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and tickettype='����Ʊ'
and tickettype not like '%����%'
and tickettype not like '%����%'
and route not like '%����%'
and route not like '%����%'
group by Department


select Department ����,SUM(price) ��������˰,COUNT(*) from Topway..V_TicketInfo 
where cmpcode='020459'
and (ModifyBillNumber in ('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=1
and tickettype='����Ʊ'
and tickettype not like '%����%'
and tickettype not like '%����%'
and route not like '%����%'
and route not like '%����%'
group by Department
order by ��������˰ desc