--����Ԥ�㵥��Ϣ
select Sales,OperName,introducer,JiDiao,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget  set Sales='��֮��',OperName='0481��֮��',introducer='��֮��-0481-��Ӫ��',JiDiao='0481��֮��'
where ConventionId in('1162','1206','1218', '1237', '1244' ,'1249' ,'1393' ,'1392')

--�Ƶ����۵��ؿ���ӡȨ��
select pstatus,prdate,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set pstatus=0,prdate='1900-01-01'
where CoupNo='-PTW079648'


--��������

select * from homsomDB..Trv_Cities 
--update homsomDB..Trv_Cities set Name='�̵�',AbbreviatedName='�̵�'
where Code='GNI'

SELECT * 
--delete
from homsomDB..Trv_Airport 
where Code='GNI' and CityID='FC750B91-D790-4CEF-B6BC-0BB7E36C660B'

SELECT *
--delete
from homsomDB..Trv_Airport where Code='JNS'

--select AbbreviatedName,* from homsomDB..Trv_Cities where   Code='CAT'

SELECT *from homsomDB..Trv_Airport 
--update homsomDB..Trv_Airport  set Name='��������',EnglishName='Adado Airport',AbbreviationName='��������'
where Code='AAD'

SELECT *from homsomDB..Trv_Airport 
--update homsomDB..Trv_Airport  set Name='����˹�˻���',EnglishName='Kirensk Airport',AbbreviationName='����˹�˻���'
where Code='KCK'

select * from homsomDB..Trv_Cities 
--update homsomDB..Trv_Cities set Name='�����ڹ�',AbbreviatedName='�����ڹ�'
where Code='ETE'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='017290_20190301'


--���ڱ����
--select * from HotelOrderDB..HTL_Holidays

select StartDate,EndDate,Isfilter,Remark,* from HotelOrderDB..HTL_Holidays
--update HotelOrderDB..HTL_Holidays set EndDate='2019-05-03'
where Remark='�Ͷ���'

select * from HotelOrderDB..HTL_Holidays
--update HotelOrderDB..HTL_Holidays set StartDate='2019-04-28',EndDate='2019-04-28'
where ID='45'

select * from HotelOrderDB..HTL_Holidays
--update HotelOrderDB..HTL_Holidays set StartDate='2019-05-05',EndDate='2019-05-05'
where ID='46'

--���кͻ���
select a.Code,c.Code,a.Name,c.Name,a.EnglishName,c.EnglishName,a.AbbreviationName,c.AbbreviatedName
from homsomDB..Trv_Airport a
left join homsomDB..Trv_Cities c on c.ID=a.CityID

select * from homsomDB..Trv_Airport where Code='LON'



select amount,totprice,totsprice,tax,profit,settleno,* from Topway..tbcash where coupno='AS002426937'
select t_amount ,totprice,totsprice,tottax,totprofit,* from Topway..tbFiveCoupInfo 
--update Topway..tbFiveCoupInfo set t_amount=20,totprice=20,totsprice=10,tottax=0,totprofit=10
where CoupNo='AS002426937'

select Tax,SalesPrice,Amount,* from homsomDB..Intl_BookingOrders 
--update homsomDB..Intl_BookingOrders set Tax=0,SalesPrice=20,Amount=20
where Id='66141275-7d13-43a4-a465-91c27b9e6a17'


