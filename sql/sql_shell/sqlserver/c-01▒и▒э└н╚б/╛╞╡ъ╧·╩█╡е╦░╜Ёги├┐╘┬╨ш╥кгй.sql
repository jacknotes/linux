SELECT yf.cmpid as ��λ���,m.cmpname as ��λ����,CoupNo as ���۵���,InvoiceTax as ˰��
  FROM [Topway].[dbo].[tbHtlcoupYf] yf
  left join tbCompanyM m on m.cmpid=yf.cmpid
  where datetime>='2017-12-01' and datetime<'2018-01-01'
  and InvoiceTax<>0