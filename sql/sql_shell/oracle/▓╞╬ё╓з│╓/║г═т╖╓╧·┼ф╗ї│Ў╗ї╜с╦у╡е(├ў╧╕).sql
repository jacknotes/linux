<VERSION>4.1.1</VERSION>
<SQLQUERY>
<REMARK>
[标题]

[应用背景]

[结果列描述]

[必要的查询条件]

[实现方法]

[其它]
</REMARK>
<BEFORERUN>
declare
  Bfiledate  date;
  Efiledate  date;
  StoreCode1 varchar2(10);
begin
  Bfiledate  := '\(1,1)';
  Efiledate  := '\(2,1)';
  StoreCode1 := '\(3,1)';

  /* Bfiledate:='2016-09-01';
  Efiledate:='2016-10-31';
  StoreCode1:='40144';*/

  delete from tmp_test2;
  commit;

  insert into tmp_test2
  
    (char13 --类型
    ,
     char1 --单号
    ,
     char2 --店号
    ,
     char3 --店名
    ,
     char4 --品类代码
    ,
     char5 --品类
    ,
     char10 --商品代码
    ,
     char11 --商品名称
    ,
     char12 --商品条形码
    ,
     int1 --实配数
    ,
     num4 --总仓成本金额
    ,
     num3 --成本金额
    ,
     num1 --零售金额
     
    ,
     date1 --填单日期
    ,
     char6 --填单人
    ,
     char7 --状态
    ,
     char8 --仓位号
    ,
     char9 --仓位
    ,
     date2 --操作日期
    ,
     date3 --开始日期
    ,
     date4, --结束日期
     char14 ---价格组计算公式
     ,char15--品牌
     --,
    -- num5 --结算比例
     )
  --统配出
    SELECT STKOUT.CLS,
           STKOUT.NUM NUM,
           CLIENT.CODE storecode,
           CLIENT.NAME storename,
           h4v_goodssort.ascode ascode,
           h4v_goodssort.asname asname,
           goods.code goodscode,
           goods.name goodsname,
           goods.code2 goodscode2,
           sum(STKOUTDTL.QTY) QTY, --实配数
           sum(STKOUTDTL.CAMT + STKOUTDTL.CTAX) Ziamt, --总仓成本金额
           sum(STKOUTDTL.Total) iamt, --库存价（成本金额） 
           --sum((goods.rtlprc) * (STKOUTDTL.QTY)) salamt, 营业额（售价会变动，经财务部门（何元钦）要求，改成下面的取值）
           sum(STKOUTdtl.CRTOTAL) CRTOTAL, --营业额（为了保持数据一致）
           
           STKOUT.Ocrdate,
           STKOUT.Filler,
           MODULESTAT.STATNAME STATNAME,
           warehouse.code code2,
           warehouse.name name2,
           trunc(Stkoutlog.time),
           Bfiledate,
           Efiledate,
           wp.whsprcformula,
           goods.brand
           --,To_number(replace(replace(wp.whsprcformula,'RTLPRC',''),'*',''))
    
      FROM STKOUT        STKOUT,
           STKOUTDTL     STKOUTDTL,
           Stkoutlog     Stkoutlog,
           MODULESTAT    MODULESTAT,
           CLIENT        CLIENT,
           GOODS         GOODS,
           h4v_goodssort h4v_goodssort,
           warehouse     warehouse,
           WSPRCGRPGD    wp
    
     WHERE STKOUT.NUM = STKOUTDTL.NUM
       and STKOUT.Cls = STKOUTDTL.Cls
       and STKOUT.CLS = '批发'
       and wp.gcode = CLIENT.WSPRCGRP
       and GOODS.Code = wp.GDCode
       and GOODS.Gid = wp.gdgid
       and wp.calcmode = '按公式'
       and STKOUT.NUM = Stkoutlog.NUM
       and STKOUT.CLS = Stkoutlog.CLS
       and Stkoutlog.Stat in (700, 720, 740, 320, 340) --已收货 状态
       and STKOUT.STAT = MODULESTAT.NO
       and STKOUT.BILLTO = CLIENT.GID
       and STKOUTDTL.GDGID = GOODS.GID
       and GOODS.GID = h4v_goodssort.gid
          
       and trunc(Stkoutlog.Time) between Bfiledate and Efiledate
       and GOODS.Wrh = warehouse.gid
       and (StoreCode1 is null or CLIENT.CODE = StoreCode1)
    
     group by STKOUT.NUM,
              CLIENT.CODE,
              CLIENT.NAME,
              MODULESTAT.STATNAME,
              trunc(Stkoutlog.time),
              h4v_goodssort.ascode,
              h4v_goodssort.asname,
              goods.code,
              goods.name,
              goods.code2,
              STKOUT.Ocrdate,
              STKOUT.Filler,
              warehouse.code,
              warehouse.name,
              wp.whsprcformula,
              STKOUT.CLS,
           goods.brand
    
    union all
    --统配出退   
    SELECT STKOUTBCK.CLS,
           STKOUTBCK.NUM NUM,
           CLIENT.CODE storecode,
           CLIENT.NAME storename,
           h4v_goodssort.ascode ascode,
           h4v_goodssort.asname asname,
           goods.code goodscode,
           goods.name goodsname,
           goods.code2 goodscode2,
           -sum(STKOUTBCKDTL.QTY) QTY, --实配数
           -sum(STKOUTBCKDTL.CAMT + STKOUTBCKDTL.CTAX) Ziamt, --总仓成本金额
           -sum(STKOUTBCKDTL.Total) iamt, --库存价（成本金额） 
           --sum((goods.rtlprc) * (STKOUTBCKDTL.QTY)) salamt, 营业额（售价会变动，经财务部门（何元钦）要求，改成下面的取值）
           -sum(STKOUTBCKdtl.CRTOTAL) CRTOTAL, --营业额（为了保持数据一致）
           
           STKOUTBCK.Ocrdate,
           STKOUTBCK.Filler,
           MODULESTAT.STATNAME STATNAME,
           warehouse.code code2,
           warehouse.name name2,
           trunc(STKOUTBCKlog.time),
           Bfiledate,
           Efiledate,
           wp.whsprcformula,
           goods.brand
           --,To_number(replace(replace(wp.whsprcformula,'RTLPRC',''),'*',''))
    
      FROM STKOUTBCK     STKOUTBCK,
           STKOUTBCKDTL  STKOUTBCKDTL,
           STKOUTBCKlog  STKOUTBCKlog,
           MODULESTAT    MODULESTAT,
           CLIENT        CLIENT,
           GOODS         GOODS,
           h4v_goodssort h4v_goodssort,
           warehouse     warehouse,
           WSPRCGRPGD    wp
    
     WHERE STKOUTBCK.NUM = STKOUTBCKDTL.NUM
       and STKOUTBCK.Cls = STKOUTBCKDTL.Cls
       and STKOUTBCK.CLS = '批发退'
       and wp.gcode = CLIENT.WSPRCGRP
       and GOODS.Code = wp.GDCode
       and GOODS.Gid = wp.gdgid
       and wp.calcmode = '按公式'
       and STKOUTBCK.NUM = STKOUTBCKlog.NUM
       and STKOUTBCK.CLS = STKOUTBCKlog.CLS
       and STKOUTBCKlog.Stat in (1000, 1020, 1040, 320, 340)
       and STKOUTBCK.STAT = MODULESTAT.NO
       and STKOUTBCK.BILLTO = CLIENT.GID
       and STKOUTBCKDTL.GDGID = GOODS.GID
       and GOODS.GID = h4v_goodssort.gid
          
       and trunc(STKOUTBCKlog.Time) between Bfiledate and Efiledate
       and GOODS.Wrh = warehouse.gid
       and (StoreCode1 is null or CLIENT.CODE = StoreCode1)
    
     group by STKOUTBCK.NUM,
              CLIENT.CODE,
              CLIENT.NAME,
              MODULESTAT.STATNAME,
              trunc(STKOUTBCKlog.time),
              h4v_goodssort.ascode,
              h4v_goodssort.asname,
              goods.code,
              goods.name,
              goods.code2,
              STKOUTBCK.Ocrdate,
              STKOUTBCK.Filler,
              warehouse.code,
              warehouse.name,
              wp.whsprcformula,
              STKOUTBCK.CLS,
           goods.brand
    
   /* union all
    --直配单
    SELECT DirAlc.CLS,
           DirAlc.NUM NUM,
           CLIENT.CODE storecode,
           CLIENT.NAME storename,
           h4v_goodssort.ascode ascode,
           h4v_goodssort.asname asname,
           goods.code goodscode,
           goods.name goodsname,
           goods.code2 goodscode2,
           sum(DirAlcDTL.QTY) QTY, --实配数
           sum(DirAlcDTL.CAMT + DirAlcDTL.CTAX) Ziamt, --总仓成本金额
           sum(DirAlcDTL.Total) iamt, --库存价（成本金额） 
           --sum((goods.rtlprc) * (STKOUTDTL.QTY)) salamt, 营业额（售价会变动，经财务部门（何元钦）要求，改成下面的取值）
           sum(DirAlcdtl.RTOTAL) RTOTAL, --营业额（为了保持数据一致）
           
           DirAlc.Ocrdate,
           DirAlc.Filler,
           MODULESTAT.STATNAME STATNAME,
           warehouse.code code2,
           warehouse.name name2,
           trunc(DirAlclog.time),
           Bfiledate,
           Efiledate,
           wp.whsprcformula,
           goods.brand
           --,To_number(replace(replace(wp.whsprcformula,'RTLPRC',''),'*',''))
    
      FROM DirAlc        DirAlc,
           DirAlcDTL     DirAlcDTL,
           DirAlclog     DirAlclog,
           MODULESTAT    MODULESTAT,
           CLIENT        CLIENT,
           GOODS         GOODS,
           h4v_goodssort h4v_goodssort,
           warehouse     warehouse,
           WSPRCGRPGD    wp
    
     WHERE DirAlc.NUM = DirAlcDTL.NUM
       and DirAlc.Cls = DirAlcDTL.Cls
       and DirAlc.CLS = '直配出'
       and wp.gcode = CLIENT.WSPRCGRP
       and GOODS.Code = wp.GDCode
       and GOODS.Gid = wp.gdgid
       and wp.calcmode = '按公式'
       and DirAlc.NUM = DirAlclog.NUM
       and DirAlc.CLS = DirAlclog.CLS
       and DirAlclog.Stat in (1000, 1020, 1040, 320, 340)
       and DirAlc.STAT = MODULESTAT.NO
       and DirAlc.RECEIVER = CLIENT.GID
       and DirAlcDTL.GDGID = GOODS.GID
       and GOODS.GID = h4v_goodssort.gid
       and trunc(DirAlclog.Time) between Bfiledate and Efiledate
       and GOODS.Wrh = warehouse.gid
       and (StoreCode1 is null or CLIENT.CODE = StoreCode1)
    
     group by DirAlc.NUM,
              CLIENT.CODE,
              CLIENT.NAME,
              MODULESTAT.STATNAME,
              trunc(DirAlclog.time),
              h4v_goodssort.ascode,
              h4v_goodssort.asname,
              goods.code,
              goods.name,
              goods.code2,
              DirAlc.Ocrdate,
              DirAlc.Filler,
              warehouse.code,
              warehouse.name,
              wp.whsprcformula,
              DirAlc.CLS,
           goods.brand
    
    union all
    --直配单
    SELECT DirAlc.CLS,
           DirAlc.NUM NUM,
           CLIENT.CODE storecode,
           CLIENT.NAME storename,
           h4v_goodssort.ascode ascode,
           h4v_goodssort.asname asname,
           goods.code goodscode,
           goods.name goodsname,
           goods.code2 goodscode2,
           sum(DirAlcDTL.QTY) QTY, --实配数
           sum(DirAlcDTL.CAMT + DirAlcDTL.CTAX) Ziamt, --总仓成本金额
           sum(DirAlcDTL.Total) iamt, --库存价（成本金额） 
           --sum((goods.rtlprc) * (STKOUTDTL.QTY)) salamt, 营业额（售价会变动，经财务部门（何元钦）要求，改成下面的取值）
           sum(DirAlcdtl.RTOTAL) RTOTAL, --营业额（为了保持数据一致）
           
           DirAlc.Ocrdate,
           DirAlc.Filler,
           MODULESTAT.STATNAME STATNAME,
           warehouse.code code2,
           warehouse.name name2,
           trunc(DirAlclog.time),
           Bfiledate,
           Efiledate,
           wp.whsprcformula,
           goods.brand
           --,To_number(replace(replace(wp.whsprcformula,'RTLPRC',''),'*',''))
    
      FROM DirAlc        DirAlc,
           DirAlcDTL     DirAlcDTL,
           DirAlclog     DirAlclog,
           MODULESTAT    MODULESTAT,
           CLIENT        CLIENT,
           GOODS         GOODS,
           h4v_goodssort h4v_goodssort,
           warehouse     warehouse,
           WSPRCGRPGD    wp
    
     WHERE DirAlc.NUM = DirAlcDTL.NUM
       and DirAlc.Cls = DirAlcDTL.Cls
       and DirAlc.CLS = '直配出退'
       and wp.gcode = CLIENT.WSPRCGRP
       and GOODS.Code = wp.GDCode
       and GOODS.Gid = wp.gdgid
       and wp.calcmode = '按公式'
       and DirAlc.NUM = DirAlclog.NUM
       and DirAlc.CLS = DirAlclog.CLS
       and DirAlclog.Stat in (700, 720, 740, 320, 340)
       and DirAlc.STAT = MODULESTAT.NO
       and DirAlc.RECEIVER = CLIENT.GID
       and DirAlcDTL.GDGID = GOODS.GID
       and GOODS.GID = h4v_goodssort.gid
       and trunc(DirAlclog.Time) between Bfiledate and Efiledate
       and GOODS.Wrh = warehouse.gid
       and (StoreCode1 is null or CLIENT.CODE = StoreCode1)
    
     group by DirAlc.NUM,
              CLIENT.CODE,
              CLIENT.NAME,
              MODULESTAT.STATNAME,
              trunc(DirAlclog.time),
              h4v_goodssort.ascode,
              h4v_goodssort.asname,
              goods.code,
              goods.name,
              goods.code2,
              DirAlc.Ocrdate,
              DirAlc.Filler,
              warehouse.code,
              warehouse.name,
              wp.whsprcformula,
              DirAlc.CLS,
           goods.brand	*/
    
    union all
    --配货差异
    select ALCDIFF.Cls,
           ALCDIFF.Num,
           CLIENT.CODE storecode,
           CLIENT.NAME storename,
           h4v_goodssort.ascode ascode,
           h4v_goodssort.asname asname,
           goods.code goodscode,
           goods.name goodsname,
           goods.code2 goodscode2,
           sum(ALCDIFFDTL.QTY) QTY, --实配数
           sum(ALCDIFFDTL.CAMT + ALCDIFFDTL.CTAX) Ziamt, --总仓成本金额
           sum(ALCDIFFDTL.Total) iamt, --库存价（成本金额） 
           sum(ALCDIFFdtl.CRTOTAL) CRTOTAL, --营业额（为了保持数据一致）
           
           ALCDIFF.Ocrdate,
           ALCDIFF.CREATEOPER,
           MODULESTAT.STATNAME STATNAME,
           warehouse.code code2,
           warehouse.name name2,
           trunc(ALCDIFFlog.time),
           Bfiledate,
           Efiledate,
           wp.whsprcformula,
           goods.brand
           --,To_number(replace(replace(wp.whsprcformula,'RTLPRC',''),'*',''))
    
      from ALCDIFF       ALCDIFF,
           ALCDIFFDTL    ALCDIFFDTL,
           ALCDIFFlog    ALCDIFFlog,
           MODULESTAT    MODULESTAT,
           CLIENT        CLIENT,
           GOODS         GOODS,
           h4v_goodssort h4v_goodssort,
           warehouse     warehouse,
           WSPRCGRPGD    wp
    
     WHERE ALCDIFF.NUM = ALCDIFFDTL.NUM
       and ALCDIFF.Cls = ALCDIFFDTL.Cls
       and ALCDIFF.CLS = '批发差异'			--2017-12-11 由于没有国外配货差异的需求，暂时封存--徐超群
       and wp.gcode = CLIENT.WSPRCGRP
       and GOODS.Code = wp.GDCode
       and GOODS.Gid = wp.gdgid
       and wp.calcmode = '按公式'
       and ALCDIFF.NUM = ALCDIFFlog.NUM
       and ALCDIFF.CLS = ALCDIFFlog.CLS
       and ALCDIFFlog.Stat IN (400, 420, 440, 320, 340)
       and ALCDIFF.STAT = MODULESTAT.NO
       and ALCDIFF.BILLTO = CLIENT.GID
       and ALCDIFFDTL.GDGID = GOODS.GID
       and GOODS.GID = h4v_goodssort.gid
       and trunc(ALCDIFFlog.Time) between Bfiledate and Efiledate
       and GOODS.Wrh = warehouse.gid
       and (StoreCode1 is null or CLIENT.CODE = StoreCode1)
    
     group by ALCDIFF.NUM,
              CLIENT.CODE,
              CLIENT.NAME,
              MODULESTAT.STATNAME,
              trunc(ALCDIFFlog.time),
              h4v_goodssort.ascode,
              h4v_goodssort.asname,
              goods.code,
              goods.name,
              goods.code2,
              ALCDIFF.Ocrdate,
              ALCDIFF.CREATEOPER,
              warehouse.code,
              warehouse.name,
              wp.whsprcformula,
              ALCDIFF.CLS,
           goods.brand
    
    ;
  commit;
