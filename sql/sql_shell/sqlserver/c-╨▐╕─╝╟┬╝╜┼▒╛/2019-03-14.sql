select cmpcode,* from Topway..tbcash where coupno='AS002314083'

--��Ʊҵ�������Ϣ
SELECT sales,SpareTC,* froM Topway..tbcash 
--UPDATE Topway..tbcash  SET sales='��־ǿ',SpareTC='��־ǿ'
WHERE coupno='AS002133875'

--�������Ϣ
select sprice1,route,pform,* FROM Topway..tbcash 
--update Topway..tbcash set route='PVG-HKG ��Ʊ��'
WHERE coupno='AS002314083'

--������Ϣ
select sprice1,route,pform,* FROM Topway..tbcash 
--update Topway..tbcash set route='PVG-HKG'
WHERE coupno='AS002314083' AND ticketno='3554297088'

--�޸Ĺ�Ӧ��
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='�渶ʩ����I'
where coupno='AS002311711'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='ZSBSPETI'
where coupno='AS002302422'

--��λ�ͻ����Ŷ�ȵ���
select SX_BaseCreditLine ,SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement set SX_TotalCreditLine=90000
where BillNumber='018113_20190301'

--�޸�UC�ţ���Ʊ��
select custid AS �ֻ�Ա���,* from topway..tbCusholderM where cmpid ='019539' and custname='����÷'
select custid,OriginalBillNumber,ModifyBillNumber,* from Topway..tbcash where cmpcode='019539'
select SettleMentManner AS �ֽ��㷽ʽ,* from topway..HM_SetCompanySettleMentManner where CmpId='019539' and Type=0 and Status=1
select OriginalBillNumber AS ���˵���,ModifyBillNumber AS ���˵���,cmpcode,custid,datetime,* from topway..tbcash where coupno in ('AS002315886 ','AS002315886 ')
select HSLastPaymentDate,* from topway..AccountStatement where CompanyCode='019539' order by BillNumber desc
select Cmpname,* from Topway..tbFiveCoupInfo where CmpId='019539'and Ndate>'2019-03-01'
--�޸�UC�ţ�ERP��
select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,pform,xfprice,* from Topway..tbcash
--update topway..tbcash set cmpcode='019539',OriginalBillNumber='019539_20190301',custid='D514200',pform='�½�(�㺭)'
 where coupno in ('AS002315886')
 
 select CustId,CmpId,Cmpname,* from Topway..tbFiveCoupInfo 
  --update Topway..tbFiveCoupInfo set CustId='D514200',CmpId='019539',Cmpname='�Ϻ��������������������޹�˾'
  where CoupNo iN('AS002315886')
  
 /*�޸�UC�ţ�TMS)
 SELECT T2.CoupNo,T1.OrderNo,*
  FROM homsomDB..Intl_BookingOrders T1
  INNER JOIN Topway..tbFiveCoupInfo T2 ON T1.Id=T2.OrderId
  where Id in(select OrderId from Topway..tbFiveCoupInfo where CoupNo in ('AS002315886'))*/
  
   --�޸�UC�ţ�TMS)
  select CmpId,CompanyName,CustId,* from homsomDB..Intl_BookingOrders 
  --update homsomDB..Intl_BookingOrders set CmpId='020705',CustId='D632141',CompanyName='�Ϻ��������������������޹�˾'
  where OrderNo in ('IF00027480')
  
  select CmpId,CompanyName,CustId,* from homsomDB..Intl_BookingOrders 
  --update homsomDB..Intl_BookingOrders set CmpId='016888',CustId='D172032',CompanyName='�Ϻ��������������������޹�˾'
  where OrderNo='IF00027480'
  
  select CompanyName,* from homsomDB..Intl_BookingPassengers 
  --update homsomDB..Intl_BookingPassengers  set CompanyName='�Ϻ��������������������޹�˾'
  where BookingOrderId in(Select id from homsomdb..Intl_BookingOrders where OrderNo in ('IF00027480'))
  
  
  --�����տ
  select Price,* from Topway..tbConventionKhSk 
  --update Topway..tbConventionKhSk set Price='34344.34'
  where ConventionId='1390'
  
  --�޸Ľ���۲��
  select totsprice,profit,* from Topway..tbcash 
  --update Topway..tbcash  set totsprice=6928,profit=2802
  where coupno='AS002310356'
  
  --2019��2��11����2019��2��26�� ��ע����ð��Ʊ��
  --Ʊ�š����۵��š���Ӧ����Դ����Ʊ���š��ύ���ڡ�������ڡ����չ�˾��Ʊ�ѡ��տͻ���Ʊ����Ʊ����ҵ����ʡ���Ʊҵ����ʡ��ύ��Ʊҵ����ʡ���ע
 select  tcode+t.ticketno Ʊ��,t.coupno ���۵���,t_source  ��Ӧ����Դ,reno ��Ʊ����,edatetime �ύ����,ExamineDate �������,
 scount2 ���չ�˾��Ʊ��,rtprice �տͻ���Ʊ���,c.SpareTC ��Ʊ����ҵ�����,c.sales ��Ʊҵ�����,opername �ύ��Ʊҵ�����,t.info ��ע
 from Topway..tbReti t
 left join Topway..tbcash c on t.reno=c.reti
 where t.info like'%ð��Ʊ%'
 and ExamineDate>='2019-02-11'
 and ExamineDate<'2019-02-27'
 
 
 --�ؿ���ӡȨ��
 select Pstatus,PrDate,* from Topway..tbConventionKhSk 
 --update Topway..tbConventionKhSk  set Pstatus=0,PrDate='1900-01-01'
 where ConventionId='1390' and Id='2589'
 
 select pstatus,prdate,* from Topway..tbSettlementApp 
 --update Topway..tbSettlementApp set pstatus=0,prdate='1900-01-01'
 where id='109726'
 
--��Ʊ���۵�����
select * 
--delete
 from Topway..tbTrainTicketInfo where CoupNo in ('RS000020607','RS000020608','RS000020609')
select * 
--delete
from Topway..tbTrainUser where TrainTicketNo in (select ID from Topway..tbTrainTicketInfo where CoupNo in ('RS000020607','RS000020608','RS000020609'))

--��ӡȨ��
select Pstatus,PrDate,dzHxDate,* from Topway..tbTrvKhSk where Id='227155'