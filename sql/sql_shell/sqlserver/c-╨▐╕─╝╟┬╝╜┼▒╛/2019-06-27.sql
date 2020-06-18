/*
a 2018年1月1日-2019年6月26日出过国内机票的常旅客名单数字，
b 终止合作的客户以及合作状态为正常合作仅限现结的客户
*/
--出票证件号
if OBJECT_ID ('tempdb..#cp') is not null drop table #cp
select distinct cmpcode,idno 
into #cp
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-06-27'
and inf=0
--and reti=''
and cmpcode in ('020029',
'016428',
'016400',
'006596',
'018038',
'016618',
'020204',
'019607',
'016532',
'016289',
'020548',
'019653',
'019959',
'018463',
'018030',
'016336',
'019708',
'017327',
'017753',
'016414',
'018331',
'019772',
'019177',
'019588',
'019807',
'017505',
'016646',
'018896',
'020345',
'020096',
'020099',
'020308',
'020114',
'017508',
'016264',
'017547',
'019878',
'017364',
'018487',
'019830',
'020091',
'018928',
'019205',
'016720',
'019497',
'020560',
'016266',
'016554',
'016938',
'018589',
'019850',
'018304',
'018193',
'019691',
'018014',
'019753',
'018813',
'020231',
'018833',
'016962',
'018726',
'020561',
'020646',
'020544',
'020456',
'017654',
'020667',
'017325',
'020149',
'018408',
'019023',
'019249',
'017150',
'020665',
'018967',
'019442',
'019774',
'019704',
'017682',
'018536',
'019792',
'018669',
'020141',
'019365',
'019258',
'000037',
'020005',
'019230',
'017495',
'019568',
'019465',
'018047',
'018767',
'020219',
'018758',
'020425',
'016886',
'013909',
'018509',
'006944',
'020003',
'018037',
'019195',
'020426',
'017740',
'020023',
'019988',
'017033',
'019991',
'017700',
'020065',
'019692',
'020291',
'018834',
'018173',
'020495',
'020726',
'018720',
'018670',
'019989',
'019535',
'016724',
'017986',
'019231',
'017182',
'019506',
'018608',
'020569',
'020477',
'018318',
'020416',
'018626',
'019721',
'016307',
'018176',
'019941',
'018814',
'019939',
'019121',
'020758',
'018930',
'018766',
'018303',
'020651',
'018199',
'020161',
'019475',
'020263',
'017200',
'017449',
'020351',
'020784',
'019110',
'020701',
'018671',
'020338',
'018134',
'020727',
'018420',
'020602',
'020215',
'019658',
'020180',
'020095',
'020094',
'017480',
'020119',
'019592',
'020087',
'019634',
'016348',
'020253',
'020695',
'016961',
'020235',
'019363',
'017939',
'020069',
'019764',
'016719',
'016310',
'017519',
'020771',
'020349',
'019827',
'018945',
'020476',
'018385',
'020234',
'018731',
'019640',
'019882',
'020387',
'017873',
'020486',
'019961',
'020729',
'016504',
'019656',
'020734',
'019484',
'019006',
'020155',
'016936',
'020157',
'019348',
'016492',
'020288',
'019780',
'019638',
'018940',
'020679',
'018345',
'020462',
'020690',
'020148',
'018522',
'019021',
'020641',
'018341',
'018094',
'017223',
'018822',
'017930',
'017932',
'017776',
'020147',
'020384',
'020812',
'020243',
'018981',
'013184',
'018868',
'020763',
'017886',
'018343',
'019919',
'020709',
'018259',
'020072',
'002045',
'020466',
'016239',
'020626',
'018929',
'017055',
'017007',
'017921',
'020603',
'019670',
'016890',
'019901',
'017326',
'020132',
'019953',
'020228',
'020675',
'020684',
'019998',
'017146',
'020733',
'016294',
'020191',
'016635',
'019794',
'017559',
'020718',
'018281',
'018061',
'020536',
'020761',
'020820',
'020799',
'020293',
'020142',
'019842',
'017919',
'018925',
'019227',
'019347',
'019403',
'019609',
'019951',
'020033',
'020510',
'020801')

select cmpcode,COUNT(1) 数量  from #cp
group by cmpcode


