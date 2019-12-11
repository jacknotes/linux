/*14家天纳克2019年第一季度， UC016448只成本中心为CA 的数据
UC016448
UC018541
UC020085 
UC020273 
UC016713 
UC020636 
UC020637 
UC020638 
UC020643 
UC020655 
UC020665 
UC020685 
UC020742 
UC016448  
*/
--国内
if OBJECT_ID('tempdb..#gnsj') is not null drop table #gnsj
select 'UC'+cmpcode UC号,u.Name 公司名称,sum(price) 销量不含税,sum(tax) 税收,COUNT(1) 张数,sum(price)/COUNT(1) 平均票价,
sum(price)/SUM(convert(decimal(18,3),priceinfo)) 折扣率,AVG(DATEDIFF(DD,datetime,begdate)) 平均出票天数 
into #gnsj
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2019-01-01'
and datetime<'2019-04-01'
and cmpcode='016448'
AND inf=0
--and CostCenter='CA'
GROUP BY 'UC'+cmpcode,u.Name

if OBJECT_ID('tempdb..#gnhs') is not null drop table #gnhs
select top 1  'UC'+cmpcode UC号,u.Name 公司名称,ride 航司,sum(price) 销量不含税
into #gnhs
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2019-01-01'
and datetime<'2019-04-01'
and cmpcode='016448'
AND inf=0
--and CostCenter='CA'
GROUP BY 'UC'+cmpcode,u.Name,ride
order by 销量不含税 desc


--国际
if OBJECT_ID('tempdb..#gjsj') is not null drop table #gjsj
select 'UC'+cmpcode UC号,u.Name 公司名称,sum(price) 销量不含税,sum(tax) 税收,COUNT(1) 张数,
AVG(DATEDIFF(DD,datetime,begdate)) 平均出票天数 
into #gjsj
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2019-01-01'
and datetime<'2019-04-01'
and  cmpcode='016448'
AND inf=1
--and CostCenter='CA'
GROUP BY 'UC'+cmpcode,u.Name


--select * from #gjsj

select s.UC号,s.公司名称,s.销量不含税,s.税收,s.张数,s.平均票价,折扣率,s.平均出票天数,航司,h.销量不含税/s.销量不含税 占比比例
,j.销量不含税,j.税收,j.张数,j.平均出票天数 
from #gnsj s
left join #gnhs h on s.UC号=h.UC号
left join #gjsj j on s.UC号=j.UC号
