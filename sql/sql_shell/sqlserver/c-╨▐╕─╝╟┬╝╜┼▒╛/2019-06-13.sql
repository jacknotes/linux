--修改UC号（机票）原uc020459，现uc020842
--select * from Topway..tbCusholderM where cmpid='020842' and mobilephone='13524135823'
--select pform,OriginalBillNumber,* from Topway..tbcash where cmpcode='020842'

select cmpcode,custid,pform,OriginalBillNumber,* from Topway..tbcash 
--update Topway..tbcash set cmpcode='020842',custid='D690563',pform='月结(中行)',OriginalBillNumber='020842_20190501'
where coupno in('AS002444639','AS002444695')

select custid,OriginalBillNumber,ModifyBillNumber,cmpcode,* from Topway..tbReti 
--update Topway..tbReti set custid='D690563'
where reno in('9267238','9267140')

select custid,OriginalBillNumber,ModifyBillNumber,cmpcode,* from Topway..tbReti 
--update Topway..tbReti set cmpcode='020842'
where reno in('9267238','9267140')

select Cmpname,* from Topway..tbFiveCoupInfo 
--update Topway..tbFiveCoupInfo  set Cmpname='（会务）康宝莱（上海）管理有限公司'
where coupno in('AS002444639','AS002444695')

select CmpId,CompanyName,CompanyId,*  from homsomDB..Intl_BookingOrders 
--update homsomDB..Intl_BookingOrders  set CmpId='020842',CompanyName='（会务）康宝莱（上海）管理有限公司',CompanyId='17B6E10B-4AA1-498A-BD97-AA540093926E'
where Id in('96efc436-9baf-41aa-a141-07b680ff1187','75b3c311-f5c0-4b01-b102-67a6c7d7bfc5')


--酒店销售单重开打印权限
select pstatus,prdate,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set pstatus=0,prdate='1900-01-01'
where CoupNo='PTW083765'

--（产品部专用）机票供应商来源（国际）
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='ZSBSPETI'
where coupno in('AS000000000') and tcode+ticketno='1319578376249'

--宇培退票费
select reno,totprice from Topway..tbReti 
where reno in ('0425251','0435161','0425279','9265962','9265740',
'9265962','0435072','0429267','0433561','0426076','0429266',
'0435075','0431936','0426138','0426592',
'0435019','0430763')

--行程单
SELECT info3,* FROM Topway..tbcash 
--UPDATE Topway..tbcash  SET info3='需打印中文行程单'
WHERE coupno IN('AS002462003','AS002497047')


--国际行程显示中文
select a.Code,AbbreviationName,c.Name from homsomDB..Trv_Airport a
left join homsomDB..trv_Cities c on c.ID=a.CityID
select Code,Name from homsomDB..Trv_Cities where CountryType=2
select top 100 * from homsomDB..Intl_BookingOrders  where Id='a6301e38-8022-40c1-84ee-03e5672296f5'
select top 100 * from homsomDB..Intl_BookingSegements
select top 100 * from homsomDB..Intl_BookingLegs where CoupNo='AS001193003'

select * from Topway..tbcash c
left join homsomDB..Intl_BookingOrders o on o.SalesOrderNo=c.coupno

select * from Topway..tbcash where tcode+ticketno='9881287920920'
select * from homsomDB..Intl_BookingOrders where SalesOrderNo='AS000775974'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno='AS002547173'

select totsprice,profit,sprice1,t_source,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=20,totsprice=totsprice+10,profit=profit+10,t_source='ZSBSPETI'
where coupno='AS000000000' and ticketno='9578923355'

/*14家天纳克2019年第一季度， UC016448只成本中心为CA 的数据
UC016448
UC018541
UC020085 
UC020273 
UC016713 
UC020636 
UC020637 
UC020638 
UC020643 
UC020655 
UC020665 
UC020685 
UC020742 
UC016448  
*/
--国内
if OBJECT_ID('tempdb..#gnsj') is not null drop table #gnsj
select 'UC'+cmpcode UC号,u.Name 公司名称,sum(price) 销量不含税,sum(tax) 税收,COUNT(1) 张数,sum(price)/COUNT(1) 平均票价,
sum(price)/SUM(convert(decimal(18,3),priceinfo)) 折扣率,AVG(DATEDIFF(DD,datetime,begdate)) 平均出票天数 
into #gnsj
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2019-01-01'
and datetime<'2019-04-01'
and cmpcode in('018541','020085','020273','016713','020636'
,'020637','020638','020643','020655','020665','020685','020742','016448')
AND inf=0
--and CostCenter='CA'
GROUP BY 'UC'+cmpcode,u.Name

