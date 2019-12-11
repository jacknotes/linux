

--供应商来源
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno='AS002361854'
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS易商欧士机D'
where coupno='AS002362717'

INSERT INTO homsomDB..Trv_Airport
        ( ID ,
          Ver ,
          ModifyBy ,
          ModifyDate ,
          CreateBy ,
          CreateDate ,
          Code ,
          Name ,
          EnglishName ,
          CityID ,
          AbbreviationName
        )
VALUES  ( NEWID() , -- ID - uniqueidentifier
          GETDATE() , -- Ver - datetime
          'SYS' , -- ModifyBy - nvarchar(255)
          GETDATE() , -- ModifyDate - datetime
          'SYS' , -- CreateBy - nvarchar(255)
          GETDATE() , -- CreateDate - datetime
          'BZX' , -- Code - nvarchar(255)
          '恩阳机场' , -- Name - nvarchar(255)
          'BAZHONG ENYANG AIRPORT' , -- EnglishName - nvarchar(255)
          '0570CD1A-6899-4652-ADCC-886FFADDFFEE' , -- CityID - uniqueidentifier
          '恩阳机场'  -- AbbreviationName - nvarchar(255)
        )
        
        select * from ehomsom..tbInfItktCitycode where jccode='BZX'
        select * from ehomsom..tbInfAirPortName where jccode='BZX'
   
  --城市     
  INSERT INTO   ehomsom..tbInfItktCitycode
  (id,jccode,city,ename,sx,line,ntype)
  VALUES(NEWID(),'BZX','巴中','Bazhong','BZ','-','1')
     
    --机场    
 insert into ehomsom..tbInfAirPortName 
 ( id, jccode, province, city, sx, airname, airnamesx, ename, country, ntype, airportname)
 values(NEWID(),'BZX','四川省','巴中','巴中','恩阳机场','恩阳机场','Bazhong Enyang Airport','中国','5',null)
 
 --账单撤销
 select SubmitState,* from Topway..AccountStatement 
 --update Topway..AccountStatement  set SubmitState=1
 where BillNumber='020432_20190401'
 
 select * from homsomDB..Trv_Dictionaries where DictionaryType='4' 
 select UnitCompanyID,* from homsomDB..Trv_FlightNormalPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034' 
 select UnitCompanyID,* from homsomDB..Trv_FlightTripartitePolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 select UnitCompanyID,* from homsomDB..Trv_FlightAdvancedPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'


--国内机票正常线路
 
select Cmpid,
(case RebateStyle when 1 then '个人后返' when 0 then '单位后返' else '' end ) 返佣类型,
[percent]/100 后返比列
from  homsomDB..Trv_FlightNormalPolicies f
left join homsomDB..Trv_UnitCompanies un on un.ID=f.UnitCompanyID
left join homsomDB..Trv_RebateRelations re on re.FlightNormalPolicyID=f.ID
where --f.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034' --单位+个人后返
--f.CommissionTypeID in('3FD965EA-EE4B-46EB-9C9A-A17000A88032','3FD965EA-EE4B-46EB-9C9B-A17000A88036') --个人后返
f.CommissionTypeID in('C2D6F448-BDDD-42FE-91C9-A90415A361CF','3FD965EA-EE4B-46EB-9C9A-A17000A88033') --单位后返
and CooperativeStatus in ('1','2','3')
and Type='A'
 
 select top 10* from homsomDB..Trv_RebateRelations where FlightNormalPolicyID in()
 
 --特殊线路
 
 
 select Cmpid,(case RebateStyle when 1 then '个人后返' when 0 then '单位后返' else '' end ) 返佣类型,[percent]/100 后返比列
from  homsomDB..Trv_FlightAdvancedPolicies f
left join homsomDB..Trv_UnitCompanies un on un.ID=f.UnitCompanyID
left join homsomDB..Trv_RebateRelations re on re.FlightNormalPolicyID=f.ID
where --f.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034' --单位+个人后返
--f.CommissionTypeID in('3FD965EA-EE4B-46EB-9C9A-A17000A88032','3FD965EA-EE4B-46EB-9C9B-A17000A88036') --个人后返
f.CommissionTypeID in('C2D6F448-BDDD-42FE-91C9-A90415A361CF','3FD965EA-EE4B-46EB-9C9A-A17000A88033') --单位后返
and CooperativeStatus in ('1','2','3')
and Type='A'

