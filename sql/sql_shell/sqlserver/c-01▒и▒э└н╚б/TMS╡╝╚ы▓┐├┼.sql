SELECT * FROM homsomdb..Trv_UnitCompanies WHERE Cmpid='019333'  ----12CD09E1-095C-4B40-81E9-A506009CE2AD

IF OBJECT_ID('tempdb.dbo.#p') IS NOT NULL DROP TABLE #p
CREATE TABLE #P(dep varchar(100)) 

INSERT INTO #P(dep)

--="UNION ALL SELECT '" &B1&"' AS depname"
SELECT 'TDA-SH（周强）' AS depname
UNION ALL SELECT 'QMPP3-SH（梅军）' AS depname
UNION ALL SELECT 'IEIA-SH(经健雄)' AS depname
UNION ALL SELECT 'IESP-SH（经健雄）' AS depname
UNION ALL SELECT 'IEIE-SH（郭晓鹏）' AS depname
UNION ALL SELECT 'TSP-SH（郭晓鹏）' AS depname
UNION ALL SELECT 'CH-SH（张纹）' AS depname
UNION ALL SELECT 'CH-SH总监（张纹）' AS depname
UNION ALL SELECT 'HRB-SH（张纹）' AS depname
UNION ALL SELECT 'FM-SH（张纹）' AS depname
UNION ALL SELECT 'TSP-SH（周强）' AS depname
UNION ALL SELECT 'TDM2-SH（周强）' AS depname
UNION ALL SELECT 'SPD2-SH（周强）' AS depname
UNION ALL SELECT 'TDE-SH（周强）' AS depname
UNION ALL SELECT 'IEIS-SH（经健雄）' AS depname
UNION ALL SELECT 'QMPP4-SH（梅军）' AS depname
UNION ALL SELECT 'QMI-SH（梅军）' AS depname
UNION ALL SELECT 'QMM-SH（梅军）' AS depname
UNION ALL SELECT 'AQ-SH总监（张纹）' AS depname
UNION ALL SELECT 'LO-SH总监（张纹）' AS depname
UNION ALL SELECT 'OPD2-SH（经健雄）' AS depname
UNION ALL SELECT 'LOT-SH（叶青）' AS depname
UNION ALL SELECT 'OP-SH（张纹）' AS depname
UNION ALL SELECT 'SO-SH（经健雄）' AS depname
UNION ALL SELECT 'TAS1-SH（郭晓鹏）' AS depname
UNION ALL SELECT 'TST-SH（郭晓鹏）' AS depname
UNION ALL SELECT 'TSL-SH（郭晓鹏）' AS depname
UNION ALL SELECT 'SPD-SH（郭晓鹏）' AS depname
UNION ALL SELECT 'PUN-SH (陈万里）' AS depname
UNION ALL SELECT 'TDM21-SH（周强）' AS depname
UNION ALL SELECT '审批人张纹' AS depname
UNION ALL SELECT '马夸特开关（上海）有限公司' AS depname
UNION ALL SELECT 'TS-SH总监（张纹）' AS depname
UNION ALL SELECT 'PUP-SH（陈万里）' AS depname
UNION ALL SELECT 'PUN2-SH（陈万里）' AS depname
UNION ALL SELECT 'PUA-SH(陈万里）' AS depname
UNION ALL SELECT 'QMPS-SH（梅军）' AS depname
UNION ALL SELECT 'IT-SH（张纹）' AS depname
UNION ALL SELECT 'HRP-SH（张纹）' AS depname
UNION ALL SELECT 'OP1-SH（周强）' AS depname
UNION ALL SELECT 'SOLP-SH（经健雄）' AS depname
UNION ALL SELECT 'FI-SH（张纹）' AS depname
UNION ALL SELECT 'TDM1-SH（周强）' AS depname
UNION ALL SELECT 'QMOC3-SH（梅军）' AS depname
UNION ALL SELECT 'AP5S-SH（屈彬）' AS depname
UNION ALL SELECT '审批人屈彬' AS depname
UNION ALL SELECT 'SPH-SH（郭晓鹏）' AS depname
UNION ALL SELECT 'OPQ1-SH（经健雄）' AS depname
UNION ALL SELECT 'TA-SH（张纹）' AS depname
UNION ALL SELECT 'OPP-SH（经健雄）' AS depname
UNION ALL SELECT 'TDE1-SH（周强）' AS depname
UNION ALL SELECT 'TDS2-SH（周强）' AS depname
UNION ALL SELECT 'TDS2-SH（屠科）' AS depname
UNION ALL SELECT 'GM-SH（张纹）' AS depname
UNION ALL SELECT 'IEIA-SH（郭晓鹏）' AS depname
UNION ALL SELECT 'IEIE-SH（经健雄)' AS depname
UNION ALL SELECT 'TAL-SH（郭晓鹏）' AS depname
UNION ALL SELECT 'TAL1-SH（郭晓鹏）' AS depname
UNION ALL SELECT 'TDM1-SH（经健雄）' AS depname
UNION ALL SELECT 'TSH-SH（郭晓鹏）' AS depname
UNION ALL SELECT 'TDS1-SH（屠科）' AS depname
UNION ALL SELECT '审批人梅军' AS depname
UNION ALL SELECT 'TAL2-SH（屈彬）' AS depname
UNION ALL SELECT 'CP-SH-梅军审批' AS depname
UNION ALL SELECT 'TDC-SH（周强）' AS depname
UNION ALL SELECT 'QMOC-SH（梅军）' AS depname
UNION ALL SELECT 'TAS2-SH（郭晓鹏）' AS depname
UNION ALL SELECT 'TDS1-SH（王立）' AS depname
UNION ALL SELECT 'TD-SH(总监)' AS depname
UNION ALL SELECT 'QMPP5-SH（梅军）' AS depname
UNION ALL SELECT 'TD-SH（周强）' AS depname
UNION ALL SELECT 'TES-SH（周强）' AS depname
UNION ALL SELECT 'PU(张纹)' AS depname
UNION ALL SELECT 'TET1-SH（周强）' AS depname
UNION ALL SELECT 'PR-SH（张纹）' AS depname
UNION ALL SELECT 'AP5L-SH' AS depname
UNION ALL SELECT 'TDM1-SH（屠科）' AS depname
UNION ALL SELECT 'OP2-SH（经健雄）' AS depname
UNION ALL SELECT 'SOP-SH（经健雄）' AS depname
UNION ALL SELECT 'Sales and Program Management, Automotive（郭晓鹏）' AS depname
UNION ALL SELECT 'TDS1-SH（周强）' AS depname
UNION ALL SELECT 'LO-SH（叶青）' AS depname
UNION ALL SELECT 'Engineering（周强）' AS depname
UNION ALL SELECT 'PUN1-SH（陈万里）' AS depname
UNION ALL SELECT 'TDS-SH（周强）' AS depname
UNION ALL SELECT 'TAL1-SH（屈彬）' AS depname
UNION ALL SELECT 'Purchasing(陈万里)' AS depname
UNION ALL SELECT 'IET-SH（经健雄）' AS depname
UNION ALL SELECT 'OPS2-SH（经健雄）' AS depname
UNION ALL SELECT 'APDX-SH（周强）' AS depname
UNION ALL SELECT 'LOD(徐孝)' AS depname
UNION ALL SELECT 'LO-SH（徐孝）' AS depname
UNION ALL SELECT 'TET-SH（周强）' AS depname
UNION ALL SELECT 'TAL-SH（屈彬）' AS depname





