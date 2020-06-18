--���
--select * from Topway..tbmileage


--����
IF OBJECT_ID('tempdb.dbo.#mileage') IS NOT NULL DROP TABLE #mileage
select DISTINCT rtrim(cityfrom)+'-'+rtrim(cityto) route,mileage,kilometres 
into #mileage
from topway..tbmileage

select * from #mileage
where route in ('�人-����',
'����-�人',
'����-����',
'����-����',
'�ɶ�-����',
'����-�ɶ�',
'�Ϻ�����-�ɶ�',
'�ɶ�-�Ϻ�����',
'����-����',
'����-����',
'������Է-���',
'���-������Է',
'�Ϻ��ֶ�-����',
'����-�Ϻ��ֶ�',
'�Ϻ�����-�����׶�',
'�ϲ�-�Ϻ��ֶ�',
'�����׶�-�ɶ�',
'�ɶ�-����',
'����-�ɶ�',
'����-����',
'����-����',
'����-�����׶�',
'����-�Ͼ�',
'�Ͼ�-����',
'���ͺ���-�����׶�',
'�����׶�-���ͺ���',
'����-����',
'����-�Ϻ�����',
'����-����',
'�Ϻ�����-����',
'����-�Ϻ�����',
'����-�Ϻ��ֶ�',
'�Ͼ�-����',
'����-����',
'����-����',
'�����-��³ľ��',
'��³ľ��-�����',
'�����׶�-����',
'�Ϻ�����-����',
'����-�Ϻ�����',
'�����׶�-��������',
'�����׶�-��ɳ',
'��ɳ-�����׶�',
'��³ľ��-����',
'����-��³ľ��',
'����-�����׶�',
'����-�Ϻ�����',
'�Ͼ�-����',
'����-�Ϻ��ֶ�',
'�Ͼ�-����',
'�Ϻ��ֶ�-�ɶ�',
'�ɶ�-�Ϻ��ֶ�',
'�����׶�-�Ϻ�����',
'��������-�Ϻ�����',
'�Ͼ�-��������',
'����-����',
'�Ͼ�-�ɶ�',
'����-����',
'����-���',
'����-�Ϻ��ֶ�',
'�Ͼ�-����',
'����-��������',
'�Ϻ��ֶ�-����',
'��ɳ-�Ϻ��ֶ�',
'�Ϻ�����-��ɳ',
'�Ϻ�����-����',
'�Ϻ��ֶ�-����',
'�е�-ʯ��ׯ',
'����-�Ϻ�����',
'����-����',
'����-����',
'�Ͼ�-����',
'����-����',
'����-����',
'����-�Ϻ��ֶ�',
'�Ͼ�-����',
'����-�����׶�',
'�����׶�-̫ԭ',
'̫ԭ-����',
'����-�����׶�',
'�����׶�-����',
'���-����',
'���-����',
'����-�Ϻ��ֶ�',
'�ɶ�-�����׶�',
'����-��ɳ',
'��ɳ-����',
'����-�ɶ�',
'����-�人',
'�人-�Ϻ��ֶ�',
'�Ϻ��ֶ�-����',
'��³ľ��-�Ϻ�����',
'�Ϻ�����-��³ľ��',
'�Ϻ��ֶ�-����',
'�Ϻ�����-��������',
'�ൺ-�Ϻ�����',
'�Ϻ�����-�ൺ',
'������-�Ϻ��ֶ�',
'�Ϻ��ֶ�-������',
'ʯ��ׯ-�Ϻ�����',
'�Ϻ��ֶ�-ʯ��ׯ',
'����-��������',
'��������-����',
'�Ϻ�����-̫ԭ',
'�Ϻ�����-����',
'����-�Ϻ�����',
'�Ϻ�����-����',
'����-�Ϻ��ֶ�',
'�Ϻ��ֶ�-����',
'����-�Ϻ�����',
'��������-����',
'��������-�����׶�',
'�Ϻ��ֶ�-����',
'����-�Ϻ��ֶ�',
'�Ϻ��ֶ�-����',
'����-�Ϻ��ֶ�',
'�Ͼ�-����',
'�ɶ�-����',
'�Ϻ�����-������Է',
'����-����',
'��³ľ��-��������',
'����-����',
'����-�Ϻ��ֶ�',
'�Ϻ��ֶ�-����',
'̫ԭ-�Ϻ�����',
'����-����',
'�Ϻ�����-�人',
'�人-�Ϻ�����',
'���-�Ϻ�����',
'�Ϻ�����-���',
'����-�ൺ',
'�人-����',
'�ൺ-����',
'����-�ൺ',
'��ͨ-�ൺ',
'�ൺ-����',
'����-�ൺ',
'�Ͼ�-�ൺ',
'�ൺ-�Ͼ�',
'��������-��³ľ��',
'���ͺ���-������Է',
'������Է-���ͺ���',
'����-�Ϻ�����',
'����-����',
'�Ͼ�-������',
'�Ϻ��ֶ�-����',
'�Ϻ�����-����',
'����-�Ϻ�����',
'�Ϻ��ֶ�-����',
'����-�Ϻ�����',
'�Ϻ�����-����',
'����-����',
'����-����',
'����-��ɳ',
'��ɳ-����',
'�Ϻ�����-֣��',
'֣��-�Ϻ��ֶ�',
'����-�Ϻ��ֶ�',
'̫ԭ-����',
'����-̫ԭ',
'�Ϻ�����-����',
'�����׶�-�Ϻ��ֶ�',
'�Ϻ��ֶ�-�����׶�',
'�ൺ-��������',
'���ͺ���-���ֺ���',
'���ֺ���-���ͺ���',
'���ͺ���-�Ϻ�����',
'�Ϻ�����-���ͺ���',
'����-����',
'����-����',
'����-�Ϻ��ֶ�',
'�����׶�-����',
'����-����',
'��ɳ-��������',
'�人-����',
'��ɳ-�Ϻ�����',
'�Ϻ��ֶ�-��ɳ',
'��������-�Ϻ��ֶ�',
'��̨-�Ϻ�����',
'�ൺ-�Ϻ��ֶ�',
'����-����',
'����-����',
'����-����',
'����-̫ԭ',
'�Ϻ��ֶ�-��������',
'����-����',
'����-�人',
'��ɳ-����',
'����-��³ľ��',
'����-����',
'��������-����',
'����-����',
'�����׶�-����',
'����-�����׶�',
'���-��������',
'�ɶ�-����',
'����-�ɶ�',
'����-����',
'����-����',
'����-̫ԭ',
'̫ԭ-����',
'֣��-�ൺ',
'�ൺ-֣��',
'����-����',
'���ͺ���-��������',
'��������-��ͷ',
'����-��������',
'����-����',
'����-����',
'����-����',
'����-����',
'�Ϻ��ֶ�-�ൺ')


IF OBJECT_ID('tempdb.dbo.#tbcash1') IS NOT NULL DROP TABLE #tbcash1
select tcode+ticketno as Ʊ��,ride+flightno as �����,datetime as ��Ʊ����
,case SUBSTRING(route,1,CHARINDEX('-',route)-1) when '�Ϻ��ֶ�' then '�Ϻ�' when '�Ϻ�����' then '�Ϻ�' when '�����׶�' then '����' when '������Է' then '����' when '��������' then '����' 
when '��������' then '����' when '����' then '��ͷ' when '�人���' then '�人' when '����' then '��˫����' when '�����첼����' then '�����첼' when '�º�' then 'â��' when '˼é' then '�ն�' when '÷��' then '÷��'
else SUBSTRING(route,1,CHARINDEX('-',route)-1) end as ����
,case REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) when '�Ϻ��ֶ�' then '�Ϻ�' when '�Ϻ�����' then '�Ϻ�' when '�����׶�' then '����' when '������Է' then '����' when '��������' then '����' 
when '��������' then '����' when '����' then '��ͷ' when '�人���' then '�人' when '����' then '��˫����' when '�����첼����' then '�����첼' when '�º�' then 'â��' when '˼é' then '�ն�' when '÷��' then '÷��'
else  REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) end as ����
,route as �г�
,t_source as ��Ӧ����Դ
into #tbcash1
from topway..tbcash c with (nolock)
where tcode+ticketno in('8473562556376',
'7313562556378',
'7313562556387',
'7313562556393',
'8763562556523',
'8803562556524',
'7813562556600',
'7813562556602',
'7313562556603',
'6663562556606',
'8223562556720',
'8223562556721',
'7813563810392',
'7813563810871',
'7813563810885',
'4793563810887',
'4793563810888',
'7843563810944',
'7813563810965',
'7813563811045',
'9993563811079',
'8983563811080',
'8983563811107',
'8983563811114',
'9993563811227',
'3893563811328',
'4793563811329',
'9993563811400',
'9993563811516',
'9993563811517',
'7843563811577',
'7813563811612',
'7313563811699',
'7813563811773',
'7313563811774',
'4793563811916',
'8763563811931',
'7813563812234',
'7813563812235',
'8763563812295',
'8803563812294',
'7843563812296',
'7843563812299',
'7313563812549',
'7843563812592',
'7843563812667',
'7313563812652',
'7843563812986',
'7843563812983',
'9993563813154',
'7813563813149',
'7843563813151',
'7843563813150',
'7813563813152',
'7813563813226',
'7843563813559',
'9993563813560',
'7843563813757',
'7843563813798',
'7813563813760',
'7813563813761',
'7813563813781',
'7813563813784',
'7813563813787',
'7813563813789',
'7813563813790',
'7843563814110',
'7843563814113',
'7843564169789',
'7843564169787',
'7813564169847',
'7813564169851',
'8763564169858',
'9993564169857',
'7813564169969',
'7813564472949',
'8803564472959',
'7813564472961',
'7813564473182',
'7813564473184',
'7813564473213',
'7813564473215',
'7813564473301',
'8763564473280',
'7813564473284',
'8803564473281',
'7843564473315',
'7813564473624',
'8763564473625',
'8763564473637',
'7813564473638',
'7813564473646',
'7843564473701',
'4793564473726',
'7843564473727',
'8763564473770',
'0183564474124',
'7843564474175',
'7813564474176',
'7813564474220',
'7813564474221',
'7813564474222',
'7813564474291',
'7843564474864',
'8363564474865',
'7813564474900',
'9123564475028',
'9123564475034',
'7313564475214',
'7313564475215',
'7843564475373',
'7813564475420',
'7313564475548',
'7313564475549',
'7313564475551',
'7313564475552',
'7813564475694',
'7843564475724',
'7843564475725',
'7813565951466',
'7813565951468',
'7813565951540',
'7813565951541',
'7813565951754',
'4793565951757',
'7843565951763',
'7813565951758',
'7813565951775',
'7813565951774',
'9993565951830',
'9993565951831',
'7813565952400',
'7813565952401',
'9993565952499',
'7843565952508',
'7313565952712',
'7813565952753',
'7813565952861',
'0183565953003',
'9993565953112',
'9993565953324',
'9993565953323',
'8803565953479',
'8763565953491',
'7813565953770',
'7813565953771',
'7813565953821',
'8983565953872',
'8713565953873',
'7813565954214',
'8763565954213',
'7813565954217',
'7813565954218',
'7843565954220',
'7813565954221',
'7813565954223',
'7813565954222',
'7813565954242',
'7813565954244',
'7813565954250',
'7813565954251',
'7813565954253',
'7813565954255',
'7813565954263',
'7813565954264',
'7813565954269',
'7813565954271',
'7813566467404',
'7813566467405',
'7813566467698',
'7813566634777',
'7813566634776',
'7843566634947',
'7843566634953',
'8363566635102',
'8363566635105',
'7843566635106',
'7843566635115',
'7843566635136',
'7813566635353',
'7843566635540',
'7843566635542',
'7843566635544',
'7843566635548',
'7843566635549',
'7843566635550',
'7813566635566',
'7813566635565',
'7813566635569',
'4793566635595',
'7813566635665',
'7813566635755',
'9993566636022',
'7813566636023',
'7813566636059',
'8113566636111',
'7813566636393',
'7813566636394',
'7843566636451',
'4793566636453',
'7843566636454',
'4793566636455',
'7843566636646',
'7843566636648',
'7843566636655',
'7843566636656',
'9993566636839',
'8763566636989',
'8593566637084',
'7813566637180',
'7813566637181',
'7813566637186',
'8223566637234',
'7813566637246',
'7813566637247',
'7313566637496',
'8223566637497',
'7813566637498',
'9993566637532',
'8223566637535',
'7813566637540',
'8803566637541',
'9993566637542',
'7813566637553',
'7813566637551',
'7813566637554',
'7313566637583',
'7843566637585',
'8803566637600',
'7813566637716',
'7813566637717',
'7813566637718',
'7813566637719',
'7843566637720',
'7813566637964',
'0183566637985',
'7813566637965',
'9993566638073',
'9993566638074',
'3243566638160',
'7813566638191',
'7813566638193',
'8983566638258',
'8983566638260',
'7813566638263',
'7813566638264',
'7813566638312',
'7813566638313',
'7813566638441',
'0183566638439',
'7813566638444',
'0183566638442',
'9123566638483',
'3243566638487',
'8763566638488',
'8763566638489',
'7813566638542',
'7813566638543',
'8803567836904',
'7843567837030',
'9993567837031',
'7813567837125',
'7813567837126',
'7813567837128',
'7813567837129',
'7813567837130',
'7813567837132',
'7813567837133',
'7813567837138',
'7813567837134',
'7813567837136',
'7813567837512',
'7813567837590',
'7813567837592',
'7813567837708',
'8223567837782',
'8223567837783',
'7813567837923',
'3243567837925',
'7813567837927',
'7813567837926',
'7313567837955',
'7843567837956',
'9993567838086',
'0183567838087',
'7813567838144',
'7813567838248',
'7813567838247',
'7313567838250',
'7313567838249',
'7843567838415',
'7813567838405',
'7813567838406',
'7813567838500',
'7813567838503',
'9993567838504',
'9993567838508',
'7843567838614',
'7843567838617',
'7813567838651',
'9993567838755',
'9993567838756',
'9993567838757',
'9993567838758',
'7813567838751',
'7813567838786',
'7813567838785',
'7813567838844',
'7313567838843',
'7843568671405',
'7843568671406',
'7813568671453',
'7813568671552',
'7813568671553',
'7843568671554',
'7843568671555',
'8983568671610',
'8983568671611',
'7813568671651',
'7813568671662',
'7813568671678',
'7813568671688',
'7813568671741',
'7813568671845',
'7813568671846',
'8983568671882',
'7843568671931',
'7813568671932',
'7813568672297',
'7813568672300',
'7813568672479',
'7843568672482',
'7813568672625',
'7813568672626',
'7813568672691',
'7813568672714',
'9993568764617',
'7813568764621',
'8763568764697',
'7843568764698',
'7813568764715',
'7313568764714',
'7813568764813',
'7813568764814',
'7813569272541',
'7813569272578',
'7813569272579',
'9873569272627',
'9873569272626',
'9873569272793',
'9873569272796',
'7813569272879',
'7813569272880',
'7843569273037',
'7813569273118',
'7813569273132',
'7813569273241',
'7813569273242',
'8803569273244',
'7813569273608',
'8263569273611',
'8263569273612',
'7813569273615',
'7813569273614',
'7813569273652',
'3243569273653',
'8333569273661',
'7813569274045',
'7813569274046',
'7813569274049',
'9993569274205',
'7313569274275',
'7313569274281',
'9993569274382',
'7813569274512',
'7813569274513',
'7813569274518',
'0183569274520',
'7813569274828',
'7813569274831',
'9993569274872',
'9993569274873',
'7843569275144',
'7843569275148',
'7813569275161',
'7813569275195',
'9993569275196',
'7313569275308',
'7813569275606',
'7813569275607',
'7813569275700',
'7843569275701',
'7843569275816',
'7813569276047',
'7813569276048',
'9993569276097',
'9993569276096',
'9993569276100',
'7813569276178',
'7813569276179',
'7843636229917',
'7813636230168',
'7813636230244',
'7813636230293',
'7813636230294',
'9993636230317',
'7843636230445',
'7843636230447',
'9993636231323',
'7843636231365',
'7813636231384',
'7813636231462',
'9993636231529',
'9993636231530',
'7813636231535',
'9993636231537',
'7813636231554',
'7813636231555',
'7813636231556',
'3243636231578',
'8803636231623',
'8803636231624',
'3243636231979',
'8223636233207',
'8363636233208',
'7843636233407',
'7843636233410',
'0183636975911',
'7813636975925',
'7813636975926',
'7843636976004',
'7813636976009',
'7843636976017',
'7843636976116',
'7843636976107',
'7813636976117',
'7813636976118',
'7813637488930',
'7813637488931',
'8803637488935',
'7813637489198',
'9993637489202',
'9993637489204',
'7813637489293',
'7813637489284',
'8803637489651',
'7813637489652',
'7813637489653',
'7813637489797',
'8803637489990',
'7843637490045',
'7813637490047',
'7313637490345',
'7313637490346',
'7843637490432',
'7843637490434',
'7313637490567',
'7843637490578',
'7843637490646',
'9993637490660',
'9993637490764',
'9993637490787',
'8263637490845',
'7813637490870',
'4793637490945',
'9993637490947',
'9993637490948',
'7313637490989',
'7313637490990',
'9993637491011',
'9993637491007',
'4793637491015',
'4793637491014',
'0883637491117',
'0883637491090',
'8473637491126',
'7843637491127',
'7813637491131',
'7813637491134',
'9993637491222',
'7813637491349',
'7813637491350',
'4793637491572',
'4793637491573',
'8263637491658',
'7813637491659',
'7843637491687',
'7843637491689',
'7843637491690',
'7843637491693',
'7843637491699',
'7843637491700',
'7313638344714',
'4793638344715',
'4793638344746',
'9993638344743',
'4793638344760',
'7843638344789',
'7813638344790',
'7843638344864',
'7843638344865',
'3243638344944',
'7813638344945',
'7843638344947')
order by datetime


