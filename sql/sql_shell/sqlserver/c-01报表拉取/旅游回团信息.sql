select TrvId as Ԥ�㵥��,TrvCpName as ��Ʒ��·,PerNum as ����,StartDate as ��������,EndDate as ��������
,left(REVERSE(SUBSTRING(REVERSE(Custinfo),1,CHARINDEX('@',REVERSE(Custinfo))+15)),3) as ������,left(REVERSE(SUBSTRING(REVERSE(Custinfo),1,CHARINDEX('@',REVERSE(Custinfo))+11)),11) as ��������ϵ��ʽ
,t1.Cmpid as ��λ���
,t3.cmpname as ��λ����,TrvCpBak as ��ע
from tbTravelBudget t1
left join tbCusholderM t2 on t2.custid=t1.Custid
left join tbCusholderM t4 on t4.custid=t1.Custid
left join tbCompanyM t3 on t3.cmpid=t1.Cmpid
where EndDate>='2018-05-28' and t1.Status	<>2 and TrvType not like ('%5%')
