select uc.Name, h.name,LastName+'/'+firstname+' '+MiddleName as ename,cr.Type,cr.CredentialNo
from homsomdb..Trv_UnitPersons up
left join homsomdb..Trv_Human h on h.ID=up.ID
left join homsomdb..Trv_Credentials cr on cr.HumanID=h.ID
left join homsomdb..Trv_UnitCompanies uc on uc.ID=up.CompanyID
where uc.CooperativeStatus in('1','2','3')
and uc.Cmpid in ('019234')
  and IsDisplay=1 

SELECT h.Name,h.Mobile FROM homsomDB..Trv_UPCollections_UnitPersons  up
left join homsomDB..Trv_Human h on h.ID=up.UnitPersonID
WHERE UPCollectionID='AA53871E-1086-4E90-954A-CFDF436FDF73' and h.IsDisplay='1'

SELECT *FROM homsomDB..Trv_UPCollections_UnitPersons 
WHERE UPCollectionID='AA53871E-1086-4E90-954A-CFDF436FDF73' 