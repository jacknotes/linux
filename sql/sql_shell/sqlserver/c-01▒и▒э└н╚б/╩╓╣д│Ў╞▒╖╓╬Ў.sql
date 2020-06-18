--手工出票分析
select indate,CONVERT(CHAR(5),indate,108),* from Topway..tbcash  c
where indate>='2019-03-01'
and indate<'2019-04-01'
and c.inf=1
and ((CONVERT(CHAR(5),indate,108)>='20:00' and CONVERT(CHAR(5),indate,108)<='23:59') or 
(CONVERT(CHAR(5),indate,108)>='00:00' and CONVERT(CHAR(5),indate,108)<='08:00')
)

select * from Topway..tbcash  c
inner join homsomDB..Trv_DomesticTicketRecord d on c.coupno = d.RecordNumber
where indate>='2019-03-01'
and indate<'2019-04-01'
and d.OperationStatus=1
and ((CONVERT(CHAR(5),indate,108)>='20:00' and CONVERT(CHAR(5),indate,108)<='23:59') or 
(CONVERT(CHAR(5),indate,108)>='00:00' and CONVERT(CHAR(5),indate,108)<='08:00')
)
