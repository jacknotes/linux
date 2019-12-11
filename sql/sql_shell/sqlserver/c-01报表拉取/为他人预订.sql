


select distinct t.Name as '1',b.Name ,c.Name  from (

select b.Name,f.* from homsomDB..Trv_UnitPersons a
left join homsomDB..Trv_Human b on a.ID=b.ID
left join homsomDB..Trv_UnitCompanies c on a.CompanyID=c.ID
left join homsomDB..Trv_UPSettings d on a.UPSettingID=d.ID
left join homsomDB..Trv_BookingCollections e on d.BookingCollectionID=e.ID
left join homsomDB..Trv_UPCollections_UnitPersons f on e.ID=f.UPCollectionID
where b.Name='≤‹√Œ—≈' and Cmpid='019234'

)t
left join homsomDB..Trv_UnitPersons up on t.UnitPersonID=up.ID
left join homsomDB..Trv_Human b on up.ID=b.ID
left join homsomDB..Trv_UnitCompanies c on up.CompanyID=c.ID
