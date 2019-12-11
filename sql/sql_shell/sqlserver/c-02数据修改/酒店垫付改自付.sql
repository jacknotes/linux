--¾Æµêµæ¸¶¸Ä×Ô¸¶
select AdvanceMethod,PayMethod,AdvanceStatus,PayStatus,AdvancePayNo,PayNo,AdvanceDate,PaySubmitDate from Topway..tbHtlcoupRefund 
--update Topway..tbHtlcoupRefund  set AdvanceMethod=0,PayMethod=2,AdvanceStatus=0,PayStatus=3,PayNo='2018121922001498140520990603',AdvancePayNo=null,PaySubmitDate='2018-12-19 14:05:57.000',AdvanceDate=null
where CoupNo='PTW073438'

select cwstatus,owe,vpay,opername1,vpayinfo,oth2 from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set cwstatus=1,owe=0,vpay=149
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo='PTW073438')

select AdvanceNumber,AdvanceName,AdvanceStatus,AdvanceDate,PayStatus,PayDate from HotelOrderDB..HTL_Orders 
--update HotelOrderDB..HTL_Orders set AdvanceNumber='',AdvanceName='',PayStatus=3,AdvanceStatus=0,PayDate='2018-12-19 14:05:57.000',AdvanceDate=null
where CoupNo='PTW073438'

select AdvancePayNo,PayNo,AdvanceMethod,PayMethod,* from HotelOrderDB..HTL_OrderSettlements 
--update HotelOrderDB..HTL_OrderSettlements  set PayNo='2018121922001498140520990603',AdvancePayNo=null,PayMethod=2,AdvanceMethod=null
where OrderID in(Select OrderID from HotelOrderDB..HTL_Orders where CoupNo='PTW073438')