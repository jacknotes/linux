--锁定单位客户的旅游会务介绍人为homsom
select distinct CmpId,* from Topway..HM_ThePreservationOfHumanInformation where Cmpid in()  and IsDisplay='1'  and MaintainType='6' and MaintainName<>'HOMSOM'

--2018年机票频次和总消费
--国内
select route as 航程,t1.airname as 航司,COUNT(*) as 频次,SUM(totprice) as 销量 from Topway..tbcash t
left join ehomsom..tbInfAirCompany t1 on t1.code2=t.ride
where datetime>='2018-01-01' and datetime<'2019-01-01'  and inf=0 and cmpcode='019358'
group by route,t1.airname
order by 频次 desc
--国际
select route as 航程,t1.airname as 航司,COUNT(*) as 频次,SUM(totprice) as 销量 from Topway..tbcash t
left join ehomsom..tbInfAirCompany t1 on t1.code2=t.ride
where datetime>='2018-01-01' and datetime<'2019-01-01'  and inf=1 and cmpcode='019358'
group by route,t1.airname
order by 频次 desc

--账单撤销
SELECT SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState='1'
where CompanyCode='020237' and BillNumber='020237_20181201'

--账单撤销
SELECT SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState='1'
where CompanyCode='020350' and BillNumber='020350_20181201'

--特殊销售单修改
DELETE from Topway..tbcash where coupno='AS000000000' and ticketno='3422933153'

--（产品部专用）修改退票录入人
select opername,cpopername,* from Topway..tbReti 
--update Topway..tbReti set cpopername='翁景超'
where reno='0426338'

--账单uc更名
select CompanyNameCN,* from Topway..AccountStatement   
--update Topway..AccountStatement set CompanyNameCN='上海新新运科技有限公司'
where CompanyCode='019121' and BillNumber='019121_20190101'

select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement set CompanyNameCN='上海安法门诊部有限公司'
where CompanyCode='019843' and BillNumber='019843_20190101'

