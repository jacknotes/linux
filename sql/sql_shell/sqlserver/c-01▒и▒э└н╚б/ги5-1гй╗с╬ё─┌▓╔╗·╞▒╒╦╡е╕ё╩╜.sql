


select ConventionId as Ԥ�㵥��,c.datetime as ��Ʊ����,c.begdate as �������,c.coupno as ���۵���,pasname as �˿�����,c.route as ��·,tair+flightno as �����,tcode+c.ticketno as Ʊ��
,priceinfo as ȫ��,'' as �ۿ���,c.price as ���۵���,tax as ˰��,fuprice as �����,c.totprice-isnull(r.totprice,0) as  ���ۼ�,quota1+quota2+quota3+quota4 as �����,reti as ��Ʊ���� 
--,(select DepName from homsomdb..Trv_CompanyStructure where ID in (select CompanyDptId from homsomDB..Trv_UnitPersons where ID in (select id from homsomdb..Trv_Human 
--where Name=c.pasname and companyid in (select id from homsomDB..Trv_UnitCompanies where Cmpid='')))) as ����
,CostCenter as �ɱ�����
--,(select name from homsomDB..Trv_CostCenter where ID in (select CostCenterID from homsomDB..Trv_UnitPersons 
--where ID in (select id from homsomdb..Trv_Human where Name=tbcash.pasname and companyid in (select id from homsomDB..Trv_UnitCompanies where Cmpid='017692')))) as �ɱ�����
,ProjectNo as ��Ŀ���
from tbcash c
left join tbReti r on r.reno=c.reti
inner join tbConventionJS js on c.ConventionYsId=js.Id
where JsType=0 AND Jstatus<>4
and ConventionId in ('750')