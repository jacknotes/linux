--2 ��Ʊ����  ���	��Ӧ����Դ	��Ʊ����	��Ʊ�������	��Ʊ״̬	��Ʊ��	HSӦ�ս��	��Ʊԭ��	����״̬	ҵ�����	�����
--��Ʊ��״̬(1��Ʊ���ύ,2��Ʊ�����,3���δͨ��,4��Ʊ������,5��Ʊ������,6��Ʊ�Ѵ���,7��Ʊ�ѽ���,8��Ʊ������,9��Ʊ�Ѷ���)
DECLARE @startedatetime VARCHAR(10)
DECLARE @endedatetime VARCHAR(10)
DECLARE @startExamineDate VARCHAR(10) 
DECLARE @endExamineDate VARCHAR(10)
DECLARE @status VARCHAR(10) --����ʽ��ѡ��   ��Ʊ���ύ/��Ʊ�ѱ���/��Ʊ�����/��Ʊ�ѽ���
DECLARE @inf VARCHAR(10) --����ʽ��ѡ��   ����/����
DECLARE @t_source VARCHAR(50)--����ʽ��ѡ��  ���ޣ���ѡ����ѡ
DECLARE @inf2 VARCHAR(20)--����ʽ��ѡ��  ����/δ����/�������
DECLARE @sales VARCHAR(20)--���ɸ�ʽ���ֹ���������

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
select t_source,reno,ExamineDate,(case when t.status=1 then '��Ʊ���ύ' when t.status=2 then '��Ʊ�����' when t.status=3 then '���δͨ��'
when t.status=4 then '��Ʊ������' when t.status=5 then '��Ʊ������' when t.status=6 then '��Ʊ�Ѵ���' when t.status=7 then '��Ʊ�ѽ���' when 
t.status=8 then '��Ʊ������' else '��Ʊ�Ѷ���' end) as ��Ʊ��״̬,c.totprice-t.totprice ��Ʊ��,stotprice HSӦ�ս��,reason ��Ʊԭ��,sales ҵ�����,
cpopername �����
from Topway..tbReti t with (nolock)
left join Topway..tbcash c on t.reno=c.reti
where t.datetime>=@startedatetime and t.datetime<=@endedatetime
and ExamineDate>=@startExamineDate and ExamineDate<=@endExamineDate
and t.status=@status
and t.inf=@inf
and t_source in(@t_source)
and t.inf2 in(@inf2)
and sales=@sales
