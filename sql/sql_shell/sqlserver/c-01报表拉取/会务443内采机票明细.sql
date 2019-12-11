select datetime as 出票日期,begdate as 起飞日期,t1.coupno as 电子销售单号,pasname as 乘客姓名,t1.route as 航程,tair as 航司,flightno as 航班号,t1.tcode+t1.ticketno as 票号,t1.totprice as 销售价,t1.price as 销售单价,tax as 税收,t1.reti as 退票单号,quota1 as 定额代理费1
from tbcash t1
left join tbConventionJS t2 on t2.Id=t1.ConventionYsId
where ConventionId=483
order by t1.coupno

--select reti,* from tbcash where coupno in ('AS000476875')
--select * from tbReti where coupno in ('AS000476875')

select * from tbConventionjs where ConventionId=483 
and GysSource='HOMSOM国内机票' and Jstatus !=4
order by id

select ConventionYsId,* from tbcash where ConventionYsId=3631

select * from tbcash where ConventionYsId='2578'
select ConventionYsId,* from tbcash where coupno in ('AS000472768')

select b.TrvJSID,a.* from tbcash a,homsomDB..Trv_TktBookings b,homsomDB..Trv_DomesticTicketRecord c,homsomDB..Trv_PnrInfos d
where a.coupno=c.RecordNumber and c.PnrInfoID=d.ID and d.ItktBookingID=b.ID and a.coupno in ('AS000482261')

select ConventionYsId,* from tbcash where coupno in ('AS000482261')
update tbcash set ConventionYsId='2736' where coupno in ('AS000482261')