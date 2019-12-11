--酒店销售单调整 结算总价请调整为20
select sprice,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set sprice=20
where CoupNo='PTW078737'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash where coupno='AS002339560'

--人工出票原因（含“直加”二字）
select datetime as 出票日期,begdate as 起飞时间,coupno as 销售单号,tcode+ticketno as 票号,t2.route as 航程,nclass as 舱位,ride+flightno as 航班号,cmpcode as 单位编号,quota1 as 定额费,totprice as 销售价,t2.profit-Mcost as 销售利润,t2.sales as 所属业务顾问,t2.SpareTC as 操作业务顾问,t2.reti as 退票单号 
from homsomDB..Trv_DomesticTicketRecord t1
left join topway..tbcash t2 on t2.coupno=t1.RecordNumber
where TicketOperationRemark like ('%直加%') and t2.t_source='HSBSPETD'
and nclass='B'
and ride='EU'

--所有差旅单位客户的国内报销凭证
IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as 单位编号,t1.cmpname as 单位名称
,(case CustomerType when 'A' then '差旅单位客户' when 'C' then '旅游单位客户' else '' end) as 单位类型
,(CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END) as 合作状态
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as 开发人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as 售后主管
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as 维护人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as 差旅业务顾问
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as 旅游业务顾问
,case t4.CertificateI when 0 then '无' when 1 then '行程单' when 2 then '发票' else '' end as 国际报销凭证,case t4.CertificateD when 0 then '无' when 1 then '行程单' when 2 then '发票' else '' end as 国内报销凭证
into #cmp1
from tbCompanyM t1
left join homsomdb..Trv_UnitCompanies t4 on t1.cmpid=t4.Cmpid
--开发人
left join homsomDB..Trv_UnitCompies_Sales t5 on t4.ID=t5.UnitCompayID
--客户主管
left join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t4.ID=t6.UnitCompanyID
--维护人
left join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.UnitCompanyID=t4.ID
--旅游业务顾问
left join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t7.TrvUnitCompanyID=t4.ID
--差旅业务顾问
left join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t8.TktUnitCompanyID=t4.ID
--人员信息
left join homsomDB..SSO_Users t9 on
t9.ID=t5.EmployeeID and t9.ID=t6.EmployeeID and t9.ID=t8.TktTCID and t9.ID=t7.TrvTCID 
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate,t4.CertificateI,t4.CertificateD
order by t1.cmpid


select * from #cmp1

--挖掘人
IF OBJECT_ID('tempdb.dbo.#wjr') IS NOT NULL DROP TABLE #wjr
select CmpId,MaintainName 
into #wjr
from  HM_ThePreservationOfHumanInformation tp where MaintainType=6 and IsDisplay=1
--运营经理
IF OBJECT_ID('tempdb.dbo.#yyjl') IS NOT NULL DROP TABLE #yyjl
select CmpId,MaintainName 
into #yyjl
from  HM_ThePreservationOfHumanInformation tp where MaintainType=9 and IsDisplay=1

select cmp1.*,wjr.MaintainName as 挖掘人,yyjl.MaintainName as 运营经理 from #cmp1 cmp1
left join #wjr wjr on wjr.cmpid=cmp1.单位编号
left join #yyjl yyjl on yyjl.cmpid=cmp1.单位编号
where 单位类型='差旅单位客户'
and cmp1.单位编号<>'000003'
and cmp1.单位编号<>'000006'


--单位客户授信额度调整
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement set SX_TotalCreditLine=240000
where BillNumber='017940_20190301'

--会务预算单信息
select Sales,OperName,introducer,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Sales='崔之阳',OperName='0481崔之阳',introducer='崔之阳-0481-运营部'
where ConventionId in ('1323',
'1308',
'1345',
'1340',
'1307',
'1358',
'1316',
'1309',
'1305',
'1306',
'1344',
'1331',
'1372',
'1232',
'1366',
'1313',
'1315',
'1314',
'1351',
'1079',
'1332',
'1138',
'938',
'1096',
'1260',
'1246',
'1330',
'1061',
'1239',
'1334',
'1247',
'1120',
'1122',
'1063',
'1216',
'1141',
'1093',
'1073',
'1270')

--会务预算单
select Sales,OperName,introducer,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Sales='崔之阳',OperName='0481崔之阳',introducer='崔之阳-0481-运营部'
where ConventionId='1242'

select co.Name,c.DepName,* from homsomDB..Trv_UnitPersons u
left join homsomDB..Trv_Human h  on u.id=h.ID
left join homsomDB..Trv_CompanyStructure c on u.CompanyDptId=c.ID
left join homsomDB..Trv_CostCenter co on u.CostCenterID=co.ID
where u.CompanyID=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='019234')
and co.Name='上海葡缇文化传播有限公司'

select * from homsomDB..Trv_UnitCompanies where Cmpid='019234'

--修改成本中心和部门
update homsomDB..Trv_UnitPersons set CostCenterID=(select top 1 a.ID from homsomDB..Trv_CostCenter  a left join homsomDB..Trv_UnitPersons b on a.ID=b.CostCenterID where b.CompanyID='C83C1A4F-59CD-49A2-BE9A-A4B20114A73A' and a.Name='上海葡缇文化传播有限公司') where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='叶永健' and up.companyid='C83C1A4F-59CD-49A2-BE9A-A4B20114A73A')