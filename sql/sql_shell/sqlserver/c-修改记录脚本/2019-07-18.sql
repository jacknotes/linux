--�����������뽫020805���޳��³���CZ��F/J/W/Y/B/M/H/U/A/L������ �˻���
select distinct idno from Topway..tbcash 
where cmpcode='020805'
and ride='cz'
and nclass in('F','J','W','Y','B','M','H','U','A','L')
and datetime>='2019-05-01'

--2.1
select sales ���ù���,SpareTC ��������,SUM(isnull(c.totprice,0)-ISNULL(t.totprice,0)) �ϼ����ۼ�,
SUM(isnull(c.profit,0)+isnull(t.profit,0)) �ϼ�����,
SUM(Mcost) �ϼ��ʽ����,SUM(fuprice) �ϼƷ����
from Topway..tbcash c
left join Topway..tbReti t on c.reti=t.reno and status2<>4
where c.datetime>='2019-07-01'
group by sales,SpareTC
order BY �ϼ����ۼ� DESC

--�ؿ���ӡ
select HXQM,* from topway..tbHtlSettlementApp 
--update topway..tbHtlSettlementApp  set HXQM=''
where id='26227'

--AS002526510 AS002589634 AS002589917 ��Ʊ���� 9267207 �����ĳ�δ��
--��Ʊ���۵���Ϊδ��
select bpay,status,opernum,oper2,oth2,totprice,dzhxDate,owe,vpay,vpayinf,dzhxDate
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
from Topway..tbcash where coupno in ('AS002526510','AS002589634','AS002589917')

--�޸���Ʊ����
select ExamineDate,ModifyBillNumber,status2,* from Topway..tbReti 
--update Topway..tbReti set ExamineDate='1900-01-01',status2='8'
where reno='9267207'

--��������ĳ�δӦ�ջ��δ��� 
select state,* from Topway..FinanceERP_ClientBankRealIncomeDetail 
--update Topway..FinanceERP_ClientBankRealIncomeDetail  set state=5
where date='2019-07-16' and money='2230'

--�����г��������
select tcode+ticketno Ʊ��,b.Sort,convert(varchar(18),DepartureTime,120) �������,CityName1 �������� from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where tcode+ticketno in('9322874436190',
'7812876524228',
'9325320692262',
'9325321023827',
'7812080298384',
'9322081507091',
'7814476488629',
'6182694796746',
'7812080707486',
'1252080705977',
'7812695776209',
'1252695768774',
'7812696056673',
'7812760777045',
'9322875454220')
order by b.Sort

--2.2ҵ�����
SELECT Sales ���ι���,JiDIao ����֧��,SUM(XsPrice) �ϼ����۽��,SUM(JsZPrice) �ϼƽ�����,SUM(Profit) �ϼ�����
from Topway..tbTrvCoup
where OperDate>='2019-07-01'
group by Sales,JiDIao
order by �ϼ����۽�� desc

--2.2������
select t2.OperDate Ԥ�㵥¼������,indate ��λע������,ss.Name ������,SUM(DisCountProfit) �ϼƼ�������
from Topway..tbTrvCoup t1
left join Topway..tbTravelBudget t2 on t2.TrvId=t1.TrvId
left join homsomDB..Trv_UnitCompanies  u on u.Cmpid=t1.Cmpid 
left join homsomDB..Trv_UnitCompies_Sales s on s.UnitCompayID=u.ID
left join Topway..tbCompanyM t3 on t3.cmpid=u.Cmpid
left join homsomDB..SSO_Users ss on ss.ID=s.EmployeeID
where t1.OperDate>='2019-07-01'
and t1.Cmpid<>''
group by t2.OperDate,indate,ss.Name
order by Ԥ�㵥¼������

--2.3ҵ�����
SELECT Sales ���ι���,JiDIao ����֧��,SUM(XsPrice) �ϼ����۽��,SUM(JsZPrice) �ϼƽ�����,SUM(Profit) �ϼ�����
from Topway..tbConventionCoup
where OperDate>='2019-07-01'
group by Sales,JiDIao
order by �ϼ����۽�� desc

--2.3������
select t2.OperDate Ԥ�㵥¼������,indate ��λע������,ss.Name ������,SUM(DisCountProfit) �ϼƼ�������
from Topway..tbConventionCoup t1
left join Topway..tbConventionBudget t2 on t2.ConventionId=t1.ConventionId
left join homsomDB..Trv_UnitCompanies  u on u.Cmpid=t1.Cmpid 
left join homsomDB..Trv_UnitCompies_Sales s on s.UnitCompayID=u.ID
left join Topway..tbCompanyM t3 on t3.cmpid=u.Cmpid
left join homsomDB..SSO_Users ss on ss.ID=s.EmployeeID
where t1.OperDate>='2019-07-01'
and t1.Cmpid<>''
group by t2.OperDate,indate,ss.Name
order by Ԥ�㵥¼������

select top 100 * from homsomDB..Trv_LowerstPrices

--3.1����
select cmpcode UC,Name ��λ����,convert(varchar(10),datetime,120) ��Ʊ����,begdate �������,coupno ���۵���,pasname �˻���,c.route �г�,tcode+ticketno Ʊ��,
 ride ��˾,flightno ������,priceinfo ȫ��,c.price ���۵���,tax ˰��,totprice ���ۼ�,profit ����,Mcost �ʽ����,originalprice ԭ��,xfprice ǰ�����,c.fuprice �����,
 Department ����,CostCenter �ɱ�����,DATEDIFF(DD,datetime,begdate) ��ǰ��Ʊ����,reti ��Ʊ����,nclass ��λ����,CabinClass ��λ�ȼ�,isnull(convert(varchar(10),l.Price),'')��ͼ�,isnull(l.UnChoosedReason,'')Reasoncode,tickettype ��Ʊ����
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on cmpcode=Cmpid
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos it on it.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=it.ItktBookingSegID
where cmpcode='016448'
and datetime>='2019-07-01'
and inf=0

--3.1����
select cmpcode UC,Name ��λ����,convert(varchar(10),datetime,120) ��Ʊ����,begdate �������,coupno ���۵���,pasname �˻���,route �г�,tcode+ticketno Ʊ��,
 ride ��˾,flightno ������,priceinfo ȫ��,c.price ���۵���,tax ˰��,totprice ���ۼ�,profit ����,Mcost �ʽ����,xfprice ǰ�����,c.fuprice �����,
 Department ����,CostCenter �ɱ�����,DATEDIFF(DD,datetime,begdate) ��ǰ��Ʊ����,reti ��Ʊ����,nclass ��λ����,CabinClass ��λ�ȼ�,tickettype ��Ʊ����
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on cmpcode=Cmpid
where cmpcode='016448'
and datetime>='2019-07-01'
and inf=1

--��20��
select MobileList,CostCenter,pcs,Department,* from topway..tbFiveCoupInfosub
--update topway..tbFiveCoupInfosub set MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='20',Department='��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��' 
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002645860')

--����֧����ʽ���Ը����渶��
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,vpayinf,* from Topway..tbcash 
--update Topway..tbcash set PayNo=TCPayNo,TCPayNo='',PayStatus=AdvanceStatus,AdvanceStatus=0,CustomerPayWay=TcPayWay,TcPayWay=null,CustomerPayDate=TcPayDate,dzhxDate=TcPayDate,TcPayDate='1900-01-01',status=1,owe=0,vpay=totprice
where coupno in ('AS001711814')

select PayStatus,AdvanceStatus,PayNo,TCPayNo,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET PayStatus=AdvanceStatus,PayNo=TCPayNo,CustomerPayWay=TcPayWay,CustomerPayDate=TcPayDate,AdvanceStatus=0,TCPayNo='',TcPayWay=0,TcPayDate=null
WHERE CoupNo in ('AS001711814')

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='019014_20190601'

