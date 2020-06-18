/*
请拉取2019.1.1-5.13，国际机票、电子票的数据。
需字段：出票日期 出发日期 航程 仓位 销量 利润。
请帮忙数据分析， SHA/PVG 张数占比、销量占比、利润占比，其他地区出发张数占比、销量占比、利润占比
*/
--表一
if OBJECT_ID('tempdb..#by') is not null drop table #by
select coupno,convert(varchar(10),datetime,120) 出票日期,begdate 出发日期,route 航程,nclass 舱位代码,sum(totprice) 销量,sum(profit) 利润,COUNT(1) 张数
into #by
from Topway..tbcash 
where datetime>='2019-01-01'
and datetime<'2019-05-14'
and inf=1
and tickettype='电子票'
and coupno not in ('AS000000000')
group by datetime,begdate,route,nclass,coupno
order by datetime

select SUM(张数)合计张数,SUM(销量)合计销量,SUM(利润)合计利润 from #by


--表二
if OBJECT_ID('tempdb..#be') is not null drop table #be
select coupno,datetime 出票日期,begdate 出发日期,route 航程,nclass 舱位代码,sum(totprice) 销量,sum(profit) 利润 ,COUNT(1) 张数
into #be
from Topway..tbcash 
where datetime>='2019-01-01'
and datetime<'2019-05-14'
and inf=1
and tickettype='电子票'
and coupno not in ('AS000000000')
and ( route like 'SHA%' or route like 'pvg%')
group by datetime,begdate,route,nclass,coupno
order by datetime

select SUM(张数)合计张数,SUM(销量)合计销量,SUM(利润)合计利润 from #be


--账单撤销
select SubmitState,HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set HotelSubmitStatus=3,SubmitState=1
where BillNumber='017602_20190401'

--行程单、特殊票价
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='需打印行程单'
where coupno='AS002459422'

select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='需打印行程单'
where coupno in('AS002434253','AS002448892')

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='020589_20190401'


select tax,stax,totsprice,profit,Mcost,* from Topway..tbcash 
--update Topway..tbcash set totsprice=2650,profit=502
where coupno='AS002461494'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=10839,profit=1629
where coupno='AS002466470'

--会务结算单作废

select Jstatus,* from topway..tbConventionJS
--update topway..tbConventionJS set Jstatus='0',Settleno='0',Pstatus='0',Pdatetime='1900-1-1' 
where Settleno='27201'

--机票结算单信息作废
select settleStatus,* from Topway..tbSettlementApp
--update Topway..tbSettlementApp set settleStatus='3' 
where id='111886'

select wstatus,settleno,* from Topway..tbcash
--update Topway..tbcash set wstatus='0',settleno='0' 
where settleno='111886'

select inf2,settleno,* from Topway..tbReti
--update Topway..tbReti set inf2='0',settleno='0' 
where settleno='111886'

select Status,* from Topway..Tab_WF_Instance
--update Topway..Tab_WF_Instance set Status='4' 
where BusinessID='111886'

select * 
--delete 
from  topway..Tab_WF_Instance_Node where InstanceID in (select id from topway..Tab_WF_Instance where BusinessID='111886') 
and Status='0'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set SpareTC='徐薇'
where coupno='AS001630693'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set SpareTC='崔玉杰',sales='崔玉杰'
where coupno in('AS001630760','AS001630756')

--行程单、特殊票价
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='需打印中文行程单'
where coupno='AS002434294'

--拆分团队票
select Pasname,MobileList,Idno,CostCenter,pcs,Department,BirthPlace,* from topway..tbFiveCoupInfosub 
--update tbFiveCoupInfosub set Idno=Idno+',无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无',MobileList=MobileList+',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='29',Department='无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无',Pasname=Pasname+',乘客2,乘客3,乘客4,乘客5,乘客6,乘客7,乘客8,乘客9,乘客10,乘客11,乘客12,乘客13,乘客14,乘客15,乘客16,乘客17,乘客18,乘客19,乘客20,乘客21,乘客22,乘客23,乘客24,乘客25,乘客26,乘客27,乘客28,乘客29',BirthPlace='1982-01-03,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01'
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002471471')

--重开打印
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus=0,PrDate='1900-01-01'
where TrvId='29918'

--修改UC号（机票）
--select * from Topway..tbCusholder where custname='黄欢'

select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,pform,xfprice,* from Topway..tbcash
--update topway..tbcash set custid='D198516'
 where coupno in ('AS002450558','AS002450624','AS002450629')
 
 select CustId,CmpId,Cmpname,* from Topway..tbFiveCoupInfo 
  --update Topway..tbFiveCoupInfo set CustId='D198516'
  where CoupNo in ('AS002450558','AS002450624','AS002450629')
  
   --修改UC号（TMS)
  select CmpId,CompanyName,CustId,* from homsomDB..Intl_BookingOrders 
  --update homsomDB..Intl_BookingOrders set CustId='D198516'
  where OrderNo in ('IF00033966','IF00033971','IF00033972')
  
  --旅游预算单信息 单位改成个人
  --select * from Topway..tbCusholder where mobilephone='18602103956'
  
select CustomerType,* from topway..tbTravelBudget
--update topway..tbTravelBudget set custid='D198634',cmpid='',Custinfo='18602103956@潘懿芳@@@潘懿芳@18602103956@D198634' ,CustomerType='个人客户'
where trvid='30047'
  
--单位信息

select  Cmpid,Address,un.Phone,COUNT(1) 人数 from homsomDB..Trv_UnitCompanies un
left join homsomDB..Trv_UnitPersons u on un.ID=u.CompanyID
left join homsomDB..Trv_Human h on h.ID=u.ID
where IsDisplay=1 
and Cmpid in('018541',
'000126',
'018021',
'017753',
'017969',
'020342',
'020075',
'018897',
'019786',
'017977',
'019935',
'018743',
'020053',
'016713',
'020421',
'020548',
'018362',
'020324',
'017120',
'018941',
'019270',
'017762',
'017608',
'020646',
'020645',
'017012',
'020550',
'016655',
'020659',
'020524',
'020585',
'020650',
'019505',
'020350',
'020316',
'019360',
'019839',
'020541',
'000370',
'019106',
'020504',
'016336',
'016087',
'018002',
'017999',
'016457',
'020561',
'020360',
'017887',
'018482')
group by Address,un.Phone,Cmpid

--常旅客
select Cmpid,u.Name,CustID,h.Name,h.LastName+'/'+h.FirstName+MiddleName 英文名,(case cr.[type] when 1 then '身份证' when 2 then '护照' else '其他' end) 证件类型,CredentialNo  
 from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons un on un.ID=h.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=un.CompanyID
left join homsomDB..Trv_Credentials cr on cr.HumanID=h.ID
where IsDisplay=1
and Cmpid in('018541',
'000126',
'018021',
'017753',
'017969',
'020342',
'020075',
'018897',
'019786',
'017977',
'019935',
'018743',
'020053',
'016713',
'020421',
'020548',
'018362',
'020324',
'017120',
'018941',
'019270',
'017762',
'017608',
'020646',
'020645',
'017012',
'020550',
'016655',
'020659',
'020524',
'020585',
'020650',
'019505',
'020350',
'020316',
'019360',
'019839',
'020541',
'000370',
'019106',
'020504',
'016336',
'016087',
'018002',
'017999',
'016457',
'020561',
'020360',
'017887',
'018482')
order by Cmpid
