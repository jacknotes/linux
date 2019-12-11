IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid as 单位编号,t1.cmpname as 单位名称
,(case CustomerType when 'A' then '差旅单位客户' when 'C' then '旅游单位客户' else '' end) as 单位类型
,(CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END) as 合作状态
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as 开发人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as 售后主管
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as 维护人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as 差旅业务顾问
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as 旅游业务顾问
,indate
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
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate
order by t1.cmpid





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

IF OBJECT_ID('tempdb.dbo.#p2') IS NOT NULL DROP TABLE #p2
select cmp1.*,wjr.MaintainName as 挖掘人,yyjl.MaintainName as 运营经理 
into #p2
from #cmp1 cmp1
left join #wjr wjr on wjr.cmpid=cmp1.单位编号
left join #yyjl yyjl on yyjl.cmpid=cmp1.单位编号

IF OBJECT_ID('tempdb.dbo.#p3') IS NOT NULL DROP TABLE #p3
select * 
into #p3
from #p2 where (单位编号 in
(select Cmpid from tbTravelBudget where OperDate>='2017-10-01' and OperDate<'2018-10-23' and Status<>2 and TrvType not like ('%5%')))
or (单位编号 in
(select Cmpid from tbConventionBudget where OperDate>='2017-10-01' and OperDate<'2018-10-23' and Status<>2  ))

--有消费的汇总
select 单位编号 from #p3

--无消费的单位ID
select ID from homsomDB..Trv_UnitCompanies where Cmpid not in (select 单位编号 from #p3)


--TMS删除旅游顾问
select *
--delete 
from homsomDB..Trv_TrvUnitCompanies_TrvTCs where TrvUnitCompanyID in (select ID from homsomDB..Trv_UnitCompanies where Cmpid not in (select 单位编号 from #p3))

--ERP删除旅游顾问
select * 
--update Topway..HM_AgreementCompanyTC set isDisplay=0
from Topway..HM_AgreementCompanyTC where TcType=1 and Cmpid not in (select 单位编号 from #p3)


--更改挖掘人
--有消费的改为HOMSOM
select * 
--update HM_ThePreservationOfHumanInformation set maintainname='HOMSOM',MaintainNumber='0421'
from HM_ThePreservationOfHumanInformation 
where MaintainType=6 and IsDisplay=1
and CmpId in (select 单位编号 from #p3)


select 单位编号 from #p3 where 单位编号 not in (select CmpId from HM_ThePreservationOfHumanInformation where MaintainType=6 and IsDisplay=1)
and 单位编号<>''

INSERT INTO [Topway].[dbo].[HM_ThePreservationOfHumanInformation]
(Pkey,CmpId,MaintainName,MaintainNumber,MaintainType,CmpOrCust,IsDisplay,ModifyBy,ModifyDate,CreateBy,CreateDate)
--="UNION ALL SELECT newid() as peky,'" &B2&"' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate"
SELECT newid() as peky,'000126' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'016266' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'016289' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'016973' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'017131' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'017186' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'017485' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'017583' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'017602' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'017706' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'017764' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'017907' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'018013' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'018125' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'018193' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'018231' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'018266' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'018343' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'018627' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'018801' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'018808' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'018931' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'019109' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'019166' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'019188' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'019226' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'019260' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'019299' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'019371' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'019523' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'019524' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'019568' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'019629' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'019732' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'019807' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'019895' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020033' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020087' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020091' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020142' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020149' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020155' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020161' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020163' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020183' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020215' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020240' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020255' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020265' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020277' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020281' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020299' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020300' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020311' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020313' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020318' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020321' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020322' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020323' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020325' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020328' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020331' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020332' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020336' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020339' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020341' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020343' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020344' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020347' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020352' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020357' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020358' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020373' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020374' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020375' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020381' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020386' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020389' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020390' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020391' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020392' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020393' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020398' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020399' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020400' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020409' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020411' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020412' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020415' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020417' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020420' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020424' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020425' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020435' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020437' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020440' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020443' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020449' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020452' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020454' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020456' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020458' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020465' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020466' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020471' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020473' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020474' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020479' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020480' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020484' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020485' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020487' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020489' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020492' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020493' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020494' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020499' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020501' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020503' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020509' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020512' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020515' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020516' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020520' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020526' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020527' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020530' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020537' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020539' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020540' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020549' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020554' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020557' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020562' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020563' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020573' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020574' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020576' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020577' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020581' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020584' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020587' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020590' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020595' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020596' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020599' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020600' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020601' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020604' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020605' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020606' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020607' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020612' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020613' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020615' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020616' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate
UNION ALL SELECT newid() as peky,'020618' AS cmpid,'HOMSOM' AS MaintainName,'0421' AS MaintainNumber,'6' AS MaintainType,'1' AS CmpOrCust,'1' AS IsDisplay,'' AS ModifyBy,'1900-1-1' AS ModifyDate,'TMS EMPPWD Sync' AS CreateBy,GETDATE() AS CreateDate



--无消费的改为空
select * 
--update HM_ThePreservationOfHumanInformation set isdisplay=0
from HM_ThePreservationOfHumanInformation 
where MaintainType=6 and IsDisplay=1
and CmpId not in (select 单位编号 from #p3)