SELECT CABINFLAG,SUM(price) �ϼ���������˰,SUM(CAST(priceinfo AS DECIMAL)) �ϼ�ȫ�۲���˰,COUNT(1) �ϼ�����,
AVG(price/CAST(priceinfo AS DECIMAL)) ƽ���ۿ���   
FROM (
SELECT --T1.coupno,
CASE WHEN price/CAST(priceinfo AS DECIMAL) >1 THEN 1
	WHEN price/CAST(priceinfo AS DECIMAL) =1 THEN 2
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.95 AND price/CAST(priceinfo AS DECIMAL) <1 THEN 3
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.90 AND price/CAST(priceinfo AS DECIMAL) <0.95 THEN 4
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.85 AND price/CAST(priceinfo AS DECIMAL) <0.90 THEN 5
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.80 AND price/CAST(priceinfo AS DECIMAL) <0.85 THEN 6
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.75 AND price/CAST(priceinfo AS DECIMAL) <0.80 THEN 7
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.70 AND price/CAST(priceinfo AS DECIMAL) <0.75 THEN 8
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.65 AND price/CAST(priceinfo AS DECIMAL) <0.70 THEN 9
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.60 AND price/CAST(priceinfo AS DECIMAL) <0.65 THEN 10
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.55 AND price/CAST(priceinfo AS DECIMAL) <0.60 THEN 11
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.50 AND price/CAST(priceinfo AS DECIMAL) <0.55 THEN 12
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.45 AND price/CAST(priceinfo AS DECIMAL) <0.50 THEN 13
	WHEN price/CAST(priceinfo AS DECIMAL) >=0.40 AND price/CAST(priceinfo AS DECIMAL) <0.45 THEN 14
	WHEN price/CAST(priceinfo AS DECIMAL) <0.40 THEN 15 END CABINFLAG,
totprice,price,priceinfo 
FROM Topway..tbcash T1 WITH (NOLOCK)
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=T1.coupno
left join homsomDB..Trv_PnrInfos pn on pn.id=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ItktBookingID=pn.ItktBookingID and it.Flight=T1.ride+flightno
WHERE T1.cmpcode = '020459'
AND it.FlightClass not like'%����%'
AND T1.inf=0
AND T1.tickettype NOT IN ('���ڷ�', '���շ�','��������')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
) T
GROUP BY CABINFLAG



select coupno,nclass,ride,it.FlightClass,price,priceinfo,price/priceinfo �ۿ�,reti,tickettype,t1.route
FROM Topway..tbcash T1 WITH (NOLOCK)
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=T1.coupno
left join homsomDB..Trv_PnrInfos pn on pn.id=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ItktBookingID=pn.ItktBookingID and it.Flight=T1.ride+flightno
WHERE T1.cmpcode = '020459'
AND it.FlightClass not like'%����%'
AND T1.inf=0
AND T1.tickettype NOT IN ('���ڷ�', '���շ�','��������')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538'))
) order by �ۿ�



--�ؿ���ӡȨ��
select Pstatus ,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='29851' and Id='227668'

--���˺���ʱ��
select dzhxDate,* from Topway..tbcash 
--update Topway..tbcash  set dzhxDate='2019-04-24'
where coupno ='AS002429000'


--�ؿ���ӡ
select pstatus,prdate,* from topway..tbDisctCommission 
--update topway..tbDisctCommission  set pstatus=0,prdate='1900-01-01'
where id='56453'

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=4038,profit=648
where coupno='AS002427407'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=4889,profit=1967
where coupno='AS002426663'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=12580,profit=2641
where coupno='AS002425192'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=8458,profit=1503
where coupno='AS002425762'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=20550,profit=4852
where coupno='AS002419684'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=2023,profit=317
where coupno='AS002424427'

select totsprice,profit,sprice1,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=20,totsprice=20,profit=0
where coupno='AS000000000' and ticketno='3680115830'


select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=13057,profit=1292
where coupno='AS002409962'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=31370,profit=1222
where coupno='AS002412500'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=7723,profit=963
where coupno='AS002415014'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=29854,profit=138
where coupno='AS002421069' and totsprice!=0

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=11580,profit=7816
where coupno='AS002425750' and totsprice!=0

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=3627,profit=211
where coupno='AS002426811'

--�ؿ���ӡ
select pstatus,prdate,* from topway..tbDisctCommission 
--update topway..tbDisctCommission  set pstatus=0,prdate='1900-01-01'
where id in('56428','56429')


--�˵�����
select HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement set HotelSubmitStatus=2
where BillNumber='020296_20190301'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='020730_20190301'

--����۲��
select totsprice,profit,* from  Topway..tbcash 
--update Topway..tbcash  set totsprice=4771,profit=127
where coupno='AS002423245'

