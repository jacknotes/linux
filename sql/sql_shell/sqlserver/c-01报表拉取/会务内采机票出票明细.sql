--����Ԥ�㵥449�ڲŻ�Ʊ��ϸ
select t1.datetime as ��Ʊ����,t1.coupno as �������۵���,tickettype as Ʊ����,t_source as ��Ӧ����Դ,recno as PNR,tcode,t1.ticketno as Ʊ��,begdate as �������,pasname as �˿�����,t1.cmpcode as ��λ���,t3.mobilephone as �ֻ�����,t1.route as ����,nclass as ��λ,stotsprice as ȫ��,t1.totprice as ���ۼ�,t1.price as ���۵���,tax as ˰��,xfprice as ǰ��,totsprice as �����,t1.disct as ��������,t1.profit as ����,Mcost as �ʽ����,coupon as �Żݽ��,fuprice as �����,t1.[status] as ״̬,flightno as �����,t1.sales as ҵ�����,SpareTC as ����ҵ�����,reti as ��Ʊ����,t4.rtprice as ��Ʊ��,t1.quota1 as ��������  from tbcash t1
left join tbConventionJS t2 on t2.Id=t1.ConventionYsId
left join tbCusholder t3 on t1.custid=t3.custid
left join tbReti t4 on t4.reno=t1.reti
where ConventionId=449
order by t1.coupno

select * from tbConventionjs where ConventionId=449 order by id