IF OBJECT_ID('tempdb.dbo.#tbcash') IS NOT NULL DROP TABLE #tbcash
select *,����+'-'+���� as route2,����+'-'+���� as route3
into #tbcash
from #tbcash1 with (nolock)


IF OBJECT_ID('tempdb.dbo.#tt') IS NOT NULL DROP TABLE #tt
select Ʊ��,tbcash.�г�,��Ʊ����,mileage,kilometres
into #tt
from #tbcash tbcash with (nolock)
left join #mileage mileage on mileage.route=tbcash.route2 or mileage.route=tbcash.route3

select distinct* from #tt
--where kilometres is null


--���ʳ�Ʊ��Ϣ
if OBJECT_ID('tempdb..#test') is not null drop table #test
select coupno as ���۵���,pasname �˻���,tcode+ticketno Ʊ��,ride+flightno ����,REPLACE(route,'-','') �г�
into #test
from Topway..tbcash with (nolock)
where tcode+ticketno in('7813551530315',
'7813551560242',
'0013551554768',
'7813552751576',
'7813552777071',
'2323552777142',
'7813552778320',
'0013552833260',
'7813554285569',
'0167310537793',
'6183677421735')

--select * from #test

--����г�
if OBJECT_ID('tempdb..#test1') is not null drop table #test1
select ���۵���,�˻���,Ʊ��,����,SUBSTRING(�г�,1,3)�г�1, SUBSTRING(�г�,4,3)�г�2, SUBSTRING(�г�,7,3)�г�3, SUBSTRING(�г�,10,3)�г�4
into #test1
from #test 

