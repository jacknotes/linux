/*
��ȡһ�ݻ�����Ӫ��-��֮�� �Ź㺮 ����Х��2019��4�·���ɱ��ŵ�����EXECL������������¸��
1.��������
2.Ԥ�㵥��
3.��λ����
4.��Ӧ�̽�����Ϣ����Ӧ����Դ
*/
select c.OperDate,c.ConventionId,u.Name,j.GysSource,Sales,FinancialCharges
from Topway..tbConventionCoup c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.Cmpid
left join Topway..tbConventionJS j on j.ConventionId=c.ConventionId
where c.OperDate>='2019-04-01'
and c.OperDate<'2019-05-01'
and Sales in('��֮��','�Ź㺮','����Х')
and Status<>2
order by c.OperDate

--2019��1��1��ǰע��ĵ�λ�ͻ�Ϊ�Ͽͻ�

select Name from  homsomDB..Trv_UnitCompanies_KEYAccountManagers u 
left join Topway..SSO_Users s on s.ID=u.EmployeeID
where Name in ('����','������','����','Ҧ�ϻ�')
select  top 100 RegisterMonth,* from homsomDB..Trv_UnitCompanies


IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as ��λ���,t1.cmpname as ��λ����
,(case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' else '' end) as ��λ����
,(CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END) as ����״̬
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as ������
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as �ͻ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as ά����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as ����ҵ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as ����ҵ�����
,indate
into #cmp1
from topway..tbCompanyM t1
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
t9.ID=t5.EmployeeID and t9.ID=t6.EmployeeID and t9.ID=t8.TktTCID and t9.ID=t7.TrvTCID 
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid

select* from #cmp1

--3��4�����������������Ͽͻ���

select  CONVERT(varchar(6),c.OperDate,112) �·�,Cmp.ά����,
sum(XsPrice) ����,sum(Profit) ����
from topway..tbTrvCoup c
left join #cmp1 cmp on Cmp.��λ���=c.Cmpid
where c.OperDate>='2019-03-01' and c.OperDate<'2019-05-01'
and Cmp.indate<'2019-01-01'
group by CONVERT(varchar(6),c.OperDate,112),Cmp.ά����

--select indate,* from Topway..tbCompanyM where cmpid='020271'
--select RegisterMonth,* from homsomDB..Trv_UnitCompanies where Cmpid='020271'

--2019��1-4�����������������Ͽͻ���

select  Cmp.ά����,
sum(XsPrice) ����,sum(Profit) ����
from topway..tbTrvCoup c
left join #cmp1 cmp on Cmp.��λ���=c.Cmpid
where c.OperDate>='2018-01-01' and c.OperDate<'2018-05-01'
and Cmp.indate<'2019-01-01'
group by Cmp.ά����


 /*   �鷳��ȡ4/1-4/30���ŵĽ������ݣ�

1�������¿ͻ����λ���10��1��֮ǰ¼��Ԥ�㵥��������      ��10��1��֮��¼��Ԥ�㵥��������

2�� ������ʼ���������10�·�¼Ԥ�㵥���Ƿ��С�10��1��֮ǰ¼��Ԥ�㵥��������10��1��֮��¼��Ԥ�㵥��������

*/
--����10��֮�� �¿ͻ�
select cmp1.������,SUM(DisCountProfit) as �������� from tbTrvCoup c
inner join tbTravelBudget b on b.TrvId=c.TrvId
inner join #cmp1 cmp1 on cmp1.��λ���=c.Cmpid
where c.OperDate>='2019-04-01' and c.OperDate<'2019-05-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
and cmp1.indate>'2018-05-01'
group by cmp1.������
order by �������� desc


--�������10��֮�� 
select c.Sales  as �������,SUM(DisCountProfit) as �������� from tbConventionCoup c
inner join tbConventionBudget b on b.ConventionId=c.ConventionId
inner join #cmp1 cmp1 on cmp1.��λ���=c.Cmpid
where c.OperDate>='2019-04-01' and c.OperDate<'2019-05-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
--and cmp1.indate>='2018-01-01'
group by c.Sales
order by �������� desc

select c.Sales  as �������,c.TrvId,SUM(DisCountProfit) as �������� from tbTrvCoup c
inner join tbTravelBudget b on b.TrvId=c.TrvId
inner join #cmp1 cmp1 on cmp1.��λ���=c.Cmpid
where c.OperDate>='2019-04-01' and c.OperDate<'2019-05-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
--and cmp1.indate>='2018-01-01'
group by c.Sales,c.TrvId
order by �������� desc

select * from Topway..tbTrvCoup where TrvId='29704'


--����10��֮ǰ �¿ͻ�
select cmp1.������,SUM(DisCountProfit)  as �������� from tbConventionCoup c
inner join tbConventionBudget b on b.ConventionId=c.ConventionId
inner join #cmp1 cmp1 on cmp1.��λ���=c.Cmpid
where c.OperDate>='2019-04-01' and c.OperDate<'2019-05-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
and cmp1.indate>'2018-05-01'
group by cmp1.������
order by �������� desc

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update  Topway..AccountStatement  set SubmitState=1
where BillNumber='020754_20190401'

--���ۼ���Ϣ
select price,totprice,owe,amount,profit,* from Topway..tbcash 
--update Topway..tbcash  set price=20,totprice='20',owe='20',amount='20',profit='18'
where coupno='AS002453151'

select price,totprice,owe,amount,profit,* from Topway..tbcash 
--update Topway..tbcash  set price=20,totprice='20',owe='20',amount='20',profit='18'
where coupno='AS002453251'

select price,totprice,owe,amount,profit,* from Topway..tbcash 
--update Topway..tbcash  set price=20,totprice='20',owe='20',amount='20',profit='18'
where coupno='AS002454899'

--����Ԥ�㵥��Ϣ
select Sales,OperName,introducer,* from Topway..tbConventionBudget
--update  Topway..tbConventionBudget set Sales='��֮��',OperName='0481��֮��',introducer='��֮��-0481-��Ӫ��'
where ConventionId in('1328','1337','1155','1338','1184','1250','1252','1398')

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='019143_20190401'

--select Departure,Destination,* from homsomdb..Trv_lineLimit where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F'

--update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure=''
--update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination=''

update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='LXA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='LXA'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='YUS') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='YUS'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='SIA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='SIA'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='KMG') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='KMG'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='SIA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='SIA'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='JZH') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='JZH'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='SIA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='SIA'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='JZH') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='JZH'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='CTU') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='CTU'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='SHA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='SHA'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='DLU') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='DLU'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='SHA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='SHA'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='LXA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='LXA'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='YUS') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='YUS'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='YBP') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='YBP'
update homsomdb..Trv_lineLimit set DepartureName=(Select Name from homsomDB..Trv_Cities where Code='XNN') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Departure='XNN'


update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='SIA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='SIA'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='SIA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='SIA'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='YUS') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='YUS'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='YBP') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='YBP'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='LXA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='LXA'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='SIA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='SIA'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='JZH') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='JZH'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='CTU') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='CTU'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='JZH') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='JZH'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='LXA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='LXA'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='SHA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='SHA'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='DLU') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='DLU'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='SHA') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='SHA'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='XNN') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='XNN'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='KMG') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='KMG'
update homsomdb..Trv_lineLimit set DestinationName=(Select Name from homsomDB..Trv_Cities where Code='YUS') where GroupId='BF7E018E-1FFE-4A3A-A313-8BF59904A58F' and Destination='YUS'


--UC016641����Ϊ�������й������޹�˾
select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement  set CompanyNameCN='�������й������޹�˾'
where BillNumber='016641_20190501'

--ɾ���������
SELECT * 
--DELETE
FROM homsomDB..Trv_Airport WHERE Code='DXB' AND ID='D80BAFED-379D-3967-92DF-0A9721BA99E6'


--���ν��㵥����
select SettleStatus,* from Topway..tbTrvSettleApp
--update Topway..tbTrvSettleApp set SettleStatus='3' 
where Id='27180'

select * from topway..tbTrvJS
--update topway..tbTrvJS set Jstatus='0',Settleno='0',Pstatus='0',Pdatetime='1900-1-1' 
where Settleno='27180'

--�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='Я�̹�����������'
where CoupNo='PTW081867'

select tcode,* from Topway..tbintercmp 
--update Topway..tbintercmp  set tcode=0
where id=96


--�Ƶ����۵���Ӧ����Դ

select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='Я�̹�����������'
where CoupNo='PTW081927'

--���ν��㵥��Ϣ
select * from Topway..tbTrvSettleApp
--update Topway..tbTrvSettleApp set SettleStatus='3' 
where Id='27201'

