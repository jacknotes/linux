--改成未阅和应收会计未审核
select haschecked,state,* from Topway..FinanceERP_ClientBankRealIncomeDetail 
--update Topway..FinanceERP_ClientBankRealIncomeDetail  set state=5,haschecked=0
where money='2200' and date='2019-06-05'

  
/*
1、销售新客户旅游会务。10月1日之前录入预算单计提利润      ，10月1日之后录入预算单计提利润。

2、 会务顾问计提利润中10月份录预算单的是否有。10月1日之前录入预算单计提利润，10月1日之后录入预算单计提利润。
*/


IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as 单位编号,t1.cmpname as 单位名称
,(case CustomerType when 'A' then '差旅单位客户' when 'C' then '旅游单位客户' else '' end) as 单位类型
,(CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END) as 合作状态
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as 开发人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as 售后主管
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as 维护人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as 差旅业务顾问
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as 旅游业务顾问
,indate
into #cmp1
from tbCompanyM t1
left join homsomdb..Trv_UnitCompanies t4 on t1.cmpid=t4.Cmpid
--开发人
left join homsomDB..Trv_UnitCompies_Sales t5 on t4.ID=t5.UnitCompayID
--客户主管
left join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t4.ID=t6.UnitCompanyID
--维护人
left join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.UnitCompanyID=t4.ID
--旅游业务顾问
left join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t7.TrvUnitCompanyID=t4.ID
--差旅业务顾问
left join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t8.TktUnitCompanyID=t4.ID
--人员信息
left join homsomDB..SSO_Users t9 on
t9.ID=t5.EmployeeID and t9.ID=t6.EmployeeID and t9.ID=t8.TktTCID and t9.ID=t7.TrvTCID 
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid

--select * from #cmp1 where indate>='2018-01-01'

--旅游10月之后 新客户
select cmp1.开发人,SUM(DisCountProfit) as 计提利润 from tbTrvCoup c
inner join tbTravelBudget b on b.TrvId=c.TrvId
inner join #cmp1 cmp1 on cmp1.单位编号=c.Cmpid
where c.OperDate>='2019-05-01' and c.OperDate<'2019-06-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
and cmp1.indate>'2018-05-01'
group by cmp1.开发人
order by 计提利润 desc


--会务10月之后 新客户
select c.Sales  as 会务顾问,SUM(Profit) as 计提利润 from tbConventionCoup c
inner join tbConventionBudget b on b.ConventionId=c.ConventionId
inner join #cmp1 cmp1 on cmp1.单位编号=c.Cmpid
where c.OperDate>='2019-05-01' and c.OperDate<'2019-06-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
--and cmp1.indate>='2018-01-01'
group by c.Sales
order by 计提利润 desc

--会务10月之前 新客户
select cmp1.开发人,SUM(DisCountProfit)  as 计提利润 from tbConventionCoup c
inner join tbConventionBudget b on b.ConventionId=c.ConventionId
inner join #cmp1 cmp1 on cmp1.单位编号=c.Cmpid
where c.OperDate>='2019-05-01' and c.OperDate<'2019-06-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
and cmp1.indate>'2018-05-01'
group by cmp1.开发人
order by 计提利润 desc

--拉取一份会务运营部-崔之阳 张广寒 周寅啸，2019年5月份完成毕团的数据EXECL表
/*
1.毕团日期
2.预算单号
3.单位名称
4.供应商结算信息：供应商来源
5.会务顾问
6.资金费用
*/

select distinct c.OperDate 毕团日期,c.ConventionId 预算单号,u.Name 单位名称,GysSource 供应商来源,
Sales 会务顾问,FinancialCharges 资金费用
from Topway..tbConventionCoup c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.Cmpid
left join Topway..tbConventionJS j on j.ConventionId=c.ConventionId
where c.OperDate<'2019-06-01' and c.OperDate>='2019-05-01'
and Sales in ('崔之阳','张广寒','周寅啸')
and Status<>2
order by 毕团日期

--到账改成未阅
select haschecked,* from Topway..FinanceERP_ClientBankRealIncomeDetail 
--update Topway..FinanceERP_ClientBankRealIncomeDetail  set haschecked=0
where money='2200' and date='2019-06-05'