--机票
SELECT t1.RecordNumber,t5.Name 
FROM homsomDB..Trv_DomesticTicketRecord t1
left join homsomDB..Trv_PnrInfos t2 on t2.ID=t1.PnrInfoID
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t2.ItktBookingID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='审批'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.RecordNumber 
in('AS002146124',
'AS002146126',
'AS002146128',
'AS002146130',
'AS002146829',
'AS002148981',
'AS002153350',
'AS002159302',
'AS002159304',
'AS002161432',
'AS002162667',
'AS002162748',
'AS002162758',
'AS002162772',
'AS002162864',
'AS002162868',
'AS002162870',
'AS002162872',
'AS002162874',
'AS002162882',
'AS002162886',
'AS002162894',
'AS002162938',
'AS002162998',
'AS002163030',
'AS002163333',
'AS002163335',
'AS002164619',
'AS002164745',
'AS002164745',
'AS002164810',
'AS002164844',
'AS002165399',
'AS002165399',
'AS002165858',
'AS002166291',
'AS002166302',
'AS002166876',
'AS002167336',
'AS002167374',
'AS002167636',
'AS002171040',
'AS002171060',
'AS002171064',
'AS002171066',
'AS002171485',
'AS002171487',
'AS002171499',
'AS002171501',
'AS002171503',
'AS002171505',
'AS002171591',
'AS002171598',
'AS002171730',
'AS002172023',
'AS002172587',
'AS002172594',
'AS002172594',
'AS002172606',
'AS002172606',
'AS002172654',
'AS002172654',
'AS002172662',
'AS002172791',
'AS002175154',
'AS002175156',
'AS002178217',
'AS002178614',
'AS002178874',
'AS002178954',
'AS002179198',
'AS002179237',
'AS002179313',
'AS002179930',
'AS002180338',
'AS002180346',
'AS002180364',
'AS002181313',
'AS002182710',
'AS002182726',
'AS002182730',
'AS002183471',
'AS002184648',
'AS002184650',
'AS002184652',
'AS002184955',
'AS002184964',
'AS002185477',
'AS002185642',
'AS002186014',
'AS002186016',
'AS002186022',
'AS002186732',
'AS002186738',
'AS002186823',
'AS002186827',
'AS002186831',
'AS002187190',
'AS002188443',
'AS002188445',
'AS002188720',
'AS002190037',
'AS002192310',
'AS002197134',
'AS002197150',
'AS002197155',
'AS002197220',
'AS002197884',
'AS002197884',
'AS002197884',
'AS002198239',
'AS002198245',
'AS002198526',
'AS002198588',
'AS002198604',
'AS002199307',
'AS002199321',
'AS002199667',
'AS002199678',
'AS002199682',
'AS002199690',
'AS002199713',
'AS002199740',
'AS002199742',
'AS002199749',
'AS002199767',
'AS002199779',
'AS002199783',
'AS002199785',
'AS002199792',
'AS002199806',
'AS002199838',
'AS002200009',
'AS002200138',
'AS002200511',
'AS002200511',
'AS002200518',
'AS002200525',
'AS002200853',
'AS002201565',
'AS002201609',
'AS002202260',
'AS002202513',
'AS002202519',
'AS002202523',
'AS002205733',
'AS002205737',
'AS002205751',
'AS002205757',
'AS002205763',
'AS002205799',
'AS002205805',
'AS002205916',
'AS002206062',
'AS002206795',
'AS002206886',
'AS002208102',
'AS002208242',
'AS002208298',
'AS002208459',
'AS002209067',
'AS002209339',
'AS002209339',
'AS002209986',
'AS002210409',
'AS002210409',
'AS002210409',
'AS002210409',
'AS002213484',
'AS002216098',
'AS002217260',
'AS002217272',
'AS002217820',
'AS002218027',
'AS002218222',
'AS002218673') 
and NodeType=110 and NodeID=110

--酒店
SELECT CoupNo,t5.Name FROM HotelOrderDB..HTL_Orders t1
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t1.OrderID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='审批'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.CoupNo in 
(  'PTW071756' ,
 'PTW072163' ,
 '-PTW072163' ,
 'PTW072240' ,
 'PTW072265' ,
 'PTW072416') and NodeType=110 and NodeID=111
 
 
 
 --上海丰树2018数据
 select datetime as 出票日期,begdate as 起飞日期,coupno as 销售单号,pasname as 乘客姓名,route as 线路,ride+flightno as 航班号,tcode+ticketno as 票号,priceinfo as 全价,
 price/priceinfo as 折扣率,totprice as 销售价,tax as 税收,fuprice as 服务费,price as 销售单价,reti as 退票单号,CostCenter as 成本中心
  from Topway..V_TicketInfo 
 where datetime>='2018-01-01' and datetime<'2019-01-01' and cmpcode='019358' and priceinfo>'0'  and inf=1
 order by datetime
 
 select DepName,* from homsomdb..Trv_CompanyStructure where id in (select CompanyDptId from homsomDB..Trv_UnitPersons t3 inner join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID 
where t4.IsDisplay=1 and t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='019358'))
select Top 10* from homsomDB..Trv_Human --where CompanyId='769FCAC7-783C-4097-ADD4-A52300E4DEF0'

 --退票日期
 select edatetime,ExamineDate from Topway..tbReti 
 --update Topway..tbReti set edatetime='2019-1-21',ExamineDate='2019-01-18'
 where reno='0426338'
 
 --泰思肯贸易乘机人数据
 select pasname as 乘机人,coupno as 销售单号,route as 行程,begdate as 出发时间,SUM(totprice) as '销量(含税)' from Topway..tbcash where datetime>='2018-01-01' and datetime<'2019-01-01' and cmpcode='018821' and reti='' and pasname like'赖%'
 group by pasname,coupno,route,begdate
 