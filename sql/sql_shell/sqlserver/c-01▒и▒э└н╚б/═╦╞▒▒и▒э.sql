--2 退票报表  序号	供应商来源	退票单号	退票审核日期	退票状态	退票费	HS应收金额	退票原因	结算状态	业务顾问	审核人
--退票单状态(1退票已提交,2退票已审核,3审核未通过,4退票已作废,5退票处理中,6退票已处理,7退票已结清,8退票已锁定,9退票已冻结)
DECLARE @startedatetime VARCHAR(10)
DECLARE @endedatetime VARCHAR(10)
DECLARE @startExamineDate VARCHAR(10) 
DECLARE @endExamineDate VARCHAR(10)
DECLARE @status VARCHAR(10) --下拉式可选项   退票已提交/退票已保存/退票已审核/退票已结清
DECLARE @inf VARCHAR(10) --下拉式可选项   国内/国际
DECLARE @t_source VARCHAR(50)--下拉式可选项  不限，单选，多选
DECLARE @inf2 VARCHAR(20)--下拉式可选项  不限/未结算/申请结算
DECLARE @sales VARCHAR(20)--自由格式，手工输入姓名

if OBJECT_ID('tempdb..#reti') is not null drop table #reti
create table #reti (
t_source VARCHAR(50),
reno VARCHAR(10),
ExamineDate VARCHAR(10),
status VARCHAR(20),
totprice decimal(18,3),
stotprice decimal(18,3),
reason VARCHAR(20),
sales VARCHAR(10),
cpopername VARCHAR(10),)
insert into #reti(t_source,reno,ExamineDate,status,totprice,stotprice,reason,sales,cpopername)
select t_source,reno,ExamineDate,(case when t.status=1 then '退票已提交' when t.status=2 then '退票已审核' when t.status=3 then '审核未通过'
when t.status=4 then '退票已作废' when t.status=5 then '退票处理中' when t.status=6 then '退票已处理' when t.status=7 then '退票已结清' when 
t.status=8 then '退票已锁定' else '退票已冻结' end) as 退票单状态,c.totprice-t.totprice 退票费,stotprice HS应收金额,reason 退票原因,sales 业务顾问,
cpopername 审核人
from Topway..tbReti t with (nolock)
left join Topway..tbcash c on t.reno=c.reti
where t.datetime>=@startedatetime and t.datetime<=@endedatetime
and ExamineDate>=@startExamineDate and ExamineDate<=@endExamineDate
and t.status=@status
and t.inf=@inf
and t_source in(@t_source)
and t.inf2 in(@inf2)
and sales=@sales
