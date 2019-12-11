--添加的常飞旅客
 SELECT c.Cmpid as 单位编号,h.Name as 中文姓名,LastName+'/'+firstname+' '+MiddleName as 英文姓名,t.CredentialNo as 证件号
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
LEFT join homsomDB..Trv_Credentials t on t.HumanID=h.ID
WHERE c.Cmpid in('019358',
'016363',
'019331',
'020432',
'020459',
'019334',
'006299',
'019539',
'017923',
'019641',
'020481',
'019301',
'016428',
'016712',
'016400',
'017888',
'017795',
'019637',
'019293',
'017189',
'020029',
'019392',
'018919',
'018210',
'019956',
'018897',
'020543',
'016655',
'015828',
'019360',
'017996',
'018038',
'017920',
'019106',
'017903',
'020380',
'016641',
'019986',
'020261',
'016232',
'018030',
'019222',
'020202',
'016991',
'019845',
'016465',
'020039',
'006596',
'019989',
'019626'
) and h.IsDisplay='1'
order by Cmpid

--更改单位名称

select cmpname,* from Topway..tbCompanyM 
--update Topway..tbCompanyM set cmpname='凯盛融英信息科技（上海）股份有限公司'
where cmpid='019637'

select Name,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set Name='凯盛融英信息科技（上海）股份有限公司'
where Cmpid='019637'

select CompanyNameCN,* from topway..AccountStatement 
--update topway..AccountStatement set CompanyNameCN='凯盛融英信息科技（上海）股份有限公司'
where CompanyCode='019637' and BillNumber='019637_20190201'

select cmpname,* from Topway..tbCompanyM 
--update Topway..tbCompanyM set cmpname='苏州艾沃意特汽车设备有限公司'
where cmpid='019584'

select Name,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set Name='苏州艾沃意特汽车设备有限公司'
where Cmpid='019584'

select CompanyNameCN,* from topway..AccountStatement 
--update topway..AccountStatement set CompanyNameCN='苏州艾沃意特汽车设备有限公司'
where CompanyCode='019584'  and BillNumber='019584_20190201'


--保险进位调整
select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash set sprice1='2.4',totsprice='2.4'
where coupno in('AS002210440','AS002212841','AS002212842','AS002219202','AS002219363','AS002223822','AS002223824','AS002225508','AS002226075','AS002230163','AS002233583',
'AS002232468')

select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash set sprice1='3.6',totsprice='3.6'
where coupno in('AS002216573','AS002218834','AS002220780','AS002220781','AS002221186','AS002222085','AS002222402','AS002222403','AS002222404','AS002222405','AS002222406','AS002222407','AS002222987','AS002222988','AS002223815','AS002227991','AS002234683','AS002235725','AS002235726','AS002235744','AS002235742','AS002235743','AS002235741','AS002235759','AS002235893','AS002235894','AS002235899','AS002235900',
'AS002236087')

select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash set sprice1='3.6',totsprice='3.6'
where coupno='AS002208643'

select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash set sprice1='2',totsprice='2'
where coupno in('AS002215063','AS002235081','AS002235082')

--火车票账单未核销
select SalesOrderState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SalesOrderState='0'
where  BillNumber='020569_20181201'


--修改航司
SELECT * FROM ehomsom..tbInfAirCompany 
--update ehomsom..tbInfAirCompany set airname='东方航空'
where airname='东方航空'

--酒店REASON CODE，预订人，差旅目的

select  h.CoupNo as 销售单号,Purpose as 差旅目的,t.pasname,ReasonDescription   FROM [HotelOrderDB].[dbo].[HTL_Orders] h
left join Topway..tbHtlcoupYf t on t.CoupNo=h.CoupNo
where h.CoupNo in ('PTW074077',
'PTW074076',
'PTW074130',
'PTW074246',
'PTW074311',
'PTW074434',
'PTW074433',
'PTW074632',
'PTW074832',
'PTW074831',
'PTW075028',
'PTW075102',
'PTW075123',
'PTW075488',
'PTW075759',
'PTW075758',
'PTW075796')

select CoupNo,pasname,* from Topway..tbHtlcoupYf where CoupNo in ('PTW074077',
'PTW074076',
'PTW074130',
'PTW074246',
'PTW074311',
'PTW074434',
'PTW074433',
'PTW074632',
'PTW074832',
'PTW074831',
'PTW075028',
'PTW075102',
'PTW075123',
'PTW075488',
'PTW075759',
'PTW075758',
'PTW075796')

--UC019634喆铁国际货运代理（上海）有限公司麻烦把20190201账期的抬头改一下
select CompanyNameCN,*  from Topway..AccountStatement 
--update Topway..AccountStatement set CompanyNameCN='喆铁国际货运代理（上海）有限公司'
where BillNumber='019634_20190201'

 --上海丰树2018国际机票匹配舱位代码
 select t.datetime as 出票日期,t.begdate as 起飞日期,t.coupno as 销售单号,t.pasname as 乘客姓名,t.route as 线路,t.ride+t.flightno as 航班号,t2.airname as 航空公司,t.tcode+t.ticketno as 票号,(case t.priceinfo when '0' then t.price else priceinfo end) as 全价,
