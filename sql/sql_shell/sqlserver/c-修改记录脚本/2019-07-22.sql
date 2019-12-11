
--1 航司出票报表   序号	出票日期	单位编号	销售单号	供应商来源	航司2字码	路线	起飞日期	舱位	票号	文件价合计	退票单号	差旅顾问
DECLARE @startdatetime VARCHAR(10)='2019-07-01'
DECLARE @enddatetime VARCHAR(10)='2019-07-30'
DECLARE @startbegdate VARCHAR(10)='2019-01-01'
DECLARE @endbegdate VARCHAR(10)='2019-10-01'
DECLARE @cmpid VARCHAR(20) ='020459'
DECLARE @inf VARCHAR(10)=0 --国际/国内
DECLARE @tickettype VARCHAR(20)='电子' --电子票/改期/升舱/其他服务

if OBJECT_ID('tempdb..#ride') is not null drop table #ride
create table #ride( 
[datetime] VARCHAR(10),
cmpid VARCHAR(20) ,
coupno VARCHAR(50),
t_source VARCHAR(50),
ride  VARCHAR(10),
[route] VARCHAR(1000),
begdate  VARCHAR(20),
nclass VARCHAR(10),
ticketno  VARCHAR(50),
totsprice decimal(18,3),
reti  VARCHAR(20),
sales VARCHAR(20),)
insert into #ride(datetime,cmpid,coupno,t_source,ride,[route],begdate,nclass,ticketno,totsprice,reti,sales)
select convert(varchar(10),datetime,120) 出票日期,cmpcode 单位编号,coupno 销售单号,t_source 供应商来源,ride 航司代码,route 路线,convert(varchar(20),begdate,120) 起飞日期,nclass 舱位,
tcode+ticketno 票号,sprice1+sprice2+sprice3+sprice4 文件价合计,reti 退票单号,sales 差旅顾问
from Topway..tbcash 
where [datetime]>=@startdatetime and [datetime]<=@enddatetime
and cmpcode=@cmpid
and begdate>=@startbegdate and begdate<=@endbegdate
and inf=@inf
and convert(varchar(4),tickettype) in (@tickettype) 

select * from #ride



--2 退票报表  序号	供应商来源	退票单号	退票审核日期	退票状态	退票费	HS应收金额	退票原因	结算状态	业务顾问	审核人

DECLARE @startedatetime VARCHAR(10)
DECLARE @endedatetime VARCHAR(10) 
DECLARE @startExamineDate VARCHAR(10) 
DECLARE @endExamineDate VARCHAR(10) 
DECLARE @status VARCHAR(10)
DECLARE @inf VARCHAR(10)
DECLARE @t_source VARCHAR(50)
DECLARE @inf2 VARCHAR(20)
DECLARE @sales VARCHAR(20)
if OBJECT_ID('tempdb..#reti') is not null drop table #reti
create table #reti (t_source,reno,)

 



--单位客户授信额度调整
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SX_TotalCreditLine='260000'
where BillNumber='020852_20190701'

--修改到账日期
select date,* from Topway..FinanceERP_ClientBankRealIncomeDetail
--update Topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-07-19'
where date='2019-07-22'and money='12234'

select date,* from Topway..FinanceERP_ClientBankRealIncomeDetail
--update Topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-07-19'
where date='2019-07-22'and money='370.66'

select date,* from Topway..FinanceERP_ClientBankRealIncomeDetail
--update Topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-07-19'
where date='2019-07-22'and money='1511.50'

select date,* from Topway..FinanceERP_ClientBankRealIncomeDetail
--update Topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-07-19'
where date='2019-07-22'and money='675'

--修改旅游收款单
select vpayinfo,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set vpayinfo='支付宝'
where TrvId='30175' and Id='228802'

--机票
select t1.RecordNumber,t5.Name from homsomDB..Trv_DomesticTicketRecord t1
left join homsomDB..Trv_PnrInfos t2 on t2.ID=t1.PnrInfoID
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t2.ItktBookingID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='审批'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.RecordNumber in 
('AS002575325',
'AS002576721',
'AS002576723',
'AS002580792',
'AS002582470',
'AS002587167',
'AS002590308',
'AS002591145',
'AS002592846',
'AS002595281',
'AS002597240',
'AS002597240',
'AS002597240',
'AS002600145',
'AS002601156',
'AS002601158',
'AS002601162',
'AS002601186',
'AS002601188',
'AS002601200',
'AS002602295',
'AS002602316',
'AS002602486',
'AS002605415',
'AS002605415',
'AS002605415',
'AS002606791',
'AS002606822',
'AS002606826',
'AS002608420',
'AS002608886',
'AS002608925',
'AS002610053',
'AS002613598',
'AS002613611',
'AS002613649',
'AS002613794',
'AS002616997',
'AS002621227',
'AS002623220',
'AS002625268',
'AS002626367',
'AS002626812',
'AS002627050',
'AS002627179',
'AS002627179',
'AS002628567',
'AS002630093',
'AS002631771',
'AS002631833',
'AS002637662',
'AS002639623',
'AS002640955',
'AS002644632',
'AS002645098',
'AS002646936',
'AS002647714',
'AS002647716',
'AS002651086',
'AS002651257',
'AS002471009')
and NodeType=110 and NodeID=111

