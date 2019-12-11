SELECT DISTINCT up.Cmpid,up.Name FROM homsomDB..Trv_ItktBookings i 
LEFT JOIN homsomDB..Trv_Travels t ON i.TravelID=t.ID
LEFT JOIN homsomDB..Trv_CompanyTravels c ON t.id=c.ID
LEFT JOIN homsomDB..Trv_TktBookings ti ON i.ID=ti.ID
left join homsomDB..Trv_UnitCompanies up on up.ID=c.UnitCompanyID
WHERE t.CreateDate >='2017-01-01' AND ISNULL(ti.Purpose,'')<>''
GROUP BY c.UnitCompanyID,up.Cmpid,up.Name