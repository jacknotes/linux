SELECT t.���,t.�˿�����,p.CustomItem [�Զ�����],reason.ReasonDescription
FROM [EDB2].[dbo].['018781-2016-11-01$'] t
LEFT join homsomDB.dbo.Trv_DomesticTicketRecord rec ON t.���۵���=rec.recordNumber 
LEFT JOIN homsomDB..Trv_PnrInfos pnr ON rec.PnrinfoID=pnr.ID
LEFT JOIN homsomDB..Trv_TktBookings tkt ON pnr.ItktBookingID=tkt.ID 
LEFT JOIN homsomDB.dbo.Trv_itktBookings itk ON itk.ID=tkt.id
LEFT JOIN homsomDB..Trv_DeniedReason reason ON reason.ItktBookingID=itk.ID AND reason.ReasonType=1
LEFT JOIN homsomDB..Trv_Passengers p ON p.ItktBookingID = itk.ID  AND p.Name=t.�˿�����
ORDER BY t.���