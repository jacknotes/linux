--单位客户授信额度调整
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement set SX_TotalCreditLine=1000000
where BillNumber='020350_20190501'

--旅游收款单信息
select * from Topway..tbTrvKhTk 
--update Topway..tbTrvKhTk  set AcountInfo='王倚安||==||招商银行长宁支行||==||6225882125103991'
where TrvId='30047'  and Id='301211'

select SUM(totprice) from Topway..tbcash where cmpcode='020350'
and datetime>='2019-04-01' and datetime<'2019-05-01'
and inf=1


--常旅客身份证显示
select Type, * from homsomDB..Trv_Credentials 
--update homsomDB..Trv_Credentials  set Type=1
where HumanID='0B8940D6-4A21-42CD-96D8-A99000FFCBFC'

--修改退票审核时间
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti set ExamineDate='2019-05-24'
where reno='0435915'

--删除到账认领
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail 
where money='13459.5' and date='2019-05-29'
and id='CEEA2FA0-7CE3-4BD1-834C-55FD93E95DEB'

select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail 
where money='162628' and date='2019-05-29'
and id='02F74C50-FE0E-40FE-84E2-5B705A93206E'

select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail 
where money='54205' and date='2019-05-29'
and id='0CEEFA70-BCA2-4C84-B67C-8F5FEC1EC238'

select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail 
where money='12984' and date='2019-05-29'
and id='963270F7-3E89-439B-B3D9-08F075254008'

select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail 
where money='30089' and date='2019-05-29'
and id='562A450E-D795-4FBE-BE9A-843B95D57558'

select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail 
where money='83114' and date='2019-05-29'
and id='BC72C429-AFE4-4F39-88C0-B64ACB2C067C'

--修改UC号（机票）

select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,pform,xfprice,* from Topway..tbcash
--update topway..tbcash set cmpcode='018756',OriginalBillNumber='018756_20190501',custid='D595444'
 where coupno in ('AS002512684')
 
 select * from Topway..tbcash where coupno='AS002498653'
 select * from Topway..tbFiveCoupInfo where CoupNo='AS002498653'

--重开打印
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='30110' and Id='228038'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=2736,profit=1504
where coupno='AS002503819'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=5074,profit=308
where coupno='AS002506413'

 select top 100 * from homsomDB..Trv_Passengers
--出票人员明细
if  OBJECT_ID('tempdb..#rs') is not null drop table #rs
select distinct cmpcode,pasname,coupno,cr.CredentialNo,count(1)张数
into #rs
from Topway..tbcash c with (nolock)
left join homsomDB..Trv_Credentials cr on cr.CredentialNo=c.idno
where (cr.CredentialNo  like'P%' or cr.CredentialNo like'G%' or cr.CredentialNo like'E%')
and  cmpcode  in ('017474',
'017283',
'016884',
'016309',
'017016',
'017569',
'016670',
'009005',
'017754',
'016525',
'017577',
'017392',
'016267',
'017122',
'016858',
'016826',
'020774',
'020753',
'020756',
'016379',
'020680',
'017088',
'020664',
'020639',
'020630',
'020617',
'020579',
'020583',
'020594',
'020598',
'020570',
'020556',
'020483',
'020547',
'020538',
'020508',
'020490',
'020470',
'020475',
'020447',
'020453',
'020455',
'020327',
'020334',
'020304',
'020283',
'020289',
'020296',
'020346',
'020366',
'020371',
'020401',
'020405',
'020413',
'020207',
'020214',
'020218',
'020264',
'020269',
'020272',
'020187',
'020192',
'020195',
'020199',
'020221',
'020224',
'020238',
'020241',
'020174',
'020138',
'020111',
'020112',
'020115',
'020118',
'020038',
'019969',
'020061',
'020062',
'020028',
'019982',
'020022',
'019992',
'020001',
'019943',
'019812',
'019908',
'019843',
'019788',
'019760',
'019727',
'019731',
'019629',
'019712',
'019679',
'019603',
'019584',
'019524',
'019461',
'019420',
'019429',
'019366',
'019333',
'019284',
'019212',
'019252',
'019234',
'019072',
'019097',
'018964',
'018989',
'018937',
'018911',
'018886',
'018816',
'018567',
'018633',
'018580',
'018537',
'018486',
'018546',
'018412',
'018367',
'018382',
'018271',
'018220',
'018103',
'017985',
'017924',
'016344',
'017872',
'017800',
'017786',
'016362',
'017893',
'017579',
'017128',
'017549',
'016617',
'007638',
'016500',
'017154',
'016287',
'017680',
'016420',
'017191',
'018539',
'018676',
'018743',
'018751',
'019462',
'019463',
'019448',
'019583',
'019735',
'020045',
'020107',
'020110',
'020282',
'020298',
'020302',
'020720',
'020694',
'017300',
'017663',
'017504',
'017101',
'017368',
'016262',
'017667',
'016795',
'020699',
'020649',
'020656',
'020553',
'020567',
'020591',
'020497',
'020514',
'020491',
'020430',
'020312',
'020314',
'020335',
'020360',
'020364',
'020212',
'020261',
'020266',
'020128',
'020130',
'020124',
'020181',
'020113',
'019983',
'019979',
'020015',
'019771',
'019855',
'019784',
'019628',
'019520',
'019580',
'019540',
'019435',
'019502',
'019145',
'019183',
'019235',
'019273',
'019290',
'018938',
'018943',
'018902',
'018892',
'019049',
'018690',
'018724',
'018714',
'018652',
'018480',
'018451',
'018560',
'018232',
'018283',
'018296',
'018415',
'018418',
'018395',
'018116',
'018141',
'018161',
'018017',
'017956',
'017957',
'017980',
'017944',
'017931',
'016284',
'017822',
'017914',
'017319',
'017454',
'016610',
'017493',
'016773',
'016354',
'016339',
'016859',
'016640',
'016707',
'017135',
'017258')
and datetime>'2018-01-01'
and datetime<'2019-04-30'
and inf=0
group by pasname,cmpcode,cr.CredentialNo,coupno
order by cmpcode

