--UC013184 ʱ��2018��1��-2019��6��
select * from ehomsom..tbInfAirCompany
select top 100 * from homsomDB..Trv_ItktBookingSegs
select top 100 * from homsomDB..Trv_LowerstPrices
select top 100 CoupNo,* from homsomDB..Trv_TktBookings
select top 100 * from homsomDB..Intl_BookingLegs
select top 100 * from homsomDB..Intl_BookingOrders
select top 100 * from homsomDB..Intl_BookingSegements

--����
select pasname �˻���,CostCenter �ɱ�����,Department ����,DETR_RP �г̵���,InvoicesID ˰��,tickettype ����,
convert(varchar(10),datetime,120) ��Ʊ����,recno PNR,tcode+ticketno Ʊ��,OldTicketNo oldƱ��,ride ��˾����,it.Airline ��˾����,'����' ���ʻ����,
'����' �Ƿ�����,c2.Name ��������,c1.Name �������,c2.CountryCode ��������,c1.CountryCode �������,c.route �г�,
case when FlightClass like'%����%' then '���ò�' when FlightClass like'%����%' then '�����' when FlightClass like'%ͷ�Ȳ�%' then 'ͷ�Ȳ�' else '-' End  ��λ�ȼ�
,nclass ��λ����,Departing �������,Arriving ��������,case when DATEDIFF(DD,datetime,Departing) between 0 and 2  then '0to2'
when DATEDIFF(DD,datetime,Departing) between 3 and 6 then '3to6' else '7+' end ��ǰ��Ʊ,DATEDIFF(DD,datetime,Departing) ��ǰ��Ʊ����,
c.price ���۵���,tax ˰��,fuprice �����,totprice ���ۼ�,priceinfo ȫ��,l.Price ��ͼ�,AuthorizationCode ��Ȩ��,l.UnChoosedReason ReasonCode,
tickettype ����,DATEDIFF(MINUTE,Departing,Arriving) ����ʱ��
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos s on s.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ID=s.ItktBookingSegID
left join homsomDB..Trv_Airport a1 on a1.Code=it.Destination
left join homsomDB..Trv_Airport a2 on a2.Code=it.Origin
left join homsomDB..Trv_Cities c1 on c1.ID=a1.CityID
left join homsomDB..Trv_Cities c2 on c2.ID=a2.CityID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=s.ItktBookingSegID
left join homsomDB..Trv_TktBookings tk on tk.ID=it.ItktBookingID
where cmpcode='013184'
and inf=0
and datetime>='2018-01-01'
and datetime<'2019-07-01'

select * from ehomsom..tbInfCabincode
--����
select  pasname �˻���,'','',CostCenter �ɱ�����,Department ����,DETR_RP �г̵���,InvoicesID ˰��,c.tickettype ����,
datetime ��Ʊ����,recno PNR,tcode+ticketno Ʊ��,OldTicketNo oldƱ��,ride ��˾����,airname ��˾����,'����' ���ʻ����,
route,cabintype,nclass,c.begdate,'',case when DATEDIFF(DD,datetime,c.begdate) between 0 and 2  then '0to2'
when DATEDIFF(DD,datetime,c.begdate) between 3 and 6 then '3to6' else '7+' end ��ǰ��Ʊ,DATEDIFF(DD,datetime,c.begdate) ��ǰ��Ʊ����
,price,tax,fuprice,totprice,''
from Topway..tbcash c
left join ehomsom..tbInfAirCompany tb on tb.code2=c.ride
left join ehomsom..tbInfCabincode t on t.code2=c.ride and t.cabin=c.nclass
and datetime>=t.begdate and datetime<=c.EndDate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2)
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode='013184'
and inf=1
and datetime>='2018-01-01'
and datetime<'2019-07-01'

select Name,CountryCode,* from homsomDB..Trv_Cities where ID =(select CityID from homsomDB..Trv_Airport where Code='cdg')

/*
UC006299   ̩���Ϻ������޹�˾
 
��ͻ��ʼ�Ҫ���밴���������ȡ2018/9/1---2019/6/30���˻���������Ʊ�š���ɳ��С�Ŀ�ĵس��С���Ʊ���ڡ�������ڡ��س����ڡ��г���������Ʊʹ����� 9������
*/
select pasname �˻�������,tcode+ticketno Ʊ��,DepartCityName ��ɳ���,ArrivalCityName Ŀ�ĵس���,convert(varchar(10),datetime,120) ��Ʊ����,begdate �������,'' �س�����,''�г�����,
case when  tickettype='����Ʊ' then 'ʹ��' else '��������' end ��Ʊʹ����� 
from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos it on it.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs i on i.ID=it.ItktBookingSegID
where cmpcode='006299'
and inf=0
and datetime>='2018-09-01'
and datetime<'2019-07-01'

