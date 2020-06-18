--行程单、特殊票价
select info3,* from Topway..tbcash 
--update  Topway..tbcash set info3='需打印行程单'
where coupno='AS002368561'

select info3,* from Topway..tbcash 
--update  Topway..tbcash set info3='需打印行程单'
where coupno='AS002372729'

select info3,* from Topway..tbcash 
--update  Topway..tbcash set info3='无需打印行程单'
where coupno='AS002364897'

select info3,* from Topway..tbcash 
--update  Topway..tbcash set info3='需打印行程单'
where coupno in('AS002365576','AS002369945','AS002372172','AS002372530')

--账单撤销
select HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set HotelSubmitStatus=2
where BillNumber='017007_20190201'

--重开打印权限
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='29851' and Id='227569'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='019754_20190301'


--最低价   提醒的最低价航班的起降时间
SELECT c.coupno,lp.Price 最低价,lp.DepartureTime,lp.ArrivalTime
 FROM topway..tbcash c 
LEFT JOIN homsomDB..Trv_DomesticTicketRecord r ON c.coupno=r.RecordNumber
LEFT JOIN homsomDB..Trv_PnrInfos p ON r.PnrInfoID=p.ID
LEFT JOIN homsomDB..Trv_ItktBookings i ON p.ItktBookingID=i.ID
left join homsomDB..Trv_ItktBookingSegs its on i.ID=its.ItktBookingID
left join homsomDB..Trv_LowerstPrices lp on its.ID=lp.ItktBookingSegID
where ModifyBillNumber in ('019607_20190301')
order by c.coupno


select top 10 * from homsomDB..Trv_LowerstPrices



--会务2019-03完成闭团明细

select distinct c1.OperDate 闭团日期 ,c1.ConventionId 预算单号,cmpname 单位名称,c2.GysSource 供应商来源,Sales 业务顾问,FinancialCharges 资金费用
from Topway..tbConventionCoup c1
left join Topway..tbCompanyM m on m.cmpid=c1.Cmpid
left join Topway..tbConventionJS c2 on c2.ConventionId=c1.ConventionId
where c1.OperDate>='2019-03-01' and c1.OperDate<'2019-04-01'
and Sales  in ('崔之阳','张广寒','周寅啸')
and c1.Status !=1
order by c1.OperDate

select * from Topway..tbConventionBudget where ConventionId='839'

--销售单信息AS000577134  
select datetime 出票日期,t_source 供应商来源,ride+flightno 航班号,tcode+ticketno 票号,route 行程,
begdate 出发日期,totprice 销售价,totsprice 结算价,profit 利润
from Topway..tbcash  where coupno='AS000577134'


/*
请拉取数据。
1.	要求客户状态：合作
2.	单位客户，所以单位国内、国际常旅客名单数。
3.	出票数据，2018年4月1日-2019年4月7日出过票的名单数（同一UC下，相同名字证件去重）。
4.	只要名单数量，无需明细
*/
--常旅客名单数
IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select uc.cmpid,uc.Name as cmpname,COUNT(up.ID) 常旅客名单数
into #cmp1
from homsomdb..Trv_UnitPersons up
left join homsomdb..Trv_Human h on h.ID=up.ID
left join homsomdb..Trv_UnitCompanies uc on uc.ID=up.CompanyID
where uc.CooperativeStatus in ('1','2','3') and h.IsDisplay=1
and uc.cmpid not in ('000003','000006')
group by uc.cmpid,uc.Name

select * from #cmp1

--出国票名单数
IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp2
select distinct cmpcode,idno 
into #cmp2
from Topway..tbcash  
where cmpcode in (select cmpid from #cmp1)
and datetime>='2018-04-01'
and datetime<'2019-04-08'

select cmpcode,count(idno) from #cmp2
group by cmpcode


--申请费用来源
select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash set feiyong=0,feiyonginfo=''
where coupno='AS002367125'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='020638_20190301'

select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='020637_20190301'


--更改支付方式（自付、垫付）
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set PayNo=TCPayNo,TCPayNo=null,PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate,dzhxDate=TcPayDate,TcPayDate='1900-01-01'
where coupno='AS002372155'

select PayStatus,AdvanceStatus,PayNo,TCPayNo,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET PayStatus=AdvanceStatus,PayNo=TCPayNo,CustomerPayWay=TcPayWay,CustomerPayDate=TcPayDate,AdvanceStatus=0,TCPayNo=NULL,TcPayWay=0,TcPayDate='1900-01-01'
WHERE CoupNo in('AS002372155')

--结算价差额
select totsprice,profit, * from  Topway..tbcash  
--update Topway..tbcash   set totsprice=6877,profit=523
where coupno='AS002372685'

--修改UC号（ERP）
select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,pform,xfprice,* from Topway..tbcash
--update topway..tbcash set cmpcode='020637',OriginalBillNumber='020637_20190301'
 where coupno in ('AS002346248','AS002346244')
 
 
 select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,pform,xfprice,* from Topway..tbcash
--update topway..tbcash set cmpcode='020638',OriginalBillNumber='020638_20190301'
 where coupno in ('AS002300722','AS002316843')
 and ticketno in ('3564475226','3566636068')
 
  select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,pform,xfprice,* from Topway..tbcash
--update topway..tbcash set cmpcode='020638',OriginalBillNumber='020638_20190301'
 where coupno in ('AS002334895','AS002340142')
 
 --火车票供应商来源/配送信息
 select Tsource,Ptype,* from Topway..tbTrainTicketInfo 
 --update Topway..tbTrainTicketInfo set Ptype=4
 where CoupNo in('RS000021771','RS000021772')