--��2018.1.1-2019.4.1�����⺽�ճ��й�2�εĳ��ÿͻ�����2018.1.1-2019.4.1�˹��Ϻ��ĳ��ÿ͡�
--���⺽˾
drop table #rs1
select cmpcode,COUNT(id) ����,pasname ���� ,idno
into #rs1
from Topway..tbcash WITH (NOLOCK)
where begdate>='2018-01-01'
and begdate<'2019-04-02'
and reti=''
and inf=0
--and ride in('MF')
and tickettype='����Ʊ'
and route not like'%����%' 
and route not like'%����%'
and route not like'%��Ʊ%'
and cmpcode in('020730',
'019956',
'015828',
'020165',
'000126',
'016696',
'016179',
'019392',
'017865',
'019089',
'018021',
'017887',
'017120',
'019409',
'019423',
'019654',
'019717',
'019948',
'020020',
'020158',
'020154',
'020220',
'020287',
'020310',
'020350',
'020370',
'018362',
'020774',
'020359',
'020017',
'019822',
'020297',
'020521',
'020506',
'020530',
'020592',
'019637',
'016751',
'020036',
'020758',
'020719',
'019483',
'020731',
'017193',
'020176',

'017275',
'017491',
'001787',
'019839',
'017506',
'017153',
'017969',
'018897',
'020504',

'019294',
'017670',
'019539',
'020039',
'016712',
'016564',
'019663',
'020511',
'018294',
'018677',
'019362',
'017273',
'017376',
'019404',
'019619',
'018642',
'019944',
'019925',
'018615',
'019978',
'017339',
'016556',
'019256',
'020541',
'020441',
'020262',
'016883',
'020640',
'017674',
'017125',
'017525',
'016991',
'020778',
'018156',
'018793',
'019591',
'019242',
'018397',
'019112',
'019325',
'019641',
'016602',
'017423',
'020614',
'020693',
'020717',
'020718',
'020659',
'018661',

'016465',
'014412',
'015717',
'016465',
'016477',
'016572',
'016655',
'016689',
'016777',
'017173',
'017642',
'017739',
'017745',
'017850',
'017988',
'018064',
'018108',
'018257',
'018309',
'018314',
'018443',
'018449',
'018574',
'018821',
'018827',
'018939',
'019143',
'019197',
'019226',
'019245',
'019259',
'019270',
'019349',
'019473',
'019505',
'019513',
'019550',
'019556',
'019651',
'019764',
'019796',
'019798',
'019897',
'019935',
'019975',
'019976',
'019996',
'020051',
'020348',
'020510',
'020588',
'020589',
'020677',
'020708',
'020711')
group by cmpcode,pasname,idno

drop table #rs
select cmpcode,COUNT(id) ����,pasname ���� ,idno,ride
into #rs
from Topway..tbcash WITH (NOLOCK)
where begdate>='2018-01-01'
and begdate<'2019-04-02'
and reti=''
and tickettype not in ('���ڷ�','���շ�','��������')
and route not like'%����%' 
and route not like'%����%'
and route not like'%��Ʊ%'
and cmpcode in('020730',
'019956',
'015828',
'020165',
'000126',
'016696',
'016179',
'019392',
'017865',
'019089',
'018021',
'017887',
'017120',
'019409',
'019423',
'019654',
'019717',
'019948',
'020020',
'020158',
'020154',
'020220',
'020287',
'020310',
'020350',
'020370',
'018362',
'020774',
'020359',
'020017',
'019822',
'020297',
'020521',
'020506',
'020530',
'020592',
'019637',
'016751',
'020036',
'020758',
'020719',
'019483',
'020731',
'017193',
'020176',

'017275',
'017491',
'001787',
'019839',
'017506',
'017153',
'017969',
'018897',
'020504',

'019294',
'017670',
'019539',
'020039',
'016712',
'016564',
'019663',
'020511',
'018294',
'018677',
'019362',
'017273',
'017376',
'019404',
'019619',
'018642',
'019944',
'019925',
'018615',
'019978',
'017339',
'016556',
'019256',
'020541',
'020441',
'020262',
'016883',
'020640',
'017674',
'017125',
'017525',
'016991',
'020778',
'018156',
'018793',
'019591',
'019242',
'018397',
'019112',
'019325',
'019641',
'016602',
'017423',
'020614',
'020693',
'020717',
'020718',
'020659',
'018661',

'016465',
'014412',
'015717',
'016465',
'016477',
'016572',
'016655',
'016689',
'016777',
'017173',
'017642',
'017739',
'017745',
'017850',
'017988',
'018064',
'018108',
'018257',
'018309',
'018314',
'018443',
'018449',
'018574',
'018821',
'018827',
'018939',
'019143',
'019197',
'019226',
'019245',
'019259',
'019270',
'019349',
'019473',
'019505',
'019513',
'019550',
'019556',
'019651',
'019764',
'019796',
'019798',
'019897',
'019935',
'019975',
'019976',
'019996',
'020051',
'020348',
'020510',
'020588',
'020589',
'020677',
'020708',
'020711')
group by cmpcode,pasname,idno,ride

