--�ĳ�δ�ĺ�Ӧ�ջ��δ���
select haschecked,state,* from Topway..FinanceERP_ClientBankRealIncomeDetail 
--update Topway..FinanceERP_ClientBankRealIncomeDetail  set state=5,haschecked=0
where money='2200' and date='2019-06-05'

  
/*
1�������¿ͻ����λ���10��1��֮ǰ¼��Ԥ�㵥��������      ��10��1��֮��¼��Ԥ�㵥��������

2�� ������ʼ���������10�·�¼Ԥ�㵥���Ƿ��С�10��1��֮ǰ¼��Ԥ�㵥��������10��1��֮��¼��Ԥ�㵥��������
*/


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
where c.OperDate>='2019-05-01' and c.OperDate<'2019-06-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
and cmp1.indate>'2018-05-01'
group by cmp1.������
order by �������� desc


--����10��֮�� �¿ͻ�
select c.Sales  as �������,SUM(Profit) as �������� from tbConventionCoup c
inner join tbConventionBudget b on b.ConventionId=c.ConventionId
inner join #cmp1 cmp1 on cmp1.��λ���=c.Cmpid
where c.OperDate>='2019-05-01' and c.OperDate<'2019-06-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
--and cmp1.indate>='2018-01-01'
group by c.Sales
order by �������� desc

--����10��֮ǰ �¿ͻ�
select cmp1.������,SUM(DisCountProfit)  as �������� from tbConventionCoup c
inner join tbConventionBudget b on b.ConventionId=c.ConventionId
inner join #cmp1 cmp1 on cmp1.��λ���=c.Cmpid
where c.OperDate>='2019-05-01' and c.OperDate<'2019-06-01'
and b.OperDate>='2018-10-01'
--and b.OperDate<'2018-10-01'
and cmp1.indate>'2018-05-01'
group by cmp1.������
order by �������� desc

--��ȡһ�ݻ�����Ӫ��-��֮�� �Ź㺮 ����Х��2019��5�·���ɱ��ŵ�����EXECL��
/*
1.��������
2.Ԥ�㵥��
3.��λ����
4.��Ӧ�̽�����Ϣ����Ӧ����Դ
5.�������
6.�ʽ����
*/

select distinct c.OperDate ��������,c.ConventionId Ԥ�㵥��,u.Name ��λ����,GysSource ��Ӧ����Դ,
Sales �������,FinancialCharges �ʽ����
from Topway..tbConventionCoup c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.Cmpid
left join Topway..tbConventionJS j on j.ConventionId=c.ConventionId
where c.OperDate<'2019-06-01' and c.OperDate>='2019-05-01'
and Sales in ('��֮��','�Ź㺮','����Х')
and Status<>2
order by ��������

--���˸ĳ�δ��
select haschecked,* from Topway..FinanceERP_ClientBankRealIncomeDetail 
--update Topway..FinanceERP_ClientBankRealIncomeDetail  set haschecked=0
where money='2200' and date='2019-06-05'

/*UC019293�ֵܣ��й�����ҵ���޹�˾
 
�����ȡ��˾2018/4/1-2019/4/30���ڻ�Ʊȫ�۲յĳ�Ʊ���ݣ���Ҫ��Ϣ���£�
 
��Ʊ���ڡ��˿����������š�·�ߡ����ۼۡ���Ʊ����
 
*/
select convert(varchar(10),datetime,120) ��Ʊ����,pasname �˿�����,Department ����,route ·��,totprice ���ۼ�,reti ��Ʊ����,
tickettype ����
from Topway..tbcash 
where cmpcode='019293'
and datetime>='2018-04-01'
and datetime<'2019-05-01'
and inf=0
and nclass='Y'
order by ��Ʊ����


/*
 
����Ҫ���Ǹ��������ͻ�������ȥ�����æ�ṩ������ͨ����Ʊ�ۡ��ĵ�λ���ݵ���������Ӧ���������Ӫ����лл��
 
 UC��  ��λ����     �����    �Ƿ�������   MU������F ��J ��Y����   MU������Y����������  ���ù���  ��Ӫ����  �ͻ�����
 
��ע����ǩ���������ĵ�λȥ����
������  15:46:21
B M E K L N R S V T Z H

select * FROM [homsomdb].[dbo].[Trv_UCSettings]
  where BindAccidentInsurance is not null and BindAccidentInsurance <>''
*/

