--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='����',SpareTC='����'
where coupno in('AS002288996','AS002289073',
'AS002289189','AS002294028','AS002336983')

select * from Topway..tbTravelBudget where TrvId='29360'
select * from Topway..tbTrvCoup where TrvId='29360'

--�ķ�Ʊ̧ͷ
select * from Topway..CompanyInvoiceInfoDetail where InvoicesTitle='�Ϻ�����ʵҵ�����ţ����޹�˾'
update Topway..CompanyInvoiceInfoDetail set InvoicesTitle='�Ϻ�����ʵҵ�����ţ����޹�˾',TaxIdentiNum='91310000679334524W',BankAccount='32443908010084455',BankName='�Ϻ�ũ����ҵ�����߱�֧��',ContactTel=' 021-33282273',TaxRegAddr='�Ϻ�������������·1899��' 
where InvoicesTitle='��������ʥ��'

select * from Topway..CompanyInvoiceInfoDetail where InvoicesTitle='�Ϻ�����ó�����޹�˾'
select * from Topway..CompanyInvoiceInfoDetail
--update Topway..CompanyInvoiceInfoDetail set InvoicesTitle='�Ϻ�����ó�����޹�˾',TaxIdentiNum='91310115607377824L',BankAccount='',BankName='',ContactTel='',TaxRegAddr='' 
where InvoicesTitle='��������ʥ��'--7779

--����Ʒר�ã����ս������Ϣ
select sprice1,totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=2
where coupno in('AS002330982','AS002334597','AS002335477','AS002341327')

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=31090,profit=3557
where coupno='AS002357648'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=2645,profit=1018
where coupno='AS002358223'


IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as ��λ���,t1.cmpname as ��λ����
,(case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' else '' end) as ��λ����
,(CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END) as ����״̬
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as ������
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as �ͻ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as ά����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as ����ҵ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as ����ҵ�����
,indate
into #cmp1
from tbCompanyM t1
left join homsomdb..Trv_UnitCompanies t4 on t1.cmpid=t4.Cmpid
--������
left join homsomDB..Trv_UnitCompies_Sales t5 on t4.ID=t5.UnitCompayID
--�ͻ�����
left join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t4.ID=t6.UnitCompanyID
--ά����
left join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.UnitCompanyID=t4.ID
--����ҵ�����
left join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t7.TrvUnitCompanyID=t4.ID
--����ҵ�����
left join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t8.TktUnitCompanyID=t4.ID
--��Ա��Ϣ
left join homsomDB..SSO_Users t9 on
t9.ID=t5.EmployeeID and t9.ID=t6.EmployeeID and t9.ID=t8.TktTCID and t9.ID=t7.TrvTCID 
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid


select c.ticketno,cm.indate,cm.��λ���,cm.������ from #cmp1 cm
left join Topway..tbcash c on cm.��λ���=c.cmpcode
where ticketno in('3541111931',
'3542740508',
'3542740507',
'5378191302',
'5378191302',
'3542738722',
'3543691117',
'3405979932',
'3570265325',
'3404419500',
'3405979932',
'3570265325',
'3570264714',
'2061820751',
'3407694445',
'3405976593',
'3407696238',
'3541109354',
'3571075671',
'3571077102',
'3571077107',
'3572376770')

--ע������ 
select indate,cmpid from Topway..tbCompanyM where cmpid in ('017505','017505','017920','017189')

--����֧����ʽ���Ը����渶��
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from homsomDB..Trv_TktBookings
--update homsomDB..Trv_TktBookings set TCPayNo=PayNo,PayNo=null,AdvanceStatus=PayStatus,PayStatus=0,TcPayWay=CustomerPayWay,CustomerPayWay=0,TcPayDate=CustomerPayDate, CustomerPayDate=null
where ID in (select b.ItktBookingID from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS002359568'))
--��Ʊ֧����Ϣ
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set TCPayNo=PayNo,PayNo=null,AdvanceStatus=PayStatus,PayStatus=0,TcPayWay=CustomerPayWay,CustomerPayWay=0,TcPayDate=CustomerPayDate,CustomerPayDate=null
where coupno in('AS002359568')

--�޸ı���ʱ��
select OperDate,* from Topway..tbTrvCoup 
--update Topway..tbTrvCoup set OperDate='2019-03-30'
where TrvId='29577'

select ModifyDate,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set ModifyDate='2019-03-30'
where TrvId='29577'

--�޸Ĺ�Ӧ����Դ
select t_source,* from Topway..tbcash  
--update Topway..tbcash  set t_source='ZSBSPETI'
where coupno='AS002337323'

--���۵�ƥ���λ
SELECT c.coupno,(SELECT TOP 1 i.cabintype 
	FROM ehomsom..tbInfCabincode i 
	WHERE	c.ride=i.code2 AND c.nclass=i.cabin 
										AND i.begdate<=c.begdate AND i.enddate>=c.begdate
	ORDER BY id DESC
	) AS cabinType
fROM Topway..tbcash  c
where c.coupno in
('AS002285373',
'AS002286001',
'AS002288988',
'AS002289455',
'AS002290418',
'AS002290503',
'AS002290565',
'AS002295121',
'AS002295137',
'AS002295921',
'AS002296004',
'AS002300678',
'AS002304883',
'AS002314273',
'AS002314332',
'AS002316778',
'AS002328750',
'AS002328832',
'AS002330040',
'AS002331183',
'AS002331187',
'AS002337714',
'AS002343291',
'AS002347575',
'AS002351469',
'AS002351476',
'AS002351482',
'AS002352456',
'AS002352456',
'AS002354256',
'AS002354262',
'AS002355933',
'AS002355937',
'AS002356067',
'AS002356524',
'AS002357258',
'AS002358853',
'AS002360940',
'AS002360942')

--�Ƶ����۵�ƥ�����Ŀ��
SELECT    CoupNo,Purpose
FROM     HotelOrderDB..HTL_Orders
where coupno in
('PTW077149',
'PTW077194',
'PTW077485',
'PTW077591',
'PTW077685',
'PTW077822',
'PTW078025',
'PTW078125',
'PTW078196',
'PTW078230',
'PTW078337',
'PTW078543',
'PTW078541',
'PTW078563',
'PTW078756',
'PTW078752',
'PTW078761',
'PTW078885')

 --�����տ��Ϣ
 select Skstatus,* from Topway..tbTrvKhSk 
 --update Topway..tbTrvKhSk  set Skstatus=2
 where TrvId='29784' and Id='227527'
 
 --�޸���Ʊ��Ϣ
 select opername, * from Topway..tbReti 
 --update Topway..tbReti  set opername='������'
 where reno in('0430499','0430497')
 
 --����۲��
 select totsprice,profit,* from Topway..tbcash 
 --update Topway..tbcash  set totsprice=21704,profit=5211
 where coupno='AS002360948'
 
 --�޸���Ʊ�������
 select ExamineDate,* from Topway..tbReti 
 --update Topway..tbReti set ExamineDate='2019-03-26'
 where reno in ('0430497','0430499')
 
 --�˵���Ϣ
 --select * from Topway..HM_CompanyAccountInfo where CmpId='020721'
 --select * from Topway..AccountStatement where CompanyCode='020721' order by BillNumber desc
 
 select SEndDate,* from Topway..HM_SetCompanySettleMentManner 
 --update Topway..HM_SetCompanySettleMentManner set SEndDate='2019-03-31',Status=-1
 where CmpId='020721' and Status=1
 
  select SStartDate,* from Topway..HM_SetCompanySettleMentManner 
 --update Topway..HM_SetCompanySettleMentManner set SStartDate='2019-04-01',Status=1
 where CmpId='020721' and Status=2
 
 SELECT EndDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
 --update homsomdb..Trv_UCSettleMentTypes set EndDate='2019-03-31',Status=-1
 WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '020721') and Status=1
 
  SELECT StartDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
 --update homsomdb..Trv_UCSettleMentTypes set StartDate='2019-04-01',Status=1
 WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '020721') and Status=2
 
 --�޸���Ʊ�������
 select ExamineDate,* from Topway..tbReti 
 --update Topway..tbReti set ExamineDate='2019-3-25'
 where reno='0430444'
 
  select ExamineDate,* from Topway..tbReti 
 --update Topway..tbReti set ExamineDate='2019-3-29'
 where reno='0430829'
 
 
 --�˵�����
 select TrainBillStatus,* from Topway..AccountStatement 
 --update Topway..AccountStatement set TrainBillStatus=1
 where BillNumber in('020261_20190301','019442_20190301')
 