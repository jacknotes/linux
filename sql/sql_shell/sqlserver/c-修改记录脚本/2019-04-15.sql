select sum(totprice) from Topway..tbcash 
where ModifyBillNumber='020459_20181101' and custid not in('D618538')
AND tickettype NOT IN ('改期费', '升舱费','改期升舱')
--and inf=0
--and reti<>''



SELECT T1.ride,SUM(totprice) 合计销量,COUNT(1) 合计张数  FROM Topway..tbcash T1 WITH (NOLOCK)
--INNER JOIN ehomsom..tbInfAirCompany T2 WITH (NOLOCK) ON T1.ride=T2.code2
WHERE
inf<>-1
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND T1.route NOT LIKE '%改期%' 
AND T1.route NOT LIKE '%升舱%'
AND ISNULL(T1.ModifyBillNumber,'') <> ''
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.ride

--2018年10月-2019年3月供应商来源为HSBSP的单位客户前300名BSP销量数据

select top 300 cmpcode,un.Name,SUM(totprice) 销量 from Topway..V_TicketInfo v
left join homsomDB..Trv_UnitCompanies un on un.Cmpid=v.cmpcode
where datetime>='2018-10-01'
and datetime<'2019-04-01'
and tickettype not in ('改期费', '升舱费','改期升舱')
and cmpcode<>''
group by cmpcode,un.Name
order by 销量 desc

select  cmpcode,un.Name,SUM(totprice) 销量 from Topway..V_TicketInfo v
left join homsomDB..Trv_UnitCompanies un on un.Cmpid=v.cmpcode
where datetime>='2019-04-01'
and datetime<'2019-05-01'
and tickettype not in ('改期费', '升舱费','改期升舱')
and cmpcode in('018661',
'016448',
'018202',
'019808',
'019956',
'020459',
'019791',
'018734',
'016564',
'020084',
'017205',
'006299',
'019334',
'019539',
'019358',
'018781',
'019505',
'019885',
'020350',
'018309',
'018294',
'019361',
'020432',
'019331',
'019641',
'019259',
'020027',
'018431',
'016497',
'017888',
'016511',
'018919',
'019294',
'017923',
'020481',
'019293',
'016477',
'019392',
'019301',
'020029',
'017275',
'020016',
'020278',
'016751',
'020645',
'016363',
'018265',
'017739',
'017189',
'018156',
'019845',
'019394',
'020237',
'015828',
'020543',
'016400',
'016712',
'020316',
'019360',
'016465',
'019799',
'018038',
'019637',
'019989',
'019974',
'017996',
'016428',
'016426',
'020362',
'020113',
'016602',
'017020',
'019550',
'016588',
'018030',
'016362',
'018541',
'017012',
'020064',
'018463',
'000126',
'019839',
'020359',
'020297',
'019507',
'018210',
'018021',
'020380',
'018080',
'020550',
'016232',
'016773',
'019626',
'020165',
'016655',
'017753',
'020099',
'017745',
'020146',
'014412',
'017903',
'017969',
'020541',
'020342',
'017670',
'016641',
'019688',
'000370',
'016689',
'020659',
'019990',
'016991',
'018615',
'016402',
'018591',
'020202',
'019798',
'019143',
'020075',
'020524',
'019830',
'018897',
'017795',
'019786',
'019106',
'017920',
'020585',
'017210',
'018381',
'017608',
'019222',
'018821',
'017730',
'017692',
'018449',
'018163',
'020646',
'020504',
'017977',
'016608',
'018353',
'019935',
'016485',
'018743',
'019986',
'020053',
'019788',
'017688',
'019848',
'019775',
'016713',
'016336',
'020421',
'020548',
'016684',
'020650',
'019653',
'018362',
'016873',
'020324',
'019471',
'016087',
'018002',
'017999',
'016457',
'016414',
'017120',
'019502',
'018257',
'019226',
'018941',
'017491',
'020561',
'019321',
'019270',
'020360',
'020583',
'019190',
'006596',
'018827',
'017887',
'016500',
'016498',
'019658',
'017762',
'018482',
'020315',
'019588',
'016578',
'020365',
'015940',
'019607',
'020231',
'018570',
'019333',
'018793',
'020631',
'006944',
'018773',
'017408',
'019634',
'017364',
'020305',
'018004',
'019807',
'017674',
'015918',
'017426',
'016640',
'019012',
'019591',
'019315',
'017602',
'019850',
'016696',
'016179',
'019859',
'020667',
'018642',
'020314',
'016610',
'020272',
'018865',
'020589',
'017865',
'019256',
'018627',
'019230',
'017065',
'019249',
'020039',
'018408',
'016264',
'020521',
'019401',
'020063',
'017290',
'020418',
'016532',
'016884',
'017153',
'017659',
'019959',
'020261',
'020665',
'016560',
'019708',
'019976',
'020228',
'016834',
'020204',
'020157',
'020396',
'018400',
'018724',
'020171',
'018637',
'020158',
'020176',
'017415',
'000037',
'018589',
'020463',
'019251',
'019515',
'020022',
'017376',
'018064',
'018110',
'019159',
'020644',
'016917',
'020405',
'016267',
'001787',
'020705',
'019714',
'017642',
'018304',
'020212',
'019325',
'020564',
'017955',
'019822',
'016531',
'016239',
'020457',
'019234',
'020221',
'017944',
'018283',
'019342',
'020553',
'017506',
'016490',
'019975',
'017232',
'018670',
'017300',
'018608')
group by cmpcode,un.Name
order by 销量 desc

