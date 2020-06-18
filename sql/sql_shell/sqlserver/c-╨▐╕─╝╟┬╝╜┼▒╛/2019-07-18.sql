--现求助汤总请将020805中剔除下出过CZ的F/J/W/Y/B/M/H/U/A/L舱名单 乘机人
select distinct idno from Topway..tbcash 
where cmpcode='020805'
and ride='cz'
and nclass in('F','J','W','Y','B','M','H','U','A','L')
and datetime>='2019-05-01'

--2.1
select sales 差旅顾问,SpareTC 操作顾问,SUM(isnull(c.totprice,0)-ISNULL(t.totprice,0)) 合计销售价,
SUM(isnull(c.profit,0)+isnull(t.profit,0)) 合计利润,
SUM(Mcost) 合计资金费用,SUM(fuprice) 合计服务费
from Topway..tbcash c
left join Topway..tbReti t on c.reti=t.reno and status2<>4
where c.datetime>='2019-07-01'
group by sales,SpareTC
order BY 合计销售价 DESC

--重开打印
select HXQM,* from topway..tbHtlSettlementApp 
--update topway..tbHtlSettlementApp  set HXQM=''
where id='26227'

--AS002526510 AS002589634 AS002589917 退票单号 9267207 核销改成未付
--机票销售单改为未付
select bpay,status,opernum,oper2,oth2,totprice,dzhxDate,owe,vpay,vpayinf,dzhxDate
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
from Topway..tbcash where coupno in ('AS002526510','AS002589634','AS002589917')

--修改退票核销
select ExamineDate,ModifyBillNumber,status2,* from Topway..tbReti 
--update Topway..tbReti set ExamineDate='1900-01-01',status2='8'
where reno='9267207'

--到账认领改成未应收会计未审核 
select state,* from Topway..FinanceERP_ClientBankRealIncomeDetail 
--update Topway..FinanceERP_ClientBankRealIncomeDetail  set state=5
where date='2019-07-16' and money='2230'

--国际行程起飞日期
select tcode+ticketno 票号,b.Sort,convert(varchar(18),DepartureTime,120) 起飞日期,CityName1 出发城市 from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where tcode+ticketno in('9322874436190',
'7812876524228',
'9325320692262',
'9325321023827',
'7812080298384',
'9322081507091',
'7814476488629',
'6182694796746',
'7812080707486',
'1252080705977',
'7812695776209',
'1252695768774',
'7812696056673',
'7812760777045',
'9322875454220')
order by b.Sort

--2.2业务顾问
SELECT Sales 旅游顾问,JiDIao 单团支持,SUM(XsPrice) 合计销售金额,SUM(JsZPrice) 合计结算金额,SUM(Profit) 合计利润
from Topway..tbTrvCoup
where OperDate>='2019-07-01'
group by Sales,JiDIao
order by 合计销售金额 desc

--2.2开发人
select t2.OperDate 预算单录入日期,indate 单位注册日期,ss.Name 开发人,SUM(DisCountProfit) 合计计提利润
from Topway..tbTrvCoup t1
left join Topway..tbTravelBudget t2 on t2.TrvId=t1.TrvId
left join homsomDB..Trv_UnitCompanies  u on u.Cmpid=t1.Cmpid 
left join homsomDB..Trv_UnitCompies_Sales s on s.UnitCompayID=u.ID
left join Topway..tbCompanyM t3 on t3.cmpid=u.Cmpid
left join homsomDB..SSO_Users ss on ss.ID=s.EmployeeID
where t1.OperDate>='2019-07-01'
and t1.Cmpid<>''
group by t2.OperDate,indate,ss.Name
order by 预算单录入日期

--2.3业务顾问
SELECT Sales 旅游顾问,JiDIao 单团支持,SUM(XsPrice) 合计销售金额,SUM(JsZPrice) 合计结算金额,SUM(Profit) 合计利润
from Topway..tbConventionCoup
where OperDate>='2019-07-01'
group by Sales,JiDIao
order by 合计销售金额 desc

--2.3开发人
select t2.OperDate 预算单录入日期,indate 单位注册日期,ss.Name 开发人,SUM(DisCountProfit) 合计计提利润
from Topway..tbConventionCoup t1
left join Topway..tbConventionBudget t2 on t2.ConventionId=t1.ConventionId
left join homsomDB..Trv_UnitCompanies  u on u.Cmpid=t1.Cmpid 
left join homsomDB..Trv_UnitCompies_Sales s on s.UnitCompayID=u.ID
left join Topway..tbCompanyM t3 on t3.cmpid=u.Cmpid
left join homsomDB..SSO_Users ss on ss.ID=s.EmployeeID
where t1.OperDate>='2019-07-01'
and t1.Cmpid<>''
group by t2.OperDate,indate,ss.Name
order by 预算单录入日期

