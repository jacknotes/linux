/*
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

--UC016485���ز��أ��Ϻ������Ӽ������޹�˾2018��1��1��--12��31�յ��������
--����ʱ��
select c.tcode+c.ticketno,datediff(MINUTE, it.Departing,it.Arriving) from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos pn on pn.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ItktBookingID=pn.ItktBookingID
where cmpcode='016485'
and (datetime>='2018-01-01' and datetime<'2019-01-01')
and inf=0
and reti=''
and tickettype='����Ʊ'



IF OBJECT_ID('tempdb.dbo.#mileage') IS NOT NULL DROP TABLE #mileage
select DISTINCT rtrim(cityfrom)+'-'+rtrim(cityto) route,mileage,kilometres 
into #mileage
from tbmileage

IF OBJECT_ID('tempdb.dbo.#tbcash1') IS NOT NULL DROP TABLE #tbcash1
select pasname �˻���,tcode+ticketno Ʊ��,coupno as ���۵���,ride+flightno as �����,datetime as ��Ʊ����
,case SUBSTRING(route,1,CHARINDEX('-',route)-1) when '�Ϻ��ֶ�' then '�Ϻ�' when '�Ϻ�����' then '�Ϻ�' when '�����׶�' then '����' when '������Է' then '����' when '��������' then '����' 
when '��������' then '����' when '����' then '��ͷ' when '�人���' then '�人' when '����' then '��˫����' when '�����첼����' then '�����첼' when '�º�' then 'â��' when '˼é' then '�ն�' when '÷��' then '÷��'
else SUBSTRING(route,1,CHARINDEX('-',route)-1) end as ����
,case REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) when '�Ϻ��ֶ�' then '�Ϻ�' when '�Ϻ�����' then '�Ϻ�' when '�����׶�' then '����' when '������Է' then '����' when '��������' then '����' 
when '��������' then '����' when '����' then '��ͷ' when '�人���' then '�人' when '����' then '��˫����' when '�����첼����' then '�����첼' when '�º�' then 'â��' when '˼é' then '�ն�' when '÷��' then '÷��'
else  REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) end as ����
,route as �г�
,t_source as ��Ӧ����Դ
into #tbcash1
from tbcash c
where cmpcode='016485'
and (datetime>='2018-01-01' and datetime<'2019-01-01')
and inf=0
and route like ('%-%')
and reti=''
and tickettype='����Ʊ'
order by datetime

select * from #tbcash1

IF OBJECT_ID('tempdb.dbo.#tbcash') IS NOT NULL DROP TABLE #tbcash
select *,����+'-'+���� as route2,����+'-'+���� as route3
into #tbcash
from #tbcash1

--select * from #tbcash
IF OBJECT_ID('tempdb.dbo.#tt') IS NOT NULL DROP TABLE #tt
select �˻���,�����,Ʊ��,���۵���,tbcash.�г�,��Ʊ����,mileage,kilometres
into #tt
from #tbcash tbcash
left join #mileage mileage on mileage.route=tbcash.route2 or mileage.route=tbcash.route3

select * from #tt
where kilometres is null



--select * from tbmileage where cityfrom='�ն�' or cityto='�ն�'
--select * from tbmileage where cityfrom='�ն�' and cityto='����'

--�˸�
select coupno as ���۵���,route as �г�,begdate as ������� from Topway..tbcash 
where cmpcode='019392' 
and (datetime>='2018-01-01' and datetime<'2019-01-01') 
and inf=1 
and (tickettype like ('%����%') or t_source like ('%����%') or route like ('%����%')or reti<>'')

--���ʳ�Ʊ��Ϣ
select coupno as ���۵���,pasname �˻���,tcode+ticketno Ʊ��,ride+flightno ����,REPLACE(route,'-','') �г�
into #test
from Topway..tbcash 
where cmpcode='016485' 
and (datetime>='2018-01-01' and datetime<'2019-01-01') 
and reti=''
and tickettype not in ('���ڷ�', '���շ�','��������')
and route not like'%����%'
and route not like'%����%'
and route not like'%��Ʊ%'
and inf=1 

--����г�
select ���۵���,�˻���,Ʊ��,����,SUBSTRING(�г�,1,3)�г�1, SUBSTRING(�г�,4,3)�г�2, SUBSTRING(�г�,7,3)�г�3, SUBSTRING(�г�,10,3)�г�4
into #test1
from #test 

--�г�1
select * 
into #xc1
from #test1 test
inner join Topway..tbmileage t on (t.CityFromCode=�г�1 and t.CityToCode=�г�2)

--�г�2
select * 
into #xc2
from #test1 test
inner join Topway..tbmileage t on (t.CityFromCode=�г�2 and t.CityToCode=�г�3)

--�г�3
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

select Kilometres,* from Topway..tbmileage

AS001354232 PVG-SFO-PVG
--�ؿ���ӡ
select PrintDate,Pstatus,* from Topway..HM_tbReti_tbReFundPayMent 
--update Topway..HM_tbReti_tbReFundPayMent set PrintDate='1900-01-01',Pstatus=0
where Id='703732'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='020334_20190301'

select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='020209_20190301'

--�Ƶ����۵�����
select status,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set status=-2
where CoupNo='-PTW077430'

select * 
--delete
from Topway..tbHtlcoupYf 
where CoupNo='-PTW077430'

select * 
--delete
from Topway..tbhtlyfchargeoff 
where coupid in(select id from Topway..tbHtlcoupYf where CoupNo='-PTW077430')


/*
UC016655 ��Ʊ����2019��4��1����2019��4��18�ţ����ڻ�Ʊ������Ʊ�����޵����۵������������������������£�
 
��Ʊ���ڣ� �������۵��� ���۵����� ��Ӧ����Դ PNR Ʊ��  �˿����� ����  ��λ  ���۵��� ˰�� �������� ���ۼ� �����

*/
select indate,coupno,tickettype,t_source,recno,tcode+ticketno,pasname,
route,nclass,price,tax,profit,totprice,fuprice
 from Topway..tbcash 
