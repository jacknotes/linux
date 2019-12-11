--常旅客删除
--select * from homsomDB..Trv_UnitCompanies where Cmpid='017735'
--TMS
select IsDisplay from homsomDB..Trv_Human 
--update homsomDB..Trv_Human  set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons where CompanyID='DD1C99FB-BD51-424E-BA28-04A24040B9DF')
and IsDisplay=1
and Name not in ('朱婧')
--ERP
select EmployeeStatus from Topway..tbCusholderM 
--update Topway..tbCusholderM set EmployeeStatus=0
where cmpid='017735'
and custname not in ('朱婧')

--行程单','特殊票价
select info3, * from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno in('AS002344169','AS002332698')

--会务预算单信息
select Sales,OperName,introducer,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Sales='崔之阳',OperName='0481崔之阳',introducer='崔之阳-0481-运营部'
where ConventionId in 
('1317','1347','1327','1361','1354','1336','1346','1365',
'1352','1353','1311','1310','1341','1326','1271','1355','1359','1321',
'1349','1356','1386','1382','1380','1383','1381','1385')

----酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='携程官网分销联盟'
where CoupNo='PTW079775'

select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='员工垫付(王贞中行卡)'
where CoupNo='PTW080098'

--会务预算单信息
select Sales,OperName,introducer from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Sales='崔之阳',OperName='0481崔之阳',introducer='崔之阳-0481-运营部'
where ConventionId='1384'

select totprice,totsprice,owe,profit,* from Topway..tbcash where coupno='AS002377747'

--删除单位员工
--select * from homsomDB..Trv_UnitCompanies where Cmpid='016888'

select IsDisplay from homsomDB..Trv_Human 
--update homsomDB..Trv_Human set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons 
where companyid='411D371B-E5C9-45BD-8886-BC9FBDC25091')
and Name not in ('黄佳萍（离职）','郑环（离职）')

select EmployeeStatus from Topway..tbCusholderM
--update  Topway..tbCusholderM set EmployeeStatus=0
where cmpid='016888'
and custname not in ('黄佳萍（离职）','郑环（离职）')

--修改UC号(国内)
--select * from Topway..tbcash where cmpcode='000126' and datetime>'2019-04-11'
--select custid from Topway..tbCusholderM where cmpid='000126' and custname='张曹萍'
--select * from Topway..AccountStatement where CompanyCode='000126' order by BillNumber desc
--select * from Topway..AccountStatement where CompanyCode='018720' order by BillNumber desc

select cmpcode,custid,ModifyBillNumber,OriginalBillNumber,pform,inf,* from Topway..tbcash 
--update Topway..tbcash  set cmpcode='000126',custid='D481444',OriginalBillNumber='000126_20190401'
where coupno='AS002320047'

   --修改UC号（TMS)
  select  CompanyName,* from homsomDB..Trv_Passengers
  --update homsomDB..Trv_Passengers set CompanyName='萨瓦尼尼国际贸易（上海）有限公司'
  where ItktBookingID='2F0F8585-5FCC-4EE9-8CF1-AA100143943E'
  
 --结算价差额
 select totsprice,profit,* from Topway..tbcash 
 --update Topway..tbcash  set totsprice='5376',profit='782'
 where coupno='AS002389837'
 
 --火车票销售单作废
 select * 
 --delete
 from Topway..tbTrainTicketInfo where CoupNo='RS000022051'
 
 select * 
 --delete
 from Topway..tbTrainUser where TrainTicketNo=( 
 select id from Topway..tbTrainTicketInfo 
 where CoupNo='RS000022051')
 
 --火车票供应商来源/配送信息
 select Ptype,* from Topway..tbTrainTicketInfo where CoupNo in('RS000022076','RS000022077')

--重开打印 
select pstatus,prdate,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set pstatus=0,prdate='1900-01-01'
where CoupNo='-PTW079321'


