/*
   1、业务类型：国际
     2、承运人：LH 
     3、供应商来源不限
     4、出票日期1：2018年1月-2018年12月
         出票日期2：2019年1月-2019年4月
     5、扣除退票
     
       报表要素1
     销售单号、供应商来源、票号、行程中包含CPH/HEL/OSL/STO/ARN/GOT/REK、舱位、文件价合计 

     报表要素2
     UC号、销售单号、票号、行程、舱位、文件价合计、差旅顾问 
*/

--报表1
select coupno,t_source,tcode+ticketno 票号,route,nclass,sprice1+sprice2+sprice3+sprice4 文件价合计
from Topway..tbcash 
where inf=1
and ride='LH'
and (datetime between '2018-01-01' and '2018-12-31')
and reti=''
and (route like '%CPH%' or route like '%HEL%' or 
route like '%OSL%' or route like '%STO%' or route like '%ARN%'
or route like '%GOT%' or route like '%REK%')
order by datetime


select coupno,t_source,tcode+ticketno 票号,route,nclass,sprice1+sprice2+sprice3+sprice4 文件价合计
from Topway..tbcash 
where inf=1
and ride='LH'
and (datetime between '2019-01-01' and '2019-04-30')
and reti=''
and (route like '%CPH%' or route like '%HEL%' or 
route like '%OSL%' or route like '%STO%' or route like '%ARN%'
or route like '%GOT%' or route like '%REK%')
order by datetime


--报表2
select cmpcode,coupno,tcode+ticketno 票号,route,nclass,sprice1+sprice2+sprice3+sprice4 文件价合计,sales
from Topway..tbcash 
where inf=1
and ride='LH'
and (datetime between '2018-01-01' and '2018-12-31')
and reti=''
order by datetime

select cmpcode,coupno,tcode+ticketno 票号,route,nclass,sprice1+sprice2+sprice3+sprice4 文件价合计,sales
from Topway..tbcash 
where inf=1
and ride='LH'
and (datetime between '2019-01-01' and '2019-04-30')
and reti=''
order by datetime


--插入票号
--select pasname,* from Topway..tbcash where coupno='AS002475122'
--update Topway..tbcash set pasname='',tcode='',ticketno='' where coupno='AS002475122' and pasname=''
update Topway..tbcash set pasname='LI/BINGHUI',tcode='781',ticketno='2400464667' where coupno='AS002475122' and pasname='乘客0'
update Topway..tbcash set pasname='LI/LEI',tcode='781',ticketno='2400464668' where coupno='AS002475122' and pasname='乘客1'
update Topway..tbcash set pasname='LI/MINGLAN',tcode='781',ticketno='2400464669' where coupno='AS002475122' and pasname='乘客2'
update Topway..tbcash set pasname='LIU/MENGYUAN',tcode='781',ticketno='2400464670' where coupno='AS002475122' and pasname='乘客3'
update Topway..tbcash set pasname='PENG/ZILING',tcode='781',ticketno='2400464671' where coupno='AS002475122' and pasname='乘客4'
update Topway..tbcash set pasname='QIAN/CHENYUN',tcode='781',ticketno='2400464672' where coupno='AS002475122' and pasname='乘客5'
update Topway..tbcash set pasname='SHEN/WANGJIE',tcode='781',ticketno='2400464673' where coupno='AS002475122' and pasname='乘客6'
update Topway..tbcash set pasname='WANG/HUI',tcode='781',ticketno='2400464674' where coupno='AS002475122' and pasname='乘客7'
update Topway..tbcash set pasname='WANG/ZEYAN',tcode='781',ticketno='2400464675' where coupno='AS002475122' and pasname='乘客8'
update Topway..tbcash set pasname='WENG/YUHAN',tcode='781',ticketno='2400464676' where coupno='AS002475122' and pasname='乘客9'
update Topway..tbcash set pasname='WU/RUYI',tcode='781',ticketno='2400464677' where coupno='AS002475122' and pasname='乘客10'
update Topway..tbcash set pasname='XU/ZHUWEI',tcode='781',ticketno='2400464678' where coupno='AS002475122' and pasname='乘客11'
update Topway..tbcash set pasname='ZHU/JIAJUN',tcode='781',ticketno='2400464679' where coupno='AS002475122' and pasname='乘客12'


