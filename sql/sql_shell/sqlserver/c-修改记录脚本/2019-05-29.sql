--UC019707ɾ���»طü�¼
select * from homsomDB..Trv_Memos 
--update homsomDB..Trv_Memos  set UnitCompanyID=null
where UnitCompanyID=(Select id  from homsomDB..Trv_UnitCompanies where Cmpid='019707')
and ID in ('9193BBB6-927A-4EA1-9C54-AA5B010DBFF8','75D07550-8E2D-40D7-AC66-AA5B010DD61B')

--��Ʊ��
--select pasname,* from Topway..tbcash where coupno='AS002507409'
update Topway..tbcash set pasname='SUN/XUANHUA',tcode='781',ticketno='2400584815' where coupno ='AS002507409' and pasname='�˿�0'
update Topway..tbcash set pasname='TAO/LAN',tcode='781',ticketno='2400584816' where coupno ='AS002507409' and pasname='�˿�1'
update Topway..tbcash set pasname='WANG/DEZHEN',tcode='781',ticketno='2400584817' where coupno ='AS002507409' and pasname='�˿�2'
update Topway..tbcash set pasname='XU/LENIAN',tcode='781',ticketno='2400584818' where coupno ='AS002507409' and pasname='�˿�3'
update Topway..tbcash set pasname='ZHANG/XIUJUAN',tcode='781',ticketno='2400584819' where coupno ='AS002507409' and pasname='�˿�4'
update Topway..tbcash set pasname='ZHAO/SHUIXIAN',tcode='781',ticketno='2400584820' where coupno ='AS002507409' and pasname='�˿�5'
update Topway..tbcash set pasname='ZHONG/YULAN',tcode='781',ticketno='2400584821' where coupno ='AS002507409' and pasname='�˿�6'
update Topway..tbcash set pasname='ZHOU/MINGZHEN',tcode='781',ticketno='2400584822' where coupno ='AS002507409' and pasname='�˿�7'
update Topway..tbcash set pasname='ZHOU/PEIFANG',tcode='781',ticketno='2400584823' where coupno ='AS002507409' and pasname='�˿�8'
update Topway..tbcash set pasname='CAI/PEIMIN',tcode='781',ticketno='2400584824' where coupno ='AS002507409' and pasname='�˿�9'
update Topway..tbcash set pasname='CHAI/JUE',tcode='781',ticketno='2400584825' where coupno ='AS002507409' and pasname='�˿�10'
update Topway..tbcash set pasname='CHEN/YINYUE',tcode='781',ticketno='2400584826' where coupno ='AS002507409' and pasname='�˿�11'
update Topway..tbcash set pasname='DONG/LAN',tcode='781',ticketno='2400584827' where coupno ='AS002507409' and pasname='�˿�12'
update Topway..tbcash set pasname='FU/MINZHEN',tcode='781',ticketno='2400584828' where coupno ='AS002507409' and pasname='�˿�13'
update Topway..tbcash set pasname='HE/PING',tcode='781',ticketno='2400584829' where coupno ='AS002507409' and pasname='�˿�14'
update Topway..tbcash set pasname='LIAO/XIANGJIE',tcode='781',ticketno='2400584830' where coupno ='AS002507409' and pasname='�˿�15'
update Topway..tbcash set pasname='LU/PUMING',tcode='781',ticketno='2400584831' where coupno ='AS002507409' and pasname='�˿�16'
update Topway..tbcash set pasname='MA/YING',tcode='781',ticketno='2400584832' where coupno ='AS002507409' and pasname='�˿�17'
update Topway..tbcash set pasname='NI/JIN',tcode='781',ticketno='2400584833' where coupno ='AS002507409' and pasname='�˿�18'

/*
��λ��ţ�UC020778
��Ʊ���ڣ�2019.1.1-2019.5.27
��Ʊ���ͣ�����+����
*/
select coupno,pasname,idno 
from Topway..tbcash where cmpcode='020778'
and datetime>='2019-01-01'
and datetime<'2019-05-28'

/*
   UC018734   ����ס�����У��й������޹�˾
     �ù�˾��������ǩ������˾�ṩ2018.5-2019.4�Ļ�Ʊ����Ʊ���Ƶ���ϸ
*/
--��Ʊ
select coupno ���۵���,convert(varchar(10),datetime,120)��Ʊ����,begdate �������,pasname �˻���,route �г�,price ���۵���,
tax ˰��,totprice ���ۼ�,isnull(CostCenter,'') �ɱ�����,ride+flightno �����,nclass ��λ,tickettype ����,reti ��Ʊ����
from Topway..tbcash 
where cmpcode='018734'
and datetime>='2018-05-01'
and datetime<'2019-05-01'
order by datetime

