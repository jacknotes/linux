IF OBJECT_ID('tempdb.dbo.#p1') IS NOT NULL DROP TABLE #p1
select t3.cmpcode,count(*) as 机票张数
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as 机票销量
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as 机票利润
into #P1
from tbcash t3
left join tbreti t2 on t3.coupno=t2.coupno
where t3.datetime>='2018-07-01' and t3.datetime<'2018-08-01'
group by t3.cmpcode

IF OBJECT_ID('tempdb.dbo.#p2') IS NOT NULL DROP TABLE #p2
select cmpid,COUNT(*) as 酒店张数
,sum(h1.price) as 酒店销量
,sum(h1.totprofit) as 酒店利润
into #p2
from tbHtlcoupYf h1
where prdate>='2018-07-01' and prdate<'2018-08-01'
group by cmpid

IF OBJECT_ID('tempdb.dbo.#p3') IS NOT NULL DROP TABLE #p3
select m.cmpid,m.cmpname
,isnull(机票张数,0)机票张数,isnull(机票销量,0)机票销量,isnull(机票利润,0)机票利润
,isnull(酒店张数,0)酒店张数,isnull(酒店销量,0)酒店销量,isnull(酒店利润,0)酒店利润
into #p3
from tbCompanyM m
left join #p1 p1 on p1.cmpcode=m.cmpid
left join #p2 p2 on p2.cmpid=m.cmpid

IF OBJECT_ID('tempdb.dbo.#p4') IS NOT NULL DROP TABLE #p4
select cmpid,cmpname,机票销量+酒店销量 as 总销量,机票利润+酒店利润 as 总利润
,(机票利润+酒店利润)/nullif((机票销量+酒店销量),0) as 毛利率
,机票张数,机票销量,机票利润,机票利润/NULLIF(机票销量,0)as 机票毛利率,酒店张数,酒店销量,酒店利润,酒店利润/NULLIF(酒店销量,0)as 酒店毛利率
into #p4
from #p3
where cmpid<>''
and (机票张数<>0 or 酒店张数<>0)




--纯机票
select * from 
(select '销量小于10000' as 销量范围,COUNT(*)单位数量,SUM(总销量)总销量,SUM(总利润)总利润,SUM(总利润)/SUM(总销量) 毛利率 from #p4
where 机票张数<>0 and 酒店张数=0
and 总销量<10000
UNION ALL
select '销量10000-20000' as 销量范围,COUNT(*)单位数量,SUM(总销量)总销量,SUM(总利润)总利润,SUM(总利润)/SUM(总销量) 毛利率 from #p4
where 机票张数<>0 and 酒店张数=0
and 总销量>=10000 and 总销量<20000
UNION ALL
select '销量大于20000' as 销量范围,COUNT(*)单位数量,SUM(总销量)总销量,SUM(总利润)总利润,SUM(总利润)/SUM(总销量) 毛利率 from #p4
where 机票张数<>0 and 酒店张数=0
and 总销量>=20000
UNION ALL
select '合计' as 销量范围,COUNT(*)单位数量,SUM(总销量)总销量,SUM(总利润)总利润,SUM(总利润)/SUM(总销量) 毛利率 from #p4
where 机票张数<>0 and 酒店张数=0
) t1



--纯酒店
select * from 
(select '销量小于10000' as 销量范围,COUNT(*)单位数量,SUM(总销量)总销量,SUM(总利润)总利润,SUM(总利润)/SUM(总销量) 毛利率 from #p4
where 酒店张数<>0 and 机票张数=0
and 总销量<10000
UNION ALL
select '销量10000-20000' as 销量范围,COUNT(*)单位数量,SUM(总销量)总销量,SUM(总利润)总利润,SUM(总利润)/SUM(总销量) 毛利率 from #p4
where 酒店张数<>0 and 机票张数=0
and 总销量>=10000 and 总销量<20000
UNION ALL
select '销量大于20000' as 销量范围,COUNT(*)单位数量,SUM(总销量)总销量,SUM(总利润)总利润,SUM(总利润)/SUM(总销量) 毛利率 from #p4
where 酒店张数<>0 and 机票张数=0
and 总销量>=20000
UNION ALL
select '合计' as 销量范围,COUNT(*)单位数量,SUM(总销量)总销量,SUM(总利润)总利润,SUM(总利润)/SUM(总销量) 毛利率 from #p4
where 酒店张数<>0 and 机票张数=0
) t2

--机票酒店
select * from 
(select '销量小于10000' as 销量范围,COUNT(*)单位数量,SUM(总销量)总销量,SUM(总利润)总利润,SUM(总利润)/SUM(总销量) 毛利率 from #p4
where 机票张数<>0 and 酒店张数<>0
and 总销量<10000
UNION ALL
select '销量10000-20000' as 销量范围,COUNT(*)单位数量,SUM(总销量)总销量,SUM(总利润)总利润,SUM(总利润)/SUM(总销量) 毛利率 from #p4
where 机票张数<>0 and 酒店张数<>0
and 总销量>=10000 and 总销量<20000
UNION ALL
select '销量大于20000' as 销量范围,COUNT(*)单位数量,SUM(总销量)总销量,SUM(总利润)总利润,SUM(总利润)/SUM(总销量) 毛利率 from #p4
where 机票张数<>0 and 酒店张数<>0
and 总销量>=20000
UNION ALL
select '合计' as 销量范围,COUNT(*)单位数量,SUM(总销量)总销量,SUM(总利润)总利润,SUM(总利润)/SUM(总销量) 毛利率 from #p4
where 机票张数<>0 and 酒店张数<>0
) t3


