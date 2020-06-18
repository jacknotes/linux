 
IF OBJECT_ID('tempdb..#国内数据总集合') IS NOT NULL
            DROP TABLE #国内数据总集合;
 
 SELECT T1.pasname AS 乘客姓名,
        CONVERT(VARCHAR(100), T2.Departing, 23) AS 出发时间,
        T7.Name AS 出发城市,
        T9.Name AS 到达城市,
        T1.totprice AS 金额
        INTO #国内数据总集合
 FROM   dbo.tbcash T1 WITH ( NOLOCK )
        LEFT JOIN homsomDB..Trv_DomesticTicketRecord T4 ON T1.coupno = T4.RecordNumber
        LEFT JOIN homsomDB..Trv_ItktBookingSegments_PnrInfos T5 ON T5.PnrInfoID = T4.PnrInfoID
        LEFT JOIN homsomDB..Trv_ItktBookingSegs T2 WITH ( NOLOCK ) ON T5.ItktBookingSegID = T2.ID
        LEFT JOIN homsomDB..Trv_LowerstPrices T3 WITH ( NOLOCK ) ON T2.ID = T3.ItktBookingSegID
        LEFT JOIN homsomDB..Trv_Airport T6 ON T2.DepartingAirport=T6.Code
        LEFT JOIN homsomDB..Trv_Cities T7 ON T6.CityID=T7.ID
        LEFT JOIN homsomDB..Trv_Airport T8 ON T2.ArrivalAirport=T8.Code
        LEFT JOIN homsomDB..Trv_Cities T9 ON T8.CityID=T9.ID
 WHERE  T1.inf = 0
        AND T1.cmpcode = '017888'
        AND T1.datetime >= '2018-07-01'
        AND T1.datetime < '2019-07-01'
        AND T1.tickettype='电子票'
 ORDER BY datetime DESC;


SELECT * FROM #国内数据总集合

SELECT TT1.行程,CAST((TT1.金额/TT1.数量)AS INT)AS 均价  FROM (
SELECT (T1.出发城市+'-'+T1.到达城市) AS  行程,SUM(T1.金额) AS 金额,COUNT(1) AS 数量 
FROM #国内数据总集合 T1 WITH ( NOLOCK )

GROUP BY T1.出发城市+'-'+T1.到达城市
)TT1

IF OBJECT_ID('tempdb..#国际数据总集合') IS NOT NULL
            DROP TABLE #国际数据总集合;


SELECT T1.route,
SUBSTRING(t1.route,1,3) route1,
(SELECT T3.Name FROM homsomDB..Trv_Airport T2 LEFT JOIN homsomDB..Trv_Cities T3 ON T2.CityID=T3.ID WHERE SUBSTRING(t1.route,1,3)=T2.Code) CITYNAME1,
(SELECT T3.CountryCode FROM homsomDB..Trv_Airport T2 LEFT JOIN homsomDB..Trv_Cities T3 ON T2.CityID=T3.ID WHERE SUBSTRING(t1.route,1,3)=T2.Code) CountryCode1,

(SELECT T3.Name FROM homsomDB..Trv_Airport T2 LEFT JOIN homsomDB..Trv_Cities T3 ON T2.CityID=T3.ID WHERE SUBSTRING(t1.route,5,3)=T2.Code) CITYNAME2,
(SELECT T3.CountryCode FROM homsomDB..Trv_Airport T2 LEFT JOIN homsomDB..Trv_Cities T3 ON T2.CityID=T3.ID WHERE SUBSTRING(t1.route,5,3)=T2.Code) CountryCode2,

(SELECT T3.Name FROM homsomDB..Trv_Airport T2 LEFT JOIN homsomDB..Trv_Cities T3 ON T2.CityID=T3.ID WHERE SUBSTRING(t1.route,9,3)=T2.Code) CITYNAME3,
(SELECT T3.CountryCode FROM homsomDB..Trv_Airport T2 LEFT JOIN homsomDB..Trv_Cities T3 ON T2.CityID=T3.ID WHERE SUBSTRING(t1.route,9,3)=T2.Code) CountryCode3,

(SELECT T3.Name FROM homsomDB..Trv_Airport T2 LEFT JOIN homsomDB..Trv_Cities T3 ON T2.CityID=T3.ID WHERE SUBSTRING(t1.route,13,3)=T2.Code) CITYNAME4,
(SELECT T3.CountryCode FROM homsomDB..Trv_Airport T2 LEFT JOIN homsomDB..Trv_Cities T3 ON T2.CityID=T3.ID WHERE SUBSTRING(t1.route,13,3)=T2.Code) CountryCode4,