select * from  #p



--去重部门
IF OBJECT_ID('tempdb.dbo.#t') IS NOT NULL DROP TABLE #t
SELECT DISTINCT dep as depname INTO #t 
FROM #p

--公司ID
SELECT * FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='017888'
--插入部门
INSERT INTO homsomDB..Trv_CompanyStructure(ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,CompanyId,ParentID,IsBranch)
SELECT  NEWID()AS ID,GETDATE()AS ver,depName AS DepName,depName AS Code,'' AS Remarks,GETDATE() AS CreateDate,'Herry' AS CreateBy,'12CD09E1-095C-4B40-81E9-A506009CE2AD' AS CompanyId,NULL AS ParentID,0 AS IsBranch
FROM #t


--检查人员、部门是否完整
SELECT up.ID, h.Name,t2.*--,dep.DepName,
FROM homsomDB..Trv_UnitPersons up
INNER JOIN homsomDB..Trv_Human h ON up.ID=h.ID AND up.CompanyID='12CD09E1-095C-4B40-81E9-A506009CE2AD' AND h.IsDisplay=1
RIGHT JOIN #t t2 ON  h.Name=t2.empName
WHERE h.ID IS NULL

--更新
UPDATE homsomDB..Trv_UnitPersons SET CompanyDptId=dep.ID
--SELECT up.ID, h.Name,t2.*,dep.DepName,dep.id
FROM homsomDB..Trv_UnitPersons up
INNER JOIN homsomDB..Trv_Human h ON up.ID=h.ID AND up.CompanyID='12CD09E1-095C-4B40-81E9-A506009CE2AD' AND h.IsDisplay=1
INNER JOIN #t t2 ON  h.Name=t2.empName
INNER JOIN homsomDB..Trv_CompanyStructure dep ON dep.CompanyId='12CD09E1-095C-4B40-81E9-A506009CE2AD' AND t2.depName=dep.DepName

