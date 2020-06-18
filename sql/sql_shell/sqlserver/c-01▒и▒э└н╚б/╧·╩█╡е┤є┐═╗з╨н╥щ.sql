/*
select * from homsomDB..Trv_FlightTripartitePolicies
select top 100 RebateStr,* from homsomDB..Trv_ItktBookingSegs

康宝莱现在还要一个数据：
东航2018.7--12月 其中使用大客户协议张数占比    %，共计节约      元
最后两个问题：张数占比    %，共计节约      元
*/
select RebateStr,SUM(price) 销量,COUNT(c.id) 张数 
into #ccc
from Topway..tbcash C
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos pn on pn.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ItktBookingID=pn.ItktBookingID and c.ride+C.flightno=it.Flight
where
-- datetime>='2018-07-01'
--and datetime<'2019-01-01'
(ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and ride in ('MU','FM')
and cmpcode='020459'
and inf=0
and tickettype not in ('改期费', '升舱费','改期升舱')
group by RebateStr

select * from #ccc

--大客户协议

select SUM(销量) 合计,SUM(张数) 张数,(100-Discount)/100 折扣 from #ccc ccc
inner join homsomDB..Trv_FlightTripartitePolicies f on f.ID=ccc.RebateStr
group by Discount