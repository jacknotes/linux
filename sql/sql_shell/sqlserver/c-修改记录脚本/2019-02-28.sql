--�޸Ĳ���
insert into 
select * from ApproveBase..App_BaseDept where DeptCode like'%����%'

--��ѯ�Ѿ�����custid
select custid from Topway..tbcash where cmpcode='018919' group by custid
select CustId from topway..tbTrvCoup where CmpId='018919' group by CustId
--ɾ��Ա���ű�UC018919
select * from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (
select a.ID from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018919')
and IsDisplay=1 and Mobile  in ('11111111111','13564599279','13818858618'))

--ɾ��ERP UC018919
select EmployeeStatus,* from Topway..tbCusholderM 
--update Topway..tbCusholderM set EmployeeStatus=0
where cmpid='018919' and EmployeeStatus=1 
--ɾ��ERP UC020719
select EmployeeStatus,* from Topway..tbCusholderM 
--update Topway..tbCusholderM set EmployeeStatus=0
where cmpid='020719' and EmployeeStatus=1 

--ɾ�����³��ֻ�����
select Mobile,* from homsomDB..Trv_Human
--update homsomDB..Trv_Human set Mobile=''
where ID in (
select a.ID from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018919')
and IsDisplay=1 and Mobile in ('123'))

--ɾ��Ա���ű�UC020719
select * from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (
select a.ID from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='020719')
and IsDisplay=1 and Mobile not in ('13671736339','13701831031'))

select * from Topway..tbCusholderM where cmpid='018919' and EmployeeStatus=1 order by custname desc

--�޸�ERPԱ��״̬
select EmployeeStatus from Topway..tbCusholderM 
--update Topway..tbCusholderM  set EmployeeStatus=1
where custid in(select CustID
FROM homsomDB..Trv_UnitPersons u
INNER JOIN homsomDB..Trv_Human h ON u.id =h.ID
INNER JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID
WHERE Cmpid='018919' AND h.IsDisplay=1)

select EmployeeStatus from Topway..tbCusholderM 
--update Topway..tbCusholderM  set EmployeeStatus=1
where custid in(select CustID
FROM homsomDB..Trv_UnitPersons u
INNER JOIN homsomDB..Trv_Human h ON u.id =h.ID
INNER JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID
WHERE Cmpid='020719' AND h.IsDisplay=1)

select COUNT(1),custid from Topway..tbCusholderM where cmpid='020719'
group by custid

--ɾ������ERPԱ������
select * from Topway..tbCusholderM 
where cmpid in('020719','018919') 
and EmployeeStatus<>1
--and EmployeeStatus=1

delete from Topway..tbCusholderM 
where cmpid in('020719','018919') 
and EmployeeStatus<>1

--��ӡȨ��
select PrintTime,CustStat,CustId,CustDate,* from Topway..tbExtraPayment 
--update Topway..tbExtraPayment set PrintTime='1900-01-01'
where Id ='51589'

--�޸�ҵ�����
select sales,* from Topway..tbcash 
--update Topway..tbcash  set sales='������'
where coupno in('AS001958601','AS001768550','AS002204807','AS001734459','AS001784351','AS001963611','AS002146134','AS002225996','AS001526335','AS001945083','AS002003478','AS001998210','AS002231655','AS002272660','AS002103274','AS002076516','AS002257441','AS002201140','AS001807710','AS001719426','AS001547507','AS001503370','AS001805616','AS002272664','AS002225986','AS002192362','AS002037919','AS001942282','AS001805606','AS001828371','AS001517712','AS001999362','AS001503368')

--�޸Ĺ�Ӧ����Դ
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno='AS002257647'

select coupno,t_source ,tcode+ticketno as Ʊ�� from Topway..tbcash 
where t_source like'%����%' and tickettype='����Ʊ' and datetime>='2019-01-01' 
and datetime<'2019-02-01' and reti=''
and inf=0