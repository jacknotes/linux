--ǰʮԤ�����Ƶ�
select top 20 hotel as �Ƶ�����,SUM(pcs) as ��ҹ��,city as ������ from Topway..tbHtlcoupYf t
inner join HotelOrderDB..HTL_Orders od on od.CoupNo=t.CoupNo
where prdate>='2018-01-01' and prdate<'2019-01-01'
group by hotel,city
order by ��ҹ�� desc

select top 20 hotel as �Ƶ�����,SUM(pcs) as ��ҹ��,city as ������ from Topway..tbHotelcoup t
inner join HotelOrderDB..HTL_Orders od on od.CoupNo=t.CoupNo
where datetime>='2018-01-01' and datetime<'2019-01-01'
group by hotel,city
order by ��ҹ�� desc

--��Ʊ�˵�����
SELECT SubmitState,* FROM Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
WHERE BillNumber='019641_20190101'

--�������ż����������Ϣ�����Σ�
select * from topway..tbTrvCoup where TrvId='29527'
select Status,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Status='12'
where TrvId='29527'

--�޸Ĺ�Ӧ����Դ
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='ZSBSPETI'
where coupno='AS002239377'

--����UC018463�ֿϵ��������Ϻ������޹�˾ ���ÿ͹��ڻ�Ʊ�����ˣ����źͳɱ�����

update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a
left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID 
where UnitCompanyID='BC9BA4E0-D5B2-4822-B0BB-A98800FDEFA0'
and TemplateName='����һ��ɸѡģ��-ɸѡ-����' and Inf=0)
where ID=(
select up.ID from homsomDB..Trv_UnitPersons up
inner join homsomDB..Trv_Human hu on up.ID=hu.ID 
where up.UserName='' and Mobile='13918811321' and IsDisplay=1  and hu.companyid='BC9BA4E0-D5B2-4822-B0BB-A98800FDEFA0')

select up.UserName,C.Name as �ɱ�����,co.DepName as �������� from homsomDB..Trv_UnitPersons up
inner join homsomDB..Trv_Human hu on up.ID=hu.ID 
left join  homsomDB..Trv_CostCenter c on c.ID=up.CostCenterID
left join homsomDB..Trv_CompanyStructure co on co.ID=up.CompanyDptId
where up.CompanyID='C5BFAE84-A02E-4000-8E1C-A2A700DC9DBA' and IsDisplay=1 and 
UserName in(
'SHG00012',
'SHG00011',
'SHG00010',
'SHG00009',
'SHG00008',
'SHG00007',
'SHG00006',
'SHG00005',
'SHG00004',
'SHG00003',
'SHG00002',
'SHG00001',
'SH002920',
'SH002916',
'SH002907',
'SH002902',
'SH002901',
'SH002890',
'SH002889',
'SH002886',
'SH002885',
'SH002884',
'SH002883',
'SH002880',
'SH002876',
'SH002862',
'SH002859',
'SH002857',
'SH002844',
'SH002832',
'SH002829',
'SH002812',
'SH002802',
'SH002789',
'SH002784',
'SH002775',
'SH002774',
'SH002760',
'SH002725',
'SH002646',
'SH002586',
'SH002573',
'SH002526',
'SH002524',
'SH002521',
'SH002520',
'SH002503',
'SH002482',
'SH002480',
'SH002479',
'SH002414',
'SH002413',
'SH002353',
'SH001918',
'SH001884',
'SH001458',
'SH001186',
'SH001140',
'SH000429',
'SH000276',
'SH000001',
'HSO00026',
'HSO00022',
'HSO00020',
'HSO00016',
'HSO00014',
'HSO00012',
'HSO00008')

select UserName,hu.Name as ����,Mobile as �ֻ�����,C.Name as �ɱ�����,co.DepName as �������� from homsomDB..Trv_UnitPersons up
inner join homsomDB..Trv_Human hu on up.ID=hu.ID 
left join  homsomDB..Trv_CostCenter c on c.ID=up.CostCenterID
left join homsomDB..Trv_CompanyStructure co on co.ID=up.CompanyDptId
where up.CompanyID='C5BFAE84-A02E-4000-8E1C-A2A700DC9DBA' and IsDisplay=1 and UserName='sh002413'

--�ɱ�����

update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter 
where Name='73206' and CompanyID='C5BFAE84-A02E-4000-8E1C-A2A700DC9DBA') 
where ID=(Select up.ID from homsomDB..Trv_UnitPersons up
inner join homsomDB..Trv_Human hu on hu.ID=up.ID
where up.CompanyID='C5BFAE84-A02E-4000-8E1C-A2A700DC9DBA' and IsDisplay=1 and UserName='SH001140')

Select Name,COUNT(Name) as �ظ��� from homsomDB..Trv_CostCenter 
where  CompanyID='C5BFAE84-A02E-4000-8E1C-A2A700DC9DBA'
group by Name
order by �ظ��� desc

