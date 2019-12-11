--2019-01-21添加的常飞旅客
 SELECT 
ISNULL(c.Cmpid,'') AS 单位编号,
ISNULL(c.Name,'') AS 单位名称,
ISNULL(h.Name,'') AS 中文名,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS 英文名,
h.Mobile AS 手机号码,
ISNULL((SELECT TOP 1 empname FROM Topway..Emppwd WHERE idnumber=h.CreateBy),'') AS 差旅顾问,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS 运营经理
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate>='2019-02-01' AND h.CreateDate<'2019-02-02' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT idnumber FROM Topway..Emppwd WHERE dep='运营部' AND idnumber NOT IN('00002','00003','0421'))
UNION ALL

SELECT 
ISNULL(c.Cmpid,'') AS 单位编号,
ISNULL(c.Name,'') AS 单位名称,
ISNULL(h.Name,'') AS 中文名,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS 英文名,
ISNULL(h.Mobile,'') AS 手机号码,
h.CreateBy AS 差旅顾问,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS 运营经理
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate>='2019-02-01' AND h.CreateDate<'2019-02-02' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT empname FROM Topway..Emppwd WHERE dep='运营部' AND empname NOT IN('homsom','恒顺旅行','运营培训测试'))

--机票账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where BillNumber='020165_20181201'

--酒店调整单
select totprofit,sprice,*  from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set totprofit='-296'
where CoupNo='-PTW075839'
select totprofit,sprice,*  from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set totprofit='-903'
where CoupNo='-PTW075840'

--酒店调整单
select totprofit,sprice,*  from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set sprice='2913.00'
where CoupNo='PTW075839'
select totprofit,sprice,*  from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set sprice='9154.00'
where CoupNo='PTW075840'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where BillNumber='020165_20181201'

select sales,SpareTC,* from Topway..tbcash  where coupno='as0016466'
select * from homsomDB..Trv_UnitCompanies where Cmpid='016466'
select top 10 * from homsomDB..Trv_TrvUnitCompanies_TrvTCs where TrvUnitCompanyID='BB6A117C-8F55-4992-AAD8-F279E6762775'

--修改供应商来源
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETI'
where coupno='AS002232971'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETI'
where coupno='AS002233048'

select SettlementTypeAir,SettlementTypeHotel,* from Topway..AccountStatement where BillNumber='016588_20181126'

--财务修改到账银行
select payway,* 
--update topway..FinanceERP_ClientBankRealIncomeDetail set payway=' 融易（中行）'
from topway..FinanceERP_ClientBankRealIncomeDetail where money='11666' and date='2019-02-02'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where BillNumber='020592_20190101'