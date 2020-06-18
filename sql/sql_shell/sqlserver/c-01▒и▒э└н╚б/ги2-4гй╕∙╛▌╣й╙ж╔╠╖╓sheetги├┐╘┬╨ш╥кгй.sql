select cmpcode as 单位编号,m.cmpname as 单位名称,c.pasname as 乘机人,c.idno as 证件号, t_source as 供应商来源,COUNT(*)
from tbcash c
inner join tbCompanyM m on m.cmpid=c.cmpcode
where (datetime>='2017-11-13' and datetime<'2017-12-12')
and inf=1
and ride in ('MU','FM')
and pasname not like ('%CHD%')
and pasname not like ('%MSRT%')
and pasname not like ('%MISS%')
and pasname not like ('%INF%')
group by cmpcode,m.cmpname,c.pasname,c.idno,t_source
order by t_source

/*
1.EXCEL插入数据透视表，选中全部
2.将供应商来源拖入筛选，将其他拖入行
3.菜单【设计】、分类汇总选择【不显示分类汇总】
菜单【设计】、报表布局选择【以表格形式显示】
分析-选项-显示报表筛选页-（供应商来源）确定
*/

select cmpcode as 单位编号,m.cmpname as 单位名称,c.pasname as 乘机人,c.idno as 证件号, t_source as 供应商来源
from tbcash c
inner join tbCompanyM m on m.cmpid=c.cmpcode
where (datetime>='2017-11-13' and datetime<'2017-12-12')
and inf=1
and ride in ('MU','FM')
and (pasname like ('%CHD%')
or pasname like ('%MSRT%')
or pasname like ('%MISS%')
or pasname like ('%INF%'))
order by t_source