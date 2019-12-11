select c.cmpcode as 单位编号,m.cmpname as 单位名称,c.datetime as 出票日期,c.coupno as 销售单号
,case c.inf when 1 then '国际' when 0 then '国内' else '' end as 类型
,c.ride+c.flightno as 航班号,begdate as 起飞时间,c.tcode+c.ticketno as 票号,c.pasname as 乘机人,c.route as 航程,c.totprice as 销售价
from tbcash c
left join tbCompanyM m on m.cmpid=c.cmpcode
where c.cmpcode in 
('020359','017730','020278','017745','018591','019394','019471','019653','018661','020297','019550','015918','020362','019588','017290','016560','018781','018265','019259','017205','019331','017739','018156','016773','020027')
and datetime>='2018-06-01' and datetime<'2018-12-01'
order by c.cmpcode 