--select * from homsomDB..Trv_UnitCompanies where Cmpid='018623'
select IsDisplay from homsomDB..Trv_Human 
--update homsomDB..Trv_Human set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons 
where companyid='ED4D414A-3827-4B3D-8193-A314009ABA10')
and Name  in ('王洁枫',
'郝颖',
'章华平',
'黄晓春',
'顾豪杰',
'陈飞',
'张洁君',
'王亚峰',
'郭建安',
'张小刚',
'曹连弟',
'贾飞北',
'肖林',
'周小娜',
'陈惠玲',
'李雪源',
'吕楚彬',
'上官圣',
'徐美根',
'郁峥嵘',
'占敏',
'谢明君',
'郭小璇',
'路海宁',
'章斌',
'刘一鹤(离职）',
'张幼伟',
'黄金行',
'王佳丽（离职）',
'傅振华',
'李相昊')

select EmployeeStatus from Topway..tbCusholderM
--update  Topway..tbCusholderM set EmployeeStatus=0
where cmpid='018623'
and custname  in ('王洁枫',
'郝颖',
'章华平',
'黄晓春',
'顾豪杰',
'陈飞',
'张洁君',
'王亚峰',
'郭建安',
'张小刚',
'曹连弟',
'贾飞北',
'肖林',
'周小娜',
'陈惠玲',
'李雪源',
'吕楚彬',
'上官圣',
'徐美根',
'郁峥嵘',
'占敏',
'谢明君',
'郭小璇',
'路海宁',
'章斌',
'刘一鹤(离职）',
'张幼伟',
'黄金行',
'王佳丽（离职）',
'傅振华',
'李相昊')


/*--康宝莱部门分析表
select Department 部门,SUM(price) 不含税销量,count(*) 张数,SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) 平均折扣率 
from Topway..V_TicketInfo where cmpcode='020459'
and ModifyBillNumber in ('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201')
and tickettype NOT IN ('改期费', '升舱费','改期升舱')
and inf=1
group by Department
order by 不含税销量 desc

select SUM(price) 合计不含税销量,count(*) 张数,SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) 合计平均折扣率 
from Topway..V_TicketInfo where cmpcode='020459'
and ModifyBillNumber in ('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201')
and tickettype NOT IN ('改期费', '升舱费','改期升舱')
and inf=1
*/
/*
select * from homsomDB..Trv_UnitPersons u
left join homsomDB..Trv_Human h on h.ID=u.ID
where u.CompanyID=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='020459')
and h.Name='陈嘉妍'
*/


DECLARE @CMPCODE VARCHAR(20)='020459'
DECLARE @CUSTID VARCHAR(20)=''
DECLARE @STARTMONTH VARCHAR(10)='2018-07'
DECLARE @ENDMONTH VARCHAR(10)='2018-12'

IF OBJECT_ID('TEMPDB..#TTMP') IS NOT NULL
DROP TABLE #TTMP
CREATE TABLE #TTMP (
	MONTHDATE VARCHAR(10),
	GNSALESAMOUNT DECIMAL(18,2),
	GNTAX DECIMAL(18,2),
	GNTPAMOUNT DECIMAL(18,2),
	GNGQAMOUNT DECIMAL(18,2),
	GNFWFAMOUNT DECIMAL(18,2),
	GJSALESAMOUNT DECIMAL(18,2),
	GJTAX DECIMAL(18,2),
	GJTPAMOUNT DECIMAL(18,2),
	GJGQAMOUNT DECIMAL(18,2),
	GJFWFAMOUNT DECIMAL(18,2),
	BXAMOUNT DECIMAL(18,2),
	GNCOUNT INT,
	GJCOUNT INT
)

