--2�����ɿ� (UC016448) 2018ȫ�꣬���ڻ�Ʊǰ��3%���л�Ʊ��ϸ��ȥ�˸ģ� 
select coupno,datetime,tcode+ticketno Ʊ��,c.route �г�,ride ��˾, nclass,totprice from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs t on t.ItktBookingID=p.ItktBookingID
left join homsomDB..Trv_RebateRelations r on t.RebateStr=r.FlightNormalPolicyID 
where cmpcode='016448' and [Percent]=3
and datetime>='2018-01-01' and datetime<'2019-01-01' AND c.inf=0 AND c.tickettype='����Ʊ'  and reti=''
order by datetime
