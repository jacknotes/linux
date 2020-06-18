select pasname
,(Select pasname,count(inf) from tbcash where ride in ('MU','FM')
and (datetime>='2015-07-01' and datetime<'2017-02-21')
and t_source not in ('¹ÙÍøMUÍÅ¿¨D','¹ÙÍøMUÍÅ¿¨I') and inf=0
group by pasname) a
,(Select pasname,count(inf) from tbcash where ride in ('MU','FM')
and (datetime>='2015-07-01' and datetime<'2017-02-21')
and t_source not in ('¹ÙÍøMUÍÅ¿¨D','¹ÙÍøMUÍÅ¿¨I') and inf=1
group by pasname) b
from tbcash
where ride in ('MU','FM')
and (datetime>='2015-07-01' and datetime<'2017-02-21')
and t_source not in ('¹ÙÍøMUÍÅ¿¨D','¹ÙÍøMUÍÅ¿¨I')
group by pasname

Select pasname,ticketno,count(inf) as num
into #i0
from tbcash where ride in ('MU','FM')
and (datetime>='2015-07-01' and datetime<'2017-02-21')
and t_source not in ('¹ÙÍøMUÍÅ¿¨D','¹ÙÍøMUÍÅ¿¨I') and inf=0
group by pasname,ticketno

select pasname,ticketno,count(inf) as num
into #i1 
from tbcash where ride in ('MU','FM')
and (datetime>='2015-07-01' and datetime<'2017-02-21')
and t_source not in ('¹ÙÍøMUÍÅ¿¨D','¹ÙÍøMUÍÅ¿¨I') and inf=1
group by pasname,ticketno

select i.pasname,COUNT(i0.num) as gn,COUNT(i1.num) as gj
into #r
from tbcash i
left join #i0 i0 on i.ticketno=i0.ticketno and i.pasname=i0.pasname
left join #i1 i1 on i.ticketno=i1.ticketno and i.pasname=i1.pasname
where ride in ('MU','FM')
and (datetime>='2015-07-01' and datetime<'2017-02-21')
and t_source not in ('¹ÙÍøMUÍÅ¿¨D','¹ÙÍøMUÍÅ¿¨I')
group by i.pasname

SELECT *,CASE WHEN pasname<>'' THEN Topway.dbo.fn_GetQuanPin(STUFF(pasname,2,0,'/')) ELSE '' END	
FROM #r
ORDER BY pasname





