--泰思肯贸易乘机人数据
 select begdate as 出发时间,coupno as 销售单号,pasname as 乘机人,route as 行程,SUM(totprice) as '销量(含税)' from Topway..tbcash where datetime>='2018-01-01' and datetime<'2019-01-01' and cmpcode='018821' and reti='' 
 group by pasname,coupno,route,begdate
 order by begdate
 
 --单位类型、结算方式、账单开始日期、新增月、注册月
select PstartDate,* from Topway..HM_CompanyAccountInfo 
 --update Topway..HM_CompanyAccountInfo set PstartDate='2019-01-21'
 where CmpId='020273' and Id='6824'
  select PendDate,Status,* from Topway..HM_CompanyAccountInfo 
 --update Topway..HM_CompanyAccountInfo set PendDate='2019-01-20 23:59:59.000',Status='-1'
 where CmpId='020273' and Id='6476'
 --y账
 select SettlementPeriodAir,AccountPeriodAir2,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SettlementPeriodAir='2019-01-01~2019-01-20',AccountPeriodAir2='2019-01-20'
where CompanyCode='020273' and BillNumber='020273_20190101'
 
 select SStartDate,* from Topway..HM_SetCompanySettleMentManner 
 --update Topway..HM_SetCompanySettleMentManner set SStartDate='2019-01-21',Status='1'
 where CmpId='020273' and Status='2'
 select SEndDate,* from Topway..HM_SetCompanySettleMentManner 
 --update Topway..HM_SetCompanySettleMentManner set SEndDate='2019-01-20',Status='-1'
 where CmpId='020273' and Status='1'
 
 SELECT StartDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
 --update homsomdb..Trv_UCSettleMentTypes set StartDate='2019-01-21',Status='1'
 WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '020273') and Status='2'
  SELECT EndDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
 --update homsomdb..Trv_UCSettleMentTypes set EndDate='2019-01-20 23:59:59.000',Status='-1'
 WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '020273') and Status='1'
 select * from Topway..AccountStatement where BillNumber like'%020273_2019%'
 --2019-01-21添加的常飞旅客
 SELECT 
ISNULL(c.Cmpid,'') AS 单位编号,
ISNULL(c.Name,'') AS 单位名称,
ISNULL(h.Name,'') AS 中文名,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS 英文名,
h.Mobile AS 手机号码,
ISNULL((SELECT TOP 1 empname FROM Topway..Emppwd WHERE idnumber=h.CreateBy),'') AS 差旅顾问,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS 运营经理
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate>='2019-01-21' AND h.CreateDate<'2019-01-22' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT idnumber FROM Topway..Emppwd WHERE dep='运营部' AND idnumber NOT IN('00002','00003','0421'))
UNION ALL

SELECT 
ISNULL(c.Cmpid,'') AS 单位编号,
ISNULL(c.Name,'') AS 单位名称,
ISNULL(h.Name,'') AS 中文名,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS 英文名,
ISNULL(h.Mobile,'') AS 手机号码,
h.CreateBy AS 差旅顾问,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS 运营经理
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate>='2019-01-21' AND h.CreateDate<'2019-01-22' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT empname FROM Topway..Emppwd WHERE dep='运营部' AND empname NOT IN('homsom','恒顺旅行','运营培训测试'))

--融宝出票数据12家20190122
select cmpcode as 单位编号,'' as 单位名称,datetime as 出票日期,coupno as 销售单号,tickettype as 类型,ride+flightno as 航班号,begdate as 起飞时间,tcode+ticketno as 票号,
pasname as 乘机人,route as 行程,totprice as 销售价 from Topway..tbcash 
where cmpcode in('019799','001787','018042','019448','019465','016362','019788','019450','019778','019798','019808','018615')
and datetime>='2018-07-01' and datetime<'2019-01-01'
order by datetime

--（产品部专用）机票供应商来源（国内)

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002209008'
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS易商笕尚D'
where coupno='AS002200955'
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002208829'
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETI'
where coupno='AS002212642'
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS易商林肯D'
where coupno='AS002202962'
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS易商伊藤忠'
where coupno='AS002200937'
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS易商中银基金D'
where coupno='AS002201040'

