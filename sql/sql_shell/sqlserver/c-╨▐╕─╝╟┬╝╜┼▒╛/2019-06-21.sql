--���뼼������
select Status,ModifyDate,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Status='14'
where TrvId='30249'

--��Ʊ���۵�ƥ������
select CreateDate ��Ʊ����,OutBegdate ��������,CoupNo ���۵���,Customer Ԥ����,Name �˿�����,Department ����,OutTrainNo ����,OutGrade ��λ�ȼ�,
OutStroke �г�,RealPrice ��Ʊ����,TotFuprice �����,TotPrice ���ۼ�,isnull(ReturnTicketID,'') ��Ʊ����,TrainTicketNo ����������
,Remark ��ע
from Topway..tbTrainTicketInfo t1
left join Topway..tbTrainUser t2 on t2.TrainTicketNo=t1.ID
where CoupNo in ('RS000024333',
'RS000024334',
'RS000024335',
'RS000024336',
'RS000024339',
'RS000024340',
'RS000024341',
'RS000024342',
'RS000024343',
'RS000024344',
'RS000024345',
'RS000024349',
'RS000024350',
'RS000024358',
'RS000024370',
'RS000024371',
'RS000024372',
'RS000024373')

--�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='Я�̹�����������'
where CoupNo='PTW085005'

/*
    UC019361   �Ϻ��㸶���ݷ������޹�˾
    ��ù�˾Y���������߽��б��������Э����ȡ2019.5.1--2019.6.20 ������MU/FM  Y������
    */
select coupno ���۵���,datetime ��Ʊʱ��,begdate �������,route �г�,tcode+ticketno Ʊ��,totprice ���ۼ�,reti ��Ʊ����,tickettype ����
from Topway..tbcash 
where cmpcode='019361'
and datetime>='2019-05-01'
and datetime<'2019-06-21'
and ride in('MU','FM')
and nclass='Y'
order by ��Ʊʱ��

/*
UC018362 ����˹��������ϵͳ���Ϻ������޹�˾
2018��ȫ��
�ֶ�Ҫ����Ա��Ϣ ���� ������ Ŀ�ĵ� ��λ�ȼ� ���ۼ۸�
*/
SELECT coupno ���۵���,pasname �˻���,convert(varchar(10),datetime,120) ��Ʊ����,begdate �������,route �г�,nclass ��λ�ȼ�,totprice ���ۼ� ,reti ��Ʊ����
from Topway..tbcash 
where cmpcode='018362'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf!=-1
order by ��Ʊ����


--����Ԥ�㵥��Ϣ
--select * from Topway..tbCusholderM where cmpid='020874'

select Custid,Custinfo,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Custid='D699525',Custinfo='13601621042@½��@020874@�Ϻ���ʿ����Ϣ�����ɷ����޹�˾@����@13601621042@D699525'
where TrvId='30260'

--�˵�����
select TrainBillStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set TrainBillStatus=1
where BillNumber='020644_20190501'

--����֧����ʽ���Ը����渶��
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from homsomDB..Trv_TktBookings
--update homsomDB..Trv_TktBookings set PayNo=TCPayNo,TCPayNo=null,PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate, TcPayDate=null
where ID in (select b.ItktBookingID from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS002494171'))
--��Ʊ֧����Ϣ
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set PayNo=TCPayNo,TCPayNo=null,PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate,dzhxDate=TcPayDate,TcPayDate=null,status=1,owe=0,vpay=totprice
where coupno in('AS002494171')
--֧����Ϣ����
select payperson,* from topway..PayDetail
--update  topway..PayDetail set payperson=1 
where ysid in (select cast(b.ItktBookingID as varchar(40)) from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS002494171'))

select * from homsomDB..Trv_DomesticTicketRecord where RecordNumber='AS002435233'
select * from homsomDB..Trv_PnrInfos where ID='913436AC-8CBD-4F04-91F9-2969776749BD'
select * from homsomDB..Trv_ItktBookingSegments_PnrInfos where PnrInfoID='913436AC-8CBD-4F04-91F9-2969776749BD'
select * from homsomDB..Trv_ItktBookingSegs where ID='4A6E7BD5-EF5C-4D22-9B7A-6889B1C8E0F4'

--��ͼ�   ���ѵ���ͼۺ������ʱ��
SELECT c.coupno,isnull(lp.Price,'') ��ͼ�,isnull(lp.DepartureTime,'') �������,isnull(lp.ArrivalTime,'') ��������,isnull(lp.Flight,'') �����
 FROM topway..tbcash c 
LEFT JOIN homsomDB..Trv_DomesticTicketRecord r ON c.coupno=r.RecordNumber
LEFT JOIN homsomDB..Trv_ItktBookingSegments_PnrInfos p on p.PnrInfoID=r.PnrInfoID
left join homsomDB..Trv_LowerstPrices lp on p.ItktBookingSegID=lp.ItktBookingSegID
where c.coupno in ('AS002362610',
'AS002366465',
'AS002368897',
'AS002369159',
'AS002371599',
'AS002372134',
'AS002372319',
'AS002376291',
'AS002376464',
'AS002376992',
'AS002377048',
'AS002377453',
'AS002377558',
'AS002377643',
'AS002379209',
'AS002379238',
'AS002379418',
'AS002380674',
'AS002381285',
'AS002382369',
'AS002382524',
'AS002383226',
'AS002384562',
'AS002385711',
'AS002385715',
'AS002388708',
'AS002389157',
'AS002389276',
'AS002389404',
'AS002391489',
'AS002391731',
'AS002392059',
'AS002392667',
'AS002392669',
'AS002394544',
'AS002395099',
'AS002395181',
'AS002395923',
'AS002396794',
'AS002396804',
'AS002397317',
'AS002400946',
'AS002401427',
'AS002401556',
'AS002402132',
'AS002403776',
'AS002405139',
'AS002405180',
'AS002408149',
'AS002408492',
'AS002412421',
'AS002414283',
'AS002414293',
'AS002415772',
'AS002417805',
'AS002420210',
'AS002421335',
'AS002422423',
'AS002422431',
'AS002423441',
'AS002423448',
'AS002424299',
'AS002425903',
'AS002427408',
'AS002427618',
'AS002427701',
'AS002428195',
'AS002431521',
'AS002431709',
'AS002431877',
'AS002432772',
'AS002432774',
'AS002433531',
'AS002433837',
'AS002435225',
'AS002435233',
'AS002435831',
'AS002436632',
'AS002438767',
'AS002439413',
'AS002439732')
and isnull(lp.Price,'')<>0
order by c.coupno


--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020237_20190501'

--UC020895 ����Ϊ�Ϻ������ʩ����������޹�˾
select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement  set CompanyNameCN='�Ϻ������ʩ����������޹�˾'
where BillNumber='020895_20190601'

--�������ż����������Ϣ�����Σ�
select Status,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Status=14
where TrvId='30286'

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002570490','AS002568448')

--select amount,totprice,totsprice,tax,profit,* from Topway..tbcash where coupno='AS002561842'
select t_amount,totprice,totsprice,tottax,totprofit,* from Topway..tbFiveCoupInfo 
--update Topway..tbFiveCoupInfo  set t_amount=300,totprice=300,totsprice=140,tottax=0,totprofit=300
where CoupNo='AS002561842'