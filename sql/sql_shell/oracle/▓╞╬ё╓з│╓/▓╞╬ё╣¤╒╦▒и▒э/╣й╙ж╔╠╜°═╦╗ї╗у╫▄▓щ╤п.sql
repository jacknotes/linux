<VERSION>4.1.1</VERSION>
<SQLQUERY>
<REMARK>
[����]

[Ӧ�ñ���]

[���������]
��Ӫ������˰��� ȡ״̬Ϊ ���ջ�  �ջ���嵥(����) �ջ���������(����) ��ɺ�嵥(����) 
��ɺ�������(����)
��Ӫ�����˻���˰��� ȡ״̬Ϊ �ѷ���  ����������(����) ������������(����) ��ɺ�嵥(��
��) ��ɺ�������(����)

[��Ҫ�Ĳ�ѯ����]

[ʵ�ַ���]

[����]
</REMARK>
<BEFORERUN>
declare 
  Bfiledate date;
  Efiledate date;
  VFLAG VARCHAR2(10);
  
begin
  Bfiledate := to_date('\(1,1)');
  Efiledate := to_date('\(2,1)');
  VFLAG :=  TRIM('\(3,1)');
  
delete from tmp_test2;
  commit;  

IF VFLAG = '����������' THEN    --����������
    BEGIN
--Ʒ���ֶ���20170602�����
insert into tmp_test2
(
       char1      --��Ӧ�̴���
      ,char2      --��Ӧ������
      ,num1       --��Ӫ������˰���
      ,num2       --��Ӫ����˰��
      ,num3       --ֱ�������˰���
      ,num4       --ֱ�����˰��
      ,num5       --��Ӫ�����˻���˰���
      ,num6       --��Ӫ�����˻�˰��
      ,num7       --ֱ������˻���˰���
      ,num8       --ֱ������˻�˰��
      ,num9       --�����۽��
      ,date1      --��ʼ����
      ,date2      --��������
      ,char3      --��������
      ,char4      --Ʒ�����
      ,char5      --Ʒ��
      ,char6      --Ʒ��
)
select code                   --��Ӧ�̴���
      ,name                   --��Ӧ������
      ,sum(STKINTOTAL)        --��Ӫ������˰���
      ,sum(STKINTAX)          --��Ӫ����˰��
      ,sum(DirAlcTOTAL)       --ֱ�������˰���
      ,sum(DirAlcTAX)         --ֱ�����˰��
      ,sum(STKINBCKTOTAL)     --��Ӫ�����˻���˰���
      ,sum(STKINBCKTAX)       --��Ӫ�����˻�˰��
      ,sum(DirAlcTOTALth)     --ֱ������˻���˰���
      ,sum(DirAlcTAXth)       --ֱ������˻�˰��
      ,sum(adjamt)            --�����۽��
      ,Bfiledate              --��ʼ����
      ,Efiledate              --��������
      ,VFLAG                  --��������
      ,ascode                 --Ʒ�����
      ,asname                 --Ʒ��
      ,BRAND                  --Ʒ��       
