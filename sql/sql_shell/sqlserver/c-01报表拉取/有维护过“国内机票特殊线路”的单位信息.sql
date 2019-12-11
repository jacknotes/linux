
--所有单位客户中，机票佣金管理，有维护过“国内机票特殊线路”的单位信息。
--报表要素： 单位名称、该单位下的常旅客名单数。

select up.Cmpid,up.Name,COUNT(*)
from homsomdb..Trv_UnitCompanies up
inner join Topway..tbCompanyM m on m.cmpid=up.Cmpid
inner join homsomdb..Trv_UnitPersons p on p.CompanyID=up.ID
inner join homsomdb..Trv_Human h on h.ID=p.ID and IsDisplay=1
where p.CompanyID in (SELECT UnitCompanyID FROM homsomDB..Trv_FlightAdvancedPolicies WHERE   Name='国内机票特殊线路') and up.Cmpid='020530'
and m.hztype not in (0,4)
group by Up.cmpid,up.Name



--既有自签政策（二方、三方），又有特殊政策的客户名单
select uc.Cmpid,Name from homsomDB..Trv_UnitCompanies uc
inner join Topway..tbCompanyM m on m.cmpid=uc.Cmpid
where m.hztype not in (0,4) and  uc.ID in(
select UnitCompanyID from homsomDB..Trv_FlightAdvancedPolicies where (getdate() between StartTime and EndTime) group by UnitCompanyID
) and uc.ID in (
select UnitCompanyID from homsomDB..Trv_FlightTripartitePolicies where (convert(date,getdate()) between CONVERT(varchar(100),SUBSTRING (NewStartTime,0, CHARINDEX(',', NewStartTime)),23) and CONVERT(varchar(100),SUBSTRING (NewendTime,0, CHARINDEX(',', NewendTime)),23)) group by UnitCompanyID
) group by uc.ID,uc.Cmpid,Name

