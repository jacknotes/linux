--修改成申请闭团
select Status,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Status=14
where TrvId='29494'

--修改UC号（机票）
修改UC号（机票）
select custid AS 现会员编号,* from topway..tbCusholderM where cmpid ='020787' 
select custid,OriginalBillNumber,ModifyBillNumber,* from Topway..tbcash where cmpcode='020787'
select SettleMentManner AS 现结算方式,* from topway..HM_SetCompanySettleMentManner where CmpId='020787' and Type=0 and Status=1
select OriginalBillNumber AS 现账单号,ModifyBillNumber AS 现账单号,cmpcode,custid,datetime,* from topway..tbcash where coupno in ('AS002315886 ','AS002315886 ')
select HSLastPaymentDate,* from topway..AccountStatement where CompanyCode='020787' order by BillNumber desc
select Cmpname,* from Topway..tbFiveCoupInfo where CmpId='019539'and Ndate>'2019-03-01'

--修改UC号（ERP）
select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,pform,xfprice,* from Topway..tbcash
--update topway..tbcash set cmpcode='020787',OriginalBillNumber='020787_20190401',custid='D660877'
 where coupno in ('AS002363356','AS002363358','AS002370193','AS002364406','AS002365034',
 'AS002365034','AS002368460','AS002368654','AS002371891','AS002371903','AS002376380','AS002376422'
 ,'AS002376775','AS002382823')
 
 select CustId,CmpId,Cmpname,* from Topway..tbFiveCoupInfo 
  --update Topway..tbFiveCoupInfo set CustId='D660877',CmpId='020787',Cmpname='江苏中科君芯科技有限公司'
  where CoupNo in ('AS002363356','AS002363358','AS002370193','AS002364406','AS002365034',
 'AS002365034','AS002368460','AS002368654','AS002371891','AS002371903','AS002376380','AS002376422'
 ,'AS002376775','AS002382823')
  
 /*修改UC号（TMS)
 SELECT T2.CoupNo,T1.OrderNo,*
  FROM homsomDB..Intl_BookingOrders T1
  INNER JOIN Topway..tbFiveCoupInfo T2 ON T1.Id=T2.OrderId
  where Id in(select OrderId from Topway..tbFiveCoupInfo where CoupNo  in ('AS002363356','AS002363358','AS002370193','AS002364406','AS002365034',
 'AS002365034','AS002368460','AS002368654','AS002371891','AS002371903','AS002376380','AS002376422'
 ,'AS002376775','AS002382823'))*/
  
   --修改UC号（TMS)
  select CmpId,CompanyName,CustId,* from homsomDB..Intl_BookingOrders 
  --update homsomDB..Intl_BookingOrders set CmpId='020787',CustId='D660877',CompanyName='江苏中科君芯科技有限公司'
  where OrderNo in ('IF00029808','IF00029985','IF00029995')
  
  select CompanyName,* from homsomDB..Intl_BookingPassengers 
  --update homsomDB..Intl_BookingPassengers  set CompanyName='江苏中科君芯科技有限公司'
  where BookingOrderId in(Select id from homsomdb..Intl_BookingOrders where OrderNo in ('IF00029808','IF00029985','IF00029995'))
  
  
  --修改UC号（酒店）
select custid AS 现会员编号,* from tbCusholderM where cmpid ='020787'
select cmpname AS 现公司全称,* from tbcompanyM where cmpid ='020787'
select SettleMentManner AS 现结算方式,* from HM_SetCompanySettleMentManner where CmpId='020787' and Type=1 and Status=1
select newModifyBillNumber AS 现账单号,OriginalBillNumber,cmpid,custid,datetime,* from tbHtlcoupYf where coupno in ('PTW079476')
select HSLastPaymentDate,* from AccountStatement where CompanyCode='020787' order by BillNumber desc

select cmpid,OriginalBillNumber,NewModifyBillNumber,custid,pform,custinfo,conname,spersoninfo, * from Topway..tbHtlcoupYf
--update Topway..tbHtlcoupYf set cmpid='020787',OriginalBillNumber='020787_20190401',custid='D660877',pform='月结(中行)',custinfo='江苏中科君芯科技有限公司|黄雯静|13917345957|13917345957',conname='江苏中科君芯科技有限公司|黄雯静|13917345957|13917345957' 
where coupno in ('PTW079476')

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='北京纯粹旅行有限公司'
where CoupNo='PTW078844'

