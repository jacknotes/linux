--账单后加入所提醒的最低价航班号以及起降时间 
SELECT c.coupno,lp.Price 最低价,lp.DepartureTime,lp.ArrivalTime,ride+flightno 航班号
 FROM topway..tbcash c 
LEFT JOIN homsomDB..Trv_DomesticTicketRecord r ON c.coupno=r.RecordNumber
LEFT JOIN homsomDB..Trv_PnrInfos p ON r.PnrInfoID=p.ID
LEFT JOIN homsomDB..Trv_ItktBookings i ON p.ItktBookingID=i.ID
left join homsomDB..Trv_ItktBookingSegs its on i.ID=its.ItktBookingID
left join homsomDB..Trv_LowerstPrices lp on its.ID=lp.ItktBookingSegID
where coupno in ('AS002441956',
'AS002441958',
'AS002442002',
'AS002446783',
'AS002447233',
'AS002447249',
'AS002449221',
'AS002450642',
'AS002452530',
'AS002453370',
'AS002454809',
'AS002456621',
'AS002456958',
'AS002457522',
'AS002457749',
'AS002457752',
'AS002457795',
'AS002457808',
'AS002458000',
'AS002458000',
'AS002458000',
'AS002458000',
'AS002458013',
'AS002458013',
'AS002458013',
'AS002458013',
'AS002458043',
'AS002458043',
'AS002458043',
'AS002458043',
'AS002459270',
'AS002459285',
'AS002459814',
'AS002461330',
'AS002462812',
'AS002464501',
'AS002464503',
'AS002464824',
'AS002465317',
'AS002465802',
'AS002470425',
'AS002472999',
'AS002475150',
'AS002476320',
'AS002478104',
'AS002484987',
'AS002484989',
'AS002485532',
'AS002485534',
'AS002485538',
'AS002486243',
'AS002488051',
'AS002491857',
'AS002491859',
'AS002491949',
'AS002498129',
'AS002498132',
'AS002499502',
'AS002503970',
'AS002507841',
'AS002508230',
'AS002510776',
'AS002511084',
'AS002511088',
'AS002511213',
'AS002511543',
'AS002511594',
'AS002512121',
'AS002512123',
'AS002512251',
'AS002512511',
'AS002513191',
'AS002516407',
'AS002516545',
'AS002517944',
'AS002518294',
'AS002518963',
'AS002518967')
and lp.Price<>''
order by c.coupno


--修改UC号（机票）

select custid,ModifyBillNumber,OriginalBillNumber,cmpcode,pform,* from Topway..tbcash
--update  Topway..tbcash set custid='D644037',OriginalBillNumber='020776_20190501',cmpcode='020776',pform='月结(招行)'
where coupno in('AS002482699','AS002502896','AS002502895')

--UC020637删除常旅客
select * from homsomDB..Trv_Human 
--update homsomDB..Trv_Human set IsDisplay=0
where id in (Select id from homsomDB..Trv_UnitPersons
where CompanyID=(Select id from homsomDB..Trv_UnitCompanies where Cmpid='020637'))
and IsDisplay=1 and Name not in('隋鑫','董爽')

select EmployeeStatus,* from Topway..tbCusholderM 
--update Topway..tbCusholderM  set EmployeeStatus=0
where cmpid='020637' and custid not in ('D617503','D617504') and EmployeeStatus=1

--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='需打印中文行程单'
where coupno in('AS002465927','AS002453661')

select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='需打印行程单'
where coupno in('AS002488145')

--会务收款单作废
select Skstatus,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set Skstatus=2
where ConventionId='1429' and Id='2747'


--UC020758和铂医药员工提前预订机票的明细，包含：订票人，乘机人（有部门最好），行程，折扣舱位，票面总价，出行时间，出票时间
select DATEDIFF(DD,[datetime],begdate) 提前出票天数,[datetime] 出票时间,begdate 起飞时间,h.Name 订票人,pasname 乘机人,Department 部门 
,[route] 行程,case when priceinfo=0 then 1 else price/priceinfo end 折扣率,totprice 票面总价,reti 退票单号,tickettype 票类型
from Topway..tbcash c
left join homsomDB..Trv_UnitPersons u on u.CustID=c.custid
left join homsomDB..Trv_Human h on h.ID=u.ID
where cmpcode='020758'
and inf=1
order by 出票时间

