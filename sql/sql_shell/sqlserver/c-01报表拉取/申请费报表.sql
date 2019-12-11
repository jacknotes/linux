--申请费报表 序号	申请费来源	出票日期	销售单号	申请费	退票日期	退票单号	扣申请费	HS应收申请费	销售利润	差旅顾问
declare @startdatetime varchar(10)
declare @enddatetime varchar(10)
declare @startExamineDate varchar(10)
declare @endExamineDate varchar(10)
declare @inf varchar(10)
declare @feiyonginfo varchar(10)
declare @tickettype varchar(10)

if OBJECT_ID('tempdb..#feiyong') is not null drop table #feiyong
create table #feiyong (
feiyonginfo varchar(20),
datetime varchar(10),
coupno varchar(20),
feiyong decimal(18,3),
ExamineDate varchar(20),
reno varchar(10),
sfeiyong decimal(18,3),
HStotprice decimal(18,3),
profit decimal(18,3),
sales varchar(10))
insert into #feiyong (feiyonginfo,datetime,coupno,feiyong,ExamineDate,reno,sfeiyong,HStotprice,profit,sales)
select feiyonginfo 申请费来源,t.datetime 出票日期,t.coupno 销售单号,t.feiyong 申请费,convert(varchar(19),ExamineDate,120) 退票日期,reno 退票单号,t.sfeiyong 扣申请费,
t.feiyong-t.sfeiyong HS应收申请费,t.profit 销售利润,sales 差旅顾问
from Topway..tbReti t
left join Topway..tbcash c on c.reti=t.reno
where t.datetime>=@startdatetime
and t.datetime<=@enddatetime
and ExamineDate>=@startExamineDate
and ExamineDate<=@endExamineDate
and t.inf=@inf
and feiyonginfo in(@feiyonginfo)
and CONVERT(varchar(4),tickettype) in(@tickettype)

select * from #feiyong