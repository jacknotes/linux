/*
���ھ��òղ��֣��밴������9-12���˵��ṩ�������ݣ�
1.��Υ����������Ʊ�ۼ���������Reason Code������ռ��
2.����Υ��ſ�������������Υ�������Υ��ռ��
3.Ա��Ԥ����Ϊ�������ͼ�δ����ռ�ȣ��˸�ǩռ�ȣ�Υ����         
4.Ա��Υ�����������ǰ10λ�������� ����  Υ�����
5.�ͼ����ѽ�֧�������·ݣ�9--12������Ʊ���ѽ���Ʊ�������ͼ����Ѵ�����Ǳ�ڿɽ�ʡ���

PS:9���˵��У���������ͼۣ���Reason Code�Ļ�Ʊֱ���޳�
*/

--1.��Υ����������Ʊ�ۼ���������Reason Code������ռ��
IF OBJECT_ID('tempdb.dbo.#lowp') IS NOT NULL DROP TABLE #lowp
select distinct SUBSTRING(ModifyBillNumber,8,6) �·�,Department,i2.OriginName ��������,i2.DestinationName �������,tcode+ticketno Ʊ��,i2.AdultPrice ���۵���,isnull(l.Price,'') ��ͼ�,isnull(l.UnChoosedReason,'') Reasoncode
into #lowp
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber 
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=p.ItktBookingID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%���ò�%'
and c.tickettype='����Ʊ'
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274')
and isnull(l.Price,'')>0
order by tcode+ticketno

--Υ����ϸ
select �·�,Ʊ��,���۵���,��ͼ�,Reasoncode from #lowp
order by �·�
--�����������
select COUNT(1) Υ�����,SUM(���۵���-��ͼ�) �����,Reasoncode from #lowp
group by Reasoncode
order by Υ����� desc

--2.����Υ��ſ�������������Υ�������Υ��ռ��
--Υ����ϸ
select �·�,Ʊ��,Department,���۵���,��ͼ�,Reasoncode,COUNT(1) ���� 
from #lowp
group by Department,���۵���,��ͼ�,Reasoncode,�·�,Ʊ��
order by �·�

--����
select Department,COUNT(1) ���� from #lowp
group by Department
order by ���� desc

--3.Ա��Ԥ����Ϊ�������ͼ�δ����ռ�ȣ��˸�ǩռ�ȣ�Υ����  
IF OBJECT_ID('tempdb.dbo.#lowp1') IS NOT NULL DROP TABLE #lowp1
select distinct SUBSTRING(ModifyBillNumber,8,6) �·�,Department,i2.OriginName ��������,i2.DestinationName �������,tcode+ticketno Ʊ��,tickettype ����,reti ��Ʊ����,i2.AdultPrice ���۵���,isnull(l.Price,'') ��ͼ�,isnull(l.UnChoosedReason,'') Reasoncode
into #lowp1
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber 
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=p.ItktBookingID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%���ò�%'
and c.tickettype='����Ʊ'
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274')
order by tcode+ticketno


select * from #lowp1
order by �·�

--select * from Topway..tbReti t1
--left join Topway..tbcash t2 on t1.reno=t2.reti and t1.ticketno=t2.ticketno


--4.Ա��Υ�����������ǰ10λ�������� ����  Υ�����
IF OBJECT_ID('tempdb.dbo.#lowp2') IS NOT NULL DROP TABLE #lowp2
select distinct SUBSTRING(ModifyBillNumber,8,6) �·�,Department,pasname,i2.OriginName ��������,i2.DestinationName �������,tcode+ticketno Ʊ��,i2.AdultPrice ���۵���,isnull(l.Price,'') ��ͼ�,isnull(l.UnChoosedReason,'') Reasoncode
into #lowp2
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber 
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=p.ItktBookingID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%���ò�%'
and c.tickettype='����Ʊ'
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274')
and isnull(l.Price,'')>0
order by tcode+ticketno

select top 10 Department,pasname,COUNT(1) ���� from #lowp2
group by Department,pasname
order by ���� desc

--5.�ͼ����ѽ�֧�������·ݣ�9--12������Ʊ���ѽ���Ʊ�������ͼ����Ѵ�����Ǳ�ڿɽ�ʡ���