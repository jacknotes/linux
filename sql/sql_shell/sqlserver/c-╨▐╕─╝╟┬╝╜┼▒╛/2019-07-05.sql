--UC013184 时间2018年1月-2019年6月
select * from ehomsom..tbInfAirCompany
select top 100 * from homsomDB..Trv_ItktBookingSegs
select top 100 * from homsomDB..Trv_LowerstPrices
select top 100 CoupNo,* from homsomDB..Trv_TktBookings
select top 100 * from homsomDB..Intl_BookingLegs
select top 100 * from homsomDB..Intl_BookingOrders
select top 100 * from homsomDB..Intl_BookingSegements

--国内
select pasname 乘机人,CostCenter 成本中心,Department 部门,DETR_RP 行程单号,InvoicesID 税号,tickettype 类型,
convert(varchar(10),datetime,120) 出票日期,recno PNR,tcode+ticketno 票号,OldTicketNo old票号,ride 航司代码,it.Airline 航司名称,'国内' 国际或国内,
'单程' 是否往返,c2.Name 出发城市,c1.Name 到达城市,c2.CountryCode 出发国家,c1.CountryCode 到达国家,c.route 行程,
case when FlightClass like'%经济%' then '经济舱' when FlightClass like'%公务%' then '公务舱' when FlightClass like'%头等舱%' then '头等舱' else '-' End  舱位等级
,nclass 舱位代码,Departing 起飞日期,Arriving 到达日期,case when DATEDIFF(DD,datetime,Departing) between 0 and 2  then '0to2'
when DATEDIFF(DD,datetime,Departing) between 3 and 6 then '3to6' else '7+' end 提前出票,DATEDIFF(DD,datetime,Departing) 提前出票天数,
c.price 销售单价,tax 税收,fuprice 服务费,totprice 销售价,priceinfo 全价,l.Price 最低价,AuthorizationCode 授权码,l.UnChoosedReason ReasonCode,
tickettype 类型,DATEDIFF(MINUTE,Departing,Arriving) 飞行时间
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos s on s.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ID=s.ItktBookingSegID
left join homsomDB..Trv_Airport a1 on a1.Code=it.Destination
left join homsomDB..Trv_Airport a2 on a2.Code=it.Origin
left join homsomDB..Trv_Cities c1 on c1.ID=a1.CityID
left join homsomDB..Trv_Cities c2 on c2.ID=a2.CityID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=s.ItktBookingSegID
left join homsomDB..Trv_TktBookings tk on tk.ID=it.ItktBookingID
where cmpcode='013184'
and inf=0
and datetime>='2018-01-01'
and datetime<'2019-07-01'

select * from ehomsom..tbInfCabincode
--国际
select  pasname 乘机人,'','',CostCenter 成本中心,Department 部门,DETR_RP 行程单号,InvoicesID 税号,c.tickettype 类型,
datetime 出票日期,recno PNR,tcode+ticketno 票号,OldTicketNo old票号,ride 航司代码,airname 航司名称,'国际' 国际或国内,
route,cabintype,nclass,c.begdate,'',case when DATEDIFF(DD,datetime,c.begdate) between 0 and 2  then '0to2'
when DATEDIFF(DD,datetime,c.begdate) between 3 and 6 then '3to6' else '7+' end 提前出票,DATEDIFF(DD,datetime,c.begdate) 提前出票天数
,price,tax,fuprice,totprice,''
from Topway..tbcash c
left join ehomsom..tbInfAirCompany tb on tb.code2=c.ride
left join ehomsom..tbInfCabincode t on t.code2=c.ride and t.cabin=c.nclass
and datetime>=t.begdate and datetime<=c.EndDate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2)
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode='013184'
and inf=1
and datetime>='2018-01-01'
and datetime<'2019-07-01'

select Name,CountryCode,* from homsomDB..Trv_Cities where ID =(select CityID from homsomDB..Trv_Airport where Code='cdg')

/*
UC006299   泰瑞达（上海）有限公司
 
如客户邮件要求，请按表格内容拉取2018/9/1---2019/6/30：乘机人姓名、票号、起飞城市、目的地城市、出票日期、起飞日期、回程日期、行程天数、机票使用情况 9项数据
*/
select pasname 乘机人姓名,tcode+ticketno 票号,DepartCityName 起飞城市,ArrivalCityName 目的地城市,convert(varchar(10),datetime,120) 出票日期,begdate 起飞日期,'' 回程日期,''行程天数,
case when  tickettype='电子票' then '使用' else '改期升舱' end 机票使用情况 
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos it on it.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs i on i.ID=it.ItktBookingSegID
where cmpcode='006299'
and inf=0
and datetime>='2018-09-01'
and datetime<'2019-07-01'

