select top(1)BillNumber as �˵���,CompanyCode as UC��,SX_BaseCreditLine as ԭʼ���,SX_TomporaryCreditLine as ��ʱ���,SX_TotalCreditLine as �ܶ��,SX_IsAuthorized as �����������,* from topway..AccountStatement
where CompanyCode='UC��'
order by BillNumber desc

--�޸��ܶ�ȼ������������
update topway..AccountStatement set SX_TotalCreditLine ='�޸ĺ��ܶ��' ,SX_IsAuthorized='�޸ĺ���������' where BillNumber='�˵���'


SELECT     id as ID��,Status as ����״̬,CmpID as UC��,*
FROM         topway..HM_CompanyCreditApply
WHERE     CmpID = 'UC��'
order by ApplyDate desc

--����״̬��2������ͨ��  0������δͨ����
update topway..HM_CompanyCreditApply set Status=2 where CmpID = 'UC��' and id='ID��'