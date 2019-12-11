--航司销量和毛利
--IF OBJECT_ID('tempdb.dbo.#ZXL') IS NOT NULL DROP TABLE #ZXL
select ride 航司编码,SUM(totprice) 销量,SUM(profit-Mcost) 毛利润 
--INTO #ZXL
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and tickettype='电子票'
and inf=0
group by ride
order by 销量 desc


--IF OBJECT_ID('tempdb.dbo.#XL') IS NOT NULL DROP TABLE #XL
select ride 航司编码,SUM(totprice) 销量,SUM(profit-Mcost) 毛利润 
--INTO #XL
from Topway..tbcash c
left join ehomsom..tbInfCabincode t on t.code2=c.ride and c.nclass=t.cabin
and t.begdate<=c.begdate and t.enddate>=c.begdate
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and (nclass='Y' or cabintype like'%公务舱%' or cabintype like'%头等舱%')
and tickettype='电子票'
and inf=0
group by ride
order by 销量 desc

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=1386,profit=51
where coupno='AS002353301'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=5366,profit=299
where coupno='AS002353452'


--UC018266上海奥普生物医药有限公司 1.注册日改为：2019.03.28 2.单位类型改为：旅游单位客户 3.结算方式改为：现结
--注册日,旅游客户
select indate,CustomerType,* from Topway..tbCompanyM 
--update Topway..tbCompanyM  set indate='2019-03-28'
where cmpid='018266'

select RegisterMonth,Type,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set RegisterMonth='03 28 2019 12:00PM',Type='C'
where Cmpid='018266'

--结算方式
--select * from Topway..AccountStatement where CompanyCode='018266' order by BillNumber desc

select PendDate,Status,* from Topway..HM_CompanyAccountInfo 
--update Topway..HM_CompanyAccountInfo set PendDate='2019-02-28',Status='-1'
where CmpId='018266' and Id='4593'

select SEndDate,Status,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SEndDate='2019-02-28',Status=-1
where CmpId='018266' and Status=1

select SStartDate,Status,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SStartDate='2019-03-01',Status=1
where CmpId='018266' and Status=2

SELECT EndDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set EndDate='2019-02-28',Status=-1
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '018266') 
and Status=1

SELECT StartDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set StartDate='2019-03-01',Status=1
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '018266') 
and Status=2

--到账改未阅
select haschecked,*  from Topway..FinanceERP_ClientBankRealIncomeDetail 
--update Topway..FinanceERP_ClientBankRealIncomeDetail set haschecked=0
where date='2019-03-26' and money='1500'

--修改机场名
select Name,AbbreviationName,EnglishName,* from homsomDB..Trv_Airport 
--update homsomDB..Trv_Airport set Name='博洛尼亚(古列尔莫马可尼机场)',EnglishName='Bologna Guglielmo Marconi Airport',AbbreviationName='博洛尼亚'
where Code='BLQ'