end;
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
    <COLUMN>char13</COLUMN>
    <TITLE>类型</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char13</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char1</COLUMN>
    <TITLE>单号</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char2</COLUMN>
    <TITLE>客户代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <COLUMN>char3</COLUMN>
    <TITLE>客户名</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>case when char15='01' then '木槿生活'
     when char15='02' then 'Mumuso Family'
else '未知' end  </COLUMN>
    <TITLE>品牌</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char15</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char4</COLUMN>
    <TITLE>品类代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <TITLE>品类</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <AGGREGATION></AGGREGATION>
    <COLUMN>char10</COLUMN>
    <TITLE>商品代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char10</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char11</COLUMN>
    <TITLE>商品名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char12</COLUMN>
    <TITLE>商品条形码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char12</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>int1</COLUMN>
    <TITLE>实配数</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>num4</COLUMN>
    <TITLE>总仓成本额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>num3</COLUMN>
    <TITLE>客户结算金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <COLUMN>num1</COLUMN>
    <TITLE>零售金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <AGGREGATION></AGGREGATION>
    <COLUMN>char14</COLUMN>
    <TITLE>批发价公式</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char14</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>num5 </COLUMN>
    <TITLE>结算比例</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num5 </COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>num1 * num5</COLUMN>
    <TITLE>结算金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>Nx</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>date1</COLUMN>
    <TITLE>填单日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy.MM.dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char6</COLUMN>
    <TITLE>填单人</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char6</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char7</COLUMN>
    <TITLE>状态</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char7</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char8</COLUMN>
    <TITLE>仓位号</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char8</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>date2</COLUMN>
    <TITLE>操作日期</TITLE>
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
    <COLUMN>date3</COLUMN>
    <TITLE>开始日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy.MM.dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>date4</COLUMN>
    <TITLE>结束日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy.MM.dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>32</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>178</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>65</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>212</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>86</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>99</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
  <GROUPITEM>
    <COLUMN>char13</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char2</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char3</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>case when char15='01' then '木槿生活'
     when char15='02' then 'Mumuso Family'
else '未知' end  </COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char4</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char5</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char10</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char11</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char12</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char14</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>date1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char6</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char7</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char8</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>单号</COLUMN>
    <ORDER>DESC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>date2</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2017.11.01</RIGHTITEM>
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
    <DEFAULTVALUE>上月初</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>date3</LEFT>
    <OPERATOR><=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2017.12.13</RIGHTITEM>
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
    <DEFAULTVALUE>昨天</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>char2</LEFT>
    <OPERATOR>IN</OPERATOR>
    <RIGHT>
      <RIGHTITEM>000003</RIGHTITEM>
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
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>85</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>2017.11.01</SGLINEITEM>
    <SGLINEITEM>2017.12.13</SGLINEITEM>
    <SGLINEITEM>000003</SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 2：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 3：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 4：</SGLINEITEM>
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
  <DXCOLORODDROW>-2147483643</DXCOLORODDROW>
  <DXCOLOREVENROW>-2147483643</DXCOLOREVENROW>
  <DXFILTERNAME></DXFILTERNAME>
  <DXFILTERTYPE></DXFILTERTYPE>
  <DXFILTERLIST>
  </DXFILTERLIST>
  <DXSHOWGRIDLINE>1</DXSHOWGRIDLINE>
</DXDBGRIDITEM>
</SQLQUERY>
<SQLREPORT>
<RPTTITLE></RPTTITLE>
<RPTGROUPCOUNT>0</RPTGROUPCOUNT>
<RPTGROUPLIST>
</RPTGROUPLIST>
<RPTCOLUMNCOUNT>0</RPTCOLUMNCOUNT>
<RPTCOLUMNWIDTHLIST>
</RPTCOLUMNWIDTHLIST>
<RPTLEFTMARGIN>20</RPTLEFTMARGIN>
<RPTORIENTATION>0</RPTORIENTATION>
<RPTCOLUMNS>1</RPTCOLUMNS>
<RPTHEADERLEVEL>0</RPTHEADERLEVEL>
<RPTPRINTCRITERIA>TRUE</RPTPRINTCRITERIA>
<RPTVERSION></RPTVERSION>
<RPTNOTE></RPTNOTE>
<RPTFONTSIZE>10</RPTFONTSIZE>
<RPTLINEHEIGHT>宋体</RPTLINEHEIGHT>
<RPTPAGEHEIGHT>66</RPTPAGEHEIGHT>
<RPTPAGEWIDTH>80</RPTPAGEWIDTH>
<RPTTITLETYPE>0</RPTTITLETYPE>
<RPTCURREPORT></RPTCURREPORT>
<RPTREPORTLIST>
</RPTREPORTLIST>
</SQLREPORT>

