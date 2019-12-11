


SELECT DISTINCT hu.email FROM homsomdb..trv_human  hu
inner join homsomDB..Trv_UnitPersons on homsomDB..Trv_UnitPersons.ID=hu.id
inner join homsomdb..Trv_UnitCompanies cmp on cmp.ID=hu.companyid
WHERE hu.email LIKE '%@%' and (homsomDB..Trv_UnitPersons.Type='经办人' or homsomDB..Trv_UnitPersons.Type='负责人') and cmp.Type='A' and hu.IsDisplay=1
group by hu.email

