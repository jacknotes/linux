/*
UC006299   泰瑞达（上海）有限公司
 
如客户邮件要求，请按表格内容拉取2018/9/1---2019/6/30：乘机人姓名、票号、起飞城市、目的地城市、出票日期、起飞日期、回程日期、行程天数、机票使用情况 9项数据
*/
select top 100 * from homsomDB..Trv_ItktBookingSegs
select top 100 * from homsomDB..Intl_BookingLegs


--国内
select pasname 乘机人姓名,tcode+ticketno 票号,DepartCityName 起飞城市,ArrivalCityName 目的地城市,convert(varchar(10),datetime,120) 出票日期,convert(varchar(20),begdate,120) 起飞日期,'--' 回程日期,'--' 行程天数
,case when tickettype like'%改期%' then '改期升舱' when reti<>'' then '退票' when c.route like '%退票%' then '退票'  else '正常使用' end 机票使用情况
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos it on it.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs i on it.ItktBookingSegID=i.ID
where cmpcode='006299'
and datetime>='2018-09-01'
and datetime<'2019-07-01'
and inf=0
order by 出票日期

--国际
--行程1
if OBJECT_ID('tempdb..#xc1') is not null drop table #xc1
select pasname 乘机人姓名,tcode+ticketno 票号, CityName1 城市1,CityName2 目的地城市1,datetime 出票日期,DepartureTime 起飞日期1
,case when c.tickettype like'%改期%' then '改期升舱' when c.route like '%改期%' then '改期升舱'  when reti<>'' then '退票' when c.route like '%退票%' then '退票'  else '正常使用' end 机票使用情况,
EndDate 回城日期,DATEDIFF(DD,begdate,EndDate) 行程天数
into #xc1
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where cmpcode='006299'
and datetime>='2018-09-01'
and datetime<'2019-07-01'
and inf=1
and b.Sort=1
and bo.Sort=1

--select * from #xc1
--行程2
if OBJECT_ID('tempdb..#xc2') is not null drop table #xc2
select pasname 乘机人姓名,tcode+ticketno 票号, CityName1 城市2,CityName2 目的地城市2,datetime 出票日期,DepartureTime 起飞日期2,route 行程
into #xc2
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where cmpcode='006299'
and datetime>='2018-09-01'
and datetime<'2019-07-01'
and inf=1
and b.Sort=2
and bo.Sort=1
--行程3
if OBJECT_ID('tempdb..#xc3') is not null drop table #xc3
select pasname 乘机人姓名,tcode+ticketno 票号, CityName1 城市3,CityName2 目的地城市3,datetime 出票日期,DepartureTime 起飞日期3
into #xc3
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where cmpcode='006299'
and datetime>='2018-09-01'
and datetime<'2019-07-01'
and inf=1
and b.Sort=3
and bo.Sort=1
--行程4
if OBJECT_ID('tempdb..#xc4') is not null drop table #xc4
select pasname 乘机人姓名,tcode+ticketno 票号, CityName1 城市4,CityName2 目的地城市4,datetime 出票日期,DepartureTime 起飞日期4
into #xc4
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where cmpcode='006299'
and datetime>='2018-09-01'
and datetime<'2019-07-01'
and inf=1
and b.Sort=4
and bo.Sort=1
--行程5
if OBJECT_ID('tempdb..#xc5') is not null drop table #xc5
select pasname 乘机人姓名,tcode+ticketno 票号, CityName1 城市5,CityName2 目的地城市5,datetime 出票日期,DepartureTime 起飞日期5
into #xc5
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where cmpcode='006299'
and datetime>='2018-09-01'
and datetime<'2019-07-01'
and inf=1
and b.Sort=5
and bo.Sort=1

select a.乘机人姓名,a.票号,城市1 起飞城市,目的地城市1,isnull(目的地城市2,'--') 目的地城市2,isnull(目的地城市3,'--') 目的地城市3,isnull(目的地城市4,'--') 目的地城市4,isnull(目的地城市5,'--') 目的地城市5,
convert(varchar(10),a.出票日期,120) 出票日期,起飞日期1,起飞日期2,起飞日期3,起飞日期4,起飞日期5,回城日期,行程天数,机票使用情况
from #xc1 a
left join #xc2 b on a.票号=b.票号
left join #xc3 c on a.票号=c.票号
left join #xc4 d on a.票号=d.票号
left join #xc5 e on a.票号=e.票号
order by 出票日期