select Cmpid,(case RebateStyle when 1 then '个人后返' when 0 then '单位后返' else '' end ) 返佣类型,[percent]/100 后返比列
from  homsomDB..Trv_FlightTripartitePolicies f
left join homsomDB..Trv_UnitCompanies un on un.ID=f.UnitCompanyID
left join homsomDB..Trv_RebateRelations re on re.FlightNormalPolicyID=f.ID
where--f.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034' --单位+个人后返
--f.CommissionTypeID in('3FD965EA-EE4B-46EB-9C9A-A17000A88032','3FD965EA-EE4B-46EB-9C9B-A17000A88036') --个人后返
f.CommissionTypeID in('C2D6F448-BDDD-42FE-91C9-A90415A361CF','3FD965EA-EE4B-46EB-9C9A-A17000A88033') --单位后返
and Type='A'
and RebateType=1
 

--国际
 select * from homsomDB..Trv_IntlFlightNormalPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'

  select Cmpid,(case RebateStyle when 1 then '个人后返' when 0 then '单位后返' else '' end ) 返佣类型,[percent]/100 后返比列
from  homsomDB..Trv_IntlFlightNormalPolicies f
left join homsomDB..Trv_UnitCompanies un on un.ID=f.UnitCompanyID
left join homsomDB..Trv_IntlRebateRelations re on re.FlightNormalPolicyID=f.ID
where --f.CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034' --单位+个人后返
--f.CommissionTypeID in('3FD965EA-EE4B-46EB-9C9A-A17000A88032','3FD965EA-EE4B-46EB-9C9B-A17000A88036') --个人后返
f.CommissionTypeID in('C2D6F448-BDDD-42FE-91C9-A90415A361CF','3FD965EA-EE4B-46EB-9C9A-A17000A88033') --单位后返
and CooperativeStatus in ('1','2','3')
and Type='A'
and Cmpid not in ('000003','000006')
 
 
 
 --select * from #cmp2
 
 select cmp2.Cmpid UC号,cmp2.Name 单位名称,'' 国内机票佣金,cmp1.维护人 运营经理,cmp1.客户主管 售后主管
 into #cmp3
 from #cmp2 cmp2
 inner join #cmp1 cmp1 on cmp1.Cmpid=cmp2.Cmpid
 where cmp2.Cmpid not in ('000003','000006')
 
 select * from #cmp3
 
 select UnitCompanyID,* from homsomDB..Trv_FlightNormalPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 select UnitCompanyID,* from homsomDB..Trv_FlightTripartitePolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 select UnitCompanyID,* from homsomDB..Trv_FlightAdvancedPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 SELECT * FROM homsomDB..Trv_RebateRelations where FlightNormalPolicyID in('13F5540F-18EB-4679-9860-4894BE5F5C7F')
 
 --国际
 select * from homsomDB..Trv_IntlFlightNormalPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 
 --单位中申请国内特殊票价为是，特殊票价报销凭证：特殊行程单的数据
 select top 10 CertificateD,CertificateI,CertificateTC,* from homsomDB..Trv_UnitCompanies where Cmpid='000321'
 
 select distinct u.Cmpid
from Topway..tbcash  c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where  u.IsSepPrice=1 and u.InvoiceType=1

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='杜鹏媛',SpareTC='杜鹏媛'
where coupno='AS001571589'

select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='杜鹏媛',SpareTC='杜鹏媛'
where coupno='AS001583950'

--退票状态
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti  set ExamineDate='2019-04-10'
where reno='0431729'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='崔玉杰',SpareTC='崔玉杰'
where coupno='AS001563769'