--国际起飞
--if OBJECT_ID('tempdb..#qf') is not null drop table #qf
select pasname 乘机人姓名,tcode+ticketno 票号,case when b.Sort=1 then CityName1 else''end 起飞城市,
case when b.Sort=2 then CityName2 else''end 目的地城市1,case when b.Sort=2 then bo.DepartureTime else''end 回程日期1,case when b.Sort=3 then CityName2 else''end 目的地城市2,
case when b.Sort=3 then bo.DepartureTime else''end 回程日期2,
case when b.Sort=4 then CityName2  else''end 目的地城市3, case when b.Sort=4then bo.DepartureTime else''end 回程日期3,
case when b.Sort=5 then CityName2  else''end 目的地城市4,case when b.Sort=5 then bo.DepartureTime else''end 回程日期4,
case when b.Sort=5 then CityName2  else''end 目的地城市5,case when b.Sort=6 then CityName2  else''end 目的地城市6,
convert(varchar(10),datetime,120) 出票日期,begdate 起飞日期, 
case when  c.tickettype='电子票' then '使用'  else '退改' end 机票使用情况,route
--into #qf
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where cmpcode='006299'
and inf=1
and datetime>='2018-09-01'
and datetime<'2019-07-01'
order by 票号

--国际返程
select pasname 乘机人姓名,tcode+ticketno 票号,case when b.Sort=2 then bo.CityName2 
when b.Sort=3 then bo.CityName2  else '' end
--into #qf
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where cmpcode='006299'
and inf=1
and datetime>='2018-09-01'
and datetime<'2019-07-01'

--账单撤销
select SubmitState,TrainBillStatus,HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1,TrainBillStatus=1,HotelSubmitStatus=2
where BillNumber='019159_20190501'

--账单撤销
select SubmitState,TrainBillStatus,HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020583_20190601'

--火车票销售价信息
select TotFuprice,TotPrice,* from Topway..tbTrainTicketInfo
--update  Topway..tbTrainTicketInfo set TotFuprice=0,TotPrice=TotPrice-15
where CoupNo in('RS000026140','RS000026141','RS000026142',
'RS000026143','RS000026144','RS000026145')

select Fuprice,* from Topway..tbTrainUser 
--update Topway..tbTrainUser  set Fuprice=0
where TrainTicketNo in (select ID from Topway..tbTrainTicketInfo
where CoupNo in('RS000026140','RS000026141','RS000026142',
'RS000026143','RS000026144','RS000026145'))

--签证销售单
select Sales,* from Topway..tbTrvCoup 
--update Topway..tbTrvCoup set Sales='孙艳'
where TrvCoupNo='97652'

--差旅顾问是杨静，贾真，汪媛 的差旅单位
select Cmpid UC,u.Name 单位名称,s.Name 差旅顾问
from homsomDB..Trv_UnitCompanies u 
left join homsomDB..Trv_TktUnitCompanies_TktTCs t on t.TktUnitCompanyID=u.ID
left join homsomDB..SSO_Users s on t.TktTCID=s.ID
where s.Name in ('杨静','贾真','汪媛')
and CooperativeStatus in ('1','2','3')
and u.Type='a'
order by 差旅顾问

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno='AS002608059'

--销售单
select totprice,t_amount,totsprice,totprofit,tottax,totdisct,* from Topway..tbFiveCoupInfo 
--update Topway..tbFiveCoupInfo  set totprice=100,t_amount=100,totsprice=4000,totprofit='-3900',tottax=0,totdisct=0
where coupno='AS002606993'


select tax,stax,* from Topway..tbcash 
--update Topway..tbcash  set stax=140
where coupno='AS002454564'

--旅游收款单信息
select Skstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Skstatus=2
where TrvId='30008' and Id='228577'

--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印中文行程单'
where coupno in('AS002525786','AS002525786','AS002527923','AS002527930')

--单位类型、结算方式、账单开始日期、新增月、注册月
select indate,InDateA,* from Topway..tbCompanyM 
--update Topway..tbCompanyM indate='2019-07-05'
where cmpid='020900'

select RegisterMonth,*  from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies  set RegisterMonth='07 05 2019 10:49AM'
where Cmpid='020900'

