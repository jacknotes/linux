--��	���λ����Ѹ��ѵ����տ-�ѽ����˿��Ԥ�㵥δ���ţ�ʱ�����䣺2014.1.1-2016.9.30��

--�����տ
select sk.ConventionId as Ԥ�㵥��,sk.OperDate as ��������,sk.totprice+InvoiceTax as �տ���
from dbo.tbConventionKhSk sk
INNER JOIN dbo.tbConventionBudget bud ON sk.ConventionId = bud.ConventionId
WHERE sk.OperDate>='2014-01-01' AND sk.OperDate<'2018-06-01' AND sk.cwstatus='1' and bud.Status not in (2,15) and sk.Skstatus<>2
order by sk.ConventionId


--�����˿
select tk.ConventionId as Ԥ�㵥��,tk.OperDate as ��������,tk.Price as �˿��� 
from dbo.tbConventionKhTk tk
inner join dbo.tbConventionBudget bud ON tk.ConventionId = bud.ConventionId
WHERE tk.OperDate>='2014-01-01' AND tk.OperDate<'2018-06-01' AND cwstatus='2' and bud.Status not in (2,15) and tk.tkstatus<>2
order by tk.ConventionId

--�����տ
select sk.TrvId as Ԥ�㵥��,sk.OperDate as ��������,sk.totprice+InvoiceTax  as �տ��� 
from  dbo.tbTrvKhSk sk
INNER JOIN dbo.tbTravelBudget bud ON sk.TrvId = bud.TrvId
WHERE  sk.OperDate>='2014-01-01' AND sk.OperDate<'2018-06-01' AND cwstatus='1' and bud.Status not in (1,2)  and sk.Skstatus<>2
order by sk.trvid

--�����˿
select tk.TrvId as Ԥ�㵥��,tk.OperDate as ��������,tk.Price as �˿��� 
from  dbo.tbTrvKhTk tk
inner join dbo.tbTravelBudget bud ON tk.TrvId = bud.TrvId
WHERE  tk.OperDate>='2014-01-01' AND tk.OperDate<'2018-06-01' AND cwstatus='2' and bud.Status not in (1,2) and Tkstatus<>2


--��	2016/09/01-2016/09/30����Ա��������ϸ����Ʊ����Ʊ+��Ʊ���;Ƶ�ҵ����Ҫ�����ݣ�1.����Ʊ��Ʊ����Ʊ����/���۵���/���/�տ�״̬/�տ���/Ƿ���� 2.����Ʊ��Ʊ����Ʊ�������/���۵���/Ӧ�����/��Ʊ״̬ 3.���Ƶ꣩��ӡ����/���۵���/���/�տ�״̬/�տ���/Ƿ����
--SELECT * FROM tbreti WHERE cmpcode=CHAR(10) ORDER BY ExamineDate
--UPDATE tbReti SET cmpcode='' WHERE cmpcode=CHAR(10)
--��Ʊ
SELECT  datetime as ��Ʊ����,coupno as ���۵���,cash+cpay+bpay+vpay+epay as ������,cowe as �ֳ���,CASE status WHEN 0 THEN 'δ��' WHEN 1 THEN '�Ѹ��ѵ���' WHEN 3 THEN 'δ����' WHEN 6 THEN 'δ���ѵ���' ELSE '' END as �տ�״̬,totprice as �տ���,owe as Ƿ����
FROM tbcash 
WHERE datetime>='2018-05-01' AND datetime<'2018-06-01'
AND LEN(cmpcode)<6
AND	LEN(CASE WHEN coupno LIKE '000000%' OR coupno = 'AS000000000' THEN '' ELSE cmpcode END)=0
AND LEFT(CASE WHEN coupno LIKE '000000%' OR coupno = 'AS000000000' THEN 'D' 
			WHEN (cmpcode='' AND custid='') OR (ConventionYsId<>0 OR trvYsId<>0) THEN ''  ELSE custid END ,1) ='D'
