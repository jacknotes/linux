--UC017739  2016��-2017��֮��ĳ����¼
select indate,begdate,coupno,route,pasname from Topway..tbcash 
where pasname in ('������',
'����',
'��ɽ��',
'������',
'QU Shengjie',
'���',
'������',
'����',
'���',
'����',
'����',
'��褳�',
'�Ӻ�',
'����',
'����',
'����',
'�����')
and datetime>='2016-01-01'
and datetime<'2018-01-01'
and inf!=-1
and tickettype not like'%����%'
and tickettype not like'%����%'
and [route] not like '%����%'
and [route] not like '%����%'
and reti=''
order by indate


--��������
select * 
--delete
from Topway..tbTrvCoup where TrvId='11563'

select Status,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Status='12'
where TrvId='11563'

--�޸�Ԥ�㵥��
--select * from Topway..tbTravelBudget where TrvId='29887'
select * from Topway..tbTrvJS 
--update Topway..tbTrvJS  set TrvId='29887'
where TrvId='11563' and Id in 
(select  trvYsId from Topway..tbcash where coupno in
('AS002395386','AS002395442','AS002395900','AS002395909','AS002395935','AS002395941'))

--����Ʒר�ã��������Դ/�����Ϣ�����ʣ�
select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash  set feiyong=0,feiyonginfo=''
where coupno='AS002414089' 

--�޸����۵���
--select price,totprice,profit,owe,amount,profit,* from Topway..tbcash where coupno='AS002401077'
update Topway..tbcash set price=1310,totprice=1370,owe=1370,amount=1370,profit=profit-80 where coupno='AS002401077'
update Topway..tbcash set price=1310,totprice=1370,owe=1370,amount=1370,profit=profit-80 where coupno='AS002401062 '
update Topway..tbcash set price=1310,totprice=1370,owe=1370,amount=1370,profit=profit-80 where coupno='AS002400677'
update Topway..tbcash set price=1310,totprice=1370,owe=1370,amount=1370,profit=profit-80 where coupno='AS002400383'
update Topway..tbcash set price=1310,totprice=1370,owe=1370,amount=1370,profit=profit-80 where coupno='AS002398062'
update Topway..tbcash set price=1310,totprice=1370,owe=1370,amount=1370,profit=profit-80 where coupno='AS002394912'
update Topway..tbcash set price=1490,totprice=1550,owe=1550,amount=1550,profit=profit-100 where coupno='AS002393702'
update Topway..tbcash set price=1810,totprice=1870,owe=1870,amount=1870,profit=profit-100 where coupno='AS002393503'
update Topway..tbcash set price=1310,totprice=1370,owe=1370,amount=1370,profit=profit-80 where coupno='AS002392994'
update Topway..tbcash set price=1310,totprice=1370,owe=1370,amount=1370,profit=profit-80 where coupno='AS002392884'
update Topway..tbcash set price=1310,totprice=1370,owe=1370,amount=1370,profit=profit-80 where coupno='AS002392879'
update Topway..tbcash set price=1810,totprice=1870,owe=1870,amount=1870,profit=profit-110 where coupno='AS002392123'
update Topway..tbcash set price=1310,totprice=1370,owe=1370,amount=1370,profit=profit-80 where coupno='AS002392021'
update Topway..tbcash set price=1700,totprice=1760,owe=1760,amount=1760,profit=profit-120 where coupno='AS002390185'
update Topway..tbcash set price=1330,totprice=1390,owe=1390,amount=1390,profit=profit-80 where coupno='AS002388216'
update Topway..tbcash set price=1310,totprice=1370,owe=1370,amount=1370,profit=profit-80 where coupno='AS002386406'
update Topway..tbcash set price=1650,totprice=1710,owe=1710,amount=1710,profit=profit-100 where coupno='AS002385980'
update Topway..tbcash set price=1330,totprice=1390,owe=1390,amount=1390,profit=profit-80 where coupno='AS002385860'
update Topway..tbcash set price=1310,totprice=1370,owe=1370,amount=1370,profit=profit-80 where coupno='AS002384814'
update Topway..tbcash set price=1490,totprice=1550,owe=1550,amount=1550,profit=profit-100 where coupno='AS002384215'
update Topway..tbcash set price=1650,totprice=1710,owe=1710,amount=1710,profit=profit-100 where coupno='AS002384066'
update Topway..tbcash set price=1550,totprice=1610,owe=1610,amount=1610,profit=profit-110 where coupno='AS002384005'
update Topway..tbcash set price=1650,totprice=1710,owe=1710,amount=1710,profit=profit-110 where coupno='AS002383478'
update Topway..tbcash set price=1090,totprice=1150,owe=1150,amount=1150,profit=profit-300 where coupno='AS002383461'
update Topway..tbcash set price=1310,totprice=1370,owe=1370,amount=1370,profit=profit-80 where coupno='AS002383341'
update Topway..tbcash set price=1330,totprice=1390,owe=1390,amount=1390,profit=profit-80 where coupno='AS002383205'
update Topway..tbcash set price=1330,totprice=1390,owe=1390,amount=1390,profit=profit-80 where coupno='AS002383136'
update Topway..tbcash set price=1330,totprice=1390,owe=1390,amount=1390,profit=profit-80 where coupno='AS002381803'
update Topway..tbcash set price=1310,totprice=1370,owe=1370,amount=1370,profit=profit-80 where coupno='AS002379330'
update Topway..tbcash set price=1200,totprice=1260,owe=1260,amount=1260,profit=profit-100 where coupno='AS002379262'
update Topway..tbcash set price=670,totprice=730,owe=730,amount=730,profit=profit-30 where coupno='AS002377847'
update Topway..tbcash set price=670,totprice=730,owe=730,amount=730,profit=profit-30 where coupno='AS002373898'
update Topway..tbcash set price=910,totprice=970,owe=970,amount=970,profit=profit-40 where coupno='AS002373169'
update Topway..tbcash set price=990,totprice=1050,owe=1050,amount=1050,profit=profit-40 where coupno='AS002369709'
update Topway..tbcash set price=1430,totprice=1490,owe=1490,amount=1490,profit=profit-90 where coupno='AS002369394'
update Topway..tbcash set price=1460,totprice=1520,owe=1520,amount=1520,profit=profit-100 where coupno='AS002369390'
update Topway..tbcash set price=1870,totprice=1930,owe=1930,amount=1930,profit=profit-100 where coupno='AS002368058'
update Topway..tbcash set price=1810,totprice=1870,owe=1870,amount=1870,profit=profit-100 where coupno='AS002367966'
update Topway..tbcash set price=990,totprice=1050,owe=1050,amount=1050,profit=profit-40 where coupno='AS002365902'
update Topway..tbcash set price=1310,totprice=1370,owe=1370,amount=1370,profit=profit-80 where coupno='AS002364334'
update Topway..tbcash set price=1430,totprice=1490,owe=1490,amount=1490,profit=profit-90 where coupno='AS002363289'