if OBJECT_ID('tempdb..#gnhs') is not null drop table #gnhs
select  'UC'+cmpcode UC号,u.Name 公司名称,ride 航司,sum(price) 销量不含税
into #gnhs
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2019-01-01'
and datetime<'2019-04-01'
and cmpcode in('018541','020085','020273','016713','020636'
,'020637','020638','020643','020655','020665','020685','020742','016448')
AND inf=0
--and CostCenter='CA'
GROUP BY 'UC'+cmpcode,u.Name,ride
order by 销量不含税 desc

select * from (
select  cmpcode UC号,u.Name 公司名称,ride 航司,sum(price) 销量不含税
from Topway..tbcash c with (nolock)
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2019-01-01'
and datetime<'2019-04-01'
AND inf=0
and cmpcode<>''
--and CostCenter='CA'
GROUP BY cmpcode,u.Name,ride
order by 销量不含税 desc) t 
where t.UC号 in('018541','020085','020273','016713','020636'
,'020637','020638','020643','020655','020665','020685','020742','016448')

--国际
if OBJECT_ID('tempdb..#gjsj') is not null drop table #gjsj
select 'UC'+cmpcode UC号,u.Name 公司名称,sum(price) 销量不含税,sum(tax) 税收,COUNT(1) 张数,
AVG(DATEDIFF(DD,datetime,begdate)) 平均出票天数 
into #gjsj
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2019-01-01'
and datetime<'2019-04-01'
and cmpcode in('018541','020085','020273','016713','020636'
,'020637','020638','020643','020655','020665','020685','020742','016448')
AND inf=1
--and CostCenter='CA'
GROUP BY 'UC'+cmpcode,u.Name

select s.UC号,s.公司名称,s.销量不含税,s.税收,s.张数,s.平均票价,折扣率,s.平均出票天数,航司,h.销量不含税/s.销量不含税 占比比例
,j.销量不含税,j.税收,j.张数,j.平均出票天数 
from #gnsj s
left join #gnhs h on s.UC号=h.UC号
left join #gjsj j on s.UC号=j.UC号



