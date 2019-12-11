/*
CZ HO MF
2018-01-01至2019-03-31
先以单位得销量为排序，再以乘机人得乘机次数排序
航司 单位名称 乘机人 证件类型 证件号 乘机次数
*/
IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
SELECT cmpcode,ride,SUM(totprice) AS totprice 
INTO #cmp 
FROM tbcash  WITH (NOLOCK) WHERE --ride IN('MF') AND 
datetime>='2018-01-01' AND datetime<'2019-04-01' AND inf=0 AND tickettype='电子票' AND cmpcode<>''
AND cmpcode IN(
'020730',
'019956',
'015828',
'020165',
'000126',
'016696',
'016179',
'019392',
'017865',
'019089',
'018021',
'017887',
'017120',
'019409',
'019423',
'019654',
'019717',
'019948',
'020020',
'020158',
'020154',
'020220',
'020287',
'020310',
'020350',
'020370',
'018362',
'020774',
'020359',
'020017',
'019822',
'020297',
'020521',
'020506',
'020530',
'020592',
'019637',
'016751',
'020036',
'020758',
'020719',
'019483',
'020731',
'017193',
'020176',

'017275',
'017491',
'001787',
'019839',
'017506',
'017153',
'017969',
'018897',
'020504',

'019294',
'017670',
'019539',
'020039',
'016712',
'016564',
'019663',
'020511',
'018294',
'018677',
'019362',
'017273',
'017376',
'019404',
'019619',
'018642',
'019944',
'019925',
'018615',
'019978',
'017339',
'016556',
'019256',
'020541',
'020441',
'020262',
'016883',
'020640',
'017674',
'017125',
'017525',
'016991',
'020778',
'018156',
'018793',
'019591',
'019242',
'018397',
'019112',
'019325',
'019641',
'016602',
'017423',
'020614',
'020693',
'020717',
'020718',
'020659',
'018661',

'016465',
'014412',
'015717',
'016465',
'016477',
'016572',
'016655',
'016689',
'016777',
'017173',
'017642',
'017739',
'017745',
'017850',
'017988',
'018064',
'018108',
'018257',
'018309',
'018314',
'018443',
'018449',
'018574',
'018821',
'018827',
'018939',
'019143',
'019197',
'019226',
'019245',
'019259',
'019270',
'019349',
'019473',
'019505',
'019513',
'019550',
'019556',
'019651',
'019764',
'019796',
'019798',
'019897',
'019935',
'019975',
'019976',
'019996',
'020051',
'020348',
'020510',
'020588',
'020589',
'020677',
'020708',
'020711'
)
GROUP BY cmpcode,ride

IF OBJECT_ID('tempdb.dbo.#per') IS NOT NULL DROP TABLE #per
SELECT cmpcode,ride,pasname,idno,COUNT(pasname) AS num 
INTO #per 
FROM tbcash WITH (NOLOCK) WHERE --ride IN('MF') AND 
datetime>='2018-01-01' AND datetime<'2019-04-01' AND inf=0 AND tickettype='电子票' AND cmpcode<>''
AND cmpcode IN(
'020730',
'019956',
'015828',
'020165',
'000126',
'016696',
'016179',
'019392',
'017865',
'019089',
'018021',
'017887',
'017120',
'019409',
'019423',
'019654',
'019717',
'019948',
'020020',
'020158',
'020154',
'020220',
'020287',
'020310',
'020350',
'020370',
'018362',
'020774',
'020359',
'020017',
'019822',
'020297',
'020521',
'020506',
'020530',
'020592',
'019637',
'016751',
'020036',
'020758',
'020719',
'019483',
'020731',
'017193',
'020176',

'017275',
'017491',
'001787',
'019839',
'017506',
'017153',
'017969',
'018897',
'020504',

'019294',
'017670',
'019539',
'020039',
'016712',
'016564',
'019663',
'020511',
'018294',
'018677',
'019362',
'017273',
'017376',
'019404',
'019619',
'018642',
'019944',
'019925',
'018615',
'019978',
'017339',
'016556',
'019256',
'020541',
'020441',
'020262',
'016883',
'020640',
'017674',
'017125',
'017525',
'016991',
'020778',
'018156',
'018793',
'019591',
'019242',
'018397',
'019112',
'019325',
'019641',
'016602',
'017423',
'020614',
'020693',
'020717',
'020718',
'020659',
'018661',

'016465',
'014412',
'015717',
'016465',
'016477',
'016572',
'016655',
'016689',
'016777',
'017173',
'017642',
'017739',
'017745',
'017850',
'017988',
'018064',
'018108',
'018257',
'018309',
'018314',
'018443',
'018449',
'018574',
'018821',
'018827',
'018939',
'019143',
'019197',
'019226',
'019245',
'019259',
'019270',
'019349',
'019473',
'019505',
'019513',
'019550',
'019556',
'019651',
'019764',
'019796',
'019798',
'019897',
'019935',
'019975',
'019976',
'019996',
'020051',
'020348',
'020510',
'020588',
'020589',
'020677',
'020708',
'020711'
)
GROUP BY cmpcode,ride,pasname,idno


