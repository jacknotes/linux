--火车票销售价信息
select TotPrice,TotFuprice,TotUnitprice,TotSprice,* from Topway..tbTrainTicketInfo 
--update Topway..tbTrainTicketInfo  set TotPrice=TotPrice-380,TotUnitprice=TotUnitprice-380,TotSprice=TotSprice-380
where CoupNo='RS000026052'

select RealPrice,Fuprice,SettlePrice,* from Topway..tbTrainUser 
--update Topway..tbTrainUser  set RealPrice=RealPrice-380,SettlePrice=SettlePrice-380
where TrainTicketNo=(Select ID from Topway..tbTrainTicketInfo where CoupNo='RS000026052')

--火车票销售价信息
select TotPrice,TotFuprice,TotUnitprice,TotSprice,* from Topway..tbTrainTicketInfo 
--update Topway..tbTrainTicketInfo  set TotFuprice=TotFuprice+10,TotPrice=TotPrice+10
where CoupNo in('RS000025244','RS000025245','RS000025246','RS000025248','RS000025247')

select RealPrice,Fuprice,SettlePrice,* from Topway..tbTrainUser 
--update Topway..tbTrainUser  set Fuprice=Fuprice+10
where TrainTicketNo in(Select ID from Topway..tbTrainTicketInfo 
where CoupNo in('RS000025244','RS000025245','RS000025246','RS000025248','RS000025247'))

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='员工垫付（王贞工行卡）'
where CoupNo in('PTW085611','PTW085613','PTW085614','PTW085615','PTW085616','PTW085617')

/*
UC017415杜福睿（上海）商业有限公司 
2019 1月--5月  MU/FM 国内机票 原价 销售单价 税收 销售总价 服务费 优惠金额
2019 1月---5月 所有国际机票，销售单价 税收 销售总价 服务费 前返金额
*/
select cmpcode UC号,coupno 销售单号,originalprice 原价,price 销售单价,tax 税收,totprice 销售总价,fuprice 服务费,originalprice-price 优惠金额
from Topway..tbcash 
where cmpcode='017415'
and datetime>='2019-01-01'
and datetime<'2019-06-01'
and ride in('mu','fm')
and inf=0
order by datetime

select cmpcode UC号,coupno 销售单号,price 销售单价,tax 税收,totprice 销售总价,fuprice 服务费,xfprice 前返金额
from Topway..tbcash 
where cmpcode='017415'
and datetime>='2019-01-01'
and datetime<'2019-06-01'
and inf=1
order by datetime

--酒店销售单重开打印权限
select pstatus,prdate,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set pstatus=0,prdate-'1900-01-01'
where CoupNo='PTW085398'


select IsJoinRank,* from Topway..Emppwd 
--update Topway..Emppwd  set IsJoinRank=1
where idnumber in('0738','0739','0740')

select employeeId,* from Topway..Emppwd 
--update Topway..Emppwd  set employeeId=136
where idnumber in('0740')


--麻烦添加 乘机人，起飞日期 线路 舱位代码 折扣率
select coupno,pasname 乘机人,begdate 起飞日期,route 线路,nclass 舱位代码,price/priceinfo  折扣率
from Topway..tbcash
where coupno in('AS002169827',
'AS002178346',
'AS002220532',
'AS002228321',
'AS002261871',
'AS002261873',
'AS002305549',
'AS002305551',
'AS002323290',
'AS002331243',
'AS002344920',
'AS002344922',
'AS002350639',
'AS002350643',
'AS002385912',
'AS002401047',
'AS002401049',
'AS002404962',
'AS002422427',
'AS002424897',
'AS002437537',
'AS002515185',
'AS002515185',
'AS002515185')
order by coupno

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='016500_20190501'

--重开打印
select SettleStatus,Pstatus,PrDate,PrName,* from Topway..tbTrvSettleApp 
--update Topway..tbTrvSettleApp  set SettleStatus=1,Pstatus=0,PrDate='1900-01-01',PrName=''
where Id='27618'

select SettleStatus,Pstatus,PrDate,PrName,* from Topway..tbConventionSettleApp 
--update Topway..tbConventionSettleApp  set SettleStatus=1,Pstatus=0,PrDate='1900-01-01',PrName=''
where Id='3948'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='黄怡丽',SpareTC='黄怡丽' 
where coupno in('AS001750117','AS001782332')

/*
    麻烦你提取香港航空数据，谢谢 
 
    出票日期：2018年1月-2018年12月 ，2019年1月-2019年6月
    航空公司：HX
    
    报表要求: 日期、销售单号、票号、航程、舱位
*/
select convert(varchar(10),datetime,120) 出票日期,coupno 销售单号,tcode+ticketno 票号,route 航程,nclass 舱位,reti 退票单号
from Topway..tbcash 
where ride='hx'
and datetime>='2018-01-01'
order by 出票日期

--机票业务顾问信息
SELECT Sales,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set Sales='倪颖'
where coupno in('PTW084575','PTW084460','PTW083761','PTW084110','PTW084707')

--退票付款单
select Pstatus,PrintDate,* from Topway..HM_tbReti_tbReFundPayMent 
--update Topway..HM_tbReti_tbReFundPayMent  set Pstatus=1,PrintDate=GETDATE()
where Id='703830'

--旅游收款信息
select vpayinfo,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set vpayinfo='微信'
where TrvId='30336' and Id='228487'

--销售单拆分16个
select MobileList,CostCenter,pcs,Department,* from topway..tbFiveCoupInfosub
--update topway..tbFiveCoupInfosub set MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='16',Department='无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无' 
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002592758')


--补票号
--select pasname,* from Topway..tbcash where coupno='AS002592758'
--update Topway..tbcash set pasname='',tcode='',ticketno='' where coupno='' and pasname=''

