SELECT yf.cmpid as 单位编号,m.cmpname as 单位名称,CoupNo as 销售单号,InvoiceTax as 税金
  FROM [Topway].[dbo].[tbHtlcoupYf] yf
  left join tbCompanyM m on m.cmpid=yf.cmpid
  where datetime>='2017-12-01' and datetime<'2018-01-01'
  and InvoiceTax<>0