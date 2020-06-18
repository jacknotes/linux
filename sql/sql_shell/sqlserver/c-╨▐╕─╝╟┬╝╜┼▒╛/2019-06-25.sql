--天纳克返佣数据
/*
1 UC016448（分3个成本中心“CA、RP、AM”）
2 UC016713
3 UC018408
4 UC018541
5 UC020085
6 UC020273
7 UC020637 （分3个部门：“CA、TCC、JV”）
8 UC020643
9 UC020655
10 UC220665
11 UC020685
12 UC020742
*/

--有返佣
if  OBJECT_ID('tempdb..#fx') is not null drop table #fx
select cmpcode UC号,u.Name 单位名称,SUM(totprice) 销量,count(1) 段数,SUM(xfprice) 返佣金额
into #fx
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos t on t.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs s on t.ItktBookingSegID=s.ID
left join homsomDB..Trv_UnitCompanies  u on u.Cmpid=c.cmpcode
where --cmpcode in('016713','018408','018541','020085','020273','020643','020655','020665','020685','020742')
cmpcode='020637'
and Department='ca'
and inf=0
and reti=''
--and tickettype='电子票'
and datetime>='2019-04-01'
and xfprice<>0
group by cmpcode,u.Name

--select * from #fx

--无返佣
if  OBJECT_ID('tempdb..#wfx') is not null drop table #wfx
select cmpcode UC号,u.Name 单位名称,SUM(totprice) 销量
into #wfx
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos t on t.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs s on t.ItktBookingSegID=s.ID
left join homsomDB..Trv_UnitCompanies  u on u.Cmpid=c.cmpcode
where --cmpcode in('016713','018408','018541','020085','020273','020643','020655','020665','020685','020742')
cmpcode='020637'
and Department='ca'
and inf=0
and reti=''
--and tickettype='电子票'
and datetime>='2019-04-01'
and xfprice=0
and ride='mu'
and nclass in('U','F','J','Y')
group by cmpcode,u.Name

if  OBJECT_ID('tempdb..#wfx1') is not null drop table #wfx1
select cmpcode UC号,u.Name 单位名称,SUM(totprice) 销量,count(1) 段数
into #wfx1
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos t on t.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs s on t.ItktBookingSegID=s.ID
left join homsomDB..Trv_UnitCompanies  u on u.Cmpid=c.cmpcode
where --cmpcode in('016713','018408','018541','020085','020273','020643','020655','020665','020685','020742')
cmpcode='020637'
and Department='ca'
and inf=0
and reti=''
--and tickettype='电子票'
and datetime>='2019-04-01'
and xfprice=0
group by cmpcode,u.Name

select f.UC号,f.单位名称,f.销量,f.段数,f.返佣金额,w1.销量,w1.段数,w.销量
from #fx f
left join #wfx w on w.UC号=f.UC号
left join #wfx1 w1 on w1.UC号=f.UC号


--UC019808 月星2018年度数据 国内国际总销量、总张数，东上航总销量、总张数、占比，国航总销量、总张数、占比，南航总销量、总张数、占比，东上航总优惠金额
--国内出票数据

if OBJECT_ID('tempdb..#gncp') is not null drop table #gncp
select cmpcode UC号,SUM(totprice) 国内总销量,COUNT(1)国内总张数
--into #gncp
from Topway..tbcash 
where cmpcode='019808'
--and reti<>''
and ModifyBillNumber in ('019808_20180101','019808_20180201','019808_20180301','019808_20180401','019808_20180501','019808_20180601','019808_20180701','019808_20180801','019808_20180901','019808_20181001','019808_20181101','019808_20181201')
and inf=0
group by cmpcode


--select * from #tpf1  select * from #gncp
--select SUM(BillAmount) from Topway..AccountStatement where BillNumber in ('019808_20180101','019808_20180201','019808_20180301','019808_20180401','019808_20180501','019808_20180601','019808_20180701','019808_20180801','019808_20180901','019808_20181001','019808_20181101','019808_20181201')

