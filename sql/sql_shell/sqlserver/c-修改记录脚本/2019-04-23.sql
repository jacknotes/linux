/*
康宝莱现在还要一个数据：
东航2018.7--12月 其中使用大客户协议张数占比    %，共计节约      元
最后两个问题：张数占比    %，共计节约      元
*/
drop table #ccc
select RebateStr,SUM(price) 销量,COUNT(c.id) 张数 ,sum(convert(decimal(8,2),originalprice)) 原销量
into #ccc
from Topway..tbcash C
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos pn on pn.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ItktBookingID=pn.ItktBookingID and c.ride+C.flightno=it.Flight
--LEFT JOIN homsomDB..Trv_ItktBookingSegments_PnrInfos p ON p.ItktBookingSegID=it.ID
where
-- datetime>='2018-07-01'
--and datetime<'2019-01-01'
(ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and ride in ('MU','FM')
and cmpcode='020459'
and inf=0
and tickettype not in ('改期费', '升舱费','改期升舱')
group by RebateStr

select sum(销量) 总销量,SUM(张数) 总张数,SUM(原销量)折扣前总销量  from #ccc

--大客户协议

select SUM(销量) 合计,SUM(张数) 张数,SUM(原销量) 折扣前销量,(100-Discount)/100 折扣 from #ccc ccc
inner join homsomDB..Trv_FlightTripartitePolicies f on f.ID=ccc.RebateStr
group by Discount

--UC016485莱特波特（上海）电子技术有限公司2018年1月1日--12月31日的数据里程
--飞行时间
select c.tcode+c.ticketno,datediff(MINUTE, it.Departing,it.Arriving) from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos pn on pn.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ItktBookingID=pn.ItktBookingID
where cmpcode='016485'
and (datetime>='2018-01-01' and datetime<'2019-01-01')
and inf=0
and reti=''
and tickettype='电子票'



IF OBJECT_ID('tempdb.dbo.#mileage') IS NOT NULL DROP TABLE #mileage
select DISTINCT rtrim(cityfrom)+'-'+rtrim(cityto) route,mileage,kilometres 
into #mileage
from tbmileage

IF OBJECT_ID('tempdb.dbo.#tbcash1') IS NOT NULL DROP TABLE #tbcash1
select pasname 乘机人,tcode+ticketno 票号,coupno as 销售单号,ride+flightno as 航班号,datetime as 出票日期
,case SUBSTRING(route,1,CHARINDEX('-',route)-1) when '上海浦东' then '上海' when '上海虹桥' then '上海' when '北京首都' then '北京' when '北京南苑' then '北京' when '西安咸阳' then '西安' 
when '遵义新舟' then '遵义' when '揭阳' then '汕头' when '武汉天河' then '武汉' when '景洪' then '西双版纳' when '乌兰察布集宁' then '乌兰察布' when '德宏' then '芒市' when '思茅' then '普洱' when '梅县' then '梅州'
else SUBSTRING(route,1,CHARINDEX('-',route)-1) end as 出发
,case REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) when '上海浦东' then '上海' when '上海虹桥' then '上海' when '北京首都' then '北京' when '北京南苑' then '北京' when '西安咸阳' then '西安' 
when '遵义新舟' then '遵义' when '揭阳' then '汕头' when '武汉天河' then '武汉' when '景洪' then '西双版纳' when '乌兰察布集宁' then '乌兰察布' when '德宏' then '芒市' when '思茅' then '普洱' when '梅县' then '梅州'
else  REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) end as 到达
,route as 行程
,t_source as 供应商来源
into #tbcash1
from tbcash c
where cmpcode='016485'
and (datetime>='2018-01-01' and datetime<'2019-01-01')
and inf=0
and route like ('%-%')
and reti=''
and tickettype='电子票'
order by datetime

select * from #tbcash1

IF OBJECT_ID('tempdb.dbo.#tbcash') IS NOT NULL DROP TABLE #tbcash
select *,出发+'-'+到达 as route2,到达+'-'+出发 as route3
into #tbcash
from #tbcash1

--select * from #tbcash
IF OBJECT_ID('tempdb.dbo.#tt') IS NOT NULL DROP TABLE #tt
select 乘机人,航班号,票号,销售单号,tbcash.行程,出票日期,mileage,kilometres
into #tt
from #tbcash tbcash
left join #mileage mileage on mileage.route=tbcash.route2 or mileage.route=tbcash.route3

select * from #tt
where kilometres is null



--select * from tbmileage where cityfrom='普洱' or cityto='普洱'
--select * from tbmileage where cityfrom='普洱' and cityto='昆明'

--退改
select coupno as 销售单号,route as 行程,begdate as 起飞日期 from Topway..tbcash 
where cmpcode='019392' 
and (datetime>='2018-01-01' and datetime<'2019-01-01') 
and inf=1 
and (tickettype like ('%改期%') or t_source like ('%改期%') or route like ('%改期%')or reti<>'')

