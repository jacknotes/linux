--①	旅游会务已付已到账收款单-已结清退款单（预算单未毕团，时间区间：2014.1.1-2016.9.30）

--会务收款单
select sk.ConventionId as 预算单号,sk.OperDate as 生成日期,sk.totprice+InvoiceTax as 收款金额
from dbo.tbConventionKhSk sk
INNER JOIN dbo.tbConventionBudget bud ON sk.ConventionId = bud.ConventionId
WHERE sk.OperDate>='2014-01-01' AND sk.OperDate<'2018-06-01' AND sk.cwstatus='1' and bud.Status not in (2,15) and sk.Skstatus<>2
order by sk.ConventionId


--会务退款单
select tk.ConventionId as 预算单号,tk.OperDate as 生成日期,tk.Price as 退款金额 
from dbo.tbConventionKhTk tk
inner join dbo.tbConventionBudget bud ON tk.ConventionId = bud.ConventionId
WHERE tk.OperDate>='2014-01-01' AND tk.OperDate<'2018-06-01' AND cwstatus='2' and bud.Status not in (2,15) and tk.tkstatus<>2
order by tk.ConventionId

--旅游收款单
select sk.TrvId as 预算单号,sk.OperDate as 生成日期,sk.totprice+InvoiceTax  as 收款金额 
from  dbo.tbTrvKhSk sk
INNER JOIN dbo.tbTravelBudget bud ON sk.TrvId = bud.TrvId
WHERE  sk.OperDate>='2014-01-01' AND sk.OperDate<'2018-06-01' AND cwstatus='1' and bud.Status not in (1,2)  and sk.Skstatus<>2
order by sk.trvid

--旅游退款单
select tk.TrvId as 预算单号,tk.OperDate as 生成日期,tk.Price as 退款金额 
from  dbo.tbTrvKhTk tk
inner join dbo.tbTravelBudget bud ON tk.TrvId = bud.TrvId
WHERE  tk.OperDate>='2014-01-01' AND tk.OperDate<'2018-06-01' AND cwstatus='2' and bud.Status not in (1,2) and Tkstatus<>2


--②	2016/09/01-2016/09/30，会员的消费明细，机票（出票+退票）和酒店业务需要的数据：1.（机票出票）出票日期/销售单号/金额/收款状态/收款金额/欠款金额 2.（机票退票）退票审核日期/销售单号/应付金额/退票状态 3.（酒店）打印日期/销售单号/金额/收款状态/收款金额/欠款金额
--SELECT * FROM tbreti WHERE cmpcode=CHAR(10) ORDER BY ExamineDate
--UPDATE tbReti SET cmpcode='' WHERE cmpcode=CHAR(10)
--机票
SELECT  datetime as 出票日期,coupno as 销售单号,cash+cpay+bpay+vpay+epay as 付款金额,cowe as 抵充金额,CASE status WHEN 0 THEN '未付' WHEN 1 THEN '已付已到账' WHEN 3 THEN '未处理' WHEN 6 THEN '未付已到账' ELSE '' END as 收款状态,totprice as 收款金额,owe as 欠款金额
FROM tbcash 
WHERE datetime>='2018-05-01' AND datetime<'2018-06-01'
AND LEN(cmpcode)<6
AND	LEN(CASE WHEN coupno LIKE '000000%' OR coupno = 'AS000000000' THEN '' ELSE cmpcode END)=0
AND LEFT(CASE WHEN coupno LIKE '000000%' OR coupno = 'AS000000000' THEN 'D' 
			WHEN (cmpcode='' AND custid='') OR (ConventionYsId<>0 OR trvYsId<>0) THEN ''  ELSE custid END ,1) ='D'
