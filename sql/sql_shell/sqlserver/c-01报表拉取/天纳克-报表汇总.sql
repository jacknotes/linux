/*
UC016713   上海天纳克排气系统有限公司
UC018408   上海天纳克排气系统有限公司研发分公司
UC018541  天纳克（苏州）排放系统有限公司
UC020085  天纳克汽车工业（广州）有限公司
UC020273  天纳克陵川（重庆）排气系统有限公司
UC020636  天纳克（中国）有限公司大连分公司
UC020637  天纳克（大连）排气系统有限公司
UC020638  天纳克-埃贝赫（大连）排气系统有限公司
UC020643  青岛天纳克富晟汽车零部件有限公司
UC020655  天纳克一汽富晟（长春）汽车零部件有限公司
UC020665  成都天纳克富晟汽车零部件有限公司
UC020742  天纳克富晟（天津）汽车零部件有限公司
UC020685  佛山天纳克一汽富晟汽车零部件有限公司
*/

--国内有返佣销量税收单列
select cmpcode,convert(varchar(7),datetime,120) 月份,Convert(decimal(18,2),sum(amount),0) as 销量,SUM(xfprice) as 返佣,SUM(tax) 税收,count(1) 张数
,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS 平均折扣率
FROM    V_TicketInfo
WHERE   cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685')  
		AND ( datetime BETWEEN '2018-01-01' AND '2019-03-31')
        AND ( reti = '' )
        AND ( inf = 0 )
        and xfprice<>0
        and tickettype='电子票'
group by convert(varchar(7),datetime,120),cmpcode
order by 月份 



--国内大客户协议销量税收单列
select cmpcode,(case ride when 'mu'  then 'MU' when 'fm' then 'MU'  else ride end) 航司,convert(varchar(7),datetime,120) 月份,Convert(decimal(18,2),sum(amount),0) as 销量,
Convert(decimal(18,2),SUM(tax),0) 税收,count(1) 张数
,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS 平均折扣率
FROM    V_TicketInfo
WHERE   cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685')        
		AND ( datetime BETWEEN '2018-01-01' AND '2019-03-31')
        AND ( reti = '' )
        AND ( inf = 0 )
        and ride in ('mu','fm','cz','ho')
        and tickettype='电子票'
group by convert(varchar(7),datetime,120),cmpcode,(case ride when 'mu'  then 'MU' when 'fm' then 'MU'  else ride end)
order by 月份



--国内经济舱航线top5月度报表不含税
select cmpcode,route,convert(varchar(7),datetime,120) 月份,Convert(decimal(18,2),sum(price),0) as 销量,count(1) 张数
,Convert(decimal(18,2),sum(price)*1.0/count(1),0) as 平均票价
 ,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS 平均折扣率
FROM    topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
WHERE   cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685')  
and i3.cabintype like '%经济舱%'    
		AND ( datetime BETWEEN '2019-01-01' AND '2019-03-31')
        AND ( reti = '' )
        AND ( inf = 0 )
        and tickettype='电子票'
        and route in('上海虹桥-北京首都','北京首都-上海虹桥','上海虹桥-广州','广州-上海虹桥','上海浦东-长春','长春-上海浦东'
        ,'上海虹桥-成都','成都-上海虹桥','上海虹桥-重庆','重庆-上海虹桥','')
group by convert(varchar(7),datetime,120),cmpcode,route
order by 月份


--国内两舱线路排名不含税
          --两舱数据
if OBJECT_ID('tempdb..#lc') is not null drop table #lc
select cmpcode,route,Convert(decimal(18,2),sum(price),0) as 销量,count(1) 张数
,Convert(decimal(18,2),sum(price)*1.0/count(1),0) as 平均票价
 ,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS 平均折扣率
 into #lc
FROM    topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
WHERE   cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and (i3.cabintype like '%头等%' or i3.cabintype like '%公务%') 
		AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31')
        AND ( reti = '' )
        AND ( inf = 0 )
        and tickettype='电子票'
group by cmpcode,route
order by 销量 desc


            --总销量
