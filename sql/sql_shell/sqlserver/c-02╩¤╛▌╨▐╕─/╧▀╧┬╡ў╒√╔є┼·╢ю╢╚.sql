select top(1)BillNumber as 账单号,CompanyCode as UC号,SX_BaseCreditLine as 原始额度,SX_TomporaryCreditLine as 临时额度,SX_TotalCreditLine as 总额度,SX_IsAuthorized as 额度审批次数,* from topway..AccountStatement
where CompanyCode='UC号'
order by BillNumber desc

--修改总额度及额度审批次数
update topway..AccountStatement set SX_TotalCreditLine ='修改后总额度' ,SX_IsAuthorized='修改后审批次数' where BillNumber='账单号'


SELECT     id as ID号,Status as 审批状态,CmpID as UC号,*
FROM         topway..HM_CompanyCreditApply
WHERE     CmpID = 'UC号'
order by ApplyDate desc

--审批状态（2，审批通过  0，审批未通过）
update topway..HM_CompanyCreditApply set Status=2 where CmpID = 'UC号' and id='ID号'