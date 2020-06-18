select coupno as 销售单号,datetime as 出票日期,begdate as 起飞时间,pasname as  乘机人,ride+flightno as 航班号,route as 航程,tcode+ticketno as 票号 from tbcash
where (begdate>='2018-05-11' and begdate<'2018-05-12')
and cmpcode ='017189'
and route like ('%沈阳-%')

select coupno as 销售单号,datetime as 出票日期,begdate as 起飞时间,pasname as  乘机人,ride+flightno as 航班号,route as 航程,tcode+ticketno as 票号 from tbcash
where (begdate>='2018-05-13' and begdate<'2018-05-14')
and cmpcode ='017189'
and route like ('%-沈阳%')