--���ν��㵥��Ϣ
select * 
--delete
from Topway..tbTrvJS where TrvId='29892' and JsPrice='10967'

select status,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set status=-2
where CoupNo='PTW080813'

--ɾ����������
select dzhxDate,CustomerPayDate,* from Topway..tbcash 
--update Topway..tbcash set CustomerPayDate='1900-01-01'
where coupno  in ('AS002414826','AS002414827','AS002414830')

--�޸�Ԥ����
--select * from homsomDB..Trv_Human where Mobile='15902132334' and IsDisplay=1
--select * from homsomDB..Trv_UnitPersons where ID='7A5B64B8-4CB7-447C-A0D1-73EEDE4477B8'

select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,pform,xfprice,pasname,* from Topway..tbcash
--update topway..tbcash set custid='D642884'
 where coupno in ('AS002330862')
 
 select CustId,Customer,Person,Tel,sperson,* from Topway..tbFiveCoupInfo 
  --update Topway..tbFiveCoupInfo set CustId='D642884',Customer='����ٻ',Person='����ٻ|13816472660',sperson='����ٻ'
  where CoupNo in('AS002330862')
  
  --�޸��˵�̧ͷ
  select CompanyNameCN,* from Topway..AccountStatement 
  --update Topway..AccountStatement  set CompanyNameCN='�٣�ŵ�Ҽ����ó�ף��Ϻ������޹�˾'
  where BillNumber='018726_20190401'

--��Ʊ��Ʒ����Ӧ�̿������й�Ӧ����ϸ����
--0����,1����,2����,3����,4�����ѹ���,5�����ѹ���,6�����Ѳ���
--ҵ������(BSP��˳ = 1, BSP���� = 2, �⿪Ʊ = 3, Ա���渶 = 4, ƽ̨ = 5, B2B = 6, ���� = 7, ���� = 8, ������ = 9)

select code, (case ntype when 0 then '����' when 1 then '����' when 2 then '����' when 3 then '����' when 4 then '�����ѹ���' when 5 then '�����ѹ���' when 6 then '�����Ѳ���' else '' end) ҵ�����,
 (case tcode when 0 then '��ʾ' when 1 then '����' else '' end) ��ʾ,acountname ��λ����,
 (case SettleType when 1 then 'BSP��˳' when 2 then 'BSP����' when 3 then '�⿪Ʊ' when 4 then 'Ա���渶' when 5 then 'ƽ̨' when 6 then 'B2B' when 7 then '����' when 8 then '����'
 when 9 then '������' else '' end )��������,cmpcon ��ϵ��,cmpmobile �ֻ�,cmptel �绰,cmpfax ����,cmpaddress ��λ��ַ,cmpemail Email
