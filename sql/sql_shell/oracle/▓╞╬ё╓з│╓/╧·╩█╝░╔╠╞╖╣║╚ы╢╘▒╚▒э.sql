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
--����
declare

  SETNO  integer;
  SETNOE integer;
begin

    SETNO  := '\(1,1)';
  SETNOE := '\(2,1)';

  /*SETNO  := '201610';
  SETNOE := '201612';*/

  delete from tmp_test1;
  commit;
  delete from tmp_test2;
  commit;
  delete from tmp_test3;
  commit;
  insert into tmp_test1
    (int1, char1, num1, num2, num3, num4, num5, num6)
    select a.settleno,
           d.asname, --Ʒ��
           0, --���۶�
           0, --ͬʱ���ϡ������人�����ټҸ�����еꡱ�������ɱ�������Խ�ϡ�����������루ֻ��40020��ֵ��
           case
             when b.code != '40020' then
              SUM((a.LSAMT + a.LSTAX) - (a.LSTAMT + a.LSTTAX) +
                  ((a.CBCYAMT + a.CBCYTAX) + (a.CBCY2AMT + a.CBCY2TAX)))
           end LSTOTAL, --���۳ɱ� 
           case
             when (b.code = '40020' or b.code = '30014' or
                  b.name like '%���ɱ�%' or b.name like '%Խ��%') then
              SUM((a.TPCAMT + a.TPCTAX) - (a.TPCTAMT + a.TPCTTAX) +
                  (a.PHCYAMT + a.PHCYTAX))
           end TPTOTAL, --ͳ�京˰��� ��ֻ��40020��ֵ��
           case
             when (b.code != '40020' and b.code != '30014' and
                  b.name not like '%���ɱ�%' and b.name not like '%Խ��%') then
              SUM(decode(a.SALE,
                         13,
                         (a.LSAMT + a.LSTAX) - (a.LSTAMT + a.LSTTAX) +
                         ((a.CBCYAMT + a.CBCYTAX) + (a.CBCY2AMT + a.CBCY2TAX)) +
                         (a.PFAMT + a.PFTAX) - (a.PFTAMT + a.PFTTAX),
                         (a.ZPCAMT + a.ZPCTAX) - (a.ZPCTAMT + a.ZPCTTAX)))
           end ZPTOTAL, --ֱ�京˰���
           case
             when a.SETTLENO = SETNOE and
                  (b.code != '40020' and b.code != '30014' and
                  b.name not like '%���ɱ�%' and b.name not like '%Խ��%') then
              sum(a.qmamt) + sum(a.qmtax)
           end b2 --�ŵ�������ĩ��
      from JXCSMRPT a, store b, h4v_goodssort d
     where a.storegid = b.gid
       and a.gdgid = d.gid
       and a.settleno >= SETNO
       and a.settleno <= SETNOE
       and (d.ascode like '1%' or d.ascode = '24' or d.ascode = '26')
     group by a.settleno, d.asname, b.code, b.name;


  insert into tmp_test2
  
    (
     
     char5 --Ʒ��
    ,
     num1 --���۽��
    ,
     num2 --�������
    ,
     char1 --��������
    
     
     )
  --ͳ���
    SELECT h4v_goodssort.asname asname,
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
           to_char(trunc(Stkoutlog.time), 'YYYYMM')
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

       --and trunc(Stkoutlog.Time) between Bfiledate and Efiledate
       and trunc(Stkoutlog.Time) >= to_date(SETNO, 'yyyymm')
       and trunc(Stkoutlog.Time) < add_months(to_date(SETNOE, 'yyyymm'), 1)

       and GOODS.Wrh = warehouse.gid
       and (h4v_goodssort.ascode like '1%' or h4v_goodssort.ascode = '24' or
           h4v_goodssort.ascode = '26')
       and (STORE.code = '40020' or STORE.code = '30014' or
           STORE.name like '%���ɱ�%' or STORE.name like '%Խ��%')
     group by h4v_goodssort.asname,
              to_char(trunc(Stkoutlog.time), 'YYYYMM'),
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
              end
    
    union all
    --ͳ�����   
    SELECT h4v_goodssort.asname asname,
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
                  ('20', '21', '22', '23', '27', '24', '25', '30') then
              store.rate20
           end jiesuanbili,
           to_char(trunc(STKOUTBCKlog.time), 'YYYYMM')
    
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
       --and trunc(STKOUTBCKlog.Time) between Bfiledate and Efiledate
       and trunc(STKOUTBCKlog.Time) >= to_date(SETNO, 'yyyymm')
       and trunc(STKOUTBCKlog.Time) < add_months(to_date(SETNOE, 'yyyymm'), 1)
       and GOODS.Wrh = warehouse.gid
       and (h4v_goodssort.ascode like '1%' or h4v_goodssort.ascode = '24' or
           h4v_goodssort.ascode = '26')
       and (STORE.code = '40020' or STORE.code = '30014' or
           STORE.name like '%���ɱ�%' or STORE.name like '%Խ��%')
     group by to_char(trunc(STKOUTBCKlog.time), 'YYYYMM'),
              h4v_goodssort.asname,
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
              end
    
    union all
    
    SELECT h4v_goodssort.asname asname,
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
                  ('20', '21', '22', '23', '27', '24', '25', '30') then
              store.rate20
           end jiesuanbili,
           to_char(trunc(DirAlclog.time), 'YYYYMM')
    
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
          --and DirAlc.CLS = 'ֱ���'
       and DirAlc.NUM = DirAlclog.NUM
       and DirAlc.CLS = DirAlclog.CLS
       and DirAlclog.Stat in (300, 1000)
       and DirAlc.STAT = MODULESTAT.NO
       and DirAlc.RECEIVER = STORE.GID
       and DirAlcDTL.GDGID = GOODS.GID
       and GOODS.GID = h4v_goodssort.gid
       --and trunc(DirAlclog.Time) between Bfiledate and Efiledate
       and trunc(DirAlclog.Time) >= to_date(SETNO, 'yyyymm')
       and trunc(DirAlclog.Time) < add_months(to_date(SETNOE, 'yyyymm'), 1)

       and GOODS.Wrh = warehouse.gid
       and GOODS.Wrh = warehouse.gid
       and (h4v_goodssort.ascode like '1%' or h4v_goodssort.ascode = '24' or
           h4v_goodssort.ascode = '26')
       and (STORE.code = '40020' or STORE.code = '30014' or
           STORE.name like '%���ɱ�%' or STORE.name like '%Խ��%')
     group by to_char(trunc(DirAlclog.time), 'YYYYMM'),
              h4v_goodssort.asname,
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
              end
    
    union all
    
    select h4v_goodssort.asname asname,
           
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
                  ('20', '21', '22', '23', '27', '24', '25', '30') then
              store.rate20
           end jiesuanbili,
           to_char(trunc(ALCDIFFlog.time), 'YYYYMM')
    
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
      -- and trunc(ALCDIFFlog.Time) between Bfiledate and Efiledate
       and trunc(ALCDIFFlog.Time) >= to_date(SETNO, 'yyyymm')
       and trunc(ALCDIFFlog.Time) < add_months(to_date(SETNOE, 'yyyymm'), 1)

       and GOODS.Wrh = warehouse.gid
       and (h4v_goodssort.ascode like '1%' or h4v_goodssort.ascode = '24' or
           h4v_goodssort.ascode = '26')
       and (STORE.code = '40020' or STORE.code = '30014' or
           STORE.name like '%���ɱ�%' or STORE.name like '%Խ��%')
     group by to_char(trunc(ALCDIFFlog.time), 'YYYYMM'),
              h4v_goodssort.asname,
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
              end ;
              
    insert into tmp_test1
    (int1, char1, num2)
    select to_number(char1), --��������
           char5, --Ʒ��
           sum(num1 * num2)
      from tmp_test2
     group by char5, char1 --��������
    ;
              

  delete from tmp_test2;
  commit;


  insert into tmp_test2
    (int1, --�ں�
     char1,
     num1,
     num2)
    select a.SETTLENO,
           d.asname, --Ʒ��
           case
             when a.SETTLENO = SETNOE then
              sum(a.qmamt) + sum(a.qmtax)
           end a2, --�ֿܲ������ĩ��
           SUM(a.ZYJAMT + a.ZYJTAX - (a.ZYJTAMT + a.ZYJTTAX)) ZYJTOTAL --��Ӫ����˰���
      from HDSETTLE.ZBJXC a, h4v_goodssort d, store b
     where a.gdgid = d.gid
       and a.STORE = b.gid
       and a.settleno >= SETNO
       and a.settleno <= SETNOE
       and (d.ascode like '1%' or d.ascode = '24' or d.ascode = '26')
     group by a.SETTLENO, d.asname, b.code, b.name;

  insert into tmp_test3
    (int2, --�ڳ�
     int3, --��ĩ
     int1, --�ں�
     char1, --���
     num1, --���۶�
     num2, --���۳ɱ�
     num3, --�����
     num4 --�����
     )
    select SETNO, --�ڳ�
           SETNOE, --��ĩ
           a.int1, --�ں�
           a.char1, --���
           --sum(a.num1), --���������ת�ʱ����С����۶ --����֤
           --sum(a.num2), --����������� --����֤
            sum(nvl(a.num1,0)+nvl(a.num2,0)), --���۶�
           --sum(a.num3), --�ŵ�������±��С����ۺ�˰�� --����֤��24293070.67��
           --sum(a.num4), --���ϡ������人�����ټҸ�����еꡱ�����ɱ�������Խ�ϡ��������̡�����ɱ���+�ŵ�������±��С�ͳ�京˰�� ����֤
           sum(nvl(a.num3,0)+nvl(a.num4,0)), --���۳ɱ� 
           --sum(a.num5), --ֱ�京˰��� ����֤
           --sum(b.num2), --��Ӫ����˰��� ����֤
           sum(nvl(a.num5,0)+nvl(b.num2,0)), --�����
           --sum(a.num6), --�ŵ�������ĩ�� ����֤
           --sum(b.num1), --�ܲ���ĩ��� ����֤
           sum(nvl(a.num6,0)+nvl(b.num1,0)) --�����
      from (select int1,
                   char1,
                   sum(num1) num1,
                   sum(num2) num2,
                   sum(num3) num3,
                   sum(num4) num4,
                   sum(num5) num5,
                   sum(num6) num6
              from tmp_test1
             group by int1, char1) a,
           tmp_test2 b
     where a.char1 = b.char1
       and a.int1 = b.int1
     group by a.int1, a.char1;

  insert into tmp_test3
    (int2, --�ڳ�
     int3, --��ĩ
     int1, --�ں�
     char1, --���
     num1 --���۶�
     )
    select SETNO, --�ڳ�
           SETNOE, --��ĩ
           to_char(a.fildate, 'YYYYMM') fildate,
           b.asname, --Ʒ��
           sum(decode(a.cls, '����', 1, '������', -1) * (a.amt + a.tax)) AMT --���۽��
      from sdrpts a
      left join h4v_goodssort b
        on a.gdgid = b.gid
     where a.cls in
           ('����', '������', '����', '������', '�ɱ�����', '�ɱ�����')
       and a.fildate >= to_date(SETNO, 'yyyymm')
       and a.fildate < add_months(to_date(SETNOE, 'yyyymm'), 1)
       and a.snd != 1000503
       and (b.ascode like '1%' or b.ascode = '24' or b.ascode = '26')
     group by b.asname, to_char(a.fildate, 'YYYYMM')
     order by b.asname;
     
  delete from tmp_test1;
  commit;   
  insert into tmp_test1
    (int2, --�ڳ�
     int3, --��ĩ
     int1, --�ں�
     char1, --���
     num1, --���۶�
     num2, --���۳ɱ�
     num3, --�����
     num4 --�����
     )  select int2, --�ڳ�
     int3, --��ĩ
     int1, --�ں�
     char1, --���
     sum(num1), --���۶�
     sum(num2), --���۳ɱ�
     sum(num3), --�����
     sum(num4) --�����
      from tmp_test3
      group by int2, --�ڳ�
     int3, --��ĩ
     int1, --�ں�
     char1;
  
  
     

  delete from tmp_test2;
  commit;

  insert into tmp_test2
    (int2, --�ڳ�
     int3, --��ĩ
     int1, --�ں�
     char1, --���
     num1, --���۶�
     num2, --���۳ɱ�
     num3, --�����
     num4) --�����
    select int2, --�ڳ�
           int3, --��ĩ
           int1, --�ں�
           '�ܼ�', --���
           sum(num1), --���۶�
           sum(num2), --���۳ɱ�
           sum(num3), --�����
           sum(num4) --�����
      from tmp_test1
     group by int2, --�ڳ�
              int3, --��ĩ
              int1,
              '�ܼ�';

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
  <TABLEITEM>
    <TABLE>tmp_test1</TABLE>
    <ALIAS>tmp_test1</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