where cmpcode='016655'
and datetime>='2019-04-01'
and datetime<'2019-04-19'
and baoxiaopz=0 --����Ʊ����
and inf=0
order by indate

SELECT * from ApproveBase..App_Content where BaseAppNo='WF0096' and EnItem='Reason' order by TransDatetime desc



select IsJoinRank,* from Topway..Emppwd 
--update Topway..Emppwd set IsJoinRank=1
where idnumber in ('0700','0720')

--��Ʊ
SELECT t1.RecordNumber,t5.Name 
FROM homsomDB..Trv_DomesticTicketRecord t1
left join homsomDB..Trv_PnrInfos t2 on t2.ID=t1.PnrInfoID
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t2.ItktBookingID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='����'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.RecordNumber in 
('AS002339178',
'AS002342885',
'AS002343589',
'AS002347417',
'AS002347421',
'AS002349739',
'AS002356941',
'AS002358664',
'AS002359707',
'AS002359923',
'AS002360585',
'AS002361267',
'AS002361404',
'AS002361432',
'AS002361459',
'AS002361461',
'AS002361463',
'AS002361465',
'AS002361481',
'AS002361529',
'AS002361549',
'AS002363713',
'AS002364829',
'AS002364843',
'AS002365393',
'AS002365754',
'AS002368287',
'AS002368289',
'AS002368291',
'AS002368483',
'AS002368491',
'AS002368509',
'AS002369653',
'AS002370852',
'AS002371493',
'AS002374385',
'AS002374392',
'AS002374406',
'AS002374406',
'AS002374406',
'AS002376191',
'AS002376800',
'AS002379149',
'AS002379157',
'AS002379159',
'AS002381115',
'AS002381291',
'AS002382499',
'AS002382499',
'AS002383218',
'AS002383228',
'AS002384362',
'AS002384850',
'AS002385105',
'AS002385127',
'AS002385348',
'AS002385354',
'AS002388677',
'AS002388677',
'AS002390485',
'AS002390564',
'AS002390597',
'AS002390701',
'AS002390869',
'AS002391628',
'AS002394004',
'AS002394004',
'AS002394191',
'AS002394191',
'AS002401917',
'AS002401925',
'AS002405029',
'AS002405105',
'AS002405256',
'AS002407127',
'AS002407144',
'AS002408076',
'AS002408079',
'AS002408259',
'AS002408417',
'AS002408704',
'AS002410475',
'AS002411702',
'AS002412018',
'AS002412188',
'AS002412241',
'AS002412282',
'AS002412726',
'AS002413504',
'AS002413506',
'AS002414027',
'AS002414304',
'AS002414494',
'AS002414604',
'AS002414618',
'AS002414744',
'AS002415292') 
and NodeType=110 and NodeID=111