from topway..tbintercmp


/*
��Ʊ���ڣ�2018��1��-2019��4��1��
   ���˺�˾��9W
   ��۳���Ʊ
   ����Ҫ��  ���۵��š�Ʊ�š�PNR���г̡�������ڡ�����ҵ����ʡ�����ҵ�����
*/
select coupno ,tcode+ticketno,recno,route,begdate,SpareTC,sales
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-04-02'
and ride ='9W'
and reti=''
order by datetime


--����Ʒר�ã��������Դ/�����Ϣ�����ʣ�
select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash set feiyonginfo='������λHYI'
where coupno='AS002415730'

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update  Topway..tbcash set totsprice=12720,profit=1205
where coupno='AS002415364'

--���ۼ��޸�
select tcode+ticketno Ʊ��,id ��ˮ��,price ���۵���,sprice1 �ļ���1,totprice ���ۼ�,totsprice �����,profit ����,owe Ӧ��,amount,* from Topway..tbcash 
--update Topway..tbcash set price=532,sprice1=532,totprice=532,owe=532,amount=532,totsprice=532
where coupno ='AS002416781'

--�������ݸ���
select * from homsomDB..Trv_Airport
--update homsomDB..Trv_Airport set AbbreviationName=Name

select * from homsomDB..Trv_Cities where CountryType=2
--update homsomDB..Trv_Cities set AbbreviatedName=Name where CountryType=2


