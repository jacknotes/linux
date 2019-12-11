--UC019688上海畅星软件有限公司
select datetime as 出票日期,begdate as 起飞日期,coupno as 销售单号,pasname as 乘客姓名,route as 线路,ride+flightno as 航班号,
tcode+ticketno as 票号,price as 销售单价,tax as 税收,fuprice as 服务费,totprice as 销售价,reti as 退票单号
from Topway..tbcash 
where cmpcode='019688'
and (datetime>='2018-01-01' and datetime<'2019-01-01')
and inf=1
--and tickettype='电子票'
--and route not in('改期','升舱')
--and t_source not in('改期','升舱')
order by datetime

--重开打印
select Pstatus,PrintDate,* from Topway..HM_tbReti_tbReFundPayMent 
--update Topway..HM_tbReti_tbReFundPayMent  set Pstatus=0,PrintDate='1900-01-01'
where Id='703679'

--删除到账认领
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money in('24168','50129','1195') and date='2019-03-07'

--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno='AS002266755'

--修改旅游预算单
select Sales,OperName,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Sales='成超雯',OperName='0670成超雯'
where TrvId='029647'

--UC020202裕力富食品（上海）有限公司
--国内
select datetime as 出票日期,begdate as 起飞日期,coupno as 销售单号,pasname as 乘客姓名,route as 线路,ride+flightno as 航班号,
tcode+ticketno as 票号,price as 销售单价,tax as 税收,fuprice as 服务费,totprice as 销售价,reti as 退票单号
from Topway..tbcash 
where cmpcode='020202'
and (datetime>='2018-01-01' and datetime<'2019-01-01')
and inf=0
--and tickettype='电子票'
--and route not in('改期','升舱')
--and t_source not in('改期','升舱')
order by datetime

--国际
select datetime as 出票日期,begdate as 起飞日期,coupno as 销售单号,pasname as 乘客姓名,route as 线路,ride+flightno as 航班号,
tcode+ticketno as 票号,price as 销售单价,tax as 税收,fuprice as 服务费,totprice as 销售价,reti as 退票单号
from Topway..tbcash 
where cmpcode='020202'
and (datetime>='2018-01-01' and datetime<'2019-01-01')
and inf=1
--and tickettype='电子票'
--and route not in('改期','升舱')
--and t_source not in('改期','升舱')
order by datetime

--保险
select datetime as 出票日期,begdate as 起飞日期,coupno as 销售单号,pasname as 乘客姓名,route as 线路,ride+flightno as 航班号,
tcode+ticketno as 票号,price as 销售单价,tax as 税收,fuprice as 服务费,totprice as 销售价,reti as 退票单号
from Topway..tbcash 
where cmpcode='020202'
and (datetime>='2018-01-01' and datetime<'2019-01-01')
and inf=-1
--and tickettype='电子票'
--and route not in('改期','升舱')
--and t_source not in('改期','升舱')
order by datetime

--孙雯洁名下的所有客户
select  Cmpid UC,Name 公司名称 from homsomDB..Trv_UnitCompanies 
where Cmpid in (select Cmpid from Topway..HM_AgreementCompanyTC where TcName='孙雯洁' and isDisplay=0)
and CooperativeStatus in ('1','2','3')


select top 10 * from homsomDB..Trv_UnitCompanies
select top 10 * from homsomDB..SSO_Users where Name='孙雯洁'

select * from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_TrvUnitCompanies_TrvTCs t on t.TrvUnitCompanyID=u.ID
left join homsomDB..SSO_Users s on s.ID=t.TrvTCID

--017680 更名为上海国芮信息科技有限公司
--select * from Topway..tbCompanyM where cmpid='017680'
--select * from homsomDB..Trv_UnitCompanies where Cmpid='017680'
select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement set CompanyNameCN='上海国芮信息科技有限公司'
where BillNumber='017680_20190301' 