--国内机票销量
INSERT INTO #TTMP(MONTHDATE,GNSALESAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) 月份,SUM(price) 国内机票销量 FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--国内机票税收
INSERT INTO #TTMP(MONTHDATE,GNTAX)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) 月份,SUM(tax) 国内机票税收 FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--国内机票退票总金额
INSERT INTO #TTMP(MONTHDATE,GNTPAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) 月份,SUM(-T1.totprice) 国内机票退票总金额 FROM Topway..tbReti T1 WITH (NOLOCK)
INNER JOIN Topway..tbcash T2 WITH (NOLOCK) ON T1.reno=T2.reti 
WHERE T1.cmpcode = @CMPCODE
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND T2.inf=0
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--国内机票改期升舱销量
INSERT INTO #TTMP(MONTHDATE,GNGQAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) 月份,SUM(totprice) 国内机票改期升舱销量 FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype IN ('改期费', '升舱费','改期升舱')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--国内机票服务费销量
INSERT INTO #TTMP(MONTHDATE,GNFWFAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) 月份,SUM(fuprice) 国内机票服务费销量 FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype not IN ('改期费', '升舱费','改期升舱')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--国际机票销量
INSERT INTO #TTMP(MONTHDATE,GJSALESAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) 月份,SUM(price) 国际机票销量 FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=1
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND T1.route NOT LIKE '%改期%' 
AND T1.route NOT LIKE '%升舱%'
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--国际机票税收
INSERT INTO #TTMP(MONTHDATE,GJTAX)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) 月份,SUM(tax) 国际机票税收 FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=1
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND T1.route NOT LIKE '%改期%' 
AND T1.route NOT LIKE '%升舱%'
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--国际机票退票总金额
INSERT INTO #TTMP(MONTHDATE,GJTPAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) 月份,SUM(-T1.totprice) 国际机票退票总金额 FROM Topway..tbReti T1 WITH (NOLOCK)
INNER JOIN Topway..tbcash T2 WITH (NOLOCK) ON T1.reno=T2.reti 
WHERE T1.cmpcode = @CMPCODE
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND T2.inf=1
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--国际机票改期升舱销量
INSERT INTO #TTMP(MONTHDATE,GJGQAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) 月份,SUM(totprice) 国际机票改期升舱销量 FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=1
AND (T1.tickettype IN ('改期费', '升舱费','改期升舱') OR T1.route  LIKE '%改期%' OR T1.route LIKE '%升舱%')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--国际机票服务费销量
INSERT INTO #TTMP(MONTHDATE,GJFWFAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) 月份,SUM(fuprice) 国际机票服务费销量 FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=1
AND (T1.tickettype not IN ('改期费', '升舱费','改期升舱') OR T1.route  LIKE '%改期%' OR T1.route LIKE '%升舱%')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--保险销量
INSERT INTO #TTMP(MONTHDATE,BXAMOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) 月份,SUM(totprice) 保险销量 FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=-1
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--国内机票张数
INSERT INTO #TTMP(MONTHDATE,GNCOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) 月份, COUNT(ID) 国内机票张数 FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype IN ('电子票','改期费', '升舱费','改期升舱')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND ISNULL(T1.reti,'')='' 
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber



--国际机票张数
INSERT INTO #TTMP(MONTHDATE,GJCOUNT)
SELECT SUBSTRING(T1.ModifyBillNumber,8,6) 月份,COUNT(ID) 国际机票张数 FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=1
AND (T1.tickettype IN ('电子票','改期费', '升舱费','改期升舱') OR T1.route  LIKE '%改期%' OR T1.route LIKE '%升舱%')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND ISNULL(T1.reti,'')='' 
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ModifyBillNumber