--（产品部专用）会务结算单供应商来源
select * from Topway..tbConventionJS 
where ConventionId='1243' 
and GysSource in ('会务备用金（丁一）','金茂三亚丽思卡尔顿酒店')

select * from Topway..tbConventionBudget where ConventionId='1243'


/*现需要拉取所有合作差旅单位中返佣类型为后返（单位后返/个人后返）的公司名单，所需字段如下：

UC号、单位名称、客户经理、售后主管、国内机票佣金（单位后返/个人年后返）、返佣比例或金额、国际机票佣金（单位后返/个人年后返）、返佣比例或金额
符合条件的单位
*/


IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select t1.cmpid ,t4.ID as 单位ID,t1.cmpname 
,(case CustomerType when 'A' then '差旅单位客户' when 'C' then '旅游单位客户' else '' end) as type
,(CASE hztype WHEN 0 THEN '我方终止合作' WHEN 1 THEN '正常合作正常月结' WHEN 2 THEN '正常合作仅限现结' WHEN 3 THEN '正常合作临时月结' WHEN 4 THEN '对方终止合作'  ELSE '' END) as 合作状态
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompies_Sales t5 on t9.ID=t5.EmployeeID where t5.UnitCompayID=t4.id)  as 开发人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_AccountManagers t6 on t9.ID=t6.EmployeeID where t6.UnitCompanyID=t4.id) as 客户主管
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_UnitCompanies_KEYAccountManagers t10 on t10.EmployeeID=t9.ID where t10.UnitCompanyID=t4.ID) as 维护人
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TktUnitCompanies_TktTCs t8 on t9.id=t8.TktTCID where t8.TktUnitCompanyID=t4.ID) as 差旅业务顾问
,(select top 1t9.name from homsomDB..SSO_Users t9 inner join homsomDB..Trv_TrvUnitCompanies_TrvTCs t7 on t9.id=t7.TrvTCID where t7.TrvUnitCompanyID=t4.ID) as 旅游业务顾问
,t4.TerminateReason as 终止合作原因
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
where hztype in ('1','2','3') and t1.cmpid not in ('000003','000006')
group by t1.cmpid,t1.cmpname,CustomerType,hztype,t4.id,indate,t4.TerminateReason
order by t1.cmpid

select * from #cmp1

--国内机票正常线路

select ID,Name,* from homsomDB..Trv_Dictionaries where Name like '%后返%'

 select * from homsomDB..Trv_Dictionaries where DictionaryType='4' 
 select ID,* from homsomDB..Trv_FlightNormalPolicies where CommissionTypeID in(select ID from homsomDB..Trv_Dictionaries where Name like '%后返%')
 select UnitCompanyID,* from homsomDB..Trv_FlightTripartitePolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 select UnitCompanyID,* from homsomDB..Trv_FlightAdvancedPolicies where CommissionTypeID='3FD965EA-EE4B-46EB-9C9A-A17000A88034'
 
 SELECT UN.Cmpid,D.Name,[Percent] 返佣比列或金额
 into #fyje
 FROM homsomDB..Trv_RebateRelations  re
 left join homsomDB..Trv_FlightNormalPolicies f1 on f1.ID=re.FlightNormalPolicyID and f1.EndTime>'2019-04-11'
 left join homsomDB..Trv_FlightTripartitePolicies f2 on f2.ID=re.FlightNormalPolicyID and f2.EndTime>'2019-04-11'
 left join homsomDB..Trv_FlightAdvancedPolicies f3 on f3.ID=re.FlightNormalPolicyID  and f3.EndTime>'2019-04-11'
 left join homsomDB..Trv_Dictionaries d on (d.ID=f1.CommissionTypeID or d.ID=f2.CommissionTypeID or d.ID=f3.CommissionTypeID)
 left join homsomDB..Trv_UnitCompanies un on (un.ID=f1.UnitCompanyID or un.ID=f2.UnitCompanyID or un.ID=f3.UnitCompanyID)
 where d.Name like '%后返%'
 and un.CooperativeStatus in ('1','2','3')
 and un.Type='A'
 AND [Percent]!=0
 AND d.Name NOT IN ('单位后返+个人后返')
 
 select * from #fyje
 
 select distinct f.cmpid uc ,cmp.cmpname 单位名称, cmp.TYPE 单位类型, cmp.合作状态,cmp.客户主管 售后主管,cmp.维护人 运营经理,
 f.name 返佣类型,f.返佣比列或金额
 from #fyje f
 left join #cmp1 cmp on Cmp.cmpid=f.cmpid
 
 
 select * from homsomDB..Trv_UnitCompanies where Cmpid='000003'
 
 
 --修改账单抬头
 select * from Topway..AccountStatement 
 --update Topway..AccountStatement set CompanyNameCN='菲诗小铺（上海）化妆品销售有限公司'
 where BillNumber='018902_20190401'
 
 --撤销闭团及闭团相关信息（旅游）
 select Status,* from Topway..tbTravelBudget 
