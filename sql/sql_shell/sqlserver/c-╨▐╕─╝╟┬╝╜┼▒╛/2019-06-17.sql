/*
单位编号：UC020778
出票日期：2019.5.28-2019.6.13
客票类型：国内+国际
表格要求：乘机人姓名	证件
*/
select distinct pasname 乘机人姓名,idno 证件
from Topway..tbcash
where cmpcode='020778'
and datetime>='2019-05-28'
and datetime<'2019-06-14'
and inf<>-1

/*UC020459
请帮忙拉取该公司5月国际票和国内头等、商务舱的数据
销售单号 订单号 出票日期 起飞日期 预订人 乘客姓名 线路 航班号 起飞时间 票号 全价 折扣率 销售单价税收 服务费 销售价 退票单号 部门 授权码 最低价 未选择最低价原因 舱位等级
*/
select top 100 * from homsomDB..Trv_DomesticTicketRecord
select top 100 * from homsomDB..Trv_Travels
select top 100 * from homsomDB..Trv_ItktBookings


select c.coupno 销售单号,t.TravelID 订单号,datetime 出票日期,begdate 起飞日期,h.Name 预订人,c.route 线路,ride+flightno 航班号,
begdate 起飞时间,tcode+ticketno 票号,c.tax 销售单价税收,fuprice 服务费,
totprice 销售价,reti 退票单号,Department 部门,AuthorizationCode 授权码 ,nclass 舱位等级,CabinClass
--,isnull(l.Price,'') 最低价,isnull(UnChoosedReason,'') 未选择最低价原因
from Topway..tbcash c
left join homsomDB..Trv_UnitPersons u on u.CustID=c.custid
left join homsomDB..Trv_Human h on h.ID=u.ID
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos p on d.PnrInfoID=p.ID
left join homsomDB..Trv_ItktBookings i on i.ID=p.ItktBookingID
left join homsomDB..Trv_Travels t on i.TravelID=t.ID
left join homsomDB..Trv_TktBookings tk on p.ItktBookingID=tk.ID
--left join homsomDB..Trv_ItktBookingSegs s on s.ItktBookingID=p.ItktBookingID
--left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=s.ID
where cmpcode='020459'
and datetime>='2019-05-01'
and datetime<'2019-06-01'
and inf=0
--and (CabinClass like '%头等%' or CabinClass like '%公务%')
and CabinClass not like'%经济%'
order by datetime

select top 100 AuthorizationCode,* from homsomDB..Intl_BookingOrders
select top 100* from homsomDB..Trv_LowerstPrices

select c.coupno 销售单号,b.OrderNo 订单号,datetime 出票日期,begdate 起飞日期,h.Name 预订人,c.route 线路,ride+flightno 航班号,
begdate 起飞时间,tcode+ticketno 票号,c.tax 销售单价税收,fuprice 服务费,
c.totprice 销售价,reti 退票单号,Department 部门,AuthorizationCode 授权码 ,nclass 舱位等级
--,isnull(l.Price,'') 最低价--,isnull(UnChoosedReason,'') 未选择最低价原因
from Topway..tbcash c
left join homsomDB..Trv_UnitPersons u on u.CustID=c.custid
left join homsomDB..Trv_Human h on h.ID=u.ID
left join Topway..tbFiveCoupInfo f on f.CoupNo=c.coupno
left join homsomDB..Intl_BookingOrders b on b.Id=f.OrderId
where cmpcode='020459'
and datetime>='2019-05-01'
and datetime<'2019-06-01'
and inf=1
order by datetime


--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno='AS002467098'

/*
出票日期2018.7.1-2019.6.9，国内机票报销凭证目前为“大发票”，承运人“FM MU”的数据。
需要字段：UC号、国内销量，国内申请费金额，出票段数，国内申请费/国内销量的百分比（按此字段排序有高到低）

如下是我后来邮件添加的条件，国内报销凭证为发票，去除掉正常合作仅限现结以及特殊票价关闭的客户
公司名称，
差旅顾问，
运营经理，
国内利润金额，
国内销量，
国内利润率，
该UC号所有的常旅客人数，
该UC号2018年6月1日-2019年5月31日出过国内机票的常旅客人数，
该UC号2017年6月1日-2019年5月31日出过国内机票的常旅客人数，
该司MU和FM的国内S V T Z舱出票销量站国内总销量占比
*/

