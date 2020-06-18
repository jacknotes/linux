
--����
IF OBJECT_ID('tempdb.dbo.#mileage') IS NOT NULL DROP TABLE #mileage
select DISTINCT rtrim(cityfrom)+'-'+rtrim(cityto) route,mileage,kilometres 
--into #mileage
from tbmileage

IF OBJECT_ID('tempdb.dbo.#tbcash1') IS NOT NULL DROP TABLE #tbcash1
select coupno as ���۵���,ride+flightno as �����,datetime as ��Ʊ����
,case SUBSTRING(route,1,CHARINDEX('-',route)-1) when '�Ϻ��ֶ�' then '�Ϻ�' when '�Ϻ�����' then '�Ϻ�' when '�����׶�' then '����' when '������Է' then '����' when '��������' then '����' 
when '��������' then '����' when '����' then '��ͷ' when '�人���' then '�人' when '����' then '��˫����' when '�����첼����' then '�����첼' when '�º�' then 'â��' when '˼é' then '�ն�' when '÷��' then '÷��'
else SUBSTRING(route,1,CHARINDEX('-',route)-1) end as ����
,case REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) when '�Ϻ��ֶ�' then '�Ϻ�' when '�Ϻ�����' then '�Ϻ�' when '�����׶�' then '����' when '������Է' then '����' when '��������' then '����' 
when '��������' then '����' when '����' then '��ͷ' when '�人���' then '�人' when '����' then '��˫����' when '�����첼����' then '�����첼' when '�º�' then 'â��' when '˼é' then '�ն�' when '÷��' then '÷��'
else  REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) end as ����
,route as �г�
,t_source as ��Ӧ����Դ
into #tbcash1
from tbcash c
where cmpcode='019392'
and (datetime>='2018-01-01' and datetime<'2019-01-01')
and inf=0
and route like ('%-%')
and reti=''
and tickettype='����Ʊ'
order by datetime

IF OBJECT_ID('tempdb.dbo.#tbcash') IS NOT NULL DROP TABLE #tbcash
select *,����+'-'+���� as route2,����+'-'+���� as route3
into #tbcash
from #tbcash1


IF OBJECT_ID('tempdb.dbo.#tt') IS NOT NULL DROP TABLE #tt
select ���۵���,tbcash.�г�,��Ʊ����,mileage,kilometres
into #tt
from #tbcash tbcash
left join #mileage mileage on mileage.route=tbcash.route2 or mileage.route=tbcash.route3

select * from #tt
where kilometres is null



--select * from tbmileage where cityfrom='�ն�' or cityto='�ն�'
--select * from tbmileage where cityfrom='�ն�' and cityto='����'

--���ʳ�Ʊ��Ϣ
select coupno as ���۵���,pasname �˻���,tcode+ticketno Ʊ��,ride+flightno ����,REPLACE(route,'-','') �г�
into #test
from Topway..tbcash 
where cmpcode='016485' 
and (datetime>='2018-01-01' and datetime<'2019-01-01') 
and reti=''
and tickettype not in ('���ڷ�', '���շ�','��������')
and route not like'%����%'
and route not like'%����%'
and route not like'%��Ʊ%'
and inf=1 

--����г�
select ���۵���,�˻���,Ʊ��,����,SUBSTRING(�г�,1,3)�г�1, SUBSTRING(�г�,4,3)�г�2, SUBSTRING(�г�,7,3)�г�3, SUBSTRING(�г�,10,3)�г�4
into #test1
from #test 

--�г�1
select * 
into #xc1
from #test1 test
inner join Topway..tbmileage t on (t.CityFromCode=�г�1 and t.CityToCode=�г�2)

--�г�2
select * 
into #xc2
from #test1 test
inner join Topway..tbmileage t on (t.CityFromCode=�г�2 and t.CityToCode=�г�3)

--�г�3
select * 
into #xc3
from #test1 test
inner join Topway..tbmileage t on (t.CityFromCode=�г�3 and t.CityToCode=�г�4)

--����
select xc1.�˻���,xc1.����,xc1.Ʊ��,xc1.mileage+isnull(xc2.mileage,0)+isnull(xc3.mileage,0) Ӣ��,
xc1.kilometres+isnull(xc2.kilometres,0)+isnull(xc3.kilometres,0)����  from #xc1 xc1
left join #xc2 xc2 on xc2.���۵���=xc1.���۵��� and xc2.Ʊ��=xc1.Ʊ�� and xc2.�˻���=xc1.�˻���
left join #xc3 xc3 on xc3.���۵���=xc1.���۵��� and xc3.Ʊ��=xc1.Ʊ�� and xc3.�˻���=xc1.�˻���
order by Ӣ��