--机票退票			
SELECT  reno as 退票单号,r.ExamineDate as 审核日期,r.coupno as 销售单号,r.totprice as 金额
,(CASE r.status2 WHEN 1 THEN '退票已提交' WHEN 2 THEN '退票已审核' WHEN 5 THEN '退票处理中' WHEN 6 THEN '退票已处理' WHEN 7 THEN '退票已结清' WHEN 8 THEN' 退票已锁定' WHEN 9 THEN '退票已冻结' ELSE '' END) as 退票状态
FROM dbo.tbReti r
INNER JOIN tbcash c ON r.coupno=c.coupno AND r.ticketno=c.ticketno
WHERE ExamineDate>='2018-05-01' AND ExamineDate<'2018-06-01' AND status2 NOT IN (3,4)
AND LEN(r.cmpcode)<6
AND	 (r.ConventionYsId=0 and r.trvYsId=0) 
--AND	LEN(CASE WHEN r.coupno LIKE '000000%' OR r.coupno = 'AS000000000' THEN '' ELSE r.cmpcode END)=0
--AND LEFT(CASE WHEN r.coupno LIKE '000000%' OR r.coupno = 'AS000000000' THEN 'D' 
			--WHEN (r.cmpcode='' AND r.custid='') OR (r.ConventionYsId<>0 OR r.trvYsId<>0) THEN ''  ELSE r.custid END ,1) ='D'
--酒店
SELECT prdate as 打印日期,CoupNo as 销售单号,c.cash+c.cpay+c.bpay+c.vpay+c.tepay [金额] ,(CASE c.cwstatus WHEN 0 THEN '未付' WHEN 1 THEN '已付已到账' WHEN 6 THEN '未付已到账' ELSE '' END) as 收款状态,price+fwprice-yhprice [收款金额],c.owe as 欠款金额
FROM dbo.tbHtlcoupYf 
LEFT JOIN dbo.tbhtlyfchargeoff c ON c.coupid = tbHtlcoupYf.id
WHERE prdate>='2018-05-01' AND prdate<'2018-06-01' and pstatus=1 and status<>-2 AND LEN(cmpid)<6
ORDER BY  coupno

--③	2016/09/01-2016/09/30，内采的消费明细，机票（出票+退票）和酒店业务需要的数据：1.（机票出票）出票日期/销售单号/金额/收款状态/收款金额/欠款金额 2.（机票退票）退票审核日期/销售单号/应付金额/退票状态 3.（酒店）打印日期/销售单号/金额/收款状态/收款金额/欠款金额
--机票
SELECT datetime as 出票日期,coupno as 销售单号,cash+cpay+bpay+vpay+epay as 付款金额,cowe as 抵充金额,CASE status WHEN 0 THEN '未付' WHEN 1 THEN '已付已到账' WHEN 3 THEN '未处理' WHEN 6 THEN '未付已到账' ELSE '' END as 收款状态,totprice as 收款金额,owe as 欠款金额
FROM tbcash 
WHERE datetime>='2018-05-01' AND datetime<'2018-06-01'
--AND custid<>'' 
AND	 (ConventionYsId<>0 OR trvYsId<>0) 
AND NOT ( coupno LIKE '000000%' OR coupno = 'AS000000000')

--退票
SELECT  r.ExamineDate as 审核日期,r.coupno as 销售单号,r.totprice as 金额
,(CASE r.status2 WHEN 1 THEN '退票已提交' WHEN 2 THEN '退票已审核' WHEN 5 THEN '退票处理中' WHEN 6 THEN '退票已处理' WHEN 7 THEN '退票已结清' WHEN 8 THEN' 退票已锁定' WHEN 9 THEN '退票已冻结' ELSE '' END) as 退票状态 
FROM dbo.tbReti r
INNER JOIN tbcash c ON r.coupno=c.coupno AND r.ticketno=c.ticketno
WHERE ExamineDate>='2018-05-01' AND ExamineDate<'2018-06-01' AND status2 NOT IN (3,4)
AND	 (r.ConventionYsId<>0 OR r.trvYsId<>0) 
--AND c.cmpcode=''
--AND	LEN(CASE WHEN r.coupno LIKE '000000%' OR r.coupno = 'AS000000000' THEN '' ELSE r.cmpcode END)=0
--AND LEFT(CASE WHEN r.coupno LIKE '000000%' OR r.coupno = 'AS000000000' THEN 'D' 
			--WHEN (r.cmpcode='' AND r.custid='') OR (r.ConventionYsId<>0 OR r.trvYsId<>0) THEN ''  ELSE r.custid END ,1) ='D'
			

