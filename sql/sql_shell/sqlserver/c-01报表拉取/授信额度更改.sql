--��ѯ
--�˵���
SELECT     CompanyCode as ��λ���,CompanyNameCN as ��λ����,BillNumber as �˵���,SX_BaseCreditLine as ���Ŷ��,SX_AppendCreditLine as ���Ӷ��
,SX_TomporaryCreditLine as ��ʱ���, SX_TotalCreditLine as �ܶ��
,SX_IsAuthorized as ���Ӵ���,CreditLineAgreenNumber as ͨ������, SX_ConsumptionAmount as �����ѽ��
FROM         AccountStatement
WHERE     AccountPeriodAir1>='2018-01-01' and  AccountPeriodAir1<'2018-12-27'
ORDER BY CompanyNameCN DESC       --���˵��ŵ�����һ��Ĭ�ϵ�һ��

--������˱�
select Status as �Ƿ�ͨ��      --(0δ���ͨ����2���ͨ��)
,ApplyDate as ����ʱ��,id as id 
from HM_CompanyCreditApply
where CmpID = '��λ���' 
order by ApplyDate desc        --������ʱ�䵹����һ��Ĭ�ϵ�һ��

--����
--�˵���
update AccountStatement set 
SX_TotalCreditLine =           --�ܶ��+���Ŷ��
,SX_IsAuthorized =             --���Ӵ���+1
,CreditLineAgreenNumber =      --ͨ������+1
where (CompanyCode = '��λ���') and BillNumber = '�˵���'  --һ��Ҫѡ��������

--������˱�
update HM_CompanyCreditApply set
Status = 2                     --(0δ���ͨ����2���ͨ��)
where CmpID = '��λ���' 
and id = '��ѯʱ����ӦID'      --һ��Ҫѡ��������