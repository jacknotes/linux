select up.cmpid as 单位编号,up.Name as 单位名称,h.Name as 姓名,h.Mobile as 手机,k.Name as 职位级别,h.ID from homsomDB..Trv_UCSettings uc
inner join Trv_UnitCompanies up on up.UCSettingID=uc.ID
left join Trv_UnitPersons p on p.CompanyID=up.ID
left join Trv_Human h on h.ID=p.ID and IsDisplay=1
left join Trv_UPRanks k on k.ID=p.UPRankID
where Enabled=1 and (uc.NeedVetting=1 or NeedHotelVetting=1)
and h.Name is not null
and h.Name<>''
order by Cmpid

