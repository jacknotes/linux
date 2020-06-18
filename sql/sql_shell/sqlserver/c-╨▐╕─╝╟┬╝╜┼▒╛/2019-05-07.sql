--4/9个人机票，庄秋萍的核销数据
select coupno 销售单号,bpay 贷记金额,oper2 操作姓名,datetime2 操作时间 from Topway..tbcash 
where oper2='庄秋萍'
and datetime2>='2019-04-09'
and datetime2<'2019-04-10'

/*
 AS002426439 原供应商来源 HS易商大金D 修改为 HSBSPETD 4/24 
 AS002426441 原供应商来源 HS易商大金D 修改为 HSBSPETD 4/26 
 AS002433096 原供应商来源 HS易商高顿D 修改为 HSBSPETD 4/30 
 AS002440662 原供应商来源 HSBSPETD 修改为 HS易商高顿D 4/30 
 AS002440880 原供应商来源 HSBSPETD 修改为 HS易商天纳克D 4/22 
 AS002419613 原供应商来源 HS易商维新力特D 修改为 HSBSPETD 4/22 
 AS002420819 原供应商来源 HS易商家乐福D 修改为 HSBSPETD 4/22 
 AS002421059 原供应商来源 HS易商月星D 修改为 HSBSPETD 4/22 
 AS002421272 原供应商来源 HS易商泰欣D 修改为 HSBSPETD 4/23 
 AS002422979 原供应商来源 HS易商胜彼I 修改为 HSBSPETI 4/24 
 AS002425712 原供应商来源 HS易商伊藤忠I 修改为 HSBSPETI
 */
 --修改供应商来源
 select t_source,* from Topway..tbcash 
 --update Topway..tbcash set t_source='HSBSPETD'
 where coupno in ('AS002426439','AS002426441','AS002433096','AS002419613','AS002420819','AS002421059',
 'AS002421272')
 
 select t_source,* from Topway..tbcash 
 --update Topway..tbcash set t_source='HSBSPETI'
 where coupno in ('AS002422979','AS002425712')
 
  select t_source,* from Topway..tbcash 
 --update Topway..tbcash set t_source='HS易商高顿D'
 where coupno in ('AS002440662')
 
  select t_source,* from Topway..tbcash 
 --update Topway..tbcash set t_source='HS易商天纳克D'
 where coupno in ('AS002440880')
 
 --财务到账改成未阅
 select haschecked,* from Topway..FinanceERP_ClientBankRealIncomeDetail 
 --update Topway..FinanceERP_ClientBankRealIncomeDetail  set haschecked=0
 where date='2019-04-02' and money='1300'


--到账未审核
select state from topway..FinanceERP_ClientBankRealIncomeDetail 
--update topway..FinanceERP_ClientBankRealIncomeDetail set state=5
where date='2019-04-02' and money='1300'

--重开打印
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus=0,PrDate='1900-01-01'
where TrvId='29979' and Id='227889'

--运营小组网单数
/*网单=1
手工导单=2
电话预订=3
空白导单=4
app=5
宝库=7
官网=6
旅游内采=8
会务内采=9
微信预订=10
wap预订=11
*/
IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select distinct c.coupno,e.team 业务顾问组
into #cmp1
from Topway..tbcash c
inner join homsomDB..Trv_ItktBookings it on it.ID=c.BaokuID
inner join Topway..Emppwd e on e.empname=c.sales
where datetime>='2019-04-01'
and datetime<'2019-05-01'
and c.ConventionYsId=0
and c.trvYsId=0
and inf=0
and it.BookingSource in ('1','5','6','10','11')
and tickettype='电子票'
and reti=''

select COUNT(coupno) 网单数,业务顾问组 from #cmp1
group by 业务顾问组
order by 网单数 desc


/*
UC018734    三井住友银行（中国）有限公司  
      烦请按以下模板提供该公司自2016年合作以来所有Ana航空的机票信息 NH
      出票日期	电子销售单号	PNR	票号	起飞日期	乘客姓名	航程	舱位	销售价	前返（1%）	结算价	服务费（3%）	销售利润	航班号
*/
select convert(varchar(10),datetime,120) 出票日期,coupno,recno,begdate,pasname,route,nclass,totprice,xfprice,
totsprice,fuprice,profit,ride +flightno 
from Topway..tbcash 
where cmpcode='018734'
and datetime>='2016-01-01'
and ride='NH'
order by 出票日期

--行程单、特殊票价
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno='AS002395502'

--补票号
--select pasname,* from Topway..tbcash where coupno='AS002450753'
update Topway..tbcash set tcode='781',ticketno='2400378478',pasname='CHEN/HUAZHONG' where coupno='AS002450753' and pasname='乘客0'
update Topway..tbcash set tcode='781',ticketno='2400378479',pasname='FAN/JIANHUI' where coupno='AS002450753' and pasname='乘客1'
update Topway..tbcash set tcode='781',ticketno='2400378480',pasname='GAO/KEWEI' where coupno='AS002450753' and pasname='乘客2'
update Topway..tbcash set tcode='781',ticketno='2400378481',pasname='GU/LEI' where coupno='AS002450753' and pasname='乘客3'
update Topway..tbcash set tcode='781',ticketno='2400378482',pasname='KAN/ZONGGANG' where coupno='AS002450753' and pasname='乘客4'
update Topway..tbcash set tcode='781',ticketno='2400378483',pasname='LIU/JIHONG' where coupno='AS002450753' and pasname='乘客5'
update Topway..tbcash set tcode='781',ticketno='2400378484',pasname='LYU/WEIQI' where coupno='AS002450753' and pasname='乘客6'
update Topway..tbcash set tcode='781',ticketno='2400378485',pasname='QIAN/ZHENJIE' where coupno='AS002450753' and pasname='乘客7'
update Topway..tbcash set tcode='781',ticketno='2400378486',pasname='SHAN/YIQUAN' where coupno='AS002450753' and pasname='乘客8'
update Topway..tbcash set tcode='781',ticketno='2400378487',pasname='SUN/ANGUO' where coupno='AS002450753' and pasname='乘客9'
update Topway..tbcash set tcode='781',ticketno='2400378488',pasname='YE/SONG' where coupno='AS002450753' and pasname='乘客10'
update Topway..tbcash set tcode='781',ticketno='2400378489',pasname='ZHOU/RONGQIANG' where coupno='AS002450753' and pasname='乘客11'


--修改销售价信息
select owe,amount,totprice,* from Topway..tbcash 
--update Topway..tbcash set owe=owe-10,amount=amount-10,totprice=totprice-10
where coupno in ('AS002400598',
'AS002400598',
'AS002401931',
'AS002401931',
'AS002406379',
'AS002406379',
'AS002413214',
'AS002413214',
'AS002417277',
'AS002417277',
'AS002417277',
'AS002417688',
'AS002422572',
'AS002422572',
'AS002435789',
'AS002435789',
'AS002435789',
'AS002440600',
'AS002440600',
'AS002440600')

--2019年1月1日至今，会务顾问（崔之阳和张广寒）闭团的明细，包括团号、销量和利润

select Sales 会务顾问,ConventionId 会务预算单号,XsPrice 销售金额,Profit 利润,DisCountProfit 计提利润
from Topway..tbConventionCoup
where OperDate>'2019-01-01'
and Sales in('崔之阳','张广寒')
and Status<>2
order  by 会务顾问
