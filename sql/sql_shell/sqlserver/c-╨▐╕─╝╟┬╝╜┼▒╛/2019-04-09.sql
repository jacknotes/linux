

IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as ��λ���,t1.cmpname as ��λ����
,(case CustomerType when 'A' then '���õ�λ�ͻ�' when 'C' then '���ε�λ�ͻ�' else '' end) as ��λ����
,(CASE hztype WHEN 0 THEN '�ҷ���ֹ����' WHEN 1 THEN '�������������½�' WHEN 2 THEN '�������������ֽ�' WHEN 3 THEN '����������ʱ�½�' WHEN 4 THEN '�Է���ֹ����'  ELSE '' END) as ����״̬
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as ������
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as �ۺ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as ά����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as ����ҵ�����
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as ����ҵ�����
,indate
into #cmp1
from tbCompanyM t1
left join homsomdb..Trv_UnitCompanies t4 on t1.cmpid=t4.Cmpid
--������
left join homsomDB..Trv_UnitCompies_Sales t5 on t4.ID=t5.UnitCompayID
--�ͻ�����
left join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t4.ID=t6.UnitCompanyID
--ά����
left join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.UnitCompanyID=t4.ID
--����ҵ�����
left join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t7.TrvUnitCompanyID=t4.ID
--����ҵ�����
left join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t8.TktUnitCompanyID=t4.ID
--��Ա��Ϣ
left join homsomDB..SSO_Users t9 on
t9.ID=t5.EmployeeID and t9.ID=t6.EmployeeID and t9.ID=t8.TktTCID and t9.ID=t7.TrvTCID 
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid

--select * from #cmp1 where indate>='2018-01-01'

--����10��֮�� �¿ͻ�
select cmp1.������,SUM(DisCountProfit) as �������� from tbTrvCoup c
inner join tbTravelBudget b on b.TrvId=c.TrvId
inner join #cmp1 cmp1 on cmp1.��λ���=c.Cmpid
where c.OperDate>='2019-03-01' and c.OperDate<'2019-04-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
and cmp1.indate>'2018-04-01'
group by cmp1.������
order by �������� desc


--����10��֮�� �¿ͻ�
select c.Sales  as �������,SUM(Profit) as �������� from tbConventionCoup c
inner join tbConventionBudget b on b.ConventionId=c.ConventionId
inner join #cmp1 cmp1 on cmp1.��λ���=c.Cmpid
where c.OperDate>='2019-03-01' and c.OperDate<'2019-04-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
--and cmp1.indate>='2018-01-01'
group by c.Sales
order by �������� desc

--����10��֮ǰ �¿ͻ�
select cmp1.������,SUM(DisCountProfit)  as �������� from tbConventionCoup c
inner join tbConventionBudget b on b.ConventionId=c.ConventionId
inner join #cmp1 cmp1 on cmp1.��λ���=c.Cmpid
where c.OperDate>='2019-03-01' and c.OperDate<'2019-04-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
and cmp1.indate>'2018-04-01'
group by cmp1.������
order by �������� desc

--��ͼ�   ���ѵ���ͼۺ������ʱ��
SELECT c.coupno,lp.Price ��ͼ�,lp.DepartureTime,lp.ArrivalTime,lp.Flight
 FROM topway..tbcash c 
LEFT JOIN homsomDB..Trv_DomesticTicketRecord r ON c.coupno=r.RecordNumber
LEFT JOIN homsomDB..Trv_PnrInfos p ON r.PnrInfoID=p.ID
LEFT JOIN homsomDB..Trv_ItktBookings i ON p.ItktBookingID=i.ID
left join homsomDB..Trv_ItktBookingSegs its on i.ID=its.ItktBookingID
left join homsomDB..Trv_LowerstPrices lp on its.ID=lp.ItktBookingSegID
where c.coupno='AS002352363'
order by c.coupno

--���˸ĳ�δ��
select haschecked,* from FinanceERP_ClientBankRealIncomeDetail 
--update FinanceERP_ClientBankRealIncomeDetail set haschecked=0
where date='2019-03-28' and money='950'

--����
select status,owe,CustomerPayWay,* from Topway..tbcash 
--update Topway..tbcash set status=1
where coupno='AS002372155'

--PC�� ����

select sum(price) ����,COUNT(*) ���� from Topway..tbcash  c
left join homsomDB..Trv_ItktBookings i on c.BaokuID=i.ID
where ModifyBillNumber in ('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201')
and cmpcode='020459'
and i.BookingSource='1'
--and i.BookingSource in ('5','10','11')
--and i.BookingSource in ('2','3','4')
and inf=0
and tickettype='����Ʊ'


/*
CZ HO MF
2018-01-01��2019-03-31
���Ե�λ������Ϊ�������Գ˻��˵ó˻���������
��˾ ��λ���� �˻��� ֤������ ֤���� �˻�����
*/
--��������
IF OBJECT_ID('tempdb.dbo.#cmp2') IS NOT NULL DROP TABLE #cz1
SELECT cmpcode ��λ���CZ,SUM(totprice) ���� 
into #cz1
FROM Topway..V_TicketInfo 
WHERE ride='CZ'
AND tickettype='����Ʊ'
and datetime>='2018-01-01'
and datetime<'2019-04-01'
group by cmpcode
order by ���� desc

IF OBJECT_ID('tempdb.dbo.#cmp2') IS NOT NULL DROP TABLE #ho1
SELECT cmpcode ��λ���HO,SUM(totprice) ���� 
into #ho1
FROM Topway..V_TicketInfo 
WHERE ride='HO'
AND tickettype='����Ʊ'
and datetime>='2018-01-01'
and datetime<'2019-04-01'
group by cmpcode
order by ���� desc

IF OBJECT_ID('tempdb.dbo.#cmp2') IS NOT NULL DROP TABLE #mf1
SELECT cmpcode ��λ���MF,SUM(totprice) ���� 
into #mf1
FROM Topway..V_TicketInfo 
WHERE ride='MF'
AND tickettype='����Ʊ'
and datetime>='2018-01-01'
and datetime<'2019-04-01'
group by cmpcode
order by ���� desc

select isnull(un.Name,'') ��λ����,cz.���� CZ����,ho.���� HO����,mf.���� MF���� from #cz1 cz
left join homsomDB..Trv_UnitCompanies un on un.Cmpid=cz.��λ���CZ
left join #ho1 ho on ho.��λ���HO=cz.��λ���CZ
left join #mf1 mf on mf.��λ���MF=cz.��λ���CZ
order by CZ���� desc 

--�˻��˵ó˻�����
select ride,un.Name,pasname,(case PassportType when '1' then '���֤' when '2' then '����'
 when '3' then 'ѧ��֤'  when '4' then '����֤'  when '5' then '����֤'  when '6' then '��������þ���֤'
  when '7' then '�۰�ͨ��֤'  when '8' then '̨��ͨ��֤' when '9' then '���ʺ�Ա֤' when '10' then '̨��֤'
  else '����' end) ֤������,
C.idno,COUNT(pasname) �˻�����
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies un on un.Cmpid=c.cmpcode
left join homsomDB..Trv_Credentials cr on cr.CredentialNo=c.idno
where tickettype='����Ʊ'
and datetime>='2018-01-01'
and datetime<'2019-04-01'
and reti<>''
and ride in ('CZ','HO','MF')
group by PassportType,C.idno,ride,un.Name,pasname
order by �˻����� desc

/*
CZ HO MF
2018-01-01��2019-03-31
���Ե�λ������Ϊ�������Գ˻��˵ó˻���������
��˾ ��λ���� �˻��� ֤������ ֤���� �˻�����
*/
--CZ
SELECT cmpcode,ride,SUM(totprice) AS totprice INTO #cmpV FROM tbcash WHERE ride IN('CZ') AND 
datetime>='2018-01-01' AND datetime<'2019-04-01' AND inf=0 AND tickettype='����Ʊ' AND cmpcode<>''
GROUP BY cmpcode,ride

SELECT cmpcode,ride,pasname,idno,COUNT(pasname) AS num INTO #perV FROM tbcash WHERE ride IN('CZ') AND 
datetime>='2018-01-01' AND datetime<'2019-04-01' AND inf=0 AND tickettype='����Ʊ' AND cmpcode<>''
GROUP BY cmpcode,ride,pasname,idno

SELECT c.*,p.pasname,p.idno,p.num FROM #perV p
LEFT JOIN #cmpV c ON p.cmpcode=c.cmpcode AND p.ride=c.ride
ORDER BY c.totprice,p.num DESC

--HO
SELECT cmpcode,ride,SUM(totprice) AS totprice INTO #cmpV1 FROM tbcash WHERE ride IN('HO') AND 
datetime>='2018-01-01' AND datetime<'2019-04-01' AND inf=0 AND tickettype='����Ʊ' AND cmpcode<>''
GROUP BY cmpcode,ride

SELECT cmpcode,ride,pasname,idno,COUNT(pasname) AS num INTO #perV1 FROM tbcash WHERE ride IN('HO') AND 
datetime>='2018-01-01' AND datetime<'2019-04-01' AND inf=0 AND tickettype='����Ʊ' AND cmpcode<>''
GROUP BY cmpcode,ride,pasname,idno

SELECT c.*,p.pasname,p.idno,p.num FROM #perV1 p
LEFT JOIN #cmpV1 c ON p.cmpcode=c.cmpcode AND p.ride=c.ride
ORDER BY c.totprice,p.num DESC

--mf
SELECT cmpcode,ride,SUM(totprice) AS totprice INTO #cmpmf FROM tbcash WHERE ride IN('mf') AND 
datetime>='2018-01-01' AND datetime<'2019-04-01' AND inf=0 AND tickettype='����Ʊ' AND cmpcode<>''
GROUP BY cmpcode,ride

SELECT cmpcode,ride,pasname,idno,COUNT(pasname) AS num INTO #permf FROM tbcash WHERE ride IN('mf') AND 
datetime>='2018-01-01' AND datetime<'2019-04-01' AND inf=0 AND tickettype='����Ʊ' AND cmpcode<>''
GROUP BY cmpcode,ride,pasname,idno

SELECT c.*,p.pasname,p.idno,p.num FROM #permf p
LEFT JOIN #cmpmf c ON p.cmpcode=c.cmpcode AND p.ride=c.ride
ORDER BY c.totprice,p.num DESC


--����֧����ʽ���Ը����渶��
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set TCPayNo=PayNo,PayNo=null,AdvanceStatus=PayStatus,PayStatus=0,TcPayWay=CustomerPayWay,CustomerPayWay=0,TcPayDate=CustomerPayDate,CustomerPayDate='1900-01-01'
where coupno in('AS002376475','AS002376476')

select PayStatus,AdvanceStatus,PayNo,TCPayNo,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET AdvanceStatus=PayStatus,TCPayNo=PayNo,TcPayWay=CustomerPayWay,TcPayDate=CustomerPayDate,PayStatus=0,PayNo=NULL,CustomerPayWay=0,CustomerPayDate='1900-01-01'
WHERE coupno in('AS002376475','AS002376476')

