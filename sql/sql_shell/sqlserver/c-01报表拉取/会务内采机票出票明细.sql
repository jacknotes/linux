--会务预算单449内才机票明细
select t1.datetime as 出票日期,t1.coupno as 电子销售单号,tickettype as 票类型,t_source as 供应商来源,recno as PNR,tcode,t1.ticketno as 票号,begdate as 起飞日期,pasname as 乘客姓名,t1.cmpcode as 单位编号,t3.mobilephone as 手机号码,t1.route as 航程,nclass as 舱位,stotsprice as 全价,t1.totprice as 销售价,t1.price as 销售单价,tax as 税收,xfprice as 前反,totsprice as 结算价,t1.disct as 促销积点,t1.profit as 利润,Mcost as 资金费用,coupon as 优惠金额,fuprice as 服务费,t1.[status] as 状态,flightno as 航班号,t1.sales as 业务顾问,SpareTC as 操作业务顾问,reti as 退票单号,t4.rtprice as 退票费,t1.quota1 as 定额代理费  from tbcash t1
left join tbConventionJS t2 on t2.Id=t1.ConventionYsId
left join tbCusholder t3 on t1.custid=t3.custid
left join tbReti t4 on t4.reno=t1.reti
where ConventionId=449
order by t1.coupno

select * from tbConventionjs where ConventionId=449 order by id
