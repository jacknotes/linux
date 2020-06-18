select cmpcode as 单位编号,m.cmpname as 单位名称,datetime as 出票日期,begdate as 起飞时间,pasname as 乘机人,idno as 证件号,t2.sales as 所属业务顾问
,case INF when 0 then '国内' when 1 then '国际' else '' end as 类型
,coupno as 销售单号,price as 销售单价,totsprice as 结算价,tax as 税收,totprice as 销售价,xfprice as 前返,coupon as 优惠金额,fuprice as 服务费
,bpprice as 正常积点,feiyong as 申请费用,disct as 促销费,manager as 管理费,Mcost as 资金费用,HKPrice as 换开费,quota1 as 定额费
,profit-Mcost as 销售利润,tcode+ticketno as 票号,nclass as 舱位,t1.TicketOperationRemark as 人工出票原因,t3.RV_Cnname as 特殊票价,t_source as 供应商来源
,SpareTC as 操作业务顾问,t2.route as 航程,ride+flightno as 航班号,t2.reti as 退票单号 
from homsomDB..Trv_DomesticTicketRecord t1
left join tbcash t2 on t2.coupno=t1.RecordNumber
left join HM_Reimbursementvouchers t3 on t3.RV_id=t2.baoxiaopz
left join tbCompanyM m on m.cmpid=t2.cmpcode
where  (t2.datetime>='2018-04-01' and t2.datetime<'2018-05-01')
and t2.cmpcode in ('')
