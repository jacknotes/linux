
--�޸�Ʊ��
--select pasname,tcode,ticketno,* from Topway..tbcash where coupno='AS002461536'
--update Topway..tbcash set pasname='',tcode='',ticketno='' where coupno='AS002461536' and pasname=''
update Topway..tbcash set pasname='DING/Xiaoxun',tcode='131',ticketno='2133377148' where coupno='AS002461536' and ID='4330766'
update Topway..tbcash set pasname='LIU/Zhongxing',tcode='131',ticketno='2133377149' where coupno='AS002461536' and ID='4330767'
update Topway..tbcash set pasname='ZHANG/Guoliang',tcode='131',ticketno='2133377150' where coupno='AS002461536' and ID='4330768'
update Topway..tbcash set pasname='WEN/Yongqiang',tcode='131',ticketno='2133377151' where coupno='AS002461536' and ID='4330769'
update Topway..tbcash set pasname='JIN/Jianchun',tcode='131',ticketno='2133377152' where coupno='AS002461536' and ID='4330770'
update Topway..tbcash set pasname='MAO/Yongfei',tcode='131',ticketno='2133377153' where coupno='AS002461536' and ID='4330771'
update Topway..tbcash set pasname='WANG/Yaming',tcode='131',ticketno='2133377154' where coupno='AS002461536' and ID='4330772'
update Topway..tbcash set pasname='QIN/Zhichao',tcode='131',ticketno='2133377155' where coupno='AS002461536' and ID='4330773'
update Topway..tbcash set pasname='GONG/Wenhui',tcode='131',ticketno='2133377156' where coupno='AS002461536' and ID='4330774'
update Topway..tbcash set pasname='ZHAI/Gang',tcode='131',ticketno='2133377157' where coupno='AS002461536' and ID='4330775'
update Topway..tbcash set pasname='WU/Yujun',tcode='131',ticketno='2133377158' where coupno='AS002461536' and ID='4330776'


