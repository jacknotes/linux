--�ܷ���һ��UC020432�����ܹ�ѧ������homsomDB..trv_human��topway..tbcusthoderM�д��ڲ���ĳ��ÿ�����

if OBJECT_ID('tempdb..#hom')is not null drop table #hom
SELECT CustID,cr.CredentialNo,h.Mobile 
into #hom
FROM homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
LEFT join homsomDB..Trv_Credentials cr on cr.HumanID=h.ID
where Cmpid='020432' and IsDisplay=1

if OBJECT_ID('tempdb..#top') is not null drop table #top
select custid,idno,mobilephone 
into #top
from Topway..tbCusholderM 
where EmployeeStatus<>0 and cmpid='020432'

select h.custid homsomdbID,isnull(h.CredentialNo,'') homsomdb֤��,h.Mobile homsomdb�ֻ�,isnull(t.custid,'') topwayID ,
isnull(idno,'')topway֤��,isnull(mobilephone,'')topway�ֻ�
from #hom h 
left join #top t on t.custid=h.custid
order by homsomdbID


--��Ʊ������
SELECT t1.RecordNumber,t5.Name 
FROM homsomDB..Trv_DomesticTicketRecord t1
left join homsomDB..Trv_PnrInfos t2 on t2.ID=t1.PnrInfoID
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t2.ItktBookingID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='����'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.RecordNumber in 
('AS002421018',
'AS002421026',
'AS002421045',
'AS002421095',
'AS002423071',
'AS002423927',
'AS002423971',
'AS002424331',
'AS002424698',
'AS002426031',
'AS002426918',
'AS002427391',
'AS002427442',
'AS002427444',
'AS002427620',
'AS002427926',
'AS002428409',
'AS002428444',
'AS002429073',
'AS002429466',
'AS002429957',
'AS002429985',
'AS002430576',
'AS002439830',
'AS002439832',
'AS002441254',
'AS002441256',
'AS002441593',
'AS002441926',
'AS002449164',
'AS002449165',
'AS002449183',
'AS002449184',
'AS002449185',
'AS002452676',
'AS002452678',
'AS002455663',
'AS002455851',
'AS002455959',
'AS002455976',
'AS002456255',
'AS002456260',
'AS002456315',
'AS002456317',
'AS002456321',
'AS002456329',
'AS002456331',
'AS002456333',
'AS002456337',
'AS002456341',
'AS002456348',
'AS002456358',
'AS002456360',
'AS002456362',
'AS002457589',
'AS002458389',
'AS002458393',
'AS002458730',
'AS002459782',
'AS002459888',
'AS002460012',
'AS002460779',
'AS002460781',
'AS002460785',
'AS002460787',
'AS002460791',
'AS002460793',
'AS002460795',
'AS002460803',
'AS002460812',
'AS002461218',
'AS002462006',
'AS002462171',
'AS002462425',
'AS002462428',
'AS002462435',
'AS002462871',
'AS002466273',
'AS002470640',
'AS002470733',
'AS002471009',
'AS002474967',
'AS002477398',
'AS002477791',
'AS002480270',
'AS002482406',
'AS002482633',
'AS002483330',
'AS002485130',
'AS002485223',
'AS002487916') and NodeType=110 and NodeID=111

--һ�� NodeType=110 and NodeID=110
--���� NodeType=110 and NodeID=111

--��˾���ռ�Y��2018���ͳ�Ʒ���
--������
select ride,SUM(totprice)����,SUM(profit)-sum(Mcost)����,COUNT(1)����
from Topway..tbcash 
where inf=0
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and tickettype='����Ʊ'
group by ride
order by ���� desc

--Y��
select ride,SUM(totprice)����,SUM(profit)-sum(Mcost)����,COUNT(1)����
from Topway..tbcash 
where inf=0
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and tickettype='����Ʊ'
and nclass='Y'
group by ride
order by ���� desc