--重开打印
select prdate,pstatus,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set prdate='1900-01-01',pstatus=0
where CoupNo='PTW079321'

--补票号
--select pasname,* from Topway..tbcash where coupno='AS002391352'
update topway..tbcash set pasname='YUAN/XIAOYANMS',tcode='618',ticketno='2427869173' where coupno in ('AS002391352') and pasname='乘客0'
update topway..tbcash set pasname='CAI/YANWENMS',tcode='618',ticketno='2427869174' where coupno in ('AS002391352') and pasname='乘客1'
update topway..tbcash set pasname='CAO/LANMS',tcode='618',ticketno='2427869175' where coupno in ('AS002391352') and pasname='乘客2'
update topway..tbcash set pasname='GUAN/QIANMS',tcode='618',ticketno='2427869176' where coupno in ('AS002391352') and pasname='乘客3'
update topway..tbcash set pasname='HUANG/ZHIJIONGMR',tcode='618',ticketno='2427869177' where coupno in ('AS002391352') and pasname='乘客4'
update topway..tbcash set pasname='JIN/LIMR',tcode='618',ticketno='2427869178' where coupno in ('AS002391352') and pasname='乘客5'
update topway..tbcash set pasname='JIN/XINXIAOMS',tcode='618',ticketno='2427869179' where coupno in ('AS002391352') and pasname='乘客6'
update topway..tbcash set pasname='LI/PEIJINMR',tcode='618',ticketno='2427869180' where coupno in ('AS002391352') and pasname='乘客7'
update topway..tbcash set pasname='MEI/WEIQIANGMR',tcode='618',ticketno='2427869181' where coupno in ('AS002391352') and pasname='乘客8'
update topway..tbcash set pasname='RUAN/YONGMR',tcode='618',ticketno='2427869184' where coupno in ('AS002391352') and pasname='乘客9'
update topway..tbcash set pasname='TANG/CHUNMEIMS',tcode='618',ticketno='2427869185' where coupno in ('AS002391352') and pasname='乘客10'
update topway..tbcash set pasname='WANG/AIQINGMS',tcode='618',ticketno='2427869186' where coupno in ('AS002391352') and pasname='乘客11'
update topway..tbcash set pasname='WANG/YINGMS',tcode='618',ticketno='2427869187' where coupno in ('AS002391352') and pasname='乘客12'
update topway..tbcash set pasname='WU/HUIFENMS',tcode='618',ticketno='2427869188' where coupno in ('AS002391352') and pasname='乘客13'
update topway..tbcash set pasname='XU/PENGCHENGMR',tcode='618',ticketno='2427869189' where coupno in ('AS002391352') and pasname='乘客14'
update topway..tbcash set pasname='YAN/MINGCHENGMR',tcode='618',ticketno='2427869190' where coupno in ('AS002391352') and pasname='乘客15'
update topway..tbcash set pasname='YIN/LIMS',tcode='618',ticketno='2427869191' where coupno in ('AS002391352') and pasname='乘客16'
update topway..tbcash set pasname='WANG/DACHUNMR',tcode='618',ticketno='2427869192' where coupno in ('AS002391352') and pasname='乘客17'
update topway..tbcash set pasname='XU/FENGLINMS',tcode='618',ticketno='2427869166' where coupno in ('AS002391352') and pasname='乘客18'
update topway..tbcash set pasname='HUANG/DANJIEMS',tcode='618',ticketno='2427869167' where coupno in ('AS002391352') and pasname='乘客19'

