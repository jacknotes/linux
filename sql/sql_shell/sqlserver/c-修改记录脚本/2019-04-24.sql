/*
��æͳ���������۵���ӡʱ����1745��1845����Ʊ����ÿ���Ŷ��٣����ǳ�Ʊ�������۵�����ʱ��
��æͳ��һ��������ݣ����б�ʾ��һ-����
����4�·����������յĺ��ˣ�������ǵĽڼ��ձ�
*/

select CONVERT(varchar(10),indate,120) ����,COUNT(id) ���� from Topway..tbcash 
where convert(varchar,indate,108)>='17:45:00'
and convert(varchar,indate,108)<='18:45:00'
and ((indate>='2019-04-01' and indate<'2019-04-05')
or (indate>='2019-04-08' and indate<'2019-04-13')
or (indate>='2019-04-15' and indate<'2019-04-20')
or (indate>='2019-04-22' and indate<'2019-04-26'))
and tickettype not in ('���ڷ�','���շ�','��������')
and  route  not like '%����%'
and  route  not like '%����%'
group by CONVERT(varchar(10),indate,120)
order by ����

/*
��æͳ���������۵���ӡʱ����1745��1845����Ʊ����ÿ���Ŷ��٣����ǳ�Ʊ�������۵�����ʱ��
��æͳ��һ��������ݣ����б�ʾ��һ-����
����4�·����������յĺ��ˣ�������ǵĽڼ��ձ�
*/
--����
select CONVERT(varchar(10),CreateDate,120) ����,COUNT(ID) ����    
into #gncp  
from homsomDB..Trv_DomesticTicketRecord 
where convert(varchar,CreateDate,108)>='17:45:00'
and convert(varchar,CreateDate,108)<='18:45:00'
and ((CreateDate>='2019-04-01' and CreateDate<'2019-04-05')
or (CreateDate>='2019-04-08' and CreateDate<'2019-04-13')
or (CreateDate>='2019-04-15' and CreateDate<'2019-04-20')
or (CreateDate>='2019-04-22' and CreateDate<'2019-04-26'))
group by CONVERT(varchar(10),CreateDate,120)
order by ����

--����
SELECT  convert(varchar(10),Ndate,120) ����,COUNT(CoupNo) ���� 
into #gjcp
FROM Topway..tbFiveCoupInfo
where convert(varchar,Ndate,108)>='17:45:00'
and convert(varchar,Ndate,108)<='18:45:00'
and ((Ndate>='2019-04-01' and Ndate<'2019-04-05')
or (Ndate>='2019-04-08' and Ndate<'2019-04-13')
or (Ndate>='2019-04-15' and Ndate<'2019-04-20')
or (Ndate>='2019-04-22' and Ndate<'2019-04-26'))
group by convert(varchar(10),Ndate,120)
order by ����

--����
select gn.����,gn.����+gj.���� ���� from #gncp gn
left join #gjcp gj on gj.����=gn.����


--��Ʊ���ۼ���Ϣ
select TotFuprice,TotPrice,TotSprice,TotUnitprice from Topway..tbTrainTicketInfo 
--update Topway..tbTrainTicketInfo  set TotFuprice='',TotPrice='443.5'
where CoupNo='RS000022474'

select Fuprice,* from Topway..tbTrainUser 
--update Topway..tbTrainUser  set Fuprice=''
where  TrainTicketNo=(select id from Topway..tbTrainTicketInfo 
where CoupNo='RS000022474')


--�г̵�������Ʊ��

select info3,baoxiaopz from Topway..tbcash 
where coupno in('AS002368883',
'AS002366412',
'AS002372391',
'AS002372395',
'AS002372379',
'AS002372403',
'AS002377445',
'AS002379629',
'AS002379717',
'AS002382185',
'AS002383195',
'AS002383203',
'AS002386102',
'AS002386104',
'AS002386114',
'AS002386122',
'AS002387605',
'AS002387821',
'AS002387827',
'AS002387837',
'AS002387839',
'AS002388084',
'AS002390746',
'AS002390746',
'AS002390742',
'AS002390748',
'AS002390738',
'AS002391092',
'AS002393403',
'AS002393401',
'AS002395213',
'AS002395211',
'AS002395215',
'AS002395339',
'AS002395463',
'AS002395467',
'AS002395470',
'AS002395476',
'AS002395486',
'AS002395482',
'AS002395472',
'AS002395496',
'AS002395498',
'AS002395494',
'AS002395693',
'AS002395695',
'AS002395715',
'AS002395719',
'AS002395745',
'AS002395751',
'AS002395788',
'AS002395869',
'AS002395871',
'AS002395871',
'AS002395877',
'AS002395888',
'AS002395931',
'AS002395929',
'AS002396011',
'AS002396015',
'AS002396015',
'AS002395977',
'AS002395983',
'AS002395993',
'AS002395979',
'AS002396022',
'AS002396030',
'AS002396034',
'AS002396043',
'AS002397191',
'AS002397198',
'AS002397838',
'AS002399157',
'AS002399165',
'AS002399488',
'AS002399554',
'AS002399801',
'AS002399776',
'AS002399797',
'AS002399815',
'AS002399785',
'AS002399813',
'AS002400771',
'AS002401625',
'AS002403617',
'AS002403661',
'AS002405363',
'AS002405377',
'AS002408243',
'AS002408251',
'AS002411336')

--�ؿ���ӡ
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='29866' and Id='227589'

--����Ԥ�㵥��Ϣ
select Sales,* from Topway..tbConventionBudget 
--update  Topway..tbConventionBudget set Sales='�Ź㺮'
where ConventionId ='1167'


