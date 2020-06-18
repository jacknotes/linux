select cmpcode,pasname,t_source 
from tbcash c
where (datetime>='2017-02-21' and datetime<'2017-03-28')
and ride in ('MU','FM')
and inf=1
and pasname not in (select EName from homsomDB..B2GWhiteList)

select * from homsomDB..B2GWhiteList where EName like ('%WANG/YIYI%')

SELECT *,CASE WHEN pasname<>'' and pasname NOT LIKE '%[0-9a-zA-Z]%' THEN Topway.dbo.fn_GetQuanPin(STUFF(pasname,2,0,'/'))  ELSE pasname END	
FROM #p1