from
(
--��Ӫ��������״̬ѡȡ�����ջ�  �ջ���嵥(����) �ջ���������(����) ��ɺ�嵥(����) ��ɺ�������(����) ��
SELECT  VENDORH.CODE                     --��Ӧ�̴���
       ,VENDORH.NAME                     --��Ӧ������
       ,WAREHOUSE.CODE WRHCODE           --�ֺ�
       ,WAREHOUSE.NAME WRHNAME           --�ֿ�����
       ,sum(Stkindtl.TOTAL) STKINTOTAL      --��˰���
       ,sum(Stkindtl.TAX) STKINTAX          --˰��
       ,0 DirAlcTOTAL                    
       ,0 DirAlcTAX
       ,0 STKINBCKTOTAL
       ,0 STKINBCKTAX
       ,0 DirAlcTOTALth
       ,0 DirAlcTAXth
       ,0 adjamt
       ,trunc(STKIN.Ocrdate)        --��������
       ,MODULESTAT.Statname         --״̬
       ,h4v_goodssort.ascode
       ,h4v_goodssort.asname
       ,BRAND
  FROM STKIN, VENDORH, WAREHOUSE, MODULESTAT, STKINLOG ,Stkindtl ,h4v_goodssort,goods 
 WHERE STKIN.WRH = WAREHOUSE.GID(+)
   AND STKIN.CLS = '��Ӫ��'
   AND STKIN.VENDOR = VENDORH.GID
   and Stkindtl.Gdgid=goods.gid
   and STKIN.Stat = MODULESTAT.No
   and STKIN.Num = STKINLOG.Num
   and STKIN.Cls = STKINLOG.Cls
   and STKINLOG.Stat in (1000,1020,1040,320,340)  --���ջ�  �ջ���嵥(����) �ջ���������(����) ��ɺ�嵥(����) ��ɺ�������(����)
   and trunc(STKIN.Ocrdate) between date'2017-05-01' and date'2017-05-31'
   and stkin.cls = Stkindtl.Cls
   and stkin.num = Stkindtl.Num
   and Stkindtl.Gdgid = h4v_goodssort.gid
  group by VENDORH.CODE                
          ,VENDORH.NAME                
          ,WAREHOUSE.CODE       
          ,WAREHOUSE.NAME 
          ,trunc(STKIN.Ocrdate)
          ,MODULESTAT.Statname 
          ,h4v_goodssort.ascode
          ,h4v_goodssort.asname
          ,BRAND
          
union all
                   
--ֱ�������
select  VendorH.CODE                --��Ӧ�̴���
       ,VendorH.NAME                --��Ӧ������
       ,WarehouseH.CODE WRHCODE     --�ֺ�
       ,WarehouseH.NAME WRHNAME     --�ֿ�����
       ,0 STKINTOTAL
       ,0 STKINTAX
       ,sum(Diralcdtl.TOTAL) DirAlcTOTAL          --��˰���
       ,sum(Diralcdtl.TAX) DirAlcTAX            --˰��
       ,0 STKINBCKTOTAL
       ,0 STKINBCKTAX
       ,0 DirAlcTOTALth
       ,0 DirAlcTAXth
       ,0 adjamt
       ,trunc(DirAlc.Ocrdate)       --��������
       ,MODULESTAT.Statname         --״̬
       ,h4v_goodssort.ascode
       ,h4v_goodssort.asname
       ,BRAND                  --Ʒ��     
from DirAlc , VendorH , WarehouseH , ModuleStat, DirAlcLog ,Diralcdtl ,h4v_goodssort,goods

where DirAlc.Vendor = VendorH.Gid
  and DirAlc.Wrh = WarehouseH.Gid(+)
  and DirAlc.Stat = ModuleStat.No
  and DirAlc.Cls ='ֱ���'
  and DirAlc.Num = DirAlcLog.Num
  and DirAlc.Cls = DirAlcLog.Cls
  and DirAlcLog.Stat in (1000,1020,1040,320,340)
  and trunc(DirAlc.Ocrdate) between Bfiledate and Efiledate
  and DirAlc.Cls = Diralcdtl.Cls
  and DirAlc.Num = Diralcdtl.Num
  and Diralcdtl.Gdgid= h4v_goodssort.gid
  and Diralcdtl.Gdgid=goods.gid
group by  VendorH.CODE                
         ,VendorH.NAME                
         ,WarehouseH.CODE      
         ,WarehouseH.NAME   
         ,trunc(DirAlc.Ocrdate)               
         ,MODULESTAT.Statname 
         ,h4v_goodssort.ascode
         ,h4v_goodssort.asname 
         ,BRAND
union all         
         
--��Ӫ�����˻���� ��״̬ѡȡ���ѷ���  ����������(����) ������������(����) ��ɺ�嵥(����) ��ɺ�������(����)��
select  VendorH.CODE                 --��Ӧ�̴���
       ,VendorH.NAME                 --��Ӧ������
       ,WarehouseH.CODE WRHCODE      --�ֺ�
       ,WarehouseH.NAME WRHNAME      --�ֿ�����
       ,0 STKINTOTAL
       ,0 STKINTAX
       ,0 DirAlcTOTAL
       ,0 DirAlcTAX
       ,sum(Stkinbckdtl.TOTAL) STKINBCKTOTAL        --��˰���
       ,sum(Stkinbckdtl.TAX) STKINBCKTAX            --˰��
       ,0 DirAlcTOTALth
       ,0 DirAlcTAXth
       ,0 adjamt
       ,trunc(STKINBCK.Ocrdate)      --��������
       ,MODULESTAT.Statname          --״̬
       ,h4v_goodssort.ascode
       ,h4v_goodssort.asname
       ,BRAND                  --Ʒ��    
from STKINBCK , VendorH , WarehouseH , ModuleStat ,STKINBCKLOG ,Stkinbckdtl ,h4v_goodssort,goods 

where STKINBCK.Vendor = VendorH.Gid
  and STKINBCK.Wrh = WarehouseH.Gid(+)
  and STKINBCK.Stat = ModuleStat.No
  and STKINBCK.Cls = '��Ӫ����'
  and STKINBCK.Num = STKINBCKLOG.Num
  and STKINBCK.Cls = STKINBCKLOG.Cls
  and STKINBCKLOG.Stat in (700,720,740,320 ,340) --�ѷ���  ����������(����) ������������(����) ��ɺ�嵥(����) ��ɺ�������(����)
  and trunc(STKINBCK.Ocrdate) between Bfiledate and Efiledate
  and STKINBCK.Cls = Stkinbckdtl.Cls
  and Stkinbck.Num = Stkinbckdtl.Num
  and Stkinbckdtl.Gdgid = h4v_goodssort.gid
  and Stkinbckdtl.Gdgid = goods.gid
group by  VendorH.CODE                
         ,VendorH.NAME                
         ,WarehouseH.CODE       
         ,WarehouseH.NAME   
         ,trunc(STKINBCK.Ocrdate)               
         ,MODULESTAT.Statname  
         ,h4v_goodssort.ascode
         ,h4v_goodssort.asname
         ,BRAND 
 union all       

--ֱ���˻����         
select  VendorH.CODE                --��Ӧ�̴���
       ,VendorH.NAME                --��Ӧ������
       ,WarehouseH.CODE WRHCODE     --�ֺ�
       ,WarehouseH.NAME WRHNAME     --�ֿ�����
       ,0 STKINTOTAL
       ,0 STKINTAX
       ,0 DirAlcTOTAL
       ,0 DirAlcTAX
       ,0 STKINBCKTOTAL
       ,0 STKINBCKTAX
       ,sum(Diralcdtl.TOTAL) DirAlcTOTALth          --��˰���
       ,sum(Diralcdtl.TAX) DirAlcTAXth            --˰��
       ,0 adjamt
       ,trunc(DirAlc.Ocrdate)              --��������
       ,MODULESTAT.Statname         --״̬
       ,h4v_goodssort.ascode
       ,h4v_goodssort.asname
       ,BRAND 
from DirAlc , VendorH , WarehouseH , ModuleStat, DirAlcLog ,Diralcdtl ,h4v_goodssort,goods

where DirAlc.Vendor = VendorH.Gid
  and DirAlc.Wrh = WarehouseH.Gid(+)
  and DirAlc.Stat = ModuleStat.No
  and DirAlc.Cls ='ֱ�����'
  and DirAlc.Num = DirAlcLog.Num
  and DirAlc.Cls = DirAlcLog.Cls
  and DirAlcLog.Stat in (700,720,740,320,340)
  and trunc(DirAlc.Ocrdate) between Bfiledate and Efiledate
  and DirAlc.Cls = DirAlcdtl.Cls
  and DirAlc.Num = DirAlcdtl.Num
  and DirAlcdtl.Gdgid = h4v_goodssort.gid
  and DirAlcdtl.Gdgid = goods.gid
group by  VendorH.CODE                
         ,VendorH.NAME                
         ,WarehouseH.CODE      
         ,WarehouseH.NAME   
         ,trunc(DirAlc.Ocrdate)               
         ,MODULESTAT.Statname 
         ,h4v_goodssort.ascode
         ,h4v_goodssort.asname
         ,BRAND 
         
union all

--���۵������

select VENDOR.Code
      ,VENDOR.Name
      ,WAREHOUSE.Code
      ,WAREHOUSE.Name 
      ,0 STKINTOTAL
      ,0 STKINTAX
      ,0 DirAlcTOTAL
      ,0 DirAlcTAX
      ,0 STKINBCKTOTAL
      ,0 STKINBCKTAX
      ,0 DirAlcTOTALth         
      ,0 DirAlcTAXth   
      ,sum(INVPRCADJBYGDDTL.Adjamt+INVPRCADJBYGDDTL.Adjtax) adjamt
      ,trunc(INVPRCADJBYGD.Ocrdate)
      ,ModuleStat.Statname
      ,h4v_goodssort.ascode
      ,h4v_goodssort.asname
      ,BRAND 
 from INVPRCADJBYGD ,INVPRCADJBYGDDTL ,VENDOR , WAREHOUSE ,ModuleStat, INVPRCADJBYGDLOG ,h4v_goodssort,goods
where INVPRCADJBYGD.Num = INVPRCADJBYGDDTL.Num
  and INVPRCADJBYGD.cls = INVPRCADJBYGDDTL.Cls
  and trunc(INVPRCADJBYGD.Ocrdate) between Bfiledate and Efiledate
  and INVPRCADJBYGD.Vendor = VENDOR.Gid
  and INVPRCADJBYGDDTL.Wrh = WAREHOUSE.Gid
  and WAREHOUSE.Gid <>1    --�ֿ�����δ֪
  and INVPRCADJBYGD.Stat = ModuleStat.No
  and INVPRCADJBYGD.Num = INVPRCADJBYGDLOG.Num
  and INVPRCADJBYGD.Cls = INVPRCADJBYGDLOG.Cls
  and INVPRCADJBYGDLOG.Stat = 100   --�����
  and INVPRCADJBYGD.Gdgid = h4v_goodssort.gid
  and INVPRCADJBYGD.Gdgid = goods.gid
  group by VENDOR.Code 
          ,VENDOR.Name
          ,WAREHOUSE.Code
          ,WAREHOUSE.Name 
          ,trunc(INVPRCADJBYGD.Ocrdate)
          ,ModuleStat.Statname
          ,h4v_goodssort.ascode
          ,h4v_goodssort.asname
          ,BRAND
         ) 
         group by code ,name ,ascode ,asname,BRAND 
         order by code ;
         
         
         
         

