
--��Ʊ
select  CASE WHEN tbCompanyM.cmpid IS NOT NULL THEN 'UC'+c.cmpcode ELSE cus.custid END
,c.datetime as ��Ʊ����,c.coupno as ���۵���,c.tcode+c.ticketno as Ʊ��,c.totprice as ���ۼ�,c.reti as ��Ʊ����
,(case c.status when 1 then '�Ѹ��ѵ���' else 'δ��' end) as �տ�״̬
,(CASE r.status2 WHEN 1 THEN '��Ʊ���ύ' WHEN 2 THEN '��Ʊ�����' WHEN 5 THEN '��Ʊ������' WHEN 6 THEN '��Ʊ�Ѵ���' WHEN 7 THEN '��Ʊ�ѽ���' WHEN 8 THEN' ��Ʊ������' WHEN 9 THEN '��Ʊ�Ѷ���' ELSE '' END) as ��Ʊ״̬ 
,r.totprice as ��ƱӦ�����
,c.OriginalBillNumber as �˵���
,pform as ���㷽ʽ
,ExamineDate as ��Ʊ�������
from tbcash c
left join tbReti r on r.reno=c.reti
LEFT JOIN dbo.tbCompanyM ON c.cmpcode<>'' and c.cmpcode=tbCompanyM.cmpid 
LEFT JOIN dbo.tbCusholder cus ON c.cmpcode='' AND c.custid=cus.custid
where (c.datetime<'2016-04-01' and c.datetime>='2014-01-01')
and LEN(c.cmpcode)<6
and c.totprice<>0
and c.datetime<>'1900-01-01 00:00:00.000'
and c.coupno<>'00000000'
and c.coupno<>'AS000000000'
and c.coupno<>'000000'


UNION ALL
select  CASE WHEN tbCompanyM.cmpid IS NOT NULL THEN 'UC'+c.cmpcode ELSE cus.custid END
,c.datetime as ��Ʊ����,c.coupno as ���۵���,c.tcode+c.ticketno as Ʊ��,c.totprice as ���ۼ�,c.reti as ��Ʊ����
,(case c.status when 1 then '�Ѹ��ѵ���' else 'δ��' end) as �տ�״̬
,(CASE r.status2 WHEN 1 THEN '��Ʊ���ύ' WHEN 2 THEN '��Ʊ�����' WHEN 5 THEN '��Ʊ������' WHEN 6 THEN '��Ʊ�Ѵ���' WHEN 7 THEN '��Ʊ�ѽ���' WHEN 8 THEN' ��Ʊ������' WHEN 9 THEN '��Ʊ�Ѷ���' ELSE '' END) as ��Ʊ״̬ 
,r.totprice as ��ƱӦ�����
,c.OriginalBillNumber as �˵���
,pform as ���㷽ʽ
,ExamineDate as ��Ʊ�������
from tbcash2013Prev c
left join tbReti r on r.reno=c.reti
LEFT JOIN dbo.tbCompanyM ON c.cmpcode<>'' and c.cmpcode=tbCompanyM.cmpid 
LEFT JOIN dbo.tbCusholder cus ON c.cmpcode='' AND c.custid=cus.custid
where (c.datetime<'2016-04-01' and c.datetime>='2014-01-01')
and LEN(c.cmpcode)<6
and c.totprice<>0
and c.coupno not in (Select coupno from tbcash)
and c.datetime<>'1900-01-01 00:00:00.000'
and c.coupno<>'00000000'
and c.coupno<>'AS000000000'
and c.coupno<>'000000'



--��Ʊ
select CASE WHEN tbCompanyM.cmpid IS NOT NULL THEN 'UC'+c.cmpcode ELSE cus.custid END
,c.datetime as ��Ʊ����,c.coupno as ���۵���,c.tcode+c.ticketno as Ʊ��,c.totprice as ���ۼ�,c.reti as ��Ʊ����
,(case c.status when 1 then '�Ѹ��ѵ���' else 'δ��' end) as �տ�״̬
,(CASE r.status2 WHEN 1 THEN '��Ʊ���ύ' WHEN 2 THEN '��Ʊ�����' WHEN 3 THEN '���δͨ��' WHEN 5 THEN '��Ʊ������' WHEN 6 THEN '��Ʊ�Ѵ���' WHEN 7 THEN '��Ʊ�ѽ���' WHEN 8 THEN' ��Ʊ������' WHEN 9 THEN '��Ʊ�Ѷ���' ELSE '' END) as ��Ʊ״̬ 
,r.totprice as ��ƱӦ�����
,c.OriginalBillNumber as �˵���
,pform as ���㷽ʽ
,ExamineDate as ��Ʊ�������
 from tbReti r 
left join tbcash c on c.reti=r.reno
LEFT JOIN dbo.tbCompanyM ON c.cmpcode<>'' and c.cmpcode=tbCompanyM.cmpid 
LEFT JOIN dbo.tbCusholder cus ON c.cmpcode='' AND c.custid=cus.custid
where (c.datetime<'2016-04-01' and c.datetime<'2014-01-01')
and r.status2 not in (4)
and r.totprice<>0
and LEN(c.cmpcode)<6
and c.datetime<>'1900-01-01 00:00:00.000'
and c.coupno<>'00000000'
and c.coupno<>'AS000000000'
and c.coupno<>'000000'
--and c.coupno in('00000000','AS000000000','000000')











select prdate as ��ӡ����,yf.CoupNo as ���۵���,price as ���ۼ� ,sform as ���㷽ʽ
--into #p2
from tbHtlcoupYf yf
where (prdate<'2016-04-01' and prdate>='2014-01-01')
and yf.status<>-2
--and cf.cwstatus=0
and LEN(yf.cmpid)<6
--and CoupNo  like ('%-%')

select * from #p2

select * from tbHtlcoupYf where CoupNo in (Select '-'+���۵��� from #p1)



select t1.TrvId as Ԥ�㵥��,t1.Custid as ��Ա���,TrvCoupNo as ���۵���,t2.XsPrice as ���ۼ�,t1.OperDate as ¼��ʱ��,t2.OperDate as ����ʱ�� from tbTravelBudget t1
left join tbTrvCoup t2 on t2.TrvId=t1.TrvId
where (t1.OperDate>='2014-01-01' and t1.OperDate<'2016-04-01')
and t1.Status<>2
and XsPrice<>0




