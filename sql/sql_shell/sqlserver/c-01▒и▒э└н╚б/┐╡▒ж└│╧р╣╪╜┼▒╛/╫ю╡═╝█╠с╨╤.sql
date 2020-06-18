/*
国内经济舱部分，请按附件内9-12月账单提供以下数据：
1.总违规次数，最低票价间相差金额，各类Reason Code次数和占比
2.部门违规概况分析：各部门违规次数，违规占比
3.员工预订行为分析：低价未采纳占比，退改签占比，违规率         
4.员工违规情况分析（前10位）：姓名 部门  违规次数
5.低价提醒节支分析：月份（9--12），机票消费金额，机票张数，低价提醒次数，潜在可节省金额

PS:9月账单中，部分有最低价，无Reason Code的机票直接剔除
*/

--1.总违规次数，最低票价间相差金额，各类Reason Code次数和占比
IF OBJECT_ID('tempdb.dbo.#lowp') IS NOT NULL DROP TABLE #lowp
select distinct SUBSTRING(ModifyBillNumber,8,6) 月份,Department,i2.OriginName 出发机场,i2.DestinationName 到达机场,tcode+ticketno 票号,i2.AdultPrice 销售单价,isnull(l.Price,'') 最低价,isnull(l.UnChoosedReason,'') Reasoncode
into #lowp
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber 
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=p.ItktBookingID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%经济舱%'
and c.tickettype='电子票'
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274')
and isnull(l.Price,'')>0
order by tcode+ticketno

--违规明细
select 月份,票号,销售单价,最低价,Reasoncode from #lowp
order by 月份
--次数和相差金额
select COUNT(1) 违规次数,SUM(销售单价-最低价) 相差金额,Reasoncode from #lowp
group by Reasoncode
order by 违规次数 desc

--2.部门违规概况分析：各部门违规次数，违规占比
--违规明细
select 月份,票号,Department,销售单价,最低价,Reasoncode,COUNT(1) 次数 
from #lowp
group by Department,销售单价,最低价,Reasoncode,月份,票号
order by 月份

--部门
select Department,COUNT(1) 次数 from #lowp
group by Department
order by 次数 desc

--3.员工预订行为分析：低价未采纳占比，退改签占比，违规率  
IF OBJECT_ID('tempdb.dbo.#lowp1') IS NOT NULL DROP TABLE #lowp1
select distinct SUBSTRING(ModifyBillNumber,8,6) 月份,Department,i2.OriginName 出发机场,i2.DestinationName 到达机场,tcode+ticketno 票号,tickettype 类型,reti 退票单号,i2.AdultPrice 销售单价,isnull(l.Price,'') 最低价,isnull(l.UnChoosedReason,'') Reasoncode
into #lowp1
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber 
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=p.ItktBookingID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%经济舱%'
and c.tickettype='电子票'
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274')
order by tcode+ticketno


select * from #lowp1
order by 月份

--select * from Topway..tbReti t1
--left join Topway..tbcash t2 on t1.reno=t2.reti and t1.ticketno=t2.ticketno


--4.员工违规情况分析（前10位）：姓名 部门  违规次数
IF OBJECT_ID('tempdb.dbo.#lowp2') IS NOT NULL DROP TABLE #lowp2
select distinct SUBSTRING(ModifyBillNumber,8,6) 月份,Department,pasname,i2.OriginName 出发机场,i2.DestinationName 到达机场,tcode+ticketno 票号,i2.AdultPrice 销售单价,isnull(l.Price,'') 最低价,isnull(l.UnChoosedReason,'') Reasoncode
into #lowp2
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber 
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=p.ItktBookingID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%经济舱%'
and c.tickettype='电子票'
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274')
and isnull(l.Price,'')>0
order by tcode+ticketno

select top 10 Department,pasname,COUNT(1) 次数 from #lowp2
group by Department,pasname
order by 次数 desc

--5.低价提醒节支分析：月份（9--12），机票消费金额，机票张数，低价提醒次数，潜在可节省金额