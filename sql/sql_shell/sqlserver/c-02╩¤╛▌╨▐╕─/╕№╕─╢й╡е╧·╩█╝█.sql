SELECT TOP 1 facevalue,TotalPrice,* FROM homsomdb..Trv_ItktBookings
SELECT TOP 1 FaceValue,TotalPrice,* FROM homsomdb..Trv_ITktSeats



update homsomDB..Trv_ItktBookings set FaceValue=1230,TotalPrice=1280
--SELECT FaceValue,TotalPrice,* from homsomDB..Trv_ItktBookings 
where id='aba476a4-134e-461a-aac1-06776417b26e'
SELECT *FROM homsomDB..Trv_PnrInfos WHERE ItktBookingID='aba476a4-134e-461a-aac1-06776417b26e'

update homsomDB..Trv_ITktSeats set FaceValue=1230,TotalPrice=1280
--SELECT FaceValue,TotalPrice,* FROM homsomDB..Trv_ITktSeats 
WHERE PnrInfoID='5C2915D2-96EF-467A-9CB3-F13EECD19D3F'