select ride  ��˾,SUM(c.totprice) ����,SUM(c.profit)-sum(Mcost) ����,COUNT(1) ����
from Topway..tbcash c with (nolock)
inner join ehomsom..tbInfCabincode t on t.cabin=c.nclass and t.code2=c.ride
and datetime>=t.begdate and datetime<=t.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or 
(c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) or 
(c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or 
(c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=0
and tickettype='����Ʊ'
and (t.cabintype like'%ͷ��%' or t.cabintype like'%����%')
group by ride
order by ���� desc


/*
   1��ҵ�����ͣ�����
     2�������˼���λ��������
     3����Ӧ����Դ������
     4����Ʊ���ڣ�2018��1��1��-2018��12��31��
     5���۳���Ʊ
*/
--CA
select (case  when nclass in ('F','A') then 'ͷ�Ȳ�' when nclass in ('J','C','D','Z','R') then '�����' when nclass in ('G','E') then '������' else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='ca'
group by (case  when nclass in ('F','A') then 'ͷ�Ȳ�' when nclass in ('J','C','D','Z','R') then '�����' 
when nclass in ('G','E') then '������' else '���ò�' end)
order by ���� desc

--MU
select (case  when nclass in ('P','F','A') then 'ͷ�Ȳ�' when nclass in ('U','J','C','D','Q','I')  then '�����' when nclass in ('W') then '������' else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='MU'
group by (case  when nclass in ('P','F','A') then 'ͷ�Ȳ�' when nclass in ('U','J','C','D','Q','I')  then '�����' when nclass in ('W') 
then '������' else '���ò�' end)
order by ���� desc

--FM
select (case  when nclass in ('P','F','A') then 'ͷ�Ȳ�' when nclass in ('U','J','C','D','Q','I')  then '�����' when nclass in ('W') then '������' else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='FM'
group by (case  when nclass in ('P','F','A') then 'ͷ�Ȳ�' when nclass in ('U','J','C','D','Q','I')  then '�����' when nclass in ('W') 
then '������' else '���ò�' end)
order by ���� desc

--CZ
select (case  when nclass in ('F','A') then 'ͷ�Ȳ�' when nclass in ('J','D','R','I')  then '�����' when nclass in ('W','P') then '������' else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='CZ'
group by (case  when nclass in ('F','A') then 'ͷ�Ȳ�' when nclass in ('J','D','R','I')  then '�����' when nclass in ('W','P') then '������' else '���ò�' end)
order by ���� desc

--hu
select (case   when nclass in ('C','D','Z','I')  then '�����'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='hu'
group by (case   when nclass in ('C','D','Z','I')  then '�����'  else '���ò�' end)
order by ���� desc

--ho
select (case  when nclass in ('F') then 'ͷ�Ȳ�' when nclass in ('C','J','D','R','I')  then '�����'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='ho'
group by (case  when nclass in ('F') then 'ͷ�Ȳ�' when nclass in ('C','J','D','R','I')  then '�����'  else '���ò�' end)
order by ���� desc

--AF
select (case  when nclass in ('P','F') then 'ͷ�Ȳ�' when nclass in ('J','C','D','I','Z','O')  then '�����' when nclass in ('W','S','A') then '������' else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='AF'
group by (case  when nclass in ('P','F') then 'ͷ�Ȳ�' when nclass in ('J','C','D','I','Z','O')  then '�����' when nclass in ('W','S','A') then '������' else '���ò�' end)
order by ���� desc

--AA
select (case   when nclass in ('J','D','R','I') then '�����' when nclass in ('W','P') then '������' else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='AA'
group by (case   when nclass in ('J','D','R','I') then '�����' when nclass in ('W','P') then '������' else '���ò�' end)
order by ���� desc

--AY
select (case   when nclass in ('J','D','R','I') then '�����'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='AY'
group by (case   when nclass in ('J','D','R','I') then '�����' else '���ò�' end)
order by ���� desc

--AC
select (case   when nclass in ('J','C','D','Z','P') then '�����' when nclass in ('O','E','N') then '������'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='AC'
group by (case   when nclass in ('J','C','D','Z','P') then '�����' when nclass in ('O','E','N') then '������'  else '���ò�' end)
order by ���� desc

--BA
select (case when nclass in ('F','A') then 'ͷ�Ȳ�'  when nclass in ('J','C','D','R','I') then '�����' when nclass in ('W','E','T') then '������'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='BA'
group by (case when nclass in ('F','A') then 'ͷ�Ȳ�'  when nclass in ('J','C','D','R','I') then '�����' when nclass in ('W','E','T') then '������'  else '���ò�' end)
order by ���� desc


--BR
select (case  when nclass in ('J','C','D') then '�����' when nclass in ('K','L','T','P') then '������'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='BR'
group by (case  when nclass in ('J','C','D') then '�����' when nclass in ('K','L','T','P') then '������'  else '���ò�' end)
order by ���� desc

--CI
select (case  when nclass in ('J','C','D') then '�����' when nclass in ('W','U','A','E') then '������'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='CI'
group by (case  when nclass in ('J','C','D') then '�����' when nclass in ('W','U','A','E') then '������'  else '���ò�' end)
order by ���� desc

--CX
select (case when nclass in ('F') then 'ͷ�Ȳ�' when nclass in ('J','C','D','I') then '�����' when nclass in ('W','R','E') then '������'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='CX'
group by (case when nclass in ('F') then 'ͷ�Ȳ�' when nclass in ('J','C','D','I') then '�����' when nclass in ('W','R','E') then '������'  else '���ò�' end)
order by ���� desc

--DL
select (case  when nclass in ('J','C','D','I','Z') then '�����' when nclass in ('P','A','G') then '������'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='DL'
group by (case  when nclass in ('J','C','D','I','Z') then '�����' when nclass in ('P','A','G') then '������'  else '���ò�' end)
order by ���� desc

--EK
select (case when nclass in ('F','A') then 'ͷ�Ȳ�' when nclass in ('J','C','O','I') then '�����'   else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='EK'
group by (case when nclass in ('F','A') then 'ͷ�Ȳ�' when nclass in ('J','C','O','I') then '�����'   else '���ò�' end)
order by ���� desc

--JL
select (case  when nclass in ('D','C','X','I') then '�����'   else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='JL'
group by (case  when nclass in ('D','C','X','I') then '�����'   else '���ò�' end)
order by ���� desc

--KA
select (case when nclass in ('F') then 'ͷ�Ȳ�' when nclass in ('D','C','J','I') then '�����'  when nclass in ('W','R','E') then '������'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='KA'
group by (case when nclass in ('F') then 'ͷ�Ȳ�' when nclass in ('D','C','J','I') then '�����'  when nclass in ('W','R','E') then '������'  else '���ò�' end)
order by ���� desc

--KE
select (case when nclass in ('F','P') then 'ͷ�Ȳ�' when nclass in ('D','C','J','I') then '�����'    else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='KE'
group by (case when nclass in ('F','P') then 'ͷ�Ȳ�' when nclass in ('D','C','J','I') then '�����'    else '���ò�' end)
order by ���� desc

--KL
select (case  when nclass in ('D','C','J','I','Z','O') then '�����'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='KL'
group by (case  when nclass in ('D','C','J','I','Z','O') then '�����'   else '���ò�' end)
order by ���� desc

--LH
select (case when nclass in ('F','A') then 'ͷ�Ȳ�'  when nclass in ('D','C','J','Z','P') then '�����' when nclass in ('G','E','N') then '������' else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='LH'
group by (case when nclass in ('F','A') then 'ͷ�Ȳ�'  when nclass in ('D','C','J','Z','P') then '�����' when nclass in ('G','E','N') then '������' else '���ò�' end)
order by ���� desc

--NH
select (case   when nclass in ('D','G','Z','P') then '�����'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='NH'
group by (case   when nclass in ('D','G','Z','P') then '�����'  else '���ò�' end)
order by ���� desc

--OZ
select (case when nclass in ('F','A') then 'ͷ�Ȳ�'  when nclass in ('D','J','Z','C','U') then '�����'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='OZ'
group by (case when nclass in ('F','A') then 'ͷ�Ȳ�'  when nclass in ('D','J','Z','C','U') then '�����'  else '���ò�' end)
order by ���� desc

--TK
select (case   when nclass in ('D','J','Z','C','K') then '�����'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='TK'
group by (case   when nclass in ('D','J','Z','C','K') then '�����'  else '���ò�' end)
order by ���� desc

--TG
select (case   when nclass in ('D','J','C') then '�����'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='TG'
group by (case   when nclass in ('D','J','C') then '�����'  else '���ò�' end)
order by ���� desc


--SQ
select (case  when nclass in ('F','A') then 'ͷ�Ȳ�' when nclass in ('D','J','C','Z','U') then '�����' when nclass in ('S','T','P','R') then '������'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='SQ'
group by (case  when nclass in ('F','A') then 'ͷ�Ȳ�' when nclass in ('D','J','C','Z','U') then '�����' when nclass in ('S','T','P','R') then '������'  else '���ò�' end)
order by ���� desc

--SU
select (case   when nclass in ('D','J','C','Z','I') then '�����' when nclass in ('S','W','A') then '������'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='SU'
group by (case   when nclass in ('D','J','C','Z','I') then '�����' when nclass in ('S','W','A') then '������'  else '���ò�' end)
order by ���� desc

--UA
select (case   when nclass in ('D','J','C','Z','P') then '�����' when nclass in ('O','R','A') then '������'  else '���ò�' end) ��λ,
COUNT(1)����,SUM(totprice)����,SUM(profit)����,SUM(Mcost)�ʽ���� 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='UA'
group by (case   when nclass in ('D','J','C','Z','P') then '�����' when nclass in ('O','R','A') then '������'  else '���ò�' end)
order by ���� desc

--�������۵���ƥ��Ԥ���ˣ�����Ŀ�ģ�REASONXCODE

select o.CoupNo,h.Name,isnull(Purpose,'')����Ŀ��,isnull(ReasonDescription,'')REASONXCODE
from HotelOrderDB..HTL_Orders o
left join Topway..tbHtlcoupYf y on y.CoupNo=o.CoupNo
left join homsomDB..Trv_UnitPersons u on u.CustID=y.custid
left join homsomDB..Trv_Human h on h.ID=u.ID
where o.CoupNo in('PTW081681',
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
'PTW082659',
'PTW082640')

--����Ԥ�㵥
select TrvId Ԥ�㵥��,SUM(YujPrice) Ԥ�Ƽ۸����� FROM Topway..tbTravelBudget 
where OperDate>='2018-01-01'
and OperDate<'2019-05-01'
--and  having SUM(YujPrice)>1000000
 group by TrvId
 order by Ԥ�Ƽ۸����� desc
 
 --��Ʊ��
 select * from Topway..tbcash 
 --update Topway..tbcash  set tcode='205',ticketno='2412644415'
 where coupno='AS002327279'
 
 --�г̵�������Ʊ��
 select info3,* from Topway..tbcash 
 --update Topway..tbcash set info3='���ӡ�г̵�'
 where coupno='AS002408952'
 
  select info3,* from Topway..tbcash 
 --update Topway..tbcash set info3='���ӡ�г̵�'
 where coupno in('AS002452095','AS002478435','AS002453772','AS002453778')
 
 --��Ʊ���ۼ���Ϣ
 select TotPrice,TotFuprice,TotPrintPrice,* from Topway..tbTrainTicketInfo 
 --update Topway..tbTrainTicketInfo  set TotPrice='58.50',TotFuprice=0,TotPrintPrice=0
 where CoupNo='RS000023812'
 
 select Fuprice,PrintPrice,* from Topway..tbTrainUser 
 --update Topway..tbTrainUser set Fuprice=0,PrintPrice=0
 where TrainTicketNo=(Select ID from Topway..tbTrainTicketInfo where CoupNo='RS000023812')
 
 --�����˸ĳ�δ����
 select state,* from Topway..FinanceERP_ClientBankRealIncomeDetail 
 --update Topway..FinanceERP_ClientBankRealIncomeDetail set state=5
 where money='264601' and date='2019-05-21'
 
 select  Payee, * from Topway..AccountStatementItem 
 --update Topway..AccountStatementItem set Payee=''
 where FinanceERP_ClientBankRealIncomeDetail_id='4877F1E4-8EB8-44B1-B0D5-CA6DA3AA6A20'
 
 select * from Topway..AccountStatement
 update Topway..AccountStatement set SX_TotalCreditLine='50000' where BillNumber='000006_20190501'