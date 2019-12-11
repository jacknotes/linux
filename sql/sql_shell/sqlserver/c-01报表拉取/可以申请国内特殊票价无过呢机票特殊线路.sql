--可以申请国内特殊票价且无国内机票特殊线路（在合作）
select u.Cmpid as UC ,u.Name as 单位名称 from homsomDB..Trv_UnitCompanies u
left join Topway..tbCompanyM t on t.cmpid=u.Cmpid
where t.hztype  not in (0,4)
and u.ID not in (SELECT UnitCompanyID FROM homsomDB..Trv_FlightAdvancedPolicies WHERE   Name='国内机票特殊线路')
and u.IsSepPrice=1