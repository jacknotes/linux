--UC020758�Ͳ�ҽҩ�Ӻ�˳������ߵĻ�Ʊ��������뾭�òգ���ϸ����������һ�·��ñȽϺͷ��������������ո�Ϊ���òգ����ÿ��Խ�ʡ����

select coupno,datetime,route,c.begdate,t.cabintype,tickettype,ride,nclass,totprice
from Topway..tbcash c with (nolock)
left join ehomsom..tbInfCabincode t on t.cabin=c.nclass and t.code2=c.ride
and [datetime]>=t.begdate and [datetime]<=t.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or
(c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) or 
(c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or 
(c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where  cmpcode='020758'
and isnull(cabintype,'')=''
order by datetime



--�г̵�
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='���ӡ�г̵�'
where coupno='AS002495360'

select * from Topway..tbFiveCoupInfo where CoupNo='AS002504121'

select convert(varchar(10),HolidayDate,120) ����, case when HolidayName like'%����%' then '3' else '4' end ��������,HolidayName �ڼ����� from Topway..T_HolidayDate
where HolidayDate>='2019-05-01'
order by ����

--�޸ĳ�Ʊ״̬
select status,* from Topway..tbFiveCoupInfo where CoupNo='AS002504121'

--�޸���Ʊ�������
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti set ExamineDate='2019-05-06'
where reno='9267033'

--�ؿ���ӡ
select Prdate,Pstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Prdate='1900-01-01',Pstatus=0
where TrvId='29805'

--����Ʒר�ã��������Դ/�����Ϣ
select feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash set feiyonginfo='������λZYI'
where coupno='AS002496616'

select feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash set feiyonginfo='������λZYI'
where coupno='AS002493359'

--�޸ĵ�λע����
select indate,* from Topway..tbCompanyM 
--update  Topway..tbCompanyM set indate='2019-05-27'
where cmpid='019707'

select RegisterMonth,* from homsomDB..Trv_UnitCompanies 
update homsomDB..Trv_UnitCompanies  set RegisterMonth='05 27 2019 10:36AM'
where Cmpid='019707'

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set  totsprice=11269,profit=2277
where coupno='AS002500136'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set  totsprice=7967,profit='-1'
where coupno='AS002496127'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set  totsprice=8731,profit='966'
where coupno='AS002500775'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='019658_20190301'

--����Ʒ��ר�ã���Ʊ��Ӧ����Դ
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='�渶������I'
where coupno='AS002501509'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='�渶��ʱ���ÿ�I'
where coupno='AS002501508'


--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set  sales='������',SpareTC='������'
where coupno='AS001655480'

select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set  sales='������',SpareTC='������'
where coupno='AS001661426'





