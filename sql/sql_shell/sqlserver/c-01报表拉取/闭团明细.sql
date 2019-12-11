--旅游
select t1.TrvId as 预算单号,t1.Sales as 操作业务顾问,t1.JiDIao as 单团支持人,introducer as 事务支持人,t2.TrvCpName as 产品名称,t2.OperDate as 生成日期,t2.EndDate as 返程日期,t1.OperDate as 闭团日期 
from tbTrvCoup t1
inner join tbTravelBudget t2 on t1.TrvId=t2.TrvId
inner join Emppwd t3 on t1.Sales=t3.empname 
where t1.OperDate >'2016-09-01' and t1.OperDate<'2016-10-01' and t2.TrvType not like '%5%' and t2.Status !=2 
--and t2.OperDate>='2016-07-01'
order by t1.OperDate

begin tran
--update tbTravelBudget set introducer=t1.Sales+'-'+t3.idnumber+'-运营部'
select t1.TrvId as 预算单号,t1.Sales as 操作业务顾问,t1.JiDIao as 单团支持人,introducer as 事务支持人,t1.Sales+'-'+t3.idnumber+'-运营部'
from tbTrvCoup t1
inner join tbTravelBudget t2 on t1.TrvId=t2.TrvId
inner join Emppwd t3 on t1.Sales=t3.empname 
where t1.OperDate >'2016-08-01' and t1.OperDate<'2016-10-01'  and t2.Status !=2 and t2.OperDate>='2016-07-01'

commit tran

--单项服务
select t1.TrvId as 预算单号,t1.Sales as 操作业务顾问,t1.JiDIao as 单团支持人,introducer as 事务支持人,t2.TrvCpName as 产品名称,t2.OperDate as 生成日期,t2.EndDate as 返程日期,t1.OperDate as 闭团日期 
from tbTrvCoup t1
inner join tbTravelBudget t2 on t1.TrvId=t2.TrvId
where t1.OperDate >'2016-09-01' and t1.OperDate<'2016-10-01' and t2.TrvType  like '%5%' and t2.Status !=2 and t2.OperDate>='2016-07-01'
order by t1.OperDate

--update tbTrvCoup set JiDIao='暂无'
where TrvId in (select t1.TrvId 
from tbTrvCoup t1
inner join tbTravelBudget t2 on t1.TrvId=t2.TrvId
where t1.OperDate >'2016-08-01' and t1.OperDate<'2016-09-01' and t2.TrvType  like '%5%' and t2.Status !=2)
--会务
select  t1.OperDate as 闭团日期,t1.ConventionId as 预算单号,t1.ConventionCpName as 单位名称,t3.GysSource as 供应商来源,t1.Sales as 会务顾问,t1.FinancialCharges as 资金费用,t5.xsprice as 收款金额,t1.JsZPrice as 结算价,t5.infotax as 进项税金,
t5.invoicetax as 销项税金,t5.Disct as 促销费,t5.Profit as 利润, '' as 利润率
from tbConventionCoup t1
left join tbConventionBudget t2 on t1.ConventionId=t2.ConventionId
left join Topway..tbConventionJS t3 on t3.ConventionId=t1.ConventionId
left join Topway..tbConventionKhSk t4 on t4.ConventionId=t1.ConventionId
left join Topway..tbConventionCoup t5 on t5.ConventionId=t1.ConventionId
where t1.OperDate >='2018-12-01' and t1.OperDate<'2019-01-01' and t2.Status !=2 
order by t1.OperDate

