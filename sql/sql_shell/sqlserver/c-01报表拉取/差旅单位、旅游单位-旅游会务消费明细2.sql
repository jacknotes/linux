--���õ�λ
select t1.cmpid as ��λ���,cmpname as ��λ����,
t1.OperDate as Ԥ�㵥��������,TrvId as Ԥ�㵥��,TrvCpName as ��·����,t2.cmpaddress as ��λ��ַ,t3.custname as ��ϵ��,LEFT(t1.Custinfo,11) as ��ϵ��ʽ,
CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END as ����״̬
from tbCompanym t2
inner join tbTravelBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid


where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='A')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A'
and t1.Status !=2 and t1.TrvType not like '%5%')
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A')

and t2.CustomerType='A'
and t1.Status !=2
--and t1.TrvType not like '%5%'
--and t1.OperDate<'2016-01-01'
order by t2.cmpid

--���ε�λ
select t1.cmpid as ��λ���,cmpname as ��λ����,
t1.OperDate as Ԥ�㵥��������,TrvId as Ԥ�㵥��,TrvCpName as ��·����,t2.cmpaddress as ��λ��ַ,t3.custname as ��ϵ��,LEFT(t1.Custinfo,11) as ��ϵ��ʽ,
CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END as ����״̬
from tbCompanym t2
inner join tbTravelBudget t1 on t1.cmpid=t2.cmpid
inner join Topway..tbCusholderM t3 on t1.Custid=t3.custid


where t2.cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C'
and t1.Status !=2)
and t2.cmpid  in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-01-01' and t2.CustomerType='C')

and t2.cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='C'
and t1.Status !=2 and t1.TrvType not like '%5%')
and t2.cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2016-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='C')

and t2.CustomerType='C'
and t1.Status !=2
--and t1.TrvType not like '%5%'
--and t1.OperDate<'2016-01-01'
order by t2.cmpid

--2015-2016δ�������λ�����õ�λ��ϸ�������������
select cmpid as ��λ���,cmpname as ��λ����,CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END as ����״̬
from tbCompanym
where  ((cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A'
and t2.Status !=2 and TrvType not like '%5%') or 
cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A'
  and t1.status=2))
and cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='A')

and CustomerType='A')

--2015-2016δ�������λ������ε�λ��ϸ�������������
select cmpid as ��λ���,cmpname as ��λ����,CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END as ����״̬
from tbCompanym
where  ((cmpid not in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='C'
and t2.Status !=2 and TrvType not like '%5%') or 
cmpid  in (select t1.cmpid 
from tbTravelBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='C'
  and t1.status=2))
and cmpid not in (select t1.cmpid  from tbConventionBudget t1
inner join Topway..tbCompanyM t2 on t1.cmpid=t2.cmpid
where t1.OperDate>='2015-01-01' and t1.OperDate<'2016-11-01' and t2.CustomerType='C')

and CustomerType='C')