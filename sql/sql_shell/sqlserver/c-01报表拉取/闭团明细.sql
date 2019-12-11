--����
select t1.TrvId as Ԥ�㵥��,t1.Sales as ����ҵ�����,t1.JiDIao as ����֧����,introducer as ����֧����,t2.TrvCpName as ��Ʒ����,t2.OperDate as ��������,t2.EndDate as ��������,t1.OperDate as �������� 
from tbTrvCoup t1
inner join tbTravelBudget t2 on t1.TrvId=t2.TrvId
inner join Emppwd t3 on t1.Sales=t3.empname 
where t1.OperDate >'2016-09-01' and t1.OperDate<'2016-10-01' and t2.TrvType not like '%5%' and t2.Status !=2 
--and t2.OperDate>='2016-07-01'
order by t1.OperDate

begin tran
--update tbTravelBudget set introducer=t1.Sales+'-'+t3.idnumber+'-��Ӫ��'
select t1.TrvId as Ԥ�㵥��,t1.Sales as ����ҵ�����,t1.JiDIao as ����֧����,introducer as ����֧����,t1.Sales+'-'+t3.idnumber+'-��Ӫ��'
from tbTrvCoup t1
inner join tbTravelBudget t2 on t1.TrvId=t2.TrvId
inner join Emppwd t3 on t1.Sales=t3.empname 
where t1.OperDate >'2016-08-01' and t1.OperDate<'2016-10-01'  and t2.Status !=2 and t2.OperDate>='2016-07-01'

commit tran

--�������
select t1.TrvId as Ԥ�㵥��,t1.Sales as ����ҵ�����,t1.JiDIao as ����֧����,introducer as ����֧����,t2.TrvCpName as ��Ʒ����,t2.OperDate as ��������,t2.EndDate as ��������,t1.OperDate as �������� 
from tbTrvCoup t1
inner join tbTravelBudget t2 on t1.TrvId=t2.TrvId
where t1.OperDate >'2016-09-01' and t1.OperDate<'2016-10-01' and t2.TrvType  like '%5%' and t2.Status !=2 and t2.OperDate>='2016-07-01'
order by t1.OperDate

--update tbTrvCoup set JiDIao='����'
where TrvId in (select t1.TrvId 
from tbTrvCoup t1
inner join tbTravelBudget t2 on t1.TrvId=t2.TrvId
where t1.OperDate >'2016-08-01' and t1.OperDate<'2016-09-01' and t2.TrvType  like '%5%' and t2.Status !=2)
--����
select  t1.OperDate as ��������,t1.ConventionId as Ԥ�㵥��,t1.ConventionCpName as ��λ����,t3.GysSource as ��Ӧ����Դ,t1.Sales as �������,t1.FinancialCharges as �ʽ����,t5.xsprice as �տ���,t1.JsZPrice as �����,t5.infotax as ����˰��,
t5.invoicetax as ����˰��,t5.Disct as ������,t5.Profit as ����, '' as ������
from tbConventionCoup t1
left join tbConventionBudget t2 on t1.ConventionId=t2.ConventionId
left join Topway..tbConventionJS t3 on t3.ConventionId=t1.ConventionId
left join Topway..tbConventionKhSk t4 on t4.ConventionId=t1.ConventionId
left join Topway..tbConventionCoup t5 on t5.ConventionId=t1.ConventionId
where t1.OperDate >='2018-12-01' and t1.OperDate<'2019-01-01' and t2.Status !=2 
order by t1.OperDate