--UC016586修改单位注册月2019-05-16
select indate,* from Topway..tbCompanyM 
--update Topway..tbCompanyM set indate='2019-05-16'
where cmpid='016586'

select RegisterMonth,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies  set RegisterMonth='05  16 2019 12:00AM'
where Cmpid='016586'

----（产品专用）保险结算价信息
select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=2
where coupno in('AS002440976', 'AS002440977' ,'AS002440978', 'AS002440979', 
'AS002440981', 'AS002440983' ,'AS002441378', 'AS002441839' ,'AS002445540' ,'AS002450838', 
'AS002451406' ,'AS002454994' ,'AS002457332' ,'AS002457333' ,'AS002458145' ,'AS002458496' ,
'AS002459034', 'AS002459120', 'AS002459191', 'AS002459583', 'AS002459698', 'AS002460549', 
'AS002465506', 'AS002465522' ,'AS002465771', 'AS002466025', 'AS002466747' ,'AS002469363' ,
'AS002469892' ,'AS002472165' ,'AS002472166', 'AS002472155' ,'AS002472189' ,'AS002472590', 
'AS002472896' ,'AS002472931', 'AS002473291' ,'AS002475697' ,'AS002475705' ,'AS002475706' ,
'AS002475710', 'AS002475712', 'AS002475714')

--删除回访协议UC020816
SELECT UnitCompanyID,* FROM homsomdb..Trv_Memos
--update homsomdb..Trv_Memos set UnitCompanyID=null
WHERE UnitCompanyID in (select id from homsomdb..Trv_UnitCompanies where Cmpid='020816')
and ID in('E0E22E48-92C1-4DC2-82BF-AA4800AD6BB6')

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=5543,profit=1406
where coupno='AS002469510'

select sprice1,totsprice,profit,amount,owe,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=10,totsprice=10,profit='-10'
where coupno in ('AS000000000')
and tcode+ticketno='2209576668473'

select sprice1,totsprice,profit,amount,owe,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=10,totsprice=10,profit='-10'
where coupno in ('AS000000000')
and tcode+ticketno='2209576668474'

--会务预算单信息
select Sales,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget  set Sales='张广寒'
where ConventionId='1397'


--结算单作废
select settleStatus,* from topway..tbSettlementApp
--update topway..tbSettlementApp set settleStatus='3' 
where id='11178'

select wstatus,settleno,* from Topway..tbcash 
--update Topway..tbcash  set wstatus='0',settleno='0' 
where settleno='11178'


/*
     1、业务类型：国际
     2、承运人：AF KL
     3、供应商来源：ZSUATPI
     4、出票日期：2019年1月-2019年5月16日
     5、扣除退票
    
     报表要素
     销售单号、出票日期、票号、舱位、文件价合计、税收
*/
select coupno,CONVERT(varchar(10),datetime,120),tcode+ticketno,nclass,sprice1+sprice2+sprice3+sprice4,tax  
from Topway..tbcash 
where t_source='ZSUATPI'
and ride in ('AF','KL')
and inf=1
and (datetime between '2019-01-01' and '2019-05-16')
and reti=''





select reti,* from Topway..tbcash where coupno in ('AS001690097',
'AS001689569',
'AS000719025')

select status2,* from Topway..tbReti where coupno in ('AS001690097',
'AS001689569',
'AS000719025')

select * from Topway..AppSettings where Description like'%查看权限%'


