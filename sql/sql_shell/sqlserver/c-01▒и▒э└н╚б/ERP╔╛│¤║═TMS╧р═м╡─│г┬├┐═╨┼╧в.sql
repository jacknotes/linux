select CustID,* from homsomDB..Trv_UnitCompanies up
inner join homsomDB..Trv_UnitPersons p on p.CompanyID=up.ID
inner join homsomDB..Trv_Human h on h.ID=p.ID and h.IsDisplay=1
where up.Cmpid='017688' and h.Name='ÖìæÂ'

select custid,* from Topway..tbCusholderM where cmpid='017688' and custname='ÖìæÂ'


select * from Topway..tbcash where cmpcode='017688' and custid='D371193'