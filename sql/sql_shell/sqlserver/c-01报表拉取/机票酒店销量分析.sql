IF OBJECT_ID('tempdb.dbo.#p1') IS NOT NULL DROP TABLE #p1
select t3.cmpcode,count(*) as ��Ʊ����
,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as ��Ʊ����
,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as ��Ʊ����
into #P1
from tbcash t3
left join tbreti t2 on t3.coupno=t2.coupno
where t3.datetime>='2018-07-01' and t3.datetime<'2018-08-01'
group by t3.cmpcode

IF OBJECT_ID('tempdb.dbo.#p2') IS NOT NULL DROP TABLE #p2
select cmpid,COUNT(*) as �Ƶ�����
,sum(h1.price) as �Ƶ�����
,sum(h1.totprofit) as �Ƶ�����
into #p2
from tbHtlcoupYf h1
where prdate>='2018-07-01' and prdate<'2018-08-01'
group by cmpid

IF OBJECT_ID('tempdb.dbo.#p3') IS NOT NULL DROP TABLE #p3
select m.cmpid,m.cmpname
,isnull(��Ʊ����,0)��Ʊ����,isnull(��Ʊ����,0)��Ʊ����,isnull(��Ʊ����,0)��Ʊ����
,isnull(�Ƶ�����,0)�Ƶ�����,isnull(�Ƶ�����,0)�Ƶ�����,isnull(�Ƶ�����,0)�Ƶ�����
into #p3
from tbCompanyM m
left join #p1 p1 on p1.cmpcode=m.cmpid
left join #p2 p2 on p2.cmpid=m.cmpid

IF OBJECT_ID('tempdb.dbo.#p4') IS NOT NULL DROP TABLE #p4
select cmpid,cmpname,��Ʊ����+�Ƶ����� as ������,��Ʊ����+�Ƶ����� as ������
,(��Ʊ����+�Ƶ�����)/nullif((��Ʊ����+�Ƶ�����),0) as ë����
,��Ʊ����,��Ʊ����,��Ʊ����,��Ʊ����/NULLIF(��Ʊ����,0)as ��Ʊë����,�Ƶ�����,�Ƶ�����,�Ƶ�����,�Ƶ�����/NULLIF(�Ƶ�����,0)as �Ƶ�ë����
into #p4
from #p3
where cmpid<>''
and (��Ʊ����<>0 or �Ƶ�����<>0)




--����Ʊ
select * from 
(select '����С��10000' as ������Χ,COUNT(*)��λ����,SUM(������)������,SUM(������)������,SUM(������)/SUM(������) ë���� from #p4
where ��Ʊ����<>0 and �Ƶ�����=0
and ������<10000
UNION ALL
select '����10000-20000' as ������Χ,COUNT(*)��λ����,SUM(������)������,SUM(������)������,SUM(������)/SUM(������) ë���� from #p4
where ��Ʊ����<>0 and �Ƶ�����=0
and ������>=10000 and ������<20000
UNION ALL
select '��������20000' as ������Χ,COUNT(*)��λ����,SUM(������)������,SUM(������)������,SUM(������)/SUM(������) ë���� from #p4
where ��Ʊ����<>0 and �Ƶ�����=0
and ������>=20000
UNION ALL
select '�ϼ�' as ������Χ,COUNT(*)��λ����,SUM(������)������,SUM(������)������,SUM(������)/SUM(������) ë���� from #p4
where ��Ʊ����<>0 and �Ƶ�����=0
) t1



--���Ƶ�
select * from 
(select '����С��10000' as ������Χ,COUNT(*)��λ����,SUM(������)������,SUM(������)������,SUM(������)/SUM(������) ë���� from #p4
where �Ƶ�����<>0 and ��Ʊ����=0
and ������<10000
UNION ALL
select '����10000-20000' as ������Χ,COUNT(*)��λ����,SUM(������)������,SUM(������)������,SUM(������)/SUM(������) ë���� from #p4
where �Ƶ�����<>0 and ��Ʊ����=0
and ������>=10000 and ������<20000
UNION ALL
select '��������20000' as ������Χ,COUNT(*)��λ����,SUM(������)������,SUM(������)������,SUM(������)/SUM(������) ë���� from #p4
where �Ƶ�����<>0 and ��Ʊ����=0
and ������>=20000
UNION ALL
select '�ϼ�' as ������Χ,COUNT(*)��λ����,SUM(������)������,SUM(������)������,SUM(������)/SUM(������) ë���� from #p4
where �Ƶ�����<>0 and ��Ʊ����=0
) t2

--��Ʊ�Ƶ�
select * from 
(select '����С��10000' as ������Χ,COUNT(*)��λ����,SUM(������)������,SUM(������)������,SUM(������)/SUM(������) ë���� from #p4
where ��Ʊ����<>0 and �Ƶ�����<>0
and ������<10000
UNION ALL
select '����10000-20000' as ������Χ,COUNT(*)��λ����,SUM(������)������,SUM(������)������,SUM(������)/SUM(������) ë���� from #p4
where ��Ʊ����<>0 and �Ƶ�����<>0
and ������>=10000 and ������<20000
UNION ALL
select '��������20000' as ������Χ,COUNT(*)��λ����,SUM(������)������,SUM(������)������,SUM(������)/SUM(������) ë���� from #p4
where ��Ʊ����<>0 and �Ƶ�����<>0
and ������>=20000
UNION ALL
select '�ϼ�' as ������Χ,COUNT(*)��λ����,SUM(������)������,SUM(������)������,SUM(������)/SUM(������) ë���� from #p4
where ��Ʊ����<>0 and �Ƶ�����<>0
) t3