IF OBJECT_ID('tempdb.dbo.#hebing') IS NOT NULL DROP TABLE #hebing
SELECT c.*,p.pasname,p.idno,p.num INTO #hebing FROM #per p
LEFT JOIN #cmp c ON p.cmpcode=c.cmpcode AND p.ride=c.ride 
WHERE  p.num>=2
ORDER BY c.totprice,p.num DESC



IF OBJECT_ID('tempdb.dbo.#hebing1') IS NOT NULL DROP TABLE #hebing1
SELECT c.*,p.pasname,p.idno,p.num INTO #hebing1 FROM #per p
LEFT JOIN #cmp c ON p.cmpcode=c.cmpcode AND p.ride=c.ride 

ORDER BY c.totprice,p.num DESC


--SELECT * FROM #hebing1 WHERE cmpcode='020778'

SELECT h.cmpcode,h.pasname,h.idno,SUM(h.num) FROM #hebing h 
GROUP BY h.cmpcode,h.pasname,h.idno  HAVING(SUM(h.num)>=4)

SELECT h.cmpcode,h.pasname,h.idno,SUM(h.num) FROM #hebing1 h 
--WHERE h.ride='mf' 
GROUP BY h.cmpcode,h.pasname,h.idno   HAVING(SUM(h.num)<2)

--一年内出过票的名单数
SELECT DISTINCT cmpcode,pasname,idno 
into #cprs 
FROM #hebing1

select distinct cmpcode,COUNT(idno) from #cprs
group by cmpcode

--任意航空出行过2次人数
drop table #cgcs
SELECT h.cmpcode,h.pasname,h.idno,SUM(h.num) 次数
into #cgcs
FROM #hebing h 
GROUP BY h.cmpcode,h.pasname,h.idno  HAVING(SUM(h.num)>=6)

select cmpcode,COUNT(idno) from #cgcs
group by cmpcode

select * from #cgcs

--乘过南航的人数

SELECT  cmpcode,COUNT(idno)

FROM #hebing1
where ride='cz'
group by cmpcode



--乘过一次南航的人数
SELECT cmpcode,pasname,idno,num
FROM #hebing1
where ride='cz' and num<6
group by cmpcode

--（产品专用）申请费来源/金额信息（国际）
select feiyong ,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash set feiyong=0,feiyonginfo=''
where coupno='AS002429919'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='017290_20190301'

--国际订单
--更改支付方式（自付、垫付)国际

select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set PayNo=TCPayNo,TCPayNo='',PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=null,CustomerPayDate=TcPayDate,dzhxDate=TcPayDate,TcPayDate='1900-01-01',status=1,owe=0,vpay=totprice
where coupno in ('AS002359436','AS002352133','AS002339419','AS002323390','AS002277444','AS002277425','AS002277412')


select PayStatus,AdvanceStatus,PayNo,TCPayNo,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET PayStatus=AdvanceStatus,PayNo=TCPayNo,CustomerPayWay=TcPayWay,CustomerPayDate=TcPayDate,AdvanceStatus=0,TCPayNo='',TcPayWay=0,TcPayDate=null
WHERE CoupNo in ('AS002359436','AS002352133','AS002339419','AS002323390','AS002277444','AS002277425','AS002277412')