--退票费
if OBJECT_ID('tempdb..#tpf1') is not null drop table #tpf1
select cmpcode UC号,sum(-totprice) 国内退票费 ,count(1)国内退票张数 
into #tpf1
from Topway..tbReti
where cmpcode='019808'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=0
group by cmpcode

--国际出票数据
if OBJECT_ID('tempdb..#gjcp') is not null drop table #gjcp
select cmpcode UC号,SUM(totprice) 国际总销量,COUNT(1)国际总张数
--into #gjcp
from Topway..tbcash 
where cmpcode='019808'
--and reti<>''
and ModifyBillNumber in ('019808_20180101','019808_20180201','019808_20180301','019808_20180401','019808_20180501','019808_20180601','019808_20180701','019808_20180801','019808_20180901','019808_20181001','019808_20181101','019808_20181201')
and inf=1
group by cmpcode

--select * from #tpf2

--退票费
if OBJECT_ID('tempdb..#tpf2') is not null drop table #tpf2
select cmpcode UC号,sum(-totprice) 国际退票费,count(1)国际退票张数
into #tpf2
from Topway..tbReti
where cmpcode='019808'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
group by cmpcode

--东上航
if OBJECT_ID('tempdb..#dscp') is not null drop table #dscp
select cmpcode UC号,SUM(totprice) 东上航总销量,sum(coupon) 东上航优惠金额,sum(convert(decimal(18,3),isnull(originalprice,0)))-sum(price)协议优惠金额,COUNT(1)东上航总张数
--into #dscp
from Topway..tbcash 
where cmpcode='019808'
--and reti<>''
and ModifyBillNumber in ('019808_20180101','019808_20180201','019808_20180301','019808_20180401','019808_20180501','019808_20180601','019808_20180701','019808_20180801','019808_20180901','019808_20181001','019808_20181101','019808_20181201')
and ride in('FM','MU')
--and originalprice<>''
group by cmpcode



--退票费
if OBJECT_ID('tempdb..#dsf1') is not null drop table #dsf1
select cmpcode UC号,sum(-totprice) 东上航退票费 ,COUNT(1)东上航退票张数
into #dsf1
from Topway..tbReti
where cmpcode='019808'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and ride in('FM','MU')
group by cmpcode

--南航
if OBJECT_ID('tempdb..#nhcp') is not null drop table #nhcp
select cmpcode UC号,SUM(totprice) 南航总销量,COUNT(1)南航总张数
--into #nhcp
from Topway..tbcash 
where cmpcode='019808'
and ModifyBillNumber in ('019808_20180101','019808_20180201','019808_20180301','019808_20180401','019808_20180501','019808_20180601','019808_20180701','019808_20180801','019808_20180901','019808_20181001','019808_20181101','019808_20181201')

and ride in('cz')
group by cmpcode

--退票费
if OBJECT_ID('tempdb..#nsf1') is not null drop table #nsf1
select cmpcode UC号,sum(-totprice) 南航退票费 ,COUNT(1)南航退票张数
into #nsf1
from Topway..tbReti
where cmpcode='019808'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and ride in('cz')
group by cmpcode

--国航
if OBJECT_ID('tempdb..#ghcp') is not null drop table #ghcp
select cmpcode UC号,SUM(totprice) 国航总销量,COUNT(1)国航总张数
--into #ghcp
from Topway..tbcash 
where cmpcode='019808'
--and reti<>''
and ModifyBillNumber in ('019808_20180101','019808_20180201','019808_20180301','019808_20180401','019808_20180501','019808_20180601','019808_20180701','019808_20180801','019808_20180901','019808_20181001','019808_20181101','019808_20181201')

and ride in('ca')
group by cmpcode

--退票费
if OBJECT_ID('tempdb..#gsf1') is not null drop table #gsf1
select cmpcode UC号,sum(price-totprice) 国航退票费,COUNT(1) 国航退票张数
into #gsf1
from Topway..tbReti
where cmpcode='019808'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and ride in('ca')
group by cmpcode

