--预订未出票
SELECT t.AdminStatus,tt.TravelID,p.PNR,tt.TCName,i.CreatorTC,t.CreateBy,* FROM homsomDB..Trv_TktBookings t 
 LEFT JOIN homsomDB..Trv_ItktBookings i ON t.ID=i.ID
 LEFT JOIN homsomDB..Trv_Travels tt ON i.TravelID=tt.ID
 LEFT JOIN homsomDB..Trv_PnrInfos p ON i.ID=p.ItktBookingID
 WHERE (tt.TCName='路希' or i.CreatorTC='0664') AND t.AdminStatus NOT IN(5,6,7)--排除出票成功、通知取消、用户取消