-- update Topway..tbTravelBudget  set Status=14
 where TrvId='29698'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='蒋燕华',SpareTC='蒋燕华'
where coupno in ('AS001552858','AS001552862')

--旅游结算单信息

select Jstatus,* from Topway..tbTrvJS 
--update Topway..tbTrvJS set Jstatus='4'
where TrvId='29688' and JsPrice='42750'
delete from Topway..tbHtlcoupYf where CoupNo='PTW080103'


--删除常旅客绑定部门ID
select CompanyDptId from homsomDB..Trv_UnitPersons 
--update  homsomDB..Trv_UnitPersons  set CompanyDptId=null
where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID 
where up.CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B' 
and IsDisplay=1 )

--删除现有部门
select * 
--delete
from homsomDB..Trv_CompanyStructure where CompanyId='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B'

--新增部门
--insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','#N/A','#N/A','','2019-04-11','homsom','2019-04-11','homsom','689B6FB7-AC78-424A-9608-D35F6E101FC9',null,'0')

insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','#N/A','#N/A','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','深圳网络规划','深圳网络规划','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海人力资源','上海人力资源','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海数据洞悉','上海数据洞悉','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海开发','上海开发','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海COMM','上海COMM','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海供应链管理','上海供应链管理','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海供应链管理COMM存货控制','上海供应链管理COMM存货控制','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海营运营运-LSM','上海营运营运-LSM','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海营运OER','上海营运OER','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海营运营运-AMDM','上海营运营运-AMDM','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海市场新品开发','上海市场新品开发','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海市场','上海市场','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海市场品牌管理','上海市场品牌管理','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京营运','北京营运','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京COMM','北京COMM','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京工程','北京工程','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海CEO办公室','上海CEO办公室','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京营运营运-AMDM','北京营运营运-AMDM','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','东莞COMM','东莞COMM','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海供应链管理中央采购','上海供应链管理中央采购','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京洋桥店','北京洋桥店','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','天津大通店','天津大通店','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海银春路店','上海银春路店','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海江月店','上海江月店','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海财务','上海财务','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','深圳政府关系','深圳政府关系','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','深圳开发','深圳开发','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京开发开发','北京开发开发','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海营运','上海营运','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','广州开发','广州开发','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海工程','上海工程','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海网络规划','上海网络规划','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京网络规划','北京网络规划','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海市场市场部LSM','上海市场市场部LSM','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','深圳财务','深圳财务','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','深圳人力资源','深圳人力资源','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海IT','上海IT','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','深圳营运','深圳营运','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','深圳营运营运-LSM','深圳营运营运-LSM','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海营运培训','上海营运培训','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海龙华西店','上海龙华西店','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海蒙自店','上海蒙自店','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海华青南路店','上海华青南路店','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','上海四川北路店','上海四川北路店','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','杭州营运营运-AMDM','杭州营运营运-AMDM','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京东高地店','北京东高地店','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京长安商场店','北京长安商场店','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京营运营运-LSM','北京营运营运-LSM','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京双安店','北京双安店','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京四元桥家乐福店','北京四元桥家乐福店','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京政府关系','北京政府关系','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','天津开发开发','天津开发开发','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京开发资产管理','北京开发资产管理','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','深圳营运培训','深圳营运培训','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','深圳营运营运-AMDM','深圳营运营运-AMDM','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','深圳工程','深圳工程','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京甜水园店','北京甜水园店','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')
insert into homsomDB..Trv_CompanyStructure (ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId,ParentID,IsBranch) values (NEWID(),'2019-04-11','北京天宫院店','北京天宫院店','','2019-04-11','homsom','2019-04-11','homsom','329D7AC1-6CAC-47B2-AA79-A5DA00A4975B',null,'0')




