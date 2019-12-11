--1 航司出票报表   序号	出票日期	单位编号	销售单号	供应商来源	航司2字码	路线	起飞日期	舱位	票号	文件价合计	退票单号	差旅顾问
DECLARE @startdatetime VARCHAR(10)
DECLARE @enddatetime VARCHAR(10)
DECLARE @startbegdate VARCHAR(10)
DECLARE @endbegdate VARCHAR(10)
DECLARE @cmpid VARCHAR(20) 
DECLARE @inf VARCHAR(10)--国际/国内
DECLARE @tickettype VARCHAR(20) --电子票/改期/升舱/其他服务

if OBJECT_ID('tempdb..#ride') is not null drop table #ride
create table #ride( 
[datetime] VARCHAR(10),
cmpid VARCHAR(20) ,
coupno VARCHAR(50),
t_source VARCHAR(50),
ride  VARCHAR(10),
[route] VARCHAR(1000),
begdate  VARCHAR(20),
nclass VARCHAR(10),
ticketno  VARCHAR(50),
totsprice decimal(18,3),
reti  VARCHAR(20),
sales VARCHAR(20),
)
insert into #ride(datetime,cmpid,coupno,t_source,ride,[route],begdate,nclass,ticketno,totsprice,reti,sales)
select convert(varchar(10),datetime,120) 出票日期,cmpcode 单位编号,coupno 销售单号,t_source 供应商来源,ride 航司代码,route 路线,convert(varchar(20),begdate,120) 起飞日期,nclass 舱位,
tcode+ticketno 票号,sprice1+sprice2+sprice3+sprice4 文件价合计,reti 退票单号,sales 差旅顾问,cmpcode,pasname,
from Topway..tbcash 
where [datetime]>='2018-10-08' and [datetime]<='2019-07-29'
--and cmpcode=@cmpid
--and begdate>=@startbegdate and begdate<=@endbegdate
--and inf=@inf
and t_source in ('官网东航欧西D','官网东航欧西I')
and tickettype in ('电子票') 

select * from #ride