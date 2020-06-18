--�˵��ĳ��������
select SalesOrderState,* from Topway..AccountStatement
--update Topway..AccountStatement set SalesOrderState=4
 where BillNumber in ('000003_20180101','000003_20180301','000003_20180401','000003_20180501')
 
select SalesOrderState,* from Topway..AccountStatement where CompanyCode='000003' and SalesOrderState=0

select * from ApproveBase..App_Content where Value like'%5381195350%'

--���۵�ƥ���λ
SELECT c.coupno,(SELECT TOP 1 i.cabintype 
	FROM ehomsom..tbInfCabincode i 
	WHERE	c.ride=i.code2 AND c.nclass=i.cabin 
										AND i.begdate<=c.begdate AND i.enddate>=c.begdate
	ORDER BY id DESC
	) AS cabinType
fROM Topway..tbcash  c
where c.coupno in
('AS002290616',
'AS002328727',
'AS002361420',
'AS002310419',
'AS002311437',
'AS002351106',
'AS002343576',
'AS002357480',
'AS002293333',
'AS002304797',
'AS002350990',
'AS002310419',
'AS002311437',
'AS002309241',
'AS002311484',
'AS002343840',
'AS002343838',
'AS002361420',
'AS002308813',
'AS002311437',
'AS002360761',
'AS002293106',
'AS002300545',
'AS002346925',
'AS002346929',
'AS002352149',
'AS002360807',
'AS002360822',
'AS002346925',
'AS002346929',
'AS002352149',
'AS002360757',
'AS002305884',
'AS002305907',
'AS002360807',
'AS002360822',
'AS002360725',
'AS002360727',
'AS002300545',
'AS002346925',
'AS002346929',
'AS002352149',
'AS002360725',
'AS002360727',
'AS002290506',
'AS002310707',
'AS002328794',
'AS002328806',
'AS002351152',
'AS002293106',
'AS002328800',
'AS002328812')


select coupno,originalprice,nclass from Topway..tbcash where coupno in
('AS002290616',
'AS002328727',
'AS002361420',
'AS002310419',
'AS002311437',
'AS002351106',
'AS002343576',
'AS002357480',
'AS002293333',
'AS002304797',
'AS002350990',
'AS002310419',
'AS002311437',
'AS002309241',
'AS002311484',
'AS002343840',
'AS002343838',
'AS002361420',
'AS002308813',
'AS002311437',
'AS002360761',
'AS002293106',
'AS002300545',
'AS002346925',
'AS002346929',
'AS002352149',
'AS002360807',
'AS002360822',
'AS002346925',
'AS002346929',
'AS002352149',
'AS002360757',
'AS002305884',
'AS002305907',
'AS002360807',
'AS002360822',
'AS002360725',
'AS002360727',
'AS002300545',
'AS002346925',
'AS002346929',
'AS002352149',
'AS002360725',
'AS002360727',
'AS002290506',
'AS002310707',
'AS002328794',
'AS002328806',
'AS002351152',
'AS002293106',
'AS002328800',
'AS002328812')

--�������ż����������Ϣ�����Σ�
select * from Topway..tbTrvCoup where TrvId='29494'

select Status,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Status=12
where TrvId='29494'

--�ֹ���Ʊ����
select indate,CONVERT(CHAR(5),indate,108),* from Topway..tbcash  c
where indate>='2019-03-01'
and indate<'2019-04-01'
and c.inf=1
and ((CONVERT(CHAR(5),indate,108)>='20:00' and CONVERT(CHAR(5),indate,108)<='23:59') or 
(CONVERT(CHAR(5),indate,108)>='00:00' and CONVERT(CHAR(5),indate,108)<='08:00')
)

select * from Topway..tbcash  c
inner join homsomDB..Trv_DomesticTicketRecord d on c.coupno = d.RecordNumber
where indate>='2019-03-01'
and indate<'2019-04-01'
and d.OperationStatus=1
and ((CONVERT(CHAR(5),indate,108)>='20:00' and CONVERT(CHAR(5),indate,108)<='23:59') or 
(CONVERT(CHAR(5),indate,108)>='00:00' and CONVERT(CHAR(5),indate,108)<='08:00')
)

select  CONVERT(CHAR(5),indate,108),* from Topway..tbcash c
--left join homsomDB..Intl_BookingOrders i on i.PNR=c.recno
where --i.BookingSource in ('2','3','4')
 indate>='2019-03-01'
and indate<'2019-04-01'
and ((CONVERT(CHAR(5),indate,108)>='20:00' and CONVERT(CHAR(5),indate,108)<='23:59') or 
(CONVERT(CHAR(5),indate,108)>='00:00' and CONVERT(CHAR(5),indate,108)<='08:00')
)
and inf=0
and oper0<>'�Զ�¼��'
and coupno<>'AS000000000'

select * from Topway..tbcash where coupno ='AS002342346'
select OperationStatus,* from homsomDB..Trv_DomesticTicketRecord where RecordNumber='AS002342346'

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=7722,profit=226
where coupno='AS002363015'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=8990,profit=552
where coupno='AS002362707'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=2300,profit=310
where coupno='AS002369060'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=5427,profit=1781
where coupno='AS002370011'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=2137,profit=117
where coupno='AS002370137'

/*
����Ҫ��ȡ���к������õ�λ�з�Ӷ����Ϊ�󷵣���λ��/���˺󷵣��Ĺ�˾�����������ֶ����£�

UC�š���λ���ơ��ͻ������ۺ����ܡ����ڻ�ƱӶ�𣨵�λ��/������󷵣�����Ӷ����������ʻ�ƱӶ�𣨵�λ��/������󷵣�����Ӷ�������
*/
--��ӶID
select * from homsomDB..Trv_Dictionaries where DictionaryType='4'

--��λ����
 select Cmpid ,un.Name,*from homsomDB..Trv_UnitCompanies un
 left join homsomDB..Trv_FlightNormalPolicies f1 on f1.UnitCompanyID=un.ID and f1.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 left join homsomDB..Trv_FlightTripartitePolicies f2 on f2.UnitCompanyID=un.ID and f2.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 left join homsomDB..Trv_FlightAdvancedPolicies f3 on f3.UnitCompanyID=un.ID and f3.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 where un.Type='A'
 
 select * from homsomDB..Trv_FlightNormalPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 select * from homsomDB..Trv_FlightTripartitePolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 select * from homsomDB..Trv_FlightAdvancedPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 
 --����
 select * from homsomDB..Trv_IntlFlightNormalPolicies where CommissionTypeID=''
 


--����δ���
select state 
--update topway..FinanceERP_ClientBankRealIncomeDetail set state=5
from topway..FinanceERP_ClientBankRealIncomeDetail where money='14902' and date='2019-04-04'


--ɾ�����������

select Payee,* 
--update topway..AccountStatementItem set Payee=''
from topway..AccountStatementItem where PKeyBill in 
(select PKey from topway..AccountStatement where CompanyCode='019848' and BillNumber='019848_20190301')
and ReceivedAmount='14902'


--����Ʒר�ã��������Դ/�����Ϣ�����ʣ�
select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash  set feiyong='',feiyonginfo=''
where coupno='AS002372162'

--����Ʒ��ר�ã���Ʊ��Ӧ����Դ�����ʣ�
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='ZSUATPI'
where coupno='AS002370212'

--�Ƶ����۵��ؿ���ӡȨ��
select prdate,pstatus,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set prdate='1900-01-01',pstatus=0
where CoupNo='PTW079568'