/*
 ��ѯ������
     1��������ڣ�2018��1��1����3��31��
     2��������:MU��FM
     3����λ��SHEET1  U F P J C D I Q
                 SHEET2 ��λ����
     4�����۵����ͣ�����Ʊ
    5���۳���Ʊ �۳������Ϊ0
 
     ����Ҫ��
     �ļ��ۺϼơ� ҵ�����

*/

SELECT coupno as ���۵���,tcode+ticketno as Ʊ��,route as �г�,nclass as ��λ,begdate as �׶γ�������,totsprice as '�ļ���(��˰)' ,sales as ҵ����� from Topway..tbcash 
where begdate>='2018-01-01' and begdate<'2018-04-01' and ride in ('MU','FM') and tickettype ='����Ʊ' and reti='' and totsprice<>0 --and nclass in ('U','F','P','J','C','D','I','Q')
 and inf=1
order by begdate