--删除离职员工
select distinct* from  homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (
select a.ID from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='019251')
and IsDisplay=1 and Name in ('朱伟明',
'朱豪',
'周明雅',
'周冲',
'郑颖',
'郑瑛敏',
'张元',
'张仙花',
'张黎明',
'张磊',
'张辉',
'张根棉',
'张艾崙',
'袁志鹏',
'袁英',
'袁晓政',
'于茉莉',
'姚禕韡',
'杨丽妍',
'杨俊杰',
'杨镔',
'许怡凤',
'徐志强',
'徐晓艳',
'徐涛',
'徐莉茹',
'肖兴',
'王文兵',
'王可',
'王俊宾',
'王芳',
'王达',
'王昂',
'田煌',
'汤尧雯',
'谭飞翔',
'覃璁',
'谈奥',
'孙晓春',
'孙景丽',
'宋晓光',
'司丽娜',
'史晶晶',
'石昕',
'盛立宇',
'沈羽',
'沈述凯',
'沈军',
'彭伟玉',
'寗龙蛟',
'南杰',
'闵金炼',
'毛爱君',
'马睿',
'罗依龄',
'陆婕云',
'刘映雪',
'刘青',
'刘明辉',
'刘林',
'刘峰',
'林晓羽',
'梁兴玉',
'李重',
'李长军',
'李杨',
'李扬',
'李彦',
'李祥子',
'李荣赚',
'李明',
'李静',
'李静',
'李广尧',
'赖永晨',
'金雪萍',
'蒋伟',
'蒋靖',
'惠燕萍',
'惠荣',
'惠迪',
'侯东岳',
'过小艳',
'郭永平',
'关艳龙',
'高芳翔',
'冯俏',
'冯磊',
'范涛',
'樊惠敏',
'多晶婷',
'代艳',
'程伟琴',
'陈杨辉',
'陈新凤',
'陈晓倩',
'陈仕贵',
'陈凤娟',
'曾庆林',
'安学良')
)

--删除ERP
select EmployeeStatus,* from Topway..tbCusholderM 
--update  Topway..tbCusholderM set EmployeeStatus=0
where cmpid='019251'

--同步常旅客

insert into topway..tbCusholderM(cmpid,custid,ccustid,custname,custtype1,male,username,phone,mobilephone,personemail,CardId,custtype,homeadd,joindate) 
select cmpid,CustID,CustID,h.Name,
CASE
WHEN u.Type='普通员工' THEN ''
WHEN u.Type='经办人' THEN '3'
WHEN u.Type='负责人' THEN '4'
WHEN u.Type='高管' THEN '5'
ELSE 2 end
,
CASE 
WHEN h.Gender=1 THEN '男'
WHEN h.Gender=0 THEN '女'
ELSE '男' end
,'',h.Telephone,h.Mobile,h.Email,'',u.CustomerType,'手工批量导入' ,h.CreateDate
FROM homsomDB..Trv_UnitPersons u
INNER JOIN homsomDB..Trv_Human h ON u.id =h.ID
INNER JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE Cmpid in ('019251') and IsDisplay=1

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='深圳市道旅旅游科技股份有限公司'
where CoupNo='PTW077021'

--更新项目编号
--删除原有项目编号
select *
--delete 
from homsomDB..Trv_Customizations 
where UnitCompanyID=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='019333')
--插入新的项目编号
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','Warehouse','0','Warehouse','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','Admin','0','Admin','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','CPI TFK-S-China','0','CPI TFK-S-China','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','CPI Lotes-S-China','0','CPI Lotes-S-China','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','HIS MEGA-S','0','HIS MEGA-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','HIS JGP-S','0','HIS JGP-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','TFH-W','0','TFH-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','TFH-SAT-China','0','TFH-SAT-China','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','BCO06-W','0','BCO06-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','BCO07-W','0','BCO07-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','BCO08-W','0','BCO08-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','BCO08-SAT','0','BCO08-SAT','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','Brazil-S','0','Brazil-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','India FX-SAT','0','India FX-SAT','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','India FX-S','0','India FX-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','SGI07-W','0','SGI07-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','SGI-S','0','SGI-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','TPN WISTRON SZ-S','0','TPN WISTRON SZ-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','TPI WISTRON ZS-S','0','TPI WISTRON ZS-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','TPI23-W','0','TPI23-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','TPI24-W','0','TPI24-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','TPI25-W','0','TPI25-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','TPI QSMC-S','0','TPI QSMC-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','TPI FXCD-S','0','TPI FXCD-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','TPI WISTRON-SAT','0','TPI WISTRON-SAT','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','TPI SUNREX-SAT','0','TPI SUNREX-SAT','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','HNI-S-China','0','HNI-S-China','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','UMPG-S-China','0','UMPG-S-China','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','UMP18MP-W','0','UMP18MP-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','UMP18GMP-W','0','UMP18GMP-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','UMP19MP-W','0','UMP19MP-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','UMP19-SAT','0','UMP19-SAT','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','UMP19-Conversion','0','UMP19-Conversion','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','UMP19GMP-SAT','0','UMP19GMP-SAT','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','UMP19GMP-W','0','UMP19GMP-W','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','UMP19GMP-S','0','UMP19GMP-S','12CD09E1-095C-4B40-81E9-A506009CE2AD')
INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),'2019-04-10','2019-04-10','homsom','2019-04-10','UMP-S-China','0','UMP-S-China','12CD09E1-095C-4B40-81E9-A506009CE2AD')