/*UC019293兄弟（中国）商业有限公司
 
请帮拉取该司2018/4/1-2019/4/30国内机票全价舱的出票数据，需要信息如下：
 
出票日期、乘客姓名、部门、路线、销售价、退票单号
 
*/
select convert(varchar(10),datetime,120) 出票日期,pasname 乘客姓名,Department 部门,route 路线,totprice 销售价,reti 退票单号,
tickettype 类型
from Topway..tbcash 
where cmpcode='019293'
and datetime>='2018-04-01'
and datetime<'2019-05-01'
and inf=0
and nclass='Y'
order by 出票日期


/*
 
现需要我们各组引导客户冲量进去。请帮忙提供“不开通特殊票价”的单位数据单独发给对应各组差旅运营经理，谢谢！
 
 UC号  单位名称     服务费    是否捆绑保险   MU近半年F ，J ，Y销量   MU近半年Y舱以下销量  差旅顾问  运营经理  客户经理
 
备注：自签二方三方的单位去除掉
陈永林  15:46:21
B M E K L N R S V T Z H

select * FROM [homsomdb].[dbo].[Trv_UCSettings]
  where BindAccidentInsurance is not null and BindAccidentInsurance <>''
*/

IF OBJECT_ID('tempdb.dbo.#company') IS NOT NULL DROP TABLE #company
SELECT 
u.Cmpid,
u.Name,
CASE WHEN ISNULL(BindAccidentInsurance,'')='' THEN '否' ELSE '是' END 是否捆绑保险
INTO #company
FROM homsomDB..Trv_UnitCompanies u 
LEFT JOIN homsomDB..Trv_UCSettings s ON u.UCSettingID=s.ID
WHERE 
IsSepPrice=0 --国内
AND CooperativeStatus NOT IN(0,4) AND u.Type='A'

