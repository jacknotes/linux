

select t.datetime as ��Ʊ����,t.coupno as ���۵���,t.tcode+t.ticketno as Ʊ��,begdate as ���ʱ��,pasname as �˻���,t.route as ����,t.price as ���۵���,
tax as ˰��,t.totprice as ���ۼ�,t.totprice as �����,t.disct as ������,t.profit as ����,flightno as �����,reno as ��Ʊ����,scount2 as ���չ�˾��Ʊ��,t.profit-t.Mcost as ��������,r.totprice as HSӦ�����,
r.rtprice as �տͻ���Ʊ��
from Topway..tbReti r
inner join tbcash t on t.reti=r.reno
where r.ExamineDate>='2018-1-1' and r.ExamineDate<'2018-12-27' and t.cmpcode='019807'
order by ExamineDate

