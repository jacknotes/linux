--������λ�ͻ������λ��������Ϊhomsom
select distinct CmpId,* from Topway..HM_ThePreservationOfHumanInformation where Cmpid in()  and IsDisplay='1'  and MaintainType='6' and MaintainName<>'HOMSOM'

--2018���ƱƵ�κ�������
--����
select route as ����,t1.airname as ��˾,COUNT(*) as Ƶ��,SUM(totprice) as ���� from Topway..tbcash t
left join ehomsom..tbInfAirCompany t1 on t1.code2=t.ride
where datetime>='2018-01-01' and datetime<'2019-01-01'  and inf=0 and cmpcode='019358'
group by route,t1.airname
order by Ƶ�� desc
--����
select route as ����,t1.airname as ��˾,COUNT(*) as Ƶ��,SUM(totprice) as ���� from Topway..tbcash t
left join ehomsom..tbInfAirCompany t1 on t1.code2=t.ride
where datetime>='2018-01-01' and datetime<'2019-01-01'  and inf=1 and cmpcode='019358'
group by route,t1.airname
order by Ƶ�� desc

--�˵�����
SELECT SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState='1'
where CompanyCode='020237' and BillNumber='020237_20181201'

--�˵�����
SELECT SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState='1'
where CompanyCode='020350' and BillNumber='020350_20181201'

--�������۵��޸�
DELETE from Topway..tbcash where coupno='AS000000000' and ticketno='3422933153'

--����Ʒ��ר�ã��޸���Ʊ¼����
select opername,cpopername,* from Topway..tbReti 
--update Topway..tbReti set cpopername='�̾���'
where reno='0426338'

--�˵�uc����
select CompanyNameCN,* from Topway..AccountStatement   
--update Topway..AccountStatement set CompanyNameCN='�Ϻ������˿Ƽ����޹�˾'
where CompanyCode='019121' and BillNumber='019121_20190101'

select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement set CompanyNameCN='�Ϻ��������ﲿ���޹�˾'
where CompanyCode='019843' and BillNumber='019843_20190101'

--��Ʊ
SELECT t1.RecordNumber,t5.Name 
FROM homsomDB..Trv_DomesticTicketRecord t1
left join homsomDB..Trv_PnrInfos t2 on t2.ID=t1.PnrInfoID
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t2.ItktBookingID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='����'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.RecordNumber 
in('AS002146124',
'AS002146126',
'AS002146128',
'AS002146130',
'AS002146829',
'AS002148981',
'AS002153350',
'AS002159302',
'AS002159304',
'AS002161432',
'AS002162667',
'AS002162748',
'AS002162758',
'AS002162772',
'AS002162864',
'AS002162868',
'AS002162870',
'AS002162872',
'AS002162874',
'AS002162882',
'AS002162886',
'AS002162894',
'AS002162938',
'AS002162998',
'AS002163030',
'AS002163333',
'AS002163335',
'AS002164619',
'AS002164745',
'AS002164745',
'AS002164810',
'AS002164844',
'AS002165399',
'AS002165399',
'AS002165858',
'AS002166291',
'AS002166302',
'AS002166876',
'AS002167336',
'AS002167374',
'AS002167636',
'AS002171040',
'AS002171060',
'AS002171064',
'AS002171066',
'AS002171485',
'AS002171487',
'AS002171499',
'AS002171501',
'AS002171503',
'AS002171505',
'AS002171591',
'AS002171598',
'AS002171730',
'AS002172023',
'AS002172587',
'AS002172594',
'AS002172594',
'AS002172606',
'AS002172606',
'AS002172654',
'AS002172654',
'AS002172662',
'AS002172791',
'AS002175154',
'AS002175156',
'AS002178217',
'AS002178614',
'AS002178874',
'AS002178954',
'AS002179198',
'AS002179237',
'AS002179313',
'AS002179930',
'AS002180338',
'AS002180346',
'AS002180364',
'AS002181313',
'AS002182710',
'AS002182726',
'AS002182730',
'AS002183471',
'AS002184648',
'AS002184650',
'AS002184652',
'AS002184955',
'AS002184964',
'AS002185477',
'AS002185642',
'AS002186014',
'AS002186016',
'AS002186022',
'AS002186732',
'AS002186738',
'AS002186823',
'AS002186827',
'AS002186831',
'AS002187190',
'AS002188443',
'AS002188445',
'AS002188720',
'AS002190037',
'AS002192310',
'AS002197134',
'AS002197150',
'AS002197155',
'AS002197220',
'AS002197884',
'AS002197884',
'AS002197884',
'AS002198239',
'AS002198245',
'AS002198526',
'AS002198588',
'AS002198604',
'AS002199307',
'AS002199321',
'AS002199667',
'AS002199678',
'AS002199682',
'AS002199690',
'AS002199713',
'AS002199740',
'AS002199742',
'AS002199749',
'AS002199767',
'AS002199779',
'AS002199783',
'AS002199785',
'AS002199792',
'AS002199806',
'AS002199838',
'AS002200009',
'AS002200138',
'AS002200511',
'AS002200511',
'AS002200518',
'AS002200525',
'AS002200853',
'AS002201565',
'AS002201609',
'AS002202260',
'AS002202513',
'AS002202519',
'AS002202523',
'AS002205733',
'AS002205737',
'AS002205751',
'AS002205757',
'AS002205763',
'AS002205799',
'AS002205805',
'AS002205916',
'AS002206062',
'AS002206795',
'AS002206886',
'AS002208102',
'AS002208242',
'AS002208298',
'AS002208459',
'AS002209067',
'AS002209339',
'AS002209339',
'AS002209986',
'AS002210409',
'AS002210409',
'AS002210409',
'AS002210409',
'AS002213484',
'AS002216098',
'AS002217260',
'AS002217272',
'AS002217820',
'AS002218027',
'AS002218222',
'AS002218673') 
and NodeType=110 and NodeID=110

--�Ƶ�
SELECT CoupNo,t5.Name FROM HotelOrderDB..HTL_Orders t1
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t1.OrderID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='����'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.CoupNo in 
(  'PTW071756' ,
 'PTW072163' ,
 '-PTW072163' ,
 'PTW072240' ,
 'PTW072265' ,
 'PTW072416') and NodeType=110 and NodeID=111
 
 
 
 --�Ϻ�����2018����
 select datetime as ��Ʊ����,begdate as �������,coupno as ���۵���,pasname as �˿�����,route as ��·,ride+flightno as �����,tcode+ticketno as Ʊ��,priceinfo as ȫ��,
 price/priceinfo as �ۿ���,totprice as ���ۼ�,tax as ˰��,fuprice as �����,price as ���۵���,reti as ��Ʊ����,CostCenter as �ɱ�����
  from Topway..V_TicketInfo 
 where datetime>='2018-01-01' and datetime<'2019-01-01' and cmpcode='019358' and priceinfo>'0'  and inf=1
 order by datetime
 
 select DepName,* from homsomdb..Trv_CompanyStructure where id in (select CompanyDptId from homsomDB..Trv_UnitPersons t3 inner join homsomdb.dbo.Trv_Human t4 on t3.ID=t4.ID 
where t4.IsDisplay=1 and t3.CompanyId in (Select ID from  homsomdb..Trv_UnitCompanies where Cmpid='019358'))
select Top 10* from homsomDB..Trv_Human --where CompanyId='769FCAC7-783C-4097-ADD4-A52300E4DEF0'

 --��Ʊ����
 select edatetime,ExamineDate from Topway..tbReti 
 --update Topway..tbReti set edatetime='2019-1-21',ExamineDate='2019-01-18'
 where reno='0426338'
 
 --̩˼��ó�׳˻�������
 select pasname as �˻���,coupno as ���۵���,route as �г�,begdate as ����ʱ��,SUM(totprice) as '����(��˰)' from Topway..tbcash where datetime>='2018-01-01' and datetime<'2019-01-01' and cmpcode='018821' and reti='' and pasname like'��%'
 group by pasname,coupno,route,begdate
 