--旅游结算单信息
--select * from Topway..tbCusholderM where mobilephone='13311832352'
--select * from Topway..tbTrvCoup where TrvId='29899'

select Custid,PasName,Custinfo,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Custinfo='17612178676@费凡@020783@上海银联股份有限公司@费凡@17612178676@D664617'
where TrvId='29899'

select * from Topway..tbTrvCoup  
--update Topway..tbTrvCoup set Custid='D664617'
where TrvId='29899'

select * from Topway..tbTravelBudget
--update Topway..tbTravelBudget set Custid='D664617',PasName='费凡'
where TrvId='29899'

select * from Topway..tbTrvCoup  
--update Topway..tbTrvCoup set Custid='D664617'
where TrvId='29907'

select Custid,PasName from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Custid='D664618',PasName='周泰来'
where TrvId='29907'

select Custid,PasName,Custinfo,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Custinfo='13311832352@周泰来@020783@上海银联股份有限公司@周泰来@13311832352@D664618'
where TrvId='29907'

select * from homsomDB..Trv_UnitCompanies where Cmpid='020783'

--行程单、特殊票价
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='需打印行程单'
where coupno in ('AS002293562','AS002302505')

--旅游结算单作废
select * from topway..tbTrvSettleApp
--update topway..tbTrvSettleApp set SettleStatus='3' 
where Id='27094'

select * from topway..tbTrvJS
--update topway..tbTrvJS set Jstatus='0',Settleno='0',Pstatus='0',Pdatetime='1900-1-1' 
where Settleno='27094'


--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='携程官网分销联盟'
where CoupNo='PTW080664'

--修改旅游收款
select owe,bpay,cwstatus,dzHxDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set cwstatus=1
where TrvId='29659'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update  Topway..AccountStatement  set SubmitState=1
where BillNumber='018720_20190221'


--单位客户授信额度调整
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update  Topway..AccountStatement  set SX_TotalCreditLine=60000
where BillNumber='020491_20190401'

--删除单位项目编号UC019333 帝费自动化工程技术（上海）有限公司
--select * from homsomDB..Trv_UnitCompanies where Cmpid='019333'
--删除现有项目编号

select * 
--delete
from homsomDB..Trv_Customizations 
where UnitCompanyID in(select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='019333') 

--插入新项目编号

INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','Warehouse','0','Warehouse','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','Admin','0','Admin','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','CPI TFK-S-China','0','CPI TFK-S-China','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','CPI Lotes-S-China','0','CPI Lotes-S-China','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','HIS MEGA-S','0','HIS MEGA-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','HMD00-SAT','0','HMD00-SAT','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','HMD00-W','0','HMD00-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','TFH-W','0','TFH-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','TFH-SAT-China','0','TFH-SAT-China','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','HST-SAT-China','0','HST-SAT-China','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','BCO06-W','0','BCO06-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','BCO07-W','0','BCO07-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','BCO08-W','0','BCO08-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','BCO08-SAT','0','BCO08-SAT','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','Brazil-S','0','Brazil-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','India FX-SAT','0','India FX-SAT','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','India FX-S','0','India FX-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','SGI07-W','0','SGI07-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','SGI-S','0','SGI-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','TPN WISTRON SZ-S','0','TPN WISTRON SZ-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','TPI WISTRON ZS-S','0','TPI WISTRON ZS-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','TPI23-W','0','TPI23-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','TPI24-W','0','TPI24-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','TPI25-W','0','TPI25-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','TPI QSMC-S','0','TPI QSMC-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','TPI FXCD-S','0','TPI FXCD-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','TPI WISTRON-SAT','0','TPI WISTRON-SAT','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','TPI SUNREX-S-China','0','TPI SUNREX-S-China','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','HNI-S-China','0','HNI-S-China','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','UMPG-S-China','0','UMPG-S-China','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','UMP18MP-W','0','UMP18MP-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','UMP18GMP-W','0','UMP18GMP-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','UMP19MP-W','0','UMP19MP-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','UMP19-SAT','0','UMP19-SAT','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','UMP19-Conversion','0','UMP19-Conversion','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','UMP19GMP-SAT','0','UMP19GMP-SAT','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','UMP19GMP-W','0','UMP19GMP-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','UMP19GMP-S','0','UMP19GMP-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),'2019-04-26','2019-04-26','homsom','2019-04-26','UMP-S-China','0','UMP-S-China','12CD09E1-095C-4B40-81E9-A506009CE2AD')

