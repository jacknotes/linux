--烦请分别拉取2015-2016,所有差旅客户、旅游客户，有消费的明细，没消费的明细

--差旅单位-旅游
select t1.cmpid as 单位编号,cmpname as 单位名称,t1.OperDate as 预算单生成日期,TrvId as 预算单号,TrvCpName as 线路名称,t2.cmpaddress as 单位地址,t3.custname as 联系人,LEFT(t1.Custinfo,11) as 联系方式
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2019-01-01' and t2.CustomerType='A'
and t1.TrvType not like '%5%' and t1.Status !=2
order by t1.cmpid

--差旅单位-会务

select t1.cmpid as 单位编号,cmpname as 单位名称,t1.OperDate as 预算单生成日期,ConventionId as 预算单号,ConventionCpName as 线路名称,t2.cmpaddress as 单位地址,t3.custname as 联系人,LEFT(t1.Custinfo,11) as 联系方式
from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2019-01-01' and t2.CustomerType='A' and t1.status!=2
order by t1.cmpid

--差旅单位-单项服务
select t1.cmpid as 单位编号,cmpname as 单位名称,t1.OperDate as 预算单生成日期,TrvId as 预算单号,TrvCpName as 线路名称,t2.cmpaddress as 单位地址,t3.custname as 联系人,LEFT(t1.Custinfo,11) as 联系方式
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2019-01-01' and t2.CustomerType='A'
and t1.TrvType like '%5%' and t1.Status !=2
order by t1.cmpid


--旅游单位-旅游
select t1.cmpid as 单位编号,cmpname as 单位名称,t1.OperDate as 预算单生成日期,t1.TrvId as 预算单号,t1.TrvCpName as 线路名称,t2.cmpaddress as 单位地址,t3.custname as 联系人,LEFT(t1.Custinfo,11) as 联系方式
,t4.XsPrice as 销量,Profit as 利润
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
left join Topway..tbTrvCoup t4 on t4.TrvId=t1.TrvId
where t1.OperDate>='2018-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t1.TrvType not like '%5%' and t1.Status !=2
order by t1.cmpid


--旅游单位-会务

select t1.cmpid as 单位编号,cmpname as 单位名称,t1.OperDate as 预算单生成日期,t1.ConventionId as 预算单号,t1.ConventionCpName as 线路名称,t2.cmpaddress as 单位地址,t3.custname as 联系人,LEFT(t1.Custinfo,11) as 联系方式
,t4.XsPrice as 销量,Profit as 利润
from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
left join Topway..tbConventionCoup t4 on t4.ConventionId=t1.ConventionId
where t1.OperDate>='2018-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C' and t1.status!=2
order by t1.cmpid

--旅游单位-单项服务
select t1.cmpid as 单位编号,cmpname as 单位名称,t1.OperDate as 预算单生成日期,t1.TrvId as 预算单号,t1.TrvCpName as 线路名称,t2.cmpaddress as 单位地址,t3.custname as 联系人,LEFT(t1.Custinfo,11) as 联系方式
,t4.XsPrice as 销量,Profit as 利润
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
left join Topway..tbTrvCoup t4 on t4.TrvId=t1.TrvId
where t1.OperDate>='2018-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t1.TrvType like '%5%' and t1.Status !=2
order by t1.cmpid

--2015年有消费，2016年未消费差旅客户
select cmpid as 单位编号,cmpname as 单位名称,CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END as 合作状态
from tbCompanym
where cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' --and t2.CustomerType='A'
and t2.Status !=2)
and cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' --and t2.CustomerType='A')

and cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' --and t2.CustomerType='A'
and t2.Status !=2)
and cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' --and t2.CustomerType='A')

and CustomerType='A'


--2015年有消费，2016年未消费旅游客户
select cmpid as 单位编号,cmpname as 单位名称,CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END as 合作状态
from tbCompanym
where cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C'
and t2.Status !=2)
and cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C')

and cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t2.Status !=2)
and cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='c')

and CustomerType='C'

--单位客户合作状态
select * from tbCompanyM where hztype=1


--差旅单位2015年有消费，2016年未消费
--2015年旅游消费明细
select t1.cmpid as 单位编号,cmpname as 单位名称,
t1.OperDate as 预算单生成日期,TrvId as 预算单号,TrvCpName as 线路名称,t2.cmpaddress as 单位地址,t3.custname as 联系人,LEFT(t1.Custinfo,11) as 联系方式,
CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END as 合作状态
from tbCompanym t2
inner join tbTravelBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid


where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A'
and t1.Status !=2)
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A')

and t2.CustomerType='A'
and t1.Status !=2
and t1.TrvType not like '%5%'
order by t2.cmpid


--差旅单位2015年有消费，2016年未消费
--2015年会务消费明细
select t1.cmpid as 单位编号,cmpname as 单位名称,t1.OperDate as 预算单生成日期,ConventionId as 预算单号,ConventionCpName as 线路名称,t2.cmpaddress as 单位地址,t3.custname as 联系人,LEFT(t1.Custinfo,11) as 联系方式,
CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END as 合作状态
from tbCompanym t2
inner join tbConventionBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid


where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A'
and t1.Status !=2)
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A')

and t2.CustomerType='A'
and t1.Status !=2
order by t2.cmpid


--差旅单位2015年有消费，2016年未消费
--2015年单项服务消费明细
select t1.cmpid as 单位编号,cmpname as 单位名称,
t1.OperDate as 预算单生成日期,TrvId as 预算单号,TrvCpName as 线路名称,t2.cmpaddress as 单位地址,t3.custname as 联系人,LEFT(t1.Custinfo,11) as 联系方式,
CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END as 合作状态
from tbCompanym t2
inner join tbTravelBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid


where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A'
and t1.Status !=2)
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A')

and t2.CustomerType='A'
and t1.Status !=2
and t1.TrvType  like '%5%'
order by t2.cmpid



--旅游单位2015年有消费，2016年未消费
--2015年旅游消费明细
select t1.cmpid as 单位编号,cmpname as 单位名称,
t1.OperDate as 预算单生成日期,t1.TrvId as 预算单号,t1.TrvCpName as 线路名称,t2.cmpaddress as 单位地址,t3.custname as 联系人,LEFT(t1.Custinfo,11) as 联系方式,
CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END as 合作状态
,t4.XsPrice as 销量,Profit as 利润
from tbCompanym t2
inner join tbTravelBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
left join Topway..tbTrvCoup t4 on t1.TrvId=t4.TrvId

where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t1.Status !=2)
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C')

and t2.CustomerType='C'
and t1.Status !=2
and t1.TrvType not like '%5%'
order by t2.cmpid


--旅游单位2015年有消费，2016年未消费
--2015年会务消费明细
select t1.cmpid as 单位编号,cmpname as 单位名称,t1.OperDate as 预算单生成日期,t1.ConventionId as 预算单号,t1.ConventionCpName as 线路名称,t2.cmpaddress as 单位地址,t3.custname as 联系人,LEFT(t1.Custinfo,11) as 联系方式,
CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END as 合作状态
,t4.XsPrice as 销量,t4.Profit as 利润
from tbCompanym t2
inner join tbConventionBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
left join Topway..tbConventionCoup t4 on t4.ConventionId=t1.ConventionId

where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t1.Status !=2)
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C')

and t2.CustomerType='C'
and t1.Status !=2
order by t2.cmpid


--旅游单位2015年有消费，2016年未消费
--2015年单项服务消费明细
select t1.cmpid as 单位编号,cmpname as 单位名称,
t1.OperDate as 预算单生成日期,t1.TrvId as 预算单号,t1.TrvCpName as 线路名称,t2.cmpaddress as 单位地址,t3.custname as 联系人,LEFT(t1.Custinfo,11) as 联系方式,
CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END as 合作状态
,t4.XsPrice as 销量,Profit as 利润
from tbCompanym t2
inner join tbTravelBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
left join Topway..tbTrvCoup t4 on t1.TrvId=t4.TrvId

where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t1.Status !=2)
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C')

and t2.CustomerType='C'
and t1.Status !=2
and t1.TrvType  like '%5%'
order by t2.cmpid

--2015-2016旅游及会务均无消费的单位客户-差旅单位
select cmpid as 单位编号,cmpname as 单位名称,CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END as 合作状态
from tbCompanym
where cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t2.Status !=2)
and cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='c')
and CustomerType='A'

--2015-2016旅游及会务均无消费的单位客户-旅游单位
select cmpid as 单位编号,cmpname as 单位名称,CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END as 合作状态
from tbCompanym
where cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t2.Status !=2)
and cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='c')
and CustomerType='C'

--测试
select * from tbTravelBudget where Cmpid=''
select * from tbConventionBudget where Cmpid=''