END;  --*********************************************** �ָ���  ****************************************************************         
    ELSE
       BEGIN   --����������  ȡlog����

insert into tmp_test2
(
       char1      --��Ӧ�̴���
      ,char2      --��Ӧ������
      ,num1       --��Ӫ������˰���
      ,num2       --��Ӫ����˰��
      ,num3       --ֱ�������˰���
      ,num4       --ֱ�����˰��
      ,num5       --��Ӫ�����˻���˰���
      ,num6       --��Ӫ�����˻�˰��
      ,num7       --ֱ������˻���˰���
      ,num8       --ֱ������˻�˰��
      ,num9       --�����۽��
      ,date1      --��ʼ����
      ,date2      --��������
      ,char3      --��������
      ,char4      --Ʒ�����
      ,char5      --Ʒ��
      ,char6      --Ʒ��
)
select code
      ,name
      ,sum(STKINTOTAL)
      ,sum(STKINTAX)
      ,sum(DirAlcTOTAL)
      ,sum(DirAlcTAX)
      ,sum(STKINBCKTOTAL)
      ,sum(STKINBCKTAX)
      ,sum(DirAlcTOTALth)
      ,sum(DirAlcTAXth)
      ,sum(adjamt)
      ,Bfiledate
      ,Efiledate
      ,VFLAG
      ,ascode
      ,asname
      ,BRAND        
