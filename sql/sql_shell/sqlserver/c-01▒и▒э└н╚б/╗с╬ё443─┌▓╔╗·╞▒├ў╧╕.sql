select datetime as ��Ʊ����,begdate as �������,t1.coupno as �������۵���,pasname as �˿�����,t1.route as ����,tair as ��˾,flightno as �����,t1.tcode+t1.ticketno as Ʊ��,t1.totprice as ���ۼ�,t1.price as ���۵���,tax as ˰��,t1.reti as ��Ʊ����,quota1 as ��������1
from tbcash t1
left join tbConventionJS t2 on t2.Id=t1.ConventionYsId
where ConventionId=483
order by t1.coupno

--select reti,* from tbcash where coupno in ('AS000476875')
--select * from tbReti where coupno in ('AS000476875')

select * from tbConventionjs where ConventionId=483 
and GysSource='HOMSOM���ڻ�Ʊ' and Jstatus !=4
order by id

select ConventionYsId,* from tbcash where ConventionYsId=3631

select * from tbcash where ConventionYsId='2578'
select ConventionYsId,* from tbcash where coupno in ('AS000472768')

select b.TrvJSID,a.* from tbcash a,homsomDB..Trv_TktBookings b,homsomDB..Trv_DomesticTicketRecord c,homsomDB..Trv_PnrInfos d
where a.coupno=c.RecordNumber and c.PnrInfoID=d.ID and d.ItktBookingID=b.ID and a.coupno in ('AS000482261')

select ConventionYsId,* from tbcash where coupno in ('AS000482261')
update tbcash set ConventionYsId='2736' where coupno in ('AS000482261')