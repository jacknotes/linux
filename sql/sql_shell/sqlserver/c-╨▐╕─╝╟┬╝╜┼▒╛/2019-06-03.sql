--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='�����', SpareTC='�����'
where coupno='AS002517402'

--UC018110���ϲƲ����չɷ����޹�˾
--��Ʊ�˵���ƥ���¾��òո������
select coupno,CabinClass,ride,nclass from Topway..tbcash where coupno in ('AS002441744',
'AS002445242',
'AS002445245',
'AS002445256',
'AS002449462',
'AS002449521',
'AS002449545',
'AS002453320',
'AS002453320',
'AS002463672',
'AS002465169',
'AS002465169',
'AS002465169',
'AS002468499',
'AS002468650',
'AS002468650',
'AS002468846',
'AS002468846',
'AS002469487',
'AS002469602',
'AS002469602',
'AS002472309',
'AS002472508',
'AS002472514',
'AS002475792',
'AS002476177',
'AS002477024',
'AS002477051',
'AS002479411',
'AS002479421',
'AS002479421',
'AS002479423',
'AS002479423',
'AS002479776',
'AS002480009',
'AS002480009',
'AS002480054',
'AS002480054',
'AS002480495',
'AS002482183',
'AS002482185',
'AS002485776',
'AS002487583',
'AS002490271',
'AS002490878',
'AS002492022',
'AS002493167',
'AS002494334',
'AS002494554',
'AS002497064',
'AS002499212',
'AS002499582',
'AS002504895',
'AS002504895',
'AS002505939',
'AS002505941',
'AS002506179',
'AS002506457',
'AS002507678',
'AS002508526',
'AS002511533',
'AS002513859',
'AS002515701',
'AS002518639',
'AS002518670',
'AS001642025')

--���ս�λ
select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash set sprice1=2
where coupno in ('AS002478032','AS002478492')


--UC019847 2017.5-2018.8���ڵϰ��������չ�˾���ʼ����ڳ�Ʊ����
select convert(varchar(7),datetime,120) �·�,ride ��˾,route �г�,sum(totprice)����,COUNT(1)����,sum(fuprice) �ϼƷ����,sum(tax) �ϼ�˰��
from Topway..tbcash 
where cmpcode='019847'
--and datetime>='2017-05-01'
--and datetime<'2018-09-01'
and inf=0
group by ride,route,convert(varchar(7),datetime,120)
order by �·�

select convert(varchar(7),datetime,120) �·�,ride ��˾,route �г�,sum(totprice)����,COUNT(1)����,sum(fuprice) �ϼƷ����,sum(tax) �ϼ�˰��
from Topway..tbcash 
where cmpcode='019847'
--and datetime>='2017-05-01'
--and datetime<'2018-09-01'
and inf=1
group by ride,route,convert(varchar(7),datetime,120)
order by �·�

--ƥ��Ԥ���ˣ�����Ŀ�ĺ�reason code
select CoupNo,isnull(Purpose,''),isnull(ReasonDescription,''),h.Name from HotelOrderDB..HTL_Orders o
left join homsomDB..Trv_UnitPersons un on un.CustID=o.CustID
left join homsomDB..Trv_Human h on h.ID=un.ID
where CoupNo in ('PTW081681',
'PTW081971',
'PTW082030',
'PTW082121',
'PTW082251',
'PTW082367',
'PTW082449',
'PTW082448',
'PTW082447',
'PTW082439',
'PTW082539',
'PTW082600',
'PTW082659',
'PTW082640',
'PTW083552',
'PTW083551')

--�޸ĳ�Ʊ����
select datetime,indate,* from Topway..tbcash 
--update Topway..tbcash set datetime='2019-05-31',indate='2019-05-31 09:00:11.000'
where coupno='AS002519636'

--����Ʒר�ã��������Դ/�����Ϣ�����ʣ�
select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash  set feiyong=0,feiyonginfo=''
where coupno='AS002520665'

--����Ԥ�㵥��Ϣ
select StartDate,EndDate,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set StartDate='2019-06-22',EndDate='2019-06-22'
where TrvId='30122'

--UC019505��λ����
select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement set CompanyNameCN='�Ϻ����ҵ���Źɷ����޹�˾'
where BillNumber='019505_20190601'

--UC017122�Ϻ�˼��������Ϣ�������޹�˾,�鷳������˾��ģģ���ṩ�ͻ��������������
select convert(varchar(7),[datetime],120) ��Ʊ�·�,convert(varchar(10),datetime,120) ��Ʊ����,begdate �������,coupno ���۵���,pasname �˻���,route �г�,ride+flightno �����,tcode+ticketno Ʊ��,priceinfo ȫ��,price/priceinfo �ۿ���,
price ���۵���,tax ˰��,fuprice �����,totprice ���ۼ�,reti ��Ʊ����
from Topway..tbcash
where cmpcode='017122' 
and inf<>-1
order by ��Ʊ�·�

--�޸ĺ������ںͱ�ע
select dzhxDate,oth2,* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='2019-05-31',oth2='5/31 ��ת �ý�27397�ֳ�'
where coupno='AS002371150'

