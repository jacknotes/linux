--UC020518 �Ϻ����꽨�����޹�˾ 2.12��֮ǰ����ĳ��ÿ�����

SELECT 
ISNULL(c.Cmpid,'') AS ��λ���,
ISNULL(c.Name,'') AS ��λ����,
ISNULL(h.Name,'') AS ������,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS Ӣ����,
h.Mobile AS �ֻ�����,
ISNULL((SELECT TOP 1 empname FROM Topway..Emppwd WHERE idnumber=h.CreateBy),'') AS ���ù���,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS ��Ӫ����
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate<='2019-02-12' --AND h.CreateDate<'2019-02-14' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT idnumber FROM Topway..Emppwd WHERE dep='��Ӫ��' AND idnumber NOT IN('00002','00003','0421'))
and c.Cmpid='020518'
UNION ALL

SELECT 
ISNULL(c.Cmpid,'') AS ��λ���,
ISNULL(c.Name,'') AS ��λ����,
ISNULL(h.Name,'') AS ������,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS Ӣ����,
ISNULL(h.Mobile,'') AS �ֻ�����,
h.CreateBy AS ���ù���,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS ��Ӫ����
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate<='2019-02-12' --AND h.CreateDate<'2019-02-14' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT empname FROM Topway..Emppwd WHERE dep='��Ӫ��' AND empname NOT IN('homsom','��˳����','��Ӫ��ѵ����'))
and c.Cmpid='020518'

select Name ����,Mobile �绰,CreateDate �������� from homsomDB..Trv_Human  h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
where u.CompanyID=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='020518')
and CreateDate<='2019-02-12'
order by CreateDate

--��Ӧ����Դ
select t_source,* FROM Topway..tbcash 
--UPDATE Topway..tbcash SET t_source='HSBSPETI'
WHERE coupno='AS002324474'

--���㱣�ռ۽�λ
select sprice1,totsprice,* FROM Topway..tbcash 
--UPDATE Topway..tbcash  SET sprice1=2,totsprice=2
WHERE coupno IN('AS002296182','AS002299311','AS002299310','AS002299312','AS002299313','AS002299314','AS002303818','AS002303819','AS002303820', 
'AS002303821','AS002303828','AS002303830','AS002315492','AS002315692')

--��λ���͡����㷽ʽ���˵���ʼ���ڡ������¡�ע����
--ע����
SELECT CustomerType,indate ע��,depdate0 ����,sform,* FROM Topway..tbCompanyM 
--update Topway..tbCompanyM  set indate='2019-03-18',sform='�½�(����)'
WHERE cmpid='016890'

select Type,RegisterMonth,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set RegisterMonth='03  18 2019 12:00AM'
where Cmpid='016890'

--���㷽ʽ
select * from Topway..HM_CompanyAccountInfo 
where CmpId='016890'

select SEndDate,Status,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SEndDate='2019-02-28',Status=-1
where CmpId='016890' and Status=1

select SStartDate,Status,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SStartDate='2019-03-01',Status=1
where CmpId='016890' and Status=2

SELECT EndDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes  set EndDate='2019-02-28',Status='-1'
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '016890') and Status=1

SELECT StartDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set StartDate='2019-03-01',Status=1
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '016890') and Status=2

--�˵�
select * from Topway..AccountStatement where CompanyCode='016890' order by BillNumber desc

select SX_BaseCreditLine,SX_TotalCreditLine* from Topway..AccountStatement where BillNumber='016890_20190301'

--������2018��7-12�����
--����
IF OBJECT_ID('tempdb.dbo.#mileage') IS NOT NULL DROP TABLE #mileage
select DISTINCT rtrim(cityfrom)+'-'+rtrim(cityto) route,mileage,kilometres 
into #mileage
from tbmileage