--1、天纳克（UC016448）2018全年，东上航Y舱冲88折机票明细（去退改）
select datetime 出票日期,begdate 起飞日期,coupno 销售单号,pasname 乘机人,c.route 行程,tcode+ticketno 票号,ride+flightno 航班号
,priceinfo 全价,price/priceinfo 折扣率,originalprice 原价,price 销售单价,coupon 优惠金额,tax 税收,xfprice 前返金额
, totprice 销售价,DATEDIFF(DD,datetime,begdate)提前出票天数,CostCenter 成本中心,nclass 舱位
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs t on t.ItktBookingID=p.ItktBookingID
--left join homsomDB..Trv_RebateRelations r on t.RebateStr=r.FlightNormalPolicyID 
where cmpcode='016448' --and [Percent]=3
and datetime>='2018-01-01' and datetime<'2019-01-01' AND c.inf=0 AND c.tickettype='电子票' AND c.originalprice>c.price AND c.ride IN('FM','MU') and reti=''
AND  CONVERT(DECIMAL(18,2),c.price/c.originalprice)=0.88

--2、天纳克 (UC016448) 2018全年，国内机票前返3%所有机票明细（去退改） 
select  datetime 出票日期,begdate 起飞日期,coupno 销售单号,pasname 乘机人,c.route 行程,tcode+ticketno 票号,ride+flightno 航班号
,priceinfo 全价,'' 折扣率,originalprice 原价,c.price 销售单价,coupon 优惠金额,tax 税收,xfprice 前返金额
, totprice 销售价,DATEDIFF(DD,datetime,begdate)提前出票天数,CostCenter 成本中心,nclass 舱位 from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs t on t.ItktBookingID=p.ItktBookingID
left join homsomDB..Trv_RebateRelations r on t.RebateStr=r.FlightNormalPolicyID 
where cmpcode='016448' and [Percent]=3
and datetime>='2018-01-01' and datetime<'2019-01-01' AND c.inf=0 AND c.tickettype='电子票'  and reti=''
order by datetime


select * from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs t on t.ItktBookingID=p.ItktBookingID
left join homsomDB..Trv_RebateRelations r on t.RebateStr=r.ID 
where cmpcode='016448' and [Percent]=3
and datetime>='2018-01-01' and datetime<'2019-01-01'


/*
UC018309
UC019392
UC019394
UC016588
UC015828
UC019358
UC020758
UC018431
2019年5月1日-5月31日期间，国内机票、国际机票两舱的消费金额
*/
--国内
select cmpcode,SUM(totprice) 消费金额 from Topway..tbcash 
where cmpcode in('018309','019392','019394','016588','015828','019358','020758','018431')
and datetime>='2019-05-01' and datetime<'2019-06-01'
and inf=0 
and (CabinClass like('%头等舱%') or CabinClass like('%公务舱%'))
group by cmpcode

--国际
select cmpcode,SUM(totprice)消费金额 from Topway..tbcash c
left join #cabin ca on ca.cabin=c.nclass
where cmpcode in('018309','019392','019394','016588','015828','019358','020758','018431')
and datetime>='2019-05-01' and datetime<'2019-06-01'
and (CabinName like('%头等舱%') or CabinName like('%公务舱%'))
and inf=1 
group by cmpcode


if OBJECT_ID('tempdb..#cabin') is not null  drop table #cabin
select distinct CabinName,Cabin 
into #cabin
from homsomDB..Intl_BookingLegs 
where CabinName<>''

select * from #cabin

/*
审核日期：2019年3月10日至2019年5月31日    备注含“SME”
 
要素：票号、销售单号、供应商来源、退票单号、提交日期、审核日期、航空公司退票费、收客户退票金额、出票操作业务顾问、出票业务顾问、提交退票业务顾问、备注
*/
select  tcode+c.ticketno 票号,t.coupno 销售单号,t_source 供应商来源,reno 退票单号,edatetime 提交日期
,ExamineDate 审核日期,scount2 航空公司退票费,rtprice 收客户退票金额,c.SpareTC 出票操作业务顾问,
c.sales 出票业务顾问 ,opername 提交退票业务顾问,t.info
from Topway..tbReti t
left join Topway..tbcash c on c.reti=t.reno
where ExamineDate>='2019-03-10' and ExamineDate<'2019-06-01'
and t.info like'%SME%'
order by 审核日期

