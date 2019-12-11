/*
报表系统中退票收入tbreti.totprice2225325-退票成本tbreti.stotprice2236831-退票佣金tbcash.yjprice+bpprice7244-退票折扣tbreti.disct52948
*/
退票成本+退票佣金+退票折扣-退票收入
SELECT 2236831+7244+52948-2225325=71698
SELECT 2236831+7244-2225325=18750
计算供应商金额（HS应收金额 = 原结算价[含税] - 已使用金额 - 已使用税收 - 航空公司退票费 - NO SHOW费 ）

HS应付金额 = 实际销售价 - 收客户退票金额
//计算调整利润 (调整利润 = HS应收金额 - HS应付金额 + 单位佣金后返 + 正常积点 + 促销积点-多收退票费抵充促销积点)



计算供应商金额（HS应收金额 = 原结算价[含税] - 已使用金额 - 已使用税收 - 航空公司退票费 - NO SHOW费 ）
stotprice=sprice-scount1-usedtaxg-scount2-noshowg
HS应付金额 = 实际销售价 - 收客户退票金额
totprice=totprice[tbcash]-rtprice
//计算调整利润 (调整利润 = HS应收金额 - HS应付金额 + 单位佣金后返 + 正常积点 + 促销积点-多收退票费抵充促销积点)
tzprofit=stotprice-totprice+(yjprice+bpprice+disct)[tbcash]-zkrefundprice
SELECT stotprice,totprice,sprice,UsedTaxG,scount1,scount2,NoShowG,rtprice,ZkRefundPrice,* FROM tbreti



SELECT TOP 100 tbcash.coupno,tbreti.totprice,yjprice+bpprice,tbreti.disct,tbreti.ZkRefundPrice
,tbReti.stotprice-tbreti.totprice+yjprice+bpprice+tbcash.disct-tbreti.ZkRefundPrice [退票利润]
,tbReti.profit
from tbreti 
left join tbcash on tbreti.ticketno = tbcash.ticketno and tbreti.reno=tbcash.reti 
left join tbCompanyM on tbreti.cmpcode = cmpid  
where ExamineDate >= '2017-12-01' and ExamineDate <'2018-01-01' 
and tbreti.status2 not in(1,3,4) 
AND tbreti.ZkRefundPrice<>0

--=====报表相关--财务相关--退票应收及应付报表--退票成本及收入查询列表 start---> =======================================
--退票收入
select tbreti.cmpcode,count(*) as num,cmpname
,sum(tbreti.stotprice)as [HS应收金额stotprice]
,sum(tbreti.totprice)as [HS应付金额totprice]
,sum(yjprice+bpprice)as [tpyjprice单位佣金后返+正常积点]
,sum(tbreti.disct)as [促销积点disct]
--,SUM(tbcash.disct) AS [促销积点disct2,二者取其一]  
,SUM(tbreti.ZkRefundPrice)AS [多收退票费抵充促销积点ZkRefundPrice]
,SUM(dbo.tbReti.profit) [利润]
,SUM(tbReti.stotprice-tbreti.totprice+yjprice+bpprice+tbreti.disct-tbreti.ZkRefundPrice) [公式计算利润]
from tbreti 
left join tbcash on tbreti.ticketno = tbcash.ticketno and tbreti.reno=tbcash.reti 
left join tbCompanyM on tbreti.cmpcode = cmpid  
where ExamineDate >= '2017-12-01' and ExamineDate <'2018-01-01' 
and tbreti.status2 not in(1,3,4) 
group by tbreti.cmpcode,cmpname
ORDER BY tbReti.cmpcode 

--注意 退票用票号和退票单号可能为Null
SELECT tbreti.status2,* FROM tbreti 
left join tbcash on tbreti.ticketno = tbcash.ticketno and tbreti.reno=tbcash.reti 
WHERE dbo.tbcash.id IS NULL

--注意 cmpcode是换行符
SELECT r.id,r.coupno,r.ticketno,r.ExamineDate,r.cmpcode,c.cmpcode,CASE WHEN c.cmpcode=CHAR(10) THEN 1 ELSE 0 END FROM dbo.tbReti r INNER JOIN tbcash c ON r.cmpcode=CHAR(10) AND r.coupno=c.coupno AND r.ticketno=c.ticketno 
SELECT ExamineDate,* FROM dbo.tbReti WHERE cmpcode=CHAR(10)
UPDATE tbReti SET cmpcode='' WHERE cmpcode=CHAR(10)
--退票成本
select t_source,count(*)as num,sum(tbreti.stotprice) as stotprice 
from tbreti 
inner join tbcash on tbreti.ticketno = tbcash.ticketno and tbreti.reno=tbcash.reti 
left join tbCompanyM on tbreti.cmpcode = cmpid  
where ExamineDate >= '2017-09-01' and ExamineDate <'2017-10-01' and tbreti.status2 not in(1,3,4) 
group by t_source 

--退票收入计算利润的明细

SELECT tbreti.id, tbreti.cmpcode,tbreti.custid,tbcash.datetime
,tbReti.stotprice [HS应收金额]
,tbreti.totprice[HS应付金额]
,tbcash.yjprice[单位佣金后返]
,tbcash.bpprice [正常积点]
,tbreti.disct[促销积点]
--,tbcash.disct[促销积点2]
,tbreti.ZkRefundPrice[多收退票费抵充促销积点]
,tbReti.stotprice-tbreti.totprice+yjprice+bpprice+tbcash.disct-tbreti.ZkRefundPrice
,tbReti.profit
from tbreti 
left join tbcash on tbreti.ticketno = tbcash.ticketno and tbreti.reno=tbcash.reti 
left join tbCompanyM on tbreti.cmpcode = cmpid  
where ExamineDate >= '2017-09-01' and ExamineDate <'2017-10-01' 
and tbreti.status2 not in(1,3,4) 

--=====end---<-------=======================================


151283
151284
151416
151282
151105
152008
151289
152339
151104
152340
151236

--AND tbreti.disct<>tbcash.disct
AND dbo.tbReti. id IN (130241,125705,131456,130240)

UPDATE tbreti SET disct=20,profit=14 WHERE id=130241
UPDATE tbreti SET disct=5,profit=53 WHERE id=125705
UPDATE tbreti SET disct=10,profit=61 WHERE id=131456
UPDATE tbreti SET disct=30,profit=44 WHERE id=130240



SELECT SUM(tbreti.profit),COUNT(1)
SELECT tbreti.id, dbo.tbReti.cmpcode,dbo.tbReti.custid,LEN(dbo.tbreti.cmpcode),CASE WHEN tbreti.cmpcode='' THEN 1 ELSE 0 end ,REPLACE(tbreti.cmpcode,CHAR(10),'br')
from tbreti 
left join tbcash on tbreti.ticketno = tbcash.ticketno and tbreti.reno=tbcash.reti 
left join tbCompanyM on tbreti.cmpcode = cmpid  
where ExamineDate >= '2015-10-01' and ExamineDate <'2015-11-01' 
and tbreti.status2 not in(1,3,4) 
AND NOT(
len(tbreti.cmpcode)=6 
OR (tbreti.custid <>'' and  tbreti.cmpcode='')
OR (tbreti.custid ='' and  tbreti.cmpcode=''  )
)

                       

