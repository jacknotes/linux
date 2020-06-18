select c.cmpcode as 单位编号,m.cmpname as 单位名称,c.pasname as 乘机人,c.idno as 证件号
,SUM(totsprice) as 结算价合计
,case uc.IsSepPrice when 0 then '不可申请' when 1 then '可以申请' else '' end as 特殊票价
from topway..tbcash c
left join topway..tbCompanyM m on m.cmpid=c.cmpcode
left join homsomDB..Trv_UnitCompanies uc on uc.Cmpid=c.cmpcode
where c.datetime>='2018-01-01' and c.datetime<'2018-12-18'
and tickettype='电子票'
and m.hztype not in (0,4)
and inf=0
group by c.cmpcode,m.cmpname,c.pasname,c.idno,uc.IsSepPrice 
order by c.cmpcode
