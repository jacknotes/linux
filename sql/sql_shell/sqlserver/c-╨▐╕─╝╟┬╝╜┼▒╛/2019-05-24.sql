select DATEDIFF(HH,indate,begdate),* from Topway..tbcash where coupno='AS002487782'

--��Ʊ����޸�/����
select Status,* from Topway..HM_tbReti_tbReFundPayMent 
--update Topway..HM_tbReti_tbReFundPayMent set Status=4
where Id='703781'

select status2,* from Topway..tbReti 
--update Topway..tbReti set status2=2
where reno='9267003'


--����Ԥ�㵥��Ϣ
select Cmpid,Custinfo,CustomerType,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Cmpid='',Custinfo='15257586707@ξ�ϻ�@020139@@ξ�ϻ�@15257586707@D553572',CustomerType='���˿ͻ�'
where TrvId='30031'


--��Ʊ��Ա��ϸ
if  OBJECT_ID('tempdb..#rs') is not null drop table #rs
select distinct cmpcode,pasname,idno,count(1)����
into #rs
from Topway..tbcash c with (nolock)
where cmpcode in ('020027',
'018080',
'020305',
'016709',
'019436',
'017888',
'020260',
'020724',
'016588',
'017202',
'017649',
'017399',
'020146',
'020741',
'020355',
'017996',
'018809',
'019360',
'016426',
'020315',
'020723',
'018125',
'016402',
'017012',
'018400',
'018326',
'016337',
'020249',
'020063',
'020698',
'016087',
'016346',
'019158',
'019219',
'020200',
'018627',
'017056',
'017920',
'019261',
'019972',
'020507',
'016834',
'020053',
'020545',
'017415',
'016531',
'019557',
'016515',
'019987',
'019159',
'020324',
'020342',
'016352',
'018131',
'020183',
'019997',
'017762',
'020571',
'016490',
'018591',
'017947',
'018570',
'019845')
and datetime>'2018-01-01'
and datetime<'2019-04-30'
and inf=0
group by pasname,cmpcode,idno
order by cmpcode

select cmpcode,pasname,idno from #rs


select top 100 * from homsomDB..Trv_Passengers

select distinct Cmpid,h.Name,LastName+'/'+FirstName+MiddleName,cr.CredentialNo from homsomDB..Trv_DomesticTicketRecord d
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID 
left join homsomDB..Trv_Passengers pa on pa.ItktBookingID=p.ItktBookingID
left join homsomDB..Trv_Credentials cr on cr.HumanID=pa.UPID
left join homsomDB..Trv_UnitPersons un on un.ID=pa.UPID
left join homsomDB..Trv_UnitCompanies u on u.ID=un.CompanyID
left join homsomDB..Trv_Human h on h.ID=pa.UPID
where handlestatus=3
and Cmpid='016087'



--�޸���Ʊ���
select scount2 ���չ�˾��Ʊ��,rtprice �տͻ���Ʊ��,price ʵ�����ۼ�,totprice HSӦ�����,sprice ԭ�����,profit ��Ʊ����,status2,stotprice HSӦ�ս��,ExamineDate,* from Topway..tbReti 
--update Topway..tbReti set status2=2,scount2=2100,stotprice=24151,sprice=26251,profit=-100,ExamineDate=getdate()
where reno='9267059'


--��λ�ͻ����Ŷ�ȵ���
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SX_TotalCreditLine=100000
where BillNumber='020585_20190501'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--UPDATE Topway..AccountStatement SET SubmitState=1
where BillNumber='018964_20190401'