select top 100 * from homsomDB..Trv_LowerstPrices

--3.1国内
select cmpcode UC,Name 单位名称,convert(varchar(10),datetime,120) 出票日期,begdate 起飞日期,coupno 销售单号,pasname 乘机人,c.route 行程,tcode+ticketno 票号,
 ride 航司,flightno 航班编号,priceinfo 全价,c.price 销售单价,tax 税收,totprice 销售价,profit 利润,Mcost 资金费用,originalprice 原价,xfprice 前返金额,c.fuprice 服务费,
 Department 部门,CostCenter 成本中心,DATEDIFF(DD,datetime,begdate) 提前出票天数,reti 退票单号,nclass 舱位代码,CabinClass 舱位等级,isnull(convert(varchar(10),l.Price),'')最低价,isnull(l.UnChoosedReason,'')Reasoncode,tickettype 机票类型
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on cmpcode=Cmpid
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos it on it.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=it.ItktBookingSegID
where cmpcode='016448'
and datetime>='2019-07-01'
and inf=0

--3.1国际
select cmpcode UC,Name 单位名称,convert(varchar(10),datetime,120) 出票日期,begdate 起飞日期,coupno 销售单号,pasname 乘机人,route 行程,tcode+ticketno 票号,
 ride 航司,flightno 航班编号,priceinfo 全价,c.price 销售单价,tax 税收,totprice 销售价,profit 利润,Mcost 资金费用,xfprice 前返金额,c.fuprice 服务费,
 Department 部门,CostCenter 成本中心,DATEDIFF(DD,datetime,begdate) 提前出票天数,reti 退票单号,nclass 舱位代码,CabinClass 舱位等级,tickettype 机票类型
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on cmpcode=Cmpid
where cmpcode='016448'
and datetime>='2019-07-01'
and inf=1

--拆单20人
select MobileList,CostCenter,pcs,Department,* from topway..tbFiveCoupInfosub
--update topway..tbFiveCoupInfosub set MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='20',Department='无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无' 
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002645860')

--更改支付方式（自付、垫付）
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,vpayinf,* from Topway..tbcash 
--update Topway..tbcash set PayNo=TCPayNo,TCPayNo='',PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=null,CustomerPayDate=TcPayDate,dzhxDate=TcPayDate,TcPayDate='1900-01-01',status=1,owe=0,vpay=totprice
where coupno in ('AS001711814')

select PayStatus,AdvanceStatus,PayNo,TCPayNo,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET PayStatus=AdvanceStatus,PayNo=TCPayNo,CustomerPayWay=TcPayWay,CustomerPayDate=TcPayDate,AdvanceStatus=0,TCPayNo='',TcPayWay=0,TcPayDate=null
WHERE CoupNo in ('AS001711814')

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='019014_20190601'

