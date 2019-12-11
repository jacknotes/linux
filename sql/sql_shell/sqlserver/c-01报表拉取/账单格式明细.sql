--部门
IF OBJECT_ID('tempdb.dbo.#dep') IS NOT NULL DROP TABLE #dep
select DISTINCT Name,dep.DepName 
into #dep
from homsomdb..Trv_Human h 
inner join homsomDB..Trv_UnitPersons up on up.ID=h.ID 
inner join homsomdb..Trv_CompanyStructure dep on dep.ID=up.CompanyDptId
where up.CompanyID in (Select id from homsomDB..Trv_UnitCompanies where Cmpid='016448')
and IsDisplay=1

--出票数据
IF OBJECT_ID('tempdb.dbo.#tbc') IS NOT NULL DROP TABLE #tbc
select cmpcode as 单位编号,begdate as 起飞日期,datetime as 出票日期,coupno as 销售单号,pasname as 乘客姓名,route as 线路,ride+flightno as 航班号,tcode+ticketno as 票号
,priceinfo as 全价,'' as 折扣率,price as 销售单价,tax as 税收,xfprice as 前返,totprice as 销售价,reti as 退票单号 
,CostCenter as 成本中心
,ProjectNo as 项目编号
,nclass as 舱位
into #tbc
from tbcash c
where cmpcode='016448'
and (datetime>='2017-01-01' and datetime<'2018-01-01')
--and (datetime>='2018-01-01' and datetime<'2018-07-01')
and inf=1
order by datetime

select * from #tbc tbc


select tbc.*,dep.depname as 部门 from #tbc tbc
left join #dep dep on dep.name=tbc.乘客姓名

select cmpcode as 单位编号,begdate as 起飞日期,datetime as 出票日期,coupno as 销售单号,pasname as 乘客姓名,route as 线路,ride+flightno as 航班号,tcode+ticketno as 票号
,priceinfo as 全价,'' as 折扣率,price as 销售单价,tax as 税收,xfprice as 前返,totprice as 销售价,reti as 退票单号 
,CostCenter as 成本中心
,ProjectNo as 项目编号
,nclass as 舱位
from tbcash c
where cmpcode='020085'
and (datetime>='2017-05-01' and datetime<'2017-06-01')
and inf=1
order by datetime



