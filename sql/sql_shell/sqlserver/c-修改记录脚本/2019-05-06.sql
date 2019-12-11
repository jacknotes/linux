
/*收客户退票金额应该是0元 HS应付应该是-209元  是不是写返了？
利润应该是0元
退票单号3660 退票单号3661 改好麻烦跟我说下，谢谢
*/
select * from Topway..Train_ReturnTicket 
--update Topway..Train_ReturnTicket set SupplierFee=209,Fee=0
where ID in('3660','3661')

--麻烦在账单后加入所提醒的最低价航班号以及起降时间
select top 100 * from homsomDB..Trv_ItktBookingSegs

select RecordNumber,l.Price,it.Departing,it.Arriving,it.Flight   from homsomDB..Trv_DomesticTicketRecord d
left join homsomDB..Trv_PnrInfos p on p.id=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ItktBookingID=p.ItktBookingID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=it.ID
where RecordNumber in ('AS002362610',
'AS002368897',
'AS002369159',
'AS002372134',
'AS002372319',
'AS002376291',
'AS002376464',
'AS002376992',
'AS002377048',
'AS002377453',
'AS002377643',
'AS002379209',
'AS002379238',
'AS002379418',
'AS002380674',
'AS002381285',
'AS002382369',
'AS002382524',
'AS002383226',
'AS002384562',
'AS002385711',
'AS002385715',
'AS002388708',
'AS002389157',
'AS002389276',
'AS002389404',
'AS002391489',
'AS002391731',
'AS002392059',
'AS002392667',
'AS002392669',
'AS002394544',
'AS002395099',
'AS002395181',
'AS002395923',
'AS002396794',
'AS002396804',
'AS002397317',
'AS002400946',
'AS002401427',
'AS002401556',
'AS002402132',
'AS002403776',
'AS002405139',
'AS002405180',
'AS002408149',
'AS002408492',
'AS002412421',
'AS002414283',
'AS002414293',
'AS002415772',
'AS002417805',
'AS002420210',
'AS002421335',
'AS002422423',
'AS002422431',
'AS002423441',
'AS002423448',
'AS002424299',
'AS002425903',
'AS002427408',
'AS002427618',
'AS002427701',
'AS002428195',
'AS002431521',
'AS002431709',
'AS002431877',
'AS002432772',
'AS002432774',
'AS002433531',
'AS002433837',
'AS002435225',
'AS002435233',
'AS002435831',
'AS002436632',
'AS002438767',
'AS002439732')
and l.Price<>''

--账单撤销
select HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement set HotelSubmitStatus=2
where BillNumber='020585_20190401'

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='携程官网分销联盟'
where CoupNo='PTW081449'

--修改服务费
select fuprice,profit,* from Topway..tbcash 
--update Topway..tbcash set fuprice=10
where coupno in ('AS002400598',
'AS002400598',
'AS002401931',
'AS002401931',
'AS002406379',
'AS002406379',
'AS002413214',
'AS002413214',
'AS002417277',
'AS002417277',
'AS002417277',
'AS002417688',
'AS002422572',
'AS002422572',
'AS002435789',
'AS002435789',
'AS002435789',
'AS002440600',
'AS002440600',
'AS002440600')



--流程审核人
select * from ApproveBase..App_DefineBase  
--update ApproveBase..App_DefineBase  set Signer='0601'
where AppNo='wf0126' and Signer=601

--会务收款单信息
select Skstatus,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set Skstatus=2
where ConventionId='1407'

select Status,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Status=2
where ConventionId='1407'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='020787_20190401'

--行程单、特殊票价
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='需打印行程单'
where coupno ='AS002404585'


select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='需打印行程单'
where coupno in ('AS002370995','AS002371000','AS002371002','AS002384417','AS002384419')

--多余机场删除
--select * from homsomDB..Trv_Cities where ID='878CC28E-97C6-424C-ADB1-2F7ACA9B0A47'

select * 
--delete
from homsomDB..Trv_Airport where Code='CYI' and ID='FA660F1D-7F2B-4B41-8D81-CEDAA537CF0E'

