--��Ʊ��������������
select t1.cmpid as ��λ���,t1.cmpname as ��λ����
--,(case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' else '' end) as ��λ����
--,(CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END) as ����״̬
,(t9.Name)  as ������

--,SUM(ISNULL(t3.totprice,0)-ISNULL(t2.totprice,0)) as ��Ʊ����
--,sum(h1.price) as �Ƶ�����
--,SUM(l1.XsPrice) as ��������
--,SUM(c1.XsPrice) as ��������
--,FLOOR(isnull(sum(RealPrice + trainU.Fuprice + PrintPrice),0)) -FLOOR(isnull(sum(trainU.RealPrice+r.Fee),0)) as ��Ʊ����
--,SUM(ISNULL(t3.profit,0)+ISNULL(t2.profit,0)) as ��Ʊ����
--,sum(h1.totprofit) as �Ƶ�����
--,SUM(l1.Profit) as ��������
--,sum(c1.Profit) as ��������
--,FLOOR(isnull(Sum(trainU.Fuprice - CASE Tsource WHEN '������' THEN 5 when '�߲�����' then 1 ELSE 0 END),0))+ FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0))as ��Ʊ����
--,COUNT(1) as ����
 from tbCompanyM t1
--��Ʊ
--left join tbcash t3 on t3.cmpcode=t1.cmpid
--left join tbreti t2 on t3.coupno=t2.coupno
--�Ƶ�
--left join tbHtlcoupYf h1 on h1.cmpid=t1.cmpid and h1.status2<>-2
--left join tbhtlyfchargeoff h2 on h2.coupid=h1.id
--����
--left join tbTrvCoup l1 on l1.Cmpid=t1.cmpid
--����
--left join tbConventionCoup c1 on c1.Cmpid=t1.cmpid
--��Ʊ
--left join tbTrainTicketInfo trainO on trainO.CmpId=t1.cmpid
--LEFT JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo
--left join Train_ReturnTicket r on r.TickOrderDetailID = trainU.ID
--TMS
left join homsomdb..Trv_UnitCompanies t4 on t1.cmpid=t4.Cmpid
--������
left join homsomDB..Trv_UnitCompies_Sales t5 on t4.ID=t5.UnitCompayID
--��Ա��Ϣ
left join homsomDB..SSO_Users t9 on
t9.ID=t5.EmployeeID 
where 
t9.Name in ('������','������','̸��Ρ','��','������','��','����Ԫ','¥���','���컪','������','������','������')
--and hztype<>0
--and hztype<>4
and (t1.indate>='2017-01-01' and t1.indate<'2017-04-01') 
--and (t3.datetime>='2017-01-01' and t3.datetime<'2017-04-01') 
--and (h1.prdate>='2017-01-01' and h1.prdate<'2017-04-01')  
--and (l1.OperDate>='2017-01-01' and l1.OperDate<'2017-04-01')
--and (c1.OperDate>='2017-01-01' and c1.OperDate<'2017-04-01')           
--and (trainO.CreateDate>='2017-01-01' and trainO.CreateDate<'2017-04-01')
--and (r.AuditTime >='2017-01-01' AND r.AuditTime<'2017-04-01')
--and trainO.Isdisplay=0
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,t9.Name
order by t1.cmpid

