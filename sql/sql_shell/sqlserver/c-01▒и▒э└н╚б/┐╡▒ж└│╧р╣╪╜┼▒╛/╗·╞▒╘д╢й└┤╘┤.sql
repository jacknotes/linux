/*网单=1
手工导单=2
电话预订=3
空白导单=4
app=5
宝库=7
官网=6
旅游内采=8
会务内采=9
微信预订=10
wap预订=11
*/
--PC端 国内

select sum(price) 销量,COUNT(c.id) 张数 from Topway..tbcash  c
left join homsomDB..Trv_ItktBookings i on c.BaokuID=i.ID
where (ModifyBillNumber in ('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
--and i.BookingSource='1'
--and i.BookingSource in ('5','10','11')
--and i.BookingSource in ('2','3','4')
and inf=0
and tickettype='电子票'

--PC端 国际
select sum(price) 销量,COUNT(c.id) 张数 from Topway..tbcash  c
--inner join homsomDB..Intl_BookingOrders i on c.recno=i.PNR
where (ModifyBillNumber in ('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and c.custid not in('D618538')))
and cmpcode='020459'
--and i.BookingSource='1'
--and i.BookingSource in ('5','10','11')
--and i.BookingSource in ('2','3','4')
and tickettype='电子票'
AND tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND c.route NOT LIKE '%改期%' 
AND c.route NOT LIKE '%升舱%'
and inf=1