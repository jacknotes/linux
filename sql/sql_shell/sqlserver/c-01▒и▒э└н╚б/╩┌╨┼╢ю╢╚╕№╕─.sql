--查询
--账单表
SELECT     CompanyCode as 单位编号,CompanyNameCN as 单位名称,BillNumber as 账单号,SX_BaseCreditLine as 授信额度,SX_AppendCreditLine as 附加额度
,SX_TomporaryCreditLine as 临时额度, SX_TotalCreditLine as 总额度
,SX_IsAuthorized as 增加次数,CreditLineAgreenNumber as 通过次数, SX_ConsumptionAmount as 已消费金额
FROM         AccountStatement
WHERE     AccountPeriodAir1>='2018-01-01' and  AccountPeriodAir1<'2018-12-27'
ORDER BY CompanyNameCN DESC       --按账单号倒排序，一般默认第一条

--短信审核表
select Status as 是否通过      --(0未审核通过，2审核通过)
,ApplyDate as 发送时间,id as id 
from HM_CompanyCreditApply
where CmpID = '单位编号' 
order by ApplyDate desc        --按发送时间倒排序，一般默认第一条

--更改
--账单表
update AccountStatement set 
SX_TotalCreditLine =           --总额度+授信额度
,SX_IsAuthorized =             --增加次数+1
,CreditLineAgreenNumber =      --通过次数+1
where (CompanyCode = '单位编号') and BillNumber = '账单号'  --一定要选中条件啊

--短信审核表
update HM_CompanyCreditApply set
Status = 2                     --(0未审核通过，2审核通过)
where CmpID = '单位编号' 
and id = '查询时所对应ID'      --一定要选中条件啊