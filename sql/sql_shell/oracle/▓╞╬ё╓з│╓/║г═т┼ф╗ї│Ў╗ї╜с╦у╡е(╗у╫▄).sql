<VERSION>4.1.1</VERSION>
<SQLQUERY>
<REMARK>
[����]

[Ӧ�ñ���]

[���������]

[��Ҫ�Ĳ�ѯ����]

[ʵ�ַ���]

[����]
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
  
    (char13 --����
    ,
     char1 --����
    ,
     char2 --���
    ,
     char3 --����
    ,
     char4 --Ʒ�����
    ,
     char5 --Ʒ��
    ,
     char10 --��Ʒ����
    ,
     char11 --��Ʒ����
    ,
     char12 --��Ʒ������
    ,
     int1 --ʵ����
    ,
     num4 --�ֳܲɱ����
    ,
     num3 --�ɱ����
    ,
     num1 --���۽��
    ,
     num2 --�������
    ,
     date1 --�����
    ,
     char6 --���
    ,
     char7 --״̬
    ,
     char8 --��λ��
    ,
     char9 --��λ
    ,
     date2 --��������
    ,
     date3 --��ʼ����
    ,
     date4 --��������
     
     )
  --ͳ���
    SELECT STKOUT.CLS,
           STKOUT.NUM NUM,
           STORE.CODE storecode,
           STORE.NAME storename,
           h4v_goodssort.ascode ascode,
           h4v_goodssort.asname asname,
           goods.code goodscode,
           goods.name goodsname,
           goods.code2 goodscode2,
           sum(STKOUTDTL.QTY) QTY, --ʵ����
           sum(STKOUTDTL.CAMT + STKOUTDTL.CTAX) ziamt, --���ֳܲɱ��� 
           sum(STKOUTDTL.Total) iamt, --���ۣ��ɱ��� 
           --sum((goods.rtlprc) * (STKOUTDTL.QTY)) salamt, Ӫҵ��ۼۻ�䶯���������ţ���Ԫ�գ�Ҫ�󣬸ĳ������ȡֵ��
           sum(STKOUTdtl.CRTOTAL) CRTOTAL, --Ӫҵ�Ϊ�˱�������һ�£�
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
       and STKOUT.CLS = 'ͳ���'
       and STKOUT.NUM = Stkoutlog.NUM
       and STKOUT.CLS = Stkoutlog.CLS
       and Stkoutlog.Stat in (700, 720, 740, 320, 340) --���ջ� ״̬
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
    --ͳ�����   
    SELECT STKOUTBCK.CLS,
           STKOUTBCK.NUM NUM,
           STORE.CODE storecode,
           STORE.NAME storename,
           h4v_goodssort.ascode ascode,
           h4v_goodssort.asname asname,
           goods.code goodscode,
           goods.name goodsname,
           goods.code2 goodscode2,
           -sum(STKOUTBCKDTL.QTY) QTY, --ʵ����
           -sum(STKOUTBCKDTL.CAMT + STKOUTBCKDTL.CTAX) ziamt, --���ֳܲɱ���
           sum(STKOUTBCKDTL.Total) iamt, --���ۣ��ɱ��� 
           
           -sum(STKOUTBCKdtl.CRTOTAL) CRTOTAL, --Ӫҵ�Ϊ�˱�������һ�£�
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
       and STKOUTBCK.CLS = 'ͳ�����'
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
           sum(DirAlcDTL.QTY) QTY, --ʵ����
           sum(DirAlcDTL.CAMT + DirAlcDTL.CTAX) ziamt, --���ֳܲɱ���
           sum(DirAlcDTL.Total) iamt, --���ۣ��ɱ��� 
           --sum((goods.rtlprc) * (STKOUTDTL.QTY)) salamt, Ӫҵ��ۼۻ�䶯���������ţ���Ԫ�գ�Ҫ�󣬸ĳ������ȡֵ��
           sum(DirAlcdtl.RTOTAL) RTOTAL, --Ӫҵ�Ϊ�˱�������һ�£�
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
       and DirAlc.CLS = 'ֱ���'
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
           sum(DirAlcDTL.QTY) QTY, --ʵ����
           sum(DirAlcDTL.CAMT + DirAlcDTL.CTAX) ziamt, --���ֳܲɱ���
           sum(DirAlcDTL.Total) iamt, --���ۣ��ɱ��� 
           --sum((goods.rtlprc) * (STKOUTDTL.QTY)) salamt, Ӫҵ��ۼۻ�䶯���������ţ���Ԫ�գ�Ҫ�󣬸ĳ������ȡֵ��
           sum(DirAlcdtl.RTOTAL) RTOTAL, --Ӫҵ�Ϊ�˱�������һ�£�
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
       and DirAlc.CLS = 'ֱ�����'
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
           sum(ALCDIFFDTL.QTY) QTY, --ʵ����
           sum( ALCDIFFDTL.CAMT + ALCDIFFDTL.CTAX) ziamt, --���ֳܲɱ���
           sum(ALCDIFFDTL.Total) iamt, --���ۣ��ɱ��� 
           sum(ALCDIFFdtl.CRTOTAL) CRTOTAL, --Ӫҵ�Ϊ�˱�������һ�£�
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
       and ALCDIFF.CLS = '�������'
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
    <TITLE>����</TITLE>
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
    <TITLE>����</TITLE>
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
    <TITLE>���</TITLE>
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
    <TITLE>����</TITLE>
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
    <COLUMN>int1</COLUMN>
    <TITLE>ʵ����</TITLE>
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
    <TITLE>�ֳܲɱ����</TITLE>
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
    <TITLE>�ɱ����(�ŵ�)</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>�ɱ����</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>num1</COLUMN>
    <TITLE>���۽��</TITLE>
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
    <TITLE>�������</TITLE>
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
    <TITLE>������</TITLE>
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
    <TITLE>�����</TITLE>
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
    <TITLE>���</TITLE>
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
    <TITLE>״̬</TITLE>
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
    <TITLE>��λ��</TITLE>
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
    <TITLE>��λ</TITLE>
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
    <COLUMN>date3</COLUMN>
    <TITLE>��ʼ����</TITLE>
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
    <TITLE>��������</TITLE>
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
    <COLUMN>Ʒ�����</COLUMN>
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
    <DEFAULTVALUE>�³�</DEFAULTVALUE>
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
    <DEFAULTVALUE>����</DEFAULTVALUE>
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
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>2017.03.01</SGLINEITEM>
    <SGLINEITEM>2017.03.20</SGLINEITEM>
    <SGLINEITEM>40223</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 2��</SGLINEITEM>
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
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 4��</SGLINEITEM>
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
<RPTLINEHEIGHT>����</RPTLINEHEIGHT>
<RPTPAGEHEIGHT>66</RPTPAGEHEIGHT>
<RPTPAGEWIDTH>80</RPTPAGEWIDTH>
<RPTTITLETYPE>0</RPTTITLETYPE>
<RPTCURREPORT></RPTCURREPORT>
<RPTREPORTLIST>
</RPTREPORTLIST>
</SQLREPORT>

