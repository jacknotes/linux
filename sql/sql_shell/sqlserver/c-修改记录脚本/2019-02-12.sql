--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='员工垫付(邵雪梅浦发卡)'
where CoupNo='PTW075904'

-- UC019360 咖世家餐饮管理（上海）有限公司数据
select t.coupno as 销售单号,pasname as 乘机人,i1.ArrivalTime as 出发日期,route as 行程,i1.Name,i1.Name1,i1.Code,i1.Code1,* from Topway..tbcash t
left join Topway..tbFiveCoupInfo t1 on t1.CoupNo=t.coupno
left join homsomDB..Intl_BookingSegements i on i.BookingOrderId=t1.OrderId
left join homsomDB..Intl_BookingLegs i1 on i1.BookingSegmentId=i.Id
where datetime>='2018-02-26' and datetime<'2019-02-11' and cmpcode='019360' and inf=1
order by t.coupno

select coupno as 销售单号,pasname as 乘机人,datetime as 出发日期,route as 行程  from Topway..tbcash t
left join homsomDB..Intl_PNRs i on i.Code=t.recno
left join homsomDB..Intl_BookingSegements i1 on i1.BookingOrderId=i.BookingOrderId
left join homsomDB..Intl_BookingLegs i2 on i2.BookingSegmentId=i1.Id
where datetime>='2018-02-26' and datetime<'2019-02-11' and cmpcode='019360' and inf=1
order by 销售单号



select DepartureDate,* from homsomDB..Intl_BookingOrders where CmpId='019360' and DepartureDate>='2018-02-26' and DepartureDate<'2019-02-11'

--销售单匹配舱位
SELECT c.coupno,(SELECT TOP 1 i.cabintype 
	FROM ehomsom..tbInfCabincode i 
	WHERE	c.ride=i.code2 AND c.nclass=i.cabin 
										AND i.begdate<=c.begdate AND i.enddate>=c.begdate
	ORDER BY id DESC
	) AS cabinType
fROM Topway..tbcash  c
where c.coupno in
('AS002171583',
'AS002171585',
'AS002171585',
'AS002177050',
'AS002177055',
'AS002177101',
'AS002177344',
'AS002179731',
'AS002179899',
'AS002179901',
'AS002180553',
'AS002183019',
'AS002184677',
'AS002195798',
'AS002198303',
'AS002198798',
'AS002198864',
'AS002200184',
'AS002200188',
'AS002201338',
'AS002204899',
'AS002206257',
'AS002206656',
'AS002208462',
'AS002209181',
'AS002209704',
'AS002213106',
'AS002214269',
'AS002217270',
'AS002218152',
'AS002223042',
'AS002223637',
'AS002223647',
'AS002223755',
'AS002223757',
'AS002223923',
'AS002225241',
'AS002225361',
'AS002225381',
'AS002225509',
'AS002226297',
'AS002226300',
'AS002226401',
'AS002226462',
'AS002226463',
'AS002227902',
'AS002233979',
'AS002234008',
'AS002234552',
'AS002234572',
'AS002234705',
'AS002235565',
'AS002235569',
'AS002236812')

--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='需打印中文行程单'
where coupno='AS001954275'

--修改UC号
select custid AS 现会员编号,* from topway..tbCusholderM where cmpid ='016888'
select custid,OriginalBillNumber,ModifyBillNumber,* from Topway..tbcash where cmpcode='016888' 
select SettleMentManner AS 现结算方式,* from topway..HM_SetCompanySettleMentManner where CmpId='016888' and Type=0 and Status=1
select OriginalBillNumber AS 现账单号,ModifyBillNumber AS 现账单号,cmpcode,custid,datetime,* from topway..tbcash where coupno in ('AS002193902','AS002193937')
select HSLastPaymentDate,* from topway..AccountStatement where CompanyCode='016888' order by BillNumber desc
--修改UC号（ERP）
select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,* from Topway..tbcash
--update topway..tbcash set cmpcode='016888',OriginalBillNumber='016888_20181226',ModifyBillNumber='016888_20181226',custid='D179052'
 where coupno in ('AS002193902','AS002193937')

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where BillNumber='017735_20181226'

select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where BillNumber='018734_20190101'


 --2018年特殊换开国际机票
 
select coupno as 销售单号,tcode+ticketno as 票号,route as 行程,sales as 差旅顾问,profit as 销售利润 from Topway..tbcash 
where  datetime>='2018-01-01' and datetime<'2019-01-01' and inf='1' and HKType='1'

--OA酒店会务产品部
select Signer,* from ApproveBase..HR_AskForLeave_Signer 
--update ApproveBase..HR_AskForLeave_Signer set Signer='0601'
where DeptCode='酒店会务产品部'

--重开打印权限

select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus='0',PrDate='1900-01-01'
where TrvId='029513'

--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno='AS002201777'

--退票数据
select t1.tcode+t1.ticketno as 票号,t.coupno as 销售单号,t1.t_source as 供应商来源,t.reno as 退票单号,t.edatetime as 提交日期,ExamineDate as 审核日期,scount2 as 航空公司退票费,
rtprice as 收取客户退票金额,t1.SpareTC as 出票操作业务顾问,t1.sales as 出票业务顾问,t.opername as 提交退票业务顾问,t.info as 备注
 from Topway..tbReti t
left join Topway..tbcash t1 on t1.coupno=t.coupno and t1.reti=t.reno
where ExamineDate>='2019-01-07' and ExamineDate<'2019-02-11' and t.info like'%冒退票%'
order by ExamineDate

--机票销售单改为未付
select bpay as 支付金额,status as 收款状态,opernum as 核销次数,oper2 as 核销人,oth2 as 备注,totprice as 销售价,dzhxDate as 核销时间,owe as 欠款金额,*
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=800,dzhxDate='1900-1-1'
from Topway..tbcash where coupno='AS002201236' and ticketno='3541111829'

--酒店预定城市计数前十
--预付
select top 10 city as 城市,COUNT(*) as 预定次数 from Topway..tbHtlcoupYf 
where datetime>='2018-01-01' and datetime<'2019-01-01'
and status<>'-2'
group by city
order by 预定次数 desc

--自付
select top 10 city as 城市,COUNT(*) as 预定次数 from Topway..tbHotelcoup
where datetime>='2018-01-01' and datetime<'2019-01-01'
and status<>'-2'
group by city
order by 预定次数 desc

--账单撤销
select HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement set HotelSubmitStatus='2'
where BillNumber='017506_20190101'

--修改供应商来源
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002239218'
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno='AS002237544'