--��Ʊ
select CoupNo ���۵���,Name �˿�,PrintDate ��Ʊʱ��,OutBegdate ����ʱ��,OutTrainNo ����,OutStroke �г�,OutGrade ����,TotUnitprice ԭ��,TotFuprice �����,TotPrintPrice ��ӡ��,TotPrice ���ۼ�
from Topway..tbTrainTicketInfo t
left join Topway..tbTrainUser t2 on t.ID=t2.TrainTicketNo
where CmpId='018734'
and PrintDate>='2018-05-01'
and PrintDate<'2019-05-01'
order by PrintDate

/*
UC020459���������Ϻ����������޹�˾
5��  ���й�Ӧ����ԴΪ���λ�BSP�� �ⲿ�ֵ��ʽ�ɱ�*/
select coupno ���۵���,convert(varchar(10),datetime,120) ��Ʊ����,t_source ��Ӧ����Դ,Mcost �ʽ�ɱ�
from Topway..tbcash 
where cmpcode='020459'
and datetime>='2019-05-01'
 and t_source like '%�λ�%'
 order by ��Ʊ����
 
--UC019707ɾ�����ÿ�
select * from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (Select ID from homsomDB..Trv_UnitPersons 
where companyid=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='019707'))
and IsDisplay=1
and Name not in ('��ӱ','������','���','���»�')

select EmployeeStatus,* from Topway..tbCusholderM 
--update Topway..tbCusholderM set EmployeeStatus=0
where cmpid='019707' 
and joindate<'2019-05-29' 
and custname not in ('��ӱ','������','���','���»�')

--�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='Я�̹�����������'
where CoupNo='PTW082698'

--���۵��ĳ�δ��
select bpay,status,opernum,oper2,oth2,totprice,dzhxDate,owe,cowe,coweinf,vpay,vpayinf,*  from Topway..tbcash 
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
where coupno='AS002439241'

--�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='Ա���渶���������п���'
where coupno='PTW083473'

--�Ƶ����۵��ĳɹ���
select dinf,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set dinf=0
where CoupNo='PTW083463'

--���æ��ȡ�߲����µĵ�λ�ͻ���ͨ������Ʊ�ۡ�+���г̵����Ĺ�˾UC�ź�����
--����
select Cmpid,u.Name,s.Name 
from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_TktUnitCompanies_TktTCs t on t.TktUnitCompanyID=u.ID
left join homsomDB..SSO_Users s on s.ID=t.TktTCID
where CertificateD=1
and IsSepPrice=1
and s.Name='�߲�'
and CooperativeStatus in ('1','2','3')

--����
select Cmpid,u.Name,s.Name 
from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_TktUnitCompanies_TktTCs t on t.TktUnitCompanyID=u.ID
left join homsomDB..SSO_Users s on s.ID=t.TktTCID
where CertificateI=1
and IsIntlSpecialPrice=1
and s.Name='�߲�'
and CooperativeStatus in ('1','2','3')

--020075��Ҫ�Ƶ�����ݷ��� Ԥ�����ڣ�2018-06-01-2019-05-29��ֻҪ����״̬����ȷ�ϵ� 
SELECT case when dinf=0 then '����' when dinf=1 then '����' else '' end ����,CoupNo ���۵���,prdate Ԥ������
,hotel �Ƶ�����,cmpid ���,pasname ��������,beg_date ��ס����,end_date �������,nights*pcs ��ҹ,price �����ܼ�,fwprice �����,price+fwprice-yhprice Ӧ�ս��,
sprice �����ܼ�,totprofit ����,case when status=1 then '��ȷ��' else '' end ����״̬,
case when status2=1 then '�ѽ���' when status2=2 then '����' when status2=0 then 'δ����' else '' end �տ�״̬,
case when pstatus=0 then 'δ��ӡ' when pstatus=1 then '�Ѵ�ӡ' when pstatus=2 then'�����ӡ' else '' end ��ӡ״̬,
Sales ҵ�����
FROM Topway..tbHtlcoupYf 
WHERE cmpid='020075'
AND prdate>='2018-06-01'
and status=1


--UC016682ɾ�����ÿ�
select * from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (Select ID from homsomDB..Trv_UnitPersons 
where companyid=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='016682'))
and IsDisplay=1
and ID not in ('6FED6291-5268-4A5B-8541-AA5C00FA0B74','C2921360-8BC8-4535-8B7D-1C1AFF4D3311')


--UC016682�޸�ע����2019.05.29
select  indate,* from Topway..tbCompanyM 
--update Topway..tbCompanyM  set indate='2019-05-29'
where cmpid='016682'

select RegisterMonth,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies  set RegisterMonth='05  29 2019 12:00AM'
where Cmpid='016682'

--UC016682�Ϻ���������ó�����޹�˾ Ҫ�����θĲ���
select CustomerType,* from Topway..tbCompanyM 
--update Topway..tbCompanyM set CustomerType='A'
where cmpid='016682'

SELECT Type,* FROM homsomDB..Trv_UnitCompanies 
--UPDATE homsomDB..Trv_UnitCompanies SET Type='A'
WHERE Cmpid='016682'