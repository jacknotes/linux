SELECT * FROM dbo.tbcash T1
WHERE T1.datetime>='2019-06-01' AND T1.datetime<='2019-12-10' AND T1.cmpcode='019956' AND T1.pasname='YEH/RICHARD'


SELECT  *
FROM    ( SELECT    T1.coupno AS 销售单号 ,
                    T1.pasname AS 乘客姓名 ,
                    T2.DepartCityName AS '城市（从）' ,
                    T2.ArrivalCityName AS '城市（到）' ,
                    T2.Flight AS 航班号 ,
                    LEFT(CONVERT(VARCHAR(100), T2.Departing, 120), 16) AS 起飞时间
          FROM      dbo.tbcash T1 WITH ( NOLOCK )
                    LEFT JOIN homsomDB..Trv_DomesticTicketRecord T4 ON T1.coupno = T4.RecordNumber
                    LEFT JOIN homsomDB..Trv_ItktBookingSegments_PnrInfos T5 ON T5.PnrInfoID = T4.PnrInfoID
                    LEFT JOIN homsomDB..Trv_ItktBookingSegs T2 WITH ( NOLOCK ) ON T5.ItktBookingSegID = T2.ID
          WHERE     T2.Departing >= '2019-06-01 00:00:00'
                    AND T2.Departing <= '2019-12-10 23:59:59'
                    AND T1.cmpcode = '019956'
                    AND T1.pasname = 'YEH/RICHARD'
                    AND T1.inf = 0
                    AND T1.tickettype = '电子票'
                    AND NOT EXISTS ( SELECT TOP 1
                                            1
                                     FROM   dbo.tbReti T9
                                     WHERE  T1.coupno = T9.coupno
                                            AND T1.ticketno = T9.ticketno
                                            AND ( T9.status2 = 2
                                                  OR T9.status2 = 7
                                                  OR T9.status2 = 8
                                                ) )
          UNION ALL
          SELECT    T1.coupno AS 销售单号 ,
                    T1.pasname AS 乘客姓名 ,
                    T5.CityName1 AS '城市（从）' ,
                    T5.CityName2 AS '城市（到）' ,
                    T5.Code + T5.FlightNo AS 航班号 ,
                    LEFT(CONVERT(VARCHAR(100), T5.DepartureTime, 120), 16) AS 起飞时间
          FROM      tbcash T1 WITH ( NOLOCK )
                    LEFT JOIN Topway..tbFiveCoupInfo T2 WITH ( NOLOCK ) ON T1.coupno = T2.CoupNo
                    LEFT JOIN homsomDB..Intl_BookingOrders T3 WITH ( NOLOCK ) ON T2.OrderId = T3.Id
                    LEFT JOIN homsomDB..Intl_BookingSegements T4 WITH ( NOLOCK ) ON T3.Id = T4.BookingOrderId
                    LEFT JOIN homsomDB..Intl_BookingLegs T5 WITH ( NOLOCK ) ON T4.Id = T5.BookingSegmentId
          WHERE     T5.DepartureTime >= '2019-06-01 00:00:00'
                    AND T5.DepartureTime <= '2019-12-10 23:59:59'
                    AND T1.cmpcode = '019956'
                    AND T1.pasname = 'YEH/RICHARD'
                    AND T1.inf = 1
                    AND T1.tickettype = '电子票'
                    AND NOT EXISTS ( SELECT TOP 1
                                            1
                                     FROM   dbo.tbReti T9
                                     WHERE  T1.coupno = T9.coupno
                                            AND T1.ticketno = T9.ticketno
                                            AND ( T9.status2 = 2
                                                  OR T9.status2 = 7
                                                  OR T9.status2 = 8
                                                ) )
        ) TT
ORDER BY TT.起飞时间 ASC;