/*
请帮忙拉取2019年5月13日之后新签约的客户，
要求
1，国内特殊票价为“是”的客户
2，需展示内容：开通UC号的日期，UC号，单位名称，常旅客全部名单数，已经出过机票的常旅客名单数，合作至今的国内销量，国内利润，利润率，请按组展示
*/
--单位名单
if OBJECT_ID('tempdb..#dw') is not null drop table #dw
select indate 开通UC号的日期,cmpid UC号,cmpname  单位名称
into #dw
from Topway..tbCompanyM 
where indate>='2019-05-13'
and IsSepPrice=1
order by 开通UC号的日期
--常旅客名单
select Cmpid UC号,h.Name 中文姓名,LastName+'/'+FirstName+MiddleName 英文姓名,cr.CredentialNo  证件号
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on h.ID=u.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
left join homsomDB..Trv_Credentials cr on cr.HumanID=h.ID
where Cmpid in(Select UC号 from #dw)
order by UC号

if OBJECT_ID('tempdb..#lks') is not null drop table #lks
select Cmpid UC号,COUNT(1)  常旅客名单数
into #lks
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on h.ID=u.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
left join homsomDB..Trv_Credentials cr on cr.HumanID=h.ID
where Cmpid in(Select UC号 from #dw)
group by Cmpid
order by UC号

--出过机票人数
if OBJECT_ID('tempdb..#rs') is not null drop table #rs
select distinct cmpcode UC号,pasname 乘机人,idno 证件号  
into #rs
from Topway..tbcash 
where cmpcode in (Select UC号 from #dw)

if OBJECT_ID('tempdb..#rs1') is not null drop table #rs1
select UC号,COUNT(1) 人数 into #rs1 from #rs group by UC号
--销量
if OBJECT_ID('tempdb..#XL') is not null drop table #XL
select c.cmpcode UC号,SUM(isnull(c.totprice,0)-isnull(t.totprice,0)) 合作至今的国内销量,
SUM(isnull(c.profit,0)+isnull(t.profit,0)) 国内利润,'' 利润率
into #XL
from Topway..tbcash c
left join Topway..tbReti t on c.reti=t.reno
where C.cmpcode in (Select UC号 from #dw)
and c.inf=0
group by c.cmpcode
ORDER BY UC号

select h.MaintainName 运营经理,convert(varchar(18),开通UC号的日期,120) 开通UC号的日期,d.UC号,常旅客名单数,isnull(人数,0) as 出过机票人数,isnull(合作至今的国内销量,0) 合作至今的国内销量,isnull(国内利润,0) 国内利润
from #dw d
left join #rs1 r on r.UC号=d.UC号
left join #XL x on x.UC号=d.UC号
left join #lks l on L.UC号=d.UC号
left join Topway..HM_ThePreservationOfHumanInformation h on h.CmpId=d.UC号 and MaintainType=9 and IsDisplay=1
order by 运营经理,开通UC号的日期


--旅游收款单信息
SELECT Skstatus,* FROM Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Skstatus=2
where TrvId='30115'

--删除常旅客 UC020548竹间智能科技（上海）有限公司
select distinct Mobile from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies
where Cmpid='020548')) and IsDisplay=1
and Mobile in('18600566682',
'18510900920',
'13321101159',
'15701665293',
'15948022480',
'13683281000',
'13021689296',
'15890656380',
'18310252704',
'18911716626',
'17346523695',
'18911411560',
'15101579545',
'15737129735',
'18601083290',
'13520091244',
'17610510915',
'13701329460',
'15201113751',
'18684312033',
'18911907578',
'13911156290',
'15910845564',
'18810800920',
'18510332870',
'15116997250',
'13515390716',
'13581828468',
'18604325791',
'13141310357',
'18510180315',
'13520326929',
'18600463756',
'18500847946',
'13910783063',
'13601353652',
'13381158750',
'13661010080',
'18611343721',
'18500541280',
'13011168709',
'13691399836',
'18611755760',
'18511929268',
'15011481930',
'18600736986',
'15810915106',
'13321175207',
'18600983336',
'18621165065',
'13520541350',
'13379023011',
'15801312408',
'15611731216',
'13501083209',
'13811323798',
'13608020722',
'18526285693',
'13911676814',
'15011186889',
'13810852031',
'13581757101',
'15694343651',
'18611700660',
'17701023782',
'18001134519',
'18513771919',
'18519099965',
'15810909818',
'13811963507',
'17710902205',
'16607371566',
'17801190551')


select * from Topway..tbCusholderM 
--update Topway..tbCusholderM  set EmployeeStatus=0
where mobilephone in('18600566682',
'18510900920',
'13321101159',
'15701665293',
'15948022480',
'13683281000',
'13021689296',
'15890656380',
'18310252704',
'18911716626',
'17346523695',
'18911411560',
'15101579545',
'15737129735',
'18601083290',
'13520091244',
'17610510915',
'13701329460',
'15201113751',
'18684312033',
'18911907578',
'13911156290',
'15910845564',
'18810800920',
'18510332870',
'15116997250',
'13515390716',
'13581828468',
'18604325791',
'13141310357',
'18510180315',
'13520326929',
'18600463756',
'18500847946',
'13910783063',
'13601353652',
'13381158750',
'13661010080',
'18611343721',
'18500541280',
'13011168709',
'13691399836',
'18611755760',
'18511929268',
'15011481930',
'18600736986',
'15810915106',
'13321175207',
'18600983336',
'18621165065',
'13520541350',
'13379023011',
'15801312408',
'15611731216',
'13501083209',
'13811323798',
'13608020722',
'18526285693',
'13911676814',
'15011186889',
'13810852031',
'13581757101',
'15694343651',
'18611700660',
'17701023782',
'18001134519',
'18513771919',
'18519099965',
'15810909818',
'13811963507',
'17710902205',
'16607371566',
'17801190551')

select distinct Mobile from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies
where Cmpid='020548')) and IsDisplay=1
and Name in ('孟庆龙','周宇','闫俊')

--修改销售价
select price+tax+fuprice,totprice,owe,amount,* from Topway..tbcash 
--update Topway..tbcash  set totprice=1895,totprice=1895,amount=1895
where coupno='AS002588421'

select IsJoinRank,* from Topway..Emppwd 
--update Topway..Emppwd  set IsJoinRank=1
where idnumber='0743'