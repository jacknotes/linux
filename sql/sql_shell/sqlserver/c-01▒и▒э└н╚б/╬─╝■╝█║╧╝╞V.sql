/*
 查询条件：
     1、起飞日期：2018年1月1日至3月31日
     2、承运人:MU和FM
     3、舱位：SHEET1  U F P J C D I Q
                 SHEET2 舱位不限
     4、销售单类型：电子票
    5、扣除退票 扣除结算价为0
 
     报表要求：
     文件价合计、 业务顾问

*/

SELECT coupno as 销售单号,tcode+ticketno as 票号,route as 行程,nclass as 舱位,begdate as 首段出行日期,totsprice as '文件价(含税)' ,sales as 业务顾问 from Topway..tbcash 
where begdate>='2018-01-01' and begdate<'2018-04-01' and ride in ('MU','FM') and tickettype ='电子票' and reti='' and totsprice<>0 --and nclass in ('U','F','P','J','C','D','I','Q')
 and inf=1
order by begdate