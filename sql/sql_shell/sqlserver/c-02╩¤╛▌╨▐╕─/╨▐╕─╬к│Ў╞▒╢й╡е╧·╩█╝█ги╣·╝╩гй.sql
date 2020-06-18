/*
出票日期2018-12-10、未出票订单号IF00017448、原销售单价5090元，现销售单价5096元，原税收908元，现税收902元，原销售价5998元，现销售价5998元。 出票日期2018-12-10、
未出票订单号IF00017446、原销售单价5090元/人，现销售单价5096元/人，原税收908元/人，现税收902元/人，原销售价5998元/人，现销售价5998元/人。
*/
SELECT SalesPrice,* FROM homsomDB..Intl_BookingOrders 
--UPDATE homsomDB..Intl_BookingOrders SET Tax=902,SalesPrice=5998,amount=5998
WHERE OrderNo='IF00017448'

select SalesUnitPrice,Tax,*
--update homsomDB..Intl_Settlements set SalesUnitPrice=5096,Tax=902,SalesPrice=5998
from homsomDB..Intl_Settlements where OrderId in (select id from homsomDB..Intl_BookingOrders where OrderNo='IF00017448')