select * from #t

--成本中心
SELECT * FROM homsomDB..Trv_CostCenter WHERE CompanyId='12CD09E1-095C-4B40-81E9-A506009CE2AD'

IF OBJECT_ID('tempdb.dbo.#p2') IS NOT NULL DROP TABLE #p2
CREATE TABLE #P2(costcenter varchar(100)) 

INSERT INTO #P2(costcenter)

--="UNION ALL SELECT '" &B1&"' AS costcenter"
SELECT '宁波星健' AS costcenter
UNION ALL SELECT '泰康苏州吴园' AS costcenter
UNION ALL SELECT '余姚改造' AS costcenter
UNION ALL SELECT '无锡中海' AS costcenter
UNION ALL SELECT '南京银海' AS costcenter
UNION ALL SELECT '海南鹏欣' AS costcenter
UNION ALL SELECT '外出学习' AS costcenter
UNION ALL SELECT '北京星健' AS costcenter
UNION ALL SELECT '海南博鳌' AS costcenter
UNION ALL SELECT '大爱城项目' AS costcenter
UNION ALL SELECT '保利的标准化设计' AS costcenter
UNION ALL SELECT '无锡国药康' AS costcenter
UNION ALL SELECT '公司营销' AS costcenter
UNION ALL SELECT '天津中海' AS costcenter
UNION ALL SELECT '华润沈阳小南街' AS costcenter
UNION ALL SELECT '北京一方项目' AS costcenter
UNION ALL SELECT '西安九九项目' AS costcenter
UNION ALL SELECT '星健北京七叶香山' AS costcenter
UNION ALL SELECT '广州泰成' AS costcenter
UNION ALL SELECT '蜀园' AS costcenter
UNION ALL SELECT '杭州西湖' AS costcenter
UNION ALL SELECT '天津中海标示项目' AS costcenter
UNION ALL SELECT '大爱城项目 ' AS costcenter
UNION ALL SELECT '北京星健' AS costcenter
UNION ALL SELECT '西安医院' AS costcenter
UNION ALL SELECT '大爱城项目 ' AS costcenter
UNION ALL SELECT '杭州围产' AS costcenter
UNION ALL SELECT '中海苏州' AS costcenter
UNION ALL SELECT '北京星健' AS costcenter


--去重成本中心
IF OBJECT_ID('tempdb.dbo.#t2') IS NOT NULL DROP TABLE #t2
SELECT DISTINCT costcenter as costcenter INTO #t2 
FROM #p2



INSERT INTO homsomDB..Trv_CostCenter(ID,Ver,Name,Code,Remarks,ModifyBy,ModifyDate,CreateBy,CreateDate,CompanyId,ParentID)
SELECT  NEWID()AS ID,GETDATE()AS ver,costcenter AS name,costcenter AS Code,'' AS Remarks,'homsom' as modifyby,GETDATE() as modifydate,'homsom' AS CreateBy,GETDATE() AS CreateDate,'12CD09E1-095C-4B40-81E9-A506009CE2AD' AS CompanyId,NULL AS ParentID
FROM #t2 t2
where t2.costcenter not in (SELECT Name FROM homsomDB..Trv_CostCenter WHERE CompanyId='12CD09E1-095C-4B40-81E9-A506009CE2AD')


--BU
IF OBJECT_ID('tempdb.dbo.#p3') IS NOT NULL DROP TABLE #p3
CREATE TABLE #P3(BU varchar(100)) 

INSERT INTO #P3(BU)

--="UNION ALL SELECT '" &B1&"' AS BU"
SELECT '售前' AS BU
UNION ALL SELECT '售前' AS BU
UNION ALL SELECT '售前' AS BU
UNION ALL SELECT '售前' AS BU
UNION ALL SELECT '售前' AS BU
UNION ALL SELECT '售前' AS BU
UNION ALL SELECT '售前' AS BU
UNION ALL SELECT '售前' AS BU


