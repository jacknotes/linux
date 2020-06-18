select info.CMPID,m.cmpname from  CompanyInvoiceInfo info
inner join tbCompanyM m on m.cmpid=info.CMPID
where info.HotelInvoiceType like ('%2%')