(SELECT T3.Name FROM homsomDB..Trv_Airport T2 LEFT JOIN homsomDB..Trv_Cities T3 ON T2.CityID=T3.ID WHERE SUBSTRING(t1.route,17,3)=T2.Code) CITYNAME5,
(SELECT T3.CountryCode FROM homsomDB..Trv_Airport T2 LEFT JOIN homsomDB..Trv_Cities T3 ON T2.CityID=T3.ID WHERE SUBSTRING(t1.route,17,3)=T2.Code) CountryCode5,

(SELECT T3.Name FROM homsomDB..Trv_Airport T2 LEFT JOIN homsomDB..Trv_Cities T3 ON T2.CityID=T3.ID WHERE SUBSTRING(t1.route,21,3)=T2.Code) CITYNAME6,
(SELECT T3.CountryCode FROM homsomDB..Trv_Airport T2 LEFT JOIN homsomDB..Trv_Cities T3 ON T2.CityID=T3.ID WHERE SUBSTRING(t1.route,21,3)=T2.Code) CountryCode6,

t1.pasname,
T1.totprice
INTO #国际数据总集合
FROM dbo.tbcash T1 
WHERE T1.inf = 1
        AND T1.cmpcode = '017888'
        AND T1.datetime >= '2018-07-01'
        AND T1.datetime < '2019-07-01'
        AND T1.tickettype='电子票'
		AND T1.route NOT LIKE '%退票费%'
        
IF OBJECT_ID('tempdb..#国际数据总集合_行程价格') IS NOT NULL
            DROP TABLE #国际数据总集合_行程价格;

SELECT 
(
ISNULL(CITYNAME1,'') 
+CASE WHEN ISNULL(CITYNAME2,'')<>'' THEN '-'+CITYNAME2 ELSE '' END
+CASE WHEN ISNULL(CITYNAME3,'')<>'' THEN '-'+CITYNAME3 ELSE '' END
+CASE WHEN ISNULL(CITYNAME4,'')<>'' THEN '-'+CITYNAME4 ELSE '' END
+CASE WHEN ISNULL(CITYNAME5,'')<>'' THEN '-'+CITYNAME5 ELSE '' END
+CASE WHEN ISNULL(CITYNAME6,'')<>'' THEN '-'+CITYNAME6 ELSE '' END
) AS 行程,
totprice
INTO #国际数据总集合_行程价格
FROM #国际数据总集合

SELECT TT.行程,CAST((TT.金额/TT.数量)AS INT)AS 均价 FROM
(

SELECT 
行程,
SUM(totprice) AS 金额,
COUNT(1) AS 数量 
FROM #国际数据总集合_行程价格 
WHERE 行程<>''
GROUP BY 行程

)TT


        
IF OBJECT_ID('tempdb..#国家集合') IS NOT NULL
            DROP TABLE #国家集合;
        SELECT DISTINCT T7.CountryCode
        INTO #国家集合
        FROM    dbo.tbcash T1 WITH(NOLOCK)
                LEFT JOIN topway..tbFiveCoupInfo T2 WITH(NOLOCK) ON T1.coupno = T2.CoupNo
                LEFT JOIN homsomdb..Intl_BookingOrders T3 WITH(NOLOCK) ON T2.OrderId = T3.Id
                LEFT JOIN homsomdb..Intl_BookingSegements T4 WITH(NOLOCK) ON T3.Id = T4.BookingOrderId
                LEFT JOIN homsomdb..Intl_BookingLegs T5 WITH(NOLOCK) ON T4.Id = T5.BookingSegmentId
                LEFT JOIN homsomDB..Trv_Airport T6 ON T5.Code1=T6.Code
                LEFT JOIN homsomDB..Trv_Cities T7 ON t6.CityID=T7.ID
                WHERE T1.inf = 1
        AND T1.cmpcode = '017888'
        AND T1.datetime >= '2018-07-01'
        AND T1.datetime < '2019-07-01'
        AND T1.tickettype='电子票'
		AND T1.route NOT LIKE '%退票费%'
		
	SELECT CountryCode,CAST((TT.金额/TT.数量)AS INT)AS 均价 FROM
(	
		SELECT T1.CountryCode,
SUM(T2.totprice) AS 金额,
COUNT(1) AS 数量 FROM #国家集合 T1
		LEFT JOIN #国际数据总集合 T2 ON T1.CountryCode= T2.CountryCode1 
										OR T1.CountryCode= T2.CountryCode2 
										OR T1.CountryCode= T2.CountryCode3 
										OR T1.CountryCode= T2.CountryCode4 
										OR T1.CountryCode= T2.CountryCode5 
										OR T1.CountryCode= T2.CountryCode6 
										GROUP BY T1.CountryCode
										)TT