--酒店（旅游）
SELECT prdate as 打印日期,CoupNo as 销售单号,c.cash+c.cpay+c.bpay+c.vpay+c.tepay [金额] ,(CASE c.cwstatus WHEN 0 THEN '未付' WHEN 1 THEN '已付已到账' WHEN 6 THEN '未付已到账' ELSE '' END) as 收款状态,price+fwprice-yhprice [收款状态],c.owe as 欠款金额
FROM dbo.tbHtlcoupYf t1
LEFT JOIN dbo.tbhtlyfchargeoff c ON c.coupid = t1.id
inner join tbTrvJS t2 on t1.id=t2.CoupId
WHERE prdate>='2018-05-01' AND prdate<'2018-06-01' and t1.pstatus=1 and status<>-2 AND cmpid=''
ORDER BY  coupno
--酒店（会务）
SELECT prdate as 打印日期,CoupNo as 销售单号,c.cash+c.cpay+c.bpay+c.vpay+c.tepay [金额] ,(CASE c.cwstatus WHEN 0 THEN '未付' WHEN 1 THEN '已付已到账' WHEN 6 THEN '未付已到账' ELSE '' END) as 收款状态,price+fwprice-yhprice [收款状态],c.owe as 欠款金额
FROM dbo.tbHtlcoupYf t1
LEFT JOIN dbo.tbhtlyfchargeoff c ON c.coupid = t1.id
inner join tbConventionJS t2 on t1.id=t2.CoupId
WHERE prdate>='2018-05-01' AND prdate<'2018-06-01' and t1.pstatus=1 and status<>-2 AND cmpid=''
ORDER BY  coupno






--④	担保状态为：担保中或者是担保金可退回的机票、酒店、旅游、会务、签证的金额。需求数据：单位编号、单位名称、销售单号（或预算单号）、金额、担保时间
--（注：金额仅为担保中或可退回金额，非最初担保金额——担保金额中会有部分已退回）
IF OBJECT_ID('tempdb.dbo.#r') IS NOT NULL DROP TABLE #r
SELECT BillNo,ISNULL(c1.cmpcode,ISNULL(c3.cmpid,'')) AS cmpid,ISNULL(c1.custid,ISNULL(c3.custid,'')) AS custid,t2.CoupNo,t1.DepositMoney
,ISNULL(c1.status,ISNULL(c3.status2,-99)) AS STATUS
,t2.TypeId,t2.TbCashId,c1.ticketno,t1.CreateDate
INTO #r
FROM Guarantees t1
INNER JOIN dbo.GuaranteesTbCash t2 ON t1.BillId = t2.BillId
LEFT JOIN tbcash c1 ON t2.TbCashId=c1.id AND t2.CoupNo=c1.coupno
LEFT JOIN dbo.tbHtlcoupYf c3 ON t2.TbCashId=c3.id AND t2.CoupNo=c3.CoupNo
WHERE t1.StatusId=1 AND t1.IsDisplay=1 AND t2.IsDisplay=1 --AND c1.id IS NULL AND c3.id IS NULL

SELECT BillNo as 流水号,r.cmpid as 单位编号,r.custid as 会员编号,r.CoupNo as 销售单号,r.DepositMoney as 总金额,isnull(c.totprice,0)  as 机票明细,isnull(t.totprice,0) as 退票金额,isnull(yf.price,0) as 酒店明细,r.ticketno as 票号,r.CreateDate as 担保时间
,CASE WHEN TypeId=1 AND r.STATUS<>1 THEN '担保中' WHEN TypeId=1 AND r.STATUS=1 THEN '担保金可退回' 
	WHEN TypeId=2 AND r.STATUS<>1 THEN '担保中' WHEN TypeId=2 AND r.STATUS=1 THEN '担保金可退回' 
	ELSE '' END as 担保状态
	FROM #r r
	left join tbcash c on c.ticketno=r.ticketno
	left join tbReti t on t.reno=c.reti
left join tbHtlcoupYf yf on yf.CoupNo=r.coupno
order by BillNo