--销售价信息
update Topway..tbcash set price='590',xfprice='0',feiyong='0',fuprice='15',totprice='655',amount='655',owe='655',profit='655'-totsprice where tcode+ticketno='8763638345016'
update Topway..tbcash set price='1240',xfprice='0',feiyong='0',fuprice='15',totprice='1305',amount='1305',owe='1305',profit='1305'-totsprice where tcode+ticketno='7313638346618'
update Topway..tbcash set price='1240',xfprice='0',feiyong='0',fuprice='15',totprice='1305',amount='1305',owe='1305',profit='1305'-totsprice where tcode+ticketno='7313638346619'
update Topway..tbcash set price='680',xfprice='0',feiyong='0',fuprice='15',totprice='745',amount='745',owe='745',profit='745'-totsprice where tcode+ticketno='8803638347091'
update Topway..tbcash set price='1480',xfprice='0',feiyong='0',fuprice='15',totprice='1545',amount='1545',owe='1545',profit='1545'-totsprice where tcode+ticketno='9993638347092'
update Topway..tbcash set price='1280',xfprice='0',feiyong='0',fuprice='15',totprice='1345',amount='1345',owe='1345',profit='1345'-totsprice where tcode+ticketno='7813638347243'
update Topway..tbcash set price='1280',xfprice='0',feiyong='0',fuprice='15',totprice='1345',amount='1345',owe='1345',profit='1345'-totsprice where tcode+ticketno='7813638347244'
update Topway..tbcash set price='970',xfprice='0',feiyong='0',fuprice='15',totprice='1035',amount='1035',owe='1035',profit='1035'-totsprice where tcode+ticketno='7813638347278'
update Topway..tbcash set price='970',xfprice='0',feiyong='0',fuprice='15',totprice='1035',amount='1035',owe='1035',profit='1035'-totsprice where tcode+ticketno='7813638347279'
update Topway..tbcash set price='740',xfprice='0',feiyong='0',fuprice='15',totprice='805',amount='805',owe='805',profit='805'-totsprice where tcode+ticketno='8763640013384'
update Topway..tbcash set price='1360',xfprice='0',feiyong='0',fuprice='15',totprice='1425',amount='1425',owe='1425',profit='1425'-totsprice where tcode+ticketno='7843640015066'
update Topway..tbcash set price='1360',xfprice='0',feiyong='0',fuprice='15',totprice='1425',amount='1425',owe='1425',profit='1425'-totsprice where tcode+ticketno='7843640015079'
update Topway..tbcash set price='680',xfprice='0',feiyong='0',fuprice='15',totprice='745',amount='745',owe='745',profit='745'-totsprice where tcode+ticketno='7843640015138'
update Topway..tbcash set price='620',xfprice='0',feiyong='0',fuprice='15',totprice='685',amount='685',owe='685',profit='685'-totsprice where tcode+ticketno='9993651352215'
update Topway..tbcash set price='1060',xfprice='0',feiyong='0',fuprice='15',totprice='1125',amount='1125',owe='1125',profit='1125'-totsprice where tcode+ticketno='9993651352238'
update Topway..tbcash set price='750',xfprice='0',feiyong='0',fuprice='15',totprice='815',amount='815',owe='815',profit='815'-totsprice where tcode+ticketno='7813651352564'
update Topway..tbcash set price='1280',xfprice='0',feiyong='0',fuprice='15',totprice='1345',amount='1345',owe='1345',profit='1345'-totsprice where tcode+ticketno='7818278071845'
update Topway..tbcash set price='1420',xfprice='0',feiyong='0',fuprice='15',totprice='1485',amount='1485',owe='1485',profit='1485'-totsprice where tcode+ticketno='7813651354396'
update Topway..tbcash set price='1420',xfprice='0',feiyong='0',fuprice='15',totprice='1485',amount='1485',owe='1485',profit='1485'-totsprice where tcode+ticketno='7813651354397'
update Topway..tbcash set price='780',xfprice='0',feiyong='0',fuprice='15',totprice='845',amount='845',owe='845',profit='845'-totsprice where tcode+ticketno='7818278073614'
update Topway..tbcash set price='680',xfprice='0',feiyong='0',fuprice='15',totprice='745',amount='745',owe='745',profit='745'-totsprice where tcode+ticketno='7813651354467'
update Topway..tbcash set price='600',xfprice='0',feiyong='0',fuprice='15',totprice='665',amount='665',owe='665',profit='665'-totsprice where tcode+ticketno='7812383313145'
update Topway..tbcash set price='1400',xfprice='0',feiyong='0',fuprice='15',totprice='1465',amount='1465',owe='1465',profit='1465'-totsprice where tcode+ticketno='7818278073799'
update Topway..tbcash set price='1220',xfprice='0',feiyong='0',fuprice='15',totprice='1285',amount='1285',owe='1285',profit='1285'-totsprice where tcode+ticketno='9993645855332'
update Topway..tbcash set price='990',xfprice='0',feiyong='0',fuprice='15',totprice='1055',amount='1055',owe='1055',profit='1055'-totsprice where tcode+ticketno='7818278076270'
update Topway..tbcash set price='590',xfprice='0',feiyong='0',fuprice='15',totprice='655',amount='655',owe='655',profit='655'-totsprice where tcode+ticketno='7818278076276'
update Topway..tbcash set price='1490',xfprice='0',feiyong='0',fuprice='15',totprice='1555',amount='1555',owe='1555',profit='1555'-totsprice where tcode+ticketno='9993652755018'
update Topway..tbcash set price='520',xfprice='0',feiyong='0',fuprice='15',totprice='585',amount='585',owe='585',profit='585'-totsprice where tcode+ticketno='4793652756373'
update Topway..tbcash set price='760',xfprice='0',feiyong='0',fuprice='15',totprice='825',amount='825',owe='825',profit='825'-totsprice where tcode+ticketno='7818278092372'
update Topway..tbcash set price='380',xfprice='0',feiyong='0',fuprice='15',totprice='445',amount='445',owe='445',profit='445'-totsprice where tcode+ticketno='7818278093980'
update Topway..tbcash set price='1040',xfprice='0',feiyong='0',fuprice='15',totprice='1105',amount='1105',owe='1105',profit='1105'-totsprice where tcode+ticketno='7843646827317'
update Topway..tbcash set price='410',xfprice='0',feiyong='0',fuprice='15',totprice='475',amount='475',owe='475',profit='475'-totsprice where tcode+ticketno='7843653061521'
update Topway..tbcash set price='410',xfprice='0',feiyong='0',fuprice='15',totprice='475',amount='475',owe='475',profit='475'-totsprice where tcode+ticketno='7843653061522'
update Topway..tbcash set price='410',xfprice='0',feiyong='0',fuprice='15',totprice='475',amount='475',owe='475',profit='475'-totsprice where tcode+ticketno='7843653061523'
update Topway..tbcash set price='410',xfprice='0',feiyong='0',fuprice='15',totprice='475',amount='475',owe='475',profit='475'-totsprice where tcode+ticketno='7843653061524'
update Topway..tbcash set price='1130',xfprice='0',feiyong='0',fuprice='15',totprice='1195',amount='1195',owe='1195',profit='1195'-totsprice where tcode+ticketno='7818278100100'
update Topway..tbcash set price='1130',xfprice='0',feiyong='0',fuprice='15',totprice='1195',amount='1195',owe='1195',profit='1195'-totsprice where tcode+ticketno='7843653860465'
update Topway..tbcash set price='1820',xfprice='0',feiyong='0',fuprice='15',totprice='1885',amount='1885',owe='1885',profit='1885'-totsprice where tcode+ticketno='7843653860467'
update Topway..tbcash set price='870',xfprice='0',feiyong='0',fuprice='15',totprice='935',amount='935',owe='935',profit='935'-totsprice where tcode+ticketno='7813653950132'
update Topway..tbcash set price='1200',xfprice='0',feiyong='0',fuprice='15',totprice='1265',amount='1265',owe='1265',profit='1265'-totsprice where tcode+ticketno='7813653950133'
update Topway..tbcash set price='760',xfprice='0',feiyong='0',fuprice='15',totprice='825',amount='825',owe='825',profit='825'-totsprice where tcode+ticketno='7818278105191'
update Topway..tbcash set price='1010',xfprice='0',feiyong='0',fuprice='15',totprice='1075',amount='1075',owe='1075',profit='1075'-totsprice where tcode+ticketno='7843651607904'
update Topway..tbcash set price='1290',xfprice='0',feiyong='0',fuprice='15',totprice='1355',amount='1355',owe='1355',profit='1355'-totsprice where tcode+ticketno='7818278107025'
update Topway..tbcash set price='870',xfprice='0',feiyong='0',fuprice='15',totprice='935',amount='935',owe='935',profit='935'-totsprice where tcode+ticketno='7843654466728'
update Topway..tbcash set price='870',xfprice='0',feiyong='0',fuprice='15',totprice='935',amount='935',owe='935',profit='935'-totsprice where tcode+ticketno='7843654467036'
update Topway..tbcash set price='1110',xfprice='0',feiyong='0',fuprice='15',totprice='1175',amount='1175',owe='1175',profit='1175'-totsprice where tcode+ticketno='7843651608285'
update Topway..tbcash set price='1040',xfprice='0',feiyong='0',fuprice='15',totprice='1105',amount='1105',owe='1105',profit='1105'-totsprice where tcode+ticketno='4793654467438'
update Topway..tbcash set price='1230',xfprice='0',feiyong='0',fuprice='15',totprice='1295',amount='1295',owe='1295',profit='1295'-totsprice where tcode+ticketno='7818278109236'
update Topway..tbcash set price='1040',xfprice='0',feiyong='0',fuprice='15',totprice='1105',amount='1105',owe='1105',profit='1105'-totsprice where tcode+ticketno='4793654467441'
update Topway..tbcash set price='1160',xfprice='0',feiyong='0',fuprice='15',totprice='1225',amount='1225',owe='1225',profit='1225'-totsprice where tcode+ticketno='7818278109243'
update Topway..tbcash set price='740',xfprice='0',feiyong='0',fuprice='15',totprice='805',amount='805',owe='805',profit='805'-totsprice where tcode+ticketno='7818278111284'
update Topway..tbcash set price='1280',xfprice='0',feiyong='0',fuprice='15',totprice='1345',amount='1345',owe='1345',profit='1345'-totsprice where tcode+ticketno='7818278112526'
update Topway..tbcash set price='890',xfprice='0',feiyong='0',fuprice='15',totprice='955',amount='955',owe='955',profit='955'-totsprice where tcode+ticketno='7818278113947'
update Topway..tbcash set price='650',xfprice='0',feiyong='0',fuprice='15',totprice='715',amount='715',owe='715',profit='715'-totsprice where tcode+ticketno='7818278113949'
update Topway..tbcash set price='630',xfprice='0',feiyong='0',fuprice='15',totprice='695',amount='695',owe='695',profit='695'-totsprice where tcode+ticketno='0183655340960'
update Topway..tbcash set price='950',xfprice='0',feiyong='0',fuprice='15',totprice='1015',amount='1015',owe='1015',profit='1015'-totsprice where tcode+ticketno='9993655340961'
update Topway..tbcash set price='990',xfprice='0',feiyong='0',fuprice='15',totprice='1055',amount='1055',owe='1055',profit='1055'-totsprice where tcode+ticketno='7312474353365'
update Topway..tbcash set price='860',xfprice='0',feiyong='0',fuprice='15',totprice='925',amount='925',owe='925',profit='925'-totsprice where tcode+ticketno='8263655342353'
update Topway..tbcash set price='480',xfprice='0',feiyong='0',fuprice='15',totprice='545',amount='545',owe='545',profit='545'-totsprice where tcode+ticketno='9993655342358'
update Topway..tbcash set price='1010',xfprice='0',feiyong='0',fuprice='15',totprice='1075',amount='1075',owe='1075',profit='1075'-totsprice where tcode+ticketno='7843655121987'
update Topway..tbcash set price='620',xfprice='0',feiyong='0',fuprice='15',totprice='685',amount='685',owe='685',profit='685'-totsprice where tcode+ticketno='7818278120714'
update Topway..tbcash set price='1060',xfprice='0',feiyong='0',fuprice='15',totprice='1125',amount='1125',owe='1125',profit='1125'-totsprice where tcode+ticketno='7843655343949'
update Topway..tbcash set price='910',xfprice='0',feiyong='0',fuprice='15',totprice='975',amount='975',owe='975',profit='975'-totsprice where tcode+ticketno='7843655343962'
update Topway..tbcash set price='570',xfprice='0',feiyong='0',fuprice='15',totprice='635',amount='635',owe='635',profit='635'-totsprice where tcode+ticketno='7813655344043'
update Topway..tbcash set price='920',xfprice='0',feiyong='0',fuprice='15',totprice='985',amount='985',owe='985',profit='985'-totsprice where tcode+ticketno='8761951322501'
update Topway..tbcash set price='940',xfprice='0',feiyong='0',fuprice='15',totprice='1005',amount='1005',owe='1005',profit='1005'-totsprice where tcode+ticketno='0181958187712'
update Topway..tbcash set price='1130',xfprice='0',feiyong='0',fuprice='15',totprice='1195',amount='1195',owe='1195',profit='1195'-totsprice where tcode+ticketno='8761958188999'
update Topway..tbcash set price='1090',xfprice='0',feiyong='0',fuprice='15',totprice='1155',amount='1155',owe='1155',profit='1155'-totsprice where tcode+ticketno='0181958189136'
update Topway..tbcash set price='500',xfprice='0',feiyong='0',fuprice='15',totprice='565',amount='565',owe='565',profit='565'-totsprice where tcode+ticketno='7818278149671'


