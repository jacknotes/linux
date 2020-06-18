--ɾ��Ա���ű�
select * from homsomDB..Trv_Human 
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (
select a.ID from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID in (select ID from homsomDB..Trv_UnitCompanies where Cmpid='020730')
and IsDisplay=1 and Name not in ('ףǿ','��һ��','Ҧ����','����'))

--TMS���ÿ͵���ERP
insert into tbcusholderM(cmpid,custid,ccustid,custname,custtype1,male,username,phone,mobilephone,personemail,CardId,custtype,homeadd,joindate) 
select cmpid,CustID,CustID,h.Name,
CASE
WHEN u.Type='��ͨԱ��' THEN ''
WHEN u.Type='������' THEN '3'
WHEN u.Type='������' THEN '4'
WHEN u.Type='�߹�' THEN '5'
ELSE 2 end,
CASE 
WHEN h.Gender=1 THEN '��'
WHEN h.Gender=0 THEN 'Ů'
ELSE '��' end
,'',h.Telephone,h.Mobile,h.Email,'',u.CustomerType,'�ֹ���������' ,h.CreateDate
FROM homsomDB..Trv_UnitPersons u
INNER JOIN homsomDB..Trv_Human h ON u.id =h.ID
INNER JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID
WHERE Cmpid='018163' AND h.IsDisplay=1 and h.Name not in ('½����','���','��ع��','���ǿ','������','����','�ܽ�')

--ɾ������ERP��Ա
delete from Topway..tbCusholderM where cmpid='018163'  and custname not in('½����','���','��ع��','���ǿ','������','����','�ܽ�')  and id between 167283 and 167305

--����Ʒ��ר�ã���Ʊ��Ӧ����Դ�����ڣ�
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HS���̶���ŵD'
where coupno='AS002263135'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno='AS002262788'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETI'
where coupno='AS002263271'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno='AS002262734'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno='AS002263203'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETI'
where coupno='AS002262216'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETI'
where coupno='AS002259439'

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno='AS002256383'

--����Ԥ�㵥ҵ�����
select Sales,OperName,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget  set Sales='����Х',OperName='0678����Х'
where ConventionId='967'

--��Ʊ��ϸ
select  cmpcode as ��λ���,m.cmpname as ��λ����,datetime as ��Ʊ����,coupno as ���۵���,tickettype as ����,ride+flightno as �����, 
begdate as �������,tcode+ticketno as Ʊ��,pasname as �˻���,route as ����,totprice as ���ۼ�
from Topway..tbcash c
left join Topway..tbCompanyM m on m.cmpid=c.cmpcode
where cmpcode in ('019483',
'017210',
'019497',
'017602',
'019885',
'019822',
'018701',
'000126',
'016962',
'019540',
'019830',
'018309',
'019507')
and datetime>='2018-08-01'
and datetime<'2019-02-01'
order by cmpcode

--�޸�����
select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163'
select * from homsomDB..Trv_UnitPersons where companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')

select Email,p.Name,* from homsomDB..Trv_UnitPersons h
left join homsomDB..Trv_Human p on p.ID=h.ID
where h.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')and IsDisplay=1
--update 
update homsomDB..Trv_Human set Email='hanson.han@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='���н�')
update homsomDB..Trv_Human set Email='aki.ru@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='�㼪')
update homsomDB..Trv_Human set Email='jessica.gu@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='��ع��')
update homsomDB..Trv_Human set Email='demi.lu@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='½����')
update homsomDB..Trv_Human set Email='allan.zhou@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Mobile='�ܽ�')
update homsomDB..Trv_Human set Email='joe.yang@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='������')
update homsomDB..Trv_Human set Email='lawrence.gu@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='����')
update homsomDB..Trv_Human set Email='sylvia.xu@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='�촺ӱ')
update homsomDB..Trv_Human set Email='ali.ma@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='���ǿ')
update homsomDB..Trv_Human set Email='momo.ye@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='Ҷ����')
update homsomDB..Trv_Human set Email='alice.zhang@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='�ŵ�Ƽ')
update homsomDB..Trv_Human set Email='will.yang@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='����')
update homsomDB..Trv_Human set Email='jax.sun@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='�����')
update homsomDB..Trv_Human set Email='kevin.lin@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='�ֽ���')
update homsomDB..Trv_Human set Email='jimmy.hu@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='��ʤ��')
update homsomDB..Trv_Human set Email='rocky.huang@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='�Ƽ���')
update homsomDB..Trv_Human set Email='david.li@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='��ΰ')
update homsomDB..Trv_Human set Email='jessica.chen@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='������')
update homsomDB..Trv_Human set Email='mike.sung@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='�ΰط�')
update homsomDB..Trv_Human set Email='scarlett.lu@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='·��')
update homsomDB..Trv_Human set Email='leo.ning@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='��ҫ��')
update homsomDB..Trv_Human set Email='michael.shao@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='������')
update homsomDB..Trv_Human set Email='louis.wu@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='������')
update homsomDB..Trv_Human set Email='eunice.liu@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='����')
update homsomDB..Trv_Human set Email='eddie.zhen@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='������')
update homsomDB..Trv_Human set Email='nicky.he@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='���')
update homsomDB..Trv_Human set Email='christine.zhong@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='������')
update homsomDB..Trv_Human set Email='roald.bai@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='�����')
update homsomDB..Trv_Human set Email='alex.yang@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='������')
update homsomDB..Trv_Human set Email='jack.zhou@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1
and h.Name='������')