--酒店销售单供应商来源
SELECT profitsource,* FROM Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='深圳市道旅旅游科技股份有限公司'
where CoupNo='PTW075140'

--丰树火车票数据
select DISTINCT OutBegdate AS 日期,Name as 乘客姓名,OutStroke as 行程,t.OutGrade as 座位,TrainWebNo as 订单号,u.RealPrice as 车票价格,u.Fuprice as 服务费,u.PrintPrice as 打印费,ISNULL(r.Fee,0) as 退票费,
TotUnitprice as 全价,u.RealPrice/TotUnitprice as 折扣率--,t1.CostCenter as 成本中心
FROM Topway..tbTrainTicketInfo t
LEFT JOIN Topway..tbTrainUser u ON t.ID=u.TrainTicketNo
LEFT JOIN Topway..Train_ReturnTicket r ON u.ID=r.TickOrderDetailID
--left join Topway..tbcash t1 on t1.idno=u.Idno
where CmpId='019358' and OutBegdate>='2018-01-01' and OutBegdate<'2019-01-01' --AND t.ID='10848'
--and t1.CostCenter is not null and t1.CostCenter <>'undefined'
order by TrainWebNo


 --上海丰树2018数据
 
 select  t2.rtprice as 退票费,tickettype,
 '' as 签证费,'' as 火车票费用 ,t.coupno from Topway..tbcash t
 left join ehomsom..tbInfAirCompany t1 on t1.code2=t.ride
 left join Topway..tbReti t2 on t2.reno=t.reti
 where t.datetime>='2018-01-01' and t.datetime<'2019-01-01' and t.cmpcode='019358' and t.priceinfo>'0' 
 order by tickettype
 
 --签证费
  select  YujPrice as  签证费 from Topway..tbTravelBudget where TrvCpName like'%签证%'
  and Cmpid='019358' and StartDate>='2018-01-01' and EndDate<'2019-01-01'

--改期费（升舱）
select v.coupno as 销售单号,v.pasname as 乘客姓名,

 v.totprice as 改期费,v.tickettype,
 '' as 签证费,'' as 火车票费用
from Topway..tbcash v
left join ehomsom..tbInfAirCompany t1 on t1.code2=v.ride
  left join Topway..tbReti t3 on t3.reno=v.reti
where (v.route like'%改期%' or v.tickettype like'%改期%') and v.cmpcode='019358' and v.datetime >='2018-01-01' and v.datetime<'2019-01-01' 


--UC018134酒店数据
select datetime as 预定时间,pasname as 客人姓名,hotel as 酒店名称,beg_date as 入住时间,end_date as 离店时间,roomtype as 房型,nights as 入住天数,pcs as 间数,price as 销售总价

from Topway..tbHtlcoupYf where datetime>='2018-01-01' and datetime<'2019-01-01' and cmpid='018134'

--单位客户授信额度调整
SELECT SX_BaseCreditLine,SX_TomporaryCreditLine, SX_TotalCreditLine,*
FROM Topway..AccountStatement
--update Topway..AccountStatement set SX_TotalCreditLine=210000
WHERE     (CompanyCode = '019792') AND (BillNumber = '019792_20190101')

select sum(sprice),cmpid from Topway..tbHtlcoupYf where cmpid='019792' and datetime>='2019-01-01'  
group by cmpid

select sum(totprice) from Topway..tbcash where cmpcode='019792' and datetime>='2019-01-01' 
group by cmpcode


--UC020530 服务费明细
select coupno as 销售单号,datetime as 出票时间,begdate as 起飞时间,tcode+ticketno as 票号,route as 行程,pasname as 乘客姓名,fuprice as 服务费,ride+flightno as 航班号,totprice as 销售价,reti
from Topway..tbcash 
where cmpcode='020530' --and fuprice>'0' 
order by datetime

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where BillNumber='019791_20181121'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='蒋燕华',SpareTC='蒋燕华'
where coupno='AS001411048'