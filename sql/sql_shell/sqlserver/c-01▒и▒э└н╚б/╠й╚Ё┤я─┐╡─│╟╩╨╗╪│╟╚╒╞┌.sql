/*
UC006299   ̩���Ϻ������޹�˾
 
��ͻ��ʼ�Ҫ���밴���������ȡ2018/9/1---2019/6/30���˻���������Ʊ�š���ɳ��С�Ŀ�ĵس��С���Ʊ���ڡ�������ڡ��س����ڡ��г���������Ʊʹ����� 9������
*/
select top 100 * from homsomDB..Trv_ItktBookingSegs
select top 100 * from homsomDB..Intl_BookingLegs


--����
select pasname �˻�������,tcode+ticketno Ʊ��,DepartCityName ��ɳ���,ArrivalCityName Ŀ�ĵس���,convert(varchar(10),datetime,120) ��Ʊ����,convert(varchar(20),begdate,120) �������,'--' �س�����,'--' �г�����
,case when tickettype like'%����%' then '��������' when reti<>'' then '��Ʊ' when c.route like '%��Ʊ%' then '��Ʊ'  else '����ʹ��' end ��Ʊʹ�����
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos it on it.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs i on it.ItktBookingSegID=i.ID
where cmpcode='006299'
and datetime>='2018-09-01'
and datetime<'2019-07-01'
and inf=0
order by ��Ʊ����

--����
--�г�1
if OBJECT_ID('tempdb..#xc1') is not null drop table #xc1
select pasname �˻�������,tcode+ticketno Ʊ��, CityName1 ����1,CityName2 Ŀ�ĵس���1,datetime ��Ʊ����,DepartureTime �������1
,case when c.tickettype like'%����%' then '��������' when c.route like '%����%' then '��������'  when reti<>'' then '��Ʊ' when c.route like '%��Ʊ%' then '��Ʊ'  else '����ʹ��' end ��Ʊʹ�����,
EndDate �س�����,DATEDIFF(DD,begdate,EndDate) �г�����
into #xc1
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where cmpcode='006299'
and datetime>='2018-09-01'
and datetime<'2019-07-01'
and inf=1
and b.Sort=1
and bo.Sort=1

--select * from #xc1
--�г�2
if OBJECT_ID('tempdb..#xc2') is not null drop table #xc2
select pasname �˻�������,tcode+ticketno Ʊ��, CityName1 ����2,CityName2 Ŀ�ĵس���2,datetime ��Ʊ����,DepartureTime �������2,route �г�
into #xc2
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where cmpcode='006299'
and datetime>='2018-09-01'
and datetime<'2019-07-01'
and inf=1
and b.Sort=2
and bo.Sort=1
--�г�3
if OBJECT_ID('tempdb..#xc3') is not null drop table #xc3
select pasname �˻�������,tcode+ticketno Ʊ��, CityName1 ����3,CityName2 Ŀ�ĵس���3,datetime ��Ʊ����,DepartureTime �������3
into #xc3
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where cmpcode='006299'
and datetime>='2018-09-01'
and datetime<'2019-07-01'
and inf=1
and b.Sort=3
and bo.Sort=1
--�г�4
if OBJECT_ID('tempdb..#xc4') is not null drop table #xc4
select pasname �˻�������,tcode+ticketno Ʊ��, CityName1 ����4,CityName2 Ŀ�ĵس���4,datetime ��Ʊ����,DepartureTime �������4
into #xc4
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where cmpcode='006299'
and datetime>='2018-09-01'
and datetime<'2019-07-01'
and inf=1
and b.Sort=4
and bo.Sort=1
--�г�5
if OBJECT_ID('tempdb..#xc5') is not null drop table #xc5
select pasname �˻�������,tcode+ticketno Ʊ��, CityName1 ����5,CityName2 Ŀ�ĵس���5,datetime ��Ʊ����,DepartureTime �������5
into #xc5
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where cmpcode='006299'
and datetime>='2018-09-01'
and datetime<'2019-07-01'
and inf=1
and b.Sort=5
and bo.Sort=1

select a.�˻�������,a.Ʊ��,����1 ��ɳ���,Ŀ�ĵس���1,isnull(Ŀ�ĵس���2,'--') Ŀ�ĵس���2,isnull(Ŀ�ĵس���3,'--') Ŀ�ĵس���3,isnull(Ŀ�ĵس���4,'--') Ŀ�ĵس���4,isnull(Ŀ�ĵس���5,'--') Ŀ�ĵس���5,
convert(varchar(10),a.��Ʊ����,120) ��Ʊ����,�������1,�������2,�������3,�������4,�������5,�س�����,�г�����,��Ʊʹ�����
from #xc1 a
left join #xc2 b on a.Ʊ��=b.Ʊ��
left join #xc3 c on a.Ʊ��=c.Ʊ��
left join #xc4 d on a.Ʊ��=d.Ʊ��
left join #xc5 e on a.Ʊ��=e.Ʊ��
order by ��Ʊ����