--匹配合作状态
select 'UC'+Cmpid,(CASE CooperativeStatus WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' 
WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END) as 合作状态
from homsomDB..Trv_UnitCompanies
where Cmpid in('020756',
'020564',
'020560',
'020556',
'020555',
'020553',
'020552',
'020550',
'020544',
'020541',
'020536',
'020535',
'020532',
'020529',
'020521',
'020518',
'020510',
'020505',
'020498',
'020496',
'020491',
'020488',
'020483',
'020478',
'020477',
'020460',
'020459',
'020455',
'020448',
'020447',
'020442',
'020441',
'020432',
'020431',
'020425',
'020421',
'020410',
'020405',
'020396',
'020335',
'020334',
'020310',
'020309',
'020308',
'020303',
'020302',
'020291',
'020287',
'020285',
'020284',
'020278',
'020275',
'020260',
'020256',
'020199',
'020195',
'020174',
'020146',
'020141',
'020112',
'020084',
'020046',
'020031',
'020025',
'020016',
'020015',
'019990',
'019987',
'019969',
'019956',
'019943',
'019941',
'019916',
'019892',
'019882',
'019848',
'019839',
'019827',
'019822',
'019792',
'019784',
'019712',
'019704',
'019692',
'019688',
'019674',
'019670',
'019663',
'019658',
'019654',
'019637',
'019603',
'019587',
'019517',
'019507',
'019506',
'019497',
'019465',
'019429',
'019381',
'019360',
'019294',
'019270',
'019259',
'019251',
'019249',
'019245',
'019222',
'019180',
'019152',
'019054',
'019026',
'018945',
'018925',
'018919',
'018897',
'018896',
'018865',
'018834',
'018773',
'018767',
'018758',
'018746',
'018661',
'018643',
'018570',
'018539',
'018536',
'018526',
'018480',
'018418',
'018400',
'018398',
'018395',
'018393',
'018381',
'018369',
'018309',
'018308',
'018304',
'018296',
'018257',
'018240',
'018238',
'018234',
'018220',
'018202',
'018199',
'018193',
'018179',
'018178',
'018163',
'018146',
'018116',
'018108',
'018096',
'018080',
'018042',
'018038',
'018037',
'018030',
'018021',
'018017',
'018014',
'018002',
'017996',
'017983',
'017977',
'017956',
'017955',
'017949',
'017947',
'017940',
'017921',
'017920',
'017916',
'017914',
'017903',
'017888',
'017887',
'017865',
'017854',
'017822',
'017814',
'017762',
'017753',
'017745',
'017740',
'017739',
'017730',
'017684',
'017682',
'017674',
'017671',
'017670',
'017667',
'017659',
'017655',
'017623',
'017602',
'017595',
'017579',
'017577',
'017549',
'017525',
'017511',
'017508',
'017506',
'017505',
'017495',
'017493',
'017491',
'017480',
'017474',
'017410',
'017399',
'017378',
'017326',
'017283',
'017275',
'017193',
'017173',
'017103',
'017012',
'017007',
'016994',
'016876',
'016859',
'016848',
'016751',
'016696',
'016655',
'016646',
'016602',
'016578',
'016560',
'016500',
'016497',
'016490',
'016477',
'016400',
'016379',
'016363',
'016344',
'016337',
'016232',
'016087',
'014412',
'009005',
'006944',
'001787')

