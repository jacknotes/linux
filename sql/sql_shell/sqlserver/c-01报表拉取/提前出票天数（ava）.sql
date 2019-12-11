--��ǰ��Ʊ����
SELECT DAYSFLAG,SUM(totprice) �ϼ�����,sum(price) ����˰����,COUNT(1) �ϼ�����,SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) ���ò�ƽ���ۿ���   FROM
(Select CASE WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 0 AND 2 THEN 1
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 3 AND 4 THEN 2
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 5 AND 6 THEN 3
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 7 AND 8 THEN 4
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 9 AND 10 THEN 5
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 11 AND 12 THEN 6
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 13 AND 14 THEN 7
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) >14 THEN 8 END DAYSFLAG,
	totprice,price,priceinfo
FROM Topway..tbcash T1 WITH (NOLOCK)
INNER JOIN ehomsom..tbInfCabincode T2 WITH (NOLOCK) ON T1.ride=T2.code2 AND T1.nclass=T2.cabin
WHERE T1.cmpcode ='020459'
AND T2.begdate<=T1.[datetime] AND T2.enddate>=T1.[datetime]
AND ((T2.flightbegdate<=T1.begdate AND T2.flightenddate>=T1.begdate) OR
(T2.flightbegdate2<=T1.begdate AND T2.flightenddate2>=T1.begdate) OR
(T2.flightbegdate3<=T1.begdate AND T2.flightenddate3>=T1.begdate) OR
(T2.flightbegdate4<=T1.begdate AND T2.flightenddate4>=T1.begdate))
AND T2.cabintype like '%���ò�%'
AND T1.inf=0
AND T1.tickettype NOT IN ('���ڷ�', '���շ�','��������')
and t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181101','020459_20181201')) t
GROUP BY DAYSFLAG
order by DAYSFLAG 
