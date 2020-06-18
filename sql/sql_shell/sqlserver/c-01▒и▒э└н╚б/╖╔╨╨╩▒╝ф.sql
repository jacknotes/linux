--飞行时间
select c.tcode+c.ticketno,datediff(HOUR, it.Departing,it.Arriving) from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos pn on pn.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ItktBookingID=pn.ItktBookingID
where cmpcode='016485'
and (datetime>='2018-01-01' and datetime<'2019-01-01')
and inf=0
and reti=''
and tickettype='电子票'
