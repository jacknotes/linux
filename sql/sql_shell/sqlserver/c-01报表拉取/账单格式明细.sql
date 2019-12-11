--����
IF OBJECT_ID('tempdb.dbo.#dep') IS NOT NULL DROP TABLE #dep
select DISTINCT Name,dep.DepName 
into #dep
from homsomdb..Trv_Human h 
inner join homsomDB..Trv_UnitPersons up on up.ID=h.ID 
inner join homsomdb..Trv_CompanyStructure dep on dep.ID=up.CompanyDptId
where up.CompanyID in (Select id from homsomDB..Trv_UnitCompanies where Cmpid='016448')
and IsDisplay=1

--��Ʊ����
IF OBJECT_ID('tempdb.dbo.#tbc') IS NOT NULL DROP TABLE #tbc
select cmpcode as ��λ���,begdate as �������,datetime as ��Ʊ����,coupno as ���۵���,pasname as �˿�����,route as ��·,ride+flightno as �����,tcode+ticketno as Ʊ��
,priceinfo as ȫ��,'' as �ۿ���,price as ���۵���,tax as ˰��,xfprice as ǰ��,totprice as ���ۼ�,reti as ��Ʊ���� 
,CostCenter as �ɱ�����
,ProjectNo as ��Ŀ���
,nclass as ��λ
into #tbc
from tbcash c
where cmpcode='016448'
and (datetime>='2017-01-01' and datetime<'2018-01-01')
--and (datetime>='2018-01-01' and datetime<'2018-07-01')
and inf=1
order by datetime

select * from #tbc tbc


select tbc.*,dep.depname as ���� from #tbc tbc
left join #dep dep on dep.name=tbc.�˿�����

select cmpcode as ��λ���,begdate as �������,datetime as ��Ʊ����,coupno as ���۵���,pasname as �˿�����,route as ��·,ride+flightno as �����,tcode+ticketno as Ʊ��
,priceinfo as ȫ��,'' as �ۿ���,price as ���۵���,tax as ˰��,xfprice as ǰ��,totprice as ���ۼ�,reti as ��Ʊ���� 
,CostCenter as �ɱ�����
,ProjectNo as ��Ŀ���
,nclass as ��λ
from tbcash c
where cmpcode='020085'
and (datetime>='2017-05-01' and datetime<'2017-06-01')
and inf=1
order by datetime