IF OBJECT_ID('tempdb.dbo.#tbcash1') IS NOT NULL DROP TABLE #tbcash1
select coupno as ���۵���,ride+flightno as �����,datetime as ��Ʊ����,begdate �������,pasname �˿�����
,case SUBSTRING(route,1,CHARINDEX('-',route)-1) when '�Ϻ��ֶ�' then '�Ϻ�' when '�Ϻ�����' then '�Ϻ�' when '�����׶�' then '����' when '������Է' then '����' when '��������' then '����' 
when '��������' then '����' when '����' then '��ͷ' when '�人���' then '�人' when '����' then '��˫����' when '�����첼����' then '�����첼' when '�º�' then 'â��' when '˼é' then '�ն�' when '÷��' then '÷��'
else SUBSTRING(route,1,CHARINDEX('-',route)-1) end as ����
,case REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) when '�Ϻ��ֶ�' then '�Ϻ�' when '�Ϻ�����' then '�Ϻ�' when '�����׶�' then '����' when '������Է' then '����' when '��������' then '����' 
when '��������' then '����' when '����' then '��ͷ' when '�人���' then '�人' when '����' then '��˫����' when '�����첼����' then '�����첼' when '�º�' then 'â��' when '˼é' then '�ն�' when '÷��' then '÷��'
else  REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) end as ����
,route as �г�
,t_source as ��Ӧ����Դ
into #tbcash1
from tbcash c
where cmpcode='020459'
and (datetime>='2018-07-01' and datetime<'2019-01-01')
and inf=0
and route like ('%-%')
and reti=''
and tickettype='����Ʊ'
order by datetime

IF OBJECT_ID('tempdb.dbo.#tbcash') IS NOT NULL DROP TABLE #tbcash
select *,����+'-'+���� as route2,����+'-'+���� as route3
into #tbcash
from #tbcash1


IF OBJECT_ID('tempdb.dbo.#tt') IS NOT NULL DROP TABLE #tt
select ���۵���,tbcash.�г�,��Ʊ����,�������,�˿�����,mileage Ӣ��,kilometres ����
into #tt
from #tbcash tbcash
left join #mileage mileage on mileage.route=tbcash.route2 or mileage.route=tbcash.route3

select * from #tt
order by ��Ʊ����
where kilometres is null

--����
select coupno ���۵���,route �г�,datetime ��Ʊ����,begdate �������,pasname �˿��� ,'' Ӣ��,'' ����  from Topway..tbcash
where cmpcode='020459'
and (datetime>='2018-07-01' and datetime<'2019-01-01')
and inf=0
and route like ('%-%')
and reti=''
and tickettype='����Ʊ'
order by datetime


select * from topway..tmpdata


--����ģ��id����
--select * from homsomDB..Trv_UnitCompanies where Cmpid='020380'

SELECT n.ProcessPerson,n.ProcessPersonName,h.IsDisplay,
(SELECT h1.id FROM homsomDB..Trv_Human h1 INNER JOIN homsomDB..Trv_UnitPersons u1 ON u1.ID = h1.ID AND h1.name=n.ProcessPersonName AND h1.IsDisplay=1 AND u1.CompanyID='1D209DB4-4F14-4635-B626-A8D600DB5C9E') name1
,h.Name,t.*,* 
--UPDATE workflow..Homsom_WF_Template_Node SET ProcessPerson=(SELECT TOP 1 h1.id FROM homsomDB..Trv_Human h1 INNER JOIN homsomDB..Trv_UnitPersons u1 ON u1.ID = h1.ID AND h1.name=n.ProcessPersonName AND h1.IsDisplay=1  AND u1.CompanyID='1D209DB4-4F14-4635-B626-A8D600DB5C9E') 
FROM workflow..Homsom_WF_Template_Node n 
LEFT JOIN workflow..Homsom_WF_Template t ON n.TemplateID=t.TemplateID
LEFT JOIN homsomDB..Trv_Human  h ON n.ProcessPerson=h.ID
LEFT JOIN homsomDB..Trv_UnitPersons u ON h.id=u.ID
WHERE n.ProcessPerson<>'' 
AND t.CmpID='020380'
--AND n.TemplateID IN(
--SELECT TemplateID FROM workflow..Homsom_WF_Template WHERE TemplateName IN
--('��������ģ��-��ʢ-������','��������ģ��-�ῡ��-������','��������ģ��-Ҧ��-������','��������ģ��-½����-������','��������ģ��-�⿭-������',
--'��������ģ��-����-������','��������ģ��-������-������','��������ģ��-����-������','��������ģ��-ʯ�ݳ�-������','��������ģ��-���컪-������')
--) 
AND h.IsDisplay=0 order by t.templatename