--⑤	垫付状态为：已垫付的机票、酒店的金额。需求数据：单位编号、单位名称、销售单号（或预算单号）、金额、担保时间、除去已退款的
SELECT CASE WHEN dbo.tbCompanyM.cmpid IS NOT NULL THEN 'UC'+cmpcode ELSE cus.custid END,ISNULL(dbo.tbCompanyM.cmpname,cus.custname),tc.coupno,pay.Price,tc.totprice,TcPayDate as 担保时间 ,datetime
,red.AppDate as 退款时间
FROM tbcash tc
left join GuaranteesTbCash c on  c.TbCashId=tc.id
left join Guarantees g on g.BillId=c.BillId
LEFT JOIN dbo.tbCompanyM ON tc.cmpcode<>'' and tc.cmpcode=tbCompanyM.cmpid 
LEFT JOIN dbo.tbCusholder cus ON tc.cmpcode='' AND tc.custid=cus.custid
LEFT JOIN dbo.HM_CurrentPaymentRefund red on red.CoupNo=tc.coupno
left join dbo.PayDetail pay on pay.ysid=tc.BaokuID 
WHERE AdvanceStatus=1 and pay.payperson=2 and tc.coupno not like ('%000000%') and pay.Pstatus<>0




---要去重
--ECXEL-选中全部-数据-删除重复项


SELECT CASE WHEN dbo.tbCompanyM.cmpid IS NOT NULL THEN 'UC'+o.CMPID ELSE cus.custid END,ISNULL(dbo.tbCompanyM.cmpname,cus.custname),o.CoupNo,TotalPrice,o.AdvanceDate
,red.AdvanceReturnDate as 退款时间
FROM HotelOrderDB..HTL_Orders o
LEFT JOIN dbo.tbCompanyM ON ISNULL(o.CMPID,'')<>'' and o.CMPID=tbCompanyM.cmpid 
LEFT JOIN dbo.tbCusholder cus ON ISNULL(o.CMPID,'')='' AND o.custid=cus.custid
left join dbo.tbHtlcoupRefund red on red.CoupNo=o.CoupNo
WHERE o.AdvanceStatus=3 AND o.Status<>91


--⑥：从2016.04至2017.02.28未付款的消费明细
--机票
SELECT  datetime as 出票日期,coupno as 销售单号,cash+cpay+bpay+vpay+epay as 付款金额,cowe as 抵充金额,CASE status WHEN 0 THEN '未付' WHEN 1 THEN '已付已到账' WHEN 3 THEN '未处理' WHEN 6 THEN '未付已到账' ELSE '' END as 收款状态,totprice as 收款金额,owe as 欠款金额
,pform as 结算方式
FROM tbcash 
WHERE datetime>='2016-04-01' AND datetime<'2018-06-01'
AND LEN(cmpcode)<6
AND	LEN(CASE WHEN coupno LIKE '000000%' OR coupno = 'AS000000000' THEN '' ELSE cmpcode END)=0
--AND LEFT(CASE WHEN coupno LIKE '000000%' OR coupno = 'AS000000000' THEN 'D' 
			--WHEN (cmpcode='' AND custid='') OR (ConventionYsId<>0 OR trvYsId<>0) THEN ''  ELSE custid END ,1) ='D'
			and status=0
			--and pform='现结'
--机票退票			
SELECT  r.ExamineDate as 审核日期,r.coupno as 销售单号,r.totprice as 金额
,(CASE r.status2 WHEN 1 THEN '退票已提交' WHEN 2 THEN '退票已审核' WHEN 5 THEN '退票处理中' WHEN 6 THEN '退票已处理' WHEN 7 THEN '退票已结清' WHEN 8 THEN' 退票已锁定' WHEN 9 THEN '退票已冻结' ELSE '' END) as 退票状态
FROM dbo.tbReti r
INNER JOIN tbcash c ON r.coupno=c.coupno AND r.ticketno=c.ticketno
WHERE ExamineDate>='2016-04-01' AND ExamineDate<'2018-06-01' AND status2 NOT IN (1,3,4,7)
AND LEN(r.cmpcode)<6
--and c.pform='现结'
--AND	LEN(CASE WHEN r.coupno LIKE '000000%' OR r.coupno = 'AS000000000' THEN '' ELSE r.cmpcode END)=0
--AND LEFT(CASE WHEN r.coupno LIKE '000000%' OR r.coupno = 'AS000000000' THEN 'D' 
			--WHEN (r.cmpcode='' AND r.custid='') OR (r.ConventionYsId<>0 OR r.trvYsId<>0) THEN ''  ELSE r.custid END ,1) ='D'