from
(
--��Ӫ������
SELECT  VENDORH.CODE                     --��Ӧ�̴���
       ,VENDORH.NAME                     --��Ӧ������
       ,WAREHOUSE.CODE WRHCODE           --�ֺ�
       ,WAREHOUSE.NAME WRHNAME           --�ֿ�����
       ,sum(Stkindtl.TOTAL) STKINTOTAL      --��˰���
       ,sum(Stkindtl.TAX) STKINTAX          --˰��
       ,0 DirAlcTOTAL                    
       ,0 DirAlcTAX
       ,0 STKINBCKTOTAL
       ,0 STKINBCKTAX
       ,0 DirAlcTOTALth
       ,0 DirAlcTAXth
       ,0 adjamt
       ,trunc(STKINLOG.Time)        --��������
       ,MODULESTAT.Statname         --״̬
       ,h4v_goodssort.ascode
       ,h4v_goodssort.asname
       ,BRAND
  FROM STKIN, VENDORH, WAREHOUSE, MODULESTAT, STKINLOG ,Stkindtl ,h4v_goodssort,goods
 WHERE STKIN.WRH = WAREHOUSE.GID(+)
   AND STKIN.CLS = '��Ӫ��'
   AND STKIN.VENDOR = VENDORH.GID
   and STKIN.Stat = MODULESTAT.No
   and stkin.num = STKINLOG.Num
   and stkin.cls = STKINLOG.Cls
   and trunc(STKINLOG.Time) between Bfiledate and Efiledate
   and STKINLOG.Stat in (1000,1020,1040,320,340)
   and stkin.cls = Stkindtl.Cls
   and stkin.num = Stkindtl.Num
   and Stkindtl.Gdgid = h4v_goodssort.gid
   and Stkindtl.Gdgid = goods.gid
  group by VENDORH.CODE                
          ,VENDORH.NAME                
          ,WAREHOUSE.CODE       
          ,WAREHOUSE.NAME 
          ,trunc(STKINLOG.Time)
          ,MODULESTAT.Statname 
          ,h4v_goodssort.ascode
          ,h4v_goodssort.asname
          ,BRAND
union all
                   
--ֱ�������
select  VendorH.CODE                --��Ӧ�̴���
       ,VendorH.NAME                --��Ӧ������
       ,WarehouseH.CODE WRHCODE     --�ֺ�
       ,WarehouseH.NAME WRHNAME     --�ֿ�����
       ,0 STKINTOTAL
       ,0 STKINTAX
       ,sum(Diralcdtl.TOTAL) DirAlcTOTAL          --��˰���
       ,sum(Diralcdtl.TAX) DirAlcTAX            --˰��
       ,0 STKINBCKTOTAL
       ,0 STKINBCKTAX
       ,0 DirAlcTOTALth
       ,0 DirAlcTAXth
       ,0 adjamt
       ,trunc(DirAlcLog.Time)       --��������
       ,MODULESTAT.Statname         --״̬
       ,h4v_goodssort.ascode
       ,h4v_goodssort.asname
       ,BRAND
from DirAlc , VendorH , WarehouseH , ModuleStat ,DirAlcLog ,Diralcdtl ,h4v_goodssort,goods

where DirAlc.Vendor = VendorH.Gid
  and DirAlc.Wrh = WarehouseH.Gid(+)
  and DirAlc.Stat = ModuleStat.No
  and DirAlc.Cls ='ֱ���'
  and DirAlc.Num = DirAlcLog.Num
  and DirAlc.Cls = DirAlcLog.Cls
  and trunc(DirAlcLog.Time) between Bfiledate and Efiledate
  and DirAlcLog.stat in (1000,1020,1040,320,340)
  and DirAlc.Cls = Diralcdtl.Cls
  and DirAlc.Num = Diralcdtl.Num
  and Diralcdtl.Gdgid = h4v_goodssort.gid
  and Diralcdtl.Gdgid = goods.gid
group by  VendorH.CODE                
         ,VendorH.NAME                
         ,WarehouseH.CODE      
         ,WarehouseH.NAME   
         ,trunc(DirAlcLog.Time)            
         ,MODULESTAT.Statname 
         ,h4v_goodssort.ascode
         ,h4v_goodssort.asname 
         ,BRAND
union all         
         
--��Ӫ�����˻����
select  VendorH.CODE                 --��Ӧ�̴���
       ,VendorH.NAME                 --��Ӧ������
       ,WarehouseH.CODE WRHCODE      --�ֺ�
       ,WarehouseH.NAME WRHNAME      --�ֿ�����
       ,0 STKINTOTAL
       ,0 STKINTAX
       ,0 DirAlcTOTAL
       ,0 DirAlcTAX
       ,sum(Stkinbckdtl.TOTAL) STKINBCKTOTAL        --��˰���
       ,sum(Stkinbckdtl.TAX) STKINBCKTAX            --˰��
       ,0 DirAlcTOTALth
       ,0 DirAlcTAXth
       ,0 adjamt
       ,trunc(STKINBCKLOG.Time)      --��������
       ,MODULESTAT.Statname          --״̬
       ,h4v_goodssort.ascode
       ,h4v_goodssort.asname
       ,BRAND
from STKINBCK , VendorH , WarehouseH , ModuleStat , STKINBCKLOG ,Stkinbckdtl ,h4v_goodssort,goods

where STKINBCK.Vendor = VendorH.Gid
  and STKINBCK.Wrh = WarehouseH.Gid(+)
  and STKINBCK.Stat = ModuleStat.No
  and STKINBCK.Cls = '��Ӫ����'
  and STKINBCK.Num = STKINBCKLOG.Num
  and STKINBCK.Cls = STKINBCKLOG.Cls
  and trunc(STKINBCKLOG.Time) between Bfiledate and Efiledate
  and STKINBCKLOG.stat in (700,720,740,320,340)
  and STKINBCK.Cls = Stkinbckdtl.Cls
  and Stkinbck.Num = Stkinbckdtl.Num
  and Stkinbckdtl.Gdgid = h4v_goodssort.gid
  and Stkinbckdtl.Gdgid = goods.gid
group by  VendorH.CODE                
         ,VendorH.NAME                
         ,WarehouseH.CODE       
         ,WarehouseH.NAME   
         ,trunc(STKINBCKLOG.Time)             
         ,MODULESTAT.Statname
         ,h4v_goodssort.ascode
         ,h4v_goodssort.asname  
         ,BRAND
 union all       

--ֱ���˻����         
select  VendorH.CODE                --��Ӧ�̴���
       ,VendorH.NAME                --��Ӧ������
       ,WarehouseH.CODE WRHCODE     --�ֺ�
       ,WarehouseH.NAME WRHNAME     --�ֿ�����
       ,0 STKINTOTAL
       ,0 STKINTAX
       ,0 DirAlcTOTAL
       ,0 DirAlcTAX
       ,0 STKINBCKTOTAL
       ,0 STKINBCKTAX
       ,sum(Diralcdtl.TOTAL) DirAlcTOTALth          --��˰���
       ,sum(Diralcdtl.TAX) DirAlcTAXth            --˰��
       ,0 adjamt
       ,trunc(DirAlcLog.Time)       --��������
       ,MODULESTAT.Statname         --״̬
       ,h4v_goodssort.ascode
       ,h4v_goodssort.asname
       ,BRAND
from DirAlc , VendorH , WarehouseH , ModuleStat , DirAlcLog ,Diralcdtl ,h4v_goodssort,goods

where DirAlc.Vendor = VendorH.Gid
  and DirAlc.Wrh = WarehouseH.Gid(+)
  and DirAlc.Stat = ModuleStat.No
  and DirAlc.Cls ='ֱ�����'
  and DirAlc.Num = DirAlcLog.Num
  and DirAlc.Cls = DirAlcLog.Cls
  and trunc(DirAlcLog.Time) between Bfiledate and Efiledate
  and DirAlcLog.Stat in (700,720,740,320,340)
  and DirAlc.Cls = DirAlcdtl.Cls
  and DirAlc.Num = DirAlcdtl.Num
  and DirAlcdtl.Gdgid = h4v_goodssort.gid
  and DirAlcdtl.Gdgid = goods.gid
group by  VendorH.CODE                
         ,VendorH.NAME                
         ,WarehouseH.CODE      
         ,WarehouseH.NAME   
         ,trunc(DirAlcLog.Time)              
         ,MODULESTAT.Statname 
         ,h4v_goodssort.ascode
         ,h4v_goodssort.asname
         ,BRAND
         
union all

--���۵������

select VENDOR.Code
      ,VENDOR.Name
      ,WAREHOUSE.Code
      ,WAREHOUSE.Name 
      ,0 STKINTOTAL
      ,0 STKINTAX
      ,0 DirAlcTOTAL
      ,0 DirAlcTAX
      ,0 STKINBCKTOTAL
      ,0 STKINBCKTAX
      ,0 DirAlcTOTALth         
      ,0 DirAlcTAXth   
      ,sum(INVPRCADJBYGDDTL.Adjamt+INVPRCADJBYGDDTL.Adjtax) adjamt
      ,trunc(INVPRCADJBYGDLOG.Time)
      ,ModuleStat.Statname
      ,h4v_goodssort.ascode
      ,h4v_goodssort.asname
      ,BRAND
 from INVPRCADJBYGD ,INVPRCADJBYGDDTL ,VENDOR , WAREHOUSE ,ModuleStat , INVPRCADJBYGDLOG ,h4v_goodssort,goods
where INVPRCADJBYGD.Num = INVPRCADJBYGDDTL.Num
  and INVPRCADJBYGD.cls = INVPRCADJBYGDDTL.Cls
  and INVPRCADJBYGD.Vendor = VENDOR.Gid
  and INVPRCADJBYGDDTL.Wrh = WAREHOUSE.Gid
  and INVPRCADJBYGD.Num = INVPRCADJBYGDLOG.Num
  and INVPRCADJBYGD.Cls = INVPRCADJBYGDLOG.Cls
  and INVPRCADJBYGDLOG.Stat = 100   --�����
  and INVPRCADJBYGD.Gdgid = h4v_goodssort.gid
  and INVPRCADJBYGD.Gdgid = goods.gid
  and trunc(INVPRCADJBYGDLOG.Time) between Bfiledate and Efiledate
  and WAREHOUSE.Gid <>1    --�ֿ�����δ֪
  and INVPRCADJBYGD.Stat = ModuleStat.No
  group by VENDOR.Code
          ,VENDOR.Name
          ,WAREHOUSE.Code
          ,WAREHOUSE.Name 
          ,trunc(INVPRCADJBYGDLOG.Time)
          ,ModuleStat.Statname
          ,h4v_goodssort.ascode
          ,h4v_goodssort.asname
          ,BRAND
         ) 
         group by code ,name  ,ascode ,asname ,BRAND
         order by code ;