select * from homsomDB..Trv_CostCenter where Name='73502'
--��������
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure 
where DepName='Machine & Automation sales team' and CompanyID='C5BFAE84-A02E-4000-8E1C-A2A700DC9DBA') 
where ID=(Select up.ID from homsomDB..Trv_UnitPersons up
inner join homsomDB..Trv_Human hu on hu.ID=up.ID
where up.CompanyID='C5BFAE84-A02E-4000-8E1C-A2A700DC9DBA' and IsDisplay=1 and UserName='��¼��')

Select DepName,COUNT(DepName) as ���ID from homsomDB..Trv_CompanyStructure 
where CompanyID='C5BFAE84-A02E-4000-8E1C-A2A700DC9DBA'
group by DepName
order by ���ID desc

--���ڻ�Ʊ����
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a
left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID 
where UnitCompanyID='C5BFAE84-A02E-4000-8E1C-A2A700DC9DBA'
and TemplateName='������' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up
inner join homsomDB..Trv_Human hu on up.ID=hu.ID 
where up.UserName='��¼��' and IsDisplay=1  and up.companyid='C5BFAE84-A02E-4000-8E1C-A2A700DC9DBA')



--�����޸ĺ���״̬
SELECT SalesOrderState,* FROM topway..AccountStatement 
--update topway..AccountStatement  set SalesOrderState='0'
WHERE BillNumber='020477_20190101'

--����Ԥ�㵥��Ϣ
select enddate,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set enddate='2019-03-03'
where TrvId='29401'

--��Ʊ���۵�����
delete from Topway..tbTrainTicketInfo where CoupNo='RS000019447'
delete from Topway..tbTrainTicketInfo where CoupNo='RS000019448'
delete from Topway..tbTrainUser where TrainTicketNo=(Select ID from Topway..tbTrainTicketInfo where CoupNo='RS000019447')
delete from Topway..tbTrainUser where TrainTicketNo=(Select ID from Topway..tbTrainTicketInfo where CoupNo='RS000019448')

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState='1'
where BillNumber='020183_20190101'

--����֧����ʽ
--���ڶ���֧����Ϣ
select PayNo,TCPayNo,PayStatus,AdvanceStatus,AdvanceStatus,CustomerPayWay,TcPayWay,TcPayWay,* from homsomDB..Trv_TktBookings
--update homsomDB..Trv_TktBookings set PayNo=TCPayNo,TCPayNo='',PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate, TcPayDate=''
where ID in (select b.ItktBookingID from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS002216908','AS002216887'))
--��Ʊ֧����Ϣ
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,TcPayDate,* from Topway..tbcash
--update Topway..tbcash set PayNo=TCPayNo,TCPayNo='',PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=0,CustomerPayDate=TcPayDate, TcPayDate=''
where coupno in('AS002216908','AS002216887')
--֧����Ϣ����
select payperson,* from Topway..PayDetail
--update  topway..PayDetail set payperson=1 
where ysid in (select cast(b.ItktBookingID as varchar(40)) from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS002216908','AS002216887'))

--�Ը��ĳɵ渶
select CustomerPayDate,TcPayDate,CustomerPayWay,TcPayWay,PayNo,TCPayNo,* 
--update Topway..tbcash set TcPayDate=CustomerPayDate,CustomerPayDate=NULL,TcPayWay=3,CustomerPayWay=0,TCPayNo=PayNo,PayNo=NULL
from Topway..tbcash where coupno in('AS002216908','AS002216887')

select PayNo,TCPayNo,CustomerPayDate,TcPayDate,CustomerPayWay,TcPayWay,ID,* from homsomDB..Trv_TktBookings
--update homsomDB..Trv_TktBookings set TCPayNo=PayNo,PayNo=NULL,TcPayDate=CustomerPayDate,CustomerPayDate=NULL,TcPayWay=CustomerPayWay,CustomerPayWay=0
where ID in (select b.ItktBookingID from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS002216908','AS002216887'))

select payperson,* from Topway..PayDetail 
--update Topway..PayDetail  set payperson=?
where ysid in('5580E5C8-E80C-434D-AF03-30816E6DEDD9')
select payperson,* from Topway..PayDetail 
--update Topway..PayDetail  set payperson=?
where ysid in('1A77F810-B6B0-47C5-B60C-D15380D609C4')


--�˵�����
select HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement set HotelSubmitStatus='2'
where BillNumber='020350_20190101'

select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where BillNumber='020165_20190101'

--�ĵ���ʱ��
select date,* 
--update topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-02-14'
from topway..FinanceERP_ClientBankRealIncomeDetail where money='41235' and date='2019-02-15'
select date,* 
--update topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-02-14'
from topway..FinanceERP_ClientBankRealIncomeDetail where money='3620' and date='2019-02-15' and id='37BFABE3-D941-4D71-8108-954FDFFE57EA'

--���л�����Ϣ
select Code,Name,EnglishName,CountryCode from homsomDB..Trv_Cities where CountryType=2