--国际出票信息
select coupno as 销售单号,pasname 乘机人,tcode+ticketno 票号,ride+flightno 航班,REPLACE(route,'-','') 行程
into #test
from Topway..tbcash 
where cmpcode='016485' 
and (datetime>='2018-01-01' and datetime<'2019-01-01') 
and reti=''
and tickettype not in ('改期费', '升舱费','改期升舱')
and route not like'%改期%'
and route not like'%升舱%'
and route not like'%退票%'
and inf=1 

--拆分行程
select 销售单号,乘机人,票号,航班,SUBSTRING(行程,1,3)行程1, SUBSTRING(行程,4,3)行程2, SUBSTRING(行程,7,3)行程3, SUBSTRING(行程,10,3)行程4
into #test1
from #test 

--行程1
select * 
into #xc1
from #test1 test
inner join Topway..tbmileage t on (t.CityFromCode=行程1 and t.CityToCode=行程2)

--行程2
select * 
into #xc2
from #test1 test
inner join Topway..tbmileage t on (t.CityFromCode=行程2 and t.CityToCode=行程3)

--行程3
select * 
into #xc3
from #test1 test
inner join Topway..tbmileage t on (t.CityFromCode=行程3 and t.CityToCode=行程4)

--汇总
select xc1.乘机人,xc1.航班,xc1.票号,xc1.mileage+isnull(xc2.mileage,0)+isnull(xc3.mileage,0) 英里,
xc1.kilometres+isnull(xc2.kilometres,0)+isnull(xc3.kilometres,0)公里  from #xc1 xc1
left join #xc2 xc2 on xc2.销售单号=xc1.销售单号 and xc2.票号=xc1.票号 and xc2.乘机人=xc1.乘机人
left join #xc3 xc3 on xc3.销售单号=xc1.销售单号 and xc3.票号=xc1.票号 and xc3.乘机人=xc1.乘机人
order by 英里

select Kilometres,* from Topway..tbmileage

AS001354232 PVG-SFO-PVG
--重开打印
select PrintDate,Pstatus,* from Topway..HM_tbReti_tbReFundPayMent 
--update Topway..HM_tbReti_tbReFundPayMent set PrintDate='1900-01-01',Pstatus=0
where Id='703732'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='020334_20190301'

select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='020209_20190301'

--酒店销售单作废
select status,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set status=-2
where CoupNo='-PTW077430'

select * 
--delete
from Topway..tbHtlcoupYf 
where CoupNo='-PTW077430'

select * 
--delete
from Topway..tbhtlyfchargeoff 
where coupid in(select id from Topway..tbHtlcoupYf where CoupNo='-PTW077430')


/*
UC016655 出票日期2019年4月1号至2019年4月18号，国内机票中特殊票价是无的销售单号请拉出来，具体数据如下：
 
出票日期， 电子销售单号 销售单类型 供应商来源 PNR 票号  乘客姓名 航程  舱位  销售单价 税收 销售利润 销售价 服务费

*/
select indate,coupno,tickettype,t_source,recno,tcode+ticketno,pasname,
route,nclass,price,tax,profit,totprice,fuprice
 from Topway..tbcash 
where cmpcode='016655'
and datetime>='2019-04-01'
and datetime<'2019-04-19'
and baoxiaopz=0 --特殊票价无
and inf=0
order by indate

SELECT * from ApproveBase..App_Content where BaseAppNo='WF0096' and EnItem='Reason' order by TransDatetime desc



select IsJoinRank,* from Topway..Emppwd 
--update Topway..Emppwd set IsJoinRank=1
where idnumber in ('0700','0720')

--机票
SELECT t1.RecordNumber,t5.Name 
FROM homsomDB..Trv_DomesticTicketRecord t1
left join homsomDB..Trv_PnrInfos t2 on t2.ID=t1.PnrInfoID
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t2.ItktBookingID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='审批'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.RecordNumber in 
('AS002339178',
'AS002342885',
'AS002343589',
'AS002347417',
'AS002347421',
'AS002349739',
'AS002356941',
'AS002358664',
'AS002359707',
'AS002359923',
'AS002360585',
'AS002361267',
'AS002361404',
'AS002361432',
'AS002361459',
'AS002361461',
'AS002361463',
'AS002361465',
'AS002361481',
'AS002361529',
'AS002361549',
'AS002363713',
'AS002364829',
'AS002364843',
'AS002365393',
'AS002365754',
'AS002368287',
'AS002368289',
'AS002368291',
'AS002368483',
'AS002368491',
'AS002368509',
'AS002369653',
'AS002370852',
'AS002371493',
'AS002374385',
'AS002374392',
'AS002374406',
'AS002374406',
'AS002374406',
'AS002376191',
'AS002376800',
'AS002379149',
'AS002379157',
'AS002379159',
'AS002381115',
'AS002381291',
'AS002382499',
'AS002382499',
'AS002383218',
'AS002383228',
'AS002384362',
'AS002384850',
'AS002385105',
'AS002385127',
'AS002385348',
'AS002385354',
'AS002388677',
'AS002388677',
'AS002390485',
'AS002390564',
'AS002390597',
'AS002390701',
'AS002390869',
'AS002391628',
'AS002394004',
'AS002394004',
'AS002394191',
'AS002394191',
'AS002401917',
'AS002401925',
'AS002405029',
'AS002405105',
'AS002405256',
'AS002407127',
'AS002407144',
'AS002408076',
'AS002408079',
'AS002408259',
'AS002408417',
'AS002408704',
'AS002410475',
'AS002411702',
'AS002412018',
'AS002412188',
'AS002412241',
'AS002412282',
'AS002412726',
'AS002413504',
'AS002413506',
'AS002414027',
'AS002414304',
'AS002414494',
'AS002414604',
'AS002414618',
'AS002414744',
'AS002415292') 
and NodeType=110 and NodeID=111

