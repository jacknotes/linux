select tcode+r.ticketno as Ʊ��,t.coupno as ���۵���,t_source as ��Ӧ����Դ,scount2 as ���չ�˾��Ʊ��,r.ExamineDate as ���ʱ��,r.ride as ���չ�˾,
flightno as �����,reno as ��Ʊ���� from Topway..tbReti r
inner join tbcash t on t.reti=r.reno
where r.ExamineDate>='2018-1-1' and r.ExamineDate<'2018-12-23' and r.inf='1' and r.ride in ('fm','mu')
order by ExamineDate

select tcode+r.ticketno as Ʊ��,t.coupno as ���۵���,t_source as ��Ӧ����Դ,scount2 as ���չ�˾��Ʊ��,r.ExamineDate as ���ʱ��,r.ride as ���չ�˾,
flightno as �����,reno as ��Ʊ���� from Topway..tbReti r
inner join tbcash t on t.reti=r.reno
where r.ExamineDate>='2018-1-1' and r.ExamineDate<'2018-12-23' and r.inf='1' and r.ride like ('%HO%')
order by ExamineDate