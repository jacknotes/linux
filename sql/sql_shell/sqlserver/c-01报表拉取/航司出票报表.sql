--1 ��˾��Ʊ����   ���	��Ʊ����	��λ���	���۵���	��Ӧ����Դ	��˾2����	·��	�������	��λ	Ʊ��	�ļ��ۺϼ�	��Ʊ����	���ù���
DECLARE @startdatetime VARCHAR(10)
DECLARE @enddatetime VARCHAR(10)
DECLARE @startbegdate VARCHAR(10)
DECLARE @endbegdate VARCHAR(10)
DECLARE @cmpid VARCHAR(20) 
DECLARE @inf VARCHAR(10)--����/����
DECLARE @tickettype VARCHAR(20) --����Ʊ/����/����/��������

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
select convert(varchar(10),datetime,120) ��Ʊ����,cmpcode ��λ���,coupno ���۵���,t_source ��Ӧ����Դ,ride ��˾����,route ·��,convert(varchar(20),begdate,120) �������,nclass ��λ,
tcode+ticketno Ʊ��,sprice1+sprice2+sprice3+sprice4 �ļ��ۺϼ�,reti ��Ʊ����,sales ���ù���,cmpcode,pasname,
from Topway..tbcash 
where [datetime]>='2018-10-08' and [datetime]<='2019-07-29'
--and cmpcode=@cmpid
--and begdate>=@startbegdate and begdate<=@endbegdate
--and inf=@inf
and t_source in ('��������ŷ��D','��������ŷ��I')
and tickettype in ('����Ʊ') 

select * from #ride