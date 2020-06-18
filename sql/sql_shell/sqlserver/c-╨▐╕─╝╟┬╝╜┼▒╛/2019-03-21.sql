select popinfolist,* from Topway..Emppwd where empname not like'%测试%' and empname not in('恒顺旅行','HOMSOM') and popinfolist not like'%25%' and popinfolist<>''

--机票
SELECT t1.RecordNumber,t5.Name 
FROM homsomDB..Trv_DomesticTicketRecord t1
left join homsomDB..Trv_PnrInfos t2 on t2.ID=t1.PnrInfoID
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t2.ItktBookingID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='审批'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.RecordNumber in 
('AS002261407',
'AS002261713',
'AS002264283',
'AS002270340',
'AS002270354',
'AS002272360',
'AS002272360',
'AS002272886',
'AS002273388',
'AS002278682',
'AS002278690',
'AS002278694',
'AS002278696',
'AS002279023',
'AS002282245',
'AS002282300',
'AS002282355',
'AS002283392',
'AS002284715',
'AS002289421',
'AS002291406',
'AS002291960',
'AS002292526',
'AS002292916',
'AS002293402',
'AS002294086',
'AS002294094',
'AS002294118',
'AS002294126',
'AS002294161',
'AS002294163',
'AS002294248',
'AS002294263',
'AS002294266',
'AS002300247',
'AS002300251',
'AS002300255',
'AS002300452',
'AS002300660',
'AS002300662',
'AS002300667',
'AS002304534',
'AS002306155',
'AS002307717',
'AS002308852',
'AS002309018',
'AS002309044',
'AS002309048',
'AS002309192',
'AS002309194',
'AS002309200',
'AS002309251',
'AS002310074',
'AS002310565',
'AS002313211',
'AS002313291',
'AS002313408',
'AS002316396',
'AS002316950',
'AS002322594',
'AS002322772',
'AS002323576',
'AS002328925') and NodeType=110 and NodeID=111

--一级 NodeType=110 and NodeID=110
--二级 NodeType=110 and NodeID=111

--删除审批模板
select VettingTemplateID from homsomDB..Trv_UnitPersons 
--update homsomDB..Trv_UnitPersons set VettingTemplateID=''
where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID 
where hu.Name='黄志' and IsDisplay=1  and up.companyid='FF076962-62C1-4F30-9EE8-A9A500BDF725')

--（产品部专用）机票供应商来源（国际）
select t_source,* from Topway..tbcash  
--update Topway..tbcash  set t_source='ZSBSPETI'
where coupno='AS002324473'

select t_source,* from Topway..tbcash  
--update Topway..tbcash  set t_source='ZSBSPETI'
where coupno='AS000000000' and ticketno='3553877377'

--结算价差额
select totsprice,profit,totprice,* from Topway..tbcash 
--update Topway..tbcash set totsprice=11330,profit=5603,totprice=16933
where coupno='AS002328331'

select totsprice,profit,totprice,* from Topway..tbcash 
--update Topway..tbcash set totsprice=3614,profit=614
where coupno='AS002327896'

select totsprice,profit,totprice,* from Topway..tbcash 
--update Topway..tbcash set totsprice=4994,profit=334
where coupno='AS002329916'


--修改账单核销
select SalesOrderState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SalesOrderState=1
where BillNumber='019535_20190201'