select distinct cmpcode,pasname,CredentialNo from #rs

select top 100 * from homsomDB..Trv_DomesticTicketRecord

select distinct Cmpid,h.Name,cr.CredentialNo  from homsomDB..Trv_DomesticTicketRecord d with (nolock)
inner join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
inner join homsomDB..Trv_Passengers pa on pa.ItktBookingID=p.ItktBookingID
inner join homsomDB..Trv_UnitPersons un on un.ID=pa.UPID
inner join homsomDB..Trv_Human h on h.ID=un.ID
inner join homsomDB..Trv_Credentials cr on cr.HumanID=h.ID
inner join homsomDB..Trv_UnitCompanies u on u.ID=un.CompanyID
where h.Name<>''
and Cmpid in('017474',
'017283',
'016884',
'016309',
'017016',
'017569',
'016670',
'009005',
'017754',
'016525',
'017577',
'017392',
'016267',
'017122',
'016858',
'016826',
'020774',
'020753',
'020756',
'016379',
'020680',
'017088',
'020664',
'020639',
'020630',
'020617',
'020579',
'020583',
'020594',
'020598',
'020570',
'020556',
'020483',
'020547',
'020538',
'020508',
'020490',
'020470',
'020475',
'020447',
'020453',
'020455',
'020327',
'020334',
'020304',
'020283',
'020289',
'020296',
'020346',
'020366',
'020371',
'020401',
'020405',
'020413',
'020207',
'020214',
'020218',
'020264',
'020269',
'020272',
'020187',
'020192',
'020195',
'020199',
'020221',
'020224',
'020238',
'020241',
'020174',
'020138',
'020111',
'020112',
'020115',
'020118',
'020038',
'019969',
'020061',
'020062',
'020028',
'019982',
'020022',
'019992',
'020001',
'019943',
'019812',
'019908',
'019843',
'019788',
'019760',
'019727',
'019731',
'019629',
'019712',
'019679',
'019603',
'019584',
'019524',
'019461',
'019420',
'019429',
'019366',
'019333',
'019284',
'019212',
'019252',
'019234',
'019072',
'019097',
'018964',
'018989',
'018937',
'018911',
'018886',
'018816',
'018567',
'018633',
'018580',
'018537',
'018486',
'018546',
'018412',
'018367',
'018382',
'018271',
'018220',
'018103',
'017985',
'017924',
'016344',
'017872',
'017800',
'017786',
'016362',
'017893',
'017579',
'017128',
'017549',
'016617',
'007638',
'016500',
'017154',
'016287',
'017680',
'016420',
'017191',
'018539',
'018676',
'018743',
'018751',
'019462',
'019463',
'019448',
'019583',
'019735',
'020045',
'020107',
'020110',
'020282',
'020298',
'020302',
'020720',
'020694',
'017300',
'017663',
'017504',
'017101',
'017368',
'016262',
'017667',
'016795',
'020699',
'020649',
'020656',
'020553',
'020567',
'020591',
'020497',
'020514',
'020491',
'020430',
'020312',
'020314',
'020335',
'020360',
'020364',
'020212',
'020261',
'020266',
'020128',
'020130',
'020124',
'020181',
'020113',
'019983',
'019979',
'020015',
'019771',
'019855',
'019784',
'019628',
'019520',
'019580',
'019540',
'019435',
'019502',
'019145',
'019183',
'019235',
'019273',
'019290',
'018938',
'018943',
'018902',
'018892',
'019049',
'018690',
'018724',
'018714',
'018652',
'018480',
'018451',
'018560',
'018232',
'018283',
'018296',
'018415',
'018418',
'018395',
'018116',
'018141',
'018161',
'018017',
'017956',
'017957',
'017980',
'017944',
'017931',
'016284',
'017822',
'017914',
'017319',
'017454',
'016610',
'017493',
'016773',
'016354',
'016339',
'016859',
'016640',
'016707',
'017135',
'017258') and IsDisplay=1 and d.HandleStatus=3
and (cr.Type=1 or cr.CredentialNo like'E%' or cr.CredentialNo like'G%' or cr.CredentialNo like'p%')