select 国内总销量-国内退票费 as 国内总销量,国内总张数-国内退票张数 as 国内总张数,国际总销量-国际退票费 as 国际总销量,国际总张数-国际退票张数 as 国际总张数,
东上航总销量-东上航退票费 as 东上航总销量,东上航优惠金额,'29860'as 协议优惠金额,东上航总张数-东上航退票张数 as 东上航总张数,'' 占比,国航总销量-国航退票费 as 国航总销量,国航总张数,'' 占比,
南航总销量-南航退票费 as 南航总销量,南航总张数-南航退票张数 as 南航总张数,'' 占比
from #gncp n
left join #tpf1 t1 on t1.UC号=n.UC号
left join #gjcp g on g.UC号=n.UC号
left join #tpf2 t2 on t2.UC号=n.UC号
left join #dscp d1 on d1.UC号=n.UC号
left join #dsf1 d2 on d2.UC号=n.UC号
left join #nhcp n1 on n1.UC号=n.UC号
left join #nsf1 n2 on n2.UC号=n.UC号
left join #ghcp g1 on g1.UC号=n.UC号
left join #gsf1 g2 on g2.UC号=n.UC号

/*
陈总需要了解下列相关UC号内，各舱位出票张数、出票张数占比，金额等相关数据，请提供分析支持。

     UC016888、UC020748、UC020789、UC017735、UC017505

     全价经济舱以上：U/F/P/J/C/D/I/W/Y
     折扣经济舱：B/M/E/H/K/L/N/R/S/Q

     数据自2018.6.1—2019.5.31，满一年按照一年提取，不满一年按照合作之日起开始提取，谢谢！
各舱位出票张数、出票张数占比，金额
*/
select RegisterMonth,* from homsomDB..Trv_UnitCompanies where Cmpid in ('016888','020748','020789','017735','017505')

select cmpcode UC号,nclass 舱位,COUNT(1)张数,SUM(totprice) 销量金额 
from Topway..tbcash 
where cmpcode in('016888','020748','020789','017735','017505')
and datetime>='2018-06-01'
and datetime<'2019-06-01'
and nclass in ('U','F','P','J','C','D','I','W','Y','B','M','E','H','K','L','N','R','S','Q')
group by cmpcode,nclass
order by UC号

select cmpcode UC号,COUNT(1)总张数,SUM(totprice) 总销量金额 
from Topway..tbcash 
where cmpcode in('016888','020748','020789','017735','017505')
and datetime>='2018-06-01'
and datetime<'2019-06-01'
--and nclass in ('U','F','P','J','C','D','I','W','Y','B','M','E','H','K','L','N','R','S','Q')
group by cmpcode


--UC019732修改账单抬头
select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement  set CompanyNameCN='东电化爱普科斯（上海）电子有限公司'
where BillNumber='019732_20190621'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='017903_20190501'

--（产品专用）申请费来源/金额信息（国际）
select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash  set feiyonginfo=''
where coupno='AS002580449'

--机票销售单改为未付
select bpay ,status,opernum,oper2,oth2,totprice,dzhxDate,owe
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
from Topway..tbcash where coupno in ('AS002442898',
'AS002443115',
'AS002443581',
'AS002443588',
'AS002446763',
'AS002446766',
'AS002447022',
'AS002447025',
'AS002449452',
'AS002449458',
'AS002452764',
'AS002452767',
'AS002452861',
'AS002460160',
'AS002460164',
'AS002460163',
'AS002460167',
'AS002460972',
'AS002461780',
'AS002466444',
'AS002467924',
'AS002468495',
'AS002470574',
'AS002470574',
'AS002470576',
'AS002470576',
'AS002471330',
'AS002471337',
'AS002477806',
'AS002477806',
'AS002477821',
'AS002477835',
'AS002477835',
'AS002478148',
'AS002478650',
'AS002479572',
'AS002480528',
'AS002480587',
'AS002484727',
'AS002484767',
'AS002484767',
'AS002484762',
'AS002484770',
'AS002488521',
'AS002488860',
'AS002489255',
'AS002496034',
'AS002496036',
'AS002496040',
'AS002496046',
'AS002497544',
'AS002497862',
'AS002499801',
'AS002502799',
'AS002503844',
'AS002503847',
'AS002504759',
'AS002506355',
'AS002506347',
'AS002506347',
'AS002506379',
'AS002506395',
'AS002506358',
'AS002506382',
'AS002506350',
'AS002506350',
'AS002506340',
'AS002506340',
'AS002506340',
'AS002506344',
'AS002506344',
'AS002506344',
'AS002507949',
'AS002509547',
'AS002510908',
'AS002512055',
'AS002514428',
'AS002517594')


