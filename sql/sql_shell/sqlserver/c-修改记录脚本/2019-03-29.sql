--�г̵�������Ʊ��
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='���ӡ�г̵�'
where coupno='AS002328196'

--�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='Я�̹�����������'
where CoupNo='PTW078813'

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=6167,profit=736
where coupno='AS002356301'

--1�·ݣ����ڣ����۵����ͣ����ڷ�
select SUM(totprice) ����,COUNT(*) ���� from Topway..tbcash 
where datetime>='2019-01-01'
and datetime<'2019-02-01'
and inf=0
and tickettype like'%����%'
--and tickettype<>'����Ʊ'

--��Ʊ����2019��3��1����2019��3��28�� HSӦ�����Ϊ��0��
select tcode+t.ticketno Ʊ��,t.coupno ���۵���,t_source ��Ӧ����Դ,reno ��Ʊ����,edatetime �ύʱ��,ExamineDate ��Ʒ���ʱ��,t.sprice ԭ�����,scount2 ���չ�˾��Ʊ��,
t.price ʵ�����ۼ�,rtprice �տͻ���Ʊ�ѽ��,c.SpareTC ��Ʊ����ҵ�����,c.sales ��Ʊҵ�������,t.cmpcode UC��,t.totprice HSӦ�����,stotprice HSӦ�ս��
from Topway..tbReti t
left join Topway..tbcash  c on t.ticketno=c.ticketno and t.coupno=c.coupno
where t.datetime>='2019-03-01'
and t.datetime<'2019-03-29'
and t.totprice=0
order by edatetime

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='016588_20190226'

--����Ԥ�㵥��Ϣ
select Sales,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Sales='�Ź㺮'
where ConventionId='740'

--UC020459���������Ϻ����������޹�˾ 20190301���������۵��еĲ��ù��ʸĳ��ų�
select  sales,* from Topway..tbcash  
--update Topway..tbcash set sales='�ų�'
where OriginalBillNumber='020459_20190301'

--�޸ĵ�λҵ�����
select TcName,* from Topway..HM_AgreementCompanyTC 
--update Topway..HM_AgreementCompanyTC set TcName='�ų�'
where Cmpid='020459' and isDisplay=0

select * from homsomDB..Trv_UnitPersons u
left join homsomDB..Trv_Human h on h.ID=u.ID
where u.CompanyID=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='019539')
and h.Name='��ΰ��'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='016588_20190226'

--��ȵ���
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SX_TotalCreditLine=80000
where BillNumber='020370_20190301'

--�Ƶ����۵���Ϣ
select * from Topway..tbHtlcoupYf where CoupNo='159862'

--�ؿ���ӡ
select Pstatus,PrintDate,* from Topway..HM_tbReti_tbReFundPayMent 
--update Topway..HM_tbReti_tbReFundPayMent  set Pstatus=0,PrintDate='1900-01-01'
where Id='703712'

--���ӾƵ���ס��
INSERT INTO [HotelOrderDB].[dbo].[HTL_OrderPersons]
           ([OrderPersonID]
           ,[OrderID]
           ,[UpID]
           ,[Name]
           ,[Sex]
           ,[Telephone]
           ,[Email]
           ,[DepartmentID]
           ,[DepartmentName]
           ,[PositionID]
           ,[PositionName]
           ,[CostCenterID]
           ,[CostCenterName]
           ,[ProjectNo]
           ,[ProjectName]
           ,[Nationality]
           ,[Number]
           ,[EmpType]
           ,[CreateDate]
           ,[ModifyDate]
           ,[VettingTemplateHotel]
           ,[PersonType]
           ,[GuestToRoomNo]
           ,[GuestType]
           ,[ConfirmSMS]
           ,[ConfirmEmail]
           ,[ConfirmWechat]
           ,[IsMyMobilePhone]
           ,[IdentityTag])
     VALUES
           (NEWID(),
           '17CC08F4-AB68-4DD5-91B9-F230CA163A8D',
           '00000000-0000-0000-0000-000000268656',
           '������',
           1,
           '--',
           '--',
           '00000000-0000-0000-0000-000000000000',
           '--',
           '00000000-0000-0000-0000-000000000000',
           '',
           '00000000-0000-0000-0000-000000000000',
           '',
           '00000000-0000-0000-0000-000000000000',
           '',
           '--',
           '--',
           'nup',
           '2019-03-29 14:00:41.920',
           '2019-03-29 14:00:41.920',
           '0',
           '��ͨ���ÿ�',
           '0',
           '0',
           '0',
           '0',
           '0',
           '0',
           NULL)
           
           
      select * from HotelOrderDB..HTL_OrderPersons where OrderID='2F772099-ED07-40FE-AF17-6871EA9CDA67'
     
     
   --�����տ��Ϣ
   select Skstatus,* from Topway..tbTrvKhSk 
   --update Topway..tbTrvKhSk  set Skstatus=2
   where TrvId='029669' and Id in ('227212','227153')
   
   --����Ԥ�㵥��Ϣ
   --select * from Topway..tbCusholderM where custid='D586408'
   
   select Custid,Custinfo,PasName,* from Topway..tbTravelBudget 
   --update Topway..tbTravelBudget  set Custid='D644024',Custinfo='15801947720@������@UC020392@��˹�������Ϻ������޹�˾@������@15801947720@D644024'
   where TrvId='29360'
   
   select * from Topway..tbTrvCoup 
   --update Topway..tbTrvCoup set Custid='D644024',
   where TrvId='29360'
   --select * from Topway..tbTrvJS where TrvId='29360'
   --select * from Topway..tbTrvKhSk where TrvId='29360'
   --select * from  topway..tbTrvSettleApp where Id=''