/*
select * from homsomDB..Trv_FlightTripartitePolicies
select top 100 RebateStr,* from homsomDB..Trv_ItktBookingSegs

���������ڻ�Ҫһ�����ݣ�
����2018.7--12�� ����ʹ�ô�ͻ�Э������ռ��    %�����ƽ�Լ      Ԫ
����������⣺����ռ��    %�����ƽ�Լ      Ԫ
*/
drop table #ccc
select RebateStr,SUM(price) ����,COUNT(c.id) ���� ,sum(convert(decimal(8,2),originalprice)) ԭ����
into #ccc
from Topway..tbcash C
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos pn on pn.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ItktBookingID=pn.ItktBookingID and c.ride+C.flightno=it.Flight
--LEFT JOIN homsomDB..Trv_ItktBookingSegments_PnrInfos p ON p.ItktBookingSegID=it.ID
where
-- datetime>='2018-07-01'
--and datetime<'2019-01-01'
(ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and ride in ('MU','FM')
and cmpcode='020459'
and inf=0
and tickettype not in ('���ڷ�', '���շ�','��������')
group by RebateStr

select sum(����) ������,SUM(����) ������,SUM(ԭ����)�ۿ�ǰ������  from #ccc

--��ͻ�Э��

select SUM(����) �ϼ�,SUM(����) ����,SUM(ԭ����) �ۿ�ǰ����,(100-Discount)/100 �ۿ� from #ccc ccc
inner join homsomDB..Trv_FlightTripartitePolicies f on f.ID=ccc.RebateStr
group by Discount


--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=2405,profit=166
where coupno='AS002413796'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=3280,profit=1123
where coupno='AS002416456'

--�г̵�������Ʊ��
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where datetime>='2019-03-17' 
and cmpcode='020748'

--�г̵�
select info3 �г̵�,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno in('AS002407838',
'AS002407458',
'AS002407275',
'AS002407271',
'AS002407179',
'AS002407084',
'AS002406607',
'AS002406605',
'AS002406348',
'AS002406111',
'AS002406107',
'AS002405828',
'AS002405824',
'AS002405822',
'AS002405811',
'AS002405807',
'AS002405801',
'AS002405793',
'AS002405791',
'AS002405554',
'AS002405440',
'AS002405322',
'AS002404937',
'AS002404723',
'AS002404708',
'AS002404474',
'AS002404458',
'AS002404414',
'AS002403978',
'AS002403192',
'AS002403190',
'AS002402668',
'AS002402466',
'AS002402120',
'AS002402108',
'AS002402106',
'AS002402100',
'AS002402090',
'AS002402086',
'AS002402086',
'AS002401106',
'AS002401077',
'AS002401062',
'AS002400687',
'AS002400679',
'AS002400677',
'AS002400412',
'AS002400383',
'AS002399716',
'AS002399646',
'AS002399289',
'AS002398993',
'AS002398062',
'AS002397979',
'AS002397670',
'AS002397666',
'AS002397444',
'AS002396982',
'AS002396915',
'AS002396909',
'AS002396790',
'AS002396131',
'AS002396053',
'AS002395349',
'AS002395225',
'AS002395136',
'AS002394912',
'AS002394031',
'AS002393710',
'AS002393702',
'AS002393702',
'AS002393503',
'AS002393190',
'AS002393181',
'AS002393175',
'AS002392994',
'AS002392884',
'AS002392879',
'AS002392806',
'AS002392714',
'AS002392123',
'AS002392021',
'AS002391530',
'AS002391521',
'AS002391245',
'AS002391245',
'AS002391068',
'AS002391061',
'AS002390871',
'AS002390734',
'AS002390501',
'AS002390185',
'AS002389838',
'AS002389569',
'AS002388855',
'AS002388216',
'AS002388051',
'AS002387818',
'AS002387479',
'AS002387215',
'AS002387177',
'AS002387098',
'AS002386905',
'AS002386788',
'AS002386635',
'AS002386453',
'AS002386406',
'AS002386135',
'AS002385980',
'AS002385902',
'AS002385896',
'AS002385890',
'AS002385860',
'AS002385447',
'AS002385433',
'AS002385412',
'AS002384814',
'AS002384789',
'AS002384633',
'AS002384215',
'AS002384066',
'AS002384005',
'AS002383997',
'AS002383478',
'AS002383461',
'AS002383341',
'AS002383205',
'AS002383205',
'AS002383200',
'AS002383136',
'AS002382395',
'AS002382371',
'AS002381803',
'AS002381616',
'AS002381616',
'AS002381541',
'AS002380429',
'AS002379330',
'AS002379262',
'AS002378012',
'AS002377847',
'AS002377517',
'AS002377466',
'AS002377239',
'AS002377112',
'AS002376917',
'AS002376909',
'AS002376903',
'AS002376748',
'AS002374777',
'AS002374313',
'AS002374286',
'AS002374143',
'AS002373898',
'AS002373169',
'AS002371980',
'AS002371648',
'AS002371093',
'AS002369711',
'AS002369709',
'AS002369394',
'AS002369390',
'AS002368850',
'AS002368842',
'AS002368658',
'AS002368058',
'AS002367966',
'AS002367268',
'AS002367243',
'AS002367231',
'AS002366637',
'AS002366635',
'AS002366513',
'AS002365902',
'AS002365791',
'AS002365780',
'AS002365276',
'AS002364334',
'AS002363289',
'AS002362967',
'AS002362768',
'AS002362255',
'AS002362251')



--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020260_20190301'

--��ע
select oth2,* from Topway..tbcash 
--update Topway..tbcash set oth2='4/12���� ������25100 AS002405917�ึ��1040�� AS002395831ȫ���ˣ�AS002395779Ʊ��7843652757477ֻ����Ʊ��230'
where coupno in ('AS002395831')

select oth2,* from Topway..tbcash 
--update Topway..tbcash set oth2='4/12���� ������25100 AS002405917�ึ��1040��AS002395831ȫ���ˣ�AS002395779Ʊ��7843652757477ֻ����Ʊ��230'
where coupno in ('AS002405917',
'AS002395955',
'AS002395849',
'AS002395846',
'AS002395844',
'AS002395839',
'AS002395838',
'AS002395824',
'AS002395809',
'AS002395796',
'AS002395790',
'AS002395783',
'AS002395346',
'AS002395779')

select info,* from Topway..tbReti 
--update Topway..tbReti set info='4/12���� ������25100 AS002405917�ึ��1040�� AS002395831ȫ���ˣ�AS002395779Ʊ��7843652757477ֻ����Ʊ��230'
where reno='0432260'


/*
UC017888 ��Ʊ����2019��4��1����2019��4��22�ţ����ڻ�Ʊ������Ʊ�����޵����۵������������������������£�
 
��Ʊ���ڣ� �������۵��� ���۵����� ��Ӧ����Դ PNR Ʊ��  �˿����� ����  ��λ  ���۵��� ˰�� �������� ���ۼ� ����� 
*/
select indate,coupno,tickettype,t_source,recno,tcode+ticketno,pasname,route,nclass,
price,tax,profit,totprice,fuprice from Topway..tbcash 
where cmpcode='017888'
and datetime>='2019-04-01'
and baoxiaopz=0 --����Ʊ����
and inf=0
order by datetime

--��Ʊ��Ӧ����Դ/������Ϣ
select Tsource,* from Topway..tbTrainTicketInfo 
--update Topway..tbTrainTicketInfo set Tsource='������Ʊ'
where CoupNo='RS000022555'
