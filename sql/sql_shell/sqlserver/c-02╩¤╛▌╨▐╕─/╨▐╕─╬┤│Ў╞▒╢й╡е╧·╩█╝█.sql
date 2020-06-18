select FaceValue,TotalPrice,Tax,AirTax,FullPrice,IBEPrice,SettlementPrice,* 
from homsomDB..Trv_ITktSeats where ID='8348C622-8E95-446E-8093-A8AB016D0221'

update homsomDB..Trv_ITktSeats set FaceValue=720,TotalPrice=720,Tax=0,AirTax=0,FullPrice=720,IBEPrice=720,SettlementPrice=620 where ID='8348C622-8E95-446E-8093-A8AB016D0221'

select FaceValue,TotalPrice,Tax,AirTax,FullPrice,IBEPrice,SettlementPrice,* 
from homsomDB..Trv_ItktBookings where ID='42780319-5E32-4D99-BC90-A8AB016D0221'

update homsomDB..Trv_ItktBookings set FaceValue=720,TotalPrice=720,Tax=0,AirTax=0,FullPrice=720,IBEPrice=720,SettlementPrice=620 where ID='42780319-5E32-4D99-BC90-A8AB016D0221'

select AdultPrice,FullPrice,PolicyDiscount,FaceValue,* 
from homsomDB..Trv_ItktBookingSegs where ItktBookingID='42780319-5E32-4D99-BC90-A8AB016D0221'

update homsomDB..Trv_ItktBookingSegs set AdultPrice=720,FullPrice=720,PolicyDiscount=720,FaceValue=720 where ItktBookingID='42780319-5E32-4D99-BC90-A8AB016D0221'

select AdminStatus,* from homsomDB..Trv_TktBookings where id='42780319-5E32-4D99-BC90-A8AB016D0221'
update homsomDB..Trv_TktBookings set AdminStatus=3 where id='42780319-5E32-4D99-BC90-A8AB016D0221'

select b.ID,* from homsomDB..Trv_Travels as a
left join homsomDB..Trv_ItktBookings as b on a.ID=b.TravelID 
left join homsomDB..Trv_TktBookings as f on b.ID=f.ID
left join homsomDB..Trv_PnrInfos as c on b.ID=c.ItktBookingID
left join homsomDB..Trv_ITktSeats as d on c.ID=d.PnrInfoID
left join homsomDB..Trv_DomesticTicketRecord as e on d.ID=e.PnrInfoID
where a.TravelID='2018032202321'