select pasname,* from Topway..tbcash where coupno='AS002471471' and pasname='CAO/HAILUN'
select status,* from Topway..tbFiveCoupInfo where CoupNo='AS002471471'
select * from  tbFiveCoupInfosub where FkfiveNo in (select fiveno from tbFiveCoupInfo where CoupNo='AS002471471')
update Topway..tbcash set pasname='CAO/HAILUN MS',tcode='160',ticketno='2374488965' where coupno='AS002471471' and pasname='�˿�0'
update Topway..tbcash set pasname='CHENG/ZHANPENG MR',tcode='160',ticketno='2374488967' where coupno='AS002471471' and pasname='�˿�1'
update Topway..tbcash set pasname='CUI/HANQUAN MR',tcode='160',ticketno='2374488969' where coupno='AS002471471' and pasname='�˿�2'
update Topway..tbcash set pasname='CUI/YUE MS',tcode='160',ticketno='2374539287' where coupno='AS002471471' and pasname='�˿�3'
update Topway..tbcash set pasname='DING/JUNZHI MR',tcode='160',ticketno='2374539289' where coupno='AS002471471' and pasname='�˿�4'
update Topway..tbcash set pasname='GAO/HUANGJUN MR',tcode='160',ticketno='2374539291' where coupno='AS002471471' and pasname='�˿�5'
update Topway..tbcash set pasname='GAO/YUN MR',tcode='160',ticketno='2374539293' where coupno='AS002471471' and pasname='�˿�6'
update Topway..tbcash set pasname='HU/YUANJUN MR',tcode='160',ticketno='2374539295' where coupno='AS002471471' and pasname='�˿�7'
update Topway..tbcash set pasname='HUANG/HUILING MR',tcode='160',ticketno='2374539297' where coupno='AS002471471' and pasname='�˿�8'
update Topway..tbcash set pasname='JI/CHENGXUAN MR',tcode='160',ticketno='2374539299' where coupno='AS002471471' and pasname='�˿�9'
update Topway..tbcash set pasname='JIN/QI MS',tcode='160',ticketno='2374539301' where coupno='AS002471471' and pasname='�˿�10'
update Topway..tbcash set pasname='KANG/JIAQI MS',tcode='160',ticketno='2374539303' where coupno='AS002471471' and pasname='�˿�11'
update Topway..tbcash set pasname='SHEN/JINGQIN MS',tcode='160',ticketno='2374539305' where coupno='AS002471471' and pasname='�˿�12'
update Topway..tbcash set pasname='SHI/YUMIN MS',tcode='160',ticketno='2374539307' where coupno='AS002471471' and pasname='�˿�13'
update Topway..tbcash set pasname='SUN/ZEPING MR',tcode='160',ticketno='2374539309' where coupno='AS002471471' and pasname='�˿�14'
update Topway..tbcash set pasname='TANG/YEJUE MR',tcode='160',ticketno='2374539311' where coupno='AS002471471' and pasname='�˿�15'
update Topway..tbcash set pasname='WANG/XIAOXUAN MS',tcode='160',ticketno='2374539313' where coupno='AS002471471' and pasname='�˿�16'
update Topway..tbcash set pasname='WANG/ZHUO MS',tcode='160',ticketno='2374539315' where coupno='AS002471471' and pasname='�˿�17'
update Topway..tbcash set pasname='WU/YUKANG MR',tcode='160',ticketno='2374539317' where coupno='AS002471471' and pasname='�˿�18'
update Topway..tbcash set pasname='XU/CHENYUE MS',tcode='160',ticketno='2374539319' where coupno='AS002471471' and pasname='�˿�19'
update Topway..tbcash set pasname='XU/HANSEN MR',tcode='160',ticketno='2374539321' where coupno='AS002471471' and pasname='�˿�20'
update Topway..tbcash set pasname='XU/KE MR',tcode='160',ticketno='2374539323' where coupno='AS002471471' and pasname='�˿�21'
update Topway..tbcash set pasname='XU/ZEKAI MR',tcode='160',ticketno='2374539325' where coupno='AS002471471' and pasname='�˿�22'
update Topway..tbcash set pasname='YANG/JIALI MS',tcode='160',ticketno='2374539327' where coupno='AS002471471' and pasname='�˿�23'
update Topway..tbcash set pasname='YANG/MARY SIJIA MS',tcode='160',ticketno='2374539329' where coupno='AS002471471' and pasname='�˿�24'
update Topway..tbcash set pasname='YE/WENJUN MS',tcode='160',ticketno='2374539331' where coupno='AS002471471' and pasname='�˿�25'
update Topway..tbcash set pasname='ZHANG/JIALU MS',tcode='160',ticketno='2374539333' where coupno='AS002471471' and pasname='�˿�26'
update Topway..tbcash set pasname='ZHU/LIJIA MS',tcode='160',ticketno='2374539335' where coupno='AS002471471' and pasname='�˿�27'
update Topway..tbcash set pasname='ZHU/ZHIJIE MR',tcode='160',ticketno='2374539337' where coupno='AS002471471' and pasname='�˿�28'

update Topway..tbcash set pasname='WANG/YACHEN MR',tcode='160',ticketno='2374539339' where coupno='AS002471476' and pasname='WANG/YACHEN'


--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='������',SpareTC='������'
where coupno='AS001636891'


--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='020432_20190401'

--�޸���Ʊ�������
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti  set ExamineDate='2019-05-10'
where reno='0434597'


/*
��Ҫ����Ϣ��
UC����λ���ơ����ù��ʡ���Ӫ����
 
ɸѡ������
1.�����������Ʊ��Ϊ����
2.���ڻ�Ʊ����ƾ֤Ϊ���г̵�
3.����Ʊ�۱���ƾ֤Ϊ�������Է�Ʊ
*/

select u.Cmpid,u.Name,isnull(s.Name,'') ���ù���,isnull(MaintainName,'') ��Ӫ����
from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_TktUnitCompanies_TktTCs a on a.TktUnitCompanyID=u.ID 
LEFT JOIN homsomDB..SSO_Users s ON s.ID=a.TktTCID
left join Topway..HM_ThePreservationOfHumanInformation t on t.CmpId=u.Cmpid and MaintainType=9 and t.IsDisplay=1
where CertificateD=1
and IsSepPrice=1
and InvoiceType=2
and CooperativeStatus in ('1','2','3')
and u.Cmpid not in ('000003','000006')