--�������
--if OBJECT_ID('tempdb..#qf') is not null drop table #qf
select pasname �˻�������,tcode+ticketno Ʊ��,case when b.Sort=1 then CityName1 else''end ��ɳ���,
case when b.Sort=2 then CityName2 else''end Ŀ�ĵس���1,case when b.Sort=2 then bo.DepartureTime else''end �س�����1,case when b.Sort=3 then CityName2 else''end Ŀ�ĵس���2,
case when b.Sort=3 then bo.DepartureTime else''end �س�����2,
case when b.Sort=4 then CityName2  else''end Ŀ�ĵس���3, case when b.Sort=4then bo.DepartureTime else''end �س�����3,
case when b.Sort=5 then CityName2  else''end Ŀ�ĵس���4,case when b.Sort=5 then bo.DepartureTime else''end �س�����4,
case when b.Sort=5 then CityName2  else''end Ŀ�ĵس���5,case when b.Sort=6 then CityName2  else''end Ŀ�ĵس���6,
convert(varchar(10),datetime,120) ��Ʊ����,begdate �������, 
case when  c.tickettype='����Ʊ' then 'ʹ��'  else '�˸�' end ��Ʊʹ�����,route
--into #qf
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where cmpcode='006299'
and inf=1
and datetime>='2018-09-01'
and datetime<'2019-07-01'
order by Ʊ��

--���ʷ���
select pasname �˻�������,tcode+ticketno Ʊ��,case when b.Sort=2 then bo.CityName2 
when b.Sort=3 then bo.CityName2  else '' end
--into #qf
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where cmpcode='006299'
and inf=1
and datetime>='2018-09-01'
and datetime<'2019-07-01'

--�˵�����
select SubmitState,TrainBillStatus,HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1,TrainBillStatus=1,HotelSubmitStatus=2
where BillNumber='019159_20190501'

--�˵�����
select SubmitState,TrainBillStatus,HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020583_20190601'

--��Ʊ���ۼ���Ϣ
select TotFuprice,TotPrice,* from Topway..tbTrainTicketInfo
--update  Topway..tbTrainTicketInfo set TotFuprice=0,TotPrice=TotPrice-15
where CoupNo in('RS000026140','RS000026141','RS000026142',
'RS000026143','RS000026144','RS000026145')

select Fuprice,* from Topway..tbTrainUser 
--update Topway..tbTrainUser  set Fuprice=0
where TrainTicketNo in (select ID from Topway..tbTrainTicketInfo
where CoupNo in('RS000026140','RS000026141','RS000026142',
'RS000026143','RS000026144','RS000026145'))

--ǩ֤���۵�
select Sales,* from Topway..tbTrvCoup 
--update Topway..tbTrvCoup set Sales='����'
where TrvCoupNo='97652'

--���ù�����������棬���� �Ĳ��õ�λ
select Cmpid UC,u.Name ��λ����,s.Name ���ù���
from homsomDB..Trv_UnitCompanies u 
left join homsomDB..Trv_TktUnitCompanies_TktTCs t on t.TktUnitCompanyID=u.ID
left join homsomDB..SSO_Users s on t.TktTCID=s.ID
where s.Name in ('�','����','����')
and CooperativeStatus in ('1','2','3')
and u.Type='a'
order by ���ù���

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno='AS002608059'

--���۵�
select totprice,t_amount,totsprice,totprofit,tottax,totdisct,* from Topway..tbFiveCoupInfo 
--update Topway..tbFiveCoupInfo  set totprice=100,t_amount=100,totsprice=4000,totprofit='-3900',tottax=0,totdisct=0
where coupno='AS002606993'


select tax,stax,* from Topway..tbcash 
--update Topway..tbcash  set stax=140
where coupno='AS002454564'

--�����տ��Ϣ
select Skstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Skstatus=2
where TrvId='30008' and Id='228577'

--�г̵�
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�����г̵�'
where coupno in('AS002525786','AS002525786','AS002527923','AS002527930')

--��λ���͡����㷽ʽ���˵���ʼ���ڡ������¡�ע����
select indate,InDateA,* from Topway..tbCompanyM 
--update Topway..tbCompanyM indate='2019-07-05'
where cmpid='020900'

select RegisterMonth,*  from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies  set RegisterMonth='07 05 2019 10:49AM'
where Cmpid='020900'

