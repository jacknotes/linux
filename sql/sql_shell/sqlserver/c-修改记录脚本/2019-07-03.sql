--��ͼ۸񺽰��ʱ��
select top 100* from homsomDB..Trv_LowerstPrices 

select RecordNumber ���۵���,l.Price ��ͼ�,Flight �����,DepartureTime ����ʱ��,ArrivalTime ����ʱ�� from homsomDB..Trv_DomesticTicketRecord d
left join homsomDB..Trv_ItktBookingSegments_PnrInfos t on t.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=t.ItktBookingSegID
where RecordNumber in('AS002519668',
'AS002519716',
'AS002520761',
'AS002521252',
'AS002521258',
'AS002521401',
'AS002521403',
'AS002525106',
'AS002526749',
'AS002526935',
'AS002528276',
'AS002528788',
'AS002529738',
'AS002530233',
'AS002531167',
'AS002531451',
'AS002532376',
'AS002533114',
'AS002534245',
'AS002534247',
'AS002536422',
'AS002537100',
'AS002539449',
'AS002539596',
'AS002545440',
'AS002546923',
'AS002547905',
'AS002549158',
'AS002551002',
'AS002551008',
'AS002552095',
'AS002552097',
'AS002553383',
'AS002554109',
'AS002555461',
'AS002555686',
'AS002556233',
'AS002556235',
'AS002557079',
'AS002557541',
'AS002558374',
'AS002558376',
'AS002558766',
'AS002558817',
'AS002558821',
'AS002558963',
'AS002558969',
'AS002560024',
'AS002560806',
'AS002560897',
'AS002560899',
'AS002560903',
'AS002560915',
'AS002560939',
'AS002560941',
'AS002561098',
'AS002561100',
'AS002561568',
'AS002561572',
'AS002561685',
'AS002561687',
'AS002561690',
'AS002561695',
'AS002561705',
'AS002561707',
'AS002561802',
'AS002561902',
'AS002562200',
'AS002562831',
'AS002564509',
'AS002564511',
'AS002565427',
'AS002567682',
'AS002567930',
'AS002568744',
'AS002568808',
'AS002568835',
'AS002570989',
'AS002571840',
'AS002574536',
'AS002575274',
'AS002576070',
'AS002576990',
'AS002577851',
'AS002579983',
'AS002580611',
'AS002580940',
'AS002581286',
'AS002582481',
'AS002582685',
'AS002582712',
'AS002582721',
'AS002582732',
'AS002585537',
'AS002587008',
'AS002587197',
'AS002590303',
'AS002590515',
'AS002590867',
'AS002590919',
'AS002591631',
'AS002593761',
'AS002594663',
'AS002595198',
'AS002595216')
and l.Price<>0

--�����տ��Ϣ
select Skstatus,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set Skstatus=2
where ConventionId='1412' and Id in('2792','2791')


--�����ȡ�������ݣ�ע��2019��1��1��ǰע��ĵ�λ�ͻ�Ϊ�Ͽͻ���  ά���˵�λ���ݷ���
if OBJECT_ID ('tempdb..#dwmx') is not null drop table #dwmx
select u.cmpid uc��,u.cmpname ��λ����,isnull(s.Name,'')ά����,indate ע������,un.Type ���� 
into #dwmx
from Topway..tbCompanyM u
left join homsomDB..Trv_UnitCompanies un on un.Cmpid=u.cmpid
left join homsomDB..Trv_UnitCompanies_KeyAccountManagers k on k.UnitCompanyID=un.ID
left join homsomDB..SSO_Users s on s.ID=k.EmployeeID
where hztype in ('1','2','3')
and s.Name is not null
and s.Name not in ('���')
order by ע������

select * from #dwmx


--�Ͽͻ�����
select CONVERT(varchar(7),c.datetime,120) �·�,ά����,SUM(isnull(c.totprice,0)-isnull(t.totprice,0))������,SUM(isnull(c.profit,0)+isnull(t.profit,0))������ 
from Topway..tbcash c
left join Topway..tbReti t on t.reno=reti and status2<>4
inner join #dwmx d on d.uc��=c.cmpcode
where ע������<'2019-01-01'
and c.datetime>='2019-05-01'
and c.datetime<'2019-07-01'
group by ά����,CONVERT(varchar(7),c.datetime,120)
order by �·�

--1��-6��
select ά����,SUM(isnull(c.totprice,0)-isnull(t.totprice,0))������,SUM(isnull(c.profit,0)+isnull(t.profit,0))������ 
from Topway..tbcash c
left join Topway..tbReti t on t.reno=reti and status2<>4
inner join #dwmx d on d.uc��=c.cmpcode
where ע������<'2019-01-01'
and c.datetime>='2018-01-01'
and c.datetime<'2018-07-01'
group by ά����
order by ά����

--�����Ͽͻ�
select  CONVERT(varchar(7),OperDate,120) �·�,ά����,SUM(XsPrice) ������,SUM(Profit)������
from Topway..tbTrvCoup c
inner join #dwmx d on d.uc��=c.Cmpid
where ע������<'2019-01-01'
and OperDate>='2019-05-01'
and OperDate<'2019-07-01'
group by ά����,CONVERT(varchar(7),OperDate,120)

--1��-6��
select  ά����,SUM(XsPrice) ������,SUM(Profit)������
from Topway..tbTrvCoup c
inner join #dwmx d on d.uc��=c.Cmpid
where ע������<'2019-01-01'
and OperDate>='2019-01-01'
and OperDate<'2019-07-01'
group by ά����

select  ά����,SUM(XsPrice) ������,SUM(Profit)������
from Topway..tbTrvCoup c
inner join #dwmx d on d.uc��=c.Cmpid
where ע������<'2019-01-01'
and OperDate>='2018-01-01'
and OperDate<'2018-07-01'
group by ά����


--�޸Ļ�Ʊ����
select tickettype,* from Topway..tbcash 
--update Topway..tbcash set tickettype='���ڷ�'
where coupno='AS002601984'

--����Ԥ�㵥��Ϣ
select StartDate,EndDate,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set StartDate='2019-06-24',EndDate='2019-06-26'
where TrvId='30213'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020359_20190501'

--ɾ������
select * 
--delete
from Topway..FinanceERP_ClientBankRealIncomeDetail where id='FA8ED6C5-71E1-4714-94F1-3C12AF107222'

--UC020410 ����ɯ ��Ϊ������ Ԥ�����ͣ�����Ԥ������ƱȨ�ޣ����ò�
--select * from homsomDB..Trv_Human where Name='����ɯ'
--and ID in(Select ID from homsomDB..Trv_UnitPersons 
--where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='020410'))

select UPRankID ��ƱԤ��Ȩ��ID,UPBookingRankID,TripType ����Ա������,Type ����Ա������,* from homsomDB..Trv_UnitPersons 
--update homsomDB..Trv_UnitPersons  set UPRankID='5ACFD687-8C14-4BA5-A478-AA3800EC0156',TripType='������',Type='������'
where ID='AF69707C-7EFC-42B5-BB16-AA4C00FAE89E'

select top 100 * from homsomDB..Trv_UPRanks where CompanyID='9C4B0B2E-9CCA-4F94-8929-A8EE00BB3B65'
select * from homsomDB..Trv_UPRanks where CompanyID='9C4B0B2E-9CCA-4F94-8929-A8EE00BB3B65'
select  top 100 BookingCollectionID,* from homsomDB..Trv_UPSettings where CompanyID='9C4B0B2E-9CCA-4F94-8929-A8EE00BB3B65'

select top 100 * from homsomDB..Trv_UPCollections_UnitPersons where UPCollectionID='47EE8716-3661-4615-902D-AA4C00FAE89E'
select top 100 * from homsomDB..Trv_UPBookingRanks  where Description like'%����%'

select * from homsomDB..Trv_UnitCompanies where Cmpid='000003'
select UPRankID ��ƱԤ��Ȩ��ID,UPBookingRankID,TripType ����Ա������,Type ����Ա������,* from homsomDB..Trv_UnitPersons 
--update homsomDB..Trv_UnitPersons  set UPRankID='5ACFD687-8C14-4BA5-A478-AA3800EC0156',TripType='������',Type='������'
where ID='AF69707C-7EFC-42B5-BB16-AA4C00FAE89E'