--�˵�����
select TrainBillStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement set TrainBillStatus=1
where BillNumber='018309_20190201'

--�޸�UC�ţ��Ƶ꣩
select * from Topway..tbCusholderM where custname='����'
select custid,custinfo,spersoninfo,* from Topway..tbHtlcoupYf
--update tbHtlcoupYf set custid='D641764',custinfo='�Ͳ�ҽҩ���Ϻ����������ι�˾|����|13962103393|13962103393',spersoninfo='����|13962103393||' 
where coupno in ('PTW078216')

--����Ʒר�ã��������Դ/�����Ϣ�����ʣ�
select feiyong,feiyonginfo,* from Topway..tbcash  
--update Topway..tbcash set feiyonginfo='������λZYI'
where coupno='AS002314148'

select feiyong,feiyonginfo,* from Topway..tbcash  
--update Topway..tbcash set feiyonginfo='������λMYI'
where coupno='AS002310184'

--�Ƶ����۵� �����ܼ� �����Ϊ40201.56
select price,sprice,totprofit,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set sprice='40201.56',totprofit='-0.56'
where CoupNo='PTW078138'
--select price,sprice,totprofit,* from Topway..tbHtlcoupYf where CoupNo='PTW076453'

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='10951',profit='982'
where coupno='AS002322399'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='7564',profit='4241'
where coupno='AS002319994'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='7964',profit='3842'
where coupno='AS002320003'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='7204',profit='4602'
where coupno='AS002320030'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='7964',profit='3842'
where coupno='AS002320057'

--UC016448 ��2018����ڹ��ʵ��������ͳɱ�����CA��
--����
select convert(varchar(6),datetime,112)  �·�,sum(price) ����
from Topway..tbcash
where cmpcode='016448'
and(datetime BETWEEN '2018-01-01' AND '2018-12-31')
and reti=''
and inf=1
and tickettype='����Ʊ'
and CostCenter='ca'
and (route not like '%����%' or route not like'%����%')
group by convert(varchar(6),datetime,112)
order  by �·�

--����
select convert(varchar(6),datetime,112)  �·�,sum(price) ����
from Topway..tbcash
where cmpcode='016448'
and(datetime BETWEEN '2018-01-01' AND '2018-12-31')
and reti=''
and inf=0
and tickettype='����Ʊ'
and CostCenter='ca'
group by convert(varchar(6),datetime,112)
order  by �·�

--����Ʒר�ã��������Դ/�����Ϣ�����ʣ�
select feiyong,feiyonginfo,* from Topway..tbcash  
--update Topway..tbcash set feiyong=717,feiyonginfo='������λZYI'
where coupno='AS002308529'
select feiyong,feiyonginfo,* from Topway..tbcash  
--update Topway..tbcash set feiyong=0,feiyonginfo=''
where coupno='AS002318981'

--�Ƶ�渶���Ը�
select AdvanceMethod,PayMethod,AdvanceStatus,PayStatus,AdvancePayNo,PayNo,AdvanceDate,PaySubmitDate from Topway..tbHtlcoupRefund 
--update Topway..tbHtlcoupRefund  set AdvanceMethod=0,PayMethod=3,AdvanceStatus=0,PayStatus=3,PayNo='4200000261201902262051324341',AdvancePayNo=null,PaySubmitDate='2019-02-26 15:58:34.000',AdvanceDate=null
where CoupNo='PTW076858'

select cwstatus,owe,vpay,opername1,vpayinfo,oth2 from Topway..tbhtlyfchargeoff
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo='PTW076858')

