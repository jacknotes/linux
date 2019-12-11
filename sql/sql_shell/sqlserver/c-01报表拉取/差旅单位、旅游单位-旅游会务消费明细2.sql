--差旅单位
select t1.cmpid as 单位编号,cmpname as 单位名称,
t1.OperDate as 预算单生成日期,TrvId as 预算单号,TrvCpName as 线路名称,t2.cmpaddress as 单位地址,t3.custname as 联系人,LEFT(t1.Custinfo,11) as 联系方式,
CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END as 合作状态
from tbCompanym t2
inner join tbTravelBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid


where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A'
and t1.Status !=2 and t1.TrvType not like '%5%')
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A')

and t2.CustomerType='A'
and t1.Status !=2
--and t1.TrvType not like '%5%'
--and t1.OperDate<'2016-01-01'
order by t2.cmpid

--旅游单位
select t1.cmpid as 单位编号,cmpname as 单位名称,
t1.OperDate as 预算单生成日期,TrvId as 预算单号,TrvCpName as 线路名称,t2.cmpaddress as 单位地址,t3.custname as 联系人,LEFT(t1.Custinfo,11) as 联系方式,
CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END as 合作状态
from tbCompanym t2
inner join tbTravelBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid


where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='C'
and t1.Status !=2 and t1.TrvType not like '%5%')
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='C')

and t2.CustomerType='C'
and t1.Status !=2
--and t1.TrvType not like '%5%'
--and t1.OperDate<'2016-01-01'
order by t2.cmpid

--2015-2016未消费旅游会务差旅单位明细（不含单项服务）
select cmpid as 单位编号,cmpname as 单位名称,CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END as 合作状态
from tbCompanym
where  ((cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A'
and t2.Status !=2 and TrvType not like '%5%') or 
cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A'
  and t1.status=2))
and cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A')

and CustomerType='A')

--2015-2016未消费旅游会务旅游单位明细（不含单项服务）
select cmpid as 单位编号,cmpname as 单位名称,CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END as 合作状态
from tbCompanym
where  ((cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='C'
and t2.Status !=2 and TrvType not like '%5%') or 
cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='C'
  and t1.status=2))
and cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='C')

and CustomerType='C')