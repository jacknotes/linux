select tcode+r.ticketno as Ʊ��,t.coupno as ���۵���,t_source as ��Ӧ����Դ,scount2 as ���չ�˾��Ʊ��,r.ExamineDate as ���ʱ��,r.ride as ���չ�˾,
flightno as �����,reno as ��Ʊ���� from Topway..tbReti r
inner join tbcash t on t.reti=r.reno
where r.ExamineDate>='2018-11-1' and r.ExamineDate<'2018-12-1'
order by ExamineDate

