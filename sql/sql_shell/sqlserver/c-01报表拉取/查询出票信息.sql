select cmpcode as ��λ���,m.cmpname as ��λ����,datetime as ��Ʊ����,begdate as ���ʱ��,pasname as �˻���,idno as ֤����,t2.sales as ����ҵ�����
,case INF when 0 then '����' when 1 then '����' else '' end as ����
,coupno as ���۵���,price as ���۵���,totsprice as �����,tax as ˰��,totprice as ���ۼ�,xfprice as ǰ��,coupon as �Żݽ��,fuprice as �����
,bpprice as ��������,feiyong as �������,disct as ������,manager as �����,Mcost as �ʽ����,HKPrice as ������,quota1 as �����
,profit-Mcost as ��������,tcode+ticketno as Ʊ��,nclass as ��λ,t1.TicketOperationRemark as �˹���Ʊԭ��,t3.RV_Cnname as ����Ʊ��,t_source as ��Ӧ����Դ
,SpareTC as ����ҵ�����,t2.route as ����,ride+flightno as �����,t2.reti as ��Ʊ���� 
from homsomDB..Trv_DomesticTicketRecord t1
left join tbcash t2 on t2.coupno=t1.RecordNumber
left join HM_Reimbursementvouchers t3 on t3.RV_id=t2.baoxiaopz
left join tbCompanyM m on m.cmpid=t2.cmpcode
where  (t2.datetime>='2018-04-01' and t2.datetime<'2018-05-01')
and t2.cmpcode in ('')
