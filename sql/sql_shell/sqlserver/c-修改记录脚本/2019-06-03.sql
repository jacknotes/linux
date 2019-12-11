--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='崔玉杰', SpareTC='崔玉杰'
where coupno='AS002517402'

--UC018110永诚财产保险股份有限公司
--机票账单请匹配下经济舱跟商务舱
select coupno,CabinClass,ride,nclass from Topway..tbcash where coupno in ('AS002441744',
'AS002445242',
'AS002445245',
'AS002445256',
'AS002449462',
'AS002449521',
'AS002449545',
'AS002453320',
'AS002453320',
'AS002463672',
'AS002465169',
'AS002465169',
'AS002465169',
'AS002468499',
'AS002468650',
'AS002468650',
'AS002468846',
'AS002468846',
'AS002469487',
'AS002469602',
'AS002469602',
'AS002472309',
'AS002472508',
'AS002472514',
'AS002475792',
'AS002476177',
'AS002477024',
'AS002477051',
'AS002479411',
'AS002479421',
'AS002479421',
'AS002479423',
'AS002479423',
'AS002479776',
'AS002480009',
'AS002480009',
'AS002480054',
'AS002480054',
'AS002480495',
'AS002482183',
'AS002482185',
'AS002485776',
'AS002487583',
'AS002490271',
'AS002490878',
'AS002492022',
'AS002493167',
'AS002494334',
'AS002494554',
'AS002497064',
'AS002499212',
'AS002499582',
'AS002504895',
'AS002504895',
'AS002505939',
'AS002505941',
'AS002506179',
'AS002506457',
'AS002507678',
'AS002508526',
'AS002511533',
'AS002513859',
'AS002515701',
'AS002518639',
'AS002518670',
'AS001642025')

--保险进位
select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash set sprice1=2
where coupno in ('AS002478032','AS002478492')


--UC019847 2017.5-2018.8周期迪安天津各航空公司国际及国内出票数量
select convert(varchar(7),datetime,120) 月份,ride 航司,route 行程,sum(totprice)销量,COUNT(1)张数,sum(fuprice) 合计服务费,sum(tax) 合计税收
from Topway..tbcash 
where cmpcode='019847'
--and datetime>='2017-05-01'
--and datetime<'2018-09-01'
and inf=0
group by ride,route,convert(varchar(7),datetime,120)
order by 月份

select convert(varchar(7),datetime,120) 月份,ride 航司,route 行程,sum(totprice)销量,COUNT(1)张数,sum(fuprice) 合计服务费,sum(tax) 合计税收
from Topway..tbcash 
where cmpcode='019847'
--and datetime>='2017-05-01'
--and datetime<'2018-09-01'
and inf=1
group by ride,route,convert(varchar(7),datetime,120)
order by 月份

--匹配预定人，差旅目的和reason code
select CoupNo,isnull(Purpose,''),isnull(ReasonDescription,''),h.Name from HotelOrderDB..HTL_Orders o
left join homsomDB..Trv_UnitPersons un on un.CustID=o.CustID
left join homsomDB..Trv_Human h on h.ID=un.ID
where CoupNo in ('PTW081681',
'PTW081971',
'PTW082030',
'PTW082121',
'PTW082251',
'PTW082367',
'PTW082449',
'PTW082448',
'PTW082447',
'PTW082439',
'PTW082539',
'PTW082600',
'PTW082659',
'PTW082640',
'PTW083552',
'PTW083551')

--修改出票日期
select datetime,indate,* from Topway..tbcash 
--update Topway..tbcash set datetime='2019-05-31',indate='2019-05-31 09:00:11.000'
where coupno='AS002519636'

--（产品专用）申请费来源/金额信息（国际）
select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash  set feiyong=0,feiyonginfo=''
where coupno='AS002520665'

--旅游预算单信息
select StartDate,EndDate,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set StartDate='2019-06-22',EndDate='2019-06-22'
where TrvId='30122'

--UC019505单位更名
select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement set CompanyNameCN='上海硅产业集团股份有限公司'
where BillNumber='019505_20190601'

--UC017122上海思创华信信息技术有限公司,麻烦按照我司常模模板提供客户合作至今的数据
select convert(varchar(7),[datetime],120) 出票月份,convert(varchar(10),datetime,120) 出票日期,begdate 起飞日期,coupno 销售单号,pasname 乘机人,route 行程,ride+flightno 航班号,tcode+ticketno 票号,priceinfo 全价,price/priceinfo 折扣率,
price 销售单价,tax 税收,fuprice 服务费,totprice 销售价,reti 退票单号
from Topway..tbcash
where cmpcode='017122' 
and inf<>-1
order by 出票月份