--一级 NodeType=110 and NodeID=110
--二级 NodeType=110 and NodeID=111

--酒店
select t1.CoupNo,t5.Name from HotelOrderDB..HTL_Orders t1
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t1.OrderID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='审批'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.CoupNo in 
('PTW085718')
and NodeType=110 and NodeID=110

/*
UC020410贵酿酒业有限公司  所有人员
机票预订权限帮改为：全部舱位
还有预订类型也改为：所有预订
*/
select * from homsomDB..Trv_UPRanks where CompanyID='9C4B0B2E-9CCA-4F94-8929-A8EE00BB3B65'
select top 100 BookingType,* from homsomDB..Trv_BookingCollections where BookingType=3
select top 100 * from homsomDB..Trv_UPSettings where BookingCollectionID in(select ID from homsomDB..Trv_BookingCollections where BookingType=3)
select top 100 * from homsomDB..Trv_UPCollections_UnitPersons

--机票预订权限 全舱
--select * from homsomDB..Trv_UPRanks where CompanyID='9C4B0B2E-9CCA-4F94-8929-A8EE00BB3B65'

select UPRankID,UPSettingID,* from homsomDB..Trv_UnitPersons
--update homsomDB..Trv_UnitPersons set UPRankID='CFF6241A-BC14-422F-A011-AA0700FEA2E2'
where ID in(Select ID from homsomDB..Trv_Human
where IsDisplay=1
) and CompanyID=(Select ID from homsomDB..Trv_UnitCompanies
where Cmpid='020410')

--预订类型 所有人预订
select BookingType,* from homsomDB..Trv_BookingCollections
--update homsomDB..Trv_BookingCollections set BookingType=3
where ID in(Select BookingCollectionID from homsomDB..Trv_UPSettings
where ID in(Select UPSettingID from homsomDB..Trv_UnitPersons
where CompanyID='9C4B0B2E-9CCA-4F94-8929-A8EE00BB3B65'))

--UC020932删除员工
select * from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (Select ID from homsomDB..Trv_UnitPersons
where CompanyID=(Select  ID from homsomDB..Trv_UnitCompanies 
where Cmpid='020932')) and IsDisplay=1
and Name not in('张芸','李丽娜')

select * from Topway..tbCusholderM
--update Topway..tbCusholderM set EmployeeStatus=0
where cmpid='020932' and custname not in('张芸','李丽娜')

--促销费重新提交
 select dsettleno,sdisct,* from Topway..tbcash 
 --update Topway..tbcash  set sdisct=0
 where dsettleno='56720'
 
 
--常旅客名单 A LIST"移远名单"请提供2018年1月1日-2019年7月19日出过国内机票的常旅客名单
select distinct cmpcode,pasname,idno 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-07-20'
and inf=0
and reti=''
and cmpcode in('016307',
'018176',
'018814',
'019939',
'019121',
'020758',
'018930',
'018766',
'018303',
'020651',
'018199',
'020161',
'019475',
'020263',
'017200',
'017449',
'020351',
'020784',
'019110',
'020701',
'018671',
'020338',
'018134',
'020727',
'018420',
'020602',
'020215',
'019658',
'020180',
'020095',
'020094',
'017480',
'020119',
'020087',
'019634',
'016348',
'020253',
'020695',
'016961',
'020235',
'019363',
'017939',
'020069',
'019764',
'016719',
'016310',
'017519',
'020771',
'020349',
'019827',
'018945',
'020476',
'018385',
'020234',
'018731',
'019640',
'019882',
'020387',
'017873',
'020486',
'019961',
'020729',
'016504',
'019656',
'020734',
'019484',
'019006',
'020155',
'016936',
'020157',
'019348',
'016492',
'019780',
'019638',
'018940',
'020679',
'018345',
'020462',
'020690',
'020148',
'018522',
'019021',
'020641',
'018341',
'018094',
'017223',
'018822',
'017930',
'017932',
'017776',
'020147',
'020384',
'020812',
'020243',
'018981',
'013184',
'018868',
'020763',
'017886',
'019919',
'020709',
'018259',
'020072',
'002045',
'020466',
'016239',
'020626',
'018929',
'017007',
'017921',
'020603',
'019670',
'016890',
'019901',
'017326',
'020132',
'019953',
'020228',
'020675',
'020684',
'019998',
'017146',
'020733',
'016294',
'020191',
'016635',
'019794',
'017559',
'020718',
'018281',
'018061',
'020536',
'020761',
'020820',
'020799',
'020293',
'020142',
'019842',
'017919',
'018925',
'019227',
'019347',
'019403',
'019609',
'019951',
'020033',
'020510',
'020801',
'019863',
'017655',
'017916',
'020341',
'017954',
'020419',
'019455',
'019817',
'016848',
'017543',
'016061',
'020674',
'018926')
order by cmpcode