select Cmpid,(CASE CooperativeStatus WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END) as 合作状态
from homsomDB..Trv_UnitCompanies 
where Cmpid in ('020029',
'016428',
'016400',
'006596',
'018038',
'016618',
'020204',
'019607',
'016532',
'016289',
'020548',
'019653',
'019959',
'018463',
'018030',
'016336',
'019708',
'017327',
'017753',
'016414',
'018331',
'019772',
'019177',
'019588',
'019807',
'017505',
'016646',
'018896',
'020345',
'020096',
'020099',
'020308',
'020114',
'017508',
'016264',
'017547',
'019878',
'017364',
'018487',
'019830',
'020091',
'018928',
'019205',
'016720',
'019497',
'020560',
'016266',
'016554',
'016938',
'018589',
'019850',
'018304',
'018193',
'019691',
'018014',
'019753',
'018813',
'020231',
'018833',
'016962',
'018726',
'020561',
'020646',
'020544',
'020456',
'017654',
'020667',
'017325',
'020149',
'018408',
'019023',
'019249',
'017150',
'020665',
'018967',
'019442',
'019774',
'019704',
'017682',
'018536',
'019792',
'018669',
'020141',
'019365',
'019258',
'000037',
'020005',
'019230',
'017495',
'019568',
'019465',
'018047',
'018767',
'020219',
'018758',
'020425',
'016886',
'013909',
'018509',
'006944',
'020003',
'018037',
'019195',
'020426',
'017740',
'020023',
'019988',
'017033',
'019991',
'017700',
'020065',
'019692',
'020291',
'018834',
'018173',
'020495',
'020726',
'018720',
'018670',
'019989',
'019535',
'016724',
'017986',
'019231',
'017182',
'019506',
'018608',
'020569',
'020477',
'018318',
'020416',
'018626',
'019721',
'016307',
'018176',
'019941',
'018814',
'019939',
'019121',
'020758',
'018930',
'018766',
'018303',
'020651',
'018199',
'020161',
'019475',
'020263',
'017200',
'017449',
'020351',
'020784',
'019110',
'020701',
'018671',
'020338',
'018134',
'020727',
'018420',
'020602',
'020215',
'019658',
'020180',
'020095',
'020094',
'017480',
'020119',
'019592',
'020087',
'019634',
'016348',
'020253',
'020695',
'016961',
'020235',
'019363',
'017939',
'020069',
'019764',
'016719',
'016310',
'017519',
'020771',
'020349',
'019827',
'018945',
'020476',
'018385',
'020234',
'018731',
'019640',
'019882',
'020387',
'017873',
'020486',
'019961',
'020729',
'016504',
'019656',
'020734',
'019484',
'019006',
'020155',
'016936',
'020157',
'019348',
'016492',
'020288',
'019780',
'019638',
'018940',
'020679',
'018345',
'020462',
'020690',
'020148',
'018522',
'019021',
'020641',
'018341',
'018094',
'017223',
'018822',
'017930',
'017932',
'017776',
'020147',
'020384',
'020812',
'020243',
'018981',
'013184',
'018868',
'020763',
'017886',
'018343',
'019919',
'020709',
'018259',
'020072',
'002045',
'020466',
'016239',
'020626',
'018929',
'017055',
'017007',
'017921',
'020603',
'019670',
'016890',
'019901',
'017326',
'020132',
'019953',
'020228',
'020675',
'020684',
'019998',
'017146',
'020733',
'016294',
'020191',
'016635',
'019794',
'017559',
'020718',
'018281',
'018061',
'020536',
'020761',
'020820',
'020799',
'020293',
'020142',
'019842',
'017919',
'018925',
'019227',
'019347',
'019403',
'019609',
'019951',
'020033',
'020510',
'020801')

--酒店销售单调整单
SELECT price,sprice,totprofit,* FROM Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set price='-5921',sprice='-5921',totprofit='-30'
WHERE CoupNo='PTW085398'

--会务预算单信息
--select * from Topway..tbCusholderM where mobilephone='18612464085'
select Custid,Custinfo,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget  set Custid='D691246',Custinfo='18612464085@黄云@017831@中德安联人寿保险有限公司@黄云@18612464085@D691246'
where ConventionId='1405'

--UC019808月星集团有限公司 服务费张数、服务费总收费金额
select * from Topway..AccountStatement where CompanyCode='019808'