--插入票号
--select pasname,* from Topway..tbcash where coupno='AS002478572'
--update Topway..tbcash set pasname='',tcode='',ticketno='' where coupno='AS002478572' and pasname=''
update Topway..tbcash set pasname='XU/YING',tcode='781',ticketno='2400478208' where coupno='AS002478572' and pasname='乘客0'
update Topway..tbcash set pasname='SUN/JIALIN',tcode='781',ticketno='2400478212' where coupno='AS002478572' and pasname='乘客1'
update Topway..tbcash set pasname='WANG/HUANJUN',tcode='781',ticketno='2400478213' where coupno='AS002478572' and pasname='乘客2'
update Topway..tbcash set pasname='WANG/WEIJI',tcode='781',ticketno='2400478214' where coupno='AS002478572' and pasname='乘客3'
update Topway..tbcash set pasname='XU/JUAN',tcode='781',ticketno='2400478215' where coupno='AS002478572' and pasname='乘客4'
update Topway..tbcash set pasname='XU/XIAOOU',tcode='781',ticketno='2400478216' where coupno='AS002478572' and pasname='乘客5'
update Topway..tbcash set pasname='XU/YING',tcode='781',ticketno='2400478217' where coupno='AS002478572' and pasname='乘客6'
update Topway..tbcash set pasname='YAMAGUCHI/KOJI',tcode='781',ticketno='2400478218' where coupno='AS002478572' and pasname='乘客7'
update Topway..tbcash set pasname='YIN/CHAO',tcode='781',ticketno='2400478219' where coupno='AS002478572' and pasname='乘客8'
update Topway..tbcash set pasname='YU/JIE',tcode='781',ticketno='2400478220' where coupno='AS002478572' and pasname='乘客9'
update Topway..tbcash set pasname='YU/QING',tcode='781',ticketno='2400478221' where coupno='AS002478572' and pasname='乘客10'
update Topway..tbcash set pasname='ZHENG/SONG',tcode='781',ticketno='2400478222' where coupno='AS002478572' and pasname='乘客11'
update Topway..tbcash set pasname='ZHOU/XIAOYAN',tcode='781',ticketno='2400478223' where coupno='AS002478572' and pasname='乘客12'
update Topway..tbcash set pasname='ZHOU/YOU',tcode='781',ticketno='2400478224' where coupno='AS002478572' and pasname='乘客13'
update Topway..tbcash set pasname='ZOU/JINGLI',tcode='781',ticketno='2400478225' where coupno='AS002478572' and pasname='乘客14'
update Topway..tbcash set pasname='CAI/LILI',tcode='781',ticketno='2400478226' where coupno='AS002478572' and pasname='乘客15'
update Topway..tbcash set pasname='CHEN/JIAO',tcode='781',ticketno='2400478227' where coupno='AS002478572' and pasname='乘客16'
update Topway..tbcash set pasname='FENG/BO',tcode='781',ticketno='2400478228' where coupno='AS002478572' and pasname='乘客17'
update Topway..tbcash set pasname='GU/QINGQING',tcode='781',ticketno='2400478229' where coupno='AS002478572' and pasname='乘客18'
update Topway..tbcash set pasname='GUO/JING',tcode='781',ticketno='2400478230' where coupno='AS002478572' and pasname='乘客19'
update Topway..tbcash set pasname='KOHNO/TOMOKAZU',tcode='781',ticketno='2400478231' where coupno='AS002478572' and pasname='乘客20'
update Topway..tbcash set pasname='LI/JING',tcode='781',ticketno='2400478232' where coupno='AS002478572' and pasname='乘客21'
update Topway..tbcash set pasname='LI/QING',tcode='781',ticketno='2400478233' where coupno='AS002478572' and pasname='乘客22'
update Topway..tbcash set pasname='LIU/XIANGQIN',tcode='781',ticketno='2400478234' where coupno='AS002478572' and pasname='乘客23'
update Topway..tbcash set pasname='LU/YAN',tcode='781',ticketno='2400478235' where coupno='AS002478572' and pasname='乘客24'
update Topway..tbcash set pasname='SHEN/LINA',tcode='781',ticketno='2400478236' where coupno='AS002478572' and pasname='乘客25'
update Topway..tbcash set pasname='SHEN/RONGRONG',tcode='781',ticketno='2400478237' where coupno='AS002478572' and pasname='乘客26'
update Topway..tbcash set pasname='SHEN/RUIDONG',tcode='781',ticketno='2400478238' where coupno='AS002478572' and pasname='乘客27'
update Topway..tbcash set pasname='SONG/QINYAO',tcode='781',ticketno='2400478239' where coupno='AS002478572' and pasname='乘客28'

--update Topway..tbcash set pasname='',tcode='',ticketno='' where coupno='AS002477770' and pasname=''

