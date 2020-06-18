
--康宝莱明细
select datetime as 出票日期,begdate as 起飞日期,t1.coupno as 销售单号,t1.pasname as 乘客姓名,t1.route as 线路,tair as 航司,flightno as 航班号,t1.tcode+t1.ticketno as 票号,t1.priceinfo as 全价,t1.price as 销售单价,
tax as 税收,fuprice as 服务费,t1.totprice as 销售价,t1.reti as 退票单号,nclass as 舱位,t5.DepName as 部门
from tbcash t1
left join homsomdb..Trv_CompanyStructure t5 on t5.ID in (select CompanyDptId from homsomDB..Trv_UnitPersons t3 inner join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID 
where t4.IsDisplay=1 and t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='020459'))
left join tbConventionJS t2 on t2.Id=t1.ConventionYsId
where t1.cmpcode='020459'and datetime>='2018-01-01' and datetime<'2018-12-27' 
order by t1.datetime

--部门
select DepName,* from homsomdb..Trv_CompanyStructure where id in (select CompanyDptId from homsomDB..Trv_UnitPersons t3 inner join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID 
where t4.IsDisplay=1 and t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='020459'))


select Department 部门,SUM(price) 销量不含税  from Topway..V_TicketInfo 
where cmpcode='020459'
and (ModifyBillNumber in ('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and tickettype='电子票'
and tickettype not like '%改期%'
and tickettype not like '%升舱%'
and route not like '%改期%'
and route not like '%升舱%'
group by Department


select Department 部门,SUM(price) 销量不含税,COUNT(*) from Topway..V_TicketInfo 
where cmpcode='020459'
and (ModifyBillNumber in ('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=1
and tickettype='电子票'
and tickettype not like '%改期%'
and tickettype not like '%升舱%'
and route not like '%改期%'
and route not like '%升舱%'
group by Department
order by 销量不含税 desc