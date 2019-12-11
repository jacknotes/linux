--机票销量、利润、张数
select t1.cmpid as 单位编号,t1.cmpname as 单位名称
--,(case CustomerType when 'A' then '差旅单位客户' when 'C' then '旅游单位客户' else '' end) as 单位类型
--,(CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END) as 合作状态
,(t9.Name)  as 开发人

--,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as 机票销量
--,sum(h1.price) as 酒店销量
--,SUM(l1.XsPrice) as 旅游销量
--,SUM(c1.XsPrice) as 会务销量
--,FLOOR(isnull(sum(RealPrice + trainU.Fuprice + PrintPrice),0)) -FLOOR(isnull(sum(trainU.RealPrice+r.Fee),0)) as 火车票销量
--,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as 机票利润
--,sum(h1.totprofit) as 酒店利润
--,SUM(l1.Profit) as 旅游利润
--,sum(c1.Profit) as 会务利润
--,FLOOR(isnull(Sum(trainU.Fuprice - CASE Tsource WHEN '铁友网' THEN 5 when '七彩阳光' then 1 ELSE 0 END),0))+ FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0))as 火车票利润
--,COUNT(1) as 张数
 from tbCompanyM t1
--机票
--left join tbcash t3 on t3.cmpcode=t1.cmpid
--left join tbreti t2 on t3.coupno=t2.coupno
--酒店
--left join tbHtlcoupYf h1 on h1.cmpid=t1.cmpid and h1.status2<>-2
--left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
--旅游
--left join tbTrvCoup l1 on l1.Cmpid=t1.cmpid
--会务
--left join tbConventionCoup c1 on c1.Cmpid=t1.cmpid
--火车票
--left join tbTrainTicketInfo trainO on trainO.CmpId=t1.cmpid
--LEFT JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo
--left join Train_ReturnTicket r on r.TickOrderDetailID = trainU.ID
--TMS
left join homsomdb..Trv_UnitCompanies t4 on t1.cmpid=t4.Cmpid
--开发人
left join homsomDB..Trv_UnitCompies_Sales t5 on t4.ID=t5.UnitCompayID
--人员信息
left join homsomDB..SSO_Users t9 on
t9.ID=t5.EmployeeID 
where 
t9.Name in ('胡启霏','沈正邦','谈嘉巍','万方','彭永飞','马骏','王绅元','楼兆罡','彭庆华','范文涛','张永方','姜从余')
--and hztype<>0
--and hztype<>4
and (t1.indate>='2017-01-01' and t1.indate<'2017-04-01') 
--and (t3.datetime>='2017-01-01' and t3.datetime<'2017-04-01') 
--and (h1.prdate>='2017-01-01' and h1.prdate<'2017-04-01')  
--and (l1.OperDate>='2017-01-01' and l1.OperDate<'2017-04-01')
--and (c1.OperDate>='2017-01-01' and c1.OperDate<'2017-04-01')           
--and (trainO.CreateDate>='2017-01-01' and trainO.CreateDate<'2017-04-01')
--and (r.AuditTime >='2017-01-01' AND r.AuditTime<'2017-04-01')
--and trainO.Isdisplay=0
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,t9.Name
order by t1.cmpid