IF OBJECT_ID('tempdb.dbo.#company') IS NOT NULL DROP TABLE #company
SELECT 
u.Cmpid,
u.Name,
CASE WHEN ISNULL(BindAccidentInsurance,'')='' THEN '��' ELSE '��' END �Ƿ�������
INTO #company
FROM homsomDB..Trv_UnitCompanies u 
LEFT JOIN homsomDB..Trv_UCSettings s ON u.UCSettingID=s.ID
WHERE 
IsSepPrice=0 --����
AND CooperativeStatus NOT IN(0,4) AND u.Type='A'

IF OBJECT_ID('tempdb.dbo.#xlgaocang') IS NOT NULL DROP TABLE #xlgaocang
SELECT 
cmpcode,SUM(fuprice) as fuprice,SUM(totprice) AS totprice,SUM(price+tax) AS pricetax 
INTO #xlgaocang
FROM tbcash WHERE datetime BETWEEN '2019-01-01' AND '2019-06-30' AND cmpcode<>'' 
AND nclass IN('F','J','Y') AND cmpcode IN(SELECT cmpid FROM #company) AND inf IN('0')
GROUP BY cmpcode

IF OBJECT_ID('tempdb.dbo.#xldicang') IS NOT NULL DROP TABLE #xldicang
SELECT  cmpcode,SUM(totprice) AS totprice,SUM(price+tax) AS pricetax 
INTO #xldicang
FROM tbcash WHERE datetime BETWEEN '2019-01-01' AND '2019-06-30' AND cmpcode<>'' 
AND nclass IN('B','M','E','K','L','N','R','S','V','T','Z','H') AND cmpcode IN(SELECT cmpid FROM #company) AND inf IN('0')
GROUP BY cmpcode



IF OBJECT_ID('tempdb.dbo.#Final') IS NOT NULL DROP TABLE #Final
SELECT 'UC'+c.Cmpid AS '��λ���',
c.Name AS '��λ����',
c.�Ƿ�������,
CONVERT(DECIMAL(18,1),ISNULL(g.totprice,0)) AS '�߲�����',
CONVERT(DECIMAL(18,1),ISNULL(d.totprice,0))  AS '�Ͳ�����',
t.TcName AS ���ù���,
h.MaintainName AS ��Ӫ����,
h1.MaintainName AS �ͻ�����,
i.GroupName AS С���� 
INTO #Final
FROM #company c
LEFT JOIN #xlgaocang g ON c.Cmpid=g.cmpcode
LEFT JOIN #xldicang d ON c.Cmpid=d.cmpcode
LEFT JOIN dbo.HM_AgreementCompanyTC t ON c.Cmpid=t.Cmpid AND t.isDisplay=0 AND t.TcType=0
LEFT JOIN dbo.HM_ThePreservationOfHumanInformation h ON c.Cmpid=h.Cmpid AND h.IsDisplay=1 AND h.MaintainType=9
LEFT JOIN dbo.HM_ThePreservationOfHumanInformation h1 ON c.Cmpid=h1.Cmpid AND h1.IsDisplay=1 AND h1.MaintainType=1
LEFT JOIN dbo.Emppwd e ON t.TcName=e.empname
LEFT JOIN dbo.HM_TCGroupInfo i ON e.groupid=i.Pkey
ORDER BY i.GroupName

--��ǩ���������ĵ�λ
if OBJECT_ID('tempdb..#zq') is not null drop table #zq
select top 2172 convert(varchar(10),NewEndTime,120) ����,NewEndTime,Cmpid 
into #zq
from homsomDB..Trv_FlightTripartitePolicies t
left join homsomDB..Trv_UnitCompanies u on u.ID=t.UnitCompanyID
where (t.Name like '%����%' or t.Name like '%����%' or t.Name like '%sme%' )
and u.Type='a' and u.CooperativeStatus not in ('0','4')
order by ���� desc

SELECT * FROM #Final f WHERE f.��λ��� NOT IN(select 'UC'+CmpId from #zq) 

/*
��Ʊ����2017.5.1-2018.8.31
UC019837�ϰ�����������������޹�˾
UC019847�ϰ�����������������޹�˾�����ֹ�˾
UC019836�ϰ�����������������޹�˾���ݷֹ�˾
*/
select convert(varchar(10),datetime,120) ��Ʊ����,begdate �������,pasname �˻���,route �г�,ride+flightno �����,
case when inf=0 then '����' when inf=1 then '����' else '' end  ���ڻ����,price ���۵���,tax ˰��,fuprice �����,
totprice ���ۼ�,reti ��Ʊ����,Department ����,isnull(CostCenter,'') �ɱ�����,tcode+ticketno Ʊ��,nclass ��λ
from Topway..tbcash 
where cmpcode='019836'
and datetime>='2017-05-01'
and datetime<'2018-09-01'
and inf in(1,0)
order by ��Ʊ����


--UC020842 ��λ���͡����㷽ʽ���˵���ʼ���ڡ������¡�ע�� ע���¸�Ϊ2018��7��3��
select indate,* from Topway..tbCompanyM 
--update Topway..tbCompanyM  set indate='2018-07-03'
where cmpid='020842'

select RegisterMonth,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies  set RegisterMonth='07 03 2018  8:57AM'
where Cmpid='020842'


/*��Ʊ����2018.7.1-2019.6.9�����ڻ�Ʊ����ƾ֤ĿǰΪ����Ʊ���������ˡ�FM MU�������ݡ�
��Ҫ�ֶΣ�UC�š�������������������ѽ���Ʊ���������������/���������İٷֱȣ������ֶ������иߵ��ͣ�
*/
select cmpcode UC��,SUM(totprice) ��������,SUM(originalprice-price) ��������ѽ��,COUNT(1 )��Ʊ����,'' ��������Ѻ͹��������İٷֱ�
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies un on un.Cmpid=c.cmpcode
where CertificateD=2
and inf=0
and ride in('FM','mu')
and datetime>='2018-07-01'
and datetime<'2019-06-10'
group by cmpcode
order by ��������Ѻ͹��������İٷֱ� desc


--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='018746_20190501'

select TrainBillStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set TrainBillStatus=1
where BillNumber='019358_20190401'

--�����տ��Ϣ
select Skstatus,* from Topway..tbConventionKhSk
--update Topway..tbConventionKhSk set Skstatus=2
where ConventionId='1429' and Id='2747'

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002532485','AS002531817','AS002533350','AS002533398')

--��������020459�����λ��Ա����ƱԤ��Ȩ��������Ԥ�������������ø���Ҧ�ϻ�

select h.Name from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
left join homsomDB..Trv_UPSettings up on u.UPSettingID=up.ID
left join homsomDB..Trv_BookingCollections b on b.ID=up.BookingCollectionID
where Cmpid='020459' and IsDisplay=1 and BookingType=3

--UC020316��¡�Ҿ�������Ϻ������޹�˾
--�鷳��ȡ�����������Ʊ����
select datetime ��Ʊ����,begdate �������,coupno,tcode+ticketno,pasname,route,totprice,reti,tickettype from Topway..tbcash 
where cmpcode='020316'
and inf=1
and begdate>='2019-06-01'
order by �������



--UC020543�Ϻ����ࣨ���ţ����޹�˾  _20180901--20190501 MU/FM�����ݣ���Ʊ���ڣ�������ڣ���λ���룬�˿�����������ţ���·�����۵��ۣ�˰�գ������ܼۣ������,ȫ�� �ۿ��ʡ�
select convert(varchar(10),datetime,120) ��Ʊ����,begdate �������,nclass ��λ����,pasname �˿�����,ride+flightno �����,route ��·,
price ���۵���,tax ˰��,totprice �����ܼ�,fuprice �����,priceinfo ȫ��,'' �ۿ���
from Topway..tbcash 
where cmpcode='020543'
and datetime>='2018-09-01'
and datetime<'2019-05-01'
and ride in('mu','fm')
order by ��Ʊ����

/*UC018919
1����Ʊ��2019��1��1�ſ�ʼ��2019��5��31��
 
2����Ҫ֪�������ϳ�Ʊ��������������Ʊ�۵ĵ��ӣ������ֶ����£�
 
��Ʊ���� �������۵��� Ʊ��  �˿�����  ���� ��λ ���۵��� ���㵥�� ��������   
*/
select datetime ��Ʊ����,coupno �������۵���,tcode+ticketno Ʊ��,pasname �˿�����,route ����,nclass ��λ,price ���۵���,sprice1+sprice2+sprice3+sprice4 ���㵥��,profit ��������
from Topway..tbcash
where cmpcode='018919'
and datetime>='2019-01-01'
and datetime<'2019-06-01'
and baoxiaopz<>0
order BY ��Ʊ����

--����Ʊ��
--select pasname,* from Topway..tbcash where coupno='AS002537123'

update Topway..tbcash set tcode='057',ticketno='1433862213',pasname='CAO/GUILIANG' where coupno='AS002537123' and pasname='�˿�0'
update Topway..tbcash set tcode='057',ticketno='1433862214',pasname='CHEN/HAIJUN' where coupno='AS002537123' and pasname='�˿�1'
update Topway..tbcash set tcode='057',ticketno='1433862215',pasname='CUI/CHAOYU' where coupno='AS002537123' and pasname='�˿�2'
update Topway..tbcash set tcode='057',ticketno='1433862216',pasname='DENG/XIJUN' where coupno='AS002537123' and pasname='�˿�3'
update Topway..tbcash set tcode='057',ticketno='1433862217',pasname='DING/JIAPEI' where coupno='AS002537123' and pasname='�˿�4'
update Topway..tbcash set tcode='057',ticketno='1433862218',pasname='FANG/XIAOJUN' where coupno='AS002537123' and pasname='�˿�5'
update Topway..tbcash set tcode='057',ticketno='1433862219',pasname='GE/CHENGBING' where coupno='AS002537123' and pasname='�˿�6'
update Topway..tbcash set tcode='057',ticketno='1433862220',pasname='LIU/YUAN' where coupno='AS002537123' and pasname='�˿�7'
update Topway..tbcash set tcode='057',ticketno='1433862221',pasname='LU/RUIYONG' where coupno='AS002537123' and pasname='�˿�8'
update Topway..tbcash set tcode='057',ticketno='1433862222',pasname='LUO/LIJUN' where coupno='AS002537123' and pasname='�˿�9'
update Topway..tbcash set tcode='057',ticketno='1433862223',pasname='MA/XINGFU' where coupno='AS002537123' and pasname='�˿�10'
update Topway..tbcash set tcode='057',ticketno='1433862224',pasname='SHAO/GAICI' where coupno='AS002537123' and pasname='�˿�11'
update Topway..tbcash set tcode='057',ticketno='1433862225',pasname='SHEN/CHAOJUN' where coupno='AS002537123' and pasname='�˿�12'
update Topway..tbcash set tcode='057',ticketno='1433862226',pasname='WEI/JIAN' where coupno='AS002537123' and pasname='�˿�13'
update Topway..tbcash set tcode='057',ticketno='1433862227',pasname='WEI/YUQING' where coupno='AS002537123' and pasname='�˿�14'
update Topway..tbcash set tcode='057',ticketno='1433862228',pasname='XIE/JINFENG' where coupno='AS002537123' and pasname='�˿�15'
update Topway..tbcash set tcode='057',ticketno='1433862229',pasname='YAN/JINJIN' where coupno='AS002537123' and pasname='�˿�16'
update Topway..tbcash set tcode='057',ticketno='1433862230',pasname='YUAN/SHOUYAO' where coupno='AS002537123' and pasname='�˿�17'
update Topway..tbcash set tcode='057',ticketno='1433862231',pasname='YUE/ZHAOHUI' where coupno='AS002537123' and pasname='�˿�18'
update Topway..tbcash set tcode='057',ticketno='1433862232',pasname='ZHANG/WANLONG' where coupno='AS002537123' and pasname='�˿�19'
update Topway..tbcash set tcode='057',ticketno='1433862233',pasname='ZHANG/ZHIZHONG' where coupno='AS002537123' and pasname='�˿�20'
update Topway..tbcash set tcode='057',ticketno='1433862234',pasname='ZHAO/JIANFENG' where coupno='AS002537123' and pasname='�˿�21'
update Topway..tbcash set tcode='057',ticketno='1433862235',pasname='ZHI/RUIXIU' where coupno='AS002537123' and pasname='�˿�22'