--账单撤销
select HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set HotelSubmitStatus=2
where BillNumber='019442_20190401'

--财务账单核销
SELECT SalesOrderState,* FROM Topway..AccountStatement 
--update Topway..AccountStatement  set SalesOrderState=2
WHERE BillNumber='018661_20190301'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set  totsprice=2785,profit=477
where coupno='AS002443255'

--退票状态
select status2,* from Topway..tbReti 
--update Topway..tbReti  set status2=2
where reno='9266465'

--退票状态
select status2,* from Topway..tbReti 
--update Topway..tbReti  set status2=2
where reno ='0431211'


--账单撤销
select HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set HotelSubmitStatus=2
where BillNumber='017007_20190201'

select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=2
where BillNumber='019061_20190401'

--火车票销售价信息
SELECT TotFuprice,TotPrice,TotSprice,* FROM  Topway..tbTrainTicketInfo 
--update Topway..tbTrainTicketInfo  set TotFuprice=238.5,TotPrice=238.5,TotSprice=238.5
where CoupNo='RS000023040'

select RealPrice,SettlePrice from Topway..tbTrainUser 
--update Topway..tbTrainUser set RealPrice=238.5,SettlePrice=238.5
where TrainTicketNo =(SELECT ID FROM  Topway..tbTrainTicketInfo where CoupNo='RS000023040')

--旅游预算单信息
select top 100 * from topway..TravelRequirement_DemandOrder where DemandOrderOrderNo in('TR11630')

select top 10 * from Topway..tbTravelBudget where TrvId in('29962')

select top 100 * from homsomDB..Trv_UnitCompies_Sales
select top 100* from homsomDB..SSO_Users
select top 100* from homsomDB..Trv_UnitCompanies

select tcode+ticketno,cmpcode,isnull(ss.Name,''),isnull(m.indate,''),
(case  when m.indate>='2018-05-06' THEN '新客户' when m.indate<'2018-05-06' then '老客户' else '' end) 新老客户 
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.cmpid=c.cmpcode
left join Topway..tbCompanyM m on m.cmpid=c.cmpcode
left join homsomDB..Trv_UnitCompies_Sales s on s.UnitCompayID=u.ID
left join homsomDB..SSO_Users ss on ss.ID=s.EmployeeID
where tcode+ticketno in
('7815396942576',
'7813573975596',
'7813573975641',
'7813572377437',
'7813572377751',
'7813573976323',
'7813573974693',
'7813543689045',
'7813573977330',
'7813573976943',
'7813573976943',
'7813573976989',
'7812071242751',
'7813573975208',
'7813573975205',
'7813573977298',
'7813579540913',
'7813571077460',
'7813571077517',
'7813542738275',
'7813572376681',
'7813573976506',
'7813573976506',
'7813572375866',
'7813573977455',
'7813573976470',
'7813573976470',
'7813579540371',
'7813573975418',
'7812899201587',
'7813573976808',
'7813571076367',
'7813571076366',
'7813573974995',
'7813573974995',
'7813573977398',
'7813573978207',
'7813579540987',
'7813579540988',
'7813573976136',
'7813573975970',
'7813579541310',
'7813579541311',
'7813573977908',
'7813573976372',
'7813573977238',
'7813573974921',
'7813573974921',
'7813560723580',
'7813560723574',
'7813560723575',
'7813560723579',
'7813560723578',
'7813560723581',
'7813560723577',
'7813560723576',
'7813560721999',
'7813560723597',
'7813560723598',
'7813573974488',
'7813579541443',
'7813560724068',
'7813560724068',
'7813579540848',
'7813560722795',
'7813579540042',
'7813401436659',
'7815378190058',
'7813572376032',
'7813572376908',
'7813572376677',
'7813572377231',
'7813572376478',
'7813572376477',
'7813573973307',
'7813573973304',
'7813541112239',
'7813572375424',
'7813571076888',
'7813571076884',
'7813571076415',
'7813573973367',
'7813573973368')
 