--账单撤销
select HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set HotelSubmitStatus=2
where BillNumber='018004_20190501'

--酒店销售单作废
select status,* from Topway..tbHtlcoupYf 
--update  Topway..tbHtlcoupYf  set status=-2
where CoupNo='PTW085356'

--UC020554删除单位员工
select * from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
 where id in (Select ID from homsomDB..Trv_UnitPersons 
 where companyid=(Select  ID from homsomDB..Trv_UnitCompanies 
 where Cmpid='020554')) and IsDisplay=1
 and Name not in ('范秋丽','翁晓岚')
 
 select * from Topway..tbCusholderM
 --update Topway..tbCusholderM set EmployeeStatus=0
 where cmpid='020554'
 and custname not in ('范秋丽','翁晓岚')
 
 --机票业务顾问信息
 select sales,SpareTC,* from Topway..tbcash 
 --update Topway..tbcash  set SpareTC='张海云'
 where coupno='AS002521203'
 
 
 --结算价差额
 select totsprice,profit,* from Topway..tbcash 
 --update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
 where coupno in('AS002579001','AS002578016','AS002580827','AS002578585','AS002579189')
 
 --促销积点
 select CommissionStatus,appdate,appName,* from Topway..tbDisctCommission 
 --update Topway..tbDisctCommission  set appdate='1900-01-01',appName=null
 where id='56626'
 
 select dsettleno,sdisct,* from Topway..tbcash 
 --update Topway..tbcash  set dsettleno='56626',sdisct=0
 where dsettleno='56626'
 
 
 --重开打印
 select pstatus,prdate,settleStatus,* from Topway..tbSettlementApp 
 --update Topway..tbSettlementApp  set pstatus=0,prdate='1900-01-01'
 where id in ('113540','113542','113548')
 
  --重开打印
 select Pstatus,PrDate,SettleStatus,PrName,* from Topway..tbConventionSettleApp 
 --update Topway..tbConventionSettleApp  set SettleStatus=1,Pstatus=0,PrDate='1900-01-01'
 where Id in('3942','3943')
 
 select pstatus,prdate,HXQM,* from Topway..tbHtlSettlementApp 
 --update Topway..tbHtlSettlementApp  set HXQM=''
 where id='26072'
 
 select Pstatus,PrDate,PrName,SettleStatus,* from Topway..tbTrvSettleApp 
 --update Topway..tbTrvSettleApp  set Pstatus=0,PrDate='1900-01-01',PrName='',SettleStatus=1
 where Id='27578'
 
 /*
UC018362 艾蒙斯特朗流体系统（上海）有限公司
2018年全年
字段要求：人员信息 日期 出发地 目的地 舱位等级 销售价格
*/
select top 100 * from homsomDB..Trv_ItktBookingSegs

SELECT coupno 销售单号,pasname 乘机人,convert(varchar(10),datetime,120) 出票日期,begdate 起飞日期,Arriving 到达日期,c.route 行程,nclass 舱位等级,totprice 销售价 ,reti 退票单号
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos t on t.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs s on t.ItktBookingSegID=s.ID
where cmpcode='018362'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf!=-1
order by 出票日期

--重开打印
select Pstatus,Pdatetime,* from Topway..tbTrvJS 
--update Topway..tbTrvJS  set Pstatus=0,Pdatetime='1900-01-01'
where TrvId in('27578')

--酒店结算单作废
select settleStatus,* from Topway..tbHtlSettlementApp 
--update Topway..tbHtlSettlementApp  set settleStatus=3
where id='26073'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set SpareTC='汪媛'
where coupno='AS002582725'

select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set SpareTC='汪媛'
where coupno='AS002520367'