--�˵�����
select TrainBillStatus,HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set TrainBillStatus=1,HotelSubmitStatus=2
where BillNumber='020583_20190601'

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=13759 ,profit=profit+3
where coupno='AS002606135'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set TrainBillStatus=1,HotelSubmitStatus=3,SubmitState=1
where BillNumber='015828_20190426'

--��Ʊ¼����
select opername,* from Topway..tbReti 
--update Topway..tbReti  set opername='����Ƽ'
where reno in('0439613','0439627')
/*
���æ��ȡһ�ݻ�����Ӫ��-��֮�� �Ź㺮��2019��6�·���ɱ��ŵ�����EXECL������������¸��
1.��������
2.Ԥ�㵥��
3.��λ����
4.��Ӧ�̽�����Ϣ����Ӧ����Դ
5.�������
6.�ʽ����
*/

select t.OperDate ��������,t.ConventionId Ԥ�㵥��,u.Name ��λ����,GysSource ��Ӧ����Դ,Sales �������,FinancialCharges �ʽ����
from Topway..tbConventionCoup t
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=t.Cmpid
left join Topway..tbConventionJS tb on tb.ConventionId=t.ConventionId
where t.OperDate<'2019-07-01'
and t.OperDate>='2019-06-01'
and Sales in('��֮��','�Ź㺮')
order by ��������


SELECT * from Topway..tbcash where coupno='AS002610225'
--��23��AS002610608 
select * from Topway..tbFiveCoupInfosub
--update Topway..tbFiveCoupInfosub set MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='23',Department='��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��' 
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002610608')
--AS002610225  22��
select pcs ����,MobileList �ֻ��б�,CostCenter �ɱ�����,Department ����,* from Topway..tbFiveCoupInfosub
--update Topway..tbFiveCoupInfosub set MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='22',Department='��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��' 
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002610225')

/*
���æ��ȡ����2�ҹ�˾���ÿ�δ������������Ա������лл��
 
UC018773�������ڿعɼ������޹�˾
 
UC020410�����ҵ���޹�˾
*/
select 'UC018773' UC,Name,LastName+'/'+FirstName+MiddleName,Mobile
from homsomDB..Trv_Human 
where ID in(Select ID from homsomDB..Trv_UnitPersons
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies
where Cmpid='018773') and VettingTemplateID is null)
and IsDisplay=1

---���ڻ�Ʊ
select '020410' UC,h.Name ��������,LastName+'/'+FirstName+MiddleName Ӣ��,Mobile  �ֻ�����
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='020410' and IsDisplay=1 and isnull(cast(u.VettingTemplateID as varchar(40)),'')='' 

---���ʻ�Ʊ
select '018773' UC,h.Name ��������,LastName+'/'+FirstName+MiddleName Ӣ��,Mobile  �ֻ�����
 from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='018773' and IsDisplay=1 and isnull(cast(u.InternationalFlightVettingTemplateID as varchar(40)),'')='' 

---���ھƵ�
select '018773' UC,h.Name ��������,LastName+'/'+FirstName+MiddleName Ӣ��,Mobile  �ֻ�����
 from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='018773' and IsDisplay=1 and isnull(cast(u.HotelVettingTemplateID as varchar(40)),'')='' 

---���ʾƵ�
select '018773' UC,h.Name ��������,LastName+'/'+FirstName+MiddleName Ӣ��,Mobile  �ֻ�����
 from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='018773' and IsDisplay=1 and isnull(cast(u.InternationalHotelVettingTemplateID as varchar(40)),'')='' 

---��Ʊ
select '018773' UC,h.Name ��������,LastName+'/'+FirstName+MiddleName Ӣ��,Mobile  �ֻ�����
 from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='018773' and IsDisplay=1 and isnull(cast(u.TrainVettingTemplateID as varchar(40)),'')='' 

---��������
select '018773' UC,h.Name ��������,LastName+'/'+FirstName+MiddleName Ӣ��,Mobile  �ֻ�����
 from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='018773' and IsDisplay=1 and isnull(cast(u.CompanyTravelVettingTemplateID as varchar(40)),'')='' 

--�޸����ʱ��
Select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti  set ExamineDate='2019-07-01'
where reno='0439613'

---���ڻ�Ʊ
SELECT DISTINCT un.Cmpid UC,un.Name ��λ����,h.Name ��������,LastName+'/'+FirstName+MiddleName Ӣ��,Mobile  �ֻ�����
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
where Cmpid='020410' and IsDisplay=1 and isnull(cast(u.VettingTemplateID as varchar(40)),'')='' 
AND h.name NOT LIKE '%��ְ%'

--�����տ������ע
select oth2, * from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set oth2='���æ��ӱ�ע 6/28�й����У�3427��14800'
where TrvId='30237'