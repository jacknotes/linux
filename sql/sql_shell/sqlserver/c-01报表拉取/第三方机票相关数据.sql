select c.cmpcode as 单位编号,m.cmpname as 单位名称,datetime as 出票日期,coupno as 销售单号
,case INF when 1 then '国际' when 0 then '国内' else '' end as 类型
,ride+flightno as 航班号,begdate as 起飞时间,tcode+ticketno as 票号,pasname as 乘机人,route as 航程,totprice as 销售价
from tbcash c
left join tbCompanyM m on c.cmpcode=m.cmpid
where cmpcode in 
('019941','019959','019807','019792','019787','019784','019944','016756','018326','019983','019805','019802','018886','019886','019508','016448','018202','016511','017275','016712','017012','020016','016602','017996','015828','016400','019845','018038','018463','017020','018021','018362','000370','017454','017408')
and datetime>='2018-02-01' and datetime<'2018-08-01'


select sum(totprice) as 销售价
from tbcash c
left join tbCompanyM m on c.cmpcode=m.cmpid
where cmpcode in 
('000370')
and datetime>='2018-02-01' and datetime<'2018-08-01'