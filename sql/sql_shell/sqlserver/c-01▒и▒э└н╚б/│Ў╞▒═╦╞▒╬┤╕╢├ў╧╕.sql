
--出票
select  CASE WHEN tbCompanyM.cmpid IS NOT NULL THEN 'UC'+c.cmpcode ELSE cus.custid END
,c.datetime as 出票日期,c.coupno as 销售单号,c.tcode+c.ticketno as 票号,c.totprice as 销售价,c.reti as 退票单号
,(case c.status when 1 then '已付已到账' else '未付' end) as 收款状态
,(CASE r.status2 WHEN 1 THEN '退票已提交' WHEN 2 THEN '退票已审核' WHEN 5 THEN '退票处理中' WHEN 6 THEN '退票已处理' WHEN 7 THEN '退票已结清' WHEN 8 THEN' 退票已锁定' WHEN 9 THEN '退票已冻结' ELSE '' END) as 退票状态 
,r.totprice as 退票应付金额
,c.OriginalBillNumber as 账单号
,pform as 结算方式
,ExamineDate as 退票审核日期
from tbcash c
left join tbReti r on r.reno=c.reti
LEFT JOIN dbo.tbCompanyM ON c.cmpcode<>'' and c.cmpcode=tbCompanyM.cmpid 
LEFT JOIN dbo.tbCusholder cus ON c.cmpcode='' AND c.custid=cus.custid
where (c.datetime<'2016-04-01' and c.datetime>='2014-01-01')
and LEN(c.cmpcode)<6
and c.totprice<>0
and c.datetime<>'1900-01-01 00:00:00.000'
and c.coupno<>'00000000'
and c.coupno<>'AS000000000'
and c.coupno<>'000000'


UNION ALL
select  CASE WHEN tbCompanyM.cmpid IS NOT NULL THEN 'UC'+c.cmpcode ELSE cus.custid END
,c.datetime as 出票日期,c.coupno as 销售单号,c.tcode+c.ticketno as 票号,c.totprice as 销售价,c.reti as 退票单号
,(case c.status when 1 then '已付已到账' else '未付' end) as 收款状态
,(CASE r.status2 WHEN 1 THEN '退票已提交' WHEN 2 THEN '退票已审核' WHEN 5 THEN '退票处理中' WHEN 6 THEN '退票已处理' WHEN 7 THEN '退票已结清' WHEN 8 THEN' 退票已锁定' WHEN 9 THEN '退票已冻结' ELSE '' END) as 退票状态 
,r.totprice as 退票应付金额
,c.OriginalBillNumber as 账单号
,pform as 结算方式
,ExamineDate as 退票审核日期
from tbcash2013Prev c
left join tbReti r on r.reno=c.reti
LEFT JOIN dbo.tbCompanyM ON c.cmpcode<>'' and c.cmpcode=tbCompanyM.cmpid 
LEFT JOIN dbo.tbCusholder cus ON c.cmpcode='' AND c.custid=cus.custid
where (c.datetime<'2016-04-01' and c.datetime>='2014-01-01')
and LEN(c.cmpcode)<6
and c.totprice<>0
and c.coupno not in (Select coupno from tbcash)
and c.datetime<>'1900-01-01 00:00:00.000'
and c.coupno<>'00000000'
and c.coupno<>'AS000000000'
and c.coupno<>'000000'



--退票
select CASE WHEN tbCompanyM.cmpid IS NOT NULL THEN 'UC'+c.cmpcode ELSE cus.custid END
,c.datetime as 出票日期,c.coupno as 销售单号,c.tcode+c.ticketno as 票号,c.totprice as 销售价,c.reti as 退票单号
,(case c.status when 1 then '已付已到账' else '未付' end) as 收款状态
,(CASE r.status2 WHEN 1 THEN '退票已提交' WHEN 2 THEN '退票已审核' WHEN 3 THEN '审核未通过' WHEN 5 THEN '退票处理中' WHEN 6 THEN '退票已处理' WHEN 7 THEN '退票已结清' WHEN 8 THEN' 退票已锁定' WHEN 9 THEN '退票已冻结' ELSE '' END) as 退票状态 
,r.totprice as 退票应付金额
,c.OriginalBillNumber as 账单号
,pform as 结算方式
,ExamineDate as 退票审核日期
 from tbReti r 
left join tbcash c on c.reti=r.reno
LEFT JOIN dbo.tbCompanyM ON c.cmpcode<>'' and c.cmpcode=tbCompanyM.cmpid 
LEFT JOIN dbo.tbCusholder cus ON c.cmpcode='' AND c.custid=cus.custid
where (c.datetime<'2016-04-01' and c.datetime<'2014-01-01')
and r.status2 not in (4)
and r.totprice<>0
and LEN(c.cmpcode)<6
and c.datetime<>'1900-01-01 00:00:00.000'
and c.coupno<>'00000000'
and c.coupno<>'AS000000000'
and c.coupno<>'000000'
--and c.coupno in('00000000','AS000000000','000000')











select prdate as 打印日期,yf.CoupNo as 销售单号,price as 销售价 ,sform as 结算方式
--into #p2
from tbHtlcoupYf yf
where (prdate<'2016-04-01' and prdate>='2014-01-01')
and yf.status<>-2
--and cf.cwstatus=0
and LEN(yf.cmpid)<6
--and CoupNo  like ('%-%')

select * from #p2

select * from tbHtlcoupYf where CoupNo in (Select '-'+销售单号 from #p1)



select t1.TrvId as 预算单号,t1.Custid as 会员编号,TrvCoupNo as 销售单号,t2.XsPrice as 销售价,t1.OperDate as 录入时间,t2.OperDate as 闭团时间 from tbTravelBudget t1
left join tbTrvCoup t2 on t2.TrvId=t1.TrvId
where (t1.OperDate>='2014-01-01' and t1.OperDate<'2016-04-01')
and t1.Status<>2
and XsPrice<>0