select cmpcode UC,COUNT(1)张数,SUM(fuprice)服务费总收费金额 from Topway..tbcash 
where 
 ModifyBillNumber in('019808_20180101','019808_20180201','019808_20180301','019808_20180401','019808_20180501','019808_20180601','019808_20180701',
'019808_20180801','019808_20180901','019808_20181001','019808_20181101','019808_20181201')
AND fuprice<>0
GROUP BY cmpcode

--修改预订人信息
--select * from Topway..tbCusholder where mobilephone='15821235602'

select custid,* from Topway..tbcash 
--update Topway..tbcash set custid='D198516'
where coupno='AS002585633'

select Customer,Person,Tel,CustId,* from Topway..tbFiveCoupInfo 
--update Topway..tbFiveCoupInfo  set Customer='黄欢',Person='黄欢|15821235602',Tel='15821235602',CustId='D198516'
where CoupNo='AS002585633'


--预订人员名单
select distinct cmpcode UC,pasname 姓名,idno 证件号 from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-06-27'
and inf=0
and reti=''
and cmpcode in('020029',
'016428',
'016400',
'006596',
'018038',
'016618',
'020204',
'019607',
'016532',
'016289',
'020548',
'019653',
'019959',
'018463',
'018030',
'016336',
'019708',
'017327',
'017753',
'016414',
'018331',
'019772',
'019177',
'019588',
'019807',
'017505',
'016646',
'018896',
'020345',
'020096',
'020099',
'020308',
'020114',
'017508',
'016264',
'017547',
'019878',
'017364',
'018487',
'019830',
'020091',
'018928',
'019205',
'016720',
'019497',
'020560',
'016266',
'016554',
'016938',
'018589',
'019850',
'018304',
'018193',
'019691',
'018014',
'019753',
'018813',
'020231',
'018833',
'016962',
'018726',
'020561',
'020646',
'020544',
'020456',
'017654',
'020667',
'017325',
'020149',
'019023',
'019249',
'017150',
'018967',
'019442',
'019774',
'019704',
'017682',
'018536',
'019792',
'018669',
'020141',
'019365',
'019258',
'000037',
'020005',
'019230',
'017495',
'019568',
'019465',
'018047',
'018767',
'020219',
'018758',
'020425',
'016886',
'013909',
'018509',
'006944',
'020003',
'018037',
'019195',
'020426',
'020023',
'019988',
'017033',
'019991',
'017700',
'020065',
'019692',
'020291',
'018834',
'018173',
'020495',
'020726',
'018720',
'018670',
'019989',
'019535',
'016724',
'017986',
'019231',
'017182',
'019506',
'018608',
'020569',
'020477',
'018318',
'020416',
'018626',
'019721')
order by UC

--旅游预算单信息
--select * from Topway..tbCusholderM where mobilephone='15121021172'
select Custid,Custinfo,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Custid='D700196',Custinfo='15121021172@冯晓蓓@UC020785@玛伊娅服饰（上海）有限公司@冯晓蓓@15121021172@D700196'
where TrvId='29854'

--改到账时间
select * from topway..FinanceERP_ClientBankRealIncomeDetail 
--update topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-06-25'
 where money='813' and date='2019-06-25'

select r.coupno,c.totprice-r.totprice 退票费
from Topway..tbReti r
left join Topway..tbcash c on r.coupno=c.coupno
where r.coupno in ('AS002393228',
'AS002402968',
'AS002403022',
'AS002403988',
'AS002403359',
'AS002403676',
'AS002403022',
'AS002402985',
'AS002404832',
'AS002404822',
'AS002402959',
'AS002404105',
'AS002450807',
'AS002465646')

--结算价差额
select totsprice,profit,* from Topway..tbcash
--update  Topway..tbcash set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002577789','AS002581570','AS002584517','AS002585135')

--机票销售单改为未付
select bpay,status,opernum,oper2,oth2,totprice,dzhxDate,owe,vpay,vpayinf,dzhxDate
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1',vpay=0,vpayinf=''
from Topway..tbcash where coupno in ('AS002560329','AS002560365','AS002560425','AS002560371','AS002560554','AS002560343')

--促销费申请单
select * from Topway..tbDisctCommission 
--update Topway..tbDisctCommission  set CommissionStatus=0
where id='56610'

--UC017692丰益（上海）生物技术研发中心有限公司
 
--请将这家公司系统中的自定义项（项目编号）全部删除后，重新按附件重新导入

select  * 
--delete
from homsomDB..Trv_Customizations 
where UnitCompanyID=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='017692')


--INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'" &B1&"','0','" &B1&"','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-A-19-001','0','WRD-02-A-19-001','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-002','0','WRD-02-B-19-002','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-009','0','WRD-02-B-19-009','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-005','0','WRD-02-B-19-005','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-007','0','WRD-02-B-19-007','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-016','0','WRD-02-B-19-016','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-019','0','WRD-01-B-19-019','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-007','0','WRD-01-B-19-007','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-A-19-003','0','WRD-01-A-19-003','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-A-19-004','0','WRD-01-A-19-004','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-006','0','WRD-01-B-19-006','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-001','0','WRD-02-B-19-001','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-001','0','WRD-01-B-19-001','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-A-19-005','0','WRD-01-A-19-005','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-004','0','WRD-01-B-19-004','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-A-19-001','0','WRD-01-A-19-001','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-006','0','WRD-02-B-19-006','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-002','0','WRD-01-B-19-002','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-A-19-002','0','WRD-02-A-19-002','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-008','0','WRD-02-B-19-008','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-A-19-002','0','WRD-01-A-19-002','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-008','0','WRD-01-B-19-008','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-003','0','WRD-02-C-19-003','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-A-19-003','0','WRD-02-A-19-003','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-010','0','WRD-02-B-19-010','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-A-19-006','0','WRD-01-A-19-006','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-002','0','WRD-02-C-19-002','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-014','0','WRD-01-B-19-014','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-005','0','WRD-01-B-19-005','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-004','0','WRD-02-C-19-004','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-003','0','WRD-01-B-19-003','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-003','0','WRD-02-B-19-003','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-001','0','WRD-02-C-19-001','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-004','0','WRD-02-B-19-004','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-006','0','WRD-02-C-19-006','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-010','0','WRD-01-B-19-010','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-009','0','WRD-01-B-19-009','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-011','0','WRD-01-B-19-011','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-015','0','WRD-01-B-19-015','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-012','0','WRD-01-B-19-012','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-A-19-006','0','WRD-02-A-19-006','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-011','0','WRD-02-C-19-011','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-011','0','WRD-02-B-19-011','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-013','0','WRD-01-B-19-013','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-014','0','WRD-02-B-19-014','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-A-19-007','0','WRD-01-A-19-007','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-013','0','WRD-02-B-19-013','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-016','0','WRD-01-B-19-016','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-A-19-004','0','WRD-02-A-19-004','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-017','0','WRD-01-B-19-017','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-018','0','WRD-01-B-19-018','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-005','0','WRD-02-C-19-005','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-017','0','WRD-02-B-19-017','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-015','0','WRD-02-B-19-015','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-B-19-020','0','WRD-01-B-19-020','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-A-19-007','0','WRD-02-A-19-007','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-009','0','WRD-02-C-19-009','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-008','0','WRD-02-C-19-008','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-007','0','WRD-02-C-19-007','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-020','0','WRD-02-B-19-020','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-019','0','WRD-02-B-19-019','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-022','0','WRD-02-B-19-022','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-010','0','WRD-02-C-19-010','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-021','0','WRD-02-B-19-021','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-012','0','WRD-02-C-19-012','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-016','0','WRD-02-C-19-016','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-023','0','WRD-02-B-19-023','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-013','0','WRD-02-C-19-013','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-017','0','WRD-02-C-19-017','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-014','0','WRD-02-C-19-014','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-015','0','WRD-02-C-19-015','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-018','0','WRD-02-C-19-018','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-019','0','WRD-02-C-19-019','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-A-19-008','0','WRD-02-A-19-008','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-020','0','WRD-02-C-19-020','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-024','0','WRD-02-B-19-024','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-01-C-19-001','0','WRD-01-C-19-001','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-A-19-009','0','WRD-02-A-19-009','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-C-19-021','0','WRD-02-C-19-021','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-026','0','WRD-02-B-19-026','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-19-09','0','WRD-19-09','62D8AB5E-0415-4E86-AD05-E73C61727B0A')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWid(),GETDATE(),GETDATE(),'homsom',GETDATE(),'WRD-02-B-19-025','0','WRD-02-B-19-025','62D8AB5E-0415-4E86-AD05-E73C61727B0A')


--旅游预算单信息
select StartDate,EndDate,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set StartDate='2019-06-28',EndDate='2019-06-29'
where TrvId='30234'