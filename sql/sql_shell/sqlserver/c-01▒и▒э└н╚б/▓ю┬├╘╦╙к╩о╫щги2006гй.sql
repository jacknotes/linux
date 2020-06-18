	IF OBJECT_ID('tempdb.dbo.#emp') IS NOT NULL DROP TABLE #emp
	IF OBJECT_ID('tempdb.dbo.#gn') IS NOT NULL DROP TABLE #gn
	IF OBJECT_ID('tempdb.dbo.#gj') IS NOT NULL DROP TABLE #gj
    IF OBJECT_ID('tempdb.dbo.#h_gn') IS NOT NULL DROP TABLE #h_gn
	IF OBJECT_ID('tempdb.dbo.#h_gj') IS NOT NULL DROP TABLE #h_gj
	IF OBJECT_ID('tempdb.dbo.#train') IS NOT NULL DROP TABLE #train
	
	
	SELECT ROW_NUMBER()OVER(ORDER BY t2.depOrder,t1.idnumber) idx,empname
	INTO #emp 
	from emppwd t1 LEFT JOIN dbo.EmpSysSetting t2 ON t1.team=t2.dep AND t2.ntype=2 where t1.team = '差旅运营十组' 
	order by t2.depOrder,t1.idnumber 

	select SpareTC,count(*) as 国内出票张数
	into #gn
	from tbcash WITH(NOLOCK) where 
	(datetime BETWEEN '2018-08-01' AND CONVERT(varchar(20),DateAdd(day,1,'2018-08-31'),23)) 
	and SpareTC in (select empname from #emp)
	and inf=0
	group by SpareTC

	select SpareTC,count(*) as 国际出票张数
	into #gj
	from tbcash WITH(NOLOCK) where 
	(datetime BETWEEN '2018-08-01' AND CONVERT(varchar(20),DateAdd(day,1,'2018-08-31'),23)) 
	and SpareTC in (select empname from #emp)
	and inf=1
	group by SpareTC
	
	select ApplyPrintPeople,sum(nights*pcs) as 国内酒店间夜数
	into #h_gn
	from tbHtlcoupYf WITH(NOLOCK)
    where 
    (prdate BETWEEN '2018-08-01' AND CONVERT(varchar(20),DateAdd(day,1,'2018-08-31'),23))
    and dinf=0
    and ApplyPrintPeople in 
    (select empname from #emp) 
    group by ApplyPrintPeople
   
    
    select ApplyPrintPeople,sum(nights*pcs) as 国际酒店间夜数
    into #h_gj
    from tbHtlcoupYf WITH(NOLOCK)
    where 
    (prdate BETWEEN '2018-08-01' AND CONVERT(varchar(20),DateAdd(day,1,'2018-08-31'),23))
    and dinf=1
    and ApplyPrintPeople in 
    (select empname from #emp) 
    group by ApplyPrintPeople
   
    
    
    select ModifyBy,COUNT(*) as 火车票张数
    into #train
    from tbTrainTicketInfo WITH(NOLOCK)
    where 
    (CreateDate BETWEEN '2018-08-01' AND CONVERT(varchar(20),DateAdd(day,1,'2018-08-31'),23))
    and ModifyBy in 
    (select empname from #emp) 
    group by ModifyBy


	select ROW_NUMBER()OVER(ORDER BY idx) 序号,Emp.empname as 差旅业务顾问,gn.国内出票张数,gj.国际出票张数,gn.国内出票张数+gj.国际出票张数 as 机票合计张数
	, isnull(h_gn.国内酒店间夜数,0)国内酒店间夜数,isnull(h_gj.国际酒店间夜数,0)国际酒店间夜数,isnull(h_gn.国内酒店间夜数,0)+isnull(h_gj.国际酒店间夜数,0) as 酒店间夜数合计
	,isnull(Train.火车票张数,0)火车票张数
	from #emp emp
	inner join #gn gn on gn.spareTC=Emp.empname
	inner join #gj gj on gj.spareTC=Emp.empname
	left join #h_gn h_gn on h_gn.ApplyPrintPeople=Emp.empname
	left join #h_gj h_gj on h_gj.ApplyPrintPeople=Emp.empname
	left join #train train on Train.ModifyBy=Emp.empname