--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=2921,profit=561
where coupno='AS002469175'

--����Ԥ�㵥��Ϣ

select StartDate,EndDate,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set StartDate='2019-05-29',EndDate='2019-06-05'
where ConventionId='1405'

--�޸����ۼ���Ϣ
select fuprice,totprice,amount,owe,profit,* from Topway..tbcash 
--update Topway..tbcash set fuprice=0,totprice=totprice-15,amount=amount-15,owe=owe-15,profit=profit-15
where coupno in('AS002441511',
'AS002441564',
'AS002441794',
'AS002442442',
'AS002442677',
'AS002447846',
'AS002450132',
'AS002450142',
'AS002450372',
'AS002452776',
'AS002453494',
'AS002454385',
'AS002454429',
'AS002454659',
'AS002456090',
'AS002456122',
'AS002464119',
'AS002464309',
'AS002465599',
'AS002465617',
'AS002465699')

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='019767_20190401'

--��Ӧ����Դ
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS������������D'
where coupno='AS002454905'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS���̸�����D'
where coupno='AS002460542'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS������ͬD'
where coupno='AS002461900'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002463227'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002466137'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETI'
where coupno='AS002449635'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETI'
where coupno='AS002453048'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETI'
where coupno='AS002460041'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETI'
where coupno='AS002464514'

--�Ƶ����
select top 100 * from Topway..tbHtlcoupYf

select Top 25 hotel,SUM(pcs*nights)��ҹ��,city,SUM(price)/SUM(pcs*nights) ���� from Topway..tbHtlcoupYf 
where 
 prdate>='2018-01-01'
and prdate<'2019-01-01'
and profitsource not like'%�����%'
group by hotel,city
order by ��ҹ�� desc

select top 25 hotel,SUM(pcs*nights) ��ҹ��,city,SUM(price)/SUM(pcs*nights) ���� from Topway..tbHotelcoup 
where 
beg_date>='2018-01-01'
and end_date<'2019-01-01'
and profitsource not like'%�����%'
group by hotel,city
order by ��ҹ�� desc


/*
 ��ѯҪ��
     1��ҵ�����ͣ�����
     2�������ˣ�CZ
     3����Ӧ����Դ������
     4����Ʊ����1��2018��1��-2018��12��
     5���۳���Ʊ 
     ����Ҫ��
     UC�š����۵��š�Ʊ�š��г̡���λ���ļ��ۺϼơ����ù��� 
*/
select cmpcode,coupno,tcode+ticketno Ʊ��,route,nclass,sprice1+sprice2+sprice3+sprice4 �ļ��ۺϼ�,sales
from Topway..tbcash 
where inf=1
and ride='cz'
and (datetime between '2018-01-01' and '2018-12-31')
and reti=''
order by datetime

/*
   1��ҵ�����ͣ�����
     2�������ˣ�SK
     3����Ӧ����Դ����
     4����Ʊ����1��2018��1��-2018��12��
         ��Ʊ����2��2019��1��-2019��4��
     5���۳���Ʊ
     ����Ҫ��
     UC�š����۵��š�Ʊ�š��г̡���λ���ļ��ۺϼơ����ù��� 
*/

select cmpcode,coupno,tcode+ticketno Ʊ��,route,nclass,sprice1+sprice2+sprice3+sprice4 �ļ��ۺϼ�,sales
from Topway..tbcash 
where inf=1
and ride='SK'
and (datetime between '2018-01-01' and '2018-12-31')
and reti=''
order by datetime

select cmpcode,coupno,tcode+ticketno Ʊ��,route,nclass,sprice1+sprice2+sprice3+sprice4 �ļ��ۺϼ�,sales
from Topway..tbcash 
where inf=1
and ride='SK'
and (datetime between '2019-01-01' and '2019-04-30')
and reti=''
order by datetime


--������㵥��Ϣ����

select SettleStatus,* from Topway..tbConventionSettleApp
--update Topway..tbConventionSettleApp set SettleStatus='3' 
where Id='3904'

select * from Topway..tbConventionJS
--update Topway..tbConventionJS set Jstatus='0',Settleno='0',Pstatus='0',Pdatetime='1900-1-1' 
where Settleno='3904'