update Topway..tbcash set price='540',xfprice='0',feiyong='0',fuprice='15',totprice='605',amount='605',owe='605',profit='605'-totsprice where tcode+ticketno='7841958753952'
update Topway..tbcash set price='1040',xfprice='0',feiyong='0',fuprice='15',totprice='1105',amount='1105',owe='1105',profit='1105'-totsprice where tcode+ticketno='7818278158984'
update Topway..tbcash set price='1040',xfprice='0',feiyong='0',fuprice='15',totprice='1105',amount='1105',owe='1105',profit='1105'-totsprice where tcode+ticketno='7818278158983'
update Topway..tbcash set price='860',xfprice='0',feiyong='0',fuprice='15',totprice='925',amount='925',owe='925',profit='925'-totsprice where tcode+ticketno='7841958755038'
update Topway..tbcash set price='1620',xfprice='0',feiyong='0',fuprice='15',totprice='1685',amount='1685',owe='1685',profit='1685'-totsprice where tcode+ticketno='7311958755098'
update Topway..tbcash set price='700',xfprice='0',feiyong='0',fuprice='15',totprice='765',amount='765',owe='765',profit='765'-totsprice where tcode+ticketno='7811958755108'
update Topway..tbcash set price='1240',xfprice='0',feiyong='0',fuprice='15',totprice='1305',amount='1305',owe='1305',profit='1305'-totsprice where tcode+ticketno='7818278161224'
update Topway..tbcash set price='1410',xfprice='0',feiyong='0',fuprice='15',totprice='1475',amount='1475',owe='1475',profit='1475'-totsprice where tcode+ticketno='7818278162556'
update Topway..tbcash set price='450',xfprice='0',feiyong='0',fuprice='15',totprice='515',amount='515',owe='515',profit='515'-totsprice where tcode+ticketno='8761959732373'
update Topway..tbcash set price='420',xfprice='0',feiyong='0',fuprice='15',totprice='485',amount='485',owe='485',profit='485'-totsprice where tcode+ticketno='7311959732375'
update Topway..tbcash set price='1030',xfprice='0',feiyong='0',fuprice='15',totprice='1095',amount='1095',owe='1095',profit='1095'-totsprice where tcode+ticketno='7841959732543'
update Topway..tbcash set price='660',xfprice='0',feiyong='0',fuprice='15',totprice='725',amount='725',owe='725',profit='725'-totsprice where tcode+ticketno='7841959732727'
update Topway..tbcash set price='1100',xfprice='0',feiyong='0',fuprice='15',totprice='1165',amount='1165',owe='1165',profit='1165'-totsprice where tcode+ticketno='7841959732774'
update Topway..tbcash set price='790',xfprice='0',feiyong='0',fuprice='15',totprice='855',amount='855',owe='855',profit='855'-totsprice where tcode+ticketno='7841959733123'
update Topway..tbcash set price='820',xfprice='0',feiyong='0',fuprice='15',totprice='885',amount='885',owe='885',profit='885'-totsprice where tcode+ticketno='7818278164914'
update Topway..tbcash set price='1170',xfprice='0',feiyong='0',fuprice='15',totprice='1235',amount='1235',owe='1235',profit='1235'-totsprice where tcode+ticketno='7311959733125'
update Topway..tbcash set price='1180',xfprice='0',feiyong='0',fuprice='15',totprice='1245',amount='1245',owe='1245',profit='1245'-totsprice where tcode+ticketno='7844530087666'
update Topway..tbcash set price='1180',xfprice='0',feiyong='0',fuprice='15',totprice='1245',amount='1245',owe='1245',profit='1245'-totsprice where tcode+ticketno='7844530088442'
update Topway..tbcash set price='1200',xfprice='0',feiyong='0',fuprice='15',totprice='1265',amount='1265',owe='1265',profit='1265'-totsprice where tcode+ticketno='7844530088589'
update Topway..tbcash set price='1330',xfprice='0',feiyong='0',fuprice='15',totprice='1395',amount='1395',owe='1395',profit='1395'-totsprice where tcode+ticketno='7818278168902'
update Topway..tbcash set price='870',xfprice='0',feiyong='0',fuprice='15',totprice='935',amount='935',owe='935',profit='935'-totsprice where tcode+ticketno='7818278171495'
update Topway..tbcash set price='950',xfprice='0',feiyong='0',fuprice='15',totprice='1015',amount='1015',owe='1015',profit='1015'-totsprice where tcode+ticketno='9994531069623'
update Topway..tbcash set price='560',xfprice='0',feiyong='0',fuprice='15',totprice='625',amount='625',owe='625',profit='625'-totsprice where tcode+ticketno='7818278177278'
update Topway..tbcash set price='600',xfprice='0',feiyong='0',fuprice='15',totprice='665',amount='665',owe='665',profit='665'-totsprice where tcode+ticketno='9994531070164'
update Topway..tbcash set price='1020',xfprice='0',feiyong='0',fuprice='15',totprice='1085',amount='1085',owe='1085',profit='1085'-totsprice where tcode+ticketno='7818278183842'
update Topway..tbcash set price='460',xfprice='0',feiyong='0',fuprice='15',totprice='525',amount='525',owe='525',profit='525'-totsprice where tcode+ticketno='8764531885072'
update Topway..tbcash set price='580',xfprice='0',feiyong='0',fuprice='15',totprice='645',amount='645',owe='645',profit='645'-totsprice where tcode+ticketno='8764531885087'
update Topway..tbcash set price='1630',xfprice='0',feiyong='0',fuprice='15',totprice='1695',amount='1695',owe='1695',profit='1695'-totsprice where tcode+ticketno='7844531885447'
update Topway..tbcash set price='580',xfprice='0',feiyong='0',fuprice='15',totprice='645',amount='645',owe='645',profit='645'-totsprice where tcode+ticketno='0184531885916'
update Topway..tbcash set price='1110',xfprice='0',feiyong='0',fuprice='15',totprice='1175',amount='1175',owe='1175',profit='1175'-totsprice where tcode+ticketno='3244532675449'
update Topway..tbcash set price='1430',xfprice='0',feiyong='0',fuprice='15',totprice='1495',amount='1495',owe='1495',profit='1495'-totsprice where tcode+ticketno='7818278190573'
update Topway..tbcash set price='1190',xfprice='0',feiyong='0',fuprice='15',totprice='1255',amount='1255',owe='1255',profit='1255'-totsprice where tcode+ticketno='7844532675850'
update Topway..tbcash set price='1700',xfprice='0',feiyong='0',fuprice='15',totprice='1765',amount='1765',owe='1765',profit='1765'-totsprice where tcode+ticketno='7818278190956'
update Topway..tbcash set price='1090',xfprice='0',feiyong='0',fuprice='15',totprice='1155',amount='1155',owe='1155',profit='1155'-totsprice where tcode+ticketno='7844533580229'
update Topway..tbcash set price='1060',xfprice='0',feiyong='0',fuprice='15',totprice='1125',amount='1125',owe='1125',profit='1125'-totsprice where tcode+ticketno='3244533580733'
update Topway..tbcash set price='640',xfprice='0',feiyong='0',fuprice='15',totprice='705',amount='705',owe='705',profit='705'-totsprice where tcode+ticketno='7818278198256'
update Topway..tbcash set price='1080',xfprice='0',feiyong='0',fuprice='15',totprice='1145',amount='1145',owe='1145',profit='1145'-totsprice where tcode+ticketno='7844533581013'
update Topway..tbcash set price='580',xfprice='0',feiyong='0',fuprice='15',totprice='645',amount='645',owe='645',profit='645'-totsprice where tcode+ticketno='8764533581244'
update Topway..tbcash set price='620',xfprice='0',feiyong='0',fuprice='15',totprice='685',amount='685',owe='685',profit='685'-totsprice where tcode+ticketno='8764533581370'
update Topway..tbcash set price='620',xfprice='0',feiyong='0',fuprice='15',totprice='685',amount='685',owe='685',profit='685'-totsprice where tcode+ticketno='8764533581371'
update Topway..tbcash set price='730',xfprice='0',feiyong='0',fuprice='15',totprice='795',amount='795',owe='795',profit='795'-totsprice where tcode+ticketno='8764533581380'
update Topway..tbcash set price='1200',xfprice='0',feiyong='0',fuprice='15',totprice='1265',amount='1265',owe='1265',profit='1265'-totsprice where tcode+ticketno='7818278199540'
update Topway..tbcash set price='1300',xfprice='0',feiyong='0',fuprice='15',totprice='1365',amount='1365',owe='1365',profit='1365'-totsprice where tcode+ticketno='7818278199545'
update Topway..tbcash set price='610',xfprice='0',feiyong='0',fuprice='15',totprice='675',amount='675',owe='675',profit='675'-totsprice where tcode+ticketno='7818278199572'
update Topway..tbcash set price='680',xfprice='0',feiyong='0',fuprice='15',totprice='745',amount='745',owe='745',profit='745'-totsprice where tcode+ticketno='7844533581670'
update Topway..tbcash set price='1040',xfprice='0',feiyong='0',fuprice='15',totprice='1105',amount='1105',owe='1105',profit='1105'-totsprice where tcode+ticketno='7844533581749'
update Topway..tbcash set price='500',xfprice='0',feiyong='0',fuprice='15',totprice='565',amount='565',owe='565',profit='565'-totsprice where tcode+ticketno='7818278201837'
update Topway..tbcash set price='620',xfprice='0',feiyong='0',fuprice='15',totprice='685',amount='685',owe='685',profit='685'-totsprice where tcode+ticketno='7844533582378'
update Topway..tbcash set price='1240',xfprice='0',feiyong='0',fuprice='15',totprice='1305',amount='1305',owe='1305',profit='1305'-totsprice where tcode+ticketno='7844533582899'
update Topway..tbcash set price='1440',xfprice='0',feiyong='0',fuprice='15',totprice='1505',amount='1505',owe='1505',profit='1505'-totsprice where tcode+ticketno='7844533582920'
update Topway..tbcash set price='620',xfprice='0',feiyong='0',fuprice='15',totprice='685',amount='685',owe='685',profit='685'-totsprice where tcode+ticketno='7844534543444'
update Topway..tbcash set price='790',xfprice='0',feiyong='0',fuprice='15',totprice='855',amount='855',owe='855',profit='855'-totsprice where tcode+ticketno='3244534544315'
update Topway..tbcash set price='1600',xfprice='0',feiyong='0',fuprice='15',totprice='1665',amount='1665',owe='1665',profit='1665'-totsprice where tcode+ticketno='7844535496629'
update Topway..tbcash set price='1030',xfprice='0',feiyong='0',fuprice='15',totprice='1095',amount='1095',owe='1095',profit='1095'-totsprice where tcode+ticketno='7844535497325'
update Topway..tbcash set price='490',xfprice='0',feiyong='0',fuprice='15',totprice='555',amount='555',owe='555',profit='555'-totsprice where tcode+ticketno='4794535524574'
update Topway..tbcash set price='890',xfprice='0',feiyong='0',fuprice='15',totprice='955',amount='955',owe='955',profit='955'-totsprice where tcode+ticketno='7818278218621'
update Topway..tbcash set price='1210',xfprice='0',feiyong='0',fuprice='15',totprice='1275',amount='1275',owe='1275',profit='1275'-totsprice where tcode+ticketno='7844535920024'
update Topway..tbcash set price='530',xfprice='0',feiyong='0',fuprice='15',totprice='595',amount='595',owe='595',profit='595'-totsprice where tcode+ticketno='8764536958183'
update Topway..tbcash set price='760',xfprice='0',feiyong='0',fuprice='15',totprice='825',amount='825',owe='825',profit='825'-totsprice where tcode+ticketno='7818278232517'
update Topway..tbcash set price='760',xfprice='0',feiyong='0',fuprice='15',totprice='825',amount='825',owe='825',profit='825'-totsprice where tcode+ticketno='4794536959050'
update Topway..tbcash set price='1130',xfprice='0',feiyong='0',fuprice='15',totprice='1195',amount='1195',owe='1195',profit='1195'-totsprice where tcode+ticketno='9994536959422'
update Topway..tbcash set price='1130',xfprice='0',feiyong='0',fuprice='15',totprice='1195',amount='1195',owe='1195',profit='1195'-totsprice where tcode+ticketno='7812389991213'
update Topway..tbcash set price='1230',xfprice='0',feiyong='0',fuprice='15',totprice='1295',amount='1295',owe='1295',profit='1295'-totsprice where tcode+ticketno='7812389991234'
update Topway..tbcash set price='670',xfprice='0',feiyong='0',fuprice='15',totprice='735',amount='735',owe='735',profit='735'-totsprice where tcode+ticketno='8764536960193'
update Topway..tbcash set price='1600',xfprice='0',feiyong='0',fuprice='15',totprice='1665',amount='1665',owe='1665',profit='1665'-totsprice where tcode+ticketno='7844536960357'
update Topway..tbcash set price='1350',xfprice='0',feiyong='0',fuprice='15',totprice='1415',amount='1415',owe='1415',profit='1415'-totsprice where tcode+ticketno='7812444561963'
update Topway..tbcash set price='640',xfprice='0',feiyong='0',fuprice='15',totprice='705',amount='705',owe='705',profit='705'-totsprice where tcode+ticketno='7812444566797'
update Topway..tbcash set price='1040',xfprice='0',feiyong='0',fuprice='15',totprice='1105',amount='1105',owe='1105',profit='1105'-totsprice where tcode+ticketno='0184538438193'
update Topway..tbcash set price='810',xfprice='0',feiyong='0',fuprice='15',totprice='875',amount='875',owe='875',profit='875'-totsprice where tcode+ticketno='7812444574314'
update Topway..tbcash set price='570',xfprice='0',feiyong='0',fuprice='15',totprice='635',amount='635',owe='635',profit='635'-totsprice where tcode+ticketno='7812444574315'
update Topway..tbcash set price='700',xfprice='0',feiyong='0',fuprice='15',totprice='765',amount='765',owe='765',profit='765'-totsprice where tcode+ticketno='7844539571985'
update Topway..tbcash set price='490',xfprice='0',feiyong='0',fuprice='15',totprice='555',amount='555',owe='555',profit='555'-totsprice where tcode+ticketno='7844539572012'


--火车票销售单作废
select * 
--delete
from Topway..tbTrainUser where TrainTicketNo in (select id from Topway..tbTrainTicketInfo where CoupNo in('RS000025237','RS000025238','RS000025235','RS000025236'))

select * 
--delete
from Topway..tbTrainTicketInfo where CoupNo in('RS000025237','RS000025238','RS000025235','RS000025236')