select AdvanceNumber,AdvanceName,AdvanceStatus,AdvanceDate,PayStatus,PayDate from HotelOrderDB..HTL_Orders 
--update HotelOrderDB..HTL_Orders set AdvanceNumber='',AdvanceName='',PayStatus=3,AdvanceStatus=0,PayDate='2019-02-26 15:58:34.000',AdvanceDate=null
where CoupNo='PTW076858'

select AdvancePayNo,PayNo,AdvanceMethod,PayMethod,* from HotelOrderDB..HTL_OrderSettlements 
--update HotelOrderDB..HTL_OrderSettlements  set PayNo='4200000261201902262051324341',AdvancePayNo=null,PayMethod=3,AdvanceMethod=null
where OrderID in(Select OrderID from HotelOrderDB..HTL_Orders where CoupNo='PTW076858')

--�˵�����

select SubmitState,* from  Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='018294_20190116'

--UC019830��ͨ����Ͷ�����޹�˾���ÿ�
select Name,CredentialNo from homsomDB..Trv_UnitPersons u
left join homsomDB..Trv_Human h on h.ID=u.ID
left join homsomDB..Trv_Credentials cr on cr.HumanID=h.ID
where u.CompanyID='681617C0-6857-427F-B793-A73800FFFAC0'
and IsDisplay=1

--���ڻ�Ʊ����ģ��

update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='���ټ�' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='���ǽ�' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�˼Һ�' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='���ٻ' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�O�쿭' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�ƹ���' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='��˳' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='������' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='κ����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�ŏ���' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='��ǿ' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�̴���' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='������' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='���' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='���ٻ�' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='����ϼ' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='���' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�˴���' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='���Ľ�' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='֣�۾�' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�ź���' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�»�' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='������' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�Ե���' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='����1��ģ��-½�ֻ�' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�����' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')


--�ܵ�ƻ�����������
--�ܵ�ƻUPCollectionID
select  e.ID from homsomDB..Trv_Human b
inner join homsomDB..Trv_UnitPersons a on a.ID=b.ID
inner join homsomDB..Trv_UnitCompanies c on a.companyid=c.ID
inner join homsomDB..Trv_UPSettings d on a.UPSettingID=d.ID
inner join homsomDB..Trv_BookingCollections e on d.BookingCollectionID=e.ID
where c.Cmpid='019830' and IsDisplay=1 
and b.Name='�ܵ�ƻ'

select u.ID from homsomDB..Trv_UnitPersons u
left join homsomDB..Trv_Human h on h.ID=u.ID
where h.Name in ('���ټ�','���ǽ�',
'�','�˼Һ�','���ٻ','�O�쿭','����','����',
'�ƹ���','����','����','��˳','������','κ����',
'����','����','����','����','�ŏ���','��ǿ',
'�̴���','������','����','����','���','���ٻ�','����',
'����ϼ','���','����','�����','����','�˴���','���Ľ�','֣�۾�','�ź���','�����','�»�','������','�����','�Ե���','�����')
and u.CompanyID='681617C0-6857-427F-B793-A73800FFFAC0'