--单位明细
if OBJECT_ID('tempdb..#dwmx') is not null drop table #dwmx
select u.Cmpid UC号,u.Name 单位名称,s1.Name 差旅顾问,s2.Name 运营经理
into #dwmx
from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_TktUnitCompanies_TktTCs t on t.TktUnitCompanyID=u.ID
left join Topway..HM_ThePreservationOfHumanInformation h on h.CmpId=u.Cmpid and IsDisplay=1 and MaintainType=9
left join homsomDB..SSO_Users s1 on s1.ID=t.TktTCID
left join homsomDB..SSO_Users s2 on s2.UserID=h.MaintainNumber
where CertificateD=2
and CooperativeStatus in ('1','3')
and IsSepPrice=1
and u.Type='A'

--销量明细
if OBJECT_ID('tempdb..#xlmx') is not null drop table #xlmx
select cmpcode,SUM(totprice) 国内销量1,SUM(profit) 国内利润金额1,SUM(profit) /SUM(totprice) 国内利润率 
into #xlmx
from Topway..tbcash
where cmpcode in(Select UC号 from  #dwmx )
and inf=0
and datetime>='2018-07-01'
and datetime<'2019-07-01'
group by cmpcode

--所有常旅客人数
if OBJECT_ID('tempdb..#clrs') is not null drop table #clrs
select Cmpid,SUM(1)所有常旅客人数
into #clrs
from homsomDB..Trv_Human h 
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid in (Select UC号 from  #dwmx )
and IsDisplay=1
group by Cmpid

--该UC号2018年6月1日-2019年5月31日出过国内机票的常旅客人数
if OBJECT_ID('tempdb..#cprs') is not null drop table #cprs
select cmpcode,pasname,idno,COUNT(1)张数 
into #cprs
from Topway..tbcash 
where cmpcode in(Select UC号 from  #dwmx)
and datetime>='2018-06-01'
and datetime<'2019-06-01'
and inf=0
group by cmpcode,pasname,idno

if OBJECT_ID('tempdb..#cprs2') is not null drop table #cprs2
select cmpcode,COUNT(1)常旅客人数1 into #cprs2 from #cprs group by cmpcode

--该UC号2017年6月1日-2019年5月31日出过国内机票的常旅客人数
if OBJECT_ID('tempdb..#cprs1') is not null drop table #cprs1
select cmpcode,pasname,idno,COUNT(1)张数 
into #cprs1
from Topway..tbcash 
where cmpcode in(Select UC号 from  #dwmx)
and datetime>='2017-06-01'
and datetime<'2019-06-01'
and inf=0
group by cmpcode,pasname,idno

if OBJECT_ID('tempdb..#cprs3') is not null drop table #cprs3
select cmpcode,COUNT(1)常旅客人数2 into #cprs3 from #cprs1 group by cmpcode

--该司MU和FM的国内S V T Z舱出票销量站国内总销量占比
if OBJECT_ID('tempdb..#xlzb') is not null drop table #xlzb
select c.cmpcode,SUM(c.totprice) 国内销量2,SUM(c.totprice)/sum(m.国内销量1) 国内总销量占比
into #xlzb
from Topway..tbcash c
left join #xlmx m on m.cmpcode=c.cmpcode
where c.cmpcode in(Select UC号 from  #dwmx )
and inf=0
and datetime>='2018-07-01'
and datetime<'2019-07-01'
and c.ride in('FM','MU')
and c.nclass in ('s','v','t','z')
group by c.cmpcode

select dw.UC号,单位名称,差旅顾问,运营经理,isnull(国内销量1,0) 国内销量1,isnull(国内利润金额1,0) 国内利润金额1,isnull(国内利润率,0) 国内利润率,
isnull(所有常旅客人数,0) 所有常旅客人数,isnull(常旅客人数1,0) 常旅客人数1,isnull(常旅客人数2,0) 常旅客人数2,isnull(国内销量2,0) 国内销量2,isnull(国内总销量占比,0) 国内总销量占比
from #dwmx dw
left join #xlmx xl on dw.UC号=xl.cmpcode
left join #clrs cl on cl.Cmpid=dw.UC号
left join #cprs2 cp on cp.cmpcode=dw.UC号
left join #cprs3 cp1 on  cp1.cmpcode=dw.UC号
left join #xlzb zb on  zb.cmpcode=dw.UC号
where dw.UC号 not in ('000003')
order by dw.UC号



--（产品专用）保险结算价信息
select sprice1,totsprice,profit,totprice,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=2.2,totsprice=2.2
where coupno in ('AS002525174','AS002525706','AS002525705',
'AS002532250','AS002542863','AS002545040','AS002549740','AS002549898',
'AS002549899','AS002549911','AS002549912','AS002550471','AS002550478',
'AS002552613','AS002552614')

select sprice1,totsprice,profit,totprice,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=2.2,totsprice=2.2
where coupno in ('AS002520739','AS002533850')

select sprice1,totsprice,profit,totprice,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=3.9,totsprice=3.9
where coupno in ('AS002519869','AS002519871','AS002520369','AS002520368')

select sprice1,totsprice,profit,totprice,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=3.9,totsprice=3.9
where coupno in ('AS002522337','AS002522328','AS002522307','AS002523407',
'AS002525785','AS002527856','AS002528027','AS002528194','AS002528839','AS002528840',
'AS002529350','AS002534336','AS002535150','AS002539378','AS002539426','AS002540086',
'AS002540106','AS002540137','AS002540176','AS002540460','AS002543115','AS002543426',
'AS002546104','AS002546115','AS002547420','AS002547436','AS002550617','AS002551362',
'AS002551364','AS002552387','AS002554345','AS002556000','AS002556367','AS002556453')

--（产品部专用）结算价信息（国际）
select pasname,* from Topway..tbcash 
where tcode+ticketno='1157355670355'


--撤销闭团及闭团相关信息（会务）
select Status,* from Topway..tbConventionBudget where ConventionId='1413'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set SpareTC='蒋燕华'
where coupno='AS001709343'

--火车票销售价信息
select TotFuprice,TotPrice,TotPrintPrice,TotSprice,TotUnitprice,* from Topway..tbTrainTicketInfo 
--update Topway..tbTrainTicketInfo  set TotFuprice=0,TotPrice=TotPrice-15
where CoupNo in('RS000024581','RS000024582','RS000024583','RS000024584')

select Fuprice,* from Topway..tbTrainUser
--update  Topway..tbTrainUser set Fuprice=0
where TrainTicketNo in(select ID  from Topway..tbTrainTicketInfo 
where CoupNo in('RS000024581','RS000024582','RS000024583','RS000024584'))

--旅游收款单信息
select Skstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Skstatus=2
where TrvId='29795' and Id='228120'

--旅游结算单信息
select GysSource,* from Topway..tbTrvJS 
--update Topway..tbTrvJS  set GysSource='通达'
where TrvId='30188'

--会务收款单信息 进位
select Pstatus,PrDate,Price,totprice,owe,InvoiceTax,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set InvoiceTax=770
where ConventionId='1440' and Id='2778'

--重开打印
select Pstatus,PrDate,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set Pstatus=0,PrDate='1900-01-01'
where ConventionId='1440' and Id='2778'

--结算价进位
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002555459','AS002555460','AS002556191')

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice-1,profit=profit+1
where coupno in('AS002556192')

--账单撤销
select HotelSubmitStatus,* from Topway..AccountStatement  
--update Topway..AccountStatement   set HotelSubmitStatus=1
where BillNumber='018309_20190501'

select * from ApproveBase..App_Content where AppID='APP201906140019'

select * from ApproveBase..App_DefineBase 

select * from ApproveBase..HR_AskForLeave_Signer


--（产品专用）申请费来源/金额信息（国际
SELECT feiyong,feiyonginfo,profit,* FROM Topway..tbcash 
--update Topway..tbcash  set feiyonginfo=''
WHERE coupno='AS002559355'

SELECT feiyong,feiyonginfo,profit,* FROM Topway..tbcash 
--update Topway..tbcash  set feiyonginfo='申请座位ZYI'
WHERE coupno='AS002556101'


--删除项目编号
select Code,* 
--delete
from homsomDB..Trv_Customizations 
where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019392') 
and Code='140970001.88000'


select empname,idnumber from Topway..Emppwd where dep in('技术部','技术研发中心') and idnumber not in ('00000','00001')