--�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='Ա���渶(��ѩ÷�ַ���)'
where CoupNo='PTW075904'

-- UC019360 �����Ҳ��������Ϻ������޹�˾����
select t.coupno as ���۵���,pasname as �˻���,i1.ArrivalTime as ��������,route as �г�,i1.Name,i1.Name1,i1.Code,i1.Code1,* from Topway..tbcash t
left join Topway..tbFiveCoupInfo t1 on t1.CoupNo=t.coupno
left join homsomDB..Intl_BookingSegements i on i.BookingOrderId=t1.OrderId
left join homsomDB..Intl_BookingLegs i1 on i1.BookingSegmentId=i.Id
where datetime>='2018-02-26' and datetime<'2019-02-11' and cmpcode='019360' and inf=1
order by t.coupno

select coupno as ���۵���,pasname as �˻���,datetime as ��������,route as �г�  from Topway..tbcash t
left join homsomDB..Intl_PNRs i on i.Code=t.recno
left join homsomDB..Intl_BookingSegements i1 on i1.BookingOrderId=i.BookingOrderId
left join homsomDB..Intl_BookingLegs i2 on i2.BookingSegmentId=i1.Id
where datetime>='2018-02-26' and datetime<'2019-02-11' and cmpcode='019360' and inf=1
order by ���۵���



select DepartureDate,* from homsomDB..Intl_BookingOrders where CmpId='019360' and DepartureDate>='2018-02-26' and DepartureDate<'2019-02-11'

--���۵�ƥ���λ
SELECT c.coupno,(SELECT TOP 1 i.cabintype 
	FROM ehomsom..tbInfCabincode i 
	WHERE	c.ride=i.code2 AND c.nclass=i.cabin 
										AND i.begdate<=c.begdate AND i.enddate>=c.begdate
	ORDER BY id DESC
	) AS cabinType
fROM Topway..tbcash  c
where c.coupno in
('AS002171583',
'AS002171585',
'AS002171585',
'AS002177050',
'AS002177055',
'AS002177101',
'AS002177344',
'AS002179731',
'AS002179899',
'AS002179901',
'AS002180553',
'AS002183019',
'AS002184677',
'AS002195798',
'AS002198303',
'AS002198798',
'AS002198864',
'AS002200184',
'AS002200188',
'AS002201338',
'AS002204899',
'AS002206257',
'AS002206656',
'AS002208462',
'AS002209181',
'AS002209704',
'AS002213106',
'AS002214269',
'AS002217270',
'AS002218152',
'AS002223042',
'AS002223637',
'AS002223647',
'AS002223755',
'AS002223757',
'AS002223923',
'AS002225241',
'AS002225361',
'AS002225381',
'AS002225509',
'AS002226297',
'AS002226300',
'AS002226401',
'AS002226462',
'AS002226463',
'AS002227902',
'AS002233979',
'AS002234008',
'AS002234552',
'AS002234572',
'AS002234705',
'AS002235565',
'AS002235569',
'AS002236812')

--�г̵�
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='���ӡ�����г̵�'
where coupno='AS001954275'

--�޸�UC��
select custid AS �ֻ�Ա���,* from topway..tbCusholderM where cmpid ='016888'
select custid,OriginalBillNumber,ModifyBillNumber,* from Topway..tbcash where cmpcode='016888' 
select SettleMentManner AS �ֽ��㷽ʽ,* from topway..HM_SetCompanySettleMentManner where CmpId='016888' and Type=0 and Status=1
select OriginalBillNumber AS ���˵���,ModifyBillNumber AS ���˵���,cmpcode,custid,datetime,* from topway..tbcash where coupno in ('AS002193902','AS002193937')
select HSLastPaymentDate,* from topway..AccountStatement where CompanyCode='016888' order by BillNumber desc
--�޸�UC�ţ�ERP��
select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,* from Topway..tbcash
--update topway..tbcash set cmpcode='016888',OriginalBillNumber='016888_20181226',ModifyBillNumber='016888_20181226',custid='D179052'
 where coupno in ('AS002193902','AS002193937')

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where BillNumber='017735_20181226'

select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where BillNumber='018734_20190101'


 --2018�����⻻�����ʻ�Ʊ
 
select coupno as ���۵���,tcode+ticketno as Ʊ��,route as �г�,sales as ���ù���,profit as �������� from Topway..tbcash 
where  datetime>='2018-01-01' and datetime<'2019-01-01' and inf='1' and HKType='1'

--OA�Ƶ�����Ʒ��
select Signer,* from ApproveBase..HR_AskForLeave_Signer 
--update ApproveBase..HR_AskForLeave_Signer set Signer='0601'
where DeptCode='�Ƶ�����Ʒ��'

--�ؿ���ӡȨ��

select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus='0',PrDate='1900-01-01'
where TrvId='029513'

--�г̵�
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno='AS002201777'

--��Ʊ����
select t1.tcode+t1.ticketno as Ʊ��,t.coupno as ���۵���,t1.t_source as ��Ӧ����Դ,t.reno as ��Ʊ����,t.edatetime as �ύ����,ExamineDate as �������,scount2 as ���չ�˾��Ʊ��,
rtprice as ��ȡ�ͻ���Ʊ���,t1.SpareTC as ��Ʊ����ҵ�����,t1.sales as ��Ʊҵ�����,t.opername as �ύ��Ʊҵ�����,t.info as ��ע
 from Topway..tbReti t
left join Topway..tbcash t1 on t1.coupno=t.coupno and t1.reti=t.reno
where ExamineDate>='2019-01-07' and ExamineDate<'2019-02-11' and t.info like'%ð��Ʊ%'
order by ExamineDate

--��Ʊ���۵���Ϊδ��
select bpay as ֧�����,status as �տ�״̬,opernum as ��������,oper2 as ������,oth2 as ��ע,totprice as ���ۼ�,dzhxDate as ����ʱ��,owe as Ƿ����,*
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=800,dzhxDate='1900-1-1'
from Topway..tbcash where coupno='AS002201236' and ticketno='3541111829'

--�Ƶ�Ԥ�����м���ǰʮ
--Ԥ��
select top 10 city as ����,COUNT(*) as Ԥ������ from Topway..tbHtlcoupYf 
where datetime>='2018-01-01' and datetime<'2019-01-01'
and status<>'-2'
group by city
order by Ԥ������ desc

--�Ը�
select top 10 city as ����,COUNT(*) as Ԥ������ from Topway..tbHotelcoup
where datetime>='2018-01-01' and datetime<'2019-01-01'
and status<>'-2'
group by city
order by Ԥ������ desc

--�˵�����
select HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement set HotelSubmitStatus='2'
where BillNumber='017506_20190101'

--�޸Ĺ�Ӧ����Դ
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002239218'
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno='AS002237544'