/*
请帮忙提供“不开通特殊票价”的单位数据单独发给对应各组差旅运营经理，谢谢！
 
 UC号  单位名称     服务费    是否捆绑保险   MU近半年F ，J ，Y销量   MU近半年Y舱以下销量  差旅顾问  运营经理  客户经理
 
备注：自签二方三方的单位去除掉
*/
select u.Cmpid,u.Name,IsSepPrice 国内特殊票价, * 
from homsomDB..Trv_UnitCompanies u 
left join ehomsom..tbCompanyXY t on  t.CmpId=u.Cmpid 
left join homsomDB..Trv_FlightTripartitePolicies f on f.UnitCompanyID=u.ID 
where t.[Type]<>1 and IsSelfRv=0 

 select * FROM [homsomdb].[dbo].[Trv_UCSettings]
  where BindAccidentInsurance is not null and BindAccidentInsurance <>''


--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002523101','AS002523606','AS002523635','AS002524053','AS002527323','AS002529247')

--重开打印权限
select prdate,pstatus,HXQM,* from topway..tbHtlSettlementApp 
--update topway..tbHtlSettlementApp  set prdate='1900-01-01',pstatus=0,HXQM=''
where id='25953'

/*
请帮忙拉取海南航空国内线，销售日期：2019年01月-5月31日，
票面价（不含税收）大于1000以上的相关出票数据明细
*/
select cmpcode,coupno,datetime,begdate,pasname,route,tcode+ticketno,
ride+flightno,price,totprice,tax 
from Topway..tbcash 
where datetime>='2019-01-01'
and datetime<'2019-06-01'
and inf=0
and price>1000
and ride='HU'
order by datetime

--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno in('AS002465927','AS002453661','AS002495360','AS002486224','AS002486225','AS002486482','AS002486625','AS002486939')

--补票号
--select pasname,* from Topway..tbcash where coupno='AS002509343'
update Topway..tbcash set pasname='TANG/XINGJUANMS',tcode='235',ticketno='2384017495' where coupno='AS002509343' and pasname='乘客0'
update Topway..tbcash set pasname='LI/YINGMS',tcode='235',ticketno='2384017497' where coupno='AS002509343' and pasname='乘客1'
update Topway..tbcash set pasname='WANG/FANGMS',tcode='235',ticketno='2384017499' where coupno='AS002509343' and pasname='乘客2'
update Topway..tbcash set pasname='YIN/GUIHUAMS',tcode='235',ticketno='2384017501' where coupno='AS002509343' and pasname='乘客3'
update Topway..tbcash set pasname='ZHANG/XINYUNMS',tcode='235',ticketno='2384017503' where coupno='AS002509343' and pasname='乘客4'
update Topway..tbcash set pasname='SHEN/FANGMS',tcode='235',ticketno='2384017505' where coupno='AS002509343' and pasname='乘客5'
update Topway..tbcash set pasname='ZHOU/HONGMS',tcode='235',ticketno='2384017507' where coupno='AS002509343' and pasname='乘客6'
update Topway..tbcash set pasname='ZHANG/RUIFANGMS',tcode='235',ticketno='2384017509' where coupno='AS002509343' and pasname='乘客7'
update Topway..tbcash set pasname='HE/HONGXINGMR',tcode='235',ticketno='2384017511' where coupno='AS002509343' and pasname='乘客8'
update Topway..tbcash set pasname='YANG/JIEMR',tcode='235',ticketno='2384017513' where coupno='AS002509343' and pasname='乘客9'
update Topway..tbcash set pasname='CHEN/GANGMR',tcode='235',ticketno='2384017515' where coupno='AS002509343' and pasname='乘客10'
update Topway..tbcash set pasname='CAO/XILAIMR',tcode='235',ticketno='2384017517' where coupno='AS002509343' and pasname='乘客11'
update Topway..tbcash set pasname='ZHI/WUPINGMS',tcode='235',ticketno='2384017519' where coupno='AS002509343' and pasname='乘客12'
update Topway..tbcash set pasname='LIU/JINGSONGMR',tcode='235',ticketno='2384017521' where coupno='AS002509343' and pasname='乘客13'