(case t.priceinfo when '0' then '1' else t.price/t.priceinfo end) as 折扣率, t.price as 销售单价,t.tax as 税收,t.fuprice as 服务费,t.totprice as 销售价,t.reti as 退票单号,t.CostCenter as 成本中心,t1.rtprice as 退票费,
(Select c.totprice from Topway..tbcash c where c.coupno=t.coupno and c.ticketno=t.ticketno and (c.route like'%改期%' or c.tickettype like'%改期%') and c.cmpcode='019358' and c.ModifyBillNumber in('019358_20180101','019358_20180201','019358_20180301','019358_20180401','019358_20180501','019358_20180601','019358_20180701','019358_20180801','019358_20180901','019358_20181001','019358_20181101','019358_20181201')) as 改期升舱费
  ,t.nclass as 舱位代码
  from Topway..tbcash t
  left join Topway..tbReti t1 on t1.reno=t.reti
  left join ehomsom..tbInfAirCompany t2 on t2.code2=t.ride
 where t.ModifyBillNumber in('019358_20180101','019358_20180201','019358_20180301','019358_20180401','019358_20180501','019358_20180601','019358_20180701','019358_20180801','019358_20180901','019358_20181001','019358_20181101','019358_20181201') 
 and t.cmpcode='019358' and t.inf=1  
 order by t.ModifyBillNumber
 
 select coupno as 销售单号,nclass as 舱位 from Topway..tbcash 
 where ModifyBillNumber in('019358_20180101','019358_20180201','019358_20180301','019358_20180401','019358_20180501','019358_20180601','019358_20180701','019358_20180801','019358_20180901','019358_20181001','019358_20181101','019358_20181201')
 and inf=1 and cmpcode='019358'
 
 --特殊退票 0421829 ，调整利润320元，0421828，调整利润971元。因该公司已终止合作，已先将未使用机票特殊退票处理。现经办人要求退回这两张机票票款
 select profit,totprice,* from Topway..tbReti 
 --update Topway..tbReti set profit='320'
 where reno='0421829'
 select profit,totprice,* from Topway..tbReti 
 --update Topway..tbReti set profit='971'
 where reno='0421828'
 
 select profit,totprice,* from Topway..tbcash
 --update Topway..tbcash set profit='15'
 where reti='0421828'
 

 
 
 --账单撤销
 select * from Topway..AccountStatement where BillNumber='020592_20190101'

--市场营销改销售部
select Dept, * from homsomDB..SSO_Users 
--update homsomDB..SSO_Users set Dept='销售部'
where Dept='市场营销部'

select  dep,* from Topway..Emppwd  
--update Topway..Emppwd set dep='销售部'
where dep='销售部'


--卢叶和李双改市场
select Dept,Name, * from homsomDB..SSO_Users 
--update homsomDB..SSO_Users set Dept='市场部'
where Name in('卢叶','李双')

select dep,empname, * from Topway..Emppwd 
--update Topway..Emppwd set dep='市场部'
where empname in('卢叶','李双')

--技术部改技术研发中心
select Dept, * from homsomDB..SSO_Users 
--update homsomDB..SSO_Users set Dept='技术研发中心'
where Dept='技术研发中心'

select  dep,* from Topway..Emppwd  
--update Topway..Emppwd set dep='技术研发中心'
where dep='技术研发中心'

--修改退票状态
select status2 ,* from Topway..tbReti 
--update Topway..tbReti set status2='1'
where reno='9264581'

--修改职位

select depdetail, * from Topway..Emppwd 
--update Topway..Emppwd set depdetail='美案设计师'
where empname ='卢叶'
select depdetail, * from Topway..Emppwd 
--update Topway..Emppwd set depdetail='市场推广经理'
where empname ='李双'

select  depdetail,* from Topway..Emppwd  
--update Topway..Emppwd set depdetail='.NET开发工程师'
where empname in('王巍',
'徐鸣剑',
'周敏',
'林刚',
'张毅',
'赵冉')

select  depdetail,* from Topway..Emppwd  
--update Topway..Emppwd set depdetail='.NET开发专家'
where empname='钱晓'

select  depdetail,* from Topway..Emppwd  
--update Topway..Emppwd set depdetail='Android开发工程师'
where empname='吴志宏'

select  depdetail,* from Topway..Emppwd  
--update Topway..Emppwd set depdetail='IOS开发工程师'
where empname='程帅'

select  depdetail,* from Topway..Emppwd  
--update Topway..Emppwd set depdetail='测试工程师'
where empname='沈盛华'

select  depdetail,* from Topway..Emppwd  
--update Topway..Emppwd set depdetail='开发经理'
where empname='杨军'

select  depdetail,* from Topway..Emppwd  
--update Topway..Emppwd set depdetail='技术副总'
where empname='汤春燕'

--更改单位名称
select CompanyNameCN,* from topway..AccountStatement 
--update topway..AccountStatement set CompanyNameCN='荷美尔(中国)投资有限公司'
where CompanyCode='016336' and BillNumber='016336_20190201'

