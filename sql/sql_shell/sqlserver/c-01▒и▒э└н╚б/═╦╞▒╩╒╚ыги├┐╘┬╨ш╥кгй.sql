/*
����ϵͳ����Ʊ����tbreti.totprice2225325-��Ʊ�ɱ�tbreti.stotprice2236831-��ƱӶ��tbcash.yjprice+bpprice7244-��Ʊ�ۿ�tbreti.disct52948
*/
��Ʊ�ɱ�+��ƱӶ��+��Ʊ�ۿ�-��Ʊ����
SELECT 2236831+7244+52948-2225325=71698
SELECT 2236831+7244-2225325=18750
���㹩Ӧ�̽�HSӦ�ս�� = ԭ�����[��˰] - ��ʹ�ý�� - ��ʹ��˰�� - ���չ�˾��Ʊ�� - NO SHOW�� ��

HSӦ����� = ʵ�����ۼ� - �տͻ���Ʊ���
//����������� (�������� = HSӦ�ս�� - HSӦ����� + ��λӶ��� + �������� + ��������-������Ʊ�ѵֳ��������)



���㹩Ӧ�̽�HSӦ�ս�� = ԭ�����[��˰] - ��ʹ�ý�� - ��ʹ��˰�� - ���չ�˾��Ʊ�� - NO SHOW�� ��
stotprice=sprice-scount1-usedtaxg-scount2-noshowg
HSӦ����� = ʵ�����ۼ� - �տͻ���Ʊ���
totprice=totprice[tbcash]-rtprice
//����������� (�������� = HSӦ�ս�� - HSӦ����� + ��λӶ��� + �������� + ��������-������Ʊ�ѵֳ��������)
tzprofit=stotprice-totprice+(yjprice+bpprice+disct)[tbcash]-zkrefundprice
SELECT stotprice,totprice,sprice,UsedTaxG,scount1,scount2,NoShowG,rtprice,ZkRefundPrice,* FROM tbreti



SELECT TOP 100 tbcash.coupno,tbreti.totprice,yjprice+bpprice,tbreti.disct,tbreti.ZkRefundPrice
,tbReti.stotprice-tbreti.totprice+yjprice+bpprice+tbcash.disct-tbreti.ZkRefundPrice [��Ʊ����]
,tbReti.profit
from tbreti 
left join tbcash on tbreti.ticketno = tbcash.ticketno and tbreti.reno=tbcash.reti 
left join tbCompanyM on tbreti.cmpcode = cmpid  
where ExamineDate >= '2017-12-01' and ExamineDate <'2018-01-01' 
and tbreti.status2 not in(1,3,4) 
AND tbreti.ZkRefundPrice<>0

--=====�������--�������--��ƱӦ�ռ�Ӧ������--��Ʊ�ɱ��������ѯ�б� start---> =======================================
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
where ExamineDate >= '2017-12-01' and ExamineDate <'2018-01-01' 
and tbreti.status2 not in(1,3,4) 
group by tbreti.cmpcode,cmpname
ORDER BY tbReti.cmpcode 

--ע�� ��Ʊ��Ʊ�ź���Ʊ���ſ���ΪNull
SELECT tbreti.status2,* FROM tbreti 
left join tbcash on tbreti.ticketno = tbcash.ticketno and tbreti.reno=tbcash.reti 
WHERE dbo.tbcash.id IS NULL

--ע�� cmpcode�ǻ��з�
SELECT r.id,r.coupno,r.ticketno,r.ExamineDate,r.cmpcode,c.cmpcode,CASE WHEN c.cmpcode=CHAR(10) THEN 1 ELSE 0 END FROM dbo.tbReti r INNER JOIN tbcash c ON r.cmpcode=CHAR(10) AND r.coupno=c.coupno AND r.ticketno=c.ticketno 
SELECT ExamineDate,* FROM dbo.tbReti WHERE cmpcode=CHAR(10)
UPDATE tbReti SET cmpcode='' WHERE cmpcode=CHAR(10)
--��Ʊ�ɱ�
select t_source,count(*)as num,sum(tbreti.stotprice) as stotprice 
from tbreti 
inner join tbcash on tbreti.ticketno = tbcash.ticketno and tbreti.reno=tbcash.reti 
left join tbCompanyM on tbreti.cmpcode = cmpid  
where ExamineDate >= '2017-09-01' and ExamineDate <'2017-10-01' and tbreti.status2 not in(1,3,4) 
group by t_source 

--��Ʊ��������������ϸ

SELECT tbreti.id, tbreti.cmpcode,tbreti.custid,tbcash.datetime
,tbReti.stotprice [HSӦ�ս��]
,tbreti.totprice[HSӦ�����]
,tbcash.yjprice[��λӶ���]
,tbcash.bpprice [��������]
,tbreti.disct[��������]
--,tbcash.disct[��������2]
,tbreti.ZkRefundPrice[������Ʊ�ѵֳ��������]
,tbReti.stotprice-tbreti.totprice+yjprice+bpprice+tbcash.disct-tbreti.ZkRefundPrice
,tbReti.profit
from tbreti 
left join tbcash on tbreti.ticketno = tbcash.ticketno and tbreti.reno=tbcash.reti 
left join tbCompanyM on tbreti.cmpcode = cmpid  
where ExamineDate >= '2017-09-01' and ExamineDate <'2017-10-01' 
and tbreti.status2 not in(1,3,4) 

--=====end---<-------=======================================


151283
151284
151416
151282
151105
152008
151289
152339
151104
152340
151236

--AND tbreti.disct<>tbcash.disct
AND dbo.tbReti. id IN (130241,125705,131456,130240)

UPDATE tbreti SET disct=20,profit=14 WHERE id=130241
UPDATE tbreti SET disct=5,profit=53 WHERE id=125705
UPDATE tbreti SET disct=10,profit=61 WHERE id=131456
UPDATE tbreti SET disct=30,profit=44 WHERE id=130240



SELECT SUM(tbreti.profit),COUNT(1)
SELECT tbreti.id, dbo.tbReti.cmpcode,dbo.tbReti.custid,LEN(dbo.tbreti.cmpcode),CASE WHEN tbreti.cmpcode='' THEN 1 ELSE 0 end ,REPLACE(tbreti.cmpcode,CHAR(10),'br')
from tbreti 
left join tbcash on tbreti.ticketno = tbcash.ticketno and tbreti.reno=tbcash.reti 
left join tbCompanyM on tbreti.cmpcode = cmpid  
where ExamineDate >= '2015-10-01' and ExamineDate <'2015-11-01' 
and tbreti.status2 not in(1,3,4) 
AND NOT(
len(tbreti.cmpcode)=6 
OR (tbreti.custid <>'' and  tbreti.cmpcode='')
OR (tbreti.custid ='' and  tbreti.cmpcode=''  )
)

                       