END;    
 END IF;        
END;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>tmp_test2</TABLE>
    <ALIAS>tmp_test2</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
</TABLELIST>
<JOINLIST>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char1</COLUMN>
    <TITLE>��Ӧ�̴���</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char2</COLUMN>
    <TITLE>��Ӧ������</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char4</COLUMN>
    <TITLE>Ʒ�����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char5</COLUMN>
    <TITLE>Ʒ��</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num1</COLUMN>
    <TITLE>��Ӫ������˰���</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num2</COLUMN>
    <TITLE>��Ӫ����˰��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num5</COLUMN>
    <TITLE>��Ӫ�����˻���˰���</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num6</COLUMN>
    <TITLE>��Ӫ�����˻�˰��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num6</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num1-tmp_test2.num5</COLUMN>
    <TITLE>��Ӫ���˺ϼƷ������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>zyhj</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>255</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num3</COLUMN>
    <TITLE>ֱ�������˰���</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num4</COLUMN>
    <TITLE>ֱ�����˰��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num7</COLUMN>
    <TITLE>ֱ������˻���˰���</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num7</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num8</COLUMN>
    <TITLE>ֱ������˻�˰��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num8</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num3-tmp_test2.num7</COLUMN>
    <TITLE>ֱ����˺ϼƷ������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>zpct</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>255</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>nvl(num1,0)+nvl(num3,0)-nvl(num5,0)-nvl(num7,0)</COLUMN>
    <TITLE>�ϼ�</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>Column2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>255</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num9</COLUMN>
    <TITLE>�����۽��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num9</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.date1</COLUMN>
    <TITLE>��ʼ����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy.MM.dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.date2</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy.MM.dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char3</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>case when 
 tmp_test2.char6='02' then 'MUMUSO FAMILY'
     when 
 tmp_test2.char6='01' then 'ľ������'
