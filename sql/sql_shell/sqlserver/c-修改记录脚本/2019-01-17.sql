--账单撤销
SELECT SubmitState,* FROM topway..AccountStatement 
--update topway..AccountStatement set SubmitState='1'
WHERE (CompanyCode = '018735') and BillNumber='018735_20181101'

--申请删除供应商结算信息中“保险新卫士”一条
select * from Topway..tbConventionBudget where ConventionId='1009'
--delete  Topway..tbConventionJS where ConventionId='1009' and Id='12463'

--旅游收款单信息
select Skstatus,* from  topway..tbTrvKhSk 
--update topway..tbTrvKhSk set Skstatus='2'
where TrvId='029447' and Id='226757'

--（产品部专用）修改退票状态（国内）
select opername,operDep,* from Topway..tbReti 
--update Topway..tbreti ,operDep=''
where reno in ('0425863','0425860','0425372','0425373','0422076','0422077')

--已经审核
select status2,* from Topway..tbreti 
--update Topway..tbreti set status2='2'
where reno in ('0425863','0425860')

--单位类型、结算方式、账单开始日期、新增月、注册月
select * from Topway..AccountStatement where CompanyCode='017134' order by BillNumber desc
SELECT * FROM homsomdb..Trv_UCSettleMentTypes WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '017134') order by StartDate desc 
--erp
select Status,SEndDate,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set Status='-1',SEndDate='2018-12-31'
where CmpId='017134' and Status='1'
select Status,SStartDate,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set Status='1',SStartDate='2019-01-01'
where CmpId='017134' and Status='2'
--tms
SELECT * FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set EndDate='2018-12-31',Status='-1'
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '017134') and EndDate='2019-01-31 23:59:59.000'
SELECT * FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set StartDate='2019-01-01',Status='1'
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '017134') and StartDate='2019-02-01 00:00:00.000'

--公里数
SELECT c.cmpcode AS 单位编号,c.coupno AS 销售单号,s.Origin+s.Destination AS 城市对,ISNULL(g.Kilometres,0) AS 公里数,c.datetime AS 出票日期 FROM tbcash c 
LEFT JOIN homsomDB..Trv_DomesticTicketRecord r ON c.coupno=r.RecordNumber
LEFT JOIN homsomDB..Trv_PnrInfos p ON r.PnrInfoID=p.ID
LEFT JOIN homsomDB..Trv_ItktBookingSegments_PnrInfos t ON p.ID=t.PnrInfoID
LEFT JOIN homsomDB..Trv_ItktBookingSegs s ON t.ItktBookingSegID=s.ID
LEFT JOIN Topway..tbmileage g ON s.Origin=g.CityFromCode AND s.Destination=g.CityToCode
WHERE 
cmpcode='018080' AND datetime BETWEEN '2018-01-01' AND '2018-12-31' AND inf=0 AND coupno<>'as000000000' 
AND c.tickettype='电子票' AND c.reti=''
--AND coupno='AS002089273'
ORDER BY c.datetime desc

--重开打印权限
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus='0',PrDate='1900-01-01'
where TrvId='029447' and Id='226802'

--重开打印权限
select PrintDate,Pstatus,* from topway..HM_tbReti_tbReFundPayMent
--update topway..HM_tbReti_tbReFundPayMent set PrintDate='1900-01-01',Pstatus='0'
 WHERE     (Id IN ('703619', '703620'))
 --重开打印权限
 select pstatus,prdate,* from Topway..tbDisctCommission 
 --update Topway..tbDisctCommission set pstatus='0',prdate='1900-01-01'
 where id='56129'
 
 --预定人员名单
 select uc.Name, h.name,LastName+'/'+firstname+' '+MiddleName as ename,cr.Type,cr.CredentialNo
from homsomdb..Trv_UnitPersons up
left join homsomdb..Trv_Human h on h.ID=up.ID
left join homsomdb..Trv_Credentials cr on cr.HumanID=h.ID
left join homsomdb..Trv_UnitCompanies uc on uc.ID=up.CompanyID
where uc.CooperativeStatus in('1','2','3')
and uc.Cmpid in ('019234')
  and IsDisplay=1 

SELECT h.Name,h.Mobile FROM homsomDB..Trv_UPCollections_UnitPersons  up
left join homsomDB..Trv_Human h on h.ID=up.UnitPersonID
WHERE UPCollectionID='AA53871E-1086-4E90-954A-CFDF436FDF73' and h.IsDisplay='1'

SELECT *FROM homsomDB..Trv_UPCollections_UnitPersons 
WHERE UPCollectionID='AA53871E-1086-4E90-954A-CFDF436FDF73' 

--差额调整
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='3320',profit='251'
where coupno='AS002210569'
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='13074',profit='2056'
where coupno='AS002209299'
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='4883',profit='447'
where coupno='AS002211180'

--（产品部专用）修改退票状态（国际）
select opername,operDep,* from Topway..tbReti 
--update Topway..tbReti set opername='何燕萍'operDep=''
where reno in ('9265718','9265294','9265295','9265289','9265290','9265646')

--退款付款状态修改
select dzhxDate,status2,* from topway..tbReti 
--update topway..tbReti set dzhxDate='1900-01-01',status2='6'
where reno in ('0426098','0426100')

--账单撤销
select TrainBillStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement set TrainBillStatus='1'
where CompanyCode='019822' and BillNumber='019822_20181201'

