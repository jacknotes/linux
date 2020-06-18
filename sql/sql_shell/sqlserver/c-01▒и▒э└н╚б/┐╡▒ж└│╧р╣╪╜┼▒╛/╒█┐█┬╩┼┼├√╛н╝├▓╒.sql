SELECT CABINFLAG,SUM(price) 合计销量不含税,SUM(CAST(priceinfo AS DECIMAL)) 合计全价不含税,COUNT(1) 合计张数,
AVG(price/CAST(priceinfo AS DECIMAL)) 平均折扣率  FROM (
SELECT 
CASE WHEN price/CAST(priceinfo AS DECIMAL) >1 THEN 1
	WHEN price/CAST(priceinfo AS DECIMAL) =1 THEN 2
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.95 AND price/CAST(priceinfo AS DECIMAL) <1 THEN 3
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.90 AND price/CAST(priceinfo AS DECIMAL) <0.95 THEN 4
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.85 AND price/CAST(priceinfo AS DECIMAL) <0.90 THEN 5
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.80 AND price/CAST(priceinfo AS DECIMAL) <0.85 THEN 6
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.75 AND price/CAST(priceinfo AS DECIMAL) <0.80 THEN 7
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.70 AND price/CAST(priceinfo AS DECIMAL) <0.75 THEN 8
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.65 AND price/CAST(priceinfo AS DECIMAL) <0.70 THEN 9
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.60 AND price/CAST(priceinfo AS DECIMAL) <0.65 THEN 10
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.55 AND price/CAST(priceinfo AS DECIMAL) <0.60 THEN 11
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.50 AND price/CAST(priceinfo AS DECIMAL) <0.55 THEN 12
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.45 AND price/CAST(priceinfo AS DECIMAL) <0.50 THEN 13
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.40 AND price/CAST(priceinfo AS DECIMAL) <0.45 THEN 14
	WHEN price/CAST(priceinfo AS DECIMAL) <0.40 THEN 15 END CABINFLAG,
totprice,price,priceinfo 
FROM Topway..tbcash T1 
WHERE T1.cmpcode = '020459'
AND T1.inf=0
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
) T
GROUP BY CABINFLAG

--select top 10 * from ehomsom..tbInfCabincode order by begdate desc



SELECT CABINFLAG,SUM(price) 合计销量不含税,SUM(CAST(priceinfo AS DECIMAL)) 合计全价不含税,COUNT(1) 合计张数,
AVG(price/CAST(priceinfo AS DECIMAL)) 平均折扣率   
FROM (
SELECT --T1.coupno,
CASE WHEN price/CAST(priceinfo AS DECIMAL) >1 THEN 1
	WHEN price/CAST(priceinfo AS DECIMAL) =1 THEN 2
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.95 AND price/CAST(priceinfo AS DECIMAL) <1 THEN 3
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.90 AND price/CAST(priceinfo AS DECIMAL) <0.95 THEN 4
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.85 AND price/CAST(priceinfo AS DECIMAL) <0.90 THEN 5
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.80 AND price/CAST(priceinfo AS DECIMAL) <0.85 THEN 6
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.75 AND price/CAST(priceinfo AS DECIMAL) <0.80 THEN 7
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.70 AND price/CAST(priceinfo AS DECIMAL) <0.75 THEN 8
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.65 AND price/CAST(priceinfo AS DECIMAL) <0.70 THEN 9
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.60 AND price/CAST(priceinfo AS DECIMAL) <0.65 THEN 10
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.55 AND price/CAST(priceinfo AS DECIMAL) <0.60 THEN 11
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.50 AND price/CAST(priceinfo AS DECIMAL) <0.55 THEN 12
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.45 AND price/CAST(priceinfo AS DECIMAL) <0.50 THEN 13
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.40 AND price/CAST(priceinfo AS DECIMAL) <0.45 THEN 14
	WHEN price/CAST(priceinfo AS DECIMAL) <0.40 THEN 15 END CABINFLAG,
totprice,price,priceinfo 
FROM Topway..tbcash T1 WITH (NOLOCK)
left join ehomsom..tbInfCabincode t on t.cabin=T1.nclass and T1.ride=t.code2 and T1.[datetime]>=t.begdate and T1.[datetime]<=t.enddate
and ((T1.begdate>=flightbegdate and T1.begdate<=flightenddate) or (T1.begdate>=flightbegdate2 and T1.begdate<=flightenddate2) 
or (T1.begdate>=flightbegdate3 and T1.begdate<=flightenddate3) or (T1.begdate>=flightbegdate4 and T1.begdate<=flightenddate4))
WHERE T1.cmpcode = '020459'
and t.cabintype like'%经济舱%'
and T1.coupno  not in ('AS001905163')
AND T1.inf=0
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
) T
GROUP BY CABINFLAG 

--select * from ehomsom..tbInfCabincode

select SUM(price)/SUM(convert(decimal(8,2),priceinfo)) from Topway..tbcash T1 WITH (NOLOCK)
left join ehomsom..tbInfCabincode t on t.cabin=T1.nclass and T1.ride=t.code2 and T1.[datetime]>=t.begdate and T1.[datetime]<=t.enddate
and ((T1.begdate>=flightbegdate and T1.begdate<=flightenddate) or (T1.begdate>=flightbegdate2 and T1.begdate<=flightenddate2) 
or (T1.begdate>=flightbegdate3 and T1.begdate<=flightenddate3) or (T1.begdate>=flightbegdate4 and T1.begdate<=flightenddate4))
WHERE T1.cmpcode = '020459'
and t.cabintype like'%经济舱%'
and T1.coupno  not in ('AS001905163')
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
and inf=0
