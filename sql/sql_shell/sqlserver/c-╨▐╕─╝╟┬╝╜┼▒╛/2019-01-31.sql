--����Ԥ�㵥��Ϣ���ҵ�����
select Sales,OperName,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Sales='��һ��'
where ConventionId in ('958','975','980')

--�����������
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='13263',profit='4687'
where coupno='AS002234907'

--ɾ��δ���쵽��
select state,* 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='60899' and date='2019-01-30' and state='0'

--�ؿ���ӡȨ��
select Pstatus,Prdate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus='0',Prdate='1900-01-01'
where TrvId='029491'

--��Ʊҵ�������Ϣ
select SpareTC,* from Topway..tbcash 
--update Topway..tbcash set SpareTC='�ν�'
where coupno='AS002231199'

--��˾��Ϣ
SELECT top 10 * FROM ehomsom..tbInfAirCompany where code2='pc'
insert into ehomsom..tbInfAirCompany (airname,sx1,sx,code2,http,ntype,modifyDate,enairname,IsDeleted,sortNo,phone1,phone2,introinf)
values ('�����������','������','������','PC','','1','2019-01-31','Pegasus Airlines',NULL,'1',NULL,NULL,NULL)

--��λԱ��
select  Cmpid,(case when t1.Name<>'' then t1.Name when t1.Name='' then t1.FirstName+'/'+t1.MiddleName+t1.LastName else '' end) as ����,c.CredentialNo from homsomDB..Trv_UnitPersons t
left join homsomDB..Trv_UnitCompanies u on u.ID=t.CompanyID
left join homsomDB..Trv_Human t1 on t1.companyid=u.ID and t1.ID=t.ID
left join homsomDB..Trv_Credentials c on c.HumanID=t1.ID 
where u.Cmpid='019331' and t1.IsDisplay='1'
order by ����