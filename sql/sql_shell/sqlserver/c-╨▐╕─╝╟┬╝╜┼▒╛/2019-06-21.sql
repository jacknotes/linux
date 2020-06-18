--申请技术闭团
select Status,ModifyDate,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Status='14'
where TrvId='30249'

--火车票销售单匹配数据
select CreateDate 出票日期,OutBegdate 出发日期,CoupNo 销售单号,Customer 预订人,Name 乘客姓名,Department 部门,OutTrainNo 车次,OutGrade 座位等级,
OutStroke 行程,RealPrice 车票单价,TotFuprice 服务费,TotPrice 销售价,isnull(ReturnTicketID,'') 退票单号,TrainTicketNo 官网订单号
,Remark 备注
from Topway..tbTrainTicketInfo t1
left join Topway..tbTrainUser t2 on t2.TrainTicketNo=t1.ID
where CoupNo in ('RS000024333',
'RS000024334',
'RS000024335',
'RS000024336',
'RS000024339',
'RS000024340',
'RS000024341',
'RS000024342',
'RS000024343',
'RS000024344',
'RS000024345',
'RS000024349',
'RS000024350',
'RS000024358',
'RS000024370',
'RS000024371',
'RS000024372',
'RS000024373')

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='携程官网分销联盟'
where CoupNo='PTW085005'

/*
    UC019361   上海汇付数据服务有限公司
    因该公司Y舱特殊政策将有变更，烦请协助拉取2019.5.1--2019.6.20 产生的MU/FM  Y舱数据
    */
select coupno 销售单号,datetime 出票时间,begdate 起飞日期,route 行程,tcode+ticketno 票号,totprice 销售价,reti 退票单号,tickettype 类型
from Topway..tbcash 
where cmpcode='019361'
and datetime>='2019-05-01'
and datetime<'2019-06-21'
and ride in('MU','FM')
and nclass='Y'
order by 出票时间

/*
UC018362 艾蒙斯特朗流体系统（上海）有限公司
2018年全年
字段要求：人员信息 日期 出发地 目的地 舱位等级 销售价格
*/
SELECT coupno 销售单号,pasname 乘机人,convert(varchar(10),datetime,120) 出票日期,begdate 起飞日期,route 行程,nclass 舱位等级,totprice 销售价 ,reti 退票单号
from Topway..tbcash 
where cmpcode='018362'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf!=-1
order by 出票日期


--旅游预算单信息
--select * from Topway..tbCusholderM where cmpid='020874'

select Custid,Custinfo,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Custid='D699525',Custinfo='13601621042@陆舟@020874@上海威士顿信息技术股份有限公司@陈奇@13601621042@D699525'
where TrvId='30260'

--账单撤销
select TrainBillStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set TrainBillStatus=1
where BillNumber='020644_20190501'

--更改支付方式（自付、垫付）
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from homsomDB..Trv_TktBookings
--update homsomDB..Trv_TktBookings set PayNo=TCPayNo,TCPayNo=null,PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate, TcPayDate=null
where ID in (select b.ItktBookingID from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS002494171'))
--出票支付信息
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set PayNo=TCPayNo,TCPayNo=null,PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate,dzhxDate=TcPayDate,TcPayDate=null,status=1,owe=0,vpay=totprice
where coupno in('AS002494171')
--支付信息详情
select payperson,* from topway..PayDetail
--update  topway..PayDetail set payperson=1 
where ysid in (select cast(b.ItktBookingID as varchar(40)) from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS002494171'))

select * from homsomDB..Trv_DomesticTicketRecord where RecordNumber='AS002435233'
select * from homsomDB..Trv_PnrInfos where ID='913436AC-8CBD-4F04-91F9-2969776749BD'
select * from homsomDB..Trv_ItktBookingSegments_PnrInfos where PnrInfoID='913436AC-8CBD-4F04-91F9-2969776749BD'
select * from homsomDB..Trv_ItktBookingSegs where ID='4A6E7BD5-EF5C-4D22-9B7A-6889B1C8E0F4'

--最低价   提醒的最低价航班的起降时间
SELECT c.coupno,isnull(lp.Price,'') 最低价,isnull(lp.DepartureTime,'') 起飞日期,isnull(lp.ArrivalTime,'') 到达日期,isnull(lp.Flight,'') 航班号
 FROM topway..tbcash c 
LEFT JOIN homsomDB..Trv_DomesticTicketRecord r ON c.coupno=r.RecordNumber
LEFT JOIN homsomDB..Trv_ItktBookingSegments_PnrInfos p on p.PnrInfoID=r.PnrInfoID
left join homsomDB..Trv_LowerstPrices lp on p.ItktBookingSegID=lp.ItktBookingSegID
where c.coupno in ('AS002362610',
'AS002366465',
'AS002368897',
'AS002369159',
'AS002371599',
'AS002372134',
'AS002372319',
'AS002376291',
'AS002376464',
'AS002376992',
'AS002377048',
'AS002377453',
'AS002377558',
'AS002377643',
'AS002379209',
'AS002379238',
'AS002379418',
'AS002380674',
'AS002381285',
'AS002382369',
'AS002382524',
'AS002383226',
'AS002384562',
'AS002385711',
'AS002385715',
'AS002388708',
'AS002389157',
'AS002389276',
'AS002389404',
'AS002391489',
'AS002391731',
'AS002392059',
'AS002392667',
'AS002392669',
'AS002394544',
'AS002395099',
'AS002395181',
'AS002395923',
'AS002396794',
'AS002396804',
'AS002397317',
'AS002400946',
'AS002401427',
'AS002401556',
'AS002402132',
'AS002403776',
'AS002405139',
'AS002405180',
'AS002408149',
'AS002408492',
'AS002412421',
'AS002414283',
'AS002414293',
'AS002415772',
'AS002417805',
'AS002420210',
'AS002421335',
'AS002422423',
'AS002422431',
'AS002423441',
'AS002423448',
'AS002424299',
'AS002425903',
'AS002427408',
'AS002427618',
'AS002427701',
'AS002428195',
'AS002431521',
'AS002431709',
'AS002431877',
'AS002432772',
'AS002432774',
'AS002433531',
'AS002433837',
'AS002435225',
'AS002435233',
'AS002435831',
'AS002436632',
'AS002438767',
'AS002439413',
'AS002439732')
and isnull(lp.Price,'')<>0
order by c.coupno


--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020237_20190501'

--UC020895 更名为上海正歆设施管理服务有限公司
select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement  set CompanyNameCN='上海正歆设施管理服务有限公司'
where BillNumber='020895_20190601'

--撤销闭团及闭团相关信息（旅游）
select Status,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Status=14
where TrvId='30286'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002570490','AS002568448')

--select amount,totprice,totsprice,tax,profit,* from Topway..tbcash where coupno='AS002561842'
select t_amount,totprice,totsprice,tottax,totprofit,* from Topway..tbFiveCoupInfo 
--update Topway..tbFiveCoupInfo  set t_amount=300,totprice=300,totsprice=140,tottax=0,totprofit=300
where CoupNo='AS002561842'