--��Ʊ��Ʊ			
SELECT  reno as ��Ʊ����,r.ExamineDate as �������,r.coupno as ���۵���,r.totprice as ���
,(CASE r.status2 WHEN 1 THEN '��Ʊ���ύ' WHEN 2 THEN '��Ʊ�����' WHEN 5 THEN '��Ʊ������' WHEN 6 THEN '��Ʊ�Ѵ���' WHEN 7 THEN '��Ʊ�ѽ���' WHEN 8 THEN' ��Ʊ������' WHEN 9 THEN '��Ʊ�Ѷ���' ELSE '' END) as ��Ʊ״̬
FROM dbo.tbReti r
INNER JOIN tbcash c ON r.coupno=c.coupno AND r.ticketno=c.ticketno
WHERE ExamineDate>='2018-05-01' AND ExamineDate<'2018-06-01' AND status2 NOT IN (3,4)
AND LEN(r.cmpcode)<6
AND	 (r.ConventionYsId=0 and r.trvYsId=0) 
--AND	LEN(CASE WHEN r.coupno LIKE '000000%' OR r.coupno = 'AS000000000' THEN '' ELSE r.cmpcode END)=0
--AND LEFT(CASE WHEN r.coupno LIKE '000000%' OR r.coupno = 'AS000000000' THEN 'D' 
			--WHEN (r.cmpcode='' AND r.custid='') OR (r.ConventionYsId<>0 OR r.trvYsId<>0) THEN ''  ELSE r.custid END ,1) ='D'
--�Ƶ�
SELECT prdate as ��ӡ����,CoupNo as ���۵���,c.cash+c.cpay+c.bpay+c.vpay+c.tepay [���] ,(CASE c.cwstatus WHEN 0 THEN 'δ��' WHEN 1 THEN '�Ѹ��ѵ���' WHEN 6 THEN 'δ���ѵ���' ELSE '' END) as �տ�״̬,price+fwprice-yhprice [�տ���],c.owe as Ƿ����
FROM dbo.tbHtlcoupYf 
LEFT JOIN dbo.tbhtlyfchargeoff c ON c.coupid = tbHtlcoupYf.id
WHERE prdate>='2018-05-01' AND prdate<'2018-06-01' and pstatus=1 and status<>-2 AND LEN(cmpid)<6
ORDER BY  coupno

--��	2016/09/01-2016/09/30���ڲɵ�������ϸ����Ʊ����Ʊ+��Ʊ���;Ƶ�ҵ����Ҫ�����ݣ�1.����Ʊ��Ʊ����Ʊ����/���۵���/���/�տ�״̬/�տ���/Ƿ���� 2.����Ʊ��Ʊ����Ʊ�������/���۵���/Ӧ�����/��Ʊ״̬ 3.���Ƶ꣩��ӡ����/���۵���/���/�տ�״̬/�տ���/Ƿ����
--��Ʊ
SELECT datetime as ��Ʊ����,coupno as ���۵���,cash+cpay+bpay+vpay+epay as ������,cowe as �ֳ���,CASE status WHEN 0 THEN 'δ��' WHEN 1 THEN '�Ѹ��ѵ���' WHEN 3 THEN 'δ����' WHEN 6 THEN 'δ���ѵ���' ELSE '' END as �տ�״̬,totprice as �տ���,owe as Ƿ����
FROM tbcash 
WHERE datetime>='2018-05-01' AND datetime<'2018-06-01'
--AND custid<>'' 
AND	 (ConventionYsId<>0 OR trvYsId<>0) 
AND NOT ( coupno LIKE '000000%' OR coupno = 'AS000000000')

