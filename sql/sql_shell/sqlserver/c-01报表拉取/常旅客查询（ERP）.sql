IF OBJECT_ID('tempdb.dbo.#p') IS NOT NULL DROP TABLE #p2
select pas.cmpid,m.cmpname,pas.name,pas.englishname,idType, s.idno
into #p2
from topway..tbCusPas pas
left join topway..tbCusPasSub s on s.cusmenId=pas.CusmenId
left join Topway..tbCompanyM m on m.cmpid=pas.cmpid
where (ndatetime<'2017-07-20')
and pas.cmpid='017945'

select * from #p2 p2
--将中文名赋值到英文名
update #p2 set englishname=name where englishname=''
--身份证表
IF OBJECT_ID('tempdb.dbo.#p') IS NOT NULL DROP TABLE #sfz2
select cmpid,name,englishname,idno 
into #sfz2
from #p2 p2
where idtype=1
--护照表
IF OBJECT_ID('tempdb.dbo.#p') IS NOT NULL DROP TABLE #hz2
select cmpid,name,englishname,idno 
into #hz2
from #p2 p2
where idtype=2
--最终表
IF OBJECT_ID('tempdb.dbo.#p') IS NOT NULL DROP TABLE #p3
select p2.cmpid as 单位编号,p2.cmpname as 单位名称,p2.name,p2.englishname as ename,sfz2.idno as 身份证,hz2.idno as 护照 
into #p3
from #p2 p2
left join #sfz2 sfz2 on sfz2.cmpid=p2.cmpid and sfz2.englishname=p2.englishname and sfz2.idno=p2.idno
left join #hz2 hz2 on hz2.cmpid=p2.cmpid and hz2.englishname=p2.englishname and hz2.idno=p2.idno


select * from #p3