--匹配经办人
select distinct coupno,h.Name from Topway..tbcash c
left join homsomDB..Trv_UnitPersons un on un.CustID=c.custid
left join homsomDB..Trv_Human h on h.ID=un.ID
where coupno in ('AS002305183',
'AS002063427',
'AS001938868',
'AS001617811',
'AS002304363',
'AS002056118',
'AS002040462',
'AS002093403',
'AS001726319',
'AS001658222',
'AS001585458',
'AS001634402',
'AS002353434',
'AS001907161',
'AS001686668',
'AS002324312',
'AS001906730',
'AS002257991',
'AS001738480',
'AS001938866',
'AS001842463',
'AS002353552',
'AS001658250',
'AS001889689',
'AS002353552',
'AS002001333',
'AS002353434',
'AS001930504',
'AS002179453',
'AS001760278',
'AS001618697',
'AS002286995',
'AS002303644',
'AS002288412',
'AS001883820',
'AS002324314',
'AS001605786',
'AS002286993',
'AS001628245',
'AS001724727',
'AS002353552',
'AS002382941',
'AS001657636',
'AS001990015',
'AS001767245',
'AS001646020',
'AS002099785',
'AS001985009',
'AS002059882',
'AS001585458',
'AS002353552',
'AS002330154',
'AS001905133',
'AS001832291',
'AS001911929',
'AS002353434',
'AS001699161',
'AS002303644',
'AS001617809',
'AS002003896',
'AS002328713',
'AS001760272',
'AS001634406',
'AS001704528',
'AS002059884',
'AS001767245',
'AS001832291',
'AS002315422',
'AS002374147',
'AS001742288',
'AS001906701',
'AS002229916',
'AS002382941',
'AS001549841',
'AS001643332',
'AS002079190',
'AS001605772',
'AS001760278',
'AS001836600',
'AS001984997',
'AS002248150',
'AS002092319',
'AS001896702',
'AS002286995',
'AS002188756',
'AS002381555',
'AS002353434',
'AS001833276',
'AS002107187',
'AS002034914',
'AS001907180',
'AS001970363',
'AS001646024',
'AS002187506',
'AS001634402',
'AS002353434',
'AS001828585',
'AS001585458',
'AS002179453',
'AS001617599',
'AS001931311',
'AS002218516',
'AS001634406',
'AS002348855',
'AS002248150',
'AS002248150',
'AS002227130',
'AS001783756',
'AS001657630',
'AS001951429',
'AS002299670',
'AS002353434',
'AS002353552',
'AS001728752',
'AS002353552')

--修改结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=4815,profit=135
where coupno='AS002384345'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=3678,profit=101
where coupno='AS002384346'

--账单撤销
select TrainBillStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set TrainBillStatus=1
where BillNumber='018897_20190301'

--火车票销售单作废
select * 
--delete
from Topway..tbTrainTicketInfo where CoupNo in ('RS000020702','RS000020703','RS000020704')

select * 
--delete
from Topway..tbTrainUser 
where TrainTicketNo in (Select ID from Topway..tbTrainTicketInfo 
where CoupNo in ('RS000020702','RS000020703','RS000020704'))

--城市
select * from homsomDB..Trv_Cities  where Code='BZX'

insert into homsomDB..Trv_Cities ( ID, Ver, ModifyBy, ModifyDate, CreateBy, CreateDate, CountryType, Name, EnglishName, AbbreviatedName, Code, ProvinceID, IsHot, SortRank, CountryCode, ParentID, region)
 values  (NEWID(),'2019-04-10','SYS','2019-04-10','SYS','2019-04-10','1','巴中','bazhong',null,'BZX',null,'0','0','CHN','00000000-0000-0000-0000-000000000000','华中区')
 
 
 --删除离职员工
select distinct* from  homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (
select a.ID from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='020784')
and IsDisplay=1 )
and CreateDate>'2019-04-10'
and CreateBy not in ('0587')
--删除ERP
select EmployeeStatus,* from Topway..tbCusholderM 
--update  Topway..tbCusholderM set EmployeeStatus=0
where cmpid='020784'
and joindate>'2019-04-10'