--�г̵�
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno in('AS002537528','AS002539309')

--�޸����۵���
select * from Topway..tbcash where tcode+ticketno='7844539572503'
--update Topway..tbcash set price='',profit='',totprice='',owe='',amount='' where tcode+ticketno=''
update Topway..tbcash set price=1350,profit=profit-70,totprice=1415,owe=1415,amount=1415 where tcode+ticketno='0181958755700'
update Topway..tbcash set price=1190,profit=profit-60,totprice=1255,owe=1255,amount=1255 where tcode+ticketno='4792155622850'
update Topway..tbcash set price=1190,profit=profit-60,totprice=1255,owe=1255,amount=1255 where tcode+ticketno='4792155622849'
update Topway..tbcash set price=1190,profit=profit-60,totprice=1255,owe=1255,amount=1255 where tcode+ticketno='4792155622851'
update Topway..tbcash set price=1190,profit=profit-60,totprice=1255,owe=1255,amount=1255 where tcode+ticketno='4792155622848'
update Topway..tbcash set price=1270,profit=profit-40,totprice=1335,owe=1335,amount=1335 where tcode+ticketno='7314530088005'
update Topway..tbcash set price=840,profit=profit-80,totprice=905,owe=905,amount=905 where tcode+ticketno='7818278180400'
update Topway..tbcash set price=890,profit=profit-20,totprice=955,owe=955,amount=955 where tcode+ticketno='7814531884415'
update Topway..tbcash set price=1610,profit=profit-50,totprice=1675,owe=1675,amount=1675 where tcode+ticketno='7314532800742'
update Topway..tbcash set price=1440,profit=profit-200,totprice=1505,owe=1505,amount=1505 where tcode+ticketno='7814533580459'
update Topway..tbcash set price=960,profit=profit-100,totprice=1025,owe=1025,amount=1025 where tcode+ticketno='7844533581931'
update Topway..tbcash set price=1550,profit=profit-100,totprice=1615,owe=1615,amount=1615 where tcode+ticketno='0184533582453'
update Topway..tbcash set price=1550,profit=profit-100,totprice=1615,owe=1615,amount=1615 where tcode+ticketno='0184533582450'
update Topway..tbcash set price=1550,profit=profit-100,totprice=1615,owe=1615,amount=1615 where tcode+ticketno='0184533582448'
update Topway..tbcash set price=1550,profit=profit-100,totprice=1615,owe=1615,amount=1615 where tcode+ticketno='0184533582451'
update Topway..tbcash set price=1550,profit=profit-100,totprice=1615,owe=1615,amount=1615 where tcode+ticketno='0184533582452'
update Topway..tbcash set price=1550,profit=profit-100,totprice=1615,owe=1615,amount=1615 where tcode+ticketno='0184533582449'
update Topway..tbcash set price=1550,profit=profit-100,totprice=1615,owe=1615,amount=1615 where tcode+ticketno='0184533582446'
update Topway..tbcash set price=1550,profit=profit-100,totprice=1615,owe=1615,amount=1615 where tcode+ticketno='0184533582447'
update Topway..tbcash set price=1460,profit=profit-150,totprice=1525,owe=1525,amount=1525 where tcode+ticketno='7818278214932'
update Topway..tbcash set price=1610,profit=profit-30,totprice=1675,owe=1675,amount=1675 where tcode+ticketno='7814535496829'
update Topway..tbcash set price=1500,profit=profit-120,totprice=1565,owe=1565,amount=1565 where tcode+ticketno='7814535919754'
update Topway..tbcash set price=1500,profit=profit-120,totprice=1565,owe=1565,amount=1565 where tcode+ticketno='7814535919753'
update Topway..tbcash set price=1520,profit=profit-120,totprice=1585,owe=1585,amount=1585 where tcode+ticketno='7814536957565'
update Topway..tbcash set price=470,profit=profit-30,totprice=535,owe=535,amount=535 where tcode+ticketno='7818278231435'
update Topway..tbcash set price=1240,profit=profit-50,totprice=1305,owe=1305,amount=1305 where tcode+ticketno='7812444571290'
update Topway..tbcash set price=610,profit=profit-50,totprice=675,owe=675,amount=675 where tcode+ticketno='7812444577373'

