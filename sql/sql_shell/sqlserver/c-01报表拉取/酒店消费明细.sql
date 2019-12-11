select yf.cmpid as 单位编号,m.cmpname as 单位名称,hotel as 酒店名称,pasname as 入住人,beg_date as 入住日期,end_date as 退房日期,yf.fwprice as 服务费,CostCenter as 成本中心
,nights*pcs as 间夜,prdate as 打印日期,price as 销售价,f.totprice as 应收金额
from tbHtlcoupYf yf
inner join tbCompanyM m on m.cmpid=yf.cmpid
inner join tbhtlyfchargeoff f on f.coupid=yf.id
where yf.cmpid in ('')
and (prdate>='' and prdate<'')

