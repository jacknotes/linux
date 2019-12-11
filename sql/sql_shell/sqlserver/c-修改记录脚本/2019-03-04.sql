--修改酒店销售单信息
select Sales,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set Sales='何洁'
where CoupNo='PTW077132'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='019796_20190201'

--账单撤销火车票
select TrainBillStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set TrainBillStatus=1
where BillNumber='019394_20190201'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='019259_20190201'

select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='016485_20190201'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=6478,profit=2116
where coupno='AS002285839'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=6970,profit=1738
where coupno='AS002286219'

--修改供应商来源
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='DLBSPETI'
where coupno='AS002282766'

--单位抬头更换
select * from Topway..tbCompanyM where cmpid='017680'
select * from homsomDB..Trv_UnitCompanies where Cmpid='017680'
select * from Topway..AccountStatement where CompanyCode='017680' order by BillNumber desc

--酒店销售单差旅目的
select  CoupNo,Purpose as 差旅目的 from HotelOrderDB..HTL_Orders where CoupNo in('PTW076659',
'PTW076822',
'PTW076898',
'PTW076905',
'PTW076985')

--新增成本中心数据
--成本中心
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='73240' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='LIU/SONG')

select * from homsomDB..Trv_UnitCompanies where Cmpid='017745'

--酒店核销
select cwstatus,owe,vpay,opername1,vpayinfo,oth2 from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set cwstatus=1,owe=0,vpay=149
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo='PTW073438')

--打印权限
select PrDate,Pstatus,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk set PrDate='1900-01-01',Pstatus=0
where ConventionId='1269' and Id='2487'

select pstatus,prdate,* from Topway..tbHtlcoupYf where CoupNo='PTW077072' 

SELECT * FROM Topway..tbHtlSettlementApp where id='114217'
select * from Topway..tbhtlyfchargeoff where coupid in (select id from Topway..tbHtlcoupYf where CoupNo='PTW077072')

--票号匹配UC，开发人，和注册时间
select tcode+ticketno,isnull(cmpcode,'') as UC,isnull(m.depman,'') as 开发人,isnull(m.indate,'') as 注册日期 from Topway..tbcash c
left join Topway..tbCompanyM m on m.cmpid=c.cmpcode
left join homsomDB..Trv_UnitCompanies t1 on t1.Cmpid=c.cmpcode
left join homsomDB..Trv_UnitCompies_Sales t2 on t2.UnitCompayID=t1.ID
where tcode+ticketno in ('7815164419204',
'7815173835817',
'7813405150508',
'7813404421374',
'7813405977721',
'7813405976842',
'7813405149372',
'7813169136374',
'7813405976496',
'7813405976490',
'7813405150214',
'7813405148030',
'7813405149371',
'7813405150138',
'7815173090857',
'7815182024367',
'7815182024368',
'7813405150139',
'7813405150009',
'7813405147374',
'7813405146848',
'7813405148296',
'7813405146850',
'7813405146846',
'7813405149908',
'7813404422419',
'7813405148964',
'7813405149765',
'7813405976532',
'7813405976531',
'7813405149764',
'7813405149104',
'7813405977417',
'7813406731059',
'7813406731055',
'7813406731054',
'7815174960102',
'7813406731058',
'7815175209429',
'7813406730305',
'7813405979444',
'7815174959515',
'7813405979044',
'7813404419354',
'7813406729584',
'7813406730662',
'7813407694725',
'7815176019565',
'7813407693911',
'7813407694732',
'7815166036961',
'7813409065620',
'7813407694726',
'7813409066075',
'7813407693765',
'7815165696450',
'7815173836362',
'7815382089612',
'7812895460065',
'7813406730406',
'7812895460068',
'7813407695264',
'7812829745307',
'7813405979673',
'7815176019564',
'7813407694454',
'7813407696408',
'7813407694714',
'7813407695273',
'7813406731297',
'7812633839055',
'7813176885534',
'7815174959497',
'7813409064835',
'7813405149170',
'7813167447997',
'7813409065454',
'7813409067036',
'7813541110990',
'7813540107210',
'7813541110285',
'7813541109685',
'7813407696080',
'7813541111916',
'7813176886301',
'7815182022993',
'7813541113429',
'7813407695962',
'7813541113302',
'7813541110523',
'7813541112943',
'7813541111781',
'7813541113496',
'7813405978350',
'7815179760694',
'7813406730460',
'7813409065259',
'7813540107638',
'7813541109586',
'7813541109585',
'7813541109205',
'7813540107738',
'7815167401673',
'7813540108366',
'7813541110142',
'7813541110286',
'7813407696079',
'7813541112390',
'7813409064588',
'7813541110892',
'7813541111931',
'7813409067089',
'7813405150366',
'7813541113116',
'7813540107936',
'7813540107928',
'7813540107727',
'7813540108201',
'7812061065543',
'7812061065356',
'7812061065360',
'7812061065355',
'7813543690974',
'7813542740508',
'7813542740507',
'7813543690196',
'7813543690838',
'7813543690035',
'7813544527101',
'7813544526712',
'7813544526728',
'7812061821130',
'7815378191302',
'7813544526659',
'7813544527390',
'7813543690555',
'7812061821558',
'7812061821557',
'7812060607670',
'7813571075557',
'7813542738722',
'7813543691117',
'7813540107104')
order by m.indate

--个人
select coupno,cmpcode,depman,depdate from Topway..tbcash c
left join Topway..tbCusholderM m on m.custid=c.custid
where tcode+ticketno in ('7813405150508',
'7813167447997')

--修改顾问
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='黄怡丽',SpareTC='黄怡丽'
where coupno='AS001456731'