--�г�1
if OBJECT_ID('tempdb..#xc1') is not null drop table #xc1
select * 
into #xc1
from #test1 test
inner join Topway..tbmileage t on (t.CityFromCode=�г�1 and t.CityToCode=�г�2)

--�г�2
if OBJECT_ID('tempdb..#xc2') is not null drop table #xc2
select * 
into #xc2
from #test1 test
inner join Topway..tbmileage t on (t.CityFromCode=�г�2 and t.CityToCode=�г�3)

--�г�3
if OBJECT_ID('tempdb..#xc3') is not null drop table #xc3
select * 
into #xc3
from #test1 test
inner join Topway..tbmileage t on (t.CityFromCode=�г�3 and t.CityToCode=�г�4)

--����
select xc1.�˻���,xc1.����,xc1.Ʊ��,xc1.mileage+isnull(xc2.mileage,0)+isnull(xc3.mileage,0) Ӣ��,
xc1.kilometres+isnull(xc2.kilometres,0)+isnull(xc3.kilometres,0)����  from #xc1 xc1
left join #xc2 xc2 on xc2.���۵���=xc1.���۵��� and xc2.Ʊ��=xc1.Ʊ�� and xc2.�˻���=xc1.�˻���
left join #xc3 xc3 on xc3.���۵���=xc1.���۵��� and xc3.Ʊ��=xc1.Ʊ�� and xc3.�˻���=xc1.�˻���
order by Ӣ��

--�޸���������
--select bpprice,profit,* from Topway..tbcash where coupno='AS002604651'
--update Topway..tbcash set bpprice='',profit='' where coupno='' 
update Topway..tbcash set bpprice=0,profit=profit+9 where coupno='AS002604651'
update Topway..tbcash set bpprice=0,profit=profit+11 where coupno='AS002604647'
update Topway..tbcash set bpprice=0,profit=profit+4 where coupno='AS002604641'
update Topway..tbcash set bpprice=0,profit=profit+11 where coupno='AS002604632'
update Topway..tbcash set bpprice=0,profit=profit+10 where coupno='AS002604627'
update Topway..tbcash set bpprice=0,profit=profit+9 where coupno='AS002604624'
update Topway..tbcash set bpprice=0,profit=profit+9 where coupno='AS002604619'
update Topway..tbcash set bpprice=0,profit=profit+5 where coupno='AS002604613'
update Topway..tbcash set bpprice=0,profit=profit+8 where coupno='AS002604608'
update Topway..tbcash set bpprice=0,profit=profit+5 where coupno='AS002603986'
update Topway..tbcash set bpprice=0,profit=profit+9 where coupno='AS002603984'
update Topway..tbcash set bpprice=0,profit=profit+13 where coupno='AS002601421'
update Topway..tbcash set bpprice=0,profit=profit+8 where coupno='AS002601321'
update Topway..tbcash set bpprice=0,profit=profit+6 where coupno='AS002601303'
update Topway..tbcash set bpprice=0,profit=profit+7 where coupno='AS002601276'
update Topway..tbcash set bpprice=0,profit=profit+4 where coupno='AS002601273'
update Topway..tbcash set bpprice=0,profit=profit+9 where coupno='AS002596260'
update Topway..tbcash set bpprice=0,profit=profit+13 where coupno='AS002596258'

