--��ӵĳ����ÿ�
 SELECT c.Cmpid as ��λ���,h.Name as ��������,LastName+'/'+firstname+' '+MiddleName as Ӣ������,t.CredentialNo as ֤����
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
LEFT join homsomDB..Trv_Credentials t on t.HumanID=h.ID
WHERE c.Cmpid in('019358',
'016363',
'019331',
'020432',
'020459',
'019334',
'006299',
'019539',
'017923',
'019641',
'020481',
'019301',
'016428',
'016712',
'016400',
'017888',
'017795',
'019637',
'019293',
'017189',
'020029',
'019392',
'018919',
'018210',
'019956',
'018897',
'020543',
'016655',
'015828',
'019360',
'017996',
'018038',
'017920',
'019106',
'017903',
'020380',
'016641',
'019986',
'020261',
'016232',
'018030',
'019222',
'020202',
'016991',
'019845',
'016465',
'020039',
'006596',
'019989',
'019626'
) and h.IsDisplay='1'
order by Cmpid

--���ĵ�λ����

select cmpname,* from Topway..tbCompanyM 
--update Topway..tbCompanyM set cmpname='��ʢ��Ӣ��Ϣ�Ƽ����Ϻ����ɷ����޹�˾'
where cmpid='019637'

select Name,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set Name='��ʢ��Ӣ��Ϣ�Ƽ����Ϻ����ɷ����޹�˾'
where Cmpid='019637'

select CompanyNameCN,* from topway..AccountStatement 
--update topway..AccountStatement set CompanyNameCN='��ʢ��Ӣ��Ϣ�Ƽ����Ϻ����ɷ����޹�˾'
where CompanyCode='019637' and BillNumber='019637_20190201'

select cmpname,* from Topway..tbCompanyM 
--update Topway..tbCompanyM set cmpname='���ݰ������������豸���޹�˾'
where cmpid='019584'

select Name,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set Name='���ݰ������������豸���޹�˾'
where Cmpid='019584'

select CompanyNameCN,* from topway..AccountStatement 
--update topway..AccountStatement set CompanyNameCN='���ݰ������������豸���޹�˾'
where CompanyCode='019584'  and BillNumber='019584_20190201'


--���ս�λ����
select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash set sprice1='2.4',totsprice='2.4'
where coupno in('AS002210440','AS002212841','AS002212842','AS002219202','AS002219363','AS002223822','AS002223824','AS002225508','AS002226075','AS002230163','AS002233583',
'AS002232468')

select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash set sprice1='3.6',totsprice='3.6'
where coupno in('AS002216573','AS002218834','AS002220780','AS002220781','AS002221186','AS002222085','AS002222402','AS002222403','AS002222404','AS002222405','AS002222406','AS002222407','AS002222987','AS002222988','AS002223815','AS002227991','AS002234683','AS002235725','AS002235726','AS002235744','AS002235742','AS002235743','AS002235741','AS002235759','AS002235893','AS002235894','AS002235899','AS002235900',
'AS002236087')

select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash set sprice1='3.6',totsprice='3.6'
where coupno='AS002208643'

select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash set sprice1='2',totsprice='2'
where coupno in('AS002215063','AS002235081','AS002235082')

--��Ʊ�˵�δ����
select SalesOrderState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SalesOrderState='0'
where  BillNumber='020569_20181201'


--�޸ĺ�˾
SELECT * FROM ehomsom..tbInfAirCompany 
--update ehomsom..tbInfAirCompany set airname='��������'
where airname='��������'

--�Ƶ�REASON CODE��Ԥ���ˣ�����Ŀ��

select  h.CoupNo as ���۵���,Purpose as ����Ŀ��,t.pasname,ReasonDescription   FROM [HotelOrderDB].[dbo].[HTL_Orders] h
left join Topway..tbHtlcoupYf t on t.CoupNo=h.CoupNo
where h.CoupNo in ('PTW074077',
'PTW074076',
'PTW074130',
'PTW074246',
'PTW074311',
'PTW074434',
'PTW074433',
'PTW074632',
'PTW074832',
'PTW074831',
'PTW075028',
'PTW075102',
'PTW075123',
'PTW075488',
'PTW075759',
'PTW075758',
'PTW075796')

select CoupNo,pasname,* from Topway..tbHtlcoupYf where CoupNo in ('PTW074077',
'PTW074076',
'PTW074130',
'PTW074246',
'PTW074311',
'PTW074434',
'PTW074433',
'PTW074632',
'PTW074832',
'PTW074831',
'PTW075028',
'PTW075102',
'PTW075123',
'PTW075488',
'PTW075759',
'PTW075758',
'PTW075796')

--UC019634�������ʻ��˴����Ϻ������޹�˾�鷳��20190201���ڵ�̧ͷ��һ��
select CompanyNameCN,*  from Topway..AccountStatement 
--update Topway..AccountStatement set CompanyNameCN='�������ʻ��˴����Ϻ������޹�˾'
where BillNumber='019634_20190201'

 --�Ϻ�����2018���ʻ�Ʊƥ���λ����
 select t.datetime as ��Ʊ����,t.begdate as �������,t.coupno as ���۵���,t.pasname as �˿�����,t.route as ��·,t.ride+t.flightno as �����,t2.airname as ���չ�˾,t.tcode+t.ticketno as Ʊ��,(case t.priceinfo when '0' then t.price else priceinfo end) as ȫ��,
