select up.Cmpid as ��λ���,up.Name as ��λ����,hp.Name as Э������,hp.ServiceCharge as ����� from Trv_UnitCompanies up
left join Trv_HotelNormalPolicies hp on hp.UnitCompanyID=up.ID
where up.Type='A' and hp.Name like ('%�Ƶ�ǰ̨�Ը�%')
--and hp.ServiceCharge<>0
order by Cmpid