--��Ʊҵ�������Ϣ
select Sales,* from Topway..tbTrvCoup 
--UPDATE Topway..tbTrvCoup  SET Sales='���'
where TrvCoupNo='97653'

--��Ʊҵ�������Ϣ
SELECT * FROM Topway..tbTrvCoup 
--UPDATE Topway..tbTrvCoup  SET Sales='����'
WHERE TrvId='30118'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='019159_20190501'

--�޸���Ʊ�������
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti  set ExamineDate='2019-07-01'
where reno in('0439507','0439508')

--����Ԥ�㵥��Ϣ

select Custid,Custinfo,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set  Custid='D701469',Custinfo='13816722349@������@020391@�󷿶����Ϻ������ڿƼ����޹�˾@������@13816722349@D586376'
where TrvId='30234'

--�޸���Ʊ״̬
select status2,dzhxDate,* from Topway..tbReti 
--update Topway..tbReti  set status2=3
where reno='0435312'

--�������ݱ���
select top 100 * from homsomDB..Trv_Credentials
select top 100 * from homsomDB..Trv_CompanyStructure

select coupno,Department,DepName,pasname from Topway..tbcash c
 left join homsomDB..Trv_Credentials cr on cr.CredentialNo=idno
 left join homsomDB..Trv_UnitPersons u on u.ID=cr.HumanID
 left join homsomDB..Trv_CompanyStructure co on co.ID=u.CompanyDptId
where coupno in('AS002519988',
'AS002520467',
'AS002520546',
'AS002521009',
'AS002521481',
'AS002521494',
'AS002521494',
'AS002521816',
'AS002521942',
'AS002521944',
'AS002522020',
'AS002522026',
'AS002522473',
'AS002522677',
'AS002525126',
'AS002525409',
'AS002526464',
'AS002526996',
'AS002527675',
'AS002527677',
'AS002527928',
'AS002527931',
'AS002527933',
'AS002528150',
'AS002528768',
'AS002528831',
'AS002529009',
'AS002529071',
'AS002529815',
'AS002529865',
'AS002530081',
'AS002531685',
'AS002531772',
'AS002533342',
'AS002533770',
'AS002533770',
'AS002533770',
'AS002533770',
'AS002535193',
'AS002535285',
'AS002535406',
'AS002537221',
'AS002537223',
'AS002537718',
'AS002537720',
'AS002538817',
'AS002538988',
'AS002538990',
'AS002539700',
'AS002541221',
'AS002542753',
'AS002544075',
'AS002544075',
'AS002544075',
'AS002544075',
'AS002544381',
'AS002544638',
'AS002545154',
'AS002545640',
'AS002548121',
'AS002548233',
'AS002550174',
'AS002550287',
'AS002550287',
'AS002550491',
'AS002550493',
'AS002551906',
'AS002552902',
'AS002552904',
'AS002553051',
'AS002554304',
'AS002554333',
'AS002554353',
'AS002554357',
'AS002554877',
'AS002555214',
'AS002556468',
'AS002557091',
'AS002557343',
'AS002557693',
'AS002558310',
'AS002559848',
'AS002559850',
'AS002560113',
'AS002560119',
'AS002560730',
'AS002561556',
'AS002561758',
'AS002561758',
'AS002562372',
'AS002564286',
'AS002564728',
'AS002565136',
'AS002565902',
'AS002565905',
'AS002565916',
'AS002565916',
'AS002566669',
'AS002567519',
'AS002567519',
'AS002568451',
'AS002568464',
'AS002568480',
'AS002568527',
'AS002568529',
'AS002569261',
'AS002571623',
'AS002575280',
'AS002576629',
'AS002579166',
'AS002579168',
'AS002579180',
'AS002579180',
'AS002579185',
'AS002579217',
'AS002581510',
'AS002583575',
'AS002583583',
'AS002584539',
'AS002584551',
'AS002587049',
'AS002587595',
'AS002587597',
'AS002587597',
'AS002587639',
'AS002588171',
'AS002588721',
'AS002589715',
'AS002589775',
'AS002589800',
'AS002589970',
'AS002590074',
'AS002590170',
'AS002590500',
'AS002591143',
'AS002592654',
'AS002593512',
'AS002595355')