--行程单
select info3,* from topway..tbcash 
--update topway..tbcash  set info3='需打印行程单'
where coupno in('AS002430649','AS002485678')


/*
  请帮忙拉取如下航司的2018.1.1-2019.4.30的消费数据，便于引导客户签订大客户协议。
1 以下航司，每家航司前10的单位 ，需UC号和单位全称、排名、结算价合计，出票航线明细。
1) UA 
2) SQ 
3) AF+KL
4) LH+OS+LX
5) KA+CX
6) NH
7) EK
8) DL
9) AA
10)HX
*/
if OBJECT_ID('tempdb..#A') IS NOT NULL DROP TABLE #A
select  top 10 cmpcode,u.Name,SUM(totsprice) 结算价合计,'HX' 航司
INTO #A
from Topway..tbcash t
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=t.cmpcode
where datetime >='2018-01-01'
and datetime<'2019-05-01'
and ride='HX'
and cmpcode<>''
group by cmpcode,u.Name,ride
order by 结算价合计 desc

if OBJECT_ID('tempdb..#B') IS NOT NULL DROP TABLE #B
select  top 10 cmpcode,u.Name,SUM(totsprice) 结算价合计,'AA' 航司
INTO #B
from Topway..tbcash t
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=t.cmpcode
where datetime >='2018-01-01'
and datetime<'2019-05-01'
and ride='AA'
and cmpcode<>''
group by cmpcode,u.Name,ride
order by 结算价合计 desc

if OBJECT_ID('tempdb..#C') IS NOT NULL DROP TABLE #C
select  top 10 cmpcode,u.Name,SUM(totsprice) 结算价合计,'DL' 航司
INTO #C
from Topway..tbcash t
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=t.cmpcode
where datetime >='2018-01-01'
and datetime<'2019-05-01'
and ride='DL'
and cmpcode<>''
group by cmpcode,u.Name,ride
order by 结算价合计 desc

if OBJECT_ID('tempdb..#D') IS NOT NULL DROP TABLE #D
select  top 10 cmpcode,u.Name,SUM(totsprice) 结算价合计,'EK' 航司
INTO #D
from Topway..tbcash t
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=t.cmpcode
where datetime >='2018-01-01'
and datetime<'2019-05-01'
and ride='EK'
and cmpcode<>''
group by cmpcode,u.Name,ride
order by 结算价合计 desc