--酒店
SELECT prdate as 打印日期,CoupNo as 销售单号,c.cash+c.cpay+c.bpay+c.vpay+c.tepay [金额] ,(CASE c.cwstatus WHEN 0 THEN '未付' WHEN 1 THEN '已付已到账' WHEN 6 THEN '未付已到账' ELSE '' END) as 收款状态,price+fwprice-yhprice [收款金额],c.owe as 欠款金额
FROM dbo.tbHtlcoupYf 
LEFT JOIN dbo.tbhtlyfchargeoff c ON c.coupid = tbHtlcoupYf.id
WHERE prdate>='2016-04-01' AND prdate<'2018-06-01' and pstatus=1 and status<>-2 AND LEN(cmpid)<6
and c.cwstatus=0
--and sform='现结'
ORDER BY  coupno
 
 
 
 --其他
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
where ExamineDate >= '2018-05-01' and ExamineDate <'2018-06-01' 
and tbreti.status2 not in(1,3,4) 
group by tbreti.cmpcode,cmpname
ORDER BY tbReti.cmpcode 



--火车票业务消费明细
--火车票出票
--select FLOOR(isnull(sum(RealPrice + Fuprice + PrintPrice),0)) as xprice,FLOOR(isnull(Sum(Fuprice - CASE Tsource WHEN '铁友网' THEN 5 ELSE 0 END),0)) as xtotprofit 
SELECT trainO.CmpId as UC号,trainO.CoupNo as 销售单号,trainO.CreateDate as 出票日期,RealPrice [票面价],
Fuprice+PrintPrice AS [服务费],PrintPrice [送票费],Tsource [票源],RealPrice+Fuprice+PrintPrice AS [应收客户款项],
RealPrice+PrintPrice+(CASE Tsource WHEN '铁友网'  THEN 5  when '七彩阳光' then 1 ELSE 0  END) AS [应付供应商款项]	
from tbTrainTicketInfo trainO INNER JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo 
where trainO.CreateDate between '2018-05-01' and '2018-05-31 23:59:59'  AND trainO.Isdisplay=0 
AND trainO.TrainWebNo not LIKE '%改签%'
UNION all
SELECT trainO.CmpId as UC号,trainO.CoupNo as 销售单号,trainO.CreateDate as 出票日期,RealPrice [票面价],
Fuprice+PrintPrice AS [服务费],PrintPrice [送票费],Tsource [票源],RealPrice+Fuprice+PrintPrice AS [应收客户款项],
RealPrice+PrintPrice+(CASE Tsource WHEN '铁友网'  THEN 5   ELSE 0  END) AS [应付供应商款项]	
from tbTrainTicketInfo trainO INNER JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo 
where trainO.CreateDate between '2018-05-01' and '2018-05-31 23:59:59'  AND trainO.Isdisplay=0 
AND trainO.TrainWebNo  LIKE '%改签%'

--火车票退票
--select -FLOOR(isnull(sum(trainU.RealPrice+r.Fee),0)) as xprice,FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0)) as xtotprofit 
SELECT trainO.CmpId as UC号,trainO.CoupNo as 销售单号,r.AuditTime as 退票日期,trainO.Tsource as 票源,trainU.RealPrice as 票面价,r.Fee as 收客户退票费,r.SupplierFee as 收供应商退票费,r.Fee-trainU.RealPrice  [应收客户款项],r.SupplierFee-trainU.RealPrice  [应付供应商款项]
,r.ModifyBillNumber as 账单号,r.ID as 退票单号
from Train_ReturnTicket r INNER JOIN tbTrainUser trainU ON r.TickOrderDetailID = trainU.ID
INNER JOIN dbo.tbTrainTicketInfo trainO ON trainO.ID = trainU.TrainTicketNo 
where r.AuditTime between '2018-05-01' and '2018-05-31 23:59:59'  AND trainO.Isdisplay=0 


--酒店销售单税金
SELECT yf.cmpid as 单位编号,m.cmpname as 单位名称,CoupNo as 销售单号,InvoiceTax as 税金
  FROM [Topway].[dbo].[tbHtlcoupYf] yf
  left join tbCompanyM m on m.cmpid=yf.cmpid
  where prdate>='2018-05-01' and prdate<'2018-06-01'
  and InvoiceTax<>0
  
--酒店开专票明细
select info.CMPID as 单位编号,m.cmpname as 单位名称 
from  CompanyInvoiceInfo info
inner join tbCompanyM m on m.cmpid=info.CMPID
where info.HotelInvoiceType like ('%2%')
