
select * from topway..tbConventionJS
where id in (select TrvJSID from homsomDB..Trv_TktBookings
where id in (select ItktBookingID from  homsomDB..Trv_PnrInfos
where id in (select PnrInfoID from homsomDB..Trv_DomesticTicketRecord
WHERE     (RecordNumber = 'AS001368614'))))

update topway..tbConventionJS set Jstatus=4 where id in (select TrvJSID from homsomDB..Trv_TktBookings
where id in (select ItktBookingID from  homsomDB..Trv_PnrInfos
where id in (select PnrInfoID from homsomDB..Trv_DomesticTicketRecord
WHERE     (RecordNumber = 'AS001368615'))))