update topway..tbcash set pasname='JIN/YUCHENGMSTR',tcode='618',ticketno='2427869182' where coupno in ('AS002391351') and pasname='乘客0'
update topway..tbcash set pasname='MEI/YUTANGMISS',tcode='618',ticketno='2427869193' where coupno in ('AS002391351') and pasname='乘客1'
update topway..tbcash set pasname='YAN/CHENANMISS',tcode='618',ticketno='2427869194' where coupno in ('AS002391351') and pasname='乘客2'
update topway..tbcash set pasname='YAN/CHENYUMISS',tcode='618',ticketno='2427869195' where coupno in ('AS002391351') and pasname='乘客3'
update topway..tbcash set pasname='ZHAO/WENMISS',tcode='618',ticketno='2427869196' where coupno in ('AS002391351') and pasname='乘客4'

update topway..tbcash set pasname='NIU/DONGJIANMR',tcode='618',ticketno='2427865881' where coupno in ('AS002391350') and pasname='乘客0'
update topway..tbcash set pasname='XU/YANFEIMS',tcode='618',ticketno='2427865882' where coupno in ('AS002391350') and pasname='乘客1'
update topway..tbcash set pasname='LIU/XUMR',tcode='618',ticketno='2427865883' where coupno in ('AS002391350') and pasname='乘客2'
update topway..tbcash set pasname='PENG/YANGMS',tcode='618',ticketno='2427865884' where coupno in ('AS002391350') and pasname='乘客3'
update topway..tbcash set pasname='ZHOU/YANMR',tcode='618',ticketno='2427865885' where coupno in ('AS002391350') and pasname='乘客4'
update topway..tbcash set pasname='ZHU/XUENANMS',tcode='618',ticketno='2427865886' where coupno in ('AS002391350') and pasname='乘客5'
update topway..tbcash set pasname='JIANG/TAOMR',tcode='618',ticketno='2427865887' where coupno in ('AS002391350') and pasname='乘客6'
update topway..tbcash set pasname='BAI/YINGMS',tcode='618',ticketno='2427865888' where coupno in ('AS002391350') and pasname='乘客7'

update topway..tbcash set pasname='FENG/YIMISS',tcode='618',ticketno='2427865889' where coupno in ('AS002391349') and pasname='乘客0'
update topway..tbcash set pasname='JIANG/BAICHENGMSTR',tcode='618',ticketno='2427865890' where coupno in ('AS002391349') and pasname='乘客1'

--重开打印
select pstatus,prdate,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set pstatus=0,prdate='1900-01-01'
where CoupNo='-PTW079321'

--修改申请费来源
select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash  set feiyonginfo='申请座位MYI'
where coupno in('AS002394407','AS002389980','AS002388599')




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

	----出票明细
	IF OBJECT_ID('tempdb.dbo.#emp') IS NOT NULL DROP TABLE #emp
	SELECT ROW_NUMBER()OVER(ORDER BY t2.depOrder,t1.idnumber) idx,empname,team
	INTO #emp 
	from emppwd t1 LEFT JOIN dbo.EmpSysSetting t2 ON t1.team=t2.dep AND t2.ntype=2 where t1.dep = '运营部' order by t2.depOrder,t1.idnumber 