---酒店数据表格预付
select  convert(varchar(6),prdate,112) as 月份,hotel as 酒店名称,CityName as 城市,sum(yf.nights*pcs) as 月总间夜数,sum(price) as 月总金额 
from tbHtlcoupYf yf
inner join HotelOrderDB..HTL_Orders od on od.CoupNo=yf.CoupNo
inner join HotelOrderDB..HTL_OrderHotels oh on oh.OrderID=od.OrderID
inner join Emppwd d on d.empname=opername1
where prdate>='2018-01-01' and prdate<'2019-01-01'
and yf.status<>'-2'
group by convert(varchar(6),prdate,112),hotel,CityName
Order by convert(varchar(6),prdate,112)

--酒店数据表格自付
select convert(varchar(6),datetime,112) as 月份,hotel as 酒店名称,CityName as 城市,sum(coup.nights*pcs) as 月总间夜数,sum(price) as 月总金额 
from tbHotelcoup coup
inner join HotelOrderDB..HTL_Orders od on od.CoupNo=coup.CoupNo
inner join HotelOrderDB..HTL_OrderHotels oh on oh.OrderID=od.OrderID
inner join Emppwd d on d.empname=opername1
where datetime>='2018-01-01' and datetime<'2019-01-01'
and coup.status<>'-2'
group by convert(varchar(6),datetime,112),hotel,CityName
Order by convert(varchar(6),datetime,112)

--修改退票审核日期
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti set ExamineDate='2019-01-14 15:24:57.030'
where reno='0425860'

--到账删除
delete topway..FinanceERP_ClientBankRealIncomeDetail where money='54417.81' and id='1A78199F-8EF5-4644-9B9D-5DB26AC83F79'
 
--单位类型、结算方式、账单开始日期、新增月、注册月
select * from Topway..AccountStatement where CompanyCode='020643' order by BillNumber desc
SELECT * FROM homsomdb..Trv_UCSettleMentTypes WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '020643') order by StartDate desc 
--最新结算账期
select PstartDate,* from topway..HM_CompanyAccountInfo 
--update topway..HM_CompanyAccountInfo set PstartDate='2019-01-21 00:00:00.000'
where CmpId='020643' and Id='6820'
select PendDate,* from topway..HM_CompanyAccountInfo 
--update topway..HM_CompanyAccountInfo set PendDate='2019-01-20 23:59:59.000'
where CmpId='020643' and Id='6758'
select SettlementPeriodAir,AccountPeriodAir2,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SettlementPeriodAir='2019-01-01~2019-01-20',AccountPeriodAir2='2019-01-20'
where CompanyCode='020643' and BillNumber='020643_20190101'

--酒店销售单供应商来源

select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='深圳市道旅旅游科技股份有限公司'
where CoupNo='PTW075060'

--促销积点

select disct,bpprice,* from Topway..tbcash where coupno='AS002143887'
select Top 10* from Topway..tbDisctCommission 

--月均销量、月均利润
--后备顾问APPLE
select cmpcode as 单位编号,SUM(totprice) as 销量,SUM(profit) as 利润 from Topway..tbcash 
where cmpcode in ('020295','020441','020262','020439','016883','020640') 
and datetime>='2018-10-01' and datetime<'2019-01-01' and reti=''
group by cmpcode
--后备顾问练菲菲
select cmpcode as 单位编号,SUM(totprice) as 销量,SUM(profit) as 利润 from Topway..tbcash 
where cmpcode in ('020566  ','020514','020461','020532','020567','020614') 
and datetime>='2018-10-01' and datetime<'2019-01-01' and reti=''
group by cmpcode
--后备顾问TETE
select cmpcode as 单位编号,SUM(totprice) as 销量,SUM(profit) as 利润 from Topway..tbcash 
where cmpcode in ('018482','020552','020560','020561','020565','020432','020656','020699') 
and datetime>='2018-10-01' and datetime<'2019-01-01' and reti=''
group by cmpcode

select cmpcode as 单位编号,SUM(totprice) as 销量,SUM(profit) as 利润 from Topway..tbcash 
where cmpcode in ('020699') 
and datetime>='2018-10-01' and datetime<'2019-01-01' and reti=''
group by cmpcode

--法航广州至巴黎线 
--CAN and CDG
select coupno as 销售单号,tcode+ticketno as 票号,recno as PNR,begdate as 出发日期,route as 行程, sales as 所属差旅顾问 from Topway..tbcash 
where datetime>='2018-01-01' and datetime<'2019-01-17' 
and (route like'%CAN%' and route like'%CDG%')
 and ride in('AF','KL') 
 and inf=1 and reti=''
 order by datetime
 --CAN or CDG
 select coupno as 销售单号,tcode+ticketno as 票号,recno as PNR,begdate as 出发日期,route as 行程, sales as 所属差旅顾问 from Topway..tbcash 
where datetime>='2018-01-01' and datetime<'2019-01-17' 
and (route like'%CAN%' or route like'%CDG%')
 and ride in('AF','KL') 
 and inf=1 and reti=''
 order by datetime
 
 --18年的出票数据
 select cmpcode as UC,coupno as 销售单号,tcode+ticketno as 票号,route as 行程,nclass as 舱位,totsprice-tax as 文件价合计,sales as 所属差旅顾问 from Topway..tbcash 
 where inf=1 and ride='SK'
 and reti='' and datetime>='2018-01-01' and datetime<'2019-01-01' 
 order by coupno