--匹配单位名称并提供常旅客名单
select Cmpid,Name from homsomDB..Trv_UnitCompanies
where Cmpid in('016586',
'020834',
'020841',
'020844',
'020880',
'020901',
'020832',
'020835',
'020851',
'020857',
'020859',
'020862',
'020872',
'020876',
'020878',
'020882',
'020893',
'020894',
'020895',
'020897',
'020909',
'020911',
'020915',
'020068',
'020925',
'020829',
'020846',
'019707',
'020852',
'020866',
'020884',
'020885',
'020928',
'020931',
'020932',
'020833',
'020875',
'020910',
'020919')

select Cmpid UC号,h.Name 中文姓名,LastName+'/'+FirstName+MiddleName 英文姓名,CredentialNo 证件号
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.id=h.ID
left join homsomDB..Trv_Credentials cr on cr.HumanID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where IsDisplay=1
and  Cmpid in('016586',
'020834',
'020841',
'020844',
'020880',
'020901',
'020832',
'020835',
'020851',
'020857',
'020859',
'020862',
'020872',
'020876',
'020878',
'020882',
'020893',
'020894',
'020895',
'020897',
'020909',
'020911',
'020915',
'020068',
'020925',
'020829',
'020846',
'019707',
'020852',
'020866',
'020884',
'020885',
'020928',
'020931',
'020932',
'020833',
'020875',
'020910',
'020919')
order by Cmpid

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002651003','AS002648301','AS002649462','AS002651403')

--酒店调整单
select price,totprofit,yhprice,yjprice,sprice,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set price='-7786',totprofit='-2952'
where CoupNo='PTW087652'

select  totprice,owe,* from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set totprice='-7786',owe='-7786'
where coupid=(select id from Topway..tbHtlcoupYf 
where CoupNo='PTW087652')

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='北京好巧国际旅行社有限公司'
where CoupNo='PTW086849'

--申请费报表 序号	申请费来源	出票日期	销售单号	申请费	退票日期	退票单号	扣申请费	HS应收申请费	销售利润	差旅顾问
declare @startdatetime varchar(10)
declare @enddatetime varchar(10)
declare @startdatetime varchar(10)
declare @startdatetime varchar(10)
declare @startdatetime varchar(10)
declare @startdatetime varchar(10)
declare @startdatetime varchar(10)

select feiyonginfo 申请费来源,t.datetime 出票日期,t.coupno 销售单号,t.feiyong 申请费,ExamineDate 退票日期,reno 退票单号,t.sfeiyong 扣申请费,
t.feiyong-t.sfeiyong HS应收申请费,t.profit 销售利润,sales 差旅顾问
from Topway..tbReti t
left join Topway..tbcash c on c.reti=t.reno
where reno='9267694'
where t.datetime>=''
and t.datetime<=''
and ExamineDate>=''
and ExamineDate<=''
and t.inf=''
and feiyonginfo in()
and CONVERT(varchar(4),tickettype) in()


select reno,* from Topway..tbReti
where ExamineDate>='2019-07-01'
and sfeiyong>0


--匹配订单号
select RecordNumber,t.TravelID from  homsomDB..Trv_DomesticTicketRecord d
LEFT JOIN homsomDB..Trv_PnrInfos p ON d.PnrInfoID=p.ID
LEFT JOIN homsomDB..Trv_ItktBookings i ON p.ItktBookingID=i.ID
LEFT JOIN homsomDB..Trv_Travels t ON i.TravelID=t.ID
where RecordNumber in ('AS002454235',
'AS002537500',
'AS002444775',
'AS002454237',
'AS002237869',
'AS002164933',
'AS002560404',
'AS002347101',
'AS002472079',
'AS002562702',
'AS002556527',
'AS002344125',
'AS002248875',
'AS002176461',
'AS002245300',
'AS002248879',
'AS002560408',
'AS002290641',
'AS002164935',
'AS002176494',
'AS002412358',
'AS002061197',
'AS001871606',
'AS002324188',
'AS002037020',
'AS002472081',
'AS002344127',
'AS002459908',
'AS002176492',
'AS002356879',
'AS002561327',
'AS002237920')
