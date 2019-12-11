--非工作日设置
--查询
SELECT     *
FROM        Topway..T_HolidayDate
--新增
--="UNION ALL SELECT '" &B2&"' AS HolidayDate,'" &C2&"' AS HolidayName"
insert into Topway..T_HolidayDate(HolidayDate,HolidayName)
SELECT '2019-01-01' AS HolidayDate,'元旦' AS HolidayName
UNION ALL SELECT '2019-01-05' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-01-06' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-01-12' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-01-13' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-01-19' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-01-20' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-01-26' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-01-27' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-02-04' AS HolidayDate,'春节' AS HolidayName
UNION ALL SELECT '2019-02-05' AS HolidayDate,'春节' AS HolidayName
UNION ALL SELECT '2019-02-06' AS HolidayDate,'春节' AS HolidayName
UNION ALL SELECT '2019-02-07' AS HolidayDate,'春节' AS HolidayName
UNION ALL SELECT '2019-02-08' AS HolidayDate,'春节' AS HolidayName
UNION ALL SELECT '2019-02-09' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-02-10' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-02-16' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-02-17' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-02-23' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-02-24' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-03-02' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-03-03' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-03-09' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-03-10' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-03-16' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-03-17' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-03-23' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-03-24' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-03-30' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-03-31' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-04-05' AS HolidayDate,'清明节' AS HolidayName
UNION ALL SELECT '2019-04-06' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-04-07' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-04-13' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-04-14' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-04-20' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-04-21' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-04-27' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-04-28' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-05-01' AS HolidayDate,'劳动节' AS HolidayName
UNION ALL SELECT '2019-05-04' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-05-05' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-05-11' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-05-12' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-05-18' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-05-19' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-05-25' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-05-26' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-06-01' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-06-02' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-06-07' AS HolidayDate,'端午节' AS HolidayName
UNION ALL SELECT '2019-06-08' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-06-09' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-06-15' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-06-16' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-06-22' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-06-23' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-06-29' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-06-30' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-07-06' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-07-07' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-07-13' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-07-14' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-07-20' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-07-21' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-07-27' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-07-28' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-08-03' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-08-04' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-08-10' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-08-11' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-08-17' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-08-18' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-08-24' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-08-25' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-08-31' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-09-01' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-09-07' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-09-08' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-09-13' AS HolidayDate,'中秋节' AS HolidayName
UNION ALL SELECT '2019-09-14' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-09-15' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-09-21' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-09-22' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-09-28' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-10-01' AS HolidayDate,'国庆节' AS HolidayName
UNION ALL SELECT '2019-10-02' AS HolidayDate,'国庆节' AS HolidayName
UNION ALL SELECT '2019-10-03' AS HolidayDate,'国庆节' AS HolidayName
UNION ALL SELECT '2019-10-04' AS HolidayDate,'国庆节' AS HolidayName
UNION ALL SELECT '2019-10-05' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-10-06' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-10-07' AS HolidayDate,'国庆节' AS HolidayName
UNION ALL SELECT '2019-10-13' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-10-19' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-10-20' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-10-26' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-10-27' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-11-02' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-11-03' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-11-09' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-11-10' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-11-16' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-11-17' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-11-23' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-11-24' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-11-30' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-12-01' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-12-07' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-12-08' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-12-14' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-12-15' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-12-21' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-12-22' AS HolidayDate,'星期日' AS HolidayName
UNION ALL SELECT '2019-12-28' AS HolidayDate,'星期六' AS HolidayName
UNION ALL SELECT '2019-12-29' AS HolidayDate,'星期日' AS HolidayName

--删除
--delete FROM Topway..T_HolidayDate where HolidayDate='2019-01-12'

--国定假日设置(酒店)
SELECT     *
FROM         tripDB..Trip_HolidayConfig

--新增
--="UNION ALL SELECT newid() as id,'" &B2&"' AS datecode,'" &C2&"' AS datetext,'" &D2&"' AS HolidayDate"
insert into tripDB..Trip_HolidayConfig(ID,DateCode,DateText,HolidayDate)
SELECT newid() as id,'1231' AS datecode,'元旦' AS datetext,'2018-12-31' AS HolidayDate
UNION ALL SELECT newid() as id,'0101' AS datecode,'元旦' AS datetext,'2019-01-01' AS HolidayDate
UNION ALL SELECT newid() as id,'0204' AS datecode,'除夕' AS datetext,'2019-02-04' AS HolidayDate
UNION ALL SELECT newid() as id,'0205' AS datecode,'春节' AS datetext,'2019-02-05' AS HolidayDate
UNION ALL SELECT newid() as id,'0206' AS datecode,'初二' AS datetext,'2019-02-06' AS HolidayDate
UNION ALL SELECT newid() as id,'0207' AS datecode,'初三' AS datetext,'2019-02-07' AS HolidayDate
UNION ALL SELECT newid() as id,'0208' AS datecode,'初四' AS datetext,'2019-02-08' AS HolidayDate
UNION ALL SELECT newid() as id,'0209' AS datecode,'初五' AS datetext,'2019-02-09' AS HolidayDate
UNION ALL SELECT newid() as id,'0210' AS datecode,'初六' AS datetext,'2019-02-10' AS HolidayDate
UNION ALL SELECT newid() as id,'0405' AS datecode,'清明节' AS datetext,'2019-04-05' AS HolidayDate
UNION ALL SELECT newid() as id,'0501' AS datecode,'劳动节' AS datetext,'2019-05-01' AS HolidayDate
UNION ALL SELECT newid() as id,'0607' AS datecode,'端午节' AS datetext,'2019-06-07' AS HolidayDate
UNION ALL SELECT newid() as id,'0913' AS datecode,'中秋节' AS datetext,'2019-09-13' AS HolidayDate
UNION ALL SELECT newid() as id,'1001' AS datecode,'国庆节' AS datetext,'2019-10-01' AS HolidayDate
UNION ALL SELECT newid() as id,'1002' AS datecode,'国庆节' AS datetext,'2019-10-02' AS HolidayDate
UNION ALL SELECT newid() as id,'1003' AS datecode,'国庆节' AS datetext,'2019-10-03' AS HolidayDate
UNION ALL SELECT newid() as id,'1004' AS datecode,'国庆节' AS datetext,'2019-10-04' AS HolidayDate
UNION ALL SELECT newid() as id,'1007' AS datecode,'国庆节' AS datetext,'2019-10-07' AS HolidayDate


