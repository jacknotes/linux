SELECT p1.PNR,t2.Departing as 起飞时间,p.Name as 姓名 FROM homsomDB..Trv_Passengers p
left join homsomDB..Trv_ITktSeats s on s.PassengerID=p.ID
left join homsomDB..Trv_ItktBookings t on t.ID=p.ItktBookingID
left join homsomDB..Trv_ItktBookingSegs t2 on t2.ItktBookingID=t.ID
left join homsomDB..Trv_PnrInfos p1 on p1.ID=s.PnrInfoID
where s.ModifyDate>'2019-01-07' and type in('2','3')  and t2.Departing>'2019-01-07' 