--����ֱ���ȡ2015-2016,���в��ÿͻ������οͻ��������ѵ���ϸ��û���ѵ���ϸ

--���õ�λ-����
select t1.cmpid as ��λ���,cmpname as ��λ����,t1.OperDate as Ԥ�㵥��������,TrvId as Ԥ�㵥��,TrvCpName as ��·����,t2.cmpaddress as ��λ��ַ,t3.custname as ��ϵ��,LEFT(t1.Custinfo,11) as ��ϵ��ʽ
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2019-01-01' and t2.CustomerType='A'
and t1.TrvType not like '%5%' and t1.Status !=2
order by t1.cmpid

--���õ�λ-����

select t1.cmpid as ��λ���,cmpname as ��λ����,t1.OperDate as Ԥ�㵥��������,ConventionId as Ԥ�㵥��,ConventionCpName as ��·����,t2.cmpaddress as ��λ��ַ,t3.custname as ��ϵ��,LEFT(t1.Custinfo,11) as ��ϵ��ʽ
from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2019-01-01' and t2.CustomerType='A' and t1.status!=2
order by t1.cmpid

--���õ�λ-�������
select t1.cmpid as ��λ���,cmpname as ��λ����,t1.OperDate as Ԥ�㵥��������,TrvId as Ԥ�㵥��,TrvCpName as ��·����,t2.cmpaddress as ��λ��ַ,t3.custname as ��ϵ��,LEFT(t1.Custinfo,11) as ��ϵ��ʽ
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2019-01-01' and t2.CustomerType='A'
and t1.TrvType like '%5%' and t1.Status !=2
order by t1.cmpid


--���ε�λ-����
select t1.cmpid as ��λ���,cmpname as ��λ����,t1.OperDate as Ԥ�㵥��������,t1.TrvId as Ԥ�㵥��,t1.TrvCpName as ��·����,t2.cmpaddress as ��λ��ַ,t3.custname as ��ϵ��,LEFT(t1.Custinfo,11) as ��ϵ��ʽ
,t4.XsPrice as ����,Profit as ����
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
left join Topway..tbTrvCoup t4 on t4.TrvId=t1.TrvId
where t1.OperDate>='2018-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t1.TrvType not like '%5%' and t1.Status !=2
order by t1.cmpid


--���ε�λ-����

select t1.cmpid as ��λ���,cmpname as ��λ����,t1.OperDate as Ԥ�㵥��������,t1.ConventionId as Ԥ�㵥��,t1.ConventionCpName as ��·����,t2.cmpaddress as ��λ��ַ,t3.custname as ��ϵ��,LEFT(t1.Custinfo,11) as ��ϵ��ʽ
,t4.XsPrice as ����,Profit as ����
from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
left join Topway..tbConventionCoup t4 on t4.ConventionId=t1.ConventionId
where t1.OperDate>='2018-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C' and t1.status!=2
order by t1.cmpid

--���ε�λ-�������
select t1.cmpid as ��λ���,cmpname as ��λ����,t1.OperDate as Ԥ�㵥��������,t1.TrvId as Ԥ�㵥��,t1.TrvCpName as ��·����,t2.cmpaddress as ��λ��ַ,t3.custname as ��ϵ��,LEFT(t1.Custinfo,11) as ��ϵ��ʽ
,t4.XsPrice as ����,Profit as ����
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
left join Topway..tbTrvCoup t4 on t4.TrvId=t1.TrvId
where t1.OperDate>='2018-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t1.TrvType like '%5%' and t1.Status !=2
order by t1.cmpid

--2015�������ѣ�2016��δ���Ѳ��ÿͻ�
select cmpid as ��λ���,cmpname as ��λ����,CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END as ����״̬
from tbCompanym
where cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' --and t2.CustomerType='A'
and t2.Status !=2)
and cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' --and t2.CustomerType='A')

and cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' --and t2.CustomerType='A'
and t2.Status !=2)
and cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' --and t2.CustomerType='A')

and CustomerType='A'


--2015�������ѣ�2016��δ�������οͻ�
select cmpid as ��λ���,cmpname as ��λ����,CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END as ����״̬
from tbCompanym
where cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C'
and t2.Status !=2)
and cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C')

and cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t2.Status !=2)
and cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='c')

and CustomerType='C'

--��λ�ͻ�����״̬
select * from tbCompanyM where hztype=1


--���õ�λ2015�������ѣ�2016��δ����
--2015������������ϸ
select t1.cmpid as ��λ���,cmpname as ��λ����,
t1.OperDate as Ԥ�㵥��������,TrvId as Ԥ�㵥��,TrvCpName as ��·����,t2.cmpaddress as ��λ��ַ,t3.custname as ��ϵ��,LEFT(t1.Custinfo,11) as ��ϵ��ʽ,
CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END as ����״̬
from tbCompanym t2
inner join tbTravelBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid


where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A'
and t1.Status !=2)
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A')

and t2.CustomerType='A'
and t1.Status !=2
and t1.TrvType not like '%5%'
order by t2.cmpid


--���õ�λ2015�������ѣ�2016��δ����
--2015�����������ϸ
select t1.cmpid as ��λ���,cmpname as ��λ����,t1.OperDate as Ԥ�㵥��������,ConventionId as Ԥ�㵥��,ConventionCpName as ��·����,t2.cmpaddress as ��λ��ַ,t3.custname as ��ϵ��,LEFT(t1.Custinfo,11) as ��ϵ��ʽ,
CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END as ����״̬
from tbCompanym t2
inner join tbConventionBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid


where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A'
and t1.Status !=2)
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A')

and t2.CustomerType='A'
and t1.Status !=2
order by t2.cmpid


--���õ�λ2015�������ѣ�2016��δ����
--2015�굥�����������ϸ
select t1.cmpid as ��λ���,cmpname as ��λ����,
t1.OperDate as Ԥ�㵥��������,TrvId as Ԥ�㵥��,TrvCpName as ��·����,t2.cmpaddress as ��λ��ַ,t3.custname as ��ϵ��,LEFT(t1.Custinfo,11) as ��ϵ��ʽ,
CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END as ����״̬
from tbCompanym t2
inner join tbTravelBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid


where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A'
and t1.Status !=2)
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A')

and t2.CustomerType='A'
and t1.Status !=2
and t1.TrvType  like '%5%'
order by t2.cmpid



--���ε�λ2015�������ѣ�2016��δ����
--2015������������ϸ
select t1.cmpid as ��λ���,cmpname as ��λ����,
t1.OperDate as Ԥ�㵥��������,t1.TrvId as Ԥ�㵥��,t1.TrvCpName as ��·����,t2.cmpaddress as ��λ��ַ,t3.custname as ��ϵ��,LEFT(t1.Custinfo,11) as ��ϵ��ʽ,
CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END as ����״̬
,t4.XsPrice as ����,Profit as ����
from tbCompanym t2
inner join tbTravelBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
left join Topway..tbTrvCoup t4 on t1.TrvId=t4.TrvId

where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t1.Status !=2)
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C')

and t2.CustomerType='C'
and t1.Status !=2
and t1.TrvType not like '%5%'
order by t2.cmpid


--���ε�λ2015�������ѣ�2016��δ����
--2015�����������ϸ
select t1.cmpid as ��λ���,cmpname as ��λ����,t1.OperDate as Ԥ�㵥��������,t1.ConventionId as Ԥ�㵥��,t1.ConventionCpName as ��·����,t2.cmpaddress as ��λ��ַ,t3.custname as ��ϵ��,LEFT(t1.Custinfo,11) as ��ϵ��ʽ,
CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END as ����״̬
,t4.XsPrice as ����,t4.Profit as ����
from tbCompanym t2
inner join tbConventionBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
left join Topway..tbConventionCoup t4 on t4.ConventionId=t1.ConventionId

where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t1.Status !=2)
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C')

and t2.CustomerType='C'
and t1.Status !=2
order by t2.cmpid


--���ε�λ2015�������ѣ�2016��δ����
--2015�굥�����������ϸ
select t1.cmpid as ��λ���,cmpname as ��λ����,
t1.OperDate as Ԥ�㵥��������,t1.TrvId as Ԥ�㵥��,t1.TrvCpName as ��·����,t2.cmpaddress as ��λ��ַ,t3.custname as ��ϵ��,LEFT(t1.Custinfo,11) as ��ϵ��ʽ,
CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END as ����״̬
,t4.XsPrice as ����,Profit as ����
from tbCompanym t2
inner join tbTravelBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid
left join Topway..tbTrvCoup t4 on t1.TrvId=t4.TrvId

where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t1.Status !=2)
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C')

and t2.CustomerType='C'
and t1.Status !=2
and t1.TrvType  like '%5%'
order by t2.cmpid

--2015-2016���μ�����������ѵĵ�λ�ͻ�-���õ�λ
select cmpid as ��λ���,cmpname as ��λ����,CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END as ����״̬
from tbCompanym
where cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t2.Status !=2)
and cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='c')
and CustomerType='A'

--2015-2016���μ�����������ѵĵ�λ�ͻ�-���ε�λ
select cmpid as ��λ���,cmpname as ��λ����,CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END as ����״̬
from tbCompanym
where cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='C'
and t2.Status !=2)
and cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2018-01-01' and t1.OperDate<'2017-01-01' and t2.CustomerType='c')
and CustomerType='C'

--����
select * from tbTravelBudget where Cmpid=''
select * from tbConventionBudget where Cmpid=''