--һ�� NodeType=110 and NodeID=110
--���� NodeType=110 and NodeID=111

--�Ƶ�
SELECT CoupNo,t5.Name FROM HotelOrderDB..HTL_Orders t1
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t1.OrderID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='����'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.CoupNo in 
( 'PTW079377') and NodeType=110 and NodeID=110

--UC���޸ģ����Σ�
select * from Topway..tbTravelBudget
--update Topway..tbTravelBudget set custid='D663853',cmpid='020796',Custinfo='13917626481@�ž���@020796@�Ϻ���������Ƽ���չ���޹�˾@13917626481@�ž���' 
where trvid='29900'

/*
����ס��UC018734 �������UC018080  �������UC018897 ������UC020640 ����ŷ��UC020571   ���ɹ���UC020750
3�¡�2�µĻ�Ʊ����
�Ƿ�������ֻ�Ʊ����
*/
drop table #sss
select CmpId UC,convert(varchar(6),OutBegdate,112) �·�,SUM(TotPrice) ����,SUM(TotFuprice) ����,COUNT(ID) ���� 
into #sss
from Topway..tbTrainTicketInfo 
where 
--CmpId in('018734','018080','018897','020640','020571','020750')
OriginalBillNumber in ('018734_20190101','018734_20190201','018734_20190301','018734_20190401',
'018080_20190101','018080_20190201','018080_20190301','018080_20190401','018897_20190101',
'018897_20190201','018897_20190301','018897_20190401','020640_20190101','020640_20190201','020640_20190301',
'020640_20190401','020571_20190126','020571_20190226','020571_20190326','020571_20181226','020750_20190401','020750_20190301')
and OutBegdate>='2019-01-01'
--and OutBegdate<'2019-04-01'
group by convert(varchar(6),OutBegdate,112),CmpId
order BY �·�

select �·�,SUM(����) ����,SUM(����) ���� from #sss
group by �·�

('018734','018080','018897','020640','020571','020750') 
select * from Topway..AccountStatement where CompanyCode='020750' order by BillNumber desc

--��ӡȨ��
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus=0,PrDate='1900-01-01'
where TrvId='29905' and Id='227756'

--�������ݸ���
select * from homsomDB..Trv_Airport
--update homsomDB..Trv_Airport set AbbreviationName=Name

select * from homsomDB..Trv_Cities where CountryType=2
--update homsomDB..Trv_Cities set AbbreviatedName=Name where CountryType=2


--��Ʊ״̬
select Status,* from Topway..HM_tbReti_tbReFundPayMent 
--update Topway..HM_tbReti_tbReFundPayMent  set Status=4
where Id='703736'

--ƥ�����۵���
select coupno,price from Topway..tbcash 
where coupno in ('AS002362969',
'AS002362973',
'AS002368269',
'AS002371350',
'AS002387611',
'AS002387885',
'AS002388068',
'AS002388115',
'AS002388297',
'AS002389079',
'AS002389085',
'AS002397246',
'AS002399972',
'AS002407822',
'AS002413129',
'AS002413218',
'AS002413393',
'AS002415191',
'AS002419579',
'AS002421329')


select * from homsomDB..Trv_Cities where Code in ('BGG','GNI','JNS','AAD','SIC','KEW','KCK','NAH','ETE','BEM','CAT')
select * from homsomDB..Trv_Cities where ID='20945477-B8A5-424D-A369-04FC728025BB'
select * from homsomDB..Trv_Airport where Code='GNI'

select a.Code ������,c.Code ������,a.Name ������,c.Name ������,a.EnglishName ������,c.EnglishName ������,
a.AbbreviationName �������,c.AbbreviatedName  ���м��
from homsomDB..Trv_Airport a
left join homsomDB..Trv_Cities c on c.ID=a.CityID


