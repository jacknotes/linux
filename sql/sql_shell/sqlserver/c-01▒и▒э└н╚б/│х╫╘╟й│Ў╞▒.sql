--航司HO，冲自签出票
select COUNT(*) from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
where ride='HO'
and d.TicketOperationMode=4
and datetime>='2019-03-01'
and datetime<'2019-04-01'
and tickettype='电子票'