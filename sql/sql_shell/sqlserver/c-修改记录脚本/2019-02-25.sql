--�޸��������
select feiyonginfo,feiyong,profit,* from topway..tbcash 
--update topway..tbcash  set feiyonginfo='������λMYI',feiyong=70,profit=210
where coupno='AS002262012'

--��λ�ͻ����Ŷ�ȵ����ܶ��120��
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SX_TotalCreditLine='1200000'
where BillNumber='019956_20190201'

--�޸ĵ�λ����
--ERP��λԱ����
select cmpnamels,* from Topway..tbCusholderM 
--update Topway..tbCusholderM  set cmpnamels='÷Ү�������豸���Ϻ������޹�˾'
where cmpid='017608'

--TMS��λ
select Name,* from homsomDB..Trv_UnitCompanies where Cmpid='017608'

--����Ԥ�㵥��Ϣ
--�տ��Ϣ
select * from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set ConventionId='1242'
where ConventionId='1176'
--Ԥ�㵥����
select Status,* from topway..tbConventionBudget 
--update topway..tbConventionBudget  set Status=2
where ConventionId='1176'

--ɾ�����൥λ����
select * from Topway..tbCompanyM where id='14882'
--delete from Topway..tbCompanyM where id='14882'
select COUNT(*) from Topway..tbCompanyM where hztype in('1','2','3') and cmpid<>''
select COUNT(*) from homsomDB..Trv_UnitCompanies where CooperativeStatus in('1','2','3') and cmpid<>''


--����۲�����
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice='2859',profit='894'
where coupno='AS002266213'

--�Ƶ�渶���Ը�
select AdvanceMethod,PayMethod,AdvanceStatus,PayStatus,AdvancePayNo,PayNo,AdvanceDate,PaySubmitDate from Topway..tbHtlcoupRefund 
--update Topway..tbHtlcoupRefund  set AdvanceMethod=0,PayMethod=2,AdvanceStatus=0,PayStatus=3,PayNo='2018121922001498140520990603',AdvancePayNo=null,PaySubmitDate='2018-12-19 14:05:57.000',AdvanceDate=null
where CoupNo='PTW073438'

select cwstatus,owe,vpay,opername1,vpayinfo,oth2 from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set cwstatus=1,owe=0,vpay=149
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo='PTW073438')

select AdvanceNumber,AdvanceName,AdvanceStatus,AdvanceDate,PayStatus,PayDate from HotelOrderDB..HTL_Orders 
--update HotelOrderDB..HTL_Orders set AdvanceNumber='',AdvanceName='',PayStatus=3,AdvanceStatus=0,PayDate='2018-12-19 14:05:57.000',AdvanceDate=null
where CoupNo='PTW073438'

select AdvancePayNo,PayNo,AdvanceMethod,PayMethod,* from HotelOrderDB..HTL_OrderSettlements 
--update HotelOrderDB..HTL_OrderSettlements  set PayNo='2018121922001498140520990603',AdvancePayNo=null,PayMethod=2,AdvanceMethod=null
where OrderID in(Select OrderID from HotelOrderDB..HTL_Orders where CoupNo='PTW073438')

--�޸���Ʊ״̬
select status2,* from Topway..tbReti 
--update Topway..tbReti set status2=2
where reno='9265851'

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='���',SpareTC='���'
where coupno='AS001441296'

--�޸ĳ���֧��
select status,dzhxDate,TcPayDate,CustomerPayDate,CustomerPayWay,* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='2018-08-09',status=1,owe=0,vpay=totprice
where coupno in('AS001812250','AS001810652')

select status,dzhxDate,TcPayDate,CustomerPayDate,PayStatus,CustomerPayWay,* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='2019-02-21',status=1,TcPayDate='1900-01-01',CustomerPayWay=3,owe=0,vpay=totprice
where coupno in('AS002260528')

select status,dzhxDate,TcPayDate,CustomerPayDate,PayStatus,CustomerPayWay,* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='2019-02-21',status=1,TcPayDate='1900-01-01',CustomerPayWay=3,owe=0,vpay=totprice
where coupno in('AS002235524')

select status,dzhxDate,TcPayDate,CustomerPayDate,PayStatus,CustomerPayWay,* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='2019-02-21',status=1,TcPayDate='1900-01-01',CustomerPayWay=3,owe=0,vpay=totprice
where coupno in('AS001446167')

select status,dzhxDate,TcPayDate,CustomerPayDate,PayStatus,CustomerPayWay,* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='2018-08-14',status=1,owe=0,vpay=totprice
where coupno in('AS001821986')


--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber in('020690_2019010')

select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber in('020548_20190101')


--����֧����ʽ���Ը����渶�����ڶ���
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from homsomDB..Trv_TktBookings
--update homsomDB..Trv_TktBookings set PayNo=TCPayNo,TCPayNo=null,PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate, TcPayDate=null
where ID in (select b.ItktBookingID from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS001834923','AS001834924'))
--��Ʊ֧����Ϣ
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set PayNo=TCPayNo,TCPayNo=null,PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate,dzhxDate=TcPayDate,TcPayDate=null,status=1,owe=0,vpay=totprice
where coupno in('AS001834923','AS001834924')
--֧����Ϣ����
select payperson,* from topway..PayDetail
--update  topway..PayDetail set payperson=1 
where ysid in (select cast(b.ItktBookingID as varchar(40)) from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS001834923','AS001834924'))