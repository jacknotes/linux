
select sum(fuprice) as ����Ѻϼ� from Topway..tbcash where cmpcode='020459' and datetime<'2018-12-31'

select * from Topway..tbCompanyM where cmpname like'����%%'


--��Ʊ���ۼ���Ϣ,�޸����۵��ۺͺϼƼ�

SELECT TotSprice,TotPrice,* FROM topway..tbTrainTicketInfo 
--update topway..tbTrainTicketInfo  set TotSprice='335',TotPrice='355'
WHERE (CoupNo='RS000018597')
SELECT RealPrice,* FROM topway..tbTrainUser 
--update topway..tbTrainUser set RealPrice='335'
WHERE TrainTicketNo IN (SELECT ID FROM topway..tbTrainTicketInfo WHERE CoupNo='RS000018597')

SELECT TotSprice,TotPrice,* FROM topway..tbTrainTicketInfo 
--update topway..tbTrainTicketInfo  set TotSprice='139.5',TotPrice='159.5'
WHERE (CoupNo='RS000018591')
SELECT RealPrice,* FROM topway..tbTrainUser 
--update topway..tbTrainUser set RealPrice='139.5'
WHERE TrainTicketNo IN (SELECT ID FROM topway..tbTrainTicketInfo WHERE CoupNo='RS000018591')

SELECT TotSprice,TotPrice,* FROM topway..tbTrainTicketInfo 
--update topway..tbTrainTicketInfo  set TotSprice='139.5',TotPrice='159.5'
WHERE (CoupNo='RS000018592')
SELECT RealPrice,* FROM topway..tbTrainUser 
--update topway..tbTrainUser set RealPrice='139.5'
WHERE TrainTicketNo IN (SELECT ID FROM topway..tbTrainTicketInfo WHERE CoupNo='RS000018592')

--�����˿��Ϣ

select * from Topway..tbTrvKhTk 
--update Topway..tbTrvKhTk  set AcountInfo='��һ��||==||�Ϻ��ֶ���չ�����Ϻ�����||==||970200018288'
where TrvId='029176'

--�˵�����

select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where CompanyCode='019693' and BillNumber='019693_20181201'

--�������ż����������Ϣ�����Σ�

select Status,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Status='12'
where TrvId='29234'
--delete from Topway..tbTrvCoup where TrvId='29234'

--���¿��´�ӡȨ��

select Prname,SettleStatus,* from Topway..tbTrvSettleApp 
--update Topway..tbTrvSettleApp set Prname='',SettleStatus='1'
where Id='26574'

--�������ż����������Ϣ�����Σ�

select ModifyDate,* from Topway..tbTravelBudget  
--update Topway..tbTravelBudget set ModifyDate='2018-12-31 10:11:44.000'
where TrvId='29234'
select OperDate,* from Topway..tbTrvCoup  
--update Topway..tbTrvCoup set OperDate='2018-12-31 10:20:28.267'
where TrvId='29234'

--�г̵�������Ʊ��

select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='���ӡ�г̵�'
where coupno in('AS002163653','AS002163760')

--��Ʊҵ�������Ϣ

select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='������'
where coupno='AS001373287'

select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set SpareTC='���໪'
where coupno='AS001374859'

--�Ƶ����۵�����

select status,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set status='1'
where CoupNo='ptw074198'

--����۲��

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='3622',profit='-2'
where coupno='AS002188401'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='3622',profit='-2'
where coupno='AS002188417'

--����������״̬

select state from topway..FinanceERP_ClientBankRealIncomeDetail 
--update topway..FinanceERP_ClientBankRealIncomeDetail set state='5'
where money='10950' and id='92F9CD53-DC4A-4212-B5A0-9363768D4629' 

/*
1����λ�ͻ������Ե�λ���ڡ����ʳ��ÿ�����
Ҫ��ͻ�״̬������
����Ҫ�أ���λ��š���λ���ơ��������֡�Ӣ�����֣�Last/First Middle�������֤�����ռ�����֤�����ж��֤���Ŀ��Էּ��У�
*/
IF OBJECT_ID('tempdb.dbo.#cmp') IS NOT NULL DROP TABLE #cmp
select t1.cmpid as ��λ���,t1.cmpname as ��λ����
,(case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' else '' end) as ��λ����
,(CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END) as ����״̬
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as ������
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as �ͻ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as ά����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as ����ҵ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as ����ҵ�����
,indate
--into #cmp 
from tbCompanyM t1
left join homsomdb..Trv_UnitCompanies t4 on t1.cmpid=t4.Cmpid
--������
left join homsomDB..Trv_UnitCompies_Sales t5 on t4.ID=t5.UnitCompayID
--�ͻ�����
left join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t4.ID=t6.UnitCompanyID
--ά����
left join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.UnitCompanyID=t4.ID
--����ҵ�����
left join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t7.TrvUnitCompanyID=t4.ID
--����ҵ�����
left join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t8.TktUnitCompanyID=t4.ID
--��Ա��Ϣ
left join homsomDB..SSO_Users t9 on
t9.ID=t5.EmployeeID and t9.ID=t6.EmployeeID and t9.ID=t8.TktTCID and t9.ID=t7.TrvTCID  where t1.cmpid<>00003 and t1.cmpid<>00006 and t1.cmpid<>'' and hztype in('1','2','3')
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid

--���ɱ����������ۿ���

select CostCenter as �ɱ�����,SUM(totprice) as ����,COUNT(*) as ����,SUM(price)/COUNT(*) as ƽ��Ʊ��,AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS �ۿ���
from topway..V_TicketInfo 
where cmpcode in ('017020')
and datetime>='2018-01-01' and datetime<'2018-12-01' and reti=''
group by CostCenter
order by CostCenter



-- UC019401�Ϻ�׿˼���ܿƼ��ɷ����޹�˾������ϸ

select v.datetime as ��Ʊ����,v.begdate as �������,v.coupno as ���۵���,v.pasname as �˿�����,v.tcode+v.ticketno as Ʊ��,v.route as �г�,v.price as ���۵���,v.tax as ˰��,v.ride+v.flightno as ����� 
,v.Department as ����,v.reti as ��Ʊ����,t.ProjectNo as ��Ŀ���
from Topway..V_TicketInfo v
left join Topway..tbcash t on t.pasname=v.pasname and t.coupno=v.coupno and t.price=v.price
where v.cmpcode='019401' and v.datetime>='2018-01-01' and v.datetime<'2019-01-01' and v.pasname in('���̺�','���B','������','½����','��Сɽ','�ű�','���','�Ź�','����','����','����','��ΰ��','����','�˴���')
order by v.datetime

--�Ƶ����ѵ��ؿ���ӡ

select pstatus,prdate,* from topway..tbHtlcoupYf 
--update topway..tbHtlcoupYf set pstatus='0',prdate='1900-01-01'
where CoupNo in('ptw074015','ptw074016')

--�ึ�����Ʊ�������뵥�޸�/����

select IsEnable,* from topway..tbExtraPayment 
--update topway..tbExtraPayment set IsEnable='0'
where Id='51554'