</TABLELIST>
<JOINLIST>
  <JOINITEM>
    <LEFT>tmp_test1.int1</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>tmp_test2.int1</RIGHT>
  </JOINITEM>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>to_char(tmp_test1.int1)</COLUMN>
    <TITLE>�ں�</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.char1</COLUMN>
    <TITLE>���</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN> tmp_test1.num1</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num1/tmp_test2.num1</COLUMN>
    <TITLE>��������ռ��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>column1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0000</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN> tmp_test1.num2</COLUMN>
    <TITLE>���۳ɱ�</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num2/tmp_test2.num2</COLUMN>
    <TITLE>���۳ɱ�ռ��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>column2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0000</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN> tmp_test1.num3</COLUMN>
    <TITLE>�����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num3/ tmp_test2.num3</COLUMN>
    <TITLE>�����ռ��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>column3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0000</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN> tmp_test1.num4</COLUMN>
    <TITLE>�����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num4/ tmp_test2.num4</COLUMN>
    <TITLE>�����ռ��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>column4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0000</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int2</COLUMN>
    <TITLE>�ڳ�</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0000</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int3</COLUMN>
    <TITLE>��ĩ</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0000</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>62</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>118</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>86</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>86</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>���</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>tmp_test1.int2</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>201612</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>1</ISQUOTED>
    <PICKNAME>
    </PICKNAME>
    <PICKVALUE>
    </PICKVALUE>
    <DEFAULTVALUE>201612</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test1.int3</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>201612</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>1</ISQUOTED>
    <PICKNAME>
    </PICKNAME>
    <PICKVALUE>
    </PICKVALUE>
    <DEFAULTVALUE>201612</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>201612</SGLINEITEM>
    <SGLINEITEM>201612</SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 2��</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 3��</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 4��</SGLINEITEM>
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
  <DXLOADMETHOD>TRUE</DXLOADMETHOD>
  <DXSHOWGROUP>TRUE</DXSHOWGROUP>
  <DXSHOWFOOTER>TRUE</DXSHOWFOOTER>
  <DXSHOWSUMMARY>TRUE</DXSHOWSUMMARY>
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

