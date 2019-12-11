


select ConventionId as 预算单号,c.datetime as 出票日期,c.begdate as 起飞日期,c.coupno as 销售单号,pasname as 乘客姓名,c.route as 线路,tair+flightno as 航班号,tcode+c.ticketno as 票号
,priceinfo as 全价,'' as 折扣率,c.price as 销售单价,tax as 税收,fuprice as 服务费,c.totprice-isnull(r.totprice,0) as  销售价,quota1+quota2+quota3+quota4 as 定额费,reti as 退票单号 
--,(select DepName from homsomdb..Trv_CompanyStructure where ID in (select CompanyDptId from homsomDB..Trv_UnitPersons where ID in (select id from homsomdb..Trv_Human 
--where Name=c.pasname and companyid in (select id from homsomDB..Trv_UnitCompanies where Cmpid='')))) as 部门
,CostCenter as 成本中心
--,(select name from homsomDB..Trv_CostCenter where ID in (select CostCenterID from homsomDB..Trv_UnitPersons 
--where ID in (select id from homsomdb..Trv_Human where Name=tbcash.pasname and companyid in (select id from homsomDB..Trv_UnitCompanies where Cmpid='017692')))) as 成本中心
,ProjectNo as 项目编号
from tbcash c
left join tbReti r on r.reno=c.reti
inner join tbConventionJS js on c.ConventionYsId=js.Id
where JsType=0 AND Jstatus<>4
and ConventionId in ('750')