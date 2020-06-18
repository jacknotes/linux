--第一张表
--国内有返佣销量税收单列 
select convert(varchar(6),datetime,112) as 月份,SUM(totprice) as 销量,SUM(xfprice) as 返佣,SUM(tax) as 税收,COUNT(1) as 张数,
AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS 平均折扣率
from Topway..tbcash
where cmpcode='016448'
and (datetime between '2018-01-01' and '2018-12-31')
and reti=''
and inf=0
and xfprice<>0
and tickettype='电子票'
and CostCenter='ca'
group by convert(varchar(6),datetime,112)

--第二表
--国内单位客户航司月均报表
select convert(varchar(6),datetime,112) as 月份,sum(totprice) as 销量,SUM(tax) as 税收,count(1) 张数,
sum(totprice)*1.0/count(1) as 平均票价,
AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS 平均折扣率
FROM Topway..tbcash
WHERE cmpcode='016448'
and (datetime between '2019-01-01' and '2019-12-31')
and reti=''
and inf=0
and tickettype='电子票'
and ride in('mu','fm')--mu和fm一起算
--and ride='cz'
and CostCenter='ca'
group by convert(varchar(6),datetime,112)
order by 月份

--第三表
--国内单位客户航程月均报表
select top 5 convert(varchar(6),datetime,112) as 月份,sum(totprice-tax) as 销量,SUM(tax) as 税收,count(1) 张数,
sum(totprice)*1.0/count(1) as 平均票价,
AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS 平均折扣率
FROM Topway..tbcash
WHERE cmpcode='016448'
and (datetime between '2019-01-01' and '2019-12-31')
and reti=''
and inf=0
and tickettype='电子票'
and route='上海虹桥-北京首都'
and CostCenter='ca'
group by convert(varchar(6),datetime,112)
order by 月份
