--ɾ���Ƶ����۵�

select Jstatus,* from Topway..tbTrvJS 
--update Topway..tbTrvJS set Jstatus='4'
where TrvId='029206' and JsPrice='23888'
delete from Topway..tbHtlcoupYf where CoupNo='PTW075468'

--�޸���Ӫ����
select MaintainName,MaintainNumber,* from Topway..HM_ThePreservationOfHumanInformation 
--update Topway..HM_ThePreservationOfHumanInformation  set MaintainName='������',MaintainNumber='0665'
where CmpId in ('019437','019773','018387','019841','020279') and IsDisplay=1 and MaintainType=9

--�ĵ���ʱ��
select * 
--update topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-1-23'
from topway..FinanceERP_ClientBankRealIncomeDetail where money='196295.00' and date='2019-1-22'

--���ν��㵥��Ϣ��Ӧ�����Ƹ���
select GysSource,* from topway..tbTrvJS 
--update topway..tbTrvJS  set GysSource='�����Ƽ�����ʿ�����ʣ�'
where TrvId='29000' and Id='143029'

--UC019788��UC019786�ϼ�����
--��Ʊ
select SUM(totprice) as �ϼ����� from topway..tbcash 
where cmpcode in ('019788','019786') and datetime>='2018-01-01' and datetime<'2019-01-01'
and reti=''

--�Ƶ�
select SUM(price) as �ϼ����� from topway..tbHtlcoupYf 
where prdate>='2018-01-01' and prdate<'2019-01-01' and cmpid in('019788','019786')

--�Ƶ����۵��ؿ���ӡȨ��
select pstatus,prdate,* from topway..tbHtlcoupYf 
--update topway..tbHtlcoupYf set pstatus='0',prdate='1900-01-01'
where CoupNo='PTW075453'

--�޸Ĵ�����
select disct,* from topway..tbcash  
--update topway..tbcash set disct='2200'
where coupno='AS002226288'

--��Ʊ���
select TrainServiceCharge,TrainSpecialInvoiceUsedAmount,TrainOrdinaryInvoiceUsedAmount,* from topway..AccountStatement 
--update topway..AccountStatement set TrainServiceCharge='0',TrainOrdinaryInvoiceUsedAmount='30'
where BillNumber='020507_20190101'

--����Ʒ��ר�ã���Ʊ��Ӧ����Դ
select t_source,* from topway..tbcash 
--update topway..tbcash set t_source='HSBSPETI'
where coupno='AS002218771'

--����������ѯ
select * from ehomsom..tbPlanetype  where aname='32H'
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('124','�տ�','A320ϵ��','A320','32H','150-180','խ��')

--��˾�����޸�
--����
select DeptCode,DeptName,* from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptCode='�����з�����'
where DeptCode='�����з�����'
select DeptName,* from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptName='�����з�����'
where ID='8'
select * from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptName='�����з����� ϵͳ��ά��'
where ID='9'
select * from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptName='�����з����� ���������'
where ID='10'
select * from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptName='�����з����� ���ά����'
where ID='11'

--��Ա��
select Department,* from ApproveBase..HR_Employee 
--update ApproveBase..HR_Employee set DeptCode='�����з�����',Department='�����з�����'
where DeptCode='������'

--��ٱ�

select * from ApproveBase..HR_AskForLeave_Signer 
---update ApproveBase..HR_AskForLeave_Signer set DeptCode='�����з�����'
where DeptCode='������'

--�к󷵽���
select sum(bpprice) as �ܺ󷵽��,COUNT(*) as ��Ʊ���� from topway..tbcash 
where bpprice>'0' and datetime >='2018-01-01' and datetime<'2019-01-01' and fuprice>bpprice and reti<>''