--��λ���͡����㷽ʽ���˵���ʼ���ڡ������¡�ע����
--�޸�ע���£����㷽ʽ
select indate,CustomerType,sform,* from Topway..tbCompanyM 
--update Topway..tbCompanyM  set indate='2019-02-27',sform='�½�(����)'
where cmpid='017661'
select RegisterMonth,Type,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set RegisterMonth='02  27 2019 12:00AM',Type='A'
where Cmpid='017661'

--����2������
select PstartDate,* from topway..HM_CompanyAccountInfo 
--update topway..HM_CompanyAccountInfo set PstartDate='2019-02-01'
where CmpId='017661' and Id='6848'

select PendDate,* from topway..HM_CompanyAccountInfo 
--update topway..HM_CompanyAccountInfo set PendDate='2019-01-31 23:59:59.000'
where CmpId='017661' and Id='5323'

--���㷽ʽ
--ERP
select SEndDate,Status,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SEndDate='2019-01-31',Status=-1
where CmpId='017661' and Id in('9970','9969')
select SStartDate,Status,* from Topway..HM_SetCompanySettleMentManner
--update  Topway..HM_SetCompanySettleMentManner set SStartDate='2019-02-01',Status=1
where CmpId='017661' and Id in('19111','19110')
--TMS

SELECT EndDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set EndDate='2019-01-31 23:59:59.000',Status=-1
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '017661') 
and ID in('97531C7A-4E3D-4904-A492-A4410103FB6C','A7235427-FE0A-48E1-A110-A4410103FB89')

SELECT StartDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes  set StartDate='2019-02-01',Status=1
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '017661')
and ID in ('B6CCB797-C1E6-4552-9CD9-AA0100C4A7A5','983444B3-45B3-436A-963B-AA0100C4A7CB')

--���
select SX_BaseCreditLine,SX_TomporaryCreditLine,SX_TotalCreditLine from Topway..AccountStatement 
--update Topway..AccountStatement set SX_BaseCreditLine=30000,SX_TomporaryCreditLine=30000,SX_TotalCreditLine=30000
where BillNumber='017661_20190201'

select * from homsomDB..Trv_CostCenter 
where CompanyID in (Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017205')
and ID='E6D404B8-3E51-4515-8367-A9A000ADB763'

select CostCenterID, * from homsomDB..Trv_UnitPersons 
--update homsomDB..Trv_UnitPersons  set CostCenterID=null
where CostCenterID='E6D404B8-3E51-4515-8367-A9A000ADB763'

--�޸���Ʊ���ʱ��
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti set ExamineDate='2019-02-18'
where reno='0427737'

--�޸�����
select Email from homsomDB..Trv_Human
--update homsomDB..Trv_Human set Email='hanson.han@bourns.com'
where ID in (select p.ID from homsomDB..Trv_UnitPersons p
left join homsomDB..Trv_Human h on p.ID=h.ID
where p.companyid in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='017739')
and IsDisplay=1
and p.CustID ='D348913')

--�޸ĵ�¼�˺�
select UserName from homsomDB..Trv_UnitPersons 
--update homsomDB..Trv_UnitPersons set UserName=''
where CustID='D348913'
and CompanyID in(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017739')

--�޸�Ԥ�����ۼ�
select YujPrice,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set YujPrice=38465
where TrvId='029622'

