select tcode+r.ticketno as 票号,t.coupno as 销售单号,t_source as 供应商来源,scount2 as 航空公司退票费,r.ExamineDate as 审核时间,r.ride as 航空公司,
flightno as 航班号,reno as 退票单号 from Topway..tbReti r
inner join tbcash t on t.reti=r.reno
where r.ExamineDate>='2018-1-1' and r.ExamineDate<'2018-12-23' and r.inf='1' and r.ride in ('fm','mu')
order by ExamineDate

select tcode+r.ticketno as 票号,t.coupno as 销售单号,t_source as 供应商来源,scount2 as 航空公司退票费,r.ExamineDate as 审核时间,r.ride as 航空公司,
flightno as 航班号,reno as 退票单号 from Topway..tbReti r
inner join tbcash t on t.reti=r.reno
where r.ExamineDate>='2018-1-1' and r.ExamineDate<'2018-12-23' and r.inf='1' and r.ride like ('%HO%')
order by ExamineDate