--账单撤销
select TrainBillStatus,HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set TrainBillStatus=1,HotelSubmitStatus=2
where BillNumber='020583_20190601'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=13759 ,profit=profit+3
where coupno='AS002606135'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set TrainBillStatus=1,HotelSubmitStatus=3,SubmitState=1
where BillNumber='015828_20190426'

--退票录入人
select opername,* from Topway..tbReti 
--update Topway..tbReti  set opername='何燕萍'
where reno in('0439613','0439627')
/*
请帮忙拉取一份会务运营部-崔之阳 张广寒，2019年6月份完成毕团的数据EXECL表，具体包含以下各项：
1.毕团日期
2.预算单号
3.单位名称
4.供应商结算信息：供应商来源
5.会务顾问
6.资金费用
*/

select t.OperDate 毕团日期,t.ConventionId 预算单号,u.Name 单位名称,GysSource 供应商来源,Sales 会务顾问,FinancialCharges 资金费用
from Topway..tbConventionCoup t
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=t.Cmpid
left join Topway..tbConventionJS tb on tb.ConventionId=t.ConventionId
where t.OperDate<'2019-07-01'
and t.OperDate>='2019-06-01'
and Sales in('崔之阳','张广寒')
order by 毕团日期


SELECT * from Topway..tbcash where coupno='AS002610225'
--拆单23人AS002610608 
select * from Topway..tbFiveCoupInfosub
--update Topway..tbFiveCoupInfosub set MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='23',Department='无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无' 
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002610608')
--AS002610225  22人
select pcs 人数,MobileList 手机列表,CostCenter 成本中心,Department 部门,* from Topway..tbFiveCoupInfosub
--update Topway..tbFiveCoupInfosub set MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='22',Department='无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无' 
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002610225')

/*
请帮忙拉取以下2家公司常旅客未设置审批的人员名单，谢谢！
 
UC018773海银金融控股集团有限公司
 
UC020410贵酿酒业有限公司
*/
select 'UC018773' UC,Name,LastName+'/'+FirstName+MiddleName,Mobile
from homsomDB..Trv_Human 
where ID in(Select ID from homsomDB..Trv_UnitPersons
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies
where Cmpid='018773') and VettingTemplateID is null)
and IsDisplay=1

---国内机票
select '020410' UC,h.Name 中文姓名,LastName+'/'+FirstName+MiddleName 英文,Mobile  手机号码
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='020410' and IsDisplay=1 and isnull(cast(u.VettingTemplateID as varchar(40)),'')='' 

---国际机票
select '018773' UC,h.Name 中文姓名,LastName+'/'+FirstName+MiddleName 英文,Mobile  手机号码
 from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='018773' and IsDisplay=1 and isnull(cast(u.InternationalFlightVettingTemplateID as varchar(40)),'')='' 

---国内酒店
select '018773' UC,h.Name 中文姓名,LastName+'/'+FirstName+MiddleName 英文,Mobile  手机号码
 from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='018773' and IsDisplay=1 and isnull(cast(u.HotelVettingTemplateID as varchar(40)),'')='' 

---国际酒店
select '018773' UC,h.Name 中文姓名,LastName+'/'+FirstName+MiddleName 英文,Mobile  手机号码
 from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='018773' and IsDisplay=1 and isnull(cast(u.InternationalHotelVettingTemplateID as varchar(40)),'')='' 

---火车票
select '018773' UC,h.Name 中文姓名,LastName+'/'+FirstName+MiddleName 英文,Mobile  手机号码
 from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='018773' and IsDisplay=1 and isnull(cast(u.TrainVettingTemplateID as varchar(40)),'')='' 

---出差申请
select '018773' UC,h.Name 中文姓名,LastName+'/'+FirstName+MiddleName 英文,Mobile  手机号码
 from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='018773' and IsDisplay=1 and isnull(cast(u.CompanyTravelVettingTemplateID as varchar(40)),'')='' 

--修改审核时间
Select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti  set ExamineDate='2019-07-01'
where reno='0439613'

---国内机票
SELECT DISTINCT un.Cmpid UC,un.Name 单位名称,h.Name 中文姓名,LastName+'/'+FirstName+MiddleName 英文,Mobile  手机号码
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='020410' and IsDisplay=1 and isnull(cast(u.VettingTemplateID as varchar(40)),'')='' 
AND h.name NOT LIKE '%离职%'

--旅游收款核销备注
select oth2, * from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set oth2='请帮忙添加备注 6/28中国银行（3427）14800'
where TrvId='30237'