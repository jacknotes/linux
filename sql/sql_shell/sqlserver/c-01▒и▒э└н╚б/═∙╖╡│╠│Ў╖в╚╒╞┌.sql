select t.coupno as ���۵���,pasname as �˻���,i1.ArrivalTime as ��������,route as �г�,i1.Name,i1.Name1,i1.Code,i1.Code1,* from Topway..tbcash t
left join Topway..tbFiveCoupInfo t1 on t1.CoupNo=t.coupno
left join homsomDB..Intl_BookingSegements i on i.BookingOrderId=t1.OrderId
left join homsomDB..Intl_BookingLegs i1 on i1.BookingSegmentId=i.Id
where datetime>='2018-02-26' and datetime<'2019-02-11' and cmpcode='019360' and inf=1
order by t.coupno