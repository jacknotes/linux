select coupno ���۵���,indate ��Ʊ����,begdate �������, route ����,ride ��˾����,totprice ���ۼ�,profit ����,sales ���ù���,e.team ����С��,
(case tickettype when '����Ʊ' then '' when '���ڷ�' then '���ڷ�' when '���շ�' then '���շ�' else '' end)  �Ƿ��и���,reti ��Ʊ����
,t_source ��Ӧ����Դ
from Topway..tbcash c
left join Topway..Emppwd e on e.empname=c.sales
where t_source='ƽ̨��ţD'
order by indate

select * from Topway..Emppwd

--�ؿ���ӡ
select pstatus,prdate,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set pstatus=0,prdate='1900-01-01'
where CoupNo='PTW080416'

--����ԭƱ��
select oldrecno,OldTicketNo,* from Topway..tbcash where coupno='AS002395621'

--��Ʊ�������
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti set ExamineDate='2019-04-17'
where reno='0432441'

--Ʊ��
update Topway..tbcash  set pasname = REPLACE(pasname,' ','') where coupno in('AS002406146','AS002406007')
--select pasname,tcode,ticketno,* from Topway..tbcash where coupno='AS002406146' and pasname='�� ��'
update Topway..tbcash set tcode='479',ticketno='2131679204' where pasname='�̳���' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679205' where pasname='�»Զ�' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679206' where pasname='���' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679207' where pasname='����' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679208' where pasname='������' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679209' where pasname='�˿�' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679210' where pasname='����' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679211' where pasname='������' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679212' where pasname='������' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679213' where pasname='ʩ����' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679214' where pasname='�ﾧ' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679215' where pasname='������' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679216' where pasname='����' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679217' where pasname='��һ��' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679218' where pasname='������' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679219' where pasname='���ľ�' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679220' where pasname='�ž�֥' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679221' where pasname='������' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679222' where pasname='���' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679223' where pasname='������' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679240' where pasname='�º�' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679241' where pasname='����' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679242' where pasname='����ƽ' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679243' where pasname='����' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679244' where pasname='�߲�' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679245' where pasname='����' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679246' where pasname='��˼��' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679247' where pasname='����Ȼ' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679248' where pasname='����' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679249' where pasname='������' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679250' where pasname='���' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679251' where pasname='������' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679252' where pasname='�' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679253' where pasname='��ӱ' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679254' where pasname='����' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679255' where pasname='Ф�Ǿ�' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679256' where pasname='������' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679257' where pasname='Ҧ��' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679258' where pasname='ҦС��' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679259' where pasname='��÷' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679260' where pasname='����' and coupno='AS002406146'


--select pasname,tcode,ticketno,* from Topway..tbcash where coupno='AS002406007'

update Topway..tbcash set tcode='479',ticketno='2131679261' where pasname='������' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679262' where pasname='����˳' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679263' where pasname='������' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679264' where pasname='����' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679265' where pasname='���Ʒ�' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679266' where pasname='���Ǭu' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679267' where pasname='����' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679268' where pasname='���' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679269' where pasname='����' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679270' where pasname='��ΰ��' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679271' where pasname='ʯ����' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679272' where pasname='ۢ׿��' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679273' where pasname='��־��' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679274' where pasname='������' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679275' where pasname='�����' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679276' where pasname='������' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679277' where pasname='ׯ���' and coupno='AS002406007'



select IsJoinRank,* from Topway..Emppwd 
--update Topway..Emppwd  set IsJoinRank=0
where idnumber='0709'

--��Ʊ�������
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti  set ExamineDate='2019-04-12'
where reno='0432508'
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti  set ExamineDate='2019-04-17'
where reno='0432507'

