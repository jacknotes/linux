IF OBJECT_ID('tempdb.dbo.#p1') IS NOT NULL DROP TABLE #p1
select c.cmpcode,m.cmpname,sum(ISNULL(c.totprice,0)-ISNULL(r.totprice,0)) as xl 
into #p1
from tbcash c
left join tbReti r on r.reno=c.reti
left join tbCompanyM m on m.cmpid=c.cmpcode
where c.datetime>='2018-01-01' and c.datetime<'2018-04-01'
and t_source like ('%HSBSP%')
group by c.cmpcode,m.cmpname

select top 100* from #p1 where cmpcode<>'' order by xl desc

IF OBJECT_ID('tempdb.dbo.#p2') IS NOT NULL DROP TABLE #p2
select c.cmpcode,m.cmpname,sum(ISNULL(c.totprice,0)-ISNULL(r.totprice,0)) as xl 
into #p2
from tbcash c
left join tbReti r on r.reno=c.reti
left join tbCompanyM m on m.cmpid=c.cmpcode
where c.datetime>='2018-01-01' and c.datetime<'2018-04-01'
and c.cmpcode in (select top 100cmpcode from #p1 where cmpcode<>'' order by xl desc)
group by c.cmpcode,m.cmpname

IF OBJECT_ID('tempdb.dbo.#p3') IS NOT NULL DROP TABLE #p3
select p1.*,p2.xl as zxl 
into #p3
from #p1 p1 inner join #p2 p2 on p2.cmpcode=p1.cmpcode order by p1.xl desc


select * from #p4

IF OBJECT_ID('tempdb.dbo.#p4') IS NOT NULL DROP TABLE #p4
select CompanyCode,SettlementTypeAir 
into #p4
from AccountStatement where AccountPeriodAir1>='2018-03-26' and (CompanyCode in (select  cmpcode from #p3 ))
IF OBJECT_ID('tempdb.dbo.#p5') IS NOT NULL DROP TABLE #p5
select CmpId,DuiZhang1,DuiZhang2 
into #p5
from  HM_CompanyAccountInfo where CmpId in  (select  cmpcode from #p3 ) and PendDate>='2099-01-01'

select * from #p3 p3
left join #p4 p4 on p4.companycode=p3.cmpcode
left join #p5 p5 on p5.cmpid=p3.cmpcode