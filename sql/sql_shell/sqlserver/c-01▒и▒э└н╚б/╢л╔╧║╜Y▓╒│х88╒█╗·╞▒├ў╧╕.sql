--1、天纳克（UC016448）2018全年，东上航Y舱冲88折机票明细（去退改）
select coupno,datetime,tcode+ticketno 票号,c.route 行程,ride 航司, nclass,totprice from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs t on t.ItktBookingID=p.ItktBookingID
--left join homsomDB..Trv_RebateRelations r on t.RebateStr=r.FlightNormalPolicyID 
where cmpcode='016448' --and [Percent]=3
and datetime>='2018-01-01' and datetime<'2019-01-01' AND c.inf=0 AND c.tickettype='电子票' AND c.originalprice>c.price AND c.ride IN('FM','MU') and reti=''
AND  CONVERT(DECIMAL(18,2),c.price/c.originalprice)=0.88