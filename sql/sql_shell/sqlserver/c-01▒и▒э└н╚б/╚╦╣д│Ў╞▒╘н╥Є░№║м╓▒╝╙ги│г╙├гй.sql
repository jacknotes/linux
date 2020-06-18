select datetime as 出票日期,begdate as 起飞时间,coupno as 销售单号,tcode+ticketno as 票号,t2.route as 航程,nclass as 舱位,ride+flightno as 航班号,cmpcode as 单位编号,quota1 as 定额费,totprice as 销售价,t2.profit-Mcost as 销售利润,t2.sales as 所属业务顾问,t2.SpareTC as 操作业务顾问,t2.reti as 退票单号 
from homsomDB..Trv_DomesticTicketRecord t1
left join tbcash t2 on t2.coupno=t1.RecordNumber
where TicketOperationRemark like ('%直加%') and t2.t_source='HSBSPETD'
and (t2.datetime>='2017-09-01' and t2.datetime<'2017-10-13')