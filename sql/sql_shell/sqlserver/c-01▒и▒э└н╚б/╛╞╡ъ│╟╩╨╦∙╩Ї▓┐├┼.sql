--酒店数据表格预付
select prdate as 预定时间,hotel as 酒店名称,CityName as 城市,d.dep+d.team as '所属部门(组)',opername1 as 业务顾问,od.ConfirmPerson as 产品支持人,yf.nights*pcs as 间夜数,price as 金额 
from tbHtlcoupYf yf
inner join HotelOrderDB..HTL_Orders od on od.CoupNo=yf.CoupNo
inner join HotelOrderDB..HTL_OrderHotels oh on oh.OrderID=od.OrderID
inner join Emppwd d on d.empname=opername1
where prdate>='2018-01-01' and prdate<'2019-01-01'
and yf.status<>'-2'
order by prdate

--酒店数据表格自付
select datetime as 预定时间,hotel as 酒店名称,CityName as 城市,d.dep+d.team as '所属部门(组)',opername1 as 业务顾问,od.ConfirmPerson as 产品支持人,coup.nights*pcs as 间夜数,price as 金额 
from tbHotelcoup coup
inner join HotelOrderDB..HTL_Orders od on od.CoupNo=coup.CoupNo
inner join HotelOrderDB..HTL_OrderHotels oh on oh.OrderID=od.OrderID
inner join Emppwd d on d.empname=opername1
where datetime>='2018-01-01' and datetime<'2019-01-01'
and coup.status<>'-2'
order by datetime