--第一张SHEET
SELECT MONTHDATE 月份,
	SUM(ISNULL(GNSALESAMOUNT,0)) 国内机票销量,--国内机票销量
	SUM(ISNULL(GNTAX,0)) 国内机票税收,--国内机票税收
	SUM(ISNULL(GNTPAMOUNT,0)) 国内机票退票总金额,--国内机票退票总金额
	SUM(ISNULL(GNGQAMOUNT,0)) 国内机票改期升舱销量,--国内机票改期升舱销量
	SUM(ISNULL(GNFWFAMOUNT,0)) 国内机票服务费销量,
	SUM(ISNULL(GNSALESAMOUNT,0))+SUM(ISNULL(GNTAX,0))+SUM(ISNULL(GNTPAMOUNT,0))+SUM(ISNULL(GNGQAMOUNT,0))+SUM(ISNULL(GNFWFAMOUNT,0)) 国内机票合计,--国内机票合计
	SUM(ISNULL(GJSALESAMOUNT,0)) 国际机票销量,--国际机票销量
	SUM(ISNULL(GJTAX,0)) 国际机票税收,--国际机票税收
	SUM(ISNULL(GJTPAMOUNT,0)) 国际机票退票总金额,--国际机票退票总金额
	SUM(ISNULL(GJGQAMOUNT,0)) 国际机票改期升舱销量,--国际机票改期升舱销量
	SUM(ISNULL(GJFWFAMOUNT,0)) 国际机票服务费销量,
	SUM(ISNULL(GJSALESAMOUNT,0)) +SUM(ISNULL(GJTAX,0)) +SUM(ISNULL(GJTPAMOUNT,0)) +	SUM(ISNULL(GJGQAMOUNT,0))+SUM(ISNULL(GJFWFAMOUNT,0)) 国际机票合计,--国际机票合计
	SUM(ISNULL(BXAMOUNT,0)) 保险销量,--保险销量
	---TOTALAMOUNT START
	SUM(ISNULL(GNSALESAMOUNT,0))+SUM(ISNULL(GNTAX,0))+SUM(ISNULL(GNTPAMOUNT,0))+SUM(ISNULL(GNGQAMOUNT,0)) 
	+SUM(ISNULL(GJSALESAMOUNT,0)) +SUM(ISNULL(GJTAX,0)) +SUM(ISNULL(GJTPAMOUNT,0)) +	SUM(ISNULL(GJGQAMOUNT,0)) 
	+SUM(ISNULL(BXAMOUNT,0)) 总销量,--总销量
	---TOTALAMOUNT END
	SUM(ISNULL(GNCOUNT,0)) 国内机票张数,--国内机票张数
	SUM(ISNULL(GJCOUNT,0)) 国际机票张数,--国际机票张数
	SUM(ISNULL(GNCOUNT,0)) + SUM(ISNULL(GJCOUNT,0)) 机票总张数--机票总张数
FROM #TTMP
GROUP BY MONTHDATE

--第二张SHEET
SELECT  T1.[route] 行程,SUM(totprice) 国内机票销量,COUNT(ID) 国内机票张数 ,SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) 经济舱平均折扣率
FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.[route] ORDER BY 国内机票销量 DESC

SELECT TOP 10 T1.[route] 行程,SUM(totprice) 国际机票销量,COUNT(ID) 国际机票张数 ,SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) 经济舱平均折扣率
FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=1
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND T1.route NOT LIKE '%改期%' 
AND T1.route NOT LIKE '%升舱%'
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.[route] ORDER BY 国际机票销量 DESC

--第三张SHEET
IF OBJECT_ID('TEMPDB..#TTTHIRD') IS NOT NULL
DROP TABLE #TTTHIRD
SELECT DAYSFLAG,SUM(totprice) 合计销量,SUM(price) 不含税销量,COUNT(1) 合计张数,SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) 经济舱平均折扣率 INTO #TTTHIRD  FROM (
SELECT --T1.coupno,
CASE WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 0 AND 2 THEN 1
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 3 AND 4 THEN 2
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 5 AND 6 THEN 3
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 7 AND 8 THEN 4
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 9 AND 10 THEN 5
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 11 AND 12 THEN 6
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 13 AND 14 THEN 7
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) >14 THEN 8 END DAYSFLAG,
totprice,price,priceinfo 
FROM Topway..tbcash T1 WITH (NOLOCK)
--INNER JOIN ehomsom..tbInfCabincode T2 WITH (NOLOCK) ON T1.ride=T2.code2 AND T1.nclass=T2.cabin
WHERE T1.cmpcode = @CMPCODE
--AND T2.begdate<=T1.[datetime] AND T2.enddate>=T1.[datetime]
--AND ((T2.flightbegdate<=T1.begdate AND T2.flightenddate>=T1.begdate) OR
--(T2.flightbegdate2<=T1.begdate AND T2.flightenddate2>=T1.begdate) OR
--(T2.flightbegdate3<=T1.begdate AND T2.flightenddate3>=T1.begdate) OR
--(T2.flightbegdate4<=T1.begdate AND T2.flightenddate4>=T1.begdate))
--AND T2.cabintype like '%经济舱%'
AND T1.inf=0
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
) T
GROUP BY DAYSFLAG