select coupno,DATEDIFF(DD,datetime,begdate)��ǰ����  from Topway..tbcash 
where coupno in('AS002519988',
'AS002520467',
'AS002520546',
'AS002521009',
'AS002521481',
'AS002521494',
'AS002521494',
'AS002521816',
'AS002521942',
'AS002521944',
'AS002522020',
'AS002522026',
'AS002522473',
'AS002522677',
'AS002525126',
'AS002525409',
'AS002526464',
'AS002526996',
'AS002527675',
'AS002527677',
'AS002527928',
'AS002527931',
'AS002527933',
'AS002528150',
'AS002528768',
'AS002528831',
'AS002529009',
'AS002529071',
'AS002529815',
'AS002529865',
'AS002530081',
'AS002531685',
'AS002531772',
'AS002533342',
'AS002533770',
'AS002533770',
'AS002533770',
'AS002533770',
'AS002535193',
'AS002535285',
'AS002535406',
'AS002537221',
'AS002537223',
'AS002537718',
'AS002537720',
'AS002538817',
'AS002538988',
'AS002538990',
'AS002539700',
'AS002541221',
'AS002542753',
'AS002544075',
'AS002544075',
'AS002544075',
'AS002544075',
'AS002544381',
'AS002544638',
'AS002545154',
'AS002545640',
'AS002548121',
'AS002548233',
'AS002550174',
'AS002550287',
'AS002550287',
'AS002550491',
'AS002550493',
'AS002551906',
'AS002552902',
'AS002552904',
'AS002553051',
'AS002554304',
'AS002554333',
'AS002554353',
'AS002554357',
'AS002554877',
'AS002555214',
'AS002556468',
'AS002557091',
'AS002557343',
'AS002557693',
'AS002558310',
'AS002559848',
'AS002559850',
'AS002560113',
'AS002560119',
'AS002560730',
'AS002561556',
'AS002561758',
'AS002561758',
'AS002562372',
'AS002564286',
'AS002564728',
'AS002565136',
'AS002565902',
'AS002565905',
'AS002565916',
'AS002565916',
'AS002566669',
'AS002567519',
'AS002567519',
'AS002568451',
'AS002568464',
'AS002568480',
'AS002568527',
'AS002568529',
'AS002569261',
'AS002571623',
'AS002575280',
'AS002576629',
'AS002579166',
'AS002579168',
'AS002579180',
'AS002579180',
'AS002579185',
'AS002579217',
'AS002581510',
'AS002583575',
'AS002583583',
'AS002584539',
'AS002584551',
'AS002587049',
'AS002587595',
'AS002587597',
'AS002587597',
'AS002587639',
'AS002588171',
'AS002588721',
'AS002589715',
'AS002589775',
'AS002589800',
'AS002589970',
'AS002590074',
'AS002590170',
'AS002590500',
'AS002591143',
'AS002592654',
'AS002593512',
'AS002595355')

--�ؿ���ӡ
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='30403'

select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='30363'

select * from Topway..tbcash where coupno='AS002603480'

--020521ɾ����λԱ��
select * from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons
where CompanyID=(Select  ID from homsomDB..Trv_UnitCompanies 
where Cmpid='020521'))
and IsDisplay=1
and Name not in ('����','��ӱ��')

select * from Topway..tbCusholderM 
--update Topway..tbCusholderM  set EmployeeStatus=0
where cmpid='020521'
and custname not in('����','��ӱ��')

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno='AS002600185' and id='4419410'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno='AS002600211' and id in('4419413','4419415')

select tax,stax,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=50,profit=180
where coupno='AS002602905'


/*
    �鷳����ȡ��ۺ������ݣ�лл 
 
    ��Ʊ���ڣ�2018��1��-2018��12�� ��2019��1��-2019��6��
    ���չ�˾��HX
    
    ����Ҫ��: ���ڡ����۵��š�Ʊ�š����̡���λ���ļ��ۺϼ�
*/
select convert(varchar(10),datetime,120) ��Ʊ����,coupno ���۵���,tcode+ticketno Ʊ��,route ����,nclass ��λ,sprice1+sprice2+sprice3+sprice4 �ļ��ۺϼ�,reti ��Ʊ����
from Topway..tbcash 
where ride='hx'
and datetime>='2018-01-01'
order by ��Ʊ����


--�Ƶ�������˽��
select totprice,vpay,vpayinfo,owe, * from Topway..tbhtlyfchargeoff 
--update Topway..tbhtlyfchargeoff  set vpay=0,vpayinfo='',owe=totprice
where coupid='122919'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020472_20190601'


--UC013184 ʱ��2018��1��-2019��6��
select * from ehomsom..tbInfAirCompany
select top 100 * from homsomDB..Trv_ItktBookingSegs
select top 100 * from homsomDB..Trv_LowerstPrices
select top 100 CoupNo,* from homsomDB..Trv_TktBookings
select top 100 * from homsomDB..Intl_BookingLegs
select top 100 * from homsomDB..Intl_BookingOrders
select top 100 * from homsomDB..Intl_BookingSegements

