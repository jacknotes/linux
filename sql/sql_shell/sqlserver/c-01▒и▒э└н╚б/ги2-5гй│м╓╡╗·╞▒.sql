
--国内
select datetime as 出票日期,c.coupno as 销售单号,tcode+ticketno as 票号,begdate as 起飞时间,ride as 航司,nclass as 舱位,c.route as 航程,quota1+quota2+quota3+quota4 as 定额费
,SpareTC as 操作业务顾问,c.totprice as 销售价,c.totsprice as 结算价,profit-Mcost as 销售利润,cmpcode as 单位编号, TicketOperationRemark as 人工出票原因
from homsomDB..Trv_DomesticTicketRecord t1
left join tbcash c on c.coupno=t1.RecordNumber
where 
TicketOperationRemark like ('%超值%')
and (c.datetime>='2018-03-01' and c.datetime<'2018-04-01')

--国际
UNION ALL 
select datetime as 出票日期,c.coupno as 销售单号,tcode+ticketno as 票号,begdate as 起飞时间,ride as 航司,nclass as 舱位,c.route as 航程,quota1+quota2+quota3+quota4 as 定额费
,SpareTC as 操作业务顾问,c.totprice as 销售价,c.totsprice as 结算价,profit-Mcost as 销售利润,cmpcode as 单位编号 ,'' as 人工出票原因
from tbFiveCoupInfo fo 
left join tbcash c on c.coupno=fo.CoupNo
where comment like ('%超值%')
and c.datetime>='2018-03-01' and c.datetime<'2018-04-01'