if OBJECT_ID('tempdb..#zxl') is not null drop table #zxl
select cmpcode,SUM(price) 总销量 
into #zxl
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31')
and (i3.cabintype like '%头等%' or i3.cabintype like '%公务%') 
AND ( reti = '' )
AND ( inf = 0 ) 
and tickettype='电子票'
group by cmpcode
   
                 --汇总
select lc.cmpcode,route,销量,张数,平均票价,销量/总销量 销量占比,平均折扣率
from #lc lc
inner join #zxl zxl on lc.cmpcode=zxl.cmpcode


--国内经济舱线路排名不含税
               --经济舱数据
if OBJECT_ID('tempdb..#lc') is not null drop table #lc
select cmpcode,route,Convert(decimal(18,2),sum(price),0) as 销量,count(1) 张数
,Convert(decimal(18,2),sum(price)*1.0/count(1),0) as 平均票价
 ,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS 平均折扣率
 into #lc
FROM    topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
WHERE   cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and i3.cabintype like '%经济舱%'
		AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31')
        AND ( reti = '' )
        AND ( inf = 0 )
        and tickettype='电子票'
group by cmpcode,route
order by 销量 desc


         --总销量
if OBJECT_ID('tempdb..#zxl') is not null drop table #zxl
select cmpcode,SUM(price) 总销量 
into #zxl
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
AND ( datetime BETWEEN '2018-01-01' AND '2018-12-31')
and i3.cabintype like '%经济舱%' 
AND ( reti = '' )
AND ( inf = 0 )
and tickettype='电子票' 
group by cmpcode
   
          --汇总
select lc.cmpcode,route,销量,张数,平均票价,销量/总销量 销量占比,平均折扣率
from #lc lc
inner join #zxl zxl on lc.cmpcode=zxl.cmpcode



--国内航空公司分布不含税
               --经济舱数据
if OBJECT_ID('tempdb..#hs') is not null drop table #hs
select cmpcode,ride,Convert(decimal(18,2),sum(price),0) as 销量,count(1) 张数
 ,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS 平均折扣率
 into #hs
FROM    topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
WHERE   cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and i3.cabintype  like '%经济舱%' 
		AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
        AND ( reti = '' )
        AND ( inf = 0 )
        and tickettype='电子票'
group by cmpcode,ride
order by 销量 desc



          --两舱数据
if OBJECT_ID('tempdb..#hs2') is not null drop table #hs2
select cmpcode,ride,Convert(decimal(18,2),sum(price),0) as 销量,count(1) 张数
 ,Convert(decimal(18,2),AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END),0) AS 平均折扣率
 into #hs2
FROM    topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
WHERE   cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and (i3.cabintype like '%头等%' or i3.cabintype like '%公务%')
		AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
        AND ( reti = '' )
        AND ( inf = 0 )
        and tickettype='电子票'
group by cmpcode,ride
order by 销量 desc



         --经济舱总销量
if OBJECT_ID('tempdb..#zxl2') is not null drop table #zxl2
select cmpcode,SUM(price) 总销量 
into #zxl2
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
and i3.cabintype like '%经济舱%' 
AND reti = '' 
AND inf = 0 
and tickettype='电子票'
group by cmpcode

         --两舱舱总销量
if OBJECT_ID('tempdb..#zxl3') is not null drop table #zxl3
select cmpcode,SUM(price) 总销量 
into #zxl3
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
and (i3.cabintype like '%头等%' or i3.cabintype like '%公务%')
AND ( reti = '' )
AND ( inf = 0 ) 
and tickettype='电子票'
group by cmpcode
   
          --经济舱汇总
select hs.cmpcode,ride,销量,张数,销量/总销量 销量占比,平均折扣率
from #hs hs
inner join #zxl2 zxl2 on hs.cmpcode=zxl2.cmpcode


          --两舱舱汇总
select hs2.cmpcode,ride,销量,张数,销量/总销量 销量占比,平均折扣率
from #hs2 hs2
inner join #zxl3 zxl3 on hs2.cmpcode=zxl3.cmpcode


--国内提前出票数据分析不含税
     
     --经济舱
SELECT cmpcode,DAYSFLAG,SUM(price) 不含税销量,COUNT(1) 合计张数,''销量占比, SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) 经济舱平均折扣率  FROM (
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
and i3.cabintype like '%经济舱%' 
and reti=''
and tickettype='电子票'
AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
) T
GROUP BY DAYSFLAG,cmpcode
order by DAYSFLAG

    --两舱
