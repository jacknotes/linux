/*
UC016713   �Ϻ����ɿ�����ϵͳ���޹�˾
UC018408   �Ϻ����ɿ�����ϵͳ���޹�˾�з��ֹ�˾
UC018541  ���ɿˣ����ݣ��ŷ�ϵͳ���޹�˾
UC020085  ���ɿ�������ҵ�����ݣ����޹�˾
UC020273  ���ɿ��괨�����죩����ϵͳ���޹�˾
UC020636  ���ɿˣ��й������޹�˾�����ֹ�˾
UC020637  ���ɿˣ�����������ϵͳ���޹�˾
UC020638  ���ɿ�-�����գ�����������ϵͳ���޹�˾
UC020643  �ൺ���ɿ˸��������㲿�����޹�˾
UC020655  ���ɿ�һ�����ɣ������������㲿�����޹�˾
UC020665  �ɶ����ɿ˸��������㲿�����޹�˾
UC020742  ���ɿ˸��ɣ���������㲿�����޹�˾
UC020685  ��ɽ���ɿ�һ�����������㲿�����޹�˾
*/

--�����з�Ӷ����˰�յ���
select cmpcode,convert(varchar(7),datetime,120) �·�,Convert(decimal(18,2),sum(amount),0) as ����,SUM(xfprice) as ��Ӷ,SUM(tax) ˰��,count(1) ����
,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS ƽ���ۿ���
FROM    V_TicketInfo
WHERE   cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685')  
		AND ( datetime BETWEEN '2018-01-01' AND '2019-03-31')
        AND ( reti = '' )
        AND ( inf = 0 )
        and xfprice<>0
        and tickettype='����Ʊ'
group by convert(varchar(7),datetime,120),cmpcode
order by �·� 



--���ڴ�ͻ�Э������˰�յ���
select cmpcode,(case ride when 'mu'  then 'MU' when 'fm' then 'MU'  else ride end) ��˾,convert(varchar(7),datetime,120) �·�,Convert(decimal(18,2),sum(amount),0) as ����,
Convert(decimal(18,2),SUM(tax),0) ˰��,count(1) ����
,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS ƽ���ۿ���
FROM    V_TicketInfo
WHERE   cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685')        
		AND ( datetime BETWEEN '2018-01-01' AND '2019-03-31')
        AND ( reti = '' )
        AND ( inf = 0 )
        and ride in ('mu','fm','cz','ho')
        and tickettype='����Ʊ'
group by convert(varchar(7),datetime,120),cmpcode,(case ride when 'mu'  then 'MU' when 'fm' then 'MU'  else ride end)
order by �·�



--���ھ��òպ���top5�¶ȱ�����˰
select cmpcode,route,convert(varchar(7),datetime,120) �·�,Convert(decimal(18,2),sum(price),0) as ����,count(1) ����
,Convert(decimal(18,2),sum(price)*1.0/count(1),0) as ƽ��Ʊ��
 ,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS ƽ���ۿ���
FROM    topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
WHERE   cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685')  
and i3.cabintype like '%���ò�%'    
		AND ( datetime BETWEEN '2019-01-01' AND '2019-03-31')
        AND ( reti = '' )
        AND ( inf = 0 )
        and tickettype='����Ʊ'
        and route in('�Ϻ�����-�����׶�','�����׶�-�Ϻ�����','�Ϻ�����-����','����-�Ϻ�����','�Ϻ��ֶ�-����','����-�Ϻ��ֶ�'
        ,'�Ϻ�����-�ɶ�','�ɶ�-�Ϻ�����','�Ϻ�����-����','����-�Ϻ�����','')
group by convert(varchar(7),datetime,120),cmpcode,route
order by �·�


--����������·��������˰
          --��������
if OBJECT_ID('tempdb..#lc') is not null drop table #lc
select cmpcode,route,Convert(decimal(18,2),sum(price),0) as ����,count(1) ����
,Convert(decimal(18,2),sum(price)*1.0/count(1),0) as ƽ��Ʊ��
 ,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS ƽ���ۿ���
 into #lc
FROM    topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
WHERE   cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and (i3.cabintype like '%ͷ��%' or i3.cabintype like '%����%') 
		AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31')
        AND ( reti = '' )
        AND ( inf = 0 )
        and tickettype='����Ʊ'
group by cmpcode,route
order by ���� desc


            --������
if OBJECT_ID('tempdb..#zxl') is not null drop table #zxl
select cmpcode,SUM(price) ������ 
into #zxl
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31')
and (i3.cabintype like '%ͷ��%' or i3.cabintype like '%����%') 
AND ( reti = '' )
AND ( inf = 0 ) 
and tickettype='����Ʊ'
group by cmpcode
   
                 --����
select lc.cmpcode,route,����,����,ƽ��Ʊ��,����/������ ����ռ��,ƽ���ۿ���
from #lc lc
inner join #zxl zxl on lc.cmpcode=zxl.cmpcode


