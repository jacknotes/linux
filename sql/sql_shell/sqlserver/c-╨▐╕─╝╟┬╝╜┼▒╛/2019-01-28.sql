--账单撤销

SELECT SubmitState,* FROM topway..AccountStatement 
--update topway..AccountStatement set SubmitState='1'
WHERE CompanyCode = '019737' and BillNumber='019737_20181201'

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='广州粤大金融城国际酒店'
where CoupNo='PTW075623'

--OA部门调整
select DeptCode,DeptName,* from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptCode='销售部',DeptName='销售部'
where DeptCode='市场销售部'

--insert into ApproveBase..App_BaseDept values ('31','市场部','市场部')

--人员表
select Department,* from ApproveBase..HR_Employee 
--update ApproveBase..HR_Employee set DeptCode='销售部',Department='销售部'
where DeptCode='市场销售部'

--请假表

select * from ApproveBase..HR_AskForLeave_Signer 
---update ApproveBase..HR_AskForLeave_Signer set DeptCode='销售部'
where DeptCode='市场销售部'

--insert into ApproveBase..HR_AskForLeave_Signer values ('市场部','0102')

--删除到账认领
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='37585' and state='0'

--改到账时间
select date,* 
--update topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-01-24'
from topway..FinanceERP_ClientBankRealIncomeDetail where money='8990' and date='2019-01-25' and id='582A51B2-DF08-40CF-BAEE-5F437961359C'

--删除到账认领
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='21440' and date='2019-01-28'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='660' and date='2019-01-28'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='500' and date='2019-01-28' 
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='5856' and date='2019-01-28'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='4600' and date='2019-01-28'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='500' and date='2019-01-28' and id='7B9A3EAA-9B2C-4C81-96BC-8425CF3D111D'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='84614' and date='2019-01-28'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='42823' and date='2019-01-28' and id='8EF28C51-1B1F-4A36-8E36-F8ED8D911EFB'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='2000' and date='2019-01-28' and id='B5BEE19E-FC56-4CD1-9F9C-B15CF0FA7299'
select * 
--delete
from topway..FinanceERP_ClientBankRealIncomeDetail where money='17470' and date='2019-01-28'

--2016年的出票数据

select coupno as 销售单号,datetime as 出票日期,totprice as 销售价,reti as 退票单号,tcode+ticketno as 票号,route  as 行程,ride+flightno as 航班号 from Topway..tbcash 
where custid='D181624' and datetime>='2016-01-01' and datetime<'2017-01-01'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set SpareTC='倪颖'
where coupno='AS001710067'

--单位类型
select indate,InDateA,* from Topway..tbcompanym 
--update Topway..tbcompanym set InDateA='2018-12-07 11:31:37.000'
where cmpid='020665'
select RegisterMonth,AdditionMonthA,* from homsomDB..Trv_UnitCompanies where Cmpid='020665'

--2019-01-25添加的常飞旅客
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
WHERE h.CreateDate>='2019-01-25' AND h.CreateDate<'2019-01-26' AND h.IsDisplay=1
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
WHERE h.CreateDate>='2019-01-25' AND h.CreateDate<'2019-01-26' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT empname FROM Topway..Emppwd WHERE dep='运营部' AND empname NOT IN('homsom','恒顺旅行','运营培训测试'))

--额度
select * from Topway..AccountStatement where CompanyCode='020643'--BillNumber='020643_20190101'

/*结算单信息
1/28 重庆优合应付结算单号：108412，原状态已结算，因差旅顾问销售输入有问题，故作废结算单号，等差旅顾问重新输入后再重新提取。
*/
select * from topway..tbSettlementApp 
--update topway..tbSettlementApp set settleStatus='3'
where id='108412'
select * from topway..tbcash 
--update topway..tbcash set wstatus='0',settleno='0'
where settleno='108412'
select * from topway..tbReti 
--update topway..tbReti set inf2='0',settleno='0'
where settleno='108412'
select * from topway..Tab_WF_Instance 
--update topway..Tab_WF_Instance set Status='4'
where BusinessID='108412'
select * from topway..Tab_WF_Instance_Node 
where InstanceID in (select id from topway..Tab_WF_Instance where BusinessID='108412')
--delete from  topway..Tab_WF_Instance_Node where InstanceID in (select id from topway..Tab_WF_Instance where BusinessID='108412') and Status='0'

--酒店销售单重开打印权限
select pstatus,prdate,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set pstatus='0',prdate='1900-01-01'
where CoupNo='PTW075722'

--修改手机号码
select  Mobile,* from homsomDB..Trv_Human 
--update homsomDB..Trv_Human set Mobile='17321074979'
where ID='EB19BF9D-0D36-49D4-8E79-1D9DF1D47F98'

select Status,* from Topway..HM_CompanyAccountInfo 
--update Topway..HM_CompanyAccountInfo set Status='1'
where CmpId='020643' and Id='6820'

select Status,* from Topway..HM_CompanyAccountInfo 
--update Topway..HM_CompanyAccountInfo set Status='-1'
where CmpId='020643' and Id='6758'

--（产品专用）申请费来源/金额信息（国际）
select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash  set feiyong='154',feiyonginfo='申请座位ZYI'
where coupno='AS002222955'