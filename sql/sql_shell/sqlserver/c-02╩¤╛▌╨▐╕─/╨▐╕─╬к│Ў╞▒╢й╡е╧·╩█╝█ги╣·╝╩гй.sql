/*
��Ʊ����2018-12-10��δ��Ʊ������IF00017448��ԭ���۵���5090Ԫ�������۵���5096Ԫ��ԭ˰��908Ԫ����˰��902Ԫ��ԭ���ۼ�5998Ԫ�������ۼ�5998Ԫ�� ��Ʊ����2018-12-10��
δ��Ʊ������IF00017446��ԭ���۵���5090Ԫ/�ˣ������۵���5096Ԫ/�ˣ�ԭ˰��908Ԫ/�ˣ���˰��902Ԫ/�ˣ�ԭ���ۼ�5998Ԫ/�ˣ������ۼ�5998Ԫ/�ˡ�
*/
SELECT SalesPrice,* FROM homsomDB..Intl_BookingOrders 
--UPDATE homsomDB..Intl_BookingOrders SET Tax=902,SalesPrice=5998,amount=5998
WHERE OrderNo='IF00017448'

select SalesUnitPrice,Tax,*
--update homsomDB..Intl_Settlements set SalesUnitPrice=5096,Tax=902,SalesPrice=5998
from homsomDB..Intl_Settlements where OrderId in (select id from homsomDB..Intl_BookingOrders where OrderNo='IF00017448')