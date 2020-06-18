--����ѱ��� ���	�������Դ	��Ʊ����	���۵���	�����	��Ʊ����	��Ʊ����	�������	HSӦ�������	��������	���ù���
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
select feiyonginfo �������Դ,t.datetime ��Ʊ����,t.coupno ���۵���,t.feiyong �����,convert(varchar(19),ExamineDate,120) ��Ʊ����,reno ��Ʊ����,t.sfeiyong �������,
t.feiyong-t.sfeiyong HSӦ�������,t.profit ��������,sales ���ù���
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