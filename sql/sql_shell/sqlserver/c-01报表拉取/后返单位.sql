--select top 100 ServiceCharge,OnlineServiceCharge, * from homsomDB..Trv_FlightNormalPolicies

--机票
select uc.Cmpid,uc.Name from homsomDB..Trv_UnitCompanies as uc
inner join homsomDB..Trv_FlightNormalPolicies as fn on uc.ID=fn.UnitCompanyID
inner join homsomDB..Trv_RebateRelations re on re.FlightNormalPolicyID=fn.ID
inner join homsomDB..Trv_Dictionaries as ds on fn.CommissionTypeID=ds.ID
where uc.CooperativeStatus in (1,2,3) and fn.EndTime>='2019-05-15' and fn.CountryType=1
and ds.Name like'%后返%' and uc.Cmpid not in('017449','000006')
and re.[Percent]<>0
UNION 
select uc.Cmpid,uc.Name from homsomDB..Trv_UnitCompanies as uc
inner join homsomDB..Trv_FlightTripartitePolicies as fn on uc.ID=fn.UnitCompanyID
inner join homsomDB..Trv_RebateRelations re on re.FlightNormalPolicyID=fn.ID
inner join homsomDB..Trv_Dictionaries as ds on fn.CommissionTypeID=ds.ID
where uc.CooperativeStatus in (1,2,3) and fn.EndTime>='2019-05-15' and fn.CountryType=1
and ds.Name like'%后返%' and uc.Cmpid not in('000003','000006')
and re.[Percent]<>0
UNION 
select uc.Cmpid,uc.Name from homsomDB..Trv_UnitCompanies as uc
inner join homsomDB..Trv_FlightAdvancedPolicies as fn on uc.ID=fn.UnitCompanyID
inner join homsomDB..Trv_RebateRelations re on re.FlightNormalPolicyID=fn.ID
inner join homsomDB..Trv_Dictionaries as ds on fn.CommissionTypeID=ds.ID
where uc.CooperativeStatus in (1,2,3) and fn.EndTime>='2019-05-15' and fn.CountryType=1
and ds.Name like'%后返%' and uc.Cmpid not in('000003','000006')
and re.[Percent]<>0
union
select uc.Cmpid,uc.Name from homsomDB..Trv_UnitCompanies as uc
inner join homsomDB..Trv_IntlFlightNormalPolicies as inf on uc.ID=inf.UnitCompanyID
inner join homsomDB..Trv_IntlRebateRelations as inr on inf.CommissionTypeID=inr.ID
where inr.RebateType=1 and uc.CooperativeStatus in (1,2,3) and inf.EndTime>='2019-05-15'
and uc.Cmpid not in('000003','000006')
and inr.[Percent]<>0

--酒店
select uc.Cmpid,uc.Name from homsomDB..Trv_UnitCompanies as uc
inner join homsomDB..Trv_HotelNormalPolicies as hn on uc.ID=hn.UnitCompanyID
where uc.CooperativeStatus in (1,2,3) and hn.ValidEndTime>='2019-05-15' 
and (hn.[Percent]<>0 or hn.ServiceCharge<>0 or hn.OnlineServiceCharge<>0)
and uc.Cmpid not in('000003','000006')
group by uc.Cmpid,uc.Name