DECLARE @TOTALTHIRDAMOUNT DECIMAL(18,2) 
DECLARE @TOTALTHIRDCOUNT DECIMAL(18,2)  
SELECT @TOTALTHIRDAMOUNT=SUM(合计销量) FROM #TTTHIRD
SELECT @TOTALTHIRDCOUNT=SUM(合计张数) FROM #TTTHIRD

SELECT @TOTALTHIRDAMOUNT 总销量,@TOTALTHIRDCOUNT 总张数,DAYSFLAG, 
合计销量,不含税销量,合计销量/@TOTALTHIRDAMOUNT 销量比例,合计张数,合计张数/@TOTALTHIRDCOUNT 张数比例, 经济舱平均折扣率 FROM #TTTHIRD


--第四张SHEET
IF OBJECT_ID('TEMPDB..#TTFOURTH') IS NOT NULL
DROP TABLE #TTFOURTH
SELECT T2.airname,T1.ride,SUM(totprice) 合计销量,COUNT(1) 合计张数 INTO #TTFOURTH FROM Topway..tbcash T1 WITH (NOLOCK)
INNER JOIN ehomsom..tbInfAirCompany T2 WITH (NOLOCK) ON T1.ride=T2.code2
WHERE T1.cmpcode = @CMPCODE
AND T1.inf<>-1
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND T1.route NOT LIKE '%改期%' 
AND T1.route NOT LIKE '%升舱%'
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T2.airname,T1.ride

DECLARE @TOTALFOURTHAMOUNT DECIMAL(18,2) 
DECLARE @TOTALFOURTHCOUNT DECIMAL(18,2)  
SELECT @TOTALFOURTHAMOUNT=SUM(合计销量) FROM #TTFOURTH
SELECT @TOTALFOURTHCOUNT=SUM(合计张数) FROM #TTFOURTH

SELECT @TOTALFOURTHAMOUNT 总销量,@TOTALFOURTHCOUNT 总张数,airname 航司名称,ride 航司二字码,
合计销量,合计销量/@TOTALFOURTHAMOUNT 销量比例,合计张数,合计张数/@TOTALFOURTHCOUNT 张数比例 FROM #TTFOURTH
ORDER BY 合计销量 DESC



--第五张SHEET
IF OBJECT_ID('TEMPDB..#TTFIFTH') IS NOT NULL
DROP TABLE #TTFIFTH
SELECT T2.airname,T1.ride,SUM(totprice) 合计销量,COUNT(1) 合计张数 INTO #TTFIFTH FROM Topway..tbcash T1 WITH (NOLOCK)
INNER JOIN ehomsom..tbInfAirCompany T2 WITH (NOLOCK) ON T1.ride=T2.code2
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND T1.route NOT LIKE '%改期%' 
AND T1.route NOT LIKE '%升舱%'
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T2.airname,T1.ride

DECLARE @TOTALFIFTHAMOUNT DECIMAL(18,2) 
DECLARE @TOTALFIFTHCOUNT DECIMAL(18,2)  
SELECT @TOTALFIFTHAMOUNT=SUM(合计销量) FROM #TTFIFTH
SELECT @TOTALFIFTHCOUNT=SUM(合计张数) FROM #TTFIFTH

SELECT @TOTALFIFTHAMOUNT 总销量,@TOTALFIFTHCOUNT 总张数,airname 航司名称,ride 航司二字码,
合计销量,合计销量/@TOTALFIFTHAMOUNT 销量比例,合计张数,合计张数/@TOTALFIFTHCOUNT 张数比例 FROM #TTFIFTH
ORDER BY 合计销量 DESC

--第六张SHEET
IF OBJECT_ID('TEMPDB..#TTSIXTH') IS NOT NULL
DROP TABLE #TTSIXTH
SELECT T2.airname,T1.ride,SUM(totprice) 合计销量,COUNT(1) 合计张数 INTO #TTSIXTH FROM Topway..tbcash T1 WITH (NOLOCK)
INNER JOIN ehomsom..tbInfAirCompany T2 WITH (NOLOCK) ON T1.ride=T2.code2
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=1
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND T1.route NOT LIKE '%改期%' 
AND T1.route NOT LIKE '%升舱%'
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T2.airname,T1.ride

DECLARE @TOTALSIXTHAMOUNT DECIMAL(18,2) 
DECLARE @TOTALSIXTHCOUNT DECIMAL(18,2)  
SELECT @TOTALSIXTHAMOUNT=SUM(合计销量) FROM #TTSIXTH
SELECT @TOTALSIXTHCOUNT=SUM(合计张数) FROM #TTSIXTH

SELECT @TOTALSIXTHAMOUNT 总销量,@TOTALSIXTHCOUNT 总张数,airname 航司名称,ride 航司二字码,
合计销量,合计销量/@TOTALSIXTHAMOUNT 销量比例,合计张数,合计张数/@TOTALSIXTHCOUNT 张数比例 FROM #TTSIXTH
ORDER BY 合计销量 DESC


--第七张SHEET
IF OBJECT_ID('TEMPDB..#TTSEVENTH') IS NOT NULL
DROP TABLE #TTSEVENTH
SELECT CABINFLAG,SUM(price) 合计销量不含税,SUM(CAST(priceinfo AS DECIMAL)) 合计全价不含税,COUNT(1) 合计张数 INTO #TTSEVENTH  FROM (
SELECT --T1.coupno,
CASE WHEN price/CAST(priceinfo AS DECIMAL) >1 THEN 1
	WHEN price/CAST(priceinfo AS DECIMAL) =1 THEN 2
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.95 AND price/CAST(priceinfo AS DECIMAL) <1 THEN 3
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.90 AND price/CAST(priceinfo AS DECIMAL) <0.95 THEN 4
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.85 AND price/CAST(priceinfo AS DECIMAL) <0.90 THEN 5
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.80 AND price/CAST(priceinfo AS DECIMAL) <0.85 THEN 6
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.75 AND price/CAST(priceinfo AS DECIMAL) <0.80 THEN 7
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.70 AND price/CAST(priceinfo AS DECIMAL) <0.75 THEN 8
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.65 AND price/CAST(priceinfo AS DECIMAL) <0.70 THEN 9
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.60 AND price/CAST(priceinfo AS DECIMAL) <0.65 THEN 10
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.55 AND price/CAST(priceinfo AS DECIMAL) <0.60 THEN 11
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.50 AND price/CAST(priceinfo AS DECIMAL) <0.55 THEN 12
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.45 AND price/CAST(priceinfo AS DECIMAL) <0.50 THEN 13
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.40 AND price/CAST(priceinfo AS DECIMAL) <0.45 THEN 14
	WHEN price/CAST(priceinfo AS DECIMAL) <0.40 THEN 15 END CABINFLAG,
totprice,price,priceinfo 
FROM Topway..tbcash T1 WITH (NOLOCK)
WHERE T1.cmpcode = @CMPCODE
AND T1.inf=0
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
) T
GROUP BY CABINFLAG

DECLARE @TOTALSEVENTHAMOUNT DECIMAL(18,2) 
DECLARE @TOTALSEVENTHCOUNT DECIMAL(18,2)  
DECLARE @TOTALSEVENTHFULLAMOUNT DECIMAL(18,2)  
SELECT @TOTALSEVENTHAMOUNT=SUM(合计销量不含税) FROM #TTSEVENTH
SELECT @TOTALSEVENTHCOUNT=SUM(合计张数) FROM #TTSEVENTH
SELECT @TOTALSEVENTHFULLAMOUNT=SUM(合计全价不含税) FROM #TTSEVENTH

SELECT @TOTALSEVENTHAMOUNT/@TOTALSEVENTHFULLAMOUNT 平均折扣率,@TOTALSEVENTHAMOUNT 总销量,@TOTALSEVENTHCOUNT 总张数,CABINFLAG, 
合计销量不含税,合计销量不含税/@TOTALSEVENTHAMOUNT 销量比例,合计张数,合计张数/@TOTALSEVENTHCOUNT 张数比例 FROM #TTSEVENTH