--删除
--delete FROM tripDB..Trip_HolidayConfig where HolidayDate='2018-02-07'

----国定假日设置(旅游)
SELECT    *
FROM        HotelOrderDB..HTL_Holidays
--假日
--="UNION ALL SELECT '" &B2&"' AS startdate,'" &C2&"' AS enddate,'0' as Isfilter,'" &D2&"' AS remark"
insert into HotelOrderDB..HTL_Holidays(StartDate,EndDate,Isfilter,Remark)
SELECT '2018-12-31' AS startdate,'2018-12-31' AS enddate,'0' as Isfilter,'元旦' AS remark
UNION ALL SELECT '2019-01-01' AS startdate,'2019-01-01' AS enddate,'0' as Isfilter,'元旦' AS remark
UNION ALL SELECT '2019-02-04' AS startdate,'2019-02-04' AS enddate,'0' as Isfilter,'除夕' AS remark
UNION ALL SELECT '2019-02-05' AS startdate,'2019-02-05' AS enddate,'0' as Isfilter,'春节' AS remark
UNION ALL SELECT '2019-02-06' AS startdate,'2019-02-06' AS enddate,'0' as Isfilter,'初二' AS remark
UNION ALL SELECT '2019-02-07' AS startdate,'2019-02-07' AS enddate,'0' as Isfilter,'初三' AS remark
UNION ALL SELECT '2019-02-08' AS startdate,'2019-02-08' AS enddate,'0' as Isfilter,'初四' AS remark
UNION ALL SELECT '2019-02-09' AS startdate,'2019-02-09' AS enddate,'0' as Isfilter,'初五' AS remark
UNION ALL SELECT '2019-02-10' AS startdate,'2019-02-10' AS enddate,'0' as Isfilter,'初六' AS remark
UNION ALL SELECT '2019-04-05' AS startdate,'2019-04-05' AS enddate,'0' as Isfilter,'清明节' AS remark
UNION ALL SELECT '2019-05-01' AS startdate,'2019-05-01' AS enddate,'0' as Isfilter,'劳动节' AS remark
UNION ALL SELECT '2019-06-07' AS startdate,'2019-06-07' AS enddate,'0' as Isfilter,'端午节' AS remark
UNION ALL SELECT '2019-09-13' AS startdate,'2019-09-13' AS enddate,'0' as Isfilter,'中秋节' AS remark
UNION ALL SELECT '2019-10-01' AS startdate,'2019-10-01' AS enddate,'0' as Isfilter,'国庆节' AS remark
UNION ALL SELECT '2019-10-02' AS startdate,'2019-10-02' AS enddate,'0' as Isfilter,'国庆节' AS remark
UNION ALL SELECT '2019-10-03' AS startdate,'2019-10-03' AS enddate,'0' as Isfilter,'国庆节' AS remark
UNION ALL SELECT '2019-10-04' AS startdate,'2019-10-04' AS enddate,'0' as Isfilter,'国庆节' AS remark
UNION ALL SELECT '2019-10-07' AS startdate,'2019-10-07' AS enddate,'0' as Isfilter,'国庆节' AS remark


--调休上班
--="UNION ALL SELECT '" &B2&"' AS startdate,'" &C2&"' AS enddate,'1' as Isfilter,'" &E2&"' AS remark"
insert into HotelOrderDB..HTL_Holidays(StartDate,EndDate,Isfilter,Remark)
SELECT '2018-12-29' AS startdate,'2018-12-29' AS enddate,'1' as Isfilter,'上班' AS remark
UNION ALL SELECT '2019-02-02' AS startdate,'2019-02-02' AS enddate,'1' as Isfilter,'上班' AS remark
UNION ALL SELECT '2019-02-03' AS startdate,'2019-02-03' AS enddate,'1' as Isfilter,'上班' AS remark
UNION ALL SELECT '2019-09-29' AS startdate,'2019-09-29' AS enddate,'1' as Isfilter,'上班' AS remark
UNION ALL SELECT '2019-10-12' AS startdate,'2019-10-12' AS enddate,'1' as Isfilter,'上班' AS remark



--删除
--delete FROM HotelOrderDB..HTL_Holidays where StartDate='2018-12-30'
