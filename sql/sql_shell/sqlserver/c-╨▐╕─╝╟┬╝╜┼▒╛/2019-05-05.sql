--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='����',SpareTC='����'
where coupno='AS002440119'

select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='����',SpareTC='����'
where coupno='AS002440116'

--����Ʒ��ר�ã���Ʊ��Ӧ����Դ�����ڣ�
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSEPETD'
where coupno='AS002440880'

--��Ʊ��Ʊ���
select * from Topway..tbTrainTicketInfo where  CoupNo='RS000022379'

select top 100 SupplierFee,* from Topway..Train_ReturnTicket where TickOrderID='22379'

select  ReturnTicketID,* from Topway..tbTrainUser where TrainTicketNo in(select ID from Topway..tbTrainTicketInfo where CoupNo='RS000022379')

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='�����',SpareTC='�����'
where coupno='AS001625457'

select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='������',SpareTC='������'
where coupno='AS001605182'

--�Ƶ�REASON CODE��Ԥ���ˣ�����Ŀ��

select  h.CoupNo as ���۵���,Purpose as ����Ŀ��,hu.Name,ReasonDescription   FROM [HotelOrderDB].[dbo].[HTL_Orders] h
left join Topway..tbHtlcoupYf t on t.CoupNo=h.CoupNo
left join homsomDB..Trv_UnitPersons u on u.CustID=h.CustID
left join homsomDB..Trv_Human hu on hu.ID=u.ID
where h.CoupNo in ('-PTW078447',
'PTW079013',
'PTW079333',
'PTW079332',
'PTW079894',
'PTW080630',
'PTW080755',
'PTW080863',
'PTW080955',
'PTW080954',
'PTW081050',
'PTW081121',
'PTW081365',
'PTW081476')

--020637 ����2����Ҫɾ�����������ÿͶ�ɾ��

select IsDisplay,* from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons where
CompanyID=(Select ID from homsomDB..Trv_UnitCompanies where
Cmpid='020637'))
and IsDisplay=1
and Mobile not in ('13840858603','15542590120')

--�г̵�������Ʊ��
select info3,* from  Topway..tbcash 
--update Topway..tbcash set info3='���ӡ�г̵�'
where coupno in('AS002354749','AS002354836','AS002344456','AS002344483')

--�鷳UC018110���ϲƲ����չɷ����޹�˾
 
--��Ʊ�˵���ƥ���¾��òո������
select c.coupno,i3.cabintype from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where coupno in('AS002362017',
'AS002363013',
'AS002366062',
'AS002368561',
'AS002368561',
'AS002368561',
'AS002369651',
'AS002376408',
'AS002377214',
'AS002378966',
'AS002381464',
'AS002381464',
'AS002382437',
'AS002384718',
'AS002384949',
'AS002385155',
'AS002387823',
'AS002389359',
'AS002392817',
'AS002396390',
'AS002396992',
'AS002397373',
'AS002397375',
'AS002399452',
'AS002402064',
'AS002402066',
'AS002416064',
'AS002420172',
'AS002421635',
'AS002424895',
'AS002426822',
'AS002426822',
'AS002427060',
'AS002427060',
'AS002427090',
'AS002427090',
'AS002427979',
'AS002431458',
'AS002431983',
'AS002438120',
'AS002439684')

--�˵�����
select HotelSubmitStatus, * from Topway..AccountStatement 
--update Topway..AccountStatement  set HotelSubmitStatus=2
where BillNumber='019848_20190401'

--�˵�ƥ�䱸ע
select coupno,tcmemo from Topway..tbcash 
where coupno in('AS002361953',
'AS002361969',
'AS002364808',
'AS002364808',
'AS002364865',
'AS002364911',
'AS002364911',
'AS002365320',
'AS002365329',
'AS002367103',
'AS002367107',
'AS002367443',
'AS002367453',
'AS002367453',
'AS002367457',
'AS002367461',
'AS002370573',
'AS002370573',
'AS002370592',
'AS002370666',
'AS002372186',
'AS002372186',
'AS002381837',
'AS002389865',
'AS002390885',
'AS002390885',
'AS002393520',
'AS002393574',
'AS002393605',
'AS002393605',
'AS002393755',
'AS002394083',
'AS002394220',
'AS002395669',
'AS002395784',
'AS002397287',
'AS002397947',
'AS002399809',
'AS002399946',
'AS002401376',
'AS002401474',
'AS002407880',
'AS002410048',
'AS002413520',
'AS002418438',
'AS002418482',
'AS002423806',
'AS002425542',
'AS002426066',
'AS002426072',
'AS002427295',
'AS002427298',
'AS002427481',
'AS002427485',
'AS002429198',
'AS002430746',
'AS002430754',
'AS002432123',
'AS002432476',
'AS002435651',
'AS002437670',
'AS002440894')
and tcmemo<>''
and tcmemo!='|'