--�����µ�����Ԥ��
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','DE41C50A-6B28-452E-B91E-059C0880A898')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','5CA25F1C-9E45-42BD-850F-0B721F67A721')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','D85CB319-CE28-480F-8810-0F71E540546C')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','7456E3C6-0CCD-449C-8184-0F922B25E272')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','3BA9C5CD-144D-4958-B56E-18E6A91AB05C')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','9EA0D7FE-ABD1-4F71-A65C-1A3846B42BA5')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','AE7BB9C3-736B-4128-AB9E-1AB081DBC0CF')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','F348B725-A7DE-41DB-961B-1F8907F2B295')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','CCCA4B84-62BF-4E7C-B9A1-2403223C6387')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','70345E79-E68C-4574-8C06-2C4F619426CA')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','F3CDA9C2-DFDC-45B6-A393-3F4A28E89ADE')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','09A354A2-869A-483E-AB9F-4AFA53AAEEA5')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','E2599853-2A5F-4111-9522-4B118FD28A96')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','53DE15E7-AF19-47A0-A75E-4B5C8D38189C')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','299B97F0-06FD-4364-953E-600069E9E32E')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','2FE2CDC2-779A-4C7F-B268-6A2E19210597')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','A68DAACF-5FD7-498B-A601-6CD2E65C670B')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','05E6295C-2BDB-4FD4-ABAD-734B4BAD66A7')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','F3AAC953-6316-416B-A3E4-7A161FFFC7EA')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','802A1366-1A63-483D-ADAA-80E149375AE0')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','16876598-0127-4684-A0A8-83C686099CC2')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','C4C37FF4-739D-4E2D-BEBA-84E6DD06F66B')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','165EE575-EA5E-4A1F-B56B-8611A8591A53')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','95F5E469-D3B4-4E48-993F-B0838DA8CE7F')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','EA8CBE6C-D417-415F-A2AA-B0848DA93207')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','0370A17E-76D0-4230-953F-B0AB14425B4B')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','109C07EC-B4AB-482F-808D-B26E25A1E1F4')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','773C43BB-24AD-4181-8775-B2D3E3F5E618')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','97A9602C-45AB-4905-B9E0-C4B963C863D5')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','5EE0ACEA-BA30-4C39-95AC-CD1272540009')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','B534DB91-0BC1-4CE8-9B96-DFCFEA865006')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','EB82592B-1693-4E6D-9946-E11AF925DA15')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','5B6485B3-BB95-4C5C-A56F-E96BC9B9D95E')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','B9965D6C-8EFD-4836-99AC-E9CB97680A93')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','F0B44C46-D8FC-43B5-B6AE-EB2540C2A5E0')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','12619D7F-BD4D-4095-8E4E-EC32AA67E104')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','06E04250-0994-423C-8FA0-EFFB18EDCDA2')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','DA940381-E8C9-4101-82C5-F035F8BBB604')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','722E3015-B2AA-4246-B9DB-F2B6FA894D7E')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','E99E7F1D-AB84-4191-91C1-F5E5B49F7F67')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','96F8436A-E506-4C00-8F0E-FACCAB7EC6BA')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','8238754D-6CD7-46C2-86CA-FFDC7B48FDA2')


--����۲��
select totsprice,profit,* from Topway..tbcash  
--update Topway..tbcash set totsprice='9336',profit='945'
where coupno='AS002321892'

--��Ʊ���۵���Ϊδ��
select bpay ,status ,opernum ,oper2,oth2 ,totprice,dzhxDate ,owe  from Topway..tbcash
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
 where coupno in ('AS002250569',
'AS002211474',
'AS002211953',
'AS002212444',
'AS002212444',
'AS002212442',
'AS002214516',
'AS002214646',
'AS002214666',
'AS002215488',
'AS002215488',
'AS002215488',
'AS002215486',
'AS002215486',
'AS002215486',
'AS002215678',
'AS002215678',
'AS002215684',
'AS002215684',
'AS002217432',
'AS002218235',
'AS002220945',
'AS002223196',
'AS002223202',
'AS002223198',
'AS002223205',
'AS002223211',
'AS002223209',
'AS002224699',
'AS002225050',
'AS002225154',
'AS002225227',
'AS002225655',
'AS002225670',
'AS002225672',
'AS002225749',
'AS002226537',
'AS002227475',
'AS002227479',
'AS002227693',
'AS002228014',
'AS002228038',
'AS002228968',
'AS002229288',
'AS002229628',
'AS002229722',
'AS002230139',
'AS002230384',
'AS002230386',
'AS002230561',
'AS002230561',
'AS002230601',
'AS002230741',
'AS002230767',
'AS002230800',
'AS002230819',
'AS002230743',
'AS002230888',
'AS002231477',
'AS002231621',
'AS002231631',
'AS002231716',
'AS002232085',
'AS002232362',
'AS002232347',
'AS002232347',
'AS002232347',
'AS002232347',
'AS002232347',
'AS002232347',
'AS002232347',
'AS002232347',
'AS002232856',
'AS002233025',
'AS002233745',
'AS002234085',
'AS002234098',
'AS002234250',
'AS002234325',
'AS002234327',
'AS002234726',
'AS002235089',
'AS002235175',
'AS002235555',
'AS002236316',
'AS002236938',
'AS002238964',
'AS002239025',
'AS002239109',
'AS002239377',
'AS002240590',
'AS002240597',
'AS002240779',
'AS002240780',
'AS002242526',
'AS002242522',
'AS002243541',
'AS002243535',
'AS002243543',
'AS002243549',
'AS002246984',
'AS002246984',
'AS002246990',
'AS002246990',
'AS002247551',
'AS002247632',
'AS002247632',
'AS002247634',
'AS002247634',
'AS002247926',
'AS002247926',
'AS002247926',
'AS002247928',
'AS002247928',
'AS002247928',
'AS002248004',
'AS002250174',
'AS002250227',
'AS002250227',
'AS002250341')
 
 --�Ƶ����۵���Ϊδ��
 
 select cwstatus,owe,vpay,opername1,vpayinfo,oth2,totprice,operdate1,* from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set cwstatus=0,owe=totprice,opername1='',operdate1='1900-01-01'
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo in('PTW075117','PTW075504','PTW075760','PTW076016'))