update Topway..tbcash set pasname='LIU/JIE',tcode='781',ticketno='2400475310' where coupno='AS002477770' and pasname='乘客0'
update Topway..tbcash set pasname='LOU/YING',tcode='781',ticketno='2400475311' where coupno='AS002477770' and pasname='乘客1'
update Topway..tbcash set pasname='QIAN/MENGYI',tcode='781',ticketno='2400475312' where coupno='AS002477770' and pasname='乘客2'
update Topway..tbcash set pasname='QIU/XIAOCHEN',tcode='781',ticketno='2400475313' where coupno='AS002477770' and pasname='乘客3'
update Topway..tbcash set pasname='SHA/ZHANGQI',tcode='781',ticketno='2400475314' where coupno='AS002477770' and pasname='乘客4'
update Topway..tbcash set pasname='WANG/LIYUN',tcode='781',ticketno='2400475315' where coupno='AS002477770' and pasname='乘客5'
update Topway..tbcash set pasname='WENG/NI',tcode='781',ticketno='2400475316' where coupno='AS002477770' and pasname='乘客6'
update Topway..tbcash set pasname='WU/JINGEN',tcode='781',ticketno='2400475317' where coupno='AS002477770' and pasname='乘客7'
update Topway..tbcash set pasname='XIAO/MENG',tcode='781',ticketno='2400475318' where coupno='AS002477770' and pasname='乘客8'
update Topway..tbcash set pasname='XU/MINGDA',tcode='781',ticketno='2400475319' where coupno='AS002477770' and pasname='乘客9'
update Topway..tbcash set pasname='YE/SHENGYI',tcode='781',ticketno='2400475320' where coupno='AS002477770' and pasname='乘客10'
update Topway..tbcash set pasname='ZHANG/JIE',tcode='781',ticketno='2400475321' where coupno='AS002477770' and pasname='乘客11'
update Topway..tbcash set pasname='ZHANG/YANGSI',tcode='781',ticketno='2400475322' where coupno='AS002477770' and pasname='乘客12'
update Topway..tbcash set pasname='ZHU/HONG',tcode='781',ticketno='2400475323' where coupno='AS002477770' and pasname='乘客13'
update Topway..tbcash set pasname='CAO/YIHANG',tcode='781',ticketno='2400475324' where coupno='AS002477770' and pasname='乘客14'
update Topway..tbcash set pasname='CHEN/HAO',tcode='781',ticketno='2400475325' where coupno='AS002477770' and pasname='乘客15'
update Topway..tbcash set pasname='DAI/WENYAN',tcode='781',ticketno='2400475326' where coupno='AS002477770' and pasname='乘客16'
update Topway..tbcash set pasname='FURUKAWA/MASAHIDE',tcode='781',ticketno='2400475327' where coupno='AS002477770' and pasname='乘客17'
update Topway..tbcash set pasname='GAO/YUAN',tcode='781',ticketno='2400475328' where coupno='AS002477770' and pasname='乘客18'
update Topway..tbcash set pasname='HU/MINGHAO',tcode='781',ticketno='2400475329' where coupno='AS002477770' and pasname='乘客19'
update Topway..tbcash set pasname='HU/YI',tcode='781',ticketno='2400475330' where coupno='AS002477770' and pasname='乘客20'
update Topway..tbcash set pasname='JIN/JING',tcode='781',ticketno='2400475331' where coupno='AS002477770' and pasname='乘客21'
update Topway..tbcash set pasname='JIN/LEI',tcode='781',ticketno='2400475332' where coupno='AS002477770' and pasname='乘客22'
update Topway..tbcash set pasname='JIN/XIAOWEI',tcode='781',ticketno='2400475333' where coupno='AS002477770' and pasname='乘客23'
update Topway..tbcash set pasname='JIN/YUPING',tcode='781',ticketno='2400475334' where coupno='AS002477770' and pasname='乘客24'
update Topway..tbcash set pasname='LI/JIA',tcode='781',ticketno='2400475335' where coupno='AS002477770' and pasname='乘客25'
update Topway..tbcash set pasname='LI/JIAYING',tcode='781',ticketno='2400475336' where coupno='AS002477770' and pasname='乘客26'
update Topway..tbcash set pasname='LI/MIN',tcode='781',ticketno='2400475337' where coupno='AS002477770' and pasname='乘客27'
update Topway..tbcash set pasname='LI/NA',tcode='781',ticketno='2400475338' where coupno='AS002477770' and pasname='乘客28'



