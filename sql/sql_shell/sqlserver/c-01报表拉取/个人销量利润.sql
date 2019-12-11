select 'UC'+t1.cmpcode as ��λ���,SUM(ISNULL(t1.totprice,0)-ISNULL(t2.totprice,0)) as ��Ʊ���� 
,SUM(ISNULL(t1.profit,0)+ISNULL(t2.profit,0)) as ��Ʊ����
from tbcash t1
left join tbReti t2 on t1.reti=t2.reno
where t1.cmpcode=''
and (t1.datetime>='2015-01-01' and t1.datetime<'2016-01-01')
and pform<>'�½�'
AND	LEN(CASE WHEN t1.coupno LIKE '000000%' OR t1.coupno = 'AS000000000' THEN '' ELSE t1.cmpcode END)=''
group by 'UC'+t1.cmpcode
order by 'UC'+t1.cmpcode

select 'UC'+h1.cmpid as ��λ���,sum(h1.price) as �Ƶ����� 
,sum(h1.totprofit) as �Ƶ�����
from tbHtlcoupYf h1
where h1.cmpid=''
and (h1.prdate>='2015-01-01' and h1.prdate<'2016-01-01')
and status<>-2
group by 'UC'+h1.cmpid
order by 'UC'+h1.cmpid

select 'UC'+l1.cmpid as ��λ���,SUM(l1.XsPrice) as ��������
,SUM(l1.Profit) as ��������
from tbTrvCoup l1
where l1.cmpid =''
and (l1.OperDate>='2015-01-01' and l1.OperDate<'2016-01-01')
group by 'UC'+l1.cmpid
order by 'UC'+l1.cmpid

select 'UC'+c1.cmpid as ��λ���,SUM(c1.XsPrice) as ��������
,sum(c1.Profit) as ��������
from tbConventionCoup c1
where c1.cmpid =''
and (c1.OperDate>='2015-01-01' and c1.OperDate<'2016-01-01')
group by 'UC'+c1.cmpid
order by 'UC'+c1.cmpid


select 'UC'+trainO.cmpid as ��λ���,FLOOR(isnull(sum(RealPrice + trainU.Fuprice + PrintPrice),0)) -FLOOR(isnull(sum(trainU.RealPrice+r.Fee),0)) as ��Ʊ����
,FLOOR(isnull(Sum(trainU.Fuprice - CASE Tsource WHEN '������' THEN 5 when '�߲�����' then 1 ELSE 0 END),0))+ FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0))as ��Ʊ����
from  tbTrainTicketInfo trainO 
LEFT JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo
left join Train_ReturnTicket r on r.TickOrderDetailID = trainU.ID
where trainO.cmpid =''
and (trainO.CreateDate>='2015-01-01' and trainO.CreateDate<'2016-01-01')
and (r.AuditTime >='2015-01-01' AND r.AuditTime<'2016-01-01')
and trainO.Isdisplay=0
group by 'UC'+trainO.cmpid
order by 'UC'+trainO.cmpid