--销售单信息
select profit,totsprice,* from Topway..tbcash 
--update Topway..tbcash set profit=0
where coupno='AS002429919'

--旅游预订人修改
--select * from Topway..tbCusholderM where mobilephone='15921532123'

select Custid,Custinfo,PasName,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Custid='D664691',Custinfo='15921532123@郑李楹@020794@中国农业银行股份有限公司@郑李楹@15921532123@D664691'
where TrvId='29930'

--行程单
select info3,* from Topway..tbcash 
--update  Topway..tbcash set info3='需打印行程单'
where coupno in('AS002362602',
'AS002362590',
'AS002363139',
'AS002363926',
'AS002363931',
'AS002364170',
'AS002364338',
'AS002364483',
'AS002365160',
'AS002365162',
'AS002366830',
'AS002366773',
'AS002366824',
'AS002366928',
'AS002366962',
'AS002366968',
'AS002366964',
'AS002367300',
'AS002367928',
'AS002368174',
'AS002368168',
'AS002371019',
'AS002372201',
'AS002372199',
'AS002372959',
'AS002373179',
'AS002373632',
'AS002374036',
'AS002374023',
'AS002374040',
'AS002374045',
'AS002374047',
'AS002374032',
'AS002375333',
'AS002375372',
'AS002376643',
'AS002376641',
'AS002376647',
'AS002376645',
'AS002376931',
'AS002378642',
'AS002378626',
'AS002378634',
'AS002378652',
'AS002382089',
'AS002382360',
'AS002383480',
'AS002383476',
'AS002388148',
'AS002390808',
'AS002392540',
'AS002392546',
'AS002392558',
'AS002392556',
'AS002392761',
'AS002393699',
'AS002393859',
'AS002393865',
'AS002396361',
'AS002397701',
'AS002399405',
'AS002399427',
'AS002399504',
'AS002400069',
'AS002400551',
'AS002401901',
'AS002401905',
'AS002401909',
'AS002401899',
'AS002403669',
'AS002405293',
'AS002405411',
'AS002407281',
'AS002408068',
'AS002410404',
'AS002410448',
'AS002410641',
'AS002410645',
'AS002411719',
'AS002412324',
'AS002412322',
'AS002412326',
'AS002412336',
'AS002412368',
'AS002415632',
'AS002416340',
'AS002417601',
'AS002420147',
'AS002422698',
'AS002422966',
'AS002423848',
'AS002424376',
'AS002425793',
'AS002427133',
'AS002427401',
'AS002370884',
'AS002385048',
'AS002392338',
'AS002396140',
'AS002420898',
'AS002427110',
'AS002427190')

select  pstatus,prdate,CPQMDATE1,CPQMDATE2,CPQM1,CPQM2,* from Topway..tbHtlSettlementApp where id='25712'


--修改部门
select team,depdetail,* from Topway..Emppwd  
--update Topway..Emppwd  set team='会务运营部',depdetail='会务顾问'
where empname in('祁燕','张广寒','崔之阳')


select * from Topway..Emppwd   
--update Topway..Emppwd   set team='旅游运营部'
where team ='旅游会务运营一组'

select DeptCode,Signer,* from ApproveBase..HR_AskForLeave_Signer
--update ApproveBase..HR_AskForLeave_Signer set DeptCode='旅游运营部'
where DeptCode='旅游会务运营一组'
  
  select DeptCode,Signer,* from ApproveBase..HR_AskForLeave_Signer
--update ApproveBase..HR_AskForLeave_Signer set DeptCode='会务运营部'
where DeptCode='旅游会务运营二组'



select totprice,reti,* from Topway..tbcash where coupno='AS002308721'

  