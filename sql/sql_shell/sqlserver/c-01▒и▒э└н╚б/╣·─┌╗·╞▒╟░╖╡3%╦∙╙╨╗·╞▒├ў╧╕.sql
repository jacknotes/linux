--2、天纳克 (UC016448) 2018全年，国内机票前返3%所有机票明细（去退改） 
select coupno,datetime,tcode+ticketno 票号,c.route 行程,ride 航司, nclass,totprice from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs t on t.ItktBookingID=p.ItktBookingID
left join homsomDB..Trv_RebateRelations r on t.RebateStr=r.FlightNormalPolicyID 
where cmpcode='016448' and [Percent]=3
and datetime>='2018-01-01' and datetime<'2019-01-01' AND c.inf=0 AND c.tickettype='电子票'  and reti=''
order by datetime
