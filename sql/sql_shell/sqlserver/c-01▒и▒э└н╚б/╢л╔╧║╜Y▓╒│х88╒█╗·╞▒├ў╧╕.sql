--1�����ɿˣ�UC016448��2018ȫ�꣬���Ϻ�Y�ճ�88�ۻ�Ʊ��ϸ��ȥ�˸ģ�
select coupno,datetime,tcode+ticketno Ʊ��,c.route �г�,ride ��˾, nclass,totprice from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs t on t.ItktBookingID=p.ItktBookingID
--left join homsomDB..Trv_RebateRelations r on t.RebateStr=r.FlightNormalPolicyID 
where cmpcode='016448' --and [Percent]=3
and datetime>='2018-01-01' and datetime<'2019-01-01' AND c.inf=0 AND c.tickettype='����Ʊ' AND c.originalprice>c.price AND c.ride IN('FM','MU') and reti=''
AND  CONVERT(DECIMAL(18,2),c.price/c.originalprice)=0.88