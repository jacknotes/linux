IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select cmpid 
into #cmp
from tbCompanyM
where cmpid in 
('016448','016713','018541','018408','020085','020273')

IF OBJECT_ID('tempdb.dbo.#gn') IS NOT NULL DROP TABLE #gn
select cmpcode,SUM(price) price
into #gn
from V_TicketInfo where cmpcode in 
('016448','016713','018541','018408','020085','020273')
and datetime>='2017-01-01' and datetime<'2018-01-01'
and reti=''
and inf=0
group by cmpcode

IF OBJECT_ID('tempdb.dbo.#gj') IS NOT NULL DROP TABLE #gj
select cmpcode,SUM(price) price
into #gj
from V_TicketInfo where cmpcode in 
('016448','016713','018541','018408','020085','020273')
and datetime>='2017-01-01' and datetime<'2018-01-01'
and reti=''
and inf=1
group by cmpcode


IF OBJECT_ID('tempdb.dbo.#tax') IS NOT NULL DROP TABLE #tax
select cmpcode,SUM(tax) tax
into #tax
from tbcash where cmpcode in 
('016448','016713','018541','018408','020085','020273')
and datetime>='2017-01-01' and datetime<'2018-01-01'
group by cmpcode

IF OBJECT_ID('tempdb.dbo.#tg') IS NOT NULL DROP TABLE #tg
select cmpcode,sum(price) price 
into #tg
from tbcash 
where  (tickettype like ('%改期%') or t_source like ('%改期%') or route like ('%改期%')or reti<>'')
and cmpcode in 
('016448','016713','018541','018408','020085','020273')
and datetime>='2017-01-01' and datetime<'2018-01-01'
group by cmpcode


select Cmp.cmpid,isnull(gn.price,0),isnull(gj.price,0),isnull(tax.tax,0),isnull(tg.price,0) from #cmp cmp
left join #gn gn on gn.cmpcode=Cmp.cmpid
left join #gj gj on gj.cmpcode=Cmp.cmpid
left join #tax tax on tax.cmpcode=Cmp.cmpid
left join #tg tg on tg.cmpcode=Cmp.cmpid




