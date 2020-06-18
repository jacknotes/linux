select TotalPrice,FaceValue,SalesProfit,* from homsomDB..Trv_ItktBookings where TravelID='063F3094-5885-4BB2-8722-19055EF32CED'
update homsomDB..Trv_ItktBookings set TotalPrice=1420,FaceValue=1370,SalesProfit=1370 where TravelID='063F3094-5885-4BB2-8722-19055EF32CED'
select TotalPrice,FaceValue,SalesProfit,Fare,* from homsomDB..Trv_ITktSeats where PnrInfoID='57E2C50B-0E2E-4F37-9DFC-489200B70D51'
update homsomDB..Trv_ITktSeats set TotalPrice=1420,FaceValue=1370,SalesProfit=1370 where PnrInfoID='57E2C50B-0E2E-4F37-9DFC-489200B70D51'