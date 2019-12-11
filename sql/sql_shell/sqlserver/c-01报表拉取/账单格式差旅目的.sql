select datetime as 出票日期,begdate as 起飞日期,c.coupno as 销售单号,pasname as 乘客姓名,c.route as 线路,tair+flightno as 航班号,tcode+ticketno as 票号,c.tax as 税收,totprice as  销售价,reti as 退票单号 
,(select DepName from homsomdb..Trv_CompanyStructure where ID in (select CompanyDptId from homsomDB..Trv_UnitPersons where ID in (select id from homsomdb..Trv_Human where Name=c.pasname and companyid in (select id from homsomDB..Trv_UnitCompanies where Cmpid='019837')))) as 部门
,(select name from homsomDB..Trv_CostCenter where ID in (select CostCenterID from homsomDB..Trv_UnitPersons where ID in (select id from homsomdb..Trv_Human where Name=c.pasname and companyid in (select id from homsomDB..Trv_UnitCompanies where Cmpid='019837')))) as 成本中心
,tkt.Purpose [差旅目的]
from tbcash c
LEFT join homsomDB.dbo.Trv_DomesticTicketRecord rec ON C.coupno=rec.recordNumber 
LEFT JOIN homsomDB..Trv_PnrInfos pnr ON rec.PnrinfoID=pnr.ID
LEFT JOIN homsomDB..Trv_TktBookings tkt ON pnr.ItktBookingID=tkt.ID 
LEFT JOIN homsomDB.dbo.Trv_itktBookings itk ON itk.ID=tkt.id
where cmpcode='019837'
and (datetime>='2017-03-21' and datetime<'2017-09-21')
order by datetime