--���ھ��ò���·��������˰
               --���ò�����
if OBJECT_ID('tempdb..#lc') is not null drop table #lc
select cmpcode,route,Convert(decimal(18,2),sum(price),0) as ����,count(1) ����
,Convert(decimal(18,2),sum(price)*1.0/count(1),0) as ƽ��Ʊ��
 ,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS ƽ���ۿ���
 into #lc
FROM    topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
WHERE   cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and i3.cabintype like '%���ò�%'
		AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31')
        AND ( reti = '' )
        AND ( inf = 0 )
        and tickettype='����Ʊ'
group by cmpcode,route
order by ���� desc


         --������
if OBJECT_ID('tempdb..#zxl') is not null drop table #zxl
select cmpcode,SUM(price) ������ 
into #zxl
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31')
and i3.cabintype like '%���ò�%' 
AND ( reti = '' )
AND ( inf = 0 )
and tickettype='����Ʊ' 
group by cmpcode
   
          --����
select lc.cmpcode,route,����,����,ƽ��Ʊ��,����/������ ����ռ��,ƽ���ۿ���
from #lc lc
inner join #zxl zxl on lc.cmpcode=zxl.cmpcode



--���ں��չ�˾�ֲ�����˰
               --���ò�����
if OBJECT_ID('tempdb..#hs') is not null drop table #hs
select cmpcode,ride,Convert(decimal(18,2),sum(price),0) as ����,count(1) ����
 ,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS ƽ���ۿ���
 into #hs
FROM    topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
WHERE   cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and i3.cabintype  like '%���ò�%' 
		AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
        AND ( reti = '' )
        AND ( inf = 0 )
        and tickettype='����Ʊ'
group by cmpcode,ride
order by ���� desc



          --��������
if OBJECT_ID('tempdb..#hs2') is not null drop table #hs2
select cmpcode,ride,Convert(decimal(18,2),sum(price),0) as ����,count(1) ����
 ,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS ƽ���ۿ���
 into #hs2
FROM    topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
WHERE   cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and (i3.cabintype like '%ͷ��%' or i3.cabintype like '%����%')
		AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
        AND ( reti = '' )
        AND ( inf = 0 )
        and tickettype='����Ʊ'
group by cmpcode,ride
order by ���� desc



         --���ò�������
if OBJECT_ID('tempdb..#zxl2') is not null drop table #zxl2
select cmpcode,SUM(price) ������ 
into #zxl2
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
and i3.cabintype like '%���ò�%' 
AND reti = '' 
AND inf = 0 
and tickettype='����Ʊ'
group by cmpcode

         --���ղ�������
if OBJECT_ID('tempdb..#zxl3') is not null drop table #zxl3
select cmpcode,SUM(price) ������ 
into #zxl3
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
and (i3.cabintype like '%ͷ��%' or i3.cabintype like '%����%')
AND ( reti = '' )
AND ( inf = 0 ) 
and tickettype='����Ʊ'
group by cmpcode
   
          --���òջ���
select hs.cmpcode,ride,����,����,����/������ ����ռ��,ƽ���ۿ���
from #hs hs
inner join #zxl2 zxl2 on hs.cmpcode=zxl2.cmpcode


          --���ղջ���
select hs2.cmpcode,ride,����,����,����/������ ����ռ��,ƽ���ۿ���
from #hs2 hs2
inner join #zxl3 zxl3 on hs2.cmpcode=zxl3.cmpcode


--������ǰ��Ʊ���ݷ�������˰
     
     --���ò�
SELECT cmpcode,DAYSFLAG,SUM(price) ����˰����,COUNT(1) �ϼ�����,''����ռ��, SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) ���ò�ƽ���ۿ���  FROM (
SELECT 
(CASE WHEN DATEDIFF(DD,c.[datetime],c.begdate) BETWEEN 0 AND 2 THEN 1
	WHEN DATEDIFF(DD,c.[datetime],c.begdate) BETWEEN 3 AND 6 THEN 2
	WHEN DATEDIFF(DD,c.[datetime],c.begdate) BETWEEN 7 AND 13 THEN 3
	WHEN DATEDIFF(DD,c.[datetime],c.begdate) BETWEEN 14 AND 20 THEN 4
	WHEN DATEDIFF(DD,c.[datetime],c.begdate) >20 THEN 5 END) DAYSFLAG,
totprice,price,priceinfo ,cmpcode
FROM Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
WHERE cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
AND c.inf=0
and i3.cabintype like '%���ò�%' 
and reti=''
and tickettype='����Ʊ'
AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
) T
GROUP BY DAYSFLAG,cmpcode
order by DAYSFLAG

    --����
SELECT cmpcode,DAYSFLAG,SUM(price) ����˰����,COUNT(1) �ϼ�����,''����ռ��, SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) ����ƽ���ۿ���  FROM (
SELECT 
(CASE WHEN DATEDIFF(DD,c.[datetime],c.begdate) BETWEEN 0 AND 2 THEN 1
	WHEN DATEDIFF(DD,c.[datetime],c.begdate) BETWEEN 3 AND 6 THEN 2
	WHEN DATEDIFF(DD,c.[datetime],c.begdate) BETWEEN 7 AND 13 THEN 3
	WHEN DATEDIFF(DD,c.[datetime],c.begdate) BETWEEN 14 AND 20 THEN 4
	WHEN DATEDIFF(DD,c.[datetime],c.begdate) >20 THEN 5 END) DAYSFLAG,
totprice,price,priceinfo ,cmpcode
FROM Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
WHERE cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
AND c.inf=0
and tickettype='����Ʊ'
and (i3.cabintype like '%ͷ��%' or i3.cabintype like '%����%')
and reti=''
AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
) T
GROUP BY DAYSFLAG,cmpcode
order by DAYSFLAG


--���ڻ�Ʊ���ų�Ʊ���ݷ�������˰

          --���ò�
select cmpcode,(case Department when 'null' then '' when '' then '' else Department end )����,SUM(price) as ����,COUNT(1) as ����,
AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE price/priceinfo END) AS zkpercent,AVG(DATEDIFF(day,datetime,c.begdate)) as ƽ����Ʊ����
,'' ����ռ��
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
AND c.inf ='0'
and c.reti=''
and c.tickettype='����Ʊ'
and i3.cabintype LIKE'%���ò�%'
group by (case Department when 'null' then '' when '' then '' else Department end ),cmpcode
order by ���� desc

           --����
select cmpcode,(case Department when 'null' then '' when '' then '' else Department end )����,SUM(price) as ����,COUNT(1) as ����,
AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE price/priceinfo END) AS zkpercent,AVG(DATEDIFF(day,datetime,c.begdate)) as ƽ����Ʊ����
,'' ����ռ��
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
AND c.inf ='0'
and c.reti=''
and c.tickettype='����Ʊ'
and (i3.cabintype LIKE'%�����%' or i3.cabintype LIKE'%ͷ�Ȳ�%')
group by (case Department when 'null' then '' when '' then '' else Department end ),cmpcode
order by ���� desc


--���ڻ�Ʊ�����˸����ݷ�������˰
         --��������
 if OBJECT_ID('tempdb..#gq') is not null drop table  #gq     
select cmpcode,pasname ����,(case Department when 'null' then '' when '' then '' else Department end ) ����,COUNT(1)��������,SUM(totprice)���ڷ���
into #gq
from Topway..tbcash c
where cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
and inf=0
and (tickettype like '%����%' or tickettype like '%����%')
group by cmpcode,pasname,(case Department when 'null' then '' when '' then '' else Department end )

        --��Ʊ
if OBJECT_ID('tempdb..#tp') is not null drop table  #tp         
select r.cmpcode,c.pasname ����,(case Department when 'null' then '' when '' then '' else Department end ) ����,count(r.coupno) ��Ʊ����,SUM(r.totprice) ��Ʊ����
into #tp
from Topway..tbReti r with (nolock)
left join Topway..tbcash c on c.reti=r.reno
where r.cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and ( r.datetime BETWEEN '2018-01-01' AND '2018-06-30')
and r.inf=0
and status2 not in('4')
group by r.cmpcode,c.pasname,(case Department when 'null' then '' when '' then '' else Department end )

         --������
 if OBJECT_ID('tempdb..#zsj') is not null drop table #zsj         
select cmpcode,pasname ����,(case Department when 'null' then '' when '' then '' else Department end ) ����,
SUM(price)��Ʊ���� ,COUNT(1)��Ʊ����,Convert(decimal(18,2),sum(price)*1.0/count(1),0)  ƽ��Ʊ��,
SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) ƽ���ۿ���,AVG(DATEDIFF(day,datetime,begdate))ƽ����Ʊ����
into #zsj
from Topway..tbcash 
where cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and inf=0
and ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
and coupno not in ('AS001468529',
'AS001533683',
'AS001542216',
'AS001598971')
group by cmpcode,pasname,(case Department when 'null' then '' when '' then '' else Department end )


select zsj.cmpcode,zsj.����,zsj.����,��Ʊ����,��Ʊ����,ƽ��Ʊ��,ƽ���ۿ���,
ƽ����Ʊ����,isnull(��������,'0')��������,isnull(���ڷ���,'0')���ڷ���,isnull(��Ʊ����,'0')��Ʊ����,isnull(��Ʊ����,'0')��Ʊ����
from #zsj zsj
left join #gq gq on gq.cmpcode=zsj.cmpcode and gq.����=zsj.����
left join #tp tp on tp.cmpcode=zsj.cmpcode and tp.����=zsj.����
order by ��Ʊ���� desc