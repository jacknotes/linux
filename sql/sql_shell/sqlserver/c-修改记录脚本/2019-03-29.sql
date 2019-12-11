--行程单、特殊票价
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='需打印行程单'
where coupno='AS002328196'

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='携程官网分销联盟'
where CoupNo='PTW078813'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=6167,profit=736
where coupno='AS002356301'

--1月份，国内，销售单类型：改期费
select SUM(totprice) 销量,COUNT(*) 张数 from Topway..tbcash 
where datetime>='2019-01-01'
and datetime<'2019-02-01'
and inf=0
and tickettype like'%改期%'
--and tickettype<>'电子票'

--退票数据2019年3月1日至2019年3月28日 HS应付金额为“0”
select tcode+t.ticketno 票号,t.coupno 销售单号,t_source 供应商来源,reno 退票单号,edatetime 提交时间,ExamineDate 产品审核时间,t.sprice 原结算价,scount2 航空公司退票费,
t.price 实际销售价,rtprice 收客户退票费金额,c.SpareTC 出票操作业务顾问,c.sales 出票业务顾问问,t.cmpcode UC号,t.totprice HS应付金额,stotprice HS应收金额
from Topway..tbReti t
left join Topway..tbcash  c on t.ticketno=c.ticketno and t.coupno=c.coupno
where t.datetime>='2019-03-01'
and t.datetime<'2019-03-29'
and t.totprice=0
order by edatetime

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='016588_20190226'

--会务预算单信息
select Sales,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Sales='张广寒'
where ConventionId='740'

--UC020459康宝莱（上海）管理有限公司 20190301的所有销售单中的差旅顾问改成张超
select  sales,* from Topway..tbcash  
--update Topway..tbcash set sales='张超'
where OriginalBillNumber='020459_20190301'

--修改单位业务顾问
select TcName,* from Topway..HM_AgreementCompanyTC 
--update Topway..HM_AgreementCompanyTC set TcName='张超'
where Cmpid='020459' and isDisplay=0

select * from homsomDB..Trv_UnitPersons u
left join homsomDB..Trv_Human h on h.ID=u.ID
where u.CompanyID=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='019539')
and h.Name='沈伟峰'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='016588_20190226'

--额度调整
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SX_TotalCreditLine=80000
where BillNumber='020370_20190301'

--酒店销售单信息
select * from Topway..tbHtlcoupYf where CoupNo='159862'

--重开打印
select Pstatus,PrintDate,* from Topway..HM_tbReti_tbReFundPayMent 
--update Topway..HM_tbReti_tbReFundPayMent  set Pstatus=0,PrintDate='1900-01-01'
where Id='703712'

--增加酒店入住人
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
           '朱赛芳',
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
           '普通常旅客',
           '0',
           '0',
           '0',
           '0',
           '0',
           '0',
           NULL)
           
           
      select * from HotelOrderDB..HTL_OrderPersons where OrderID='2F772099-ED07-40FE-AF17-6871EA9CDA67'
     
     
   --旅游收款单信息
   select Skstatus,* from Topway..tbTrvKhSk 
   --update Topway..tbTrvKhSk  set Skstatus=2
   where TrvId='029669' and Id in ('227212','227153')
   
   --旅游预算单信息
   --select * from Topway..tbCusholderM where custid='D586408'
   
   select Custid,Custinfo,PasName,* from Topway..tbTravelBudget 
   --update Topway..tbTravelBudget  set Custid='D644024',Custinfo='15801947720@王留香@UC020392@乐斯福管理（上海）有限公司@王留香@15801947720@D644024'
   where TrvId='29360'
   
   select * from Topway..tbTrvCoup 
   --update Topway..tbTrvCoup set Custid='D644024',
   where TrvId='29360'
   --select * from Topway..tbTrvJS where TrvId='29360'
   --select * from Topway..tbTrvKhSk where TrvId='29360'
   --select * from  topway..tbTrvSettleApp where Id=''