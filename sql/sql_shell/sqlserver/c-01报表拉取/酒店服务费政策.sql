select up.Cmpid as 单位编号,up.Name as 单位名称,hp.Name as 协议名称,hp.ServiceCharge as 服务费 from Trv_UnitCompanies up
left join Trv_HotelNormalPolicies hp on hp.UnitCompanyID=up.ID
where up.Type='A' and hp.Name like ('%酒店前台自付%')
--and hp.ServiceCharge<>0
order by Cmpid


