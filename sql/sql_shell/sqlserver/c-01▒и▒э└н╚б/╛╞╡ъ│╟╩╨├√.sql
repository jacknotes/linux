--�Ƶ����ݱ��Ԥ��
select prdate as Ԥ��ʱ��,hotel as �Ƶ�����,CityName as ����,d.dep+d.team as '��������(��)',opername1 as ҵ�����,od.ConfirmPerson as ��Ʒ֧����,yf.nights*pcs as ��ҹ��,price as ��� 
from tbHtlcoupYf yf
inner join HotelOrderDB..HTL_Orders od on od.CoupNo=yf.CoupNo
inner join HotelOrderDB..HTL_OrderHotels oh on oh.OrderID=od.OrderID
inner join Emppwd d on d.empname=opername1
where prdate>='2018-01-01' and prdate<'2019-01-01'
and yf.status<>'-2'
order by prdate

--�Ƶ����ݱ���Ը�
select datetime as Ԥ��ʱ��,hotel as �Ƶ�����,CityName as ����,d.dep+d.team as '��������(��)',opername1 as ҵ�����,od.ConfirmPerson as ��Ʒ֧����,coup.nights*pcs as ��ҹ��,price as ��� 
from tbHotelcoup coup
inner join HotelOrderDB..HTL_Orders od on od.CoupNo=coup.CoupNo
inner join HotelOrderDB..HTL_OrderHotels oh on oh.OrderID=od.OrderID
inner join Emppwd d on d.empname=opername1
where datetime>='2018-01-01' and datetime<'2019-01-01'
and coup.status<>'-2'
order by datetime



SELECT CoupNo,* FROM HotelOrderDB..HTL_Orders --WHERE OrderID='3B917DE9-3395-4D34-9C14-403726BC281E'
  SELECT OrderID,CityName,* FROM HotelOrderDB..HTL_OrderHotels
  SELECT * FROM Topway..tbHtlcoupYf
  select * from tbhtlyfchargeoff
  
  select  * from Topway..Emppwd  where depdetail='����ҵ�����'