--匹配部门

update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='f3f31100-47af-44bb-a3cd-aa14012e0cf6'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海工程' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='9a28be36-022b-4960-b6a3-a77000b8abed'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海网络规划' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='fb5b632c-6d47-4974-857a-a99700f6fc63'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='1ae6cfcf-5655-4ad8-b4b7-a823009ca472'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海CEO办公室' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='518bdf73-9b09-4cab-8025-a8f700976898'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运OER' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='b8806ac5-15d0-468d-b7cd-a934011f9cb1'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京COMM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='e78b6a39-b95f-4cb5-958b-a97b00c0e6f2'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='377bff85-dacd-46a1-845e-a87f00c9990d'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京COMM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='a3a7ce49-5129-43f8-98ab-a83f00dd732e'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='a3dc17f7-aed0-415f-bcca-d82c43d49074'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京长安商场店' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='727df2f3-22bd-4a5e-825d-aa1a009b6656'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='8b67e7ea-0932-4d09-9afa-87a073ba9a69'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京开发开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='bb77356d-8019-41e7-8066-a9f1011f3d67'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='4efd7c80-de1d-451d-821f-aa1500f34096'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海人力资源' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='ce0ea02f-6f42-4233-ab66-a82b01098aa9'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='092a6517-9171-4ffd-a0d6-a88f0126e8ce'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='f3820f8c-7aed-4226-85be-ecbec66053d3'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='80cd0f18-1c21-4fed-894b-aa14012ccb38'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='99ec4a17-5547-4d57-bce4-085b2915ac20'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京四元桥家乐福店' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='94cfb40e-0d79-45d2-9f57-aa1a009be1d9'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='b106b4b9-aead-4f5c-97e6-d02981fcd074'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海四川北路店' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='7a91a9fa-3256-4afe-8b47-aa14012e26ab'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='b209dabb-8338-437e-af12-e8a30eeaed68'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海数据洞悉' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='e5a05496-0e62-43fa-8fad-60b781388a62'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海供应链管理' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='6edcfd6f-1b24-4c07-bc5c-21188823d374'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='深圳财务' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='dbf97d4c-5a35-42d9-9d4e-a8e70117a8a1'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京洋桥店' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='5194ac4e-0af6-4c6f-aae8-a98f00e907fd'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='d0b3b52f-c9f4-4b0f-aad7-a92d01239352'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海市场新品开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='f098990c-935e-4125-98be-a8ea00c887cf'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运培训' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='30ea607a-1b92-47b7-9d89-a92d01235664'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京营运营运-LSM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='6aaa3029-f539-4e86-89c2-aa1a009b8cba'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海COMM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='c808b224-9783-477f-87ec-aa1400de96b8'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='3ecb491f-1b85-4968-bc9e-d61858bb6c5c'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='5704f491-8e94-4dc0-a8a9-aa1500f2f958'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京工程' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='861a881b-8de4-4228-bc4c-a9f101209744'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海人力资源' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='ed46983a-ed3d-4777-b8f6-a77e00c255d8'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海财务' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='27bed315-50ff-41df-a5b2-a86c009f13f7'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='0f516b8d-2ac0-4bb8-acdb-4cb4a3ec1d8f'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运培训' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='40fcb329-d6f1-40e3-b9c9-aa14011e1e91'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='3ce65f81-483d-4270-9bae-aa1500f31c9c'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海COMM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='b3fd4cde-eea5-452f-8256-33d40b2240c1'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='ece1bf24-593a-42aa-b412-a80b00b18607'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京开发开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='1f7e21e7-ac6d-4964-b023-a9f1011fc092'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海市场新品开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='cb2ae2a0-69ab-4e81-ac6e-b31f061b0f76'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海供应链管理中央采购' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='31d34e07-1294-4f2a-a778-a92900ab7fc8'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='ec3e9a8b-993f-4fac-83fd-a9ff00fe9d56'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='深圳营运营运-LSM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='48a39941-53d6-4a25-9ca6-a9ae00b3a42d'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海市场' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='05cd5b7d-b143-4f39-b62c-95fde004b804'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='8002606d-0d8b-435f-b55d-1c7eaff5d08e'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海CEO办公室' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='2267cd53-530c-4086-abde-a78400e958dc'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='3a4f9ea6-c5f8-4a36-a666-a80b00b1b26f'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京COMM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='b8a62e67-301d-44d7-bf19-a9ae00db9a83'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京营运' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='172e3d09-8d52-4952-ae15-f40a4a7dcb3c'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='fde7f14d-2ef9-4f0d-b3c7-aa14012d1788'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='1f9d54d2-2821-4094-abb7-aa1a009a12d5'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海人力资源' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='dcad76c5-f7c6-4359-acbe-fd11f4d1ea98'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='天津开发开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='c3cb22eb-e608-4afc-9858-a9f1011ebaa8'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='3e958b52-a12a-4b6b-9373-aa1500f91ccf'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='b76218ff-e81c-47d1-bf0f-a80b00b19cca'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海财务' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='386b32fc-6da3-4d41-b090-a91400a198b0'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京开发开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='30b62976-f182-449e-ba26-a9f1011fe3f7'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海供应链管理' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='fca3e7f8-c6f0-4443-8002-a80f00c517f7'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='578ec8e3-98f7-4e24-8c8e-a92100cf0494'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海IT' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='bc31ba36-658c-4ada-88e8-a95300a8191f'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海IT' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='f8ff6ee9-6af9-4790-b26b-a92600a73bf7'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海网络规划' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='d9b8d873-9b31-41ac-abd1-a93600a6cc7f'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='e43a9f68-65e0-404a-90c3-87a74207d644'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='ecaf941b-85bc-461f-9679-bb980b23a95c'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='8195fc4d-5aab-4060-bc6e-aa14012e4606'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海网络规划' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='ab685bea-2035-4f32-8560-a99700f6e4c9'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京甜水园店' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='9b292e7e-1a4c-433f-8298-a92f00949e5a'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='8fc2cb99-849f-4c6c-8cdf-bc2eec070259'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='ee0b1964-6494-4f74-8492-aa14012f107d'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京开发开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='3755951b-0c8d-45b4-94c3-a9f1011e99c4'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='天津大通店' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='bcc34c2d-b229-483e-aa26-a98f00ea2c4e'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='9bf90a9d-8747-49a4-8394-a75a00e796c3'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海蒙自店' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='a741039a-d677-4233-9a51-aa14012cf959'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='dc578d8a-a1b3-4e01-937a-312a479b043b'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运OER' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='d273b846-f666-4783-b119-30a95e74fdc0'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='19665c2b-6a4f-4083-9783-aa1a0099f190'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京开发资产管理' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='b2fc6f91-645a-4446-af0f-a9f1011f806c'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='eb447ce7-5c10-4a96-8a14-cdc5c20711a1'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海工程' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='3e905101-21e3-4938-b1e1-a80f00c4f894'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海COMM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='8e76a30c-93fc-4f8d-af98-e90c5d6cd98b'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京工程' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='56897fec-7c71-4dc2-a413-a9f10120bab6'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='广州开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='12194886-560a-4523-85e7-a9f200cb9f68'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='深圳网络规划' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='0269dfd5-133c-4a74-817a-a99700f7811d'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='东莞COMM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='84a2879e-8981-4b76-8827-aa2b011bd2a2'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='深圳工程' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='2252f7d6-1d56-4dcb-bf56-a8d600d0df78'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京双安店' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='d9b6f371-5068-4a91-9461-a91801373e72'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='64e14a8e-095f-4d0f-bb1d-aa1a009bc6bc'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海江月店' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='5da557a2-2552-4ddb-a3a1-a9ff00feb961'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京政府关系' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='46e3b048-8ce4-43f2-83e4-a98f011c2829'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运培训' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='0df81580-97f0-4778-b766-a9f101210c0c'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京COMM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='2b835a8b-61bc-4a56-9c80-a92900fa9761'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海华青南路店' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='9a672f9d-6828-4acb-80b4-557b1178ae14'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='深圳工程' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='bd73af4e-fed8-4e36-bb98-aa14012df274'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京开发开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='77b44b29-0652-4413-b5b6-a9c5010bc98f'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海IT' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='6d5ae892-5428-48ba-8b5b-a9f1011f601a'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='a5a915f4-6b7f-4a50-8f29-a93c009fdf91'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京营运' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='ad9ad1c5-b301-48e5-ac6c-a92100cf2cd6'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海供应链管理COMM存货控制' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='4e7efb30-ac3d-4e55-bc47-e247fb5a9322'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='东莞COMM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='86fa4212-6c82-42a7-91d9-2e7d026df4fd'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='东莞COMM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='e723d76a-74b7-4365-9803-aa07010a1f85'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海工程' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='97bf85d0-ff02-44cd-884f-a8cd00c56577'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海银春路店' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='cfa2d36a-7341-4aa4-bd15-a8d400ca0277'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='90760faa-bdc2-4e44-a660-a98f011c11a4'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='深圳营运' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='f3d023d7-87e9-47c3-ab61-aa1500f2d461'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='45f06c35-ff61-4287-9107-a9ae00b38665'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京开发开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='e7029718-3085-419e-90c0-aa14012ee604'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='d41a50d5-242c-46b7-aedb-a89c010fb7e0'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='深圳政府关系' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='cabb5ece-8a5e-4820-9afe-a8bf00f08ecf'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='广州开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='0b35bcfc-e8fa-4679-ab37-a890009addde'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海市场新品开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='27e929c5-3bb1-4104-a91d-a9f200cbbe69'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海供应链管理中央采购' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='e6274c0d-f8f2-430a-8622-7e08c15b773a'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='广州开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='9ffc004d-6eb6-4624-baa0-a96000a9e902'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海龙华西店' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='4cf76a6a-9ce5-48d1-859f-a8c400dea757'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='bc08b993-6cad-47fd-b368-aa14012caf5b'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='91e44695-7cf7-4707-a6ee-787324f9675e'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京工程' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='37b023f1-9f6e-4d52-a058-a83f00f18174'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京网络规划' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='33de8891-77a9-49b6-ac88-a9f10120702e'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京开发开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='a7548b24-ab77-4b31-adbd-a7f200eb131e'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='a9ae8563-8eea-48a2-9e48-a9f1011fa08b'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='35774d8d-0209-4d8b-b403-a81f00a0b934'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海市场品牌管理' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='e479477b-1cc3-46e8-bb74-a75800b955b9'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京东高地店' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='c8ec9270-945b-45a4-9d7d-668197410c80'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='深圳营运培训' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='9aa719c0-7f95-4b69-9dec-aa1a009b4788'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京政府关系' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='8f284a6c-fb2e-44f1-8ae0-a9f200c4e930'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京网络规划' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='251e687c-d720-48f8-80c8-a9f1011e714f'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='8fdbf8c4-e308-4f6e-abb2-a9f10120e397'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京COMM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='4ef9b910-a0bf-4ed1-a691-a93401205420'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海市场市场部LSM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='7c885cce-7480-4afa-a7c8-a7b40094ec0b'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='7c7aa6cb-2485-4558-b52a-a751012063ec'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='深圳营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='3422af94-81d4-4b7d-b6a5-7e70893a2864'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海市场新品开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='ca5cafea-3c33-4db9-9c65-a8f901122cc1'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='bef8e262-fd2a-4083-b124-ba2f46f27da7'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海供应链管理中央采购' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='20adb65a-bf77-4d47-93ea-63ea5e7eaed9'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='943f8448-437b-44ce-a1e2-a77000b8c814'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海网络规划' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='dae90ace-c8db-478b-be60-aa1500f28a57'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京工程' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='47e1c380-e0f0-4773-963a-a7c30094795d'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='深圳开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='12687aff-9939-49de-afdc-8ba4e231543f'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海供应链管理中央采购' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='5b96e36c-3b2f-466a-95ef-a9f200c49cfe'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='e6be950d-4e7c-4b00-90da-a93800c231d6'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='54209f95-91dd-41f8-8b35-aa1a009bacc2'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海工程' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='519fa5c6-35b8-43db-b09b-aa15010047ce'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京工程' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='bfdfb8eb-5cc4-4dea-a205-a76e012431e6'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运OER' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='1426f12b-b994-4a20-9c4c-aa2b011beefc'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='深圳人力资源' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='5678805c-4c88-4d7d-85ee-a9f10120046e'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海供应链管理' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='b379cf47-b358-4fdb-8295-a93401204298'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='5a555df0-f5f7-413c-977e-a8e900b08049'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='杭州营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='b5ef6c03-27c3-4dc6-aff1-a877011411e6'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='637f9c83-b7df-49c2-aad9-14c36bb1d6a6'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='深圳开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='553d3b93-1619-4b5b-a7fd-aa1500ffcc55'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='0a47ccff-65f5-4c8c-9c49-a80e009d90cf'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='cf955e76-bbc9-45b8-b1af-a9f30120ceec'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-AMDM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='d17be1a7-1563-4376-ac59-5ef2259ad9db'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='深圳开发' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='0bfc9576-ea3f-46e9-88b4-a80e009cb6a4'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运OER' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='6fc42139-2f38-4b35-adb2-aa1500f8b3ba'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='北京天宫院店' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='fcf67474-5d75-4e56-b1bf-a890009afa5a'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海数据洞悉' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='0e853d32-108a-4e04-9c46-d86cddc8557c'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='上海营运营运-LSM' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='917064c0-4716-4670-80b6-a92f0094bd02'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='深圳网络规划' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='a0601ad4-fc48-41b6-be2f-a93800bd1bab'


update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='3b16271e-ff63-40ed-bd16-1b5b88475433'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='b64f9e94-2487-4113-8bef-d253032f6a32'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='d3d9c071-cb2c-4a06-b880-a86b011b00e4'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='a2993411-eb31-43a0-aeb0-a86b011b00cd'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='00740c9b-7d5a-45d9-b239-9500787a050d'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='a79f4e32-7e19-4380-bfbc-920a254df449'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='6c26ab4a-424d-4183-8012-a86b011b00b1'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='9dbbaf82-928d-42e8-9232-5af0bfc1d14c'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='676bee41-402a-4baf-86dd-844ec60a1f90'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='86ac3035-141d-4367-b00a-a7f3010dbc68'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='50f6620a-7860-46c7-a668-a86b00ed1c8e'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='d88ba6fd-8317-47ae-8c24-a86e00ca678b'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='c5edf0db-1264-43c1-9936-a8f8009871d5'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='249eae9d-2091-48aa-85b3-a96a010f207e'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='3a9f8d4e-5f1c-477a-a065-a96a010f3d03'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='2ea80529-dd21-4e8d-a021-a98300fd333e'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='38d9bf04-0170-4c79-8577-a98301006b68'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='3b02f987-f9e6-436b-9829-a9830100a758'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='8892210f-a365-4e81-9054-a98800ae5998'
update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure where DepName='#N/A' and CompanyID='329D7AC1-6CAC-47B2-AA79-A5DA00A4975B') where ID='103d2954-1096-45dc-9f28-aa1100dc9c6b'


select FirstName,LastName,,Name,* from homsomDB..Trv_Human a
left join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where a.FirstName='WILSON KAI HANG' and a.LastName='CHUNG' and a.MiddleName='' and a.Name=''


