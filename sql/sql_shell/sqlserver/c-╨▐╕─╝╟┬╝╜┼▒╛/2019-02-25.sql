--修改申请费用
select feiyonginfo,feiyong,profit,* from topway..tbcash 
--update topway..tbcash  set feiyonginfo='申请座位MYI',feiyong=70,profit=210
where coupno='AS002262012'

--单位客户授信额度调整总额度120万
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SX_TotalCreditLine='1200000'
where BillNumber='019956_20190201'

--修改单位名称
--ERP单位员工表
select cmpnamels,* from Topway..tbCusholderM 
--update Topway..tbCusholderM  set cmpnamels='梅耶博格光电设备（上海）有限公司'
where cmpid='017608'

--TMS单位
select Name,* from homsomDB..Trv_UnitCompanies where Cmpid='017608'

--会务预算单信息
--收款单信息
select * from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set ConventionId='1242'
where ConventionId='1176'
--预算单作废
select Status,* from topway..tbConventionBudget 
--update topway..tbConventionBudget  set Status=2
where ConventionId='1176'

--删除多余单位数据
select * from Topway..tbCompanyM where id='14882'
--delete from Topway..tbCompanyM where id='14882'
select COUNT(*) from Topway..tbCompanyM where hztype in('1','2','3') and cmpid<>''
select COUNT(*) from homsomDB..Trv_UnitCompanies where CooperativeStatus in('1','2','3') and cmpid<>''


--结算价差额调整
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice='2859',profit='894'
where coupno='AS002266213'

--酒店垫付改自付
select AdvanceMethod,PayMethod,AdvanceStatus,PayStatus,AdvancePayNo,PayNo,AdvanceDate,PaySubmitDate from Topway..tbHtlcoupRefund 
--update Topway..tbHtlcoupRefund  set AdvanceMethod=0,PayMethod=2,AdvanceStatus=0,PayStatus=3,PayNo='2018121922001498140520990603',AdvancePayNo=null,PaySubmitDate='2018-12-19 14:05:57.000',AdvanceDate=null
where CoupNo='PTW073438'

select cwstatus,owe,vpay,opername1,vpayinfo,oth2 from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set cwstatus=1,owe=0,vpay=149
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo='PTW073438')

select AdvanceNumber,AdvanceName,AdvanceStatus,AdvanceDate,PayStatus,PayDate from HotelOrderDB..HTL_Orders 
--update HotelOrderDB..HTL_Orders set AdvanceNumber='',AdvanceName='',PayStatus=3,AdvanceStatus=0,PayDate='2018-12-19 14:05:57.000',AdvanceDate=null
where CoupNo='PTW073438'

select AdvancePayNo,PayNo,AdvanceMethod,PayMethod,* from HotelOrderDB..HTL_OrderSettlements 
--update HotelOrderDB..HTL_OrderSettlements  set PayNo='2018121922001498140520990603',AdvancePayNo=null,PayMethod=2,AdvanceMethod=null
where OrderID in(Select OrderID from HotelOrderDB..HTL_Orders where CoupNo='PTW073438')

--修改退票状态
select status2,* from Topway..tbReti 
--update Topway..tbReti set status2=2
where reno='9265851'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='刘璐',SpareTC='刘璐'
where coupno='AS001441296'

--修改成已支付
select status,dzhxDate,TcPayDate,CustomerPayDate,CustomerPayWay,* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='2018-08-09',status=1,owe=0,vpay=totprice
where coupno in('AS001812250','AS001810652')

select status,dzhxDate,TcPayDate,CustomerPayDate,PayStatus,CustomerPayWay,* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='2019-02-21',status=1,TcPayDate='1900-01-01',CustomerPayWay=3,owe=0,vpay=totprice
where coupno in('AS002260528')

select status,dzhxDate,TcPayDate,CustomerPayDate,PayStatus,CustomerPayWay,* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='2019-02-21',status=1,TcPayDate='1900-01-01',CustomerPayWay=3,owe=0,vpay=totprice
where coupno in('AS002235524')

select status,dzhxDate,TcPayDate,CustomerPayDate,PayStatus,CustomerPayWay,* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='2019-02-21',status=1,TcPayDate='1900-01-01',CustomerPayWay=3,owe=0,vpay=totprice
where coupno in('AS001446167')

select status,dzhxDate,TcPayDate,CustomerPayDate,PayStatus,CustomerPayWay,* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='2018-08-14',status=1,owe=0,vpay=totprice
where coupno in('AS001821986')


--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber in('020690_2019010')

select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber in('020548_20190101')


--更改支付方式（自付、垫付）国内订单
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from homsomDB..Trv_TktBookings
--update homsomDB..Trv_TktBookings set PayNo=TCPayNo,TCPayNo=null,PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate, TcPayDate=null
where ID in (select b.ItktBookingID from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS001834923','AS001834924'))
--出票支付信息
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set PayNo=TCPayNo,TCPayNo=null,PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate,dzhxDate=TcPayDate,TcPayDate=null,status=1,owe=0,vpay=totprice
where coupno in('AS001834923','AS001834924')
--支付信息详情
select payperson,* from topway..PayDetail
--update  topway..PayDetail set payperson=1 
where ysid in (select cast(b.ItktBookingID as varchar(40)) from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS001834923','AS001834924'))