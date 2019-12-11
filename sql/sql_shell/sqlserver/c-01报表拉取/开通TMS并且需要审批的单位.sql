select up.cmpid as ��λ���,up.Name as ��λ����,h.Name as ����,h.Mobile as �ֻ�,k.Name as ְλ����,h.ID from homsomDB..Trv_UCSettings uc
inner join Trv_UnitCompanies up on up.UCSettingID=uc.ID
left join Trv_UnitPersons p on p.CompanyID=up.ID
left join Trv_Human h on h.ID=p.ID and IsDisplay=1
left join Trv_UPRanks k on k.ID=p.UPRankID
where Enabled=1 and (uc.NeedVetting=1 or NeedHotelVetting=1)
and h.Name is not null
and h.Name<>''
order by Cmpid

