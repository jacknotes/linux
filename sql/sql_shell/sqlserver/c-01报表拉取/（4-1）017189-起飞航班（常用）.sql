select coupno as ���۵���,datetime as ��Ʊ����,begdate as ���ʱ��,pasname as  �˻���,ride+flightno as �����,route as ����,tcode+ticketno as Ʊ�� from tbcash
where (begdate>='2018-05-11' and begdate<'2018-05-12')
and cmpcode ='017189'
and route like ('%����-%')

select coupno as ���۵���,datetime as ��Ʊ����,begdate as ���ʱ��,pasname as  �˻���,ride+flightno as �����,route as ����,tcode+ticketno as Ʊ�� from tbcash
where (begdate>='2018-05-13' and begdate<'2018-05-14')
and cmpcode ='017189'
and route like ('%-����%')