--OAǩ����
select Signer,* from ApproveBase..HR_AskForLeave_Signer 
--update ApproveBase..HR_AskForLeave_Signer set Signer='0019'
where DeptCode='���۲�'

--�޸Ĳ���
select DeptCode,DeptName,* from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptCode='�ۺ����',DeptName='�ۺ����'
where DeptName='�ͻ���ϵ��'

select DeptCode,Department,* from ApproveBase..HR_Employee 
--update ApproveBase..HR_Employee set DeptCode='�ۺ����',Department='�ۺ����'
where Department='�ͻ���ϵ��'

select * from ApproveBase..HR_AskForLeave_Signer 
--update ApproveBase..HR_AskForLeave_Signer set DeptCode='�ۺ����'
where DeptCode='�ͻ���ϵ��'

select top 10 depdate0, * from Topway..tbCompanyM 

--��������
SELECT Name,* FROM homsomDB..Trv_Airport 
--update homsomDB..Trv_Airport set Name='Ŧ�߿����ɹ��ʻ���'
WHERE Code='EWR'

--��Ӧ����Դ
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002222163'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETI'
where coupno='AS002229117'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002228006'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002232320'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002232306'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002228347'

--����Ԥ�㵥��ϢԤ������Ϣ
select * from Topway..tbCusholderM where mobilephone='13611656658'
select Custid,Custinfo as Ԥ����Ϣ,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Custid='D634482'
where TrvId='29215'

--�����տ��Ϣ,Ԥ�㵥��1065���ڷ�Ʊ���Ͳ��ԣ�����ɾ�������տ���Ϣ
select *from Topway..tbConventionKhSk where ConventionId='1065' and Id in('2277','2276')
--delete from Topway..tbConventionKhSk where ConventionId='1065' and Id in('2277','2276')