--select * from #emp


	IF OBJECT_ID('tempdb.dbo.#a') IS NOT NULL DROP TABLE #a
	select isnull(team,'') as 小组
	,SpareTC as 操作业务顾问,datetime as 出票日期,coupno as 销售单号,tcode+ticketno as 票号,begdate as 起飞时间,ride as 航司,nclass as 舱位,TicketOperationRemark as 人工出票原因,
	(case cmpcode when '' then '' else  ISNULL('UC'+cmpcode,'') end )  as 单位编号,c.route as 航程,quota1+quota2+quota3+quota4 as 定额费
	,totprice as 销售价,totsprice as 结算价,profit-Mcost as 销售利润,reti as 退票
	into #a
	from tbcash c
	left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
	left join #emp emp on Emp.empname=c.SpareTC
	where (datetime>='2019-03-01' and datetime<CONVERT(varchar(20),DateAdd(day,1,'2019-04-15'),23))
	and t_source like'HS易商%D' and inf=0
	--and trvYsId=0 and ConventionYsId=0
	and 
	((ride='HO' and nclass in ('A','U','H','Q','V','W','S','T','Z','E')) OR
	(ride='SC' AND nclass IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
	(ride='RY' AND nclass IN ('M','L','K','N','Q','V','T','R','U')) OR
	(ride='ZH' AND nclass IN ('M','U','H','Q','V','W','S','E')) OR
	(ride='CZ' AND nclass IN ('V','E','L','A','U','H','M','B','C','Z')) OR
	(ride='HU' AND nclass IN ('Q')) OR
	(ride='KY' AND nclass IN ('D')) OR
	(ride='JD' AND nclass IN ('W')) OR
	(ride='UQ' AND nclass IN ('Q')) OR
	(ride='GJ' AND nclass IN ('X')) OR
	(ride='JR' AND nclass IN ('P')) OR
	(ride='3U' AND nclass IN ('W','G','S','L','E','V','R','K','N')) OR
	(ride='GS' AND nclass IN ('Q')) OR
	(ride='8L' AND nclass IN ('K','L','M','X','V','N','A','U','T','Z','R'))
	)
	order by Emp.idx
	
	--select * from #a

	select ROW_NUMBER()OVER(ORDER BY cash.小组) 序号,cash.* from #a cash
	where 销售单号 not in (select 销售单号
from  #a a 
where ((航司='HO' and 舱位 in ('A','U','H','Q','V','W','S','T','Z','E')) OR
(航司='SC' AND 舱位 IN ('M','H','K','L','P','Q','G','V','U','Z')) OR
(航司='RY' AND 舱位 IN ('M','L','K','N','Q','V','T','R','U')) OR
(航司='ZH' AND 舱位 IN ('M','U','H','Q','V','W','S','E')) OR
(航司='CZ' AND 舱位 IN ('V','E','L','A','U','H','M','B','C','Z')) OR
(航司='3U' AND 舱位 IN ('G','S','L','E','V','R','K','N')) or
(航司='8L' AND 舱位 IN ('K','L','M','X','V','N','A','U','T','Z','R'))
)
and 人工出票原因 NOT like ('%直加%')
) --出票明细


select * from Topway..tbcash where t_source like'%HS易商XXD%'

/*
请按以下要求拉取相关数据（包含退改）：

1、按UC020237 北京盛世宏明投资基金管理有限公司的成本中心拉取2019年第一季度的相关数据，字段如下：

销量、张数

2、最后拉取这家公司总的2019年第一季度的数据，字段如下：

销量、张数
*/
select * from Topway..tbCompanyM where cmpid='020237'
select * from homsomDB..Trv_UnitCompanies where Cmpid='020237'
select * from homsomDB..Trv_CostCenter where CompanyID='B2468521-19F1-469A-9CCD-A87800EE18D9'

--一月
select CostCenter 成本中心,SUM(totprice) 销量,COUNT(id) 张数 
from Topway..V_TicketInfo 
where cmpcode='020237'
and datetime>='2019-01-01'
and datetime<'2019-02-01'
group by CostCenter
order by 销量 desc

--二月
select CostCenter 成本中心,SUM(totprice) 销量,COUNT(id) 张数 
from Topway..V_TicketInfo 
where cmpcode='020237'
and datetime>='2019-02-01'
and datetime<'2019-03-01'
group by CostCenter
order by 销量 desc

--三月
select CostCenter 成本中心,SUM(totprice) 销量,COUNT(id) 张数 
from Topway..V_TicketInfo 
where cmpcode='020237'
and datetime>='2019-03-01'
and datetime<'2019-04-01'
group by CostCenter
order by 销量 desc




select SUM(totprice) 合计销量,COUNT(id) 合计张数 
from Topway..V_TicketInfo 
where cmpcode='020237'
and datetime>='2019-01-01'
and datetime<'2019-04-01'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=5239,profit=605
where coupno='AS002390190'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=5382,profit=1237
where coupno='AS002394222'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=2624,profit=62
where coupno='AS002391837'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=4223,profit=3958
where coupno='AS002395371'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=2154,profit=222
where coupno='AS002395856'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=33467,profit=5525
where coupno='AS002393200'

--申请费用来源
select feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash set feiyonginfo='申请座位ZYI'
where coupno='as002359459'

/*
        身份证 = 1,    
        护照 = 2,    
        学生证 = 3,    
        军人证 = 4,    
        回乡证 = 5,    
        外国人永久居留证 = 6,    
        港澳通行证 = 7,    
        台湾通行证 = 8,    
        国际海员证 = 9,    
        台胞证 = 10,    
        其他 = 11
  */ 
--单位常旅客
select un.Name,h.Name,LastName+'/'+MiddleName+FirstName Ename, 
(case c.Type when '1' then '身份证' when '2' then '护照' when '3' then '学生证' when '4' then '军人证' when '5' then '回乡证'
 when '6' then '外国人永久居留证' when '7' then '港澳通行证' when '8' then '台湾通行证' when '9' then '国际海员证' when '10' then '台胞证' else '' end) 证件类型,
 CredentialNo
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on h.ID=u.ID
left join homsomDB..Trv_Credentials c on c.HumanID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where IsDisplay=1
and Cmpid in('020359',
'017275',
'016448',
'016511',
'016602',
'016712',
'000370',
'015828',
'016400',
'017012',
'017020',
'017205',
'017408',
'017454',
'017730',
'017739',
'017996',
'018038',
'018156',
'018202',
'018326',
'018362',
'018463',
'018661',
'018781',
'018886',
'019259',
'019845',
'019792',
'019802',
'019805',
'019807',
'019784',
'019944',
'019959',
'019983',
'020016',
'020278')
order by un.Name

--插入票号
--select pasname,* from Topway..tbcash where coupno='AS002400985'

update topway..tbcash set pasname='PANG/YIWAN',tcode='781',ticketno='2319973994' where coupno in ('AS002400985') and pasname='乘客0'
update topway..tbcash set pasname='PENG/YICAI',tcode='781',ticketno='2319973995' where coupno in ('AS002400985') and pasname='乘客1'
update topway..tbcash set pasname='SHI/KAI',tcode='781',ticketno='2319973996' where coupno in ('AS002400985') and pasname='乘客2'
update topway..tbcash set pasname='SU/NA',tcode='781',ticketno='2319973997' where coupno in ('AS002400985') and pasname='乘客3'
update topway..tbcash set pasname='TANG/FENGLONG',tcode='781',ticketno='2319973998' where coupno in ('AS002400985') and pasname='乘客4'
update topway..tbcash set pasname='WANG/JIE',tcode='781',ticketno='2319973999' where coupno in ('AS002400985') and pasname='乘客5'
update topway..tbcash set pasname='WEI/PIXIA',tcode='781',ticketno='2319974000' where coupno in ('AS002400985') and pasname='乘客6'
update topway..tbcash set pasname='ZENG/CHEN',tcode='781',ticketno='2319974001' where coupno in ('AS002400985') and pasname='乘客7'
update topway..tbcash set pasname='ZHANG/XIULIN',tcode='781',ticketno='2319974002' where coupno in ('AS002400985') and pasname='乘客8'
update topway..tbcash set pasname='ZHU/SHA',tcode='781',ticketno='2319974003' where coupno in ('AS002400985') and pasname='乘客9'
update topway..tbcash set pasname='ZHU/WEIWEI',tcode='781',ticketno='2319974004' where coupno in ('AS002400985') and pasname='乘客10'
update topway..tbcash set pasname='CAO/HONGYU',tcode='781',ticketno='2319974016' where coupno in ('AS002400985') and pasname='乘客11'
update topway..tbcash set pasname='CHEN/YANBO',tcode='781',ticketno='2319974017' where coupno in ('AS002400985') and pasname='乘客12'
update topway..tbcash set pasname='FENG/YINGYE',tcode='781',ticketno='2319974018' where coupno in ('AS002400985') and pasname='乘客13'
update topway..tbcash set pasname='GAO/LINGLING',tcode='781',ticketno='2319974019' where coupno in ('AS002400985') and pasname='乘客14'
update topway..tbcash set pasname='GUO/CHUQIAO',tcode='781',ticketno='2319974020' where coupno in ('AS002400985') and pasname='乘客15'
update topway..tbcash set pasname='HE/RU',tcode='781',ticketno='2319974021' where coupno in ('AS002400985') and pasname='乘客16'
update topway..tbcash set pasname='HUANG/JUAN',tcode='781',ticketno='2319974022' where coupno in ('AS002400985') and pasname='乘客17'
update topway..tbcash set pasname='LIU/XIANG',tcode='781',ticketno='2319974023' where coupno in ('AS002400985') and pasname='乘客18'
update topway..tbcash set pasname='LIU/XUELING',tcode='781',ticketno='2319974024' where coupno in ('AS002400985') and pasname='乘客19'
update topway..tbcash set pasname='LIU/YIBIN',tcode='781',ticketno='2319974025' where coupno in ('AS002400985') and pasname='乘客20'
update topway..tbcash set pasname='LUN/LIN',tcode='781',ticketno='2319974026' where coupno in ('AS002400985') and pasname='乘客21'
update topway..tbcash set pasname='LUO/WEI',tcode='781',ticketno='2319974027' where coupno in ('AS002400985') and pasname='乘客22'