--����
select pasname �˻���,CostCenter �ɱ�����,Department ����,DETR_RP �г̵���,InvoicesID ˰��,tickettype ����,
datetime ��Ʊ����,recno PNR,tcode+ticketno Ʊ��,OldTicketNo oldƱ��,ride ��˾����,it.Airline ��˾����,'����' ���ʻ����,
'����' �Ƿ�����,c2.Name ��������,c1.Name �������,c2.CountryCode ��������,c1.CountryCode �������,c.route �г�,
case when FlightClass like'%����%' then '���ò�' when FlightClass like'%����%' then '�����' when FlightClass like'%ͷ�Ȳ�%' then 'ͷ�Ȳ�' else '-' End  ��λ�ȼ�
,nclass ��λ����,Departing �������,Arriving ��������,case when DATEDIFF(DD,datetime,Departing) between 0 and 2  then '0to2'
when DATEDIFF(DD,datetime,Departing) between 3 and 6 then '3to6' else '7+' end ��ǰ��Ʊ,DATEDIFF(DD,datetime,Departing) ��ǰ��Ʊ����,
c.price ���۵���,tax ˰��,fuprice �����,totprice ���ۼ�,priceinfo ȫ��,l.Price ��ͼ�,AuthorizationCode ��Ȩ��,l.UnChoosedReason ReasonCode,
tickettype ����,DATEDIFF(MINUTE,Departing,Arriving) ����ʱ��
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos s on s.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ID=s.ItktBookingSegID
left join homsomDB..Trv_Airport a1 on a1.Code=it.Destination
left join homsomDB..Trv_Airport a2 on a2.Code=it.Origin
left join homsomDB..Trv_Cities c1 on c1.ID=a1.CityID
left join homsomDB..Trv_Cities c2 on c2.ID=a2.CityID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=s.ItktBookingSegID
left join homsomDB..Trv_TktBookings tk on tk.ID=it.ItktBookingID
where cmpcode='013184'
and inf=0
and datetime>='2018-01-01'
and datetime<'2019-07-01'

--����
select pasname �˻���,CostCenter �ɱ�����,Department ����,DETR_RP �г̵���,InvoicesID ˰��,c.tickettype ����,
datetime ��Ʊ����,recno PNR,tcode+ticketno Ʊ��,OldTicketNo oldƱ��,ride ��˾����,airname ��˾����,'����' ���ʻ����,
'' �Ƿ�����,
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
left join ehomsom..tbInfAirCompany tb on tb.code2=c.ride
where cmpcode='013184'
and inf=1
and datetime>='2018-01-01'
and datetime<'2019-07-01'


--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='016232_20190501'

select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020690_20190601'

--���㵥��Ϣ�����ʣ�
select settleStatus,* from topway..tbSettlementApp
--update topway..tbSettlementApp set settleStatus='3' 
where id='113914'

select wstatus,settleno,* from topway..tbcash
--update topway..tbcash set wstatus='0',settleno='0' 
where settleno='113914'

select Status,* from topway..Tab_WF_Instance
--update topway..Tab_WF_Instance set Status='4' 
where BusinessID='113914'

/*
UC006299   ̩���Ϻ������޹�˾
 
��ͻ��ʼ�Ҫ���밴���������ȡ2018/9/1---2019/6/30���˻���������Ʊ�š���ɳ��С�Ŀ�ĵس��С���Ʊ���ڡ�������ڡ��س����ڡ��г���������Ʊʹ����� 9������
*/
select pasname �˻�������,tcode+ticketno Ʊ��,DepartCityName ��ɳ���,ArrivalCityName Ŀ�ĵس���,datetime ��Ʊ����,begdate �������,'' �س�����,''�г�����,
case when  tickettype='����Ʊ' then 'ʹ��' else '��������' end ��Ʊʹ����� 
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos it on it.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs i on i.ID=it.ItktBookingSegID
where cmpcode='006299'
and inf=0
and datetime>='2018-09-01'
and datetime<'2019-07-01'


select * from ehomsom..tbInfAirCompany
select top 100 * from homsomDB..Trv_ItktBookingSegs
select top 100 * from homsomDB..Trv_LowerstPrices
select top 100 CoupNo,* from homsomDB..Trv_TktBookings
select top 100 * from homsomDB..Intl_BookingLegs
select top 100 * from homsomDB..Intl_BookingOrders
select top 100 * from Topway..tbFiveCoupInfo


select c.coupno,route,Code1,Terminal,Code2,Terminal1
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on c.coupno=t.coupno
left join homsomDB..Intl_BookingSegements b on t.OrderId=b.BookingOrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where cmpcode='006299'
and inf=1
and datetime>='2018-09-01'
and datetime<'2019-07-01'
order by c.coupno