else 'δ֪' end</COLUMN>
    <TITLE>Ʒ��</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char6</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>188</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>128</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>128</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>128</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>128</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>62</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>32</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
  <GROUPITEM>
    <COLUMN>tmp_test2.char1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char2</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char4</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char5</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>case when 
 tmp_test2.char6='02' then 'MUMUSO FAMILY'
     when 
 tmp_test2.char6='01' then 'ľ������'
else 'δ֪' end</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>Ʒ��</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>tmp_test2.date1</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2017.05.01</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>2</ISQUOTED>
    <PICKNAME>
    </PICKNAME>
    <PICKVALUE>
    </PICKVALUE>
    <DEFAULTVALUE>�³�</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test2.date2</LEFT>
    <OPERATOR><=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2017.05.31</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>2</ISQUOTED>
    <PICKNAME>
    </PICKNAME>
    <PICKVALUE>
    </PICKVALUE>
    <DEFAULTVALUE>����</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test2.char3</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>����������</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
      <PICKNAMEITEM>����������</PICKNAMEITEM>
      <PICKNAMEITEM>����������</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>����������</PICKVALUEITEM>
      <PICKVALUEITEM>����������</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE>����������</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test2.char1</LEFT>
    <OPERATOR>LIKE</OPERATOR>
    <RIGHT>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
    </PICKNAME>
    <PICKVALUE>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test2.char2</LEFT>
    <OPERATOR>LIKE</OPERATOR>
    <RIGHT>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
    </PICKNAME>
    <PICKVALUE>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>char4</LEFT>
    <OPERATOR>IN</OPERATOR>
    <RIGHT>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
    </PICKNAME>
    <PICKVALUE>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>char5</LEFT>
    <OPERATOR>LIKE</OPERATOR>
    <RIGHT>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
    </PICKNAME>
    <PICKVALUE>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>98</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>2017.05.01</SGLINEITEM>
    <SGLINEITEM>2017.05.31</SGLINEITEM>
    <SGLINEITEM>����������</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 2��</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 3��</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 4��</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
  </LINE>
</SG>
<CHECKLIST>
  <CAPTION>
  </CAPTION>
  <EXPRESSION>
  </EXPRESSION>
  <CHECKED>
  </CHECKED>
  <ANDOR> and </ANDOR>
</CHECKLIST>
<UNIONLIST>
</UNIONLIST>
<NCRITERIAS>
  <NUMOFNEXTQRY>0</NUMOFNEXTQRY>
</NCRITERIAS>
<MULTIQUERIES>
  <NUMOFMULTIQRY>0</NUMOFMULTIQRY>
</MULTIQUERIES>
<FUNCTIONLIST>
</FUNCTIONLIST>
<DXDBGRIDITEM>
  <DXLOADMETHOD>FALSE</DXLOADMETHOD>
  <DXSHOWGROUP>FALSE</DXSHOWGROUP>
  <DXSHOWFOOTER>TRUE</DXSHOWFOOTER>
  <DXSHOWSUMMARY>FALSE</DXSHOWSUMMARY>
  <DXSHOWPREVIEW>FALSE</DXSHOWPREVIEW>
  <DXSHOWFILTER>FALSE</DXSHOWFILTER>
  <DXPREVIEWFIELD></DXPREVIEWFIELD>
  <DXCOLORODDROW>15921906</DXCOLORODDROW>
  <DXCOLOREVENROW>12632256</DXCOLOREVENROW>
  <DXFILTERNAME></DXFILTERNAME>
  <DXFILTERTYPE></DXFILTERTYPE>
  <DXFILTERLIST>
  </DXFILTERLIST>
  <DXSHOWGRIDLINE>1</DXSHOWGRIDLINE>
</DXDBGRIDITEM>
</SQLQUERY>
<SQLREPORT>
<RPTTITLE>��Ӧ�̽��˻����ܲ�ѯ_��������or��������</RPTTITLE>
<RPTGROUPCOUNT>0</RPTGROUPCOUNT>
<RPTGROUPLIST>
</RPTGROUPLIST>
<RPTCOLUMNCOUNT>10</RPTCOLUMNCOUNT>
<RPTCOLUMNWIDTHLIST>
  <RPTCOLUMNWIDTHITEM>96</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>188</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>116</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>128</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>130</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>128</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>136</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>132</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>124</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>78</RPTCOLUMNWIDTHITEM>
</RPTCOLUMNWIDTHLIST>
<RPTLEFTMARGIN>20</RPTLEFTMARGIN>
<RPTORIENTATION>0</RPTORIENTATION>
<RPTCOLUMNS>1</RPTCOLUMNS>
<RPTHEADERLEVEL>0</RPTHEADERLEVEL>
<RPTPRINTCRITERIA>TRUE</RPTPRINTCRITERIA>
<RPTVERSION></RPTVERSION>
<RPTNOTE></RPTNOTE>
<RPTFONTSIZE>10</RPTFONTSIZE>
<RPTLINEHEIGHT>����</RPTLINEHEIGHT>
<RPTPAGEHEIGHT>66</RPTPAGEHEIGHT>
<RPTPAGEWIDTH>80</RPTPAGEWIDTH>
<RPTTITLETYPE>0</RPTTITLETYPE>
<RPTCURREPORT></RPTCURREPORT>
<RPTREPORTLIST>
</RPTREPORTLIST>
</SQLREPORT>