update Topway..tbcash set price=990,profit=profit-40,totprice=1055,owe=1055,amount=1055 where tcode+ticketno='7844539572503'
update Topway..tbcash set price=1000,profit=profit-50,totprice=1065,owe=1065,amount=1065 where tcode+ticketno='9994597223983'
update Topway..tbcash set price=1000,profit=profit-50,totprice=1065,owe=1065,amount=1065 where tcode+ticketno='9994597223984'
update Topway..tbcash set price=1490,profit=profit-150,totprice=1555,owe=1555,amount=1555 where tcode+ticketno='7812447613790'
update Topway..tbcash set price=1110,profit=profit-340,totprice=1175,owe=1175,amount=1175 where tcode+ticketno='7844598179638'
update Topway..tbcash set price=1150,profit=profit-40,totprice=1215,owe=1215,amount=1215 where tcode+ticketno='7844598179682'
update Topway..tbcash set price=810,profit=profit-40,totprice=875,owe=875,amount=875 where tcode+ticketno='7812447618978'
update Topway..tbcash set price=710,profit=profit-40,totprice=775,owe=775,amount=775 where tcode+ticketno='7812447618983'
update Topway..tbcash set price=710,profit=profit-40,totprice=775,owe=775,amount=775 where tcode+ticketno='7812447618982'
update Topway..tbcash set price=1520,profit=profit-120,totprice=1585,owe=1585,amount=1585 where tcode+ticketno='7812447619001'
update Topway..tbcash set price=1440,profit=profit-200,totprice=1505,owe=1505,amount=1505 where tcode+ticketno='7814598180516'
update Topway..tbcash set price=420,profit=profit-20,totprice=485,owe=485,amount=485 where tcode+ticketno='7812447619015'
update Topway..tbcash set price=1420,profit=profit-120,totprice=1485,owe=1485,amount=1485 where tcode+ticketno='7844598180949'
update Topway..tbcash set price=1340,profit=profit-110,totprice=1405,owe=1405,amount=1405 where tcode+ticketno='7812447625217'
update Topway..tbcash set price=1340,profit=profit-110,totprice=1405,owe=1405,amount=1405 where tcode+ticketno='7814599302040'
update Topway..tbcash set price=870,profit=profit-40,totprice=935,owe=935,amount=935 where tcode+ticketno='7812447626015'
update Topway..tbcash set price=1480,profit=profit-60,totprice=1545,owe=1545,amount=1545 where tcode+ticketno='7812447631340'
update Topway..tbcash set price=1540,profit=profit-120,totprice=1605,owe=1605,amount=1605 where tcode+ticketno='7844599303922'
update Topway..tbcash set price=1350,profit=profit-30,totprice=1415,owe=1415,amount=1415 where tcode+ticketno='7812447637983'
update Topway..tbcash set price=1350,profit=profit-30,totprice=1415,owe=1415,amount=1415 where tcode+ticketno='7812447637985'
update Topway..tbcash set price=1350,profit=profit-30,totprice=1415,owe=1415,amount=1415 where tcode+ticketno='7812447637984'
update Topway..tbcash set price=1260,profit=profit-130,totprice=1325,owe=1325,amount=1325 where tcode+ticketno='7845510139060'
update Topway..tbcash set price=1510,profit=profit-30,totprice=1575,owe=1575,amount=1575 where tcode+ticketno='7812447648429'
update Topway..tbcash set price=1520,profit=profit-120,totprice=1585,owe=1585,amount=1585 where tcode+ticketno='7815510141383'
update Topway..tbcash set price=1520,profit=profit-120,totprice=1585,owe=1585,amount=1585 where tcode+ticketno='7815510141384'
update Topway..tbcash set price=1520,profit=profit-120,totprice=1585,owe=1585,amount=1585 where tcode+ticketno='7815510141385'
update Topway..tbcash set price=1190,profit=profit-20,totprice=1255,owe=1255,amount=1255 where tcode+ticketno='7812447650226'
update Topway..tbcash set price=1350,profit=profit-70,totprice=1415,owe=1415,amount=1415 where tcode+ticketno='0185514874820'
update Topway..tbcash set price=1490,profit=profit-130,totprice=1555,owe=1555,amount=1555 where tcode+ticketno='7812447656425'
update Topway..tbcash set price=1610,profit=profit-30,totprice=1675,owe=1675,amount=1675 where tcode+ticketno='7815514875526'