/*
���æ��ȡ2019��5��13��֮����ǩԼ�Ŀͻ���
Ҫ��
1����������Ʊ��Ϊ���ǡ��Ŀͻ�
2����չʾ���ݣ���ͨUC�ŵ����ڣ�UC�ţ���λ���ƣ����ÿ�ȫ�����������Ѿ�������Ʊ�ĳ��ÿ�����������������Ĺ����������������������ʣ��밴��չʾ
*/
--��λ����
if OBJECT_ID('tempdb..#dw') is not null drop table #dw
select indate ��ͨUC�ŵ�����,cmpid UC��,cmpname  ��λ����
into #dw
from Topway..tbCompanyM 
where indate>='2019-05-13'
and IsSepPrice=1
order by ��ͨUC�ŵ�����
--���ÿ�����
select Cmpid UC��,h.Name ��������,LastName+'/'+FirstName+MiddleName Ӣ������,cr.CredentialNo  ֤����
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on h.ID=u.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
left join homsomDB..Trv_Credentials cr on cr.HumanID=h.ID
where Cmpid in(Select UC�� from #dw)
order by UC��

if OBJECT_ID('tempdb..#lks') is not null drop table #lks
select Cmpid UC��,COUNT(1)  ���ÿ�������
into #lks
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on h.ID=u.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
left join homsomDB..Trv_Credentials cr on cr.HumanID=h.ID
where Cmpid in(Select UC�� from #dw)
group by Cmpid
order by UC��

--������Ʊ����
if OBJECT_ID('tempdb..#rs') is not null drop table #rs
select distinct cmpcode UC��,pasname �˻���,idno ֤����  
into #rs
from Topway..tbcash 
where cmpcode in (Select UC�� from #dw)

if OBJECT_ID('tempdb..#rs1') is not null drop table #rs1
select UC��,COUNT(1) ���� into #rs1 from #rs group by UC��
--����
if OBJECT_ID('tempdb..#XL') is not null drop table #XL
select c.cmpcode UC��,SUM(isnull(c.totprice,0)-isnull(t.totprice,0)) ��������Ĺ�������,
SUM(isnull(c.profit,0)+isnull(t.profit,0)) ��������,'' ������
into #XL
from Topway..tbcash c
left join Topway..tbReti t on c.reti=t.reno
where C.cmpcode in (Select UC�� from #dw)
and c.inf=0
group by c.cmpcode
ORDER BY UC��

select h.MaintainName ��Ӫ����,convert(varchar(18),��ͨUC�ŵ�����,120) ��ͨUC�ŵ�����,d.UC��,���ÿ�������,isnull(����,0) as ������Ʊ����,isnull(��������Ĺ�������,0) ��������Ĺ�������,isnull(��������,0) ��������
from #dw d
left join #rs1 r on r.UC��=d.UC��
left join #XL x on x.UC��=d.UC��
left join #lks l on L.UC��=d.UC��
left join Topway..HM_ThePreservationOfHumanInformation h on h.CmpId=d.UC�� and MaintainType=9 and IsDisplay=1
order by ��Ӫ����,��ͨUC�ŵ�����


--�����տ��Ϣ
SELECT Skstatus,* FROM Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Skstatus=2
where TrvId='30115'

--ɾ�����ÿ� UC020548������ܿƼ����Ϻ������޹�˾
select distinct Mobile from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies
where Cmpid='020548')) and IsDisplay=1
and Mobile in('18600566682',
'18510900920',
'13321101159',
'15701665293',
'15948022480',
'13683281000',
'13021689296',
'15890656380',
'18310252704',
'18911716626',
'17346523695',
'18911411560',
'15101579545',
'15737129735',
'18601083290',
'13520091244',
'17610510915',
'13701329460',
'15201113751',
'18684312033',
'18911907578',
'13911156290',
'15910845564',
'18810800920',
'18510332870',
'15116997250',
'13515390716',
'13581828468',
'18604325791',
'13141310357',
'18510180315',
'13520326929',
'18600463756',
'18500847946',
'13910783063',
'13601353652',
'13381158750',
'13661010080',
'18611343721',
'18500541280',
'13011168709',
'13691399836',
'18611755760',
'18511929268',
'15011481930',
'18600736986',
'15810915106',
'13321175207',
'18600983336',
'18621165065',
'13520541350',
'13379023011',
'15801312408',
'15611731216',
'13501083209',
'13811323798',
'13608020722',
'18526285693',
'13911676814',
'15011186889',
'13810852031',
'13581757101',
'15694343651',
'18611700660',
'17701023782',
'18001134519',
'18513771919',
'18519099965',
'15810909818',
'13811963507',
'17710902205',
'16607371566',
'17801190551')


select * from Topway..tbCusholderM 
--update Topway..tbCusholderM  set EmployeeStatus=0
where mobilephone in('18600566682',
'18510900920',
'13321101159',
'15701665293',
'15948022480',
'13683281000',
'13021689296',
'15890656380',
'18310252704',
'18911716626',
'17346523695',
'18911411560',
'15101579545',
'15737129735',
'18601083290',
'13520091244',
'17610510915',
'13701329460',
'15201113751',
'18684312033',
'18911907578',
'13911156290',
'15910845564',
'18810800920',
'18510332870',
'15116997250',
'13515390716',
'13581828468',
'18604325791',
'13141310357',
'18510180315',
'13520326929',
'18600463756',
'18500847946',
'13910783063',
'13601353652',
'13381158750',
'13661010080',
'18611343721',
'18500541280',
'13011168709',
'13691399836',
'18611755760',
'18511929268',
'15011481930',
'18600736986',
'15810915106',
'13321175207',
'18600983336',
'18621165065',
'13520541350',
'13379023011',
'15801312408',
'15611731216',
'13501083209',
'13811323798',
'13608020722',
'18526285693',
'13911676814',
'15011186889',
'13810852031',
'13581757101',
'15694343651',
'18611700660',
'17701023782',
'18001134519',
'18513771919',
'18519099965',
'15810909818',
'13811963507',
'17710902205',
'16607371566',
'17801190551')

select distinct Mobile from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies
where Cmpid='020548')) and IsDisplay=1
and Name in ('������','����','�ƿ�')

--�޸����ۼ�
select price+tax+fuprice,totprice,owe,amount,* from Topway..tbcash 
--update Topway..tbcash  set totprice=1895,totprice=1895,amount=1895
where coupno='AS002588421'

select IsJoinRank,* from Topway..Emppwd 
--update Topway..Emppwd  set IsJoinRank=1
where idnumber='0743'