--��Ʊ
SELECT  r.ExamineDate as �������,r.coupno as ���۵���,r.totprice as ���
,(CASE r.status2 WHEN 1 THEN '��Ʊ���ύ' WHEN 2 THEN '��Ʊ�����' WHEN 5 THEN '��Ʊ������' WHEN 6 THEN '��Ʊ�Ѵ���' WHEN 7 THEN '��Ʊ�ѽ���' WHEN 8 THEN' ��Ʊ������' WHEN 9 THEN '��Ʊ�Ѷ���' ELSE '' END) as ��Ʊ״̬ 
FROM dbo.tbReti r
INNER JOIN tbcash c ON r.coupno=c.coupno AND r.ticketno=c.ticketno
WHERE ExamineDate>='2018-05-01' AND ExamineDate<'2018-06-01' AND status2 NOT IN (3,4)
AND	 (r.ConventionYsId<>0 OR r.trvYsId<>0) 
--AND c.cmpcode=''
--AND	LEN(CASE WHEN r.coupno LIKE '000000%' OR r.coupno = 'AS000000000' THEN '' ELSE r.cmpcode END)=0
--AND LEFT(CASE WHEN r.coupno LIKE '000000%' OR r.coupno = 'AS000000000' THEN 'D' 
			--WHEN (r.cmpcode='' AND r.custid='') OR (r.ConventionYsId<>0 OR r.trvYsId<>0) THEN ''  ELSE r.custid END ,1) ='D'
			

--�Ƶ꣨���Σ�
SELECT prdate as ��ӡ����,CoupNo as ���۵���,c.cash+c.cpay+c.bpay+c.vpay+c.tepay [���] ,(CASE c.cwstatus WHEN 0 THEN 'δ��' WHEN 1 THEN '�Ѹ��ѵ���' WHEN 6 THEN 'δ���ѵ���' ELSE '' END) as �տ�״̬,price+fwprice-yhprice [�տ�״̬],c.owe as Ƿ����
FROM dbo.tbHtlcoupYf t1
LEFT JOIN dbo.tbhtlyfchargeoff c ON c.coupid = t1.id
inner join tbTrvJS t2 on t1.id=t2.CoupId
WHERE prdate>='2018-05-01' AND prdate<'2018-06-01' and t1.pstatus=1 and status<>-2 AND cmpid=''
ORDER BY  coupno
--�Ƶ꣨����
SELECT prdate as ��ӡ����,CoupNo as ���۵���,c.cash+c.cpay+c.bpay+c.vpay+c.tepay [���] ,(CASE c.cwstatus WHEN 0 THEN 'δ��' WHEN 1 THEN '�Ѹ��ѵ���' WHEN 6 THEN 'δ���ѵ���' ELSE '' END) as �տ�״̬,price+fwprice-yhprice [�տ�״̬],c.owe as Ƿ����
FROM dbo.tbHtlcoupYf t1
LEFT JOIN dbo.tbhtlyfchargeoff c ON c.coupid = t1.id
inner join tbConventionJS t2 on t1.id=t2.CoupId
WHERE prdate>='2018-05-01' AND prdate<'2018-06-01' and t1.pstatus=1 and status<>-2 AND cmpid=''
ORDER BY  coupno






--��	����״̬Ϊ�������л����ǵ�������˻صĻ�Ʊ���Ƶꡢ���Ρ�����ǩ֤�Ľ��������ݣ���λ��š���λ���ơ����۵��ţ���Ԥ�㵥�ţ���������ʱ��
--��ע������Ϊ�����л���˻ؽ����������������������л��в������˻أ�
IF OBJECT_ID('tempdb.dbo.#r') IS NOT NULL DROP TABLE #r
SELECT BillNo,ISNULL(c1.cmpcode,ISNULL(c3.cmpid,'')) AS cmpid,ISNULL(c1.custid,ISNULL(c3.custid,'')) AS custid,t2.CoupNo,t1.DepositMoney
,ISNULL(c1.status,ISNULL(c3.status2,-99)) AS STATUS
,t2.TypeId,t2.TbCashId,c1.ticketno,t1.CreateDate
INTO #r
FROM Guarantees t1
INNER JOIN dbo.GuaranteesTbCash t2 ON t1.BillId = t2.BillId
LEFT JOIN tbcash c1 ON t2.TbCashId=c1.id AND t2.CoupNo=c1.coupno
LEFT JOIN dbo.tbHtlcoupYf c3 ON t2.TbCashId=c3.id AND t2.CoupNo=c3.CoupNo
WHERE t1.StatusId=1 AND t1.IsDisplay=1 AND t2.IsDisplay=1 --AND c1.id IS NULL AND c3.id IS NULL