--去重BU
IF OBJECT_ID('tempdb.dbo.#t3') IS NOT NULL DROP TABLE #t3
SELECT DISTINCT BU as BU INTO #t3 
FROM #p3

INSERT INTO homsomDB..Trv_CompanyUndercover(ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId)
select NEWID() as id,GETDATE()AS ver,bu as UnderName,GETDATE() as CreateDate,'homsom' as CreateBy,GETDATE() as modifydate,'homsom' as ModifyBy,'12CD09E1-095C-4B40-81E9-A506009CE2AD' as CompanyId
FROM #t3 t3
where t3.BU not in (SELECT UnderName FROM homsomDB..Trv_CompanyUndercover WHERE CompanyId='12CD09E1-095C-4B40-81E9-A506009CE2AD')


--项目编号
IF OBJECT_ID('tempdb.dbo.#p4') IS NOT NULL DROP TABLE #p4
CREATE TABLE #P4(item varchar(100)) 

INSERT INTO #P4(item)

--="UNION ALL SELECT '" &B1&"' AS item"
SELECT 'ACI-S' AS item
UNION ALL SELECT 'HNI-S' AS item
UNION ALL SELECT 'MPS-S' AS item
UNION ALL SELECT 'TPI-S' AS item
UNION ALL SELECT 'TPI-SAT' AS item
UNION ALL SELECT 'TPN-W' AS item
UNION ALL SELECT 'SGI-S' AS item
UNION ALL SELECT 'ANT-S' AS item
UNION ALL SELECT 'STO-S' AS item
UNION ALL SELECT 'BCO-S' AS item
UNION ALL SELECT 'India-S' AS item
UNION ALL SELECT 'Brazil-S' AS item
UNION ALL SELECT 'SGI07-W' AS item
UNION ALL SELECT 'BCO-W' AS item
UNION ALL SELECT 'BCO07-SAT' AS item
UNION ALL SELECT 'HIS-S' AS item
UNION ALL SELECT 'CPI-S' AS item
UNION ALL SELECT 'HSB-S' AS item
UNION ALL SELECT 'HST-S' AS item
UNION ALL SELECT 'UMP-S' AS item
UNION ALL SELECT 'UMPMP-S' AS item
UNION ALL SELECT 'UMPGMP-S' AS item
UNION ALL SELECT 'UMP17MP-W' AS item
UNION ALL SELECT 'UMP17GMP-W' AS item
UNION ALL SELECT 'UMP18B-W' AS item
UNION ALL SELECT 'UMP18MP-W' AS item
UNION ALL SELECT 'UMP18GMP-W' AS item
UNION ALL SELECT 'UMP18B-SAT' AS item
UNION ALL SELECT 'UMP18MP-SAT' AS item
UNION ALL SELECT 'UMP18GMP-SAT' AS item
UNION ALL SELECT 'UMP19B-SAT' AS item
UNION ALL SELECT 'UMP-Conversion' AS item
UNION ALL SELECT 'Warehouse' AS item
UNION ALL SELECT 'Admin' AS item







--去重项目编号
IF OBJECT_ID('tempdb.dbo.#t4') IS NOT NULL DROP TABLE #t4
SELECT DISTINCT item as item INTO #t4 
FROM #p4



INSERT INTO homsomDB..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID,VettingTemplateID,NeedHotelVetting,HotelVettingTemplateID,NeedTrainVetting,TrainVettingTemplateID)
select NEWID() as id,GETDATE() as ver,GETDATE() as ModifyDate,'homsom' as ModifyBy,'homsom' as CreateBy,GETDATE() as CreateDate,item as code,0,'','12CD09E1-095C-4B40-81E9-A506009CE2AD',NULL,0,NULL,0,NULL
FROM #t4 t4
where t4.item not in (SELECT Code FROM homsomDB..Trv_Customizations WHERE UnitCompanyID='12CD09E1-095C-4B40-81E9-A506009CE2AD')

delete
--SELECT * 
FROM homsomDB..Trv_Customizations WHERE UnitCompanyID='12CD09E1-095C-4B40-81E9-A506009CE2AD'

SELECT * FROM homsomDB..Trv_Customizations WHERE UnitCompanyID='12CD09E1-095C-4B40-81E9-A506009CE2AD'