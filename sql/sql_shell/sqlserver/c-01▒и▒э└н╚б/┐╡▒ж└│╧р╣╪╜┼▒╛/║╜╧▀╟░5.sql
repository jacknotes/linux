--航线数据
SELECT  T1.[route] 行程,avg(price) 平均销售价,SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) 经济舱平均折扣率
FROM Topway..tbcash T1 WITH (NOLOCK)
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=T1.coupno
left join homsomDB..Trv_PnrInfos pn on pn.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ItktBookingID=pn.ItktBookingID and T1.ride+T1.flightno=it.Flight
WHERE --T1.cmpcode = '020459'
it.FlightClass like'%经济%'
AND T1.inf=0
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
and datetime>='2018-07-01'
and datetime<'2019-01-01'
and T1.[route] in('北京首都-上海虹桥','上海虹桥-北京首都','上海虹桥-成都','太原-上海虹桥','成都-上海虹桥')
--and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.[route] 