SELECT BillNo as ��ˮ��,r.cmpid as ��λ���,r.custid as ��Ա���,r.CoupNo as ���۵���,r.DepositMoney as �ܽ��,isnull(c.totprice,0)  as ��Ʊ��ϸ,isnull(t.totprice,0) as ��Ʊ���,isnull(yf.price,0) as �Ƶ���ϸ,r.ticketno as Ʊ��,r.CreateDate as ����ʱ��
,CASE WHEN TypeId=1 AND r.STATUS<>1 THEN '������' WHEN TypeId=1 AND r.STATUS=1 THEN '��������˻�' 
	WHEN TypeId=2 AND r.STATUS<>1 THEN '������' WHEN TypeId=2 AND r.STATUS=1 THEN '��������˻�' 
	ELSE '' END as ����״̬
	FROM #r r
	left join tbcash c on c.ticketno=r.ticketno
	left join tbReti t on t.reno=c.reti
left join tbHtlcoupYf yf on yf.CoupNo=r.coupno
order by BillNo




--��	�渶״̬Ϊ���ѵ渶�Ļ�Ʊ���Ƶ�Ľ��������ݣ���λ��š���λ���ơ����۵��ţ���Ԥ�㵥�ţ���������ʱ�䡢��ȥ���˿��
SELECT CASE WHEN dbo.tbCompanyM.cmpid IS NOT NULL THEN 'UC'+cmpcode ELSE cus.custid END,ISNULL(dbo.tbCompanyM.cmpname,cus.custname),tc.coupno,pay.Price,tc.totprice,TcPayDate as ����ʱ�� ,datetime
,red.AppDate as �˿�ʱ��
FROM tbcash tc
left join GuaranteesTbCash c on  c.TbCashId=tc.id
left join Guarantees g on g.BillId=c.BillId
LEFT JOIN dbo.tbCompanyM ON tc.cmpcode<>'' and tc.cmpcode=tbCompanyM.cmpid 
LEFT JOIN dbo.tbCusholder cus ON tc.cmpcode='' AND tc.custid=cus.custid
LEFT JOIN dbo.HM_CurrentPaymentRefund red on red.CoupNo=tc.coupno
left join dbo.PayDetail pay on pay.ysid=tc.BaokuID 
WHERE AdvanceStatus=1 and pay.payperson=2 and tc.coupno not like ('%000000%') and pay.Pstatus<>0




---Ҫȥ��
--ECXEL-ѡ��ȫ��-����-ɾ���ظ���


SELECT CASE WHEN dbo.tbCompanyM.cmpid IS NOT NULL THEN 'UC'+o.CMPID ELSE cus.custid END,ISNULL(dbo.tbCompanyM.cmpname,cus.custname),o.CoupNo,TotalPrice,o.AdvanceDate
,red.AdvanceReturnDate as �˿�ʱ��
FROM HotelOrderDB..HTL_Orders o
LEFT JOIN dbo.tbCompanyM ON ISNULL(o.CMPID,'')<>'' and o.CMPID=tbCompanyM.cmpid 
LEFT JOIN dbo.tbCusholder cus ON ISNULL(o.CMPID,'')='' AND o.custid=cus.custid
left join dbo.tbHtlcoupRefund red on red.CoupNo=o.CoupNo
WHERE o.AdvanceStatus=3 AND o.Status<>91


--�ޣ���2016.04��2017.02.28δ�����������ϸ
--��Ʊ
SELECT  datetime as ��Ʊ����,coupno as ���۵���,cash+cpay+bpay+vpay+epay as ������,cowe as �ֳ���,CASE status WHEN 0 THEN 'δ��' WHEN 1 THEN '�Ѹ��ѵ���' WHEN 3 THEN 'δ����' WHEN 6 THEN 'δ���ѵ���' ELSE '' END as �տ�״̬,totprice as �տ���,owe as Ƿ����
,pform as ���㷽ʽ
FROM tbcash 
WHERE datetime>='2016-04-01' AND datetime<'2018-06-01'
AND LEN(cmpcode)<6
AND	LEN(CASE WHEN coupno LIKE '000000%' OR coupno = 'AS000000000' THEN '' ELSE cmpcode END)=0
--AND LEFT(CASE WHEN coupno LIKE '000000%' OR coupno = 'AS000000000' THEN 'D' 
			--WHEN (cmpcode='' AND custid='') OR (ConventionYsId<>0 OR trvYsId<>0) THEN ''  ELSE custid END ,1) ='D'
			and status=0
			--and pform='�ֽ�'
