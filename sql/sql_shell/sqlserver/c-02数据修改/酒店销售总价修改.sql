--�Ƶ����۵� �����ܼ� �����Ϊ-5600 �����ܼ� �����Ϊ-5867 �����������Ϊ14
select price,sprice,totprofit,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set price='-5600',sprice='-5867',totprofit='14'
where CoupNo='PTW078138'
--select price,sprice,totprofit,* from Topway..tbHtlcoupYf where CoupNo='PTW076453'
select totprice,owe,* from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set totprice='-5600',owe='-5600'
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo='PTW078138')

select TotalPrice,* from HotelOrderDB..HTL_Orders 
--update HotelOrderDB..HTL_Orders set TotalPrice='-5600'
where CoupNo='PTW078138'

select * from HotelOrderDB..HTL_Orders  where CoupNo='PTW078138'

select JsPrice,* from Topway..tbTrvJS 
--update Topway..tbTrvJS  set JsPrice='40201.6'
where TrvId='029360' and CoupId=(Select Id from Topway..tbHtlcoupYf where CoupNo='PTW078138')