IF OBJECT_ID('tempdb.dbo.#xlgaocang') IS NOT NULL DROP TABLE #xlgaocang
SELECT 
cmpcode,SUM(fuprice) as fuprice,SUM(totprice) AS totprice,SUM(price+tax) AS pricetax 
INTO #xlgaocang
FROM tbcash WHERE datetime BETWEEN '2019-01-01' AND '2019-06-30' AND cmpcode<>'' 
AND nclass IN('F','J','Y') AND cmpcode IN(SELECT cmpid FROM #company) AND inf IN('0')
GROUP BY cmpcode

IF OBJECT_ID('tempdb.dbo.#xldicang') IS NOT NULL DROP TABLE #xldicang
SELECT  cmpcode,SUM(totprice) AS totprice,SUM(price+tax) AS pricetax 
INTO #xldicang
FROM tbcash WHERE datetime BETWEEN '2019-01-01' AND '2019-06-30' AND cmpcode<>'' 
AND nclass IN('B','M','E','K','L','N','R','S','V','T','Z','H') AND cmpcode IN(SELECT cmpid FROM #company) AND inf IN('0')
GROUP BY cmpcode



IF OBJECT_ID('tempdb.dbo.#Final') IS NOT NULL DROP TABLE #Final
SELECT 'UC'+c.Cmpid AS '单位编号',
c.Name AS '单位名称',
c.是否捆绑保险,
CONVERT(DECIMAL(18,1),ISNULL(g.totprice,0)) AS '高仓销量',
CONVERT(DECIMAL(18,1),ISNULL(d.totprice,0))  AS '低舱销量',
t.TcName AS 差旅顾问,
h.MaintainName AS 运营经理,
h1.MaintainName AS 客户经理,
i.GroupName AS 小组名 
INTO #Final
FROM #company c
LEFT JOIN #xlgaocang g ON c.Cmpid=g.cmpcode
LEFT JOIN #xldicang d ON c.Cmpid=d.cmpcode
LEFT JOIN dbo.HM_AgreementCompanyTC t ON c.Cmpid=t.Cmpid AND t.isDisplay=0 AND t.TcType=0
LEFT JOIN dbo.HM_ThePreservationOfHumanInformation h ON c.Cmpid=h.Cmpid AND h.IsDisplay=1 AND h.MaintainType=9
LEFT JOIN dbo.HM_ThePreservationOfHumanInformation h1 ON c.Cmpid=h1.Cmpid AND h1.IsDisplay=1 AND h1.MaintainType=1
LEFT JOIN dbo.Emppwd e ON t.TcName=e.empname
LEFT JOIN dbo.HM_TCGroupInfo i ON e.groupid=i.Pkey
ORDER BY i.GroupName

--自签二方三方的单位
if OBJECT_ID('tempdb..#zq') is not null drop table #zq
select top 2172 convert(varchar(10),NewEndTime,120) 日期,NewEndTime,Cmpid 
into #zq
from homsomDB..Trv_FlightTripartitePolicies t
left join homsomDB..Trv_UnitCompanies u on u.ID=t.UnitCompanyID
where (t.Name like '%两方%' or t.Name like '%三方%' or t.Name like '%sme%' )
and u.Type='a' and u.CooperativeStatus not in ('0','4')
order by 日期 desc

SELECT * FROM #Final f WHERE f.单位编号 NOT IN(select 'UC'+CmpId from #zq) 

/*
出票日期2017.5.1-2018.8.31
UC019837迪安汽车部件（天津）有限公司
UC019847迪安汽车部件（天津）有限公司保定分公司
UC019836迪安汽车部件（天津）有限公司广州分公司
*/
select convert(varchar(10),datetime,120) 出票日期,begdate 起飞日期,pasname 乘机人,route 行程,ride+flightno 航班号,
case when inf=0 then '国内' when inf=1 then '国际' else '' end  国内或国际,price 销售单价,tax 税收,fuprice 服务费,
totprice 销售价,reti 退票单号,Department 部门,isnull(CostCenter,'') 成本中心,tcode+ticketno 票号,nclass 舱位
from Topway..tbcash 
where cmpcode='019836'
and datetime>='2017-05-01'
and datetime<'2018-09-01'
and inf in(1,0)
order by 出票日期


--UC020842 单位类型、结算方式、账单开始日期、新增月、注册 注册月改为2018年7月3日
select indate,* from Topway..tbCompanyM 
--update Topway..tbCompanyM  set indate='2018-07-03'
where cmpid='020842'

select RegisterMonth,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies  set RegisterMonth='07 03 2018  8:57AM'
where Cmpid='020842'


/*出票日期2018.7.1-2019.6.9，国内机票报销凭证目前为“大发票”，承运人“FM MU”的数据。
需要字段：UC号、国内销量，国内申请费金额，出票段数，国内申请费/国内销量的百分比（按此字段排序有高到低）
*/
select cmpcode UC号,SUM(totprice) 国内销量,SUM(originalprice-price) 国内申请费金额,COUNT(1 )出票张数,'' 国内申请费和国内销量的百分比
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies un on un.Cmpid=c.cmpcode
where CertificateD=2
and inf=0
and ride in('FM','mu')
and datetime>='2018-07-01'
and datetime<'2019-06-10'
group by cmpcode
order by 国内申请费和国内销量的百分比 desc


--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='018746_20190501'

select TrainBillStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set TrainBillStatus=1
where BillNumber='019358_20190401'

--会务收款单信息
select Skstatus,* from Topway..tbConventionKhSk
--update Topway..tbConventionKhSk set Skstatus=2
where ConventionId='1429' and Id='2747'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002532485','AS002531817','AS002533350','AS002533398')

--拉个数据020459这个单位下员工机票预订权限是所有预订的名单，拉好给到姚迪华

select h.Name from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
left join homsomDB..Trv_UPSettings up on u.UPSettingID=up.ID
left join homsomDB..Trv_BookingCollections b on b.ID=up.BookingCollectionID
where Cmpid='020459' and IsDisplay=1 and BookingType=3

--UC020316百隆家具配件（上海）有限公司
--麻烦拉取合作至今国际票数据
select datetime 出票日期,begdate 起飞日期,coupno,tcode+ticketno,pasname,route,totprice,reti,tickettype from Topway..tbcash 
where cmpcode='020316'
and inf=1
and begdate>='2019-06-01'
order by 起飞日期



--UC020543上海宇培（集团）有限公司  _20180901--20190501 MU/FM的数据，出票日期，起飞日期，舱位代码，乘客姓名，航班号，线路，销售单价，税收，销售总价，服务费,全价 折扣率。
select convert(varchar(10),datetime,120) 出票日期,begdate 起飞日期,nclass 舱位代码,pasname 乘客姓名,ride+flightno 航班号,route 线路,
price 销售单价,tax 税收,totprice 销售总价,fuprice 服务费,priceinfo 全价,'' 折扣率
from Topway..tbcash 
where cmpcode='020543'
and datetime>='2018-09-01'
and datetime<'2019-05-01'
and ride in('mu','fm')
order by 出票日期

/*UC018919
1，出票日2019年1月1号开始至2019年5年31号
 
2，需要知道有以上出票日期所有有特殊票价的单子，具体字段如下：
 
出票日期 电子销售单号 票号  乘客姓名  航程 舱位 销售单价 结算单价 销售利润   
*/
select datetime 出票日期,coupno 电子销售单号,tcode+ticketno 票号,pasname 乘客姓名,route 航程,nclass 舱位,price 销售单价,sprice1+sprice2+sprice3+sprice4 结算单价,profit 销售利润
from Topway..tbcash
where cmpcode='018919'
and datetime>='2019-01-01'
and datetime<'2019-06-01'
and baoxiaopz<>0
order BY 出票日期

--插入票号
--select pasname,* from Topway..tbcash where coupno='AS002537123'

update Topway..tbcash set tcode='057',ticketno='1433862213',pasname='CAO/GUILIANG' where coupno='AS002537123' and pasname='乘客0'
update Topway..tbcash set tcode='057',ticketno='1433862214',pasname='CHEN/HAIJUN' where coupno='AS002537123' and pasname='乘客1'
update Topway..tbcash set tcode='057',ticketno='1433862215',pasname='CUI/CHAOYU' where coupno='AS002537123' and pasname='乘客2'
update Topway..tbcash set tcode='057',ticketno='1433862216',pasname='DENG/XIJUN' where coupno='AS002537123' and pasname='乘客3'
update Topway..tbcash set tcode='057',ticketno='1433862217',pasname='DING/JIAPEI' where coupno='AS002537123' and pasname='乘客4'
update Topway..tbcash set tcode='057',ticketno='1433862218',pasname='FANG/XIAOJUN' where coupno='AS002537123' and pasname='乘客5'
update Topway..tbcash set tcode='057',ticketno='1433862219',pasname='GE/CHENGBING' where coupno='AS002537123' and pasname='乘客6'
update Topway..tbcash set tcode='057',ticketno='1433862220',pasname='LIU/YUAN' where coupno='AS002537123' and pasname='乘客7'
update Topway..tbcash set tcode='057',ticketno='1433862221',pasname='LU/RUIYONG' where coupno='AS002537123' and pasname='乘客8'
update Topway..tbcash set tcode='057',ticketno='1433862222',pasname='LUO/LIJUN' where coupno='AS002537123' and pasname='乘客9'
update Topway..tbcash set tcode='057',ticketno='1433862223',pasname='MA/XINGFU' where coupno='AS002537123' and pasname='乘客10'
update Topway..tbcash set tcode='057',ticketno='1433862224',pasname='SHAO/GAICI' where coupno='AS002537123' and pasname='乘客11'
update Topway..tbcash set tcode='057',ticketno='1433862225',pasname='SHEN/CHAOJUN' where coupno='AS002537123' and pasname='乘客12'
update Topway..tbcash set tcode='057',ticketno='1433862226',pasname='WEI/JIAN' where coupno='AS002537123' and pasname='乘客13'
update Topway..tbcash set tcode='057',ticketno='1433862227',pasname='WEI/YUQING' where coupno='AS002537123' and pasname='乘客14'
update Topway..tbcash set tcode='057',ticketno='1433862228',pasname='XIE/JINFENG' where coupno='AS002537123' and pasname='乘客15'
update Topway..tbcash set tcode='057',ticketno='1433862229',pasname='YAN/JINJIN' where coupno='AS002537123' and pasname='乘客16'
update Topway..tbcash set tcode='057',ticketno='1433862230',pasname='YUAN/SHOUYAO' where coupno='AS002537123' and pasname='乘客17'
update Topway..tbcash set tcode='057',ticketno='1433862231',pasname='YUE/ZHAOHUI' where coupno='AS002537123' and pasname='乘客18'
update Topway..tbcash set tcode='057',ticketno='1433862232',pasname='ZHANG/WANLONG' where coupno='AS002537123' and pasname='乘客19'
update Topway..tbcash set tcode='057',ticketno='1433862233',pasname='ZHANG/ZHIZHONG' where coupno='AS002537123' and pasname='乘客20'
update Topway..tbcash set tcode='057',ticketno='1433862234',pasname='ZHAO/JIANFENG' where coupno='AS002537123' and pasname='乘客21'
update Topway..tbcash set tcode='057',ticketno='1433862235',pasname='ZHI/RUIXIU' where coupno='AS002537123' and pasname='乘客22'