if OBJECT_ID('tempdb..#E') IS NOT NULL DROP TABLE #E
select  top 10 cmpcode,u.Name,SUM(totsprice) 结算价合计,'NH' 航司
INTO #E
from Topway..tbcash t
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=t.cmpcode
where datetime >='2018-01-01'
and datetime<'2019-05-01'
and ride='NH'
and cmpcode<>''
group by cmpcode,u.Name,ride
order by 结算价合计 desc

if OBJECT_ID('tempdb..#F') IS NOT NULL DROP TABLE #F
select  top 10 cmpcode,u.Name,SUM(totsprice) 结算价合计,'KA+CX' 航司
INTO #F
from Topway..tbcash t
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=t.cmpcode
where datetime >='2018-01-01'
and datetime<'2019-05-01'
and ride in('KA','CX')
and cmpcode<>''
group by cmpcode,u.Name,ride
order by 结算价合计 desc

if OBJECT_ID('tempdb..#G') IS NOT NULL DROP TABLE #G
select  top 10 cmpcode,u.Name,SUM(totsprice) 结算价合计,'LH+OS+LX' 航司
INTO #G
from Topway..tbcash t
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=t.cmpcode
where datetime >='2018-01-01'
and datetime<'2019-05-01'
and ride in('LH','OS','LX')
and cmpcode<>''
group by cmpcode,u.Name,ride
order by 结算价合计 desc

if OBJECT_ID('tempdb..#H') IS NOT NULL DROP TABLE #H
select  top 10 cmpcode,u.Name,SUM(totsprice) 结算价合计,'AF+KL' 航司
INTO #H
from Topway..tbcash t
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=t.cmpcode
where datetime >='2018-01-01'
and datetime<'2019-05-01'
and ride in('AF','KL')
and cmpcode<>''
group by cmpcode,u.Name,ride
order by 结算价合计 desc

if OBJECT_ID('tempdb..#J') IS NOT NULL DROP TABLE #J
select  top 10 cmpcode,u.Name,SUM(totsprice) 结算价合计,'SQ' 航司
INTO #J
from Topway..tbcash t
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=t.cmpcode
where datetime >='2018-01-01'
and datetime<'2019-05-01'
and ride='SQ'
and cmpcode<>''
group by cmpcode,u.Name,ride
order by 结算价合计 desc

if OBJECT_ID('tempdb..#K') IS NOT NULL DROP TABLE #K
select  top 10 cmpcode,u.Name,SUM(totsprice) 结算价合计,'UA' 航司
INTO #K
from Topway..tbcash t
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=t.cmpcode
where datetime >='2018-01-01'
and datetime<'2019-05-01'
and ride='UA'
and cmpcode<>''
group by cmpcode,u.Name,ride
order by 结算价合计 desc

select * from #A 
union all
select * from #B
union all
select * from #C
union all
select * from #D 
union all
select * from #E 
union all
select * from #F
union all
select * from #G
union all
select * from #H 
union all
select * from #J 
union all
select * from #K


--出票航线明细 2018.1.1-2019.4.30
select cmpcode,coupno,ride,route,sum(totsprice) 结算价合计 from Topway..tbcash 
where ride in('UA','SQ','AF','KL','LH','LH','LX','KA','CX','NH','EK','DL','AA','HX')
and datetime>'2018-01-01'
and datetime<'2019-05-01'
and cmpcode in('016588',
'016363',
'019925',
'016564',
'016602',
'019361',
'001787',
'016400',
'018348',
'019394',
'020350',
'019974',
'006299',
'020459',
'019539',
'019550',
'016426',
'018591',
'019956',
'019106',
'016448',
'018541',
'016336',
'017012',
'018463',
'019641',
'018661',
'017996',
'006944',
'018179',
'020200',
'019363',
'020314',
'019728',
'017275',
'018734',
'020099',
'016641',
'020027',
'019807',
'016497',
'016457',
'020380',
'018624',
'019001',
'018897',
'019631',
'019226',
'020645',
'017888',
'020316',
'018156',
'019799',
'017642',
'019471',
'019392',
'017730',
'020365',
'017399',
'016559',
'019848',
'019358',
'018309',
'020016',
'019753',
'017189',
'019158',
'020463',
'019190',
'019505',
'015828',
'020176')
group by cmpcode,route,ride,coupno
order by cmpcode