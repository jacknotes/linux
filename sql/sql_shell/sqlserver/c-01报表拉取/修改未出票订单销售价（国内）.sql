select b.* 
--update homsomDB..Trv_ItktBookings set FaceValue=177,TotalPrice=177,Tax=0
from homsomDB..Trv_ItktBookings b
left join homsomDB..Trv_TktBookings  f on b.ID=f.ID
left join homsomDB..Trv_Travels a on a.ID=b.TravelID 
where a.TravelID='2018121002846'



SELECT i.* 
--UPDATE homsomDB..Trv_ITktSeats SET FaceValue=177,TotalPrice=177,Tax=0
FROM homsomDB..Trv_ITktSeats i 
INNER JOIN homsomDB..Trv_PnrInfos p ON i.PnrInfoID=p.ID
INNER JOIN homsomDB..Trv_ItktBookings b ON p.ItktBookingID=b.ID
INNER JOIN homsomDB..Trv_Travels t ON b.TravelID=t.ID
WHERE t.TravelID='2018121002846'