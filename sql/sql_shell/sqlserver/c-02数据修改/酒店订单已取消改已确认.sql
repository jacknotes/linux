select status,* from tbHtlcoupYf where CoupNo in ('PTW036422')
update tbHtlcoupYf set status=1 where CoupNo in ('PTW036422')

select Status,* from HotelOrderDB.dbo.HTL_Orders where CoupNo in ('PTW036422')
update HotelOrderDB.dbo.HTL_Orders set Status=40 where CoupNo in ('PTW036422')