--2018��1��1���������й��ʻ�Ʊ��Ʊ��ϸ  
--���� ��Ʊ���� ������� ���� �۸�  ����� Ʊ�� �����ܼ� �����ܼ�
select cmpcode UC,pasname ����,indate ��Ʊ����,begdate �������,route ����,price ���۵���,ride+flightno �����,
tcode+ticketno Ʊ��,totprice �����ܼ�,totsprice �����ܼ�
from Topway..tbcash 
where inf=1
and cmpcode in('017692','017690','017691','017694','019767','019768','017693')
and datetime>='2018-01-01'
order by cmpcode

select ID from homsomDB..Trv_Cities where Code in ('BGG')
select ID from homsomDB..Trv_Cities where Code in ('GNI')
select ID from homsomDB..Trv_Cities where Code in ('JNS')
select ID from homsomDB..Trv_Cities where Code in ('AAD')
select ID from homsomDB..Trv_Cities where Code in ('SIC')
select ID from homsomDB..Trv_Cities where Code in ('KEW')
select ID from homsomDB..Trv_Cities where Code in ('KCK')
select ID from homsomDB..Trv_Cities where Code in ('NAH')
select ID from homsomDB..Trv_Cities where Code in ('ETE')
select ID from homsomDB..Trv_Cities where Code in ('SSS') --ɾ��
select ID from homsomDB..Trv_Cities where Code in ('BEM')
select ID from homsomDB..Trv_Cities where Code in ('CAT')
select * from homsomDB..Trv_Airport where CityID in(select ID from homsomDB..Trv_Cities where Code='SSS')


select * from homsomDB..Trv_Cities

select c.Code,a.Code,c.Name,a.Name,a.EnglishName, CountryCode from homsomDB..Trv_Cities c
left join homsomDB..Trv_Airport a on a.CityID=c.ID
where c.Code in ('BGG','GNI','JNS','AAD','SIC','KEW','KCK','NAH','ETE','BEM','CAT')


--ɾ���������
select * from homsomDB..Trv_Airport where CityID='C4376314-AB67-4159-A67C-D025E62A9DD7'
select * 
--delete
from homsomDB..Trv_Cities where Code='SSS'

--���ν��㵥��Ϣ
select * 
--delete
from Topway..tbTrvJS where TrvId='29892' and Id='144931'

select status,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set status=-2
where CoupNo='PTW080656'



--��������
select * 
--delete
from Topway..tbTrvCoup where TrvId='11563'

select Status,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Status='12'
where TrvId='11563'

--�޸�Ԥ�㵥��
--select * from Topway..tbTravelBudget where TrvId='29887'
select * from Topway..tbTrvJS 
--update Topway..tbTrvJS  set TrvId='29887'
where TrvId='11563' and Id in 
(select  trvYsId from Topway..tbcash where coupno in
('AS002395386','AS002395442','AS002395900','AS002395909','AS002395935','AS002395941'))




--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='��־ǿ',SpareTC='��־ǿ'
where coupno ='AS001760572'

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=4317,profit='-90'
where coupno='AS002407364'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=7102,profit='1545'
where coupno='AS002400172' and id='4290681'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=5763,profit='1495'
where coupno='AS002402361' 

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=5763,profit='1495'
where coupno='AS002403620' 

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=14119,profit='874'
where coupno='AS002399257' 

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=13629,profit='864'
where coupno='AS002399287' 

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=24333,profit='567'
where coupno='AS002402852' 

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=24333,profit='567'
where coupno='AS002402862' 

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=8499,profit='687'
where coupno='AS002406266' 

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=2154,profit='142'
where coupno='AS002408690' 


--��λ������·��������S�գ�98�۵ĵ�λ����
select distinct un.Cmpid UC,un.Name ��λ����,(100-f1.Discount)*0.01 �ۿ�,FlightEndDate  from homsomDB..Trv_FlightAdvancedPolicies f1
left join homsomDB..Trv_FlightAdvancedPolicyItems f2 on f2.FlightAdvancedPolicyID=f1.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=f1.UnitCompanyID
where f2.Cabin like '%S%'
and f1.Discount=2
order by FlightEndDate

