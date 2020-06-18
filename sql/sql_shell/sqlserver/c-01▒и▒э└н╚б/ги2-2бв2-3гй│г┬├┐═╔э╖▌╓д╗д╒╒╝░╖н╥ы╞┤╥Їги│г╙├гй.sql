--TMS常旅客
--拉取常旅客信息
IF OBJECT_ID('tempdb.dbo.#p') IS NOT NULL DROP TABLE #p
select uc.cmpid,uc.Name as cmpname,h.name,LastName+'/'+firstname+' '+MiddleName as ename,cr.Type,cr.CredentialNo
into #p
from Trv_UnitPersons up
left join Trv_Human h on h.ID=up.ID
left join Trv_Credentials cr on cr.HumanID=h.ID
left join Trv_UnitCompanies uc on uc.ID=up.CompanyID
where (h.CreateDate>='2018-05-13' and h.CreateDate<'2018-06-13')
--uc.Cmpid in (016938,019996,020051,020045) 
 and IsDisplay=1
--and cr.Type in (1,2)


select * from #p p
--将英文名赋值到中文名
update #p set name=ename where name=''
--身份证表
IF OBJECT_ID('tempdb.dbo.#sfz') IS NOT NULL DROP TABLE #sfz
select * 
into #sfz
from #p p
where type=1
--护照表
IF OBJECT_ID('tempdb.dbo.#hz') IS NOT NULL DROP TABLE #hz
select * 
into #hz
from #p p
where type=2
--最终表
IF OBJECT_ID('tempdb.dbo.#p1') IS NOT NULL DROP TABLE #p1
select p.cmpid as 单位编号,p.cmpname as 单位名称,p.name ,p.ename as 英文名,sfz.credentialno as 身份证,hz.credentialno as 护照 
into #p1
from #p p
left join #sfz sfz on sfz.cmpid=p.cmpid and sfz.name=p.name and sfz.credentialno=p.credentialno
left join #hz hz on hz.cmpid=p.cmpid and hz.name=p.name and hz.credentialno=p.credentialno

select * from #p1

--翻译拼音
SELECT *,CASE WHEN name<>'' and name NOT LIKE '%[0-9a-zA-Z]%' and left(name,2) not in (SELECT name FROM [EDB2].[dbo].[Compound surname]) THEN Topway.dbo.fn_GetQuanPin(STUFF(name,2,0,'/')) 
WHEN left(name,2)  in (SELECT name FROM [EDB2].[dbo].[Compound surname]) THEN Topway.dbo.fn_GetQuanPin(STUFF(name,3,0,'/'))
ELSE name END	
FROM #p1
ORDER BY 单位编号


--ERP国际常旅客
--拉取常旅客信息
IF OBJECT_ID('tempdb.dbo.#p2') IS NOT NULL DROP TABLE #p2
select pas.cmpid,m.cmpname,pas.name,pas.englishname,idType, s.idno
into #p2
from topway..tbCusPas pas
inner join topway..tbCusPasSub s on s.cusmenId=pas.CusmenId
inner join Topway..tbCompanyM m on m.cmpid=pas.cmpid
where --(ndatetime>='2018-05-14' and ndatetime<'2018-06-13') 
--and
pas.cmpid in ('019830')

--select * from #p2 p2
--将中文名赋值到英文名
update #p2 set englishname=name where englishname=''
--身份证表
IF OBJECT_ID('tempdb.dbo.#sfz2') IS NOT NULL DROP TABLE #sfz2
select cmpid,name,englishname,idno 
into #sfz2
from #p2 p2
where idtype=1
--护照表
IF OBJECT_ID('tempdb.dbo.#hz2') IS NOT NULL DROP TABLE #hz2
select cmpid,name,englishname,idno 
into #hz2
from #p2 p2
where idtype=2
--最终表
IF OBJECT_ID('tempdb.dbo.#p3') IS NOT NULL DROP TABLE #p3
select p2.cmpid as 单位编号,p2.cmpname as 单位名称,p2.name,p2.englishname as ename,sfz2.idno as 身份证,hz2.idno as 护照 
into #p3
from #p2 p2
left join #sfz2 sfz2 on sfz2.cmpid=p2.cmpid and sfz2.englishname=p2.englishname and sfz2.idno=p2.idno
left join #hz2 hz2 on hz2.cmpid=p2.cmpid and hz2.englishname=p2.englishname and hz2.idno=p2.idno



--select p3.*,COUNT(*) from #p3 p3
--left join topway..tbcash c on (c.idno=p3.身份证 or c.idno=p3.护照) and p3.单位编号=c.cmpcode and c.ride in ('MU','FM')
--where name not like ('%CHD%')
--and name not like ('%MSTR%')
--and name not like ('%MISS%')
--and name not like ('%INF%')
--and name not like ('%STU%')
--AND right(name,2) not like ('%SD%')
--and name not like ('%(%')
--group by p3.单位编号,p3.单位名称,p3.name,p3.ename,p3.身份证,p3.护照

select DISTINCT * from #p3
where name not like ('%CHD%')
	and name not like ('%MSTR%')
	and name not like ('%MISS%')
	and name not like ('%INF%')
	and name not like ('%(%)%')
	and right(name,2)<>'SD' 
	and right(name,3)<>'STU' 

----翻译拼音
--SELECT *,CASE WHEN englishname<>'' and englishname NOT LIKE '%[0-9a-zA-Z]%' and left(englishname,2) not in (SELECT name FROM [EDB2].[dbo].[Compound surname]) THEN Topway.dbo.fn_GetQuanPin(STUFF(name,2,0,'/')) 
--WHEN left(englishname,2)  in (SELECT name FROM [EDB2].[dbo].[Compound surname]) THEN Topway.dbo.fn_GetQuanPin(STUFF(name,3,0,'/'))
--ELSE englishname END	
--FROM #p3
--ORDER BY cmpid



--select * from #p1 p1
--where name not like ('%CHD%')
--and name not like ('%MSRT%')
--and name not like ('%MISS%')
--and name not like ('%INF%')
--UNION ALL SELECT * from #p3 p3
--where name not like ('%CHD%')
--and name not like ('%MSRT%')
--and name not like ('%MISS%')
--and name not like ('%INF%')
--order by p1.单位编号

--个人
UNION ALL 
select DISTINCT ''as 单位编号,''as 单位名称,name as 中文名,'' as ename,idno as 身份证,idno as 护照 from Topway..tbCusmem
where name not like ('%CHD%')
	and name not like ('%MSTR%')
	and name not like ('%MISS%')
	and name not like ('%INF%')
	and name not like ('%(%)%')
	and right(name,2)<>'SD' 
	and right(name,3)<>'STU' 
	and name<>''