select CoupNo,comment from Topway..tbHtlcoupYf 
where CoupNo in('PTW079236',
'PTW079918',
'PTW080038',
'PTW080059',
'PTW080095',
'PTW080164',
'PTW080317',
'PTW080344',
'PTW080595',
'-PTW080595',
'PTW081118',
'PTW081117',
'PTW081219',
'PTW081253',
'PTW081323')

--�˵�����
select HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement set HotelSubmitStatus=2
where BillNumber='019014_20190401'

--UC017376�Ϻ������Ƽ������ɷ����޹�˾ �޸��˵�̧ͷ
select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement  set CompanyNameCN='�Ϻ������Ƽ������ɷ����޹�˾'
where BillNumber='017376_20190501'

select * from Topway..T_HolidayDate

--�޸ı���ʱ�� ���뽫�������ڴ�5��5���޸�Ϊ4��30��
select OperDate,* from Topway..tbTrvCoup 
--update Topway..tbTrvCoup set OperDate='2019-04-30'
where TrvId='29641'

select ModifyDate,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set ModifyDate='2019-04-30'
where TrvId='29641'

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='������',SpareTC='������'
where coupno ='AS001604024'

--UC020637��ղ���

--ɾ����Ա���Ű�
select CompanyDptId,* from homsomDB..Trv_UnitPersons 
--update homsomDB..Trv_UnitPersons set CompanyDptId=null
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='020637')

--ɾ������
select * 
--delete
from homsomDB..Trv_CompanyStructure 
where CompanyId='18B4C1BD-30F1-481B-8AD7-A98A00C1EB03'


--�޸�UC�ţ���Ʊ��

select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,pform,xfprice,* from Topway..tbcash
--update topway..tbcash set cmpcode='016751',OriginalBillNumber='016751_20190401',ModifyBillNumber='016751_20190401',custid='D569587'
 where coupno in ('AS002412493')
 
 select CustId,CmpId,Cmpname,* from Topway..tbFiveCoupInfo 
  --update Topway..tbFiveCoupInfo set CustId='D569587',CmpId='016751',Cmpname='���ˣ��Ϻ����Ļ������ɷ����޹�˾'
  where CoupNo in ('AS002412493')
  
 /*�޸�UC�ţ�TMS)
 SELECT T2.CoupNo,T1.OrderNo,*
  FROM homsomDB..Intl_BookingOrders T1
  INNER JOIN Topway..tbFiveCoupInfo T2 ON T1.Id=T2.OrderId
  where Id in(select OrderId from Topway..tbFiveCoupInfo where CoupNo  in ('AS002412493'))*/
  
   --�޸�UC�ţ�TMS)
  select CmpId,CompanyName,CustId,* from homsomDB..Intl_BookingOrders 
  --update homsomDB..Intl_BookingOrders set CmpId='016751',CustId='D569587',CompanyName='���ˣ��Ϻ����Ļ������ɷ����޹�˾'
  where OrderNo in ('IF00031938')
  
  --����۲��
  select totsprice,profit,* from Topway..tbcash 
  --update Topway..tbcash set totsprice='4749',profit=278
  where coupno='AS002441050'
  
--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='019061_20190401'

--��˾
insert into ehomsom..tbInfAirCompany (airname,sx1,sx,code2,http,ntype,modifyDate,enairname,IsDeleted,sortNo,phone1,phone2,introinf)
values ('¬���ﺽ��','¬���ﺽ��','¬���ﺽ��','WB','','1','2019-05-05','RwandAir',NULL,'1',NULL,NULL,NULL)

--ƥ�����Ŀ��
select CoupNo,Purpose from HotelOrderDB..HTL_Orders
where CoupNo in('PTW079145',
'PTW079229',
'PTW079230',
'PTW079228',
'PTW079184',
'PTW079249',
'PTW079256',
'PTW079287',
'PTW079409',
'PTW079549',
'PTW079781',
'PTW080837',
'PTW081272',
'PTW081271',
'PTW081221',
'PTW081434',
'-PTW081434')