--��λ�ͻ����Ŷ�ȵ���
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SX_TotalCreditLine=30000
where BillNumber='020547_20190401'

--�˵�����
select HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement set HotelSubmitStatus=2
where BillNumber='020296_20190301'

/*ɸѡ������
1.���ڱ���ƾ֤���г̵�
2.�����������Ʊ�ۣ���

��Ҫ��ȡ����Ϣ
UC����λ���ơ����ù��ʡ���Ӫ����

*/
select u.Cmpid,u.Name,isnull(s.Name,'') ���ù���,isnull(MaintainName,'') ��Ӫ����
from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_TktUnitCompanies_TktTCs a on a.TktUnitCompanyID=u.ID 
LEFT JOIN homsomDB..SSO_Users s ON s.ID=a.TktTCID
left join Topway..HM_ThePreservationOfHumanInformation t on t.CmpId=u.Cmpid and MaintainType=9 and t.IsDisplay=1
where CertificateD=1
and IsSepPrice=1
and u.Type='A'
and CooperativeStatus in ('1','2','3')
and u.Cmpid not in ('000003','000006')

--ƥ�䷵������
select * from homsomDB..Intl_BookingOrders where SalesOrderNo='AS002314128'
select inf,* from Topway..tbcash where coupno='AS002314128'
select top 100 OrderId,* from Topway..tbFiveCoupInfo 

select CoupNo,L.DepartureTime from homsomDB..Intl_BookingLegs l
left join homsomDB..Intl_BookingSegements s on l.BookingSegmentId=s.Id
left join Topway..tbFiveCoupInfo f on f.OrderId=s.BookingOrderId
where Code2='pvg'
AND  CoupNo in ('AS002419379',
'AS002414506',
'AS002384864',
'AS002351473',
'AS002349229',
'AS002349229',
'AS002329917',
'AS002328334',
'AS002323273',
'AS002314808',
'AS002314128',
'AS002314128',
'AS002314127',
'AS002290123',
'AS002290123')
AND Code1 IN('LHR',
'LHR',
'HKG',
'DXB',
'LHR',
'LHR',
'MAD',
'LHR',
'HKG',
'MAD',
'MAD',
'MAD',
'MAD',
'LHR',
'LHR')

/*
UC017579
�г����ڣ�2016.08.01-2018.12-31
�г̣�

1��	�Ϻ�-����
2��	����-�Ϻ�
3��	�Ϻ�-����
4��	����-�Ϻ�

�˻��ˣ�Ҧ��־����־����������ң������������飬����̣�������������Ȼ���Ż����������
*/
select datetime,begdate,coupno,pasname,route,ride+flightno,tcode+ticketno,price, 
tax,xfprice ��Ӷ���,totprice,reti,tickettype
from Topway..tbcash 
where begdate>='2016-08-01'
and inf=0
and begdate<'2019-01-01'
and cmpcode='017579'
and (route like('%�Ϻ�%����%')
or route like('%����%�Ϻ�%')
or route like('%�Ϻ�%����%')
or route like('%����%�Ϻ�%'))
and pasname in('Ҧ��־','��־��','����','����'
,'������','����','�����','������','����Ȼ','�Ż���','�����')
order by datetime

--�޸Ĳ�����
select SpareTC,sales,* from Topway..tbcash 
--update Topway..tbcash  set SpareTC='�ų�'
where coupno='AS002426470'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='017290_20190301'

--���������Ϊδ��
select haschecked,* from topway..FinanceERP_ClientBankRealIncomeDetail
--update topway..FinanceERP_ClientBankRealIncomeDetail set haschecked=0
 where money='25304' and date='2019-04-23'



--��˾���
select * from ehomsom..tbInfAirCompany
insert into ehomsom..tbInfAirCompany (id,airname,sx1,sx,code2,[http],ntype,modifyDate,enairname,IsDeleted,sortNo,phone1,phone2,introinf)
values (NEWID(),'̩��ʨ��','̩��ʨ��','̩��ʨ��','SL','www.lionairthai.com','1','2019-04-24','Thai Lion Air',null,'1',null,null,null)

SELECT * from homsomDB..Trv_Airport 
--update homsomDB..Trv_Airport set Name='���������',EnglishName='Bingol Airport',AbbreviationName='���������'
where Code='BGG'


SELECT * from homsomDB..Trv_Airport 
--update homsomDB..Trv_Airport set Name='���������',EnglishName='Bingol Airport',AbbreviationName='���������'
where Code='GNI'

select * from homsomDB..Trv_Cities where Code='GNI'

SELECT * from homsomDB..Trv_Airport 
--update homsomDB..Trv_Airport set Name='���������',EnglishName='Bingol Airport',AbbreviationName='���������'
where Code='BGG'

SELECT * from homsomDB..Trv_Airport 
--update homsomDB..Trv_Airport set Name='���������',EnglishName='Bingol Airport',AbbreviationName='���������'
where Code='BGG'

--UC017739 ��Ʊ����2019��4��1����2019��4��24�ţ����ڻ�Ʊ������Ʊ�����޵����۵�����������
--��Ʊ���ڣ� �������۵��� ���۵����� ��Ӧ����Դ PNR Ʊ��  �˿����� ����  ��λ  ���۵��� ˰�� �������� ���ۼ� ����� 

select convert(varchar(10),datetime,120) ��Ʊ����, coupno,tickettype,t_source,recno,tcode+ticketno,pasname
,route,nclass,price,tax,profit ,totprice,fuprice
from Topway..tbcash 
where cmpcode='017739'
and datetime>='2019-04-01'
and datetime<'2019-04-25'
and baoxiaopz=0
order by ��Ʊ����