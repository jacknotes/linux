/*出票日期2018.7.1-2019.6.9，国内机票报销凭证目前为“大发票”，承运人“FM MU”的数据。
需要字段：UC号、国内销量，国内申请费金额，出票段数，国内申请费/国内销量的百分比（按此字段排序有高到低）
*/

select cmpcode UC号,SUM(totprice) 国内销量,SUM(originalprice-price) 国内申请费金额,COUNT(1 )出票张数
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies un on un.Cmpid=c.cmpcode
where CertificateD=2
and inf=0
and ride in('FM','mu')
and datetime>='2018-07-01'
and datetime<'2019-06-10'
--and tickettype='电子票'
group by cmpcode
order by 国内销量


/*UC019707
 UC016682
 修改新增月
 */
 select depdate0,indate,Cmpid,* from Topway..tbCompanyM 
 --update Topway..tbCompanyM  set depdate0='2019-06-01'
 where cmpid in('019707')
 
 select AdditionMonthA,RegisterMonth,Cmpid,* from homsomDB..Trv_UnitCompanies 
 --update homsomDB..Trv_UnitCompanies  set AdditionMonthA='2019-06-01'
 where Cmpid in('019707')
 

--UC020543  上海宇培（集团）有限公司 新经办人吴燕飞让我们帮忙把这个抬头的2019年1-5月的账单根据他们这边的模板来导入并提交给她


select convert(varchar(10),datetime,120) 出票时间,convert(varchar(10),begdate,120)  起飞时间,Department,isnull(co.DepName,'') 部门,DATEDIFF(DD,datetime,begdate)提前出票天数,pasname 乘机人,route 行程,ride+flightno 航班号 
,tcode+ticketno 票号,priceinfo,'' 折扣率,price 销售单价,tax 税收,fuprice 服务费,totprice 销售价,reti 退票单号,tickettype 类型
from Topway..tbcash c with (nolock)
left join homsomDB..Trv_Human h on (h.Name=pasname or h.LastName+'/'+h.FirstName+h.MiddleName=pasname) and h.ID in(Select id from homsomDB..Trv_UnitPersons where CompanyID='D4FEB10C-36BC-4E43-B99D-A94A010FE8A0')
left join homsomDB..Trv_UnitPersons u on u.ID =h.ID
left join homsomDB..Trv_CompanyStructure co on co.ID=u.CompanyDptId
where ModifyBillNumber in('020543_20190101','020543_20190201','020543_20190301','020543_20190401','020543_20190501')
order by 出票时间

/*
UC020543上海宇培（集团）有限公司  _20180901--20190501 
① MU/FM航空，销售单号、票号、出票日期，起飞日期，舱位代码，乘客姓名，航班号，线路，销售单价，税收，销售总价，服务费、全价、 原价、折扣

②除MU/FM 其他同以上。
*/
select coupno 销售单号,tcode+ticketno 票号,convert(varchar(10),datetime,120) 出票时间,convert(varchar(10),begdate,120)  起飞时间,nclass 舱位代码,
pasname 乘客姓名,route 线路,price 销售单价,tax 税收,totprice 销售总价,fuprice 服务费,priceinfo 全价,originalprice 原价,'' 折扣率,reti 退票单号,tickettype 类型
from Topway..tbcash 
where cmpcode='020543'
and datetime>='2018-09-01'
and datetime<'2019-05-01'
and ride in ('mu','fm')
order by 出票时间

select coupno 销售单号,tcode+ticketno 票号,convert(varchar(10),datetime,120) 出票时间,convert(varchar(10),begdate,120)  起飞时间,nclass 舱位代码,
pasname 乘客姓名,route 线路,price 销售单价,tax 税收,totprice 销售总价,fuprice 服务费,priceinfo 全价,originalprice 原价,'' 折扣率,reti 退票单号,tickettype 类型
from Topway..tbcash 
where cmpcode='020543'
and datetime>='2018-09-01'
and datetime<'2019-05-01'
and ride not in ('mu','fm')
order by 出票时间

--修改退票审核日期
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti  set ExamineDate='2019-05-29'
where reno='9267103'

--行程单
SELECT info3,* from  Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno='AS002488145'


select ProccessDate,*
from HM_rptSalesNewlyProfit where Cmpid='019707'

--酒店结算单作废
select  settleStatus,pstatus,prdate,* from Topway..tbHtlSettlementApp 
--update Topway..tbHtlSettlementApp  set settleStatus=3
where  id='25960'

select settleno,pstatus,prdate,status2,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set settleno=null,status2=0
where settleno='25960'


--机票结算单作废
select settleStatus,* from topway..tbSettlementApp
--update topway..tbSettlementApp set settleStatus='3' 
where id='112934'

select wstatus,settleno,* from Topway..tbcash 
--update Topway..tbcash  set wstatus='0',settleno='0' 
where settleno='112934'

select Status,* from Topway..Tab_WF_Instance
--update Tab_WF_Instance set Status='4' 
where BusinessID='112934'


/*
请帮忙拉取2017年2月-2019年2月，操作差旅顾问是汪磊的个人客户信息。

需要明细：个人客户姓名，手机号，国内销售价合计，国内利润合计，国际销售价合计，国际利润合计
*/

select top 100 * from homsomDB..Trv_DomesticTicketRecord
select top 100 * from homsomDB..Trv_PnrInfos
select top 100 * from homsomDB..Trv_Passengers
select * from Topway..tbCusmem

select pasname,sum(totprice) 国内销售价合计,SUM(profit) 国内利润合计
from Topway..tbcash 
where SpareTC='汪磊'
and datetime>='2017-02-01'
and datetime<'2019-03-01'
and inf=1
and cmpcode=''
group by pasname


select pasname,mobile,sum(totprice) 国内销售价合计,SUM(profit) 国内利润合计
from Topway..tbcash c
left join Topway..tbCusmem t on t.idno=c.idno and name=pasname 
where SpareTC='汪磊'
and datetime>='2017-02-01'
and datetime<'2019-03-01'
and inf=1
and cmpcode=''
group by pasname,mobile

