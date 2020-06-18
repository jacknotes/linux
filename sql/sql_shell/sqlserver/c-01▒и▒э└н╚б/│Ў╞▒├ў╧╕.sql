SELECT datetime as 出票日期,begdate as 起飞日期,coupno as 销售单号,pasname as 乘客姓名,
route as 线路,tcode+ticketno as 票号,ride+flightno as 航班号,priceinfo as 全价,'' as 折扣率,'' as 原价,price as 销售单价,'' as  协议优惠,tax as 税收,
'' as 返佣金额,totprice  as 销售价,reti as 退票单号,c2.DepName as 部门,'' as 提前出票天数, nclass as 舱位,CostCenter as 成本中心
FROM tbcash c
left join homsomDB..Trv_UnitCompanies u on c.cmpcode=u.Cmpid
left join homsomDB..Trv_UnitPersons u2 on u2.CompanyID=u.ID
left join homsomDB..Trv_Human h on h.ID=u2.ID
left join homsomDB..Trv_CompanyStructure c2 on c2.ID=u2.CompanyDptId
--left join homsomDB..Trv_UnitCompanies t1 on t1.Cmpid=c.cmpcode
--left join homsomDB..Trv_UnitPersons t2 on t2.CompanyID=t1.ID
--left join homsomDB..Trv_CompanyStructure t3 on t3.ID=t2.CompanyDptId
WHERE c.datetime>='2018-07-01' AND c.datetime<'2019-01-01'
and c.cmpcode='016448' 
order by inf

select DepName,* from homsomdb..Trv_CompanyStructure where id in (select CompanyDptId from homsomDB..Trv_UnitPersons t3 inner join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID 
where t4.IsDisplay=1 and t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='016448'))



SELECT p.ItktBookingID,(s.Fare-s.FaceValue) AS '协议优惠',s.FaceValue,s.Fare 
FROM homsomDB..Trv_ITktSeats s 
LEFT JOIN homsomDB..Trv_PnrInfos p ON s.PnrInfoID=p.ID
LEFT JOIN homsomDB..Trv_ItktBookings i ON p.ItktBookingID=i.ID
LEFT JOIN homsomDB..Trv_CompanyTravels c ON i.TravelID=c.ID
LEFT JOIN homsomDB..Trv_TktBookings t ON i.ID=t.ID
WHERE s.FaceValue<>s.Fare AND c.UnitCompanyID IN (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid = '016448')
AND s.CreateDate>='2018-07-01' and s.CreateDate<'2019-01-01'
--AND t.TicketSourceType=1 AND (s.Fare-s.FaceValue)>=0

select * from homsomDB..Trv_Human where 