--一级 NodeType=110 and NodeID=110
--二级 NodeType=110 and NodeID=111

--酒店
SELECT CoupNo,t5.Name FROM HotelOrderDB..HTL_Orders t1
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t1.OrderID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='审批'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.CoupNo in 
( 'PTW079377') and NodeType=110 and NodeID=110

--UC号修改（旅游）
select * from Topway..tbTravelBudget
--update Topway..tbTravelBudget set custid='D663853',cmpid='020796',Custinfo='13917626481@张静静@020796@上海乐响网络科技发展有限公司@13917626481@张静静' 
where trvid='29900'

/*
三井住友UC018734 麦克米伦UC018080  基汇管理UC018897 极乐汤UC020640 常州欧亚UC020571   德纳管理UC020750
3月、2月的火车票利润
是否可以体现火车票张数
*/
drop table #sss
select CmpId UC,convert(varchar(6),OutBegdate,112) 月份,SUM(TotPrice) 销量,SUM(TotFuprice) 利润,COUNT(ID) 张数 
into #sss
from Topway..tbTrainTicketInfo 
where 
--CmpId in('018734','018080','018897','020640','020571','020750')
OriginalBillNumber in ('018734_20190101','018734_20190201','018734_20190301','018734_20190401',
'018080_20190101','018080_20190201','018080_20190301','018080_20190401','018897_20190101',
'018897_20190201','018897_20190301','018897_20190401','020640_20190101','020640_20190201','020640_20190301',
'020640_20190401','020571_20190126','020571_20190226','020571_20190326','020571_20181226','020750_20190401','020750_20190301')
and OutBegdate>='2019-01-01'
--and OutBegdate<'2019-04-01'
group by convert(varchar(6),OutBegdate,112),CmpId
order BY 月份

select 月份,SUM(利润) 利润,SUM(销量) 销量 from #sss
group by 月份

('018734','018080','018897','020640','020571','020750') 
select * from Topway..AccountStatement where CompanyCode='020750' order by BillNumber desc

--打印权限
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus=0,PrDate='1900-01-01'
where TrvId='29905' and Id='227756'

--机场数据更新
select * from homsomDB..Trv_Airport
--update homsomDB..Trv_Airport set AbbreviationName=Name

select * from homsomDB..Trv_Cities where CountryType=2
--update homsomDB..Trv_Cities set AbbreviatedName=Name where CountryType=2


--退票状态
select Status,* from Topway..HM_tbReti_tbReFundPayMent 
--update Topway..HM_tbReti_tbReFundPayMent  set Status=4
where Id='703736'

--匹配销售单价
select coupno,price from Topway..tbcash 
where coupno in ('AS002362969',
'AS002362973',
'AS002368269',
'AS002371350',
'AS002387611',
'AS002387885',
'AS002388068',
'AS002388115',
'AS002388297',
'AS002389079',
'AS002389085',
'AS002397246',
'AS002399972',
'AS002407822',
'AS002413129',
'AS002413218',
'AS002413393',
'AS002415191',
'AS002419579',
'AS002421329')


select * from homsomDB..Trv_Cities where Code in ('BGG','GNI','JNS','AAD','SIC','KEW','KCK','NAH','ETE','BEM','CAT')
select * from homsomDB..Trv_Cities where ID='20945477-B8A5-424D-A369-04FC728025BB'
select * from homsomDB..Trv_Airport where Code='GNI'

select a.Code 机场码,c.Code 城市码,a.Name 机场名,c.Name 城市名,a.EnglishName 机场名,c.EnglishName 城市名,
a.AbbreviationName 机场简称,c.AbbreviatedName  城市简称
from homsomDB..Trv_Airport a
left join homsomDB..Trv_Cities c on c.ID=a.CityID


