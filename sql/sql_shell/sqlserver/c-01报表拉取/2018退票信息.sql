

select t.datetime as 出票日期,t.coupno as 销售单号,t.tcode+t.ticketno as 票号,begdate as 起飞时间,pasname as 乘机人,t.route as 航程,t.price as 销售单价,
tax as 税收,t.totprice as 销售价,t.totprice as 结算价,t.disct as 促销费,t.profit as 利润,flightno as 航班号,reno as 退票单号,scount2 as 航空公司退票费,t.profit-t.Mcost as 调整利润,r.totprice as HS应付金额,
r.rtprice as 收客户退票费
from Topway..tbReti r
inner join tbcash t on t.reti=r.reno
where r.ExamineDate>='2018-1-1' and r.ExamineDate<'2018-12-27' and t.cmpcode='019807'
order by ExamineDate