SELECT cmpcode,DAYSFLAG,SUM(price) 不含税销量,COUNT(1) 合计张数,''销量占比, SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) 两舱平均折扣率  FROM (
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
and tickettype='电子票'
and (i3.cabintype like '%头等%' or i3.cabintype like '%公务%')
and reti=''
AND ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
) T
GROUP BY DAYSFLAG,cmpcode
order by DAYSFLAG


--国内机票部门出票数据分析不含税

          --经济舱
select cmpcode,(case Department when 'null' then '' when '' then '' else Department end )部门,SUM(price) as 销量,COUNT(1) as 张数,
AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE price/priceinfo END) AS zkpercent,AVG(DATEDIFF(day,datetime,c.begdate)) as 平均出票天数
,'' 销量占比
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
AND c.inf ='0'
and c.reti=''
and c.tickettype='电子票'
and i3.cabintype LIKE'%经济舱%'
group by (case Department when 'null' then '' when '' then '' else Department end ),cmpcode
order by 销量 desc

           --两舱
select cmpcode,(case Department when 'null' then '' when '' then '' else Department end )部门,SUM(price) as 销量,COUNT(1) as 张数,
AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE price/priceinfo END) AS zkpercent,AVG(DATEDIFF(day,datetime,c.begdate)) as 平均出票天数
,'' 销量占比
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
AND c.inf ='0'
and c.reti=''
and c.tickettype='电子票'
and (i3.cabintype LIKE'%公务舱%' or i3.cabintype LIKE'%头等舱%')
group by (case Department when 'null' then '' when '' then '' else Department end ),cmpcode
order by 销量 desc


--国内机票个人退改数据分析不含税
         --改期升舱
 if OBJECT_ID('tempdb..#gq') is not null drop table  #gq     
select cmpcode,pasname 姓名,(case Department when 'null' then '' when '' then '' else Department end ) 部门,COUNT(1)改期张数,SUM(totprice)改期费用
into #gq
from Topway..tbcash c
where cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and ( datetime BETWEEN '2018-01-01' AND '2018-06-30')
and inf=0
and (tickettype like '%改期%' or tickettype like '%升舱%')
group by cmpcode,pasname,(case Department when 'null' then '' when '' then '' else Department end )

        --退票
if OBJECT_ID('tempdb..#tp') is not null drop table  #tp         
select r.cmpcode,c.pasname 姓名,(case Department when 'null' then '' when '' then '' else Department end ) 部门,count(r.coupno) 退票张数,SUM(r.totprice) 退票费用
into #tp
from Topway..tbReti r with (nolock)
left join Topway..tbcash c on c.reti=r.reno
where r.cmpcode in ('016713','018408','018541','020085','020273','020636','020637','020638','020643','020655','020665','020742','020685') 
and ( r.datetime BETWEEN '2018-01-01' AND '2018-06-30')
and r.inf=0
and status2 not in('4')
group by r.cmpcode,c.pasname,(case Department when 'null' then '' when '' then '' else Department end )

         --总数据
 if OBJECT_ID('tempdb..#zsj') is not null drop table #zsj         
select cmpcode,pasname 姓名,(case Department when 'null' then '' when '' then '' else Department end ) 部门,
SUM(price)机票销量 ,COUNT(1)出票张数,Convert(decimal(18,2),sum(price)*1.0/count(1),0)  平均票价,
SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) 平均折扣率,AVG(DATEDIFF(day,datetime,begdate))平均出票天数
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


select zsj.cmpcode,zsj.姓名,zsj.部门,机票销量,出票张数,平均票价,平均折扣率,
平均出票天数,isnull(改期张数,'0')改期张数,isnull(改期费用,'0')改期费用,isnull(退票张数,'0')退票张数,isnull(退票费用,'0')退票费用
from #zsj zsj
left join #gq gq on gq.cmpcode=zsj.cmpcode and gq.姓名=zsj.姓名
left join #tp tp on tp.cmpcode=zsj.cmpcode and tp.姓名=zsj.姓名
order by 机票销量 desc