--修改核销日期和备注
select dzhxDate,oth2,* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='2019-05-31',oth2='5/31 内转 旅结27397抵充'
where coupno='AS002371150'

select dzhxDate,oth2,* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='2019-05-31',oth2='5/31 内转 旅结27397抵充'
where coupno='AS002371147'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='020852_20190501'

--保险进位
select sprice1,totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set sprice1='2.8',totsprice='2.8',profit=17
where coupno in ('AS002487231','AS002487364','AS002492794','AS002494194','AS002494195')

select sprice1,totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set sprice1='3.9',totsprice='3.9',profit=profit-1
where coupno in ('AS002510341','AS002510834','AS002510839','AS002511395','AS002512383','AS002512384',
'AS002512452','AS002512606','AS002513410','AS002513450','AS002513451','AS002514161','AS002515011','AS002515902',
'AS002516461','AS002517025','AS002518023','AS002518024','AS002518025','AS002518026','AS002518449','AS002518450',
'AS002519356')

select sprice1,totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set sprice1='4.2',totsprice='4.2'
where coupno in ('AS002490391','AS002491548')

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002517411','AS002519959')

select sprice1,totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set sprice1=20,totsprice=20,profit='-20'
where coupno='AS000000000' and ticketno='9578489449'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002517939')

--旅游预算单信息
select * from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Custid='D694071',Custinfo='15618509822@袁晓玲@016428@美国中央采购（国际）有限公司上海代表处@袁晓玲@15618509822@D694071',
where TrvId='30005'

--旅游预算单取消
select Status,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudge set Status=2
where TrvId='30194'


--销售单号：AS002510879，中航程由原：上海虹桥-青岛-上海虹桥， 修改为：上海浦东-青岛-上海浦东。 销售单号：AS002510829，中航程由原：上海虹桥-青岛-上海虹桥， 修改为：上海浦东-青岛-上海浦东
select * from Topway..tbcash 
--update Topway..tbcash  set route='上海浦东-青岛-上海浦东'
where coupno in('AS002510879','AS002510829')

select * from homsomDB..Trv_DomesticTicketRecord 
--update homsomDB..Trv_DomesticTicketRecord  set Route='上海浦东-青岛-上海浦东'
where RecordNumber in('AS002510879','AS002510829')

select *from homsomDB..Trv_Airport where Name like '%浦东%'

select OriginName,* from homsomDB..Trv_ItktBookingSegs 
--update homsomDB..Trv_ItktBookingSegs  set OriginName='浦东国际机场',DepartingAirport='PVG',Origin='PVG'
where ItktBookingID='5BC7873C-5FF8-4347-BECA-DAAD76BA6A28' 
and [Order]=1

select * from homsomDB..Trv_ItktBookingSegs 
--update homsomDB..Trv_ItktBookingSegs  set DestinationName='浦东国际机场',ArrivalAirport='PVG',Destination='PVG'
where ItktBookingID='5BC7873C-5FF8-4347-BECA-DAAD76BA6A28' 
and [Order]=2

--酒店销售单
--酒店销售单 销售总价 请调整为251 销售利润调整为251 
select price,sprice,totprofit,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set price='251',sprice='251',totprofit='251'
where CoupNo='PTW083768'

select totprice,owe,* from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set totprice='251',owe='251'
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo='PTW083768')

select TotalPrice,* from HotelOrderDB..HTL_Orders 
--update HotelOrderDB..HTL_Orders set TotalPrice='251'
where CoupNo='PTW083768'


--销售单号：PTW083759 销售总价 请调整为-2432 结算总价请调整为-1899.05 销售利润请调整为-303 
select price,sprice,totprofit,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set price='-2432',sprice='-1899.05',totprofit='-303'
where CoupNo='PTW083759'

select totprice,owe,* from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set totprice='-2432',owe='-2432'
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo='PTW083759')

select TotalPrice,* from HotelOrderDB..HTL_Orders 
--update HotelOrderDB..HTL_Orders set TotalPrice='-2432'
where CoupNo='PTW083759'


--出票日期:2019年3月-4月,退票审核日期在2019年5月的直加退票数据
--小组 差旅顾问 票号 退票单号 出票日期 审核日期

select team,SpareTC,c.tcode+c.ticketno,reno,c.datetime,ExamineDate from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join Topway..tbReti t on t.reno=c.reti
left join Topway..Emppwd e on SpareTC=e.empname
where c.datetime>='2019-03-01' and c.datetime<'2019-05-01'
and t.ExamineDate>='2019-05-01' and t.ExamineDate<'2019-06-01'
and TicketOperationRemark like '%直加%'
order by c.datetime