--��Ʊ��¼
drop table #zrs
select  distinct cmpcode,pasname,idno,ride
into #zrs
from Topway..tbcash  WITH (NOLOCK)
where datetime>='2018-01-01'
and datetime<'2019-04-02'
--and reti=''
and tickettype not in ('���ڷ�','���շ�','��������')
and route not like'%����%' 
and route not like'%����%'
--and route not like'%��Ʊ%'
and cmpcode in('020730',
'019956',
'015828',
'020165',
'000126',
'016696',
'016179',
'019392',
'017865',
'019089',
'018021',
'017887',
'017120',
'019409',
'019423',
'019654',
'019717',
'019948',
'020020',
'020158',
'020154',
'020220',
'020287',
'020310',
'020350',
'020370',
'018362',
'020774',
'020359',
'020017',
'019822',
'020297',
'020521',
'020506',
'020530',
'020592',
'019637',
'016751',
'020036',
'020758',
'020719',
'019483',
'020731',
'017193',
'020176',

'017275',
'017491',
'001787',
'019839',
'017506',
'017153',
'017969',
'018897',
'020504',

'019294',
'017670',
'019539',
'020039',
'016712',
'016564',
'019663',
'020511',
'018294',
'018677',
'019362',
'017273',
'017376',
'019404',
'019619',
'018642',
'019944',
'019925',
'018615',
'019978',
'017339',
'016556',
'019256',
'020541',
'020441',
'020262',
'016883',
'020640',
'017674',
'017125',
'017525',
'016991',
'020778',
'018156',
'018793',
'019591',
'019242',
'018397',
'019112',
'019325',
'019641',
'016602',
'017423',
'020614',
'020693',
'020717',
'020718',
'020659',
'018661',

'016465',
'014412',
'015717',
'016465',
'016477',
'016572',
'016655',
'016689',
'016777',
'017173',
'017642',
'017739',
'017745',
'017850',
'017988',
'018064',
'018108',
'018257',
'018309',
'018314',
'018443',
'018449',
'018574',
'018821',
'018827',
'018939',
'019143',
'019197',
'019226',
'019245',
'019259',
'019270',
'019349',
'019473',
'019505',
'019513',
'019550',
'019556',
'019651',
'019764',
'019796',
'019798',
'019897',
'019935',
'019975',
'019976',
'019996',
'020051',
'020348',
'020510',
'020588',
'020589',
'020677',
'020708',
'020711')

select  cmpcode,COUNT(idno) from #zrs 
group by cmpcode

--select  * from #zrs
--select  * from #rs
--select * from #rs1

--��Ʊ����
select cmpcode,COUNT(idno) from #rs1
group by cmpcode

--���⺽�ճ��й�2������
select cmpcode ,COUNT(idno) ���ÿ����� 
from #rs1
where ����>=2
group by cmpcode


--�˹��Ϻ��ĳ��ÿ���
select cmpcode,COUNT(idno) ���ÿ����� 
from #rs
where ride='CZ'
and ����=1
group by cmpcode

--���⺽�ճ��й�2�λ�˹��Ϻ��ĳ��ÿ���

select cmpcode, (case ride when 'cz' then 'cz' else '����' end) ��˾,����,����,idno  
into #qqq
from #rs 

select cmpcode,COUNT(����)  ����
from #qqq where idno not in(Select idno from #qqq where ��˾='cz' )
and ����>=2
group by cmpcode