(case t.priceinfo when '0' then '1' else t.price/t.priceinfo end) as �ۿ���, t.price as ���۵���,t.tax as ˰��,t.fuprice as �����,t.totprice as ���ۼ�,t.reti as ��Ʊ����,t.CostCenter as �ɱ�����,t1.rtprice as ��Ʊ��,
(Select c.totprice from Topway..tbcash c where c.coupno=t.coupno and c.ticketno=t.ticketno and (c.route like'%����%' or c.tickettype like'%����%') and c.cmpcode='019358' and c.ModifyBillNumber in('019358_20180101','019358_20180201','019358_20180301','019358_20180401','019358_20180501','019358_20180601','019358_20180701','019358_20180801','019358_20180901','019358_20181001','019358_20181101','019358_20181201')) as �������շ�
  ,t.nclass as ��λ����
  from Topway..tbcash t
  left join Topway..tbReti t1 on t1.reno=t.reti
  left join ehomsom..tbInfAirCompany t2 on t2.code2=t.ride
 where t.ModifyBillNumber in('019358_20180101','019358_20180201','019358_20180301','019358_20180401','019358_20180501','019358_20180601','019358_20180701','019358_20180801','019358_20180901','019358_20181001','019358_20181101','019358_20181201') 
 and t.cmpcode='019358' and t.inf=1  
 order by t.ModifyBillNumber
 
 select coupno as ���۵���,nclass as ��λ from Topway..tbcash 
 where ModifyBillNumber in('019358_20180101','019358_20180201','019358_20180301','019358_20180401','019358_20180501','019358_20180601','019358_20180701','019358_20180801','019358_20180901','019358_20181001','019358_20181101','019358_20181201')
 and inf=1 and cmpcode='019358'
 
 --������Ʊ 0421829 ����������320Ԫ��0421828����������971Ԫ����ù�˾����ֹ���������Ƚ�δʹ�û�Ʊ������Ʊ�����־�����Ҫ���˻������Ż�ƱƱ��
 select profit,totprice,* from Topway..tbReti 
 --update Topway..tbReti set profit='320'
 where reno='0421829'
 select profit,totprice,* from Topway..tbReti 
 --update Topway..tbReti set profit='971'
 where reno='0421828'
 
 select profit,totprice,* from Topway..tbcash
 --update Topway..tbcash set profit='15'
 where reti='0421828'
 

 
 
 --�˵�����
 select * from Topway..AccountStatement where BillNumber='020592_20190101'

--�г�Ӫ�������۲�
select Dept, * from homsomDB..SSO_Users 
--update homsomDB..SSO_Users set Dept='���۲�'
where Dept='�г�Ӫ����'

select  dep,* from Topway..Emppwd  
--update Topway..Emppwd set dep='���۲�'
where dep='���۲�'


--¬Ҷ����˫���г�
select Dept,Name, * from homsomDB..SSO_Users 
--update homsomDB..SSO_Users set Dept='�г���'
where Name in('¬Ҷ','��˫')

select dep,empname, * from Topway..Emppwd 
--update Topway..Emppwd set dep='�г���'
where empname in('¬Ҷ','��˫')

--�������ļ����з�����
select Dept, * from homsomDB..SSO_Users 
--update homsomDB..SSO_Users set Dept='�����з�����'
where Dept='�����з�����'

select  dep,* from Topway..Emppwd  
--update Topway..Emppwd set dep='�����з�����'
where dep='�����з�����'

--�޸���Ʊ״̬
select status2 ,* from Topway..tbReti 
--update Topway..tbReti set status2='1'
where reno='9264581'

--�޸�ְλ

select depdetail, * from Topway..Emppwd 
--update Topway..Emppwd set depdetail='�������ʦ'
where empname ='¬Ҷ'
select depdetail, * from Topway..Emppwd 
--update Topway..Emppwd set depdetail='�г��ƹ㾭��'
where empname ='��˫'

select  depdetail,* from Topway..Emppwd  
--update Topway..Emppwd set depdetail='.NET��������ʦ'
where empname in('��Ρ',
'������',
'����',
'�ָ�',
'����',
'��Ƚ')

select  depdetail,* from Topway..Emppwd  
--update Topway..Emppwd set depdetail='.NET����ר��'
where empname='Ǯ��'

select  depdetail,* from Topway..Emppwd  
--update Topway..Emppwd set depdetail='Android��������ʦ'
where empname='��־��'

select  depdetail,* from Topway..Emppwd  
--update Topway..Emppwd set depdetail='IOS��������ʦ'
where empname='��˧'

select  depdetail,* from Topway..Emppwd  
--update Topway..Emppwd set depdetail='���Թ���ʦ'
where empname='��ʢ��'

select  depdetail,* from Topway..Emppwd  
--update Topway..Emppwd set depdetail='��������'
where empname='���'

select  depdetail,* from Topway..Emppwd  
--update Topway..Emppwd set depdetail='��������'
where empname='������'

--���ĵ�λ����
select CompanyNameCN,* from topway..AccountStatement 
--update topway..AccountStatement set CompanyNameCN='������(�й�)Ͷ�����޹�˾'
where CompanyCode='016336' and BillNumber='016336_20190201'