select dzhxDate,oth2,* from Topway..tbcash 
--update Topway..tbcash set dzhxDate='2019-05-31',oth2='5/31 ��ת �ý�27397�ֳ�'
where coupno='AS002371147'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='020852_20190501'

--���ս�λ
select sprice1,totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set sprice1='2.8',totsprice='2.8',profit=17
where coupno in ('AS002487231','AS002487364','AS002492794','AS002494194','AS002494195')

select sprice1,totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set sprice1='3.9',totsprice='3.9',profit=profit-1
where coupno in ('AS002510341','AS002510834','AS002510839','AS002511395','AS002512383','AS002512384',
'AS002512452','AS002512606','AS002513410','AS002513450','AS002513451','AS002514161','AS002515011','AS002515902',
'AS002516461','AS002517025','AS002518023','AS002518024','AS002518025','AS002518026','AS002518449','AS002518450',
'AS002519356')

select sprice1,totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set sprice1='4.2',totsprice='4.2'
where coupno in ('AS002490391','AS002491548')

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002517411','AS002519959')

select sprice1,totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set sprice1=20,totsprice=20,profit='-20'
where coupno='AS000000000' and ticketno='9578489449'

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002517939')

--����Ԥ�㵥��Ϣ
select * from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Custid='D694071',Custinfo='15618509822@Ԭ����@016428@��������ɹ������ʣ����޹�˾�Ϻ�����@Ԭ����@15618509822@D694071',
where TrvId='30005'

--����Ԥ�㵥ȡ��
select Status,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudge set Status=2
where TrvId='30194'


--���۵��ţ�AS002510879���к�����ԭ���Ϻ�����-�ൺ-�Ϻ����ţ� �޸�Ϊ���Ϻ��ֶ�-�ൺ-�Ϻ��ֶ��� ���۵��ţ�AS002510829���к�����ԭ���Ϻ�����-�ൺ-�Ϻ����ţ� �޸�Ϊ���Ϻ��ֶ�-�ൺ-�Ϻ��ֶ�
select * from Topway..tbcash 
--update Topway..tbcash  set route='�Ϻ��ֶ�-�ൺ-�Ϻ��ֶ�'
where coupno in('AS002510879','AS002510829')

select * from homsomDB..Trv_DomesticTicketRecord 
--update homsomDB..Trv_DomesticTicketRecord  set Route='�Ϻ��ֶ�-�ൺ-�Ϻ��ֶ�'
where RecordNumber in('AS002510879','AS002510829')

select *from homsomDB..Trv_Airport where Name like '%�ֶ�%'

select OriginName,* from homsomDB..Trv_ItktBookingSegs 
--update homsomDB..Trv_ItktBookingSegs  set OriginName='�ֶ����ʻ���',DepartingAirport='PVG',Origin='PVG'
where ItktBookingID='5BC7873C-5FF8-4347-BECA-DAAD76BA6A28' 
and [Order]=1

select * from homsomDB..Trv_ItktBookingSegs 
--update homsomDB..Trv_ItktBookingSegs  set DestinationName='�ֶ����ʻ���',ArrivalAirport='PVG',Destination='PVG'
where ItktBookingID='5BC7873C-5FF8-4347-BECA-DAAD76BA6A28' 
and [Order]=2

--�Ƶ����۵�
--�Ƶ����۵� �����ܼ� �����Ϊ251 �����������Ϊ251 
select price,sprice,totprofit,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set price='251',sprice='251',totprofit='251'
where CoupNo='PTW083768'

select totprice,owe,* from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set totprice='251',owe='251'
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo='PTW083768')

select TotalPrice,* from HotelOrderDB..HTL_Orders 
--update HotelOrderDB..HTL_Orders set TotalPrice='251'
where CoupNo='PTW083768'


--���۵��ţ�PTW083759 �����ܼ� �����Ϊ-2432 �����ܼ������Ϊ-1899.05 �������������Ϊ-303 
select price,sprice,totprofit,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set price='-2432',sprice='-1899.05',totprofit='-303'
where CoupNo='PTW083759'

select totprice,owe,* from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set totprice='-2432',owe='-2432'
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo='PTW083759')

select TotalPrice,* from HotelOrderDB..HTL_Orders 
--update HotelOrderDB..HTL_Orders set TotalPrice='-2432'
where CoupNo='PTW083759'


--��Ʊ����:2019��3��-4��,��Ʊ���������2019��5�µ�ֱ����Ʊ����
--С�� ���ù��� Ʊ�� ��Ʊ���� ��Ʊ���� �������

select team,SpareTC,c.tcode+c.ticketno,reno,c.datetime,ExamineDate from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join Topway..tbReti t on t.reno=c.reti
left join Topway..Emppwd e on SpareTC=e.empname
where c.datetime>='2019-03-01' and c.datetime<'2019-05-01'
and t.ExamineDate>='2019-05-01' and t.ExamineDate<'2019-06-01'
and TicketOperationRemark like '%ֱ��%'
order by c.datetime