--��Ʊ��Ʊ			
SELECT  r.ExamineDate as �������,r.coupno as ���۵���,r.totprice as ���
,(CASE r.status2 WHEN 1 THEN '��Ʊ���ύ' WHEN 2 THEN '��Ʊ�����' WHEN 5 THEN '��Ʊ������' WHEN 6 THEN '��Ʊ�Ѵ���' WHEN 7 THEN '��Ʊ�ѽ���' WHEN 8 THEN' ��Ʊ������' WHEN 9 THEN '��Ʊ�Ѷ���' ELSE '' END) as ��Ʊ״̬
FROM dbo.tbReti r
INNER JOIN tbcash c ON r.coupno=c.coupno AND r.ticketno=c.ticketno
WHERE ExamineDate>='2016-04-01' AND ExamineDate<'2018-06-01' AND status2 NOT IN (1,3,4,7)
AND LEN(r.cmpcode)<6
--and c.pform='�ֽ�'
--AND	LEN(CASE WHEN r.coupno LIKE '000000%' OR r.coupno = 'AS000000000' THEN '' ELSE r.cmpcode END)=0
--AND LEFT(CASE WHEN r.coupno LIKE '000000%' OR r.coupno = 'AS000000000' THEN 'D' 
			--WHEN (r.cmpcode='' AND r.custid='') OR (r.ConventionYsId<>0 OR r.trvYsId<>0) THEN ''  ELSE r.custid END ,1) ='D'
--�Ƶ�
SELECT prdate as ��ӡ����,CoupNo as ���۵���,c.cash+c.cpay+c.bpay+c.vpay+c.tepay [���] ,(CASE c.cwstatus WHEN 0 THEN 'δ��' WHEN 1 THEN '�Ѹ��ѵ���' WHEN 6 THEN 'δ���ѵ���' ELSE '' END) as �տ�״̬,price+fwprice-yhprice [�տ���],c.owe as Ƿ����
FROM dbo.tbHtlcoupYf 
LEFT JOIN dbo.tbhtlyfchargeoff c ON c.coupid = tbHtlcoupYf.id
WHERE prdate>='2016-04-01' AND prdate<'2018-06-01' and pstatus=1 and status<>-2 AND LEN(cmpid)<6
and c.cwstatus=0
--and sform='�ֽ�'
ORDER BY  coupno
 
 
 
 --����
 --��Ʊ����
select tbreti.cmpcode,count(*) as num,cmpname
,sum(tbreti.stotprice)as [HSӦ�ս��stotprice]
,sum(tbreti.totprice)as [HSӦ�����totprice]
,sum(yjprice+bpprice)as [tpyjprice��λӶ���+��������]
,sum(tbreti.disct)as [��������disct]
--,SUM(tbcash.disct) AS [��������disct2,����ȡ��һ]  
,SUM(tbreti.ZkRefundPrice)AS [������Ʊ�ѵֳ��������ZkRefundPrice]
,SUM(dbo.tbReti.profit) [����]
,SUM(tbReti.stotprice-tbreti.totprice+yjprice+bpprice+tbreti.disct-tbreti.ZkRefundPrice) [��ʽ��������]
from tbreti 
left join tbcash on tbreti.ticketno = tbcash.ticketno and tbreti.reno=tbcash.reti 
left join tbCompanyM on tbreti.cmpcode = cmpid  
where ExamineDate >= '2018-05-01' and ExamineDate <'2018-06-01' 
and tbreti.status2 not in(1,3,4) 
group by tbreti.cmpcode,cmpname
ORDER BY tbReti.cmpcode 



--��Ʊҵ��������ϸ
--��Ʊ��Ʊ
--select FLOOR(isnull(sum(RealPrice + Fuprice + PrintPrice),0)) as xprice,FLOOR(isnull(Sum(Fuprice - CASE Tsource WHEN '������' THEN 5 ELSE 0 END),0)) as xtotprofit 
SELECT trainO.CmpId as UC��,trainO.CoupNo as ���۵���,trainO.CreateDate as ��Ʊ����,RealPrice [Ʊ���],
Fuprice+PrintPrice AS [�����],PrintPrice [��Ʊ��],Tsource [ƱԴ],RealPrice+Fuprice+PrintPrice AS [Ӧ�տͻ�����],
RealPrice+PrintPrice+(CASE Tsource WHEN '������'  THEN 5  when '�߲�����' then 1 ELSE 0  END) AS [Ӧ����Ӧ�̿���]	
from tbTrainTicketInfo trainO INNER JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo 
where trainO.CreateDate between '2018-05-01' and '2018-05-31 23:59:59'  AND trainO.Isdisplay=0 
AND trainO.TrainWebNo not LIKE '%��ǩ%'
UNION all
SELECT trainO.CmpId as UC��,trainO.CoupNo as ���۵���,trainO.CreateDate as ��Ʊ����,RealPrice [Ʊ���],
Fuprice+PrintPrice AS [�����],PrintPrice [��Ʊ��],Tsource [ƱԴ],RealPrice+Fuprice+PrintPrice AS [Ӧ�տͻ�����],
RealPrice+PrintPrice+(CASE Tsource WHEN '������'  THEN 5   ELSE 0  END) AS [Ӧ����Ӧ�̿���]	
from tbTrainTicketInfo trainO INNER JOIN tbTrainUser trainU ON trainO.ID = trainU.TrainTicketNo 
where trainO.CreateDate between '2018-05-01' and '2018-05-31 23:59:59'  AND trainO.Isdisplay=0 
AND trainO.TrainWebNo  LIKE '%��ǩ%'

--��Ʊ��Ʊ
--select -FLOOR(isnull(sum(trainU.RealPrice+r.Fee),0)) as xprice,FLOOR(isnull(Sum(r.Fee - r.SupplierFee),0)) as xtotprofit 
SELECT trainO.CmpId as UC��,trainO.CoupNo as ���۵���,r.AuditTime as ��Ʊ����,trainO.Tsource as ƱԴ,trainU.RealPrice as Ʊ���,r.Fee as �տͻ���Ʊ��,r.SupplierFee as �չ�Ӧ����Ʊ��,r.Fee-trainU.RealPrice  [Ӧ�տͻ�����],r.SupplierFee-trainU.RealPrice  [Ӧ����Ӧ�̿���]
,r.ModifyBillNumber as �˵���,r.ID as ��Ʊ����
from Train_ReturnTicket r INNER JOIN tbTrainUser trainU ON r.TickOrderDetailID = trainU.ID
INNER JOIN dbo.tbTrainTicketInfo trainO ON trainO.ID = trainU.TrainTicketNo 
where r.AuditTime between '2018-05-01' and '2018-05-31 23:59:59'  AND trainO.Isdisplay=0 


--�Ƶ����۵�˰��
SELECT yf.cmpid as ��λ���,m.cmpname as ��λ����,CoupNo as ���۵���,InvoiceTax as ˰��
  FROM [Topway].[dbo].[tbHtlcoupYf] yf
  left join tbCompanyM m on m.cmpid=yf.cmpid
  where prdate>='2018-05-01' and prdate<'2018-06-01'
  and InvoiceTax<>0
  
--�Ƶ꿪רƱ��ϸ
select info.CMPID as ��λ���,m.cmpname as ��λ���� 
from  CompanyInvoiceInfo info
inner join tbCompanyM m on m.cmpid=info.CMPID
where info.HotelInvoiceType like ('%2%')