--��Ʊҵ�������Ϣ
select SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set SpareTC='����'
where coupno='AS001759112'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='019658_20190601'


--�޸�Ԥ����
select custid,cmpcode,ModifyBillNumber,OriginalBillNumber,pform,* from Topway..tbcash 
--update Topway..tbcash  set custid='D583985'
where coupno='AS002586838'

select CustId,Customer,Person,Tel,* from Topway..tbFiveCoupInfo 
--update Topway..tbFiveCoupInfo  set CustId='D583985',Customer='�ܼ���',Person='�ܼ���|18817770685',Tel='18817770685'
where CoupNo='AS002586838'

--�����տ��Ϣ
select Price,totprice,owe,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Price='1850',totprice='1850',owe='1850'
where TrvId='30231'


--���ɿ����� ���ݲ������˸ģ�˰��
--�з�Ӷ
select t1.UC��,t1.��λ����,isnull(t1.����,0)����,isnull(t1.��Ӷ���,0) ��Ӷ���,isnull(t2.����,0)����,isnull(t3.MUUFJY�յ�����,0)MUUFJY�յ�����,isnull(t4.MU������λ����,0)MU������λ����,isnull(t5.CZ����,0)CZ����,
isnull(t6.HO����,0)HO����,isnull(t7.����,0)����,isnull(t7.��Ӷ���,0)��Ӷ���,isnull(t8.����,0)����,isnull(t9.MUUFJY�յ�����,0)MUUFJY�յ�����,isnull(t10.MU������λ����,0)MU������λ����,isnull(t11.CZ����,0)CZ����,isnull(t12.HO����,0)HO����
from 
(select cmpcode UC��,u.Name ��λ����,SUM(price) ����,SUM(xfprice) ��Ӷ��� from Topway..tbcash c with(nolock)
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='����Ʊ'
and xfprice<>0
and (cmpcode in('020665','020685','020643','016713','018408','018541','020742','020273','020085','020655') or (cmpcode='016448' and CostCenter='AM') OR (cmpcode='020637' and Department='JV')) 
group by cmpcode,u.Name) t1
left join
--�޷�Ӷ
(select cmpcode UC��,u.Name ��λ����,SUM(price) ���� from Topway..tbcash c with(nolock)
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='����Ʊ'
and xfprice=0
and (cmpcode in('020665','020685','020643','016713','018408','018541','020742','020273','020085','020655') or (cmpcode='016448' and CostCenter='AM') OR (cmpcode='020637' and Department='JV'))
group by cmpcode,u.Name)t2 on t1.UC��=t2.UC��
left join 
(select cmpcode UC��,u.Name ��λ����,SUM(price) MUUFJY�յ����� from Topway..tbcash c with(nolock)
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='����Ʊ'
and xfprice=0
and ride='MU'
and nclass in('U','F','J','Y')
and (cmpcode in('020665','020685','020643','016713','018408','018541','020742','020273','020085','020655') or (cmpcode='016448' and CostCenter='AM') OR (cmpcode='020637' and Department='JV'))
group by cmpcode,u.Name)t3 on t1.UC��=t3.UC��
left join

(select cmpcode UC��,u.Name ��λ����,SUM(price) MU������λ���� from Topway..tbcash c with(nolock)
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='����Ʊ'
and xfprice=0
and ride='MU'
and nclass not in('U','F','J','Y')
and (cmpcode in('020665','020685','020643','016713','018408','018541','020742','020273','020085','020655') or (cmpcode='016448' and CostCenter='AM') OR (cmpcode='020637' and Department='JV'))
group by cmpcode,u.Name) t4 on t1.UC��=t4.UC��
left join 

(select cmpcode UC��,u.Name ��λ����,SUM(price) CZ���� from Topway..tbcash c with(nolock)
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='����Ʊ'
and xfprice=0
and ride='cz'
and (cmpcode in('020665','020685','020643','016713','018408','018541','020742','020273','020085','020655') or (cmpcode='016448' and CostCenter='AM') OR (cmpcode='020637' and Department='JV'))
group by cmpcode,u.Name) t5 on t1.UC��=t5.UC��
left join 
(select cmpcode UC��,u.Name ��λ����,SUM(price) HO���� from Topway..tbcash c with(nolock)
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='����Ʊ'
and xfprice=0
and ride='ho'
and (cmpcode in('020665','020685','020643','016713','018408','018541','020742','020273','020085','020655') or (cmpcode='016448' and CostCenter='AM') OR (cmpcode='020637' and Department='JV'))
group by cmpcode,u.Name) t6 on t1.UC��=t6.UC��
left join
(select cmpcode UC��,u.Name ��λ����,SUM(price) ����,SUM(xfprice)��Ӷ��� from Topway..tbcash c with(nolock)
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=1
and reti=''
and tickettype='����Ʊ'
and route not like '%����%'
and route not like '%����%'
and xfprice<>0
and (cmpcode in('020665','020685','020643','016713','018408','018541','020742','020273','020085','020655') or (cmpcode='016448' and CostCenter='AM') OR (cmpcode='020637' and Department='JV'))
group by cmpcode,u.Name) t7 on t1.UC��=t7.UC��
left join
(select cmpcode UC��,u.Name ��λ����,SUM(price) ���� from Topway..tbcash c with(nolock)
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=1
and reti=''
and tickettype='����Ʊ'
and route not like '%����%'
and route not like '%����%'
and xfprice=0
and (cmpcode in('020665','020685','020643','016713','018408','018541','020742','020273','020085','020655') or (cmpcode='016448' and CostCenter='AM') OR (cmpcode='020637' and Department='JV'))
group by cmpcode,u.Name) t8 on t1.UC��=t8.UC��
left join
(select cmpcode UC��,u.Name ��λ����,SUM(price) MUUFJY�յ����� from Topway..tbcash c with(nolock)
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=1
and reti=''
and tickettype='����Ʊ'
and route not like '%����%'
and route not like '%����%'
and ride='MU'
and nclass  in('U','F','J','Y')
and xfprice=0
and (cmpcode in('020665','020685','020643','016713','018408','018541','020742','020273','020085','020655') or (cmpcode='016448' and CostCenter='AM') OR (cmpcode='020637' and Department='JV'))
group by cmpcode,u.Name) t9 on t1.UC��=t9.UC��
left join
(select cmpcode UC��,u.Name ��λ����,SUM(price) MU������λ���� from Topway..tbcash c with(nolock)
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=1
and reti=''
and tickettype='����Ʊ'
and route not like '%����%'
and route not like '%����%'
and ride='MU'
and nclass not in('U','F','J','Y')
and xfprice=0
and (cmpcode in('020665','020685','020643','016713','018408','018541','020742','020273','020085','020655') or (cmpcode='016448' and CostCenter='AM') OR (cmpcode='020637' and Department='JV'))
group by cmpcode,u.Name) t10 on t1.UC��=t10.UC��
left join
(select cmpcode UC��,u.Name ��λ����,SUM(price) CZ���� from Topway..tbcash c with(nolock)
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=1
and reti=''
and tickettype='����Ʊ'
and route not like '%����%'
and route not like '%����%'
and xfprice=0
and ride='cz'
and (cmpcode in('020665','020685','020643','016713','018408','018541','020742','020273','020085','020655') or (cmpcode='016448' and CostCenter='AM') OR (cmpcode='020637' and Department='JV'))
group by cmpcode,u.Name) t11 on t1.UC��=t11.UC��
left join
(select cmpcode UC��,u.Name ��λ����,SUM(price) HO���� from Topway..tbcash c with(nolock)
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=1
and reti=''
and tickettype='����Ʊ'
and route not like '%����%'
and route not like '%����%'
and xfprice=0
and ride='ho'
and (cmpcode in('020665','020685','020643','016713','018408','018541','020742','020273','020085','020655') or (cmpcode='016448' and CostCenter='AM') OR (cmpcode='020637' and Department='JV'))
group by cmpcode,u.Name) t12 on t1.UC��=t12.UC��
order by t1.UC��


--016448 ��ǰ��Ʊ����
select SUM(price) ������ 
from Topway..tbcash 
where cmpcode='016448'
and reti=''
and inf=0
and tickettype='����Ʊ'
and datetime>='2017-07-01'
and datetime <'2018-07-01'

--2017��7��-2018��6��

select (case when DATEDIFF(DD,c.datetime,c.begdate) between 0 and 2 then  1 when DATEDIFF(DD,c.datetime,c.begdate) between 3 and 6 then 2
when DATEDIFF(DD,c.datetime,c.begdate) between 7 and 13 then 3 when DATEDIFF(DD,c.datetime,c.begdate) between 14 and 20 then 4 when DATEDIFF(DD,c.datetime,c.begdate)>=21 then 5
else '' end) as ��ǰ��Ʊ������Χ,SUM(price) ����,COUNT(1)����,SUM(price)/4555989 ����ռ��,SUM(price)/SUM(CONVERT(decimal(18,3),priceinfo,null))�ۿ���
from Topway..tbcash c
left join ehomsom..tbInfCabincode t on t.code2=c.ride and c.nclass=t.cabin
and c.datetime>=t.begdate and c.datetime<=t.enddate and ((c.begdate>=flightbegdate and c.begdate<=flightenddate)
or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3)
or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode='016448'
and reti=''
and inf=1
and tickettype='����Ʊ'
and route not like '%����%'
and route not like '%����%'
and route not like'%��Ʊ%'
and cabintype like '%����%'
and priceinfo<>0
and datetime>='2017-07-01'
and datetime <'2018-07-01'
group by (case when DATEDIFF(DD,c.datetime,c.begdate) between 0 and 2 then  1 when DATEDIFF(DD,c.datetime,c.begdate) between 3 and 6 then 2
when DATEDIFF(DD,c.datetime,c.begdate) between 7 and 13 then 3 when DATEDIFF(DD,c.datetime,c.begdate) between 14 and 20 then 4 when DATEDIFF(DD,c.datetime,c.begdate)>=21 then 5
else '' end)

--������
select SUM(price) ������ 
from Topway..tbcash 
where cmpcode='016448'
and reti=''
and inf=0
and tickettype='����Ʊ'
and datetime>='2018-07-01'
and datetime<'2019-07-01'

select Department ����,SUM(price) ����,COUNT(1)����,SUM(price)/SUM(convert(decimal(18,3),priceinfo)) �ۿ���,SUM(DATEDIFF(DD,c.datetime,c.begdate))/COUNT(1)ƽ����ǰ��Ʊ����,SUM(price)/3414298 ����ռ��
from Topway..tbcash c
left join ehomsom..tbInfCabincode t on t.code2=c.ride and c.nclass=t.cabin
and c.datetime>=t.begdate and c.datetime<=t.enddate and ((c.begdate>=flightbegdate and c.begdate<=flightenddate)
or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3)
or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode='016448'
and inf=0
and reti=''
and tickettype='����Ʊ'
and (cabintype like '%ͷ��%' or cabintype like '%����%')
and datetime>='2018-07-01'
and datetime<'2019-07-01'
group by Department
order by ���� desc

--��������
select top 20 route ����,SUM(price) ����,COUNT(1)����,SUM(price)/count(1) ƽ��Ʊ��,SUM(price)/3414298 ����ռ��,SUM(price)/SUM(CONVERT(decimal(18,3),priceinfo)) �ۿ���
from Topway..tbcash c
left join ehomsom..tbInfCabincode t on t.code2=c.ride and c.nclass=t.cabin
and c.datetime>=t.begdate and c.datetime<=t.enddate and ((c.begdate>=flightbegdate and c.begdate<=flightenddate)
or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3)
or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode='016448'
and inf=0
and reti=''
and tickettype='����Ʊ'
and cabintype like '%���ò�%'
and datetime>='2018-07-01'
and datetime<'2019-07-01'
group by route
order by ���� desc

--�г̵�
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno in('AS002539361','AS002535966')

--�޸ĳ�Ʊ״̬
select HandleStatus,* from Topway..tbFiveCoupInfo where CoupNo='AS002604462'
select OrderStatus,* from homsomDB..Intl_BookingOrders where Id='d8739e47-e81b-44cc-94dd-2fa7aafa79d4'

