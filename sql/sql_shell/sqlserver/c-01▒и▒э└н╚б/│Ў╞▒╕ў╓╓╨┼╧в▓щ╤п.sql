select coupno as ���۵���,tcode as Ʊ��ǰ��λ,ticketno as Ʊ�ź�ʮλ,pasname as �˿�����,idno as ֤����,cmpcode as ��λ���,route as ����,nclass as ��λ,flightno as �����,sales as ����ҵ����� from tbcash
where tair='CZ' 
and datetime>='2016-09-01' and datetime<'2016-10-01'
and (route like '%�ֶ�-����%' 
or route like '%�ֶ�-������%' 
or route like '%�ֶ�-����%'
or route like '%�ֶ�-�人%'
or route like '%�ֶ�-��ɳ%'
or route like '%�ֶ�-֣��%'
or route like '%����-����%' 
or route like '%����-������%' 
or route like '%����-����%'
or route like '%����-�人%'
or route like '%����-��ɳ%'
or route like '%����-֣��%')
order by coupno

