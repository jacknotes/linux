/*14�����ɿ�2019���һ���ȣ� UC016448ֻ�ɱ�����ΪCA ������
UC016448
UC018541
UC020085 
UC020273 
UC016713 
UC020636 
UC020637 
UC020638 
UC020643 
UC020655 
UC020665 
UC020685 
UC020742 
UC016448  
*/
--����
if OBJECT_ID('tempdb..#gnsj') is not null drop table #gnsj
select 'UC'+cmpcode UC��,u.Name ��˾����,sum(price) ��������˰,sum(tax) ˰��,COUNT(1) ����,sum(price)/COUNT(1) ƽ��Ʊ��,
sum(price)/SUM(convert(decimal(18,3),priceinfo)) �ۿ���,AVG(DATEDIFF(DD,datetime,begdate)) ƽ����Ʊ���� 
into #gnsj
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2019-01-01'
and datetime<'2019-04-01'
and cmpcode='016448'
AND inf=0
--and CostCenter='CA'
GROUP BY 'UC'+cmpcode,u.Name

if OBJECT_ID('tempdb..#gnhs') is not null drop table #gnhs
select top 1  'UC'+cmpcode UC��,u.Name ��˾����,ride ��˾,sum(price) ��������˰
into #gnhs
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2019-01-01'
and datetime<'2019-04-01'
and cmpcode='016448'
AND inf=0
--and CostCenter='CA'
GROUP BY 'UC'+cmpcode,u.Name,ride
order by ��������˰ desc


--����
if OBJECT_ID('tempdb..#gjsj') is not null drop table #gjsj
select 'UC'+cmpcode UC��,u.Name ��˾����,sum(price) ��������˰,sum(tax) ˰��,COUNT(1) ����,
AVG(DATEDIFF(DD,datetime,begdate)) ƽ����Ʊ���� 
into #gjsj
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2019-01-01'
and datetime<'2019-04-01'
and  cmpcode='016448'
AND inf=1
--and CostCenter='CA'
GROUP BY 'UC'+cmpcode,u.Name


--select * from #gjsj

select s.UC��,s.��˾����,s.��������˰,s.˰��,s.����,s.ƽ��Ʊ��,�ۿ���,s.ƽ����Ʊ����,��˾,h.��������˰/s.��������˰ ռ�ȱ���
,j.��������˰,j.˰��,j.����,j.ƽ����Ʊ���� 
from #gnsj s
left join #gnhs h on s.UC��=h.UC��
left join #gjsj j on s.UC��=j.UC��
