SELECT * FROM homsomdb..Trv_UnitCompanies WHERE Cmpid='019333'  ----12CD09E1-095C-4B40-81E9-A506009CE2AD

IF OBJECT_ID('tempdb.dbo.#p') IS NOT NULL DROP TABLE #p
CREATE TABLE #P(dep varchar(100)) 

INSERT INTO #P(dep)

--="UNION ALL SELECT '" &B1&"' AS depname"
SELECT 'TDA-SH����ǿ��' AS depname
UNION ALL SELECT 'QMPP3-SH��÷����' AS depname
UNION ALL SELECT 'IEIA-SH(������)' AS depname
UNION ALL SELECT 'IESP-SH�������ۣ�' AS depname
UNION ALL SELECT 'IEIE-SH����������' AS depname
UNION ALL SELECT 'TSP-SH����������' AS depname
UNION ALL SELECT 'CH-SH�����ƣ�' AS depname
UNION ALL SELECT 'CH-SH�ܼࣨ���ƣ�' AS depname
UNION ALL SELECT 'HRB-SH�����ƣ�' AS depname
UNION ALL SELECT 'FM-SH�����ƣ�' AS depname
UNION ALL SELECT 'TSP-SH����ǿ��' AS depname
UNION ALL SELECT 'TDM2-SH����ǿ��' AS depname
UNION ALL SELECT 'SPD2-SH����ǿ��' AS depname
UNION ALL SELECT 'TDE-SH����ǿ��' AS depname
UNION ALL SELECT 'IEIS-SH�������ۣ�' AS depname
UNION ALL SELECT 'QMPP4-SH��÷����' AS depname
UNION ALL SELECT 'QMI-SH��÷����' AS depname
UNION ALL SELECT 'QMM-SH��÷����' AS depname
UNION ALL SELECT 'AQ-SH�ܼࣨ���ƣ�' AS depname
UNION ALL SELECT 'LO-SH�ܼࣨ���ƣ�' AS depname
UNION ALL SELECT 'OPD2-SH�������ۣ�' AS depname
UNION ALL SELECT 'LOT-SH��Ҷ�ࣩ' AS depname
UNION ALL SELECT 'OP-SH�����ƣ�' AS depname
UNION ALL SELECT 'SO-SH�������ۣ�' AS depname
UNION ALL SELECT 'TAS1-SH����������' AS depname
UNION ALL SELECT 'TST-SH����������' AS depname
UNION ALL SELECT 'TSL-SH����������' AS depname
UNION ALL SELECT 'SPD-SH����������' AS depname
UNION ALL SELECT 'PUN-SH (�����' AS depname
UNION ALL SELECT 'TDM21-SH����ǿ��' AS depname
UNION ALL SELECT '����������' AS depname
UNION ALL SELECT '����ؿ��أ��Ϻ������޹�˾' AS depname
UNION ALL SELECT 'TS-SH�ܼࣨ���ƣ�' AS depname
UNION ALL SELECT 'PUP-SH�������' AS depname
UNION ALL SELECT 'PUN2-SH�������' AS depname
UNION ALL SELECT 'PUA-SH(�����' AS depname
UNION ALL SELECT 'QMPS-SH��÷����' AS depname
UNION ALL SELECT 'IT-SH�����ƣ�' AS depname
UNION ALL SELECT 'HRP-SH�����ƣ�' AS depname
UNION ALL SELECT 'OP1-SH����ǿ��' AS depname
UNION ALL SELECT 'SOLP-SH�������ۣ�' AS depname
UNION ALL SELECT 'FI-SH�����ƣ�' AS depname
UNION ALL SELECT 'TDM1-SH����ǿ��' AS depname
UNION ALL SELECT 'QMOC3-SH��÷����' AS depname
UNION ALL SELECT 'AP5S-SH������' AS depname
UNION ALL SELECT '����������' AS depname
UNION ALL SELECT 'SPH-SH����������' AS depname
UNION ALL SELECT 'OPQ1-SH�������ۣ�' AS depname
UNION ALL SELECT 'TA-SH�����ƣ�' AS depname
UNION ALL SELECT 'OPP-SH�������ۣ�' AS depname
UNION ALL SELECT 'TDE1-SH����ǿ��' AS depname
UNION ALL SELECT 'TDS2-SH����ǿ��' AS depname
UNION ALL SELECT 'TDS2-SH�����ƣ�' AS depname
UNION ALL SELECT 'GM-SH�����ƣ�' AS depname
UNION ALL SELECT 'IEIA-SH����������' AS depname
UNION ALL SELECT 'IEIE-SH��������)' AS depname
UNION ALL SELECT 'TAL-SH����������' AS depname
UNION ALL SELECT 'TAL1-SH����������' AS depname
UNION ALL SELECT 'TDM1-SH�������ۣ�' AS depname
UNION ALL SELECT 'TSH-SH����������' AS depname
UNION ALL SELECT 'TDS1-SH�����ƣ�' AS depname
UNION ALL SELECT '������÷��' AS depname
UNION ALL SELECT 'TAL2-SH������' AS depname
UNION ALL SELECT 'CP-SH-÷������' AS depname
UNION ALL SELECT 'TDC-SH����ǿ��' AS depname
UNION ALL SELECT 'QMOC-SH��÷����' AS depname
UNION ALL SELECT 'TAS2-SH����������' AS depname
UNION ALL SELECT 'TDS1-SH��������' AS depname
UNION ALL SELECT 'TD-SH(�ܼ�)' AS depname
UNION ALL SELECT 'QMPP5-SH��÷����' AS depname
UNION ALL SELECT 'TD-SH����ǿ��' AS depname
UNION ALL SELECT 'TES-SH����ǿ��' AS depname
UNION ALL SELECT 'PU(����)' AS depname
UNION ALL SELECT 'TET1-SH����ǿ��' AS depname
UNION ALL SELECT 'PR-SH�����ƣ�' AS depname
UNION ALL SELECT 'AP5L-SH' AS depname
UNION ALL SELECT 'TDM1-SH�����ƣ�' AS depname
UNION ALL SELECT 'OP2-SH�������ۣ�' AS depname
UNION ALL SELECT 'SOP-SH�������ۣ�' AS depname
UNION ALL SELECT 'Sales and Program Management, Automotive����������' AS depname
UNION ALL SELECT 'TDS1-SH����ǿ��' AS depname
UNION ALL SELECT 'LO-SH��Ҷ�ࣩ' AS depname
UNION ALL SELECT 'Engineering����ǿ��' AS depname
UNION ALL SELECT 'PUN1-SH�������' AS depname
UNION ALL SELECT 'TDS-SH����ǿ��' AS depname
UNION ALL SELECT 'TAL1-SH������' AS depname
UNION ALL SELECT 'Purchasing(������)' AS depname
UNION ALL SELECT 'IET-SH�������ۣ�' AS depname
UNION ALL SELECT 'OPS2-SH�������ۣ�' AS depname
UNION ALL SELECT 'APDX-SH����ǿ��' AS depname
UNION ALL SELECT 'LOD(��Т)' AS depname
UNION ALL SELECT 'LO-SH����Т��' AS depname
UNION ALL SELECT 'TET-SH����ǿ��' AS depname
UNION ALL SELECT 'TAL-SH������' AS depname





select * from  #p



--ȥ�ز���
IF OBJECT_ID('tempdb.dbo.#t') IS NOT NULL DROP TABLE #t
SELECT DISTINCT dep as depname INTO #t 
FROM #p

--��˾ID
SELECT * FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='017888'
--���벿��
INSERT INTO homsomDB..Trv_CompanyStructure(ID,Ver,DepName,Code,Remarks,CreateDate,CreateBy,CompanyId,ParentID,IsBranch)
SELECT  NEWID()AS ID,GETDATE()AS ver,depName AS DepName,depName AS Code,'' AS Remarks,GETDATE() AS CreateDate,'Herry' AS CreateBy,'12CD09E1-095C-4B40-81E9-A506009CE2AD' AS CompanyId,NULL AS ParentID,0 AS IsBranch
FROM #t


--�����Ա�������Ƿ�����
SELECT up.ID, h.Name,t2.*--,dep.DepName,
FROM homsomDB..Trv_UnitPersons up
INNER JOIN homsomDB..Trv_Human h ON up.ID=h.ID AND up.CompanyID='12CD09E1-095C-4B40-81E9-A506009CE2AD' AND h.IsDisplay=1
RIGHT JOIN #t t2 ON  h.Name=t2.empName
WHERE h.ID IS NULL

--����
UPDATE homsomDB..Trv_UnitPersons SET CompanyDptId=dep.ID
--SELECT up.ID, h.Name,t2.*,dep.DepName,dep.id
FROM homsomDB..Trv_UnitPersons up
INNER JOIN homsomDB..Trv_Human h ON up.ID=h.ID AND up.CompanyID='12CD09E1-095C-4B40-81E9-A506009CE2AD' AND h.IsDisplay=1
INNER JOIN #t t2 ON  h.Name=t2.empName
INNER JOIN homsomDB..Trv_CompanyStructure dep ON dep.CompanyId='12CD09E1-095C-4B40-81E9-A506009CE2AD' AND t2.depName=dep.DepName

select * from #t

--�ɱ�����
SELECT * FROM homsomDB..Trv_CostCenter WHERE CompanyId='12CD09E1-095C-4B40-81E9-A506009CE2AD'

IF OBJECT_ID('tempdb.dbo.#p2') IS NOT NULL DROP TABLE #p2
CREATE TABLE #P2(costcenter varchar(100)) 

INSERT INTO #P2(costcenter)

--="UNION ALL SELECT '" &B1&"' AS costcenter"
SELECT '�����ǽ�' AS costcenter
UNION ALL SELECT '̩��������԰' AS costcenter
UNION ALL SELECT '��Ҧ����' AS costcenter
UNION ALL SELECT '�����к�' AS costcenter
UNION ALL SELECT '�Ͼ�����' AS costcenter
UNION ALL SELECT '��������' AS costcenter
UNION ALL SELECT '���ѧϰ' AS costcenter
UNION ALL SELECT '�����ǽ�' AS costcenter
UNION ALL SELECT '���ϲ���' AS costcenter
UNION ALL SELECT '�󰮳���Ŀ' AS costcenter
UNION ALL SELECT '�����ı�׼�����' AS costcenter
UNION ALL SELECT '������ҩ��' AS costcenter
UNION ALL SELECT '��˾Ӫ��' AS costcenter
UNION ALL SELECT '����к�' AS costcenter
UNION ALL SELECT '��������С�Ͻ�' AS costcenter
UNION ALL SELECT '����һ����Ŀ' AS costcenter
UNION ALL SELECT '�����ž���Ŀ' AS costcenter
UNION ALL SELECT '�ǽ�������Ҷ��ɽ' AS costcenter
UNION ALL SELECT '����̩��' AS costcenter
UNION ALL SELECT '��԰' AS costcenter
UNION ALL SELECT '��������' AS costcenter
UNION ALL SELECT '����к���ʾ��Ŀ' AS costcenter
UNION ALL SELECT '�󰮳���Ŀ ' AS costcenter
UNION ALL SELECT '�����ǽ�' AS costcenter
UNION ALL SELECT '����ҽԺ' AS costcenter
UNION ALL SELECT '�󰮳���Ŀ ' AS costcenter
UNION ALL SELECT '����Χ��' AS costcenter
UNION ALL SELECT '�к�����' AS costcenter
UNION ALL SELECT '�����ǽ�' AS costcenter


--ȥ�سɱ�����
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
SELECT '��ǰ' AS BU
UNION ALL SELECT '��ǰ' AS BU
UNION ALL SELECT '��ǰ' AS BU
UNION ALL SELECT '��ǰ' AS BU
UNION ALL SELECT '��ǰ' AS BU
UNION ALL SELECT '��ǰ' AS BU
UNION ALL SELECT '��ǰ' AS BU
UNION ALL SELECT '��ǰ' AS BU


--ȥ��BU
IF OBJECT_ID('tempdb.dbo.#t3') IS NOT NULL DROP TABLE #t3
SELECT DISTINCT BU as BU INTO #t3 
FROM #p3

INSERT INTO homsomDB..Trv_CompanyUndercover(ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId)
select NEWID() as id,GETDATE()AS ver,bu as UnderName,GETDATE() as CreateDate,'homsom' as CreateBy,GETDATE() as modifydate,'homsom' as ModifyBy,'12CD09E1-095C-4B40-81E9-A506009CE2AD' as CompanyId
FROM #t3 t3
where t3.BU not in (SELECT UnderName FROM homsomDB..Trv_CompanyUndercover WHERE CompanyId='12CD09E1-095C-4B40-81E9-A506009CE2AD')


--��Ŀ���
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







--ȥ����Ŀ���
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