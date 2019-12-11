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
  NumC varchar2(20);
begin

  Bfiledate  := '\(1,1)';
  Efiledate  := '\(2,1)';
  StoreCode1 := '\(3,1)';
  NumC := '\(4,1)';

  /*Bfiledate:='2016-09-01';
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
     num2 --结算比例
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
     date4 --结束日期
     
     )
  --统配出
    SELECT STKOUT.CLS,
           STKOUT.NUM NUM,
           STORE.CODE storecode,
           STORE.NAME storename,
           h4v_goodssort.ascode ascode,
           h4v_goodssort.asname asname,
           goods.code goodscode,
           goods.name goodsname,
           goods.code2 goodscode2,
           sum(STKOUTDTL.QTY) QTY, --实配数
           sum(STKOUTDTL.CAMT + STKOUTDTL.CTAX) ziamt, --（总仓成本金额） 
           sum(STKOUTDTL.Total) iamt, --库存价（成本金额） 
           --sum((goods.rtlprc) * (STKOUTDTL.QTY)) salamt, 营业额（售价会变动，经财务部门（何元钦）要求，改成下面的取值）
           sum(STKOUTdtl.CRTOTAL) CRTOTAL, --营业额（为了保持数据一致）
           case
             when h4v_goodssort.ascode in ('10',
                                           '11',
                                           '12',
                                           '13',
                                           '15',
                                           '16',
                                           '17',
                                           '18',
                                           '19',
                                           '26') then
              store.rate42
             when h4v_goodssort.ascode in ('14') then
              store.rate41
             when h4v_goodssort.ascode in
                  ('20', '21', '22', '23', '27', '24', '25', '30') then
              store.rate20
           end jiesuanbili,
           STKOUT.Ocrdate,
           STKOUT.Filler,
           MODULESTAT.STATNAME STATNAME,
           warehouse.code code2,
           warehouse.name name2,
           trunc(Stkoutlog.time),
           Bfiledate,
           Efiledate
    
      FROM STKOUT        STKOUT,
           STKOUTDTL     STKOUTDTL,
           Stkoutlog     Stkoutlog,
           MODULESTAT    MODULESTAT,
           STORE         STORE,
           GOODS         GOODS,
           h4v_goodssort h4v_goodssort,
           warehouse     warehouse
    
     WHERE STKOUT.NUM = STKOUTDTL.NUM
       and STKOUT.Cls = STKOUTDTL.Cls
       and STKOUT.CLS = '统配出'
       and STKOUT.NUM = Stkoutlog.NUM
       and STKOUT.CLS = Stkoutlog.CLS
       and Stkoutlog.Stat in (700, 720, 740, 320, 340) --已收货 状态
       and STKOUT.STAT = MODULESTAT.NO
       and STKOUT.BILLTO = STORE.GID
       and STKOUTDTL.GDGID = GOODS.GID
       and GOODS.GID = h4v_goodssort.gid
          
       and trunc(Stkoutlog.Time) >=Bfiledate 
       and trunc(Stkoutlog.Time)<Efiledate
       and GOODS.Wrh = warehouse.gid
       and (StoreCode1 is null or STORE.CODE = StoreCode1)
       and (NumC is null or STKOUT.NUM=NumC)
    
     group by STKOUT.NUM,
              STORE.CODE,
              STORE.NAME,
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
              case
                when h4v_goodssort.ascode in ('10',
                                              '11',
                                              '12',
                                              '13',
                                              '15',
                                              '16',
                                              '17',
                                              '18',
                                              '19',
                                              '26') then
                 store.rate42
                when h4v_goodssort.ascode in ('14') then
                 store.rate41
                when h4v_goodssort.ascode in
                     ('20', '21', '22', '23','27', '24', '25', '30') then
                 store.rate20
              end,
              STKOUT.CLS
    
    union all
    --统配出退   
    SELECT STKOUTBCK.CLS,
           STKOUTBCK.NUM NUM,
           STORE.CODE storecode,
           STORE.NAME storename,
           h4v_goodssort.ascode ascode,
           h4v_goodssort.asname asname,
           goods.code goodscode,
           goods.name goodsname,
           goods.code2 goodscode2,
           -sum(STKOUTBCKDTL.QTY) QTY, --实配数
           -sum(STKOUTBCKDTL.CAMT + STKOUTBCKDTL.CTAX) ziamt, --（总仓成本金额）
           sum(STKOUTBCKDTL.Total) iamt, --库存价（成本金额） 
           
           -sum(STKOUTBCKdtl.CRTOTAL) CRTOTAL, --营业额（为了保持数据一致）
           case
             when h4v_goodssort.ascode in ('10',
                                           '11',
                                           '12',
                                           '13',
                                           '15',
                                           '16',
                                           '17',
                                           '18',
                                           '19',
                                           '26') then
              store.rate42
             when h4v_goodssort.ascode in ('14') then
              store.rate41
             when h4v_goodssort.ascode in
                  ('20', '21', '22', '23','27', '24', '25', '30') then
              store.rate20
           end jiesuanbili,
           STKOUTBCK.Ocrdate,
           STKOUTBCK.Filler,
           MODULESTAT.STATNAME STATNAME,
           warehouse.code code2,
           warehouse.name name2,
           trunc(STKOUTBCKlog.time),
           Bfiledate,
           Efiledate
    
      FROM STKOUTBCK     STKOUTBCK,
           STKOUTBCKDTL  STKOUTBCKDTL,
           STKOUTBCKlog  STKOUTBCKlog,
           MODULESTAT    MODULESTAT,
           STORE         STORE,
           GOODS         GOODS,
           h4v_goodssort h4v_goodssort,
           warehouse     warehouse
    
     WHERE STKOUTBCK.NUM = STKOUTBCKDTL.NUM
       and STKOUTBCK.Cls = STKOUTBCKDTL.Cls
       and STKOUTBCK.CLS = '统配出退'
       and STKOUTBCK.NUM = STKOUTBCKlog.NUM
       and STKOUTBCK.CLS = STKOUTBCKlog.CLS
       and STKOUTBCKlog.Stat in (1000, 1020, 1040, 320, 340)
       and STKOUTBCK.STAT = MODULESTAT.NO
       and STKOUTBCK.BILLTO = STORE.GID
       and STKOUTBCKDTL.GDGID = GOODS.GID
       and GOODS.GID = h4v_goodssort.gid
          
       and trunc(STKOUTBCKlog.Time) >=Bfiledate 
       and trunc(STKOUTBCKlog.Time) <Efiledate
       and GOODS.Wrh = warehouse.gid
       and (StoreCode1 is null or STORE.CODE = StoreCode1)
       and (NumC is null or STKOUTBCK.NUM=NumC)
     group by STKOUTBCK.NUM,
              STORE.CODE,
              STORE.NAME,
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
              case
                when h4v_goodssort.ascode in ('10',
                                              '11',
                                              '12',
                                              '13',
                                              '15',
                                              '16',
                                              '17',
                                              '18',
                                              '19',
                                              '26') then
                 store.rate42
                when h4v_goodssort.ascode in ('14') then
                 store.rate41
                when h4v_goodssort.ascode in
                     ('20', '21', '22', '23','27', '24', '25', '30') then
                 store.rate20
              end,
              STKOUTBCK.CLS
    
    union all
    
    SELECT DirAlc.CLS,
           DirAlc.NUM NUM,
           STORE.CODE storecode,
           STORE.NAME storename,
           h4v_goodssort.ascode ascode,
           h4v_goodssort.asname asname,
           goods.code goodscode,
           goods.name goodsname,
           goods.code2 goodscode2,
           sum(DirAlcDTL.QTY) QTY, --实配数
           sum(DirAlcDTL.CAMT + DirAlcDTL.CTAX) ziamt, --（总仓成本金额）
           sum(DirAlcDTL.Total) iamt, --库存价（成本金额） 
           --sum((goods.rtlprc) * (STKOUTDTL.QTY)) salamt, 营业额（售价会变动，经财务部门（何元钦）要求，改成下面的取值）
           sum(DirAlcdtl.RTOTAL) RTOTAL, --营业额（为了保持数据一致）
           case
             when h4v_goodssort.ascode in ('10',
                                           '11',
                                           '12',
                                           '13',
                                           '15',
                                           '16',
                                           '17',
                                           '18',
                                           '19',
                                           '26') then
              store.rate42
             when h4v_goodssort.ascode in ('14') then
              store.rate41
             when h4v_goodssort.ascode in
                  ('20', '21', '22', '23','27', '24', '25', '30') then
              store.rate20
           end jiesuanbili,
           DirAlc.Ocrdate,
           DirAlc.Filler,
           MODULESTAT.STATNAME STATNAME,
           warehouse.code code2,
           warehouse.name name2,
           trunc(DirAlclog.time),
           Bfiledate,
           Efiledate
    
      FROM DirAlc        DirAlc,
           DirAlcDTL     DirAlcDTL,
           DirAlclog     DirAlclog,
           MODULESTAT    MODULESTAT,
           STORE         STORE,
           GOODS         GOODS,
           h4v_goodssort h4v_goodssort,
           warehouse     warehouse
    
     WHERE DirAlc.NUM = DirAlcDTL.NUM
       and DirAlc.Cls = DirAlcDTL.Cls
       and DirAlc.CLS = '直配出'
       and DirAlc.NUM = DirAlclog.NUM
       and DirAlc.CLS = DirAlclog.CLS
       and DirAlclog.Stat in (1000, 1020, 1040, 320 ,340)
       and DirAlc.STAT = MODULESTAT.NO
       and DirAlc.RECEIVER = STORE.GID
       and DirAlcDTL.GDGID = GOODS.GID
       and GOODS.GID = h4v_goodssort.gid
       and trunc(DirAlclog.Time) >= Bfiledate 
       and trunc(DirAlclog.Time) <Efiledate
       and GOODS.Wrh = warehouse.gid
       and (StoreCode1 is null or STORE.CODE = StoreCode1)
       and (NumC is null or DirAlc.NUM=NumC)
     group by DirAlc.NUM,
              STORE.CODE,
              STORE.NAME,
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
              case
                when h4v_goodssort.ascode in ('10',
                                              '11',
                                              '12',
                                              '13',
                                              '15',
                                              '16',
                                              '17',
                                              '18',
                                              '19',
                                              '26') then
                 store.rate42
                when h4v_goodssort.ascode in ('14') then
                 store.rate41
                when h4v_goodssort.ascode in
                     ('20', '21', '22', '23','27', '24', '25', '30') then
                 store.rate20
              end,
              DirAlc.CLS


    union all
    
    SELECT DirAlc.CLS,
           DirAlc.NUM NUM,
           STORE.CODE storecode,
           STORE.NAME storename,
           h4v_goodssort.ascode ascode,
           h4v_goodssort.asname asname,
           goods.code goodscode,
           goods.name goodsname,
           goods.code2 goodscode2,
           sum(DirAlcDTL.QTY) QTY, --实配数
           sum(DirAlcDTL.CAMT + DirAlcDTL.CTAX) ziamt, --（总仓成本金额）
           sum(DirAlcDTL.Total) iamt, --库存价（成本金额） 
           --sum((goods.rtlprc) * (STKOUTDTL.QTY)) salamt, 营业额（售价会变动，经财务部门（何元钦）要求，改成下面的取值）
           sum(DirAlcdtl.RTOTAL) RTOTAL, --营业额（为了保持数据一致）
           case
             when h4v_goodssort.ascode in ('10',
                                           '11',
                                           '12',
                                           '13',
                                           '15',
                                           '16',
                                           '17',
                                           '18',
                                           '19',
                                           '26') then
              store.rate42
             when h4v_goodssort.ascode in ('14') then
              store.rate41
             when h4v_goodssort.ascode in
                  ('20', '21', '22', '23','27', '24', '25', '30') then
              store.rate20
           end jiesuanbili,
           DirAlc.Ocrdate,
           DirAlc.Filler,
           MODULESTAT.STATNAME STATNAME,
           warehouse.code code2,
           warehouse.name name2,
           trunc(DirAlclog.time),
           Bfiledate,
           Efiledate
    
      FROM DirAlc        DirAlc,
           DirAlcDTL     DirAlcDTL,
           DirAlclog     DirAlclog,
           MODULESTAT    MODULESTAT,
           STORE         STORE,
           GOODS         GOODS,
           h4v_goodssort h4v_goodssort,
           warehouse     warehouse
    
     WHERE DirAlc.NUM = DirAlcDTL.NUM
       and DirAlc.Cls = DirAlcDTL.Cls
       and DirAlc.CLS = '直配出退'
       and DirAlc.NUM = DirAlclog.NUM
       and DirAlc.CLS = DirAlclog.CLS
       and DirAlclog.Stat in (700,720,740,320,340)
       and DirAlc.STAT = MODULESTAT.NO
       and DirAlc.RECEIVER = STORE.GID
       and DirAlcDTL.GDGID = GOODS.GID
       and GOODS.GID = h4v_goodssort.gid
       and trunc(DirAlclog.Time) >= Bfiledate 
       and trunc(DirAlclog.Time) <Efiledate
       and GOODS.Wrh = warehouse.gid
       and (StoreCode1 is null or STORE.CODE = StoreCode1)
       and (NumC is null or DirAlc.NUM=NumC)
     group by DirAlc.NUM,
              STORE.CODE,
              STORE.NAME,
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
              case
                when h4v_goodssort.ascode in ('10',
                                              '11',
                                              '12',
                                              '13',
                                              '15',
                                              '16',
                                              '17',
                                              '18',
                                              '19',
                                              '26') then
                 store.rate42
                when h4v_goodssort.ascode in ('14') then
                 store.rate41
                when h4v_goodssort.ascode in
                     ('20', '21', '22', '23','27', '24', '25', '30') then
                 store.rate20
              end,
              DirAlc.CLS
    
    union all
    
    select ALCDIFF.Cls,
           ALCDIFF.Num,
           STORE.CODE storecode,
           STORE.NAME storename,
           h4v_goodssort.ascode ascode,
           h4v_goodssort.asname asname,
           goods.code goodscode,
           goods.name goodsname,
           goods.code2 goodscode2,
           sum(ALCDIFFDTL.QTY) QTY, --实配数
           sum( ALCDIFFDTL.CAMT + ALCDIFFDTL.CTAX) ziamt, --（总仓成本金额）
           sum(ALCDIFFDTL.Total) iamt, --库存价（成本金额） 
           sum(ALCDIFFdtl.CRTOTAL) CRTOTAL, --营业额（为了保持数据一致）
           case
             when h4v_goodssort.ascode in ('10',
                                           '11',
                                           '12',
                                           '13',
                                           '15',
                                           '16',
                                           '17',
                                           '18',
                                           '19',
                                           '26') then
              store.rate42
             when h4v_goodssort.ascode in ('14') then
              store.rate41
             when h4v_goodssort.ascode in
                  ('20', '21', '22', '23','27', '24', '25', '30') then
              store.rate20
           end jiesuanbili,
           ALCDIFF.Ocrdate,
           ALCDIFF.CREATEOPER,
           MODULESTAT.STATNAME STATNAME,
           warehouse.code code2,
           warehouse.name name2,
           trunc(ALCDIFFlog.time),
           Bfiledate,
           Efiledate
    
      from ALCDIFF       ALCDIFF,
           ALCDIFFDTL    ALCDIFFDTL,
           ALCDIFFlog    ALCDIFFlog,
           MODULESTAT    MODULESTAT,
           STORE         STORE,
           GOODS         GOODS,
           h4v_goodssort h4v_goodssort,
           warehouse     warehouse
    
     WHERE ALCDIFF.NUM = ALCDIFFDTL.NUM
       and ALCDIFF.Cls = ALCDIFFDTL.Cls
       and ALCDIFF.CLS = '配货差异'
       and ALCDIFF.NUM = ALCDIFFlog.NUM
       and ALCDIFF.CLS = ALCDIFFlog.CLS
       and ALCDIFFlog.Stat IN (400, 420, 440, 320, 340)
       and ALCDIFF.STAT = MODULESTAT.NO
       and ALCDIFF.BILLTO = STORE.GID
       and ALCDIFFDTL.GDGID = GOODS.GID
       and GOODS.GID = h4v_goodssort.gid
       and trunc(ALCDIFFlog.Time) >= Bfiledate 
       and trunc(ALCDIFFlog.Time)<Efiledate
       and GOODS.Wrh = warehouse.gid
       and (StoreCode1 is null or STORE.CODE = StoreCode1)
       and (NumC is null or ALCDIFF.Num=NumC)

     group by ALCDIFF.NUM,
              STORE.CODE,
              STORE.NAME,
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
              case
                when h4v_goodssort.ascode in ('10',
                                              '11',
                                              '12',
                                              '13',
                                              '15',
                                              '16',
                                              '17',
                                              '18',
                                              '19',
                                              '26') then
                 store.rate42
                when h4v_goodssort.ascode in ('14') then
                 store.rate41
                when h4v_goodssort.ascode in
                     ('20', '21', '22', '23','27', '24', '25', '30') then
                 store.rate20
              end,
              ALCDIFF.CLS
    
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
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
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
    <FIELDTYPE>1</FIELDTYPE>
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
    <TITLE>店号</TITLE>
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
    <COLUMN>char3</COLUMN>
    <TITLE>店名</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <COLUMN>char4</COLUMN>
    <TITLE>品类代码</TITLE>
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
    <TITLE>品类</TITLE>
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
    <COLUMN>int1</COLUMN>
    <TITLE>实配数</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
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
    <TITLE>总仓成本金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
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
    <TITLE>成本金额(门店)</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>成本金额</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>num1</COLUMN>
    <TITLE>零售金额</TITLE>
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
    <AGGREGATION></AGGREGATION>
    <COLUMN>num2</COLUMN>
    <TITLE>结算比例</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>num1*num2</COLUMN>
    <TITLE>结算金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>Column1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>date1</COLUMN>
    <TITLE>填单日期</TITLE>
    <FIELDTYPE>11</FIELDTYPE>
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
    <FIELDTYPE>1</FIELDTYPE>
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
    <FIELDTYPE>1</FIELDTYPE>
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
    <FIELDTYPE>1</FIELDTYPE>
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
    <COLUMN>char9</COLUMN>
    <TITLE>仓位</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char9</COLUMNNAME>
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
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>122</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>38</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>51</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>190</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>208</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>146</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>1534</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>112</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>112</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>112</COLUMNWIDTHITEM>
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
    <COLUMN>char4</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char5</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>num2</COLUMN>
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
  <GROUPITEM>
    <COLUMN>char9</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>品类代码</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>date2</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2017.03.01</RIGHTITEM>
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
    <DEFAULTVALUE>月初</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>date3</LEFT>
    <OPERATOR><</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2017.03.20</RIGHTITEM>
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
      <RIGHTITEM>40223</RIGHTITEM>
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
    <LEFT>char1</LEFT>
    <OPERATOR>=</OPERATOR>
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
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>2017.03.01</SGLINEITEM>
    <SGLINEITEM>2017.03.20</SGLINEITEM>
    <SGLINEITEM>40223</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 2：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 3：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 4：</SGLINEITEM>
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