/*  ����һ ��ѯ����
    1����Ʊ���ڣ�2018��1��1��--12��31��
    2��ҵ�����ͣ�����
    3����Ӧ����Դ��ȥ���⿪XXXI ������XXX I���渶XXXXI ��B2BXXXI
    4���۳���Ʊ���۳������Ϊ0��10��20
    5������Ҫ�� �����ܵĳ�Ʊ��������    
    */
  select COUNT(1) ��Ʊ���� from Topway..tbcash  
  where datetime>='2018-01-01'  
  and datetime<'2019-01-01'
  and inf=1
  and t_source not like'�⿪%I'
  and t_source not like'����%I'
  and t_source not like'�渶%I'
  and t_source not like'B2B%I'
  --and reti=''
  and totsprice not in ('0','10','20')  
    
  /*  ����� ��ѯ����
    1����Ʊ���ڣ�2018��1��1��--12��31�� 
    2��ҵ�����ͣ�����
    3����Ӧ����Դ��ȥ���⿪XXXI ������XXX I���渶XXXXI ��B2BXXXI
    4���۳���Ʊ���۳������Ϊ0��10��20
    5�����۵����ͣ��������� ���г��а��������ڡ�
    5������Ҫ�� ���۵��š���˾2���롢Ʊ�š��г̡����ù���
*/
select coupno ���۵���,ride ��˾2����,tcode+ticketno Ʊ��,route �г�,sales  ���ù��� from Topway..tbcash  
  where datetime>='2018-01-01'  
  and datetime<'2019-01-01'
  and inf=1
  and t_source not like'�⿪%I'
  and t_source not like'����%I'
  and t_source not like'�渶%I'
  and t_source not like'B2B%I'
  --and reti=''
  and ((tickettype like'%����%' or tickettype like'%����%') or route in('%����%','%����%'))
  and totsprice not in ('0','10','20')  
  
  select bpay ,status ,opernum ,oper2,oth2 ,totprice,dzhxDate ,owe  from Topway..tbcash
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
 where coupno in ('AS002238964','AS002234726','AS002231716','AS002231631','AS002203199')
 
 --�˵�����״̬
 select SalesOrderState,* from Topway..AccountStatement 
 --update Topway..AccountStatement  set SalesOrderState=0
 where BillNumber='018294_20190116'
 
 --��Ʊҵ�������Ϣ
 select sales,SpareTC,* from Topway..tbcash 
 --update Topway..tbcash set sales='������',SpareTC='������'
 where coupno  in ('AS001547835','AS001504424')
 
 --����۲��
 select totsprice,profit,* from Topway..tbcash  where coupno='AS002321892'
 
 select * from homsomDB..Trv_Memos
 
 select COUNT(1) from Topway..tbcash  where cmpcode='020459'
 and datetime>='2018-07-01'
 and datetime<'2019-01-01'