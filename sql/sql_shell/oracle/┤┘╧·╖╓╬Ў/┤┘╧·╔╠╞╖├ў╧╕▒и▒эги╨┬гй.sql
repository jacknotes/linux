<VERSION>4.1.1</VERSION>
<SQLQUERY>
<REMARK>
[����]

[Ӧ�ñ���]

[���������]

[��Ҫ�Ĳ�ѯ����]

[ʵ�ַ���]

[����]
modify on 2010.07.01 by ym
ע�͵�---      and (r.fildate = vdate or vdate is null)�����������

modify on 2010.10.11 by liukai
-- Create table
create global temporary table HDTMP_SALDRPT0
(
  ORGKEY        INTEGER,
  SALEDATE      DATE,
  SALEQTY       NUMBER(24,4),
  SALEAMT       NUMBER(24,4),
  SALETAX       NUMBER(24,4),
  SALECAMT      NUMBER(24,4),
  SALECTAX      NUMBER(24,4),
  SALECOUNTS    INTEGER,
  CLIENTPERSALE NUMBER(24,4)
)
on commit preserve rows;
-- Grant/Revoke object privileges 
grant insert, update, delete on HDTMP_SALDRPT0 to ROLE_HDAPP;
grant insert, update, delete on HDTMP_SALDRPT0 to ROLE_HDQRY;
</REMARK>
<BEFORERUN>
declare

  vbegdate   varchar2(200);
  venddate   varchar2(200);
  vstorecode varchar2(200);

begin

  vbegdate := ('\(1,1)');
  venddate := ('\(2,1)');
  vstorecode :=trim('\(3,1)');

  /*vbegdate   := ('201706010000');
  venddate   := ('201706020000');
  vstorecode := trim('');*/

  delete from tmp_test1;
  commit;
  delete from tmp_test2;
  commit;
  delete from tmp_test3;
  commit;

  insert into tmp_test1
    (int1, --�ŵ�id
     int2, --��Ʒid
     num1, --��������
     num2, --����
     num3, --�Ż��ܶ�  
     num4, --ʵ�ս��
     char1, --��������
     char2, --��������
     num5, --���������� 
     num6, --����������� 
     char3 --��ˮ��
     )
    select C.storegid, --�ŵ�id
           A.GID, --��Ʒid
           sum(A.qty), --��������
           A.RTLPRC, --����
           sum(B.FAVAMT), --�Ż��ܶ� B
           sum(A.REALAMT), --ʵ�ս��
           B.promnum, --��������
           B.PROMCLS, --��������
           sum(B.PROMAMT), --���������� 
           sum(B.PROMQTY), --����������� 
           A.flowno --��ˮ��
      from (select posno, flowno, ITEMNO, GID, qty, RTLPRC, favamt, REALAMT
              from buy2
             where posno in (select no from workstation)
               and flowno > vbegdate
               and flowno < venddate) A
      left join (select posno,
                        FLOWNO,
                        ITEMNO,
                        favtype,
                        FAVAMT,
                        PROMNUM,
                        PROMCLS,
                        PROMAMT,
                        PROMQTY
                   from buy21
                  where posno in (select no from workstation)
                    and flowno > vbegdate
                    and flowno < venddate
                    and promnum is not null) B
        on (A.posno = B.posno and A.flowno = B.flowno and
           A.itemno = B.itemno)
      left join workstation C
        on A.posno = C.no
     where ( C.storegid=(select gid from store where code=vstorecode) or vstorecode is null)
     group by C.storegid, A.GID, A.RTLPRC, B.promnum, B.PROMCLS, A.flowno;

  insert into tmp_test2
    (char1, --ʡ��
     char2, --���
     char3, --����
     int2, --�ŵ�gid
     char4, --Ʒ��
     char5, --����
     char6, --����
     char7, --С��
     char8, --��Ʒ����
     char9, --��Ʒ����
     int1, --��Ʒgid
     char10, --��Ʒ����
     num1, --��Ʒ�۸�
     num7, --����
     char11, --����
     char12, --��������
     char13, --��������
     num2, --����������� 
     num3, --�Żݽ�� 
     num4, --���������� 
     num5, --��������
     num6, --ʵ�ս��
     char14 --��ˮ��
     )
    select b.province, --ʡ��
           b.code, --���
           b.name, --����
           a.int1, --�ŵ�id
           c.asname, --Ʒ��
           c.bsname, --����
           c.csname, --����
           c.dsname, --С��
           d.code, --��Ʒ����
           d.code2, --��Ʒ����
           a.int2, --��Ʒid
           d.name, --��Ʒ����
           a.num2, --����
           e.invprc, --����
           d.C_FASEASON, --����
           a.char2, --��������
           a.char1, --��������
           a.num6, --�����������
           a.num3, --�Ż��ܶ�  
           a.num5, --����������        
           a.num1, --��������
           a.num4, --ʵ�ս��
           a.char3--��ˮ��
      from tmp_test1 a
      left join store b
        on a.int1 = b.gid
      left join h4v_goodssort c
        on a.int2 = c.gid
      left join goods d
        on a.int2 = d.gid
      left join actinvs e
        on (a.int2 = e.gdgid and a.int1 = e.store)
     where c.ascode like '1%';

  --���� �����ϻ����

  delete from tmp_test1;
  commit;
  insert into tmp_test1
    (char1, char2, char3)
    select a.num, a.cls, b.name
      from prom a
      left join PrmTopic b
        on a.topic = b.code
    union all
    select a.num, a.cls, b.name
      from promA a
      left join PrmTopic b
        on a.topic = b.code
    union all
    select a.num, '���', b.name
      from promB a
      left join PrmTopic b
        on a.topic = b.code
    union all
    select a.num, '��Ʒ', b.name
      from promC a
      left join PrmTopic b
        on a.topic = b.code;

  --��������
  insert into tmp_test3
    (char1, --ʡ��
     char2, --���
     char3, --����
     int2, --�ŵ�gid
     char4, --Ʒ��
     char5, --����
     char6, --����
     char7, --С��
     char8, --��Ʒ����
     char9, --��Ʒ����
     int1, --��Ʒgid
     char10, --��Ʒ����
     num1, --��Ʒ�۸�
     num7, --����
     char11, --����
     char12, --��������
     char14, --�����
     char13, --��������
     num2, --����������� 
     num3, --�Żݽ�� 
     num4, --���������� 
     num5, --��������
     num6, --ʵ�ս��
     char15--��ˮ��
     )
    select a.char1, --ʡ��
           a.char2, --���
           a.char3, --����
           a.int2, --�ŵ�gid
           a.char4, --Ʒ��
           a.char5, --����
           a.char6, --����
           a.char7, --С��
           a.char8, --��Ʒ����
           a.char9, --��Ʒ����
           a.int1, --��Ʒgid
           a.char10, --��Ʒ����
           a.num1, --��Ʒ�۸�
           a.num7, --����
           a.char11, --����
           a.char12, --��������
           b.char3, --�����
           a.char13, --��������
           sum(a.num2), --����������� 
           sum(a.num3), --�Żݽ�� 
           sum(a.num4), --���������� 
           sum(a.num5), --��������
           sum(a.num6), --ʵ�ս��
           a.char14 --��ˮ��
      from tmp_test2 a
      left join tmp_test1 b
        on (a.char13 = b.char1 and a.char12 = b.char2)
      group by a.char1, --ʡ��
           a.char2, --���
           a.char3, --����
           a.int2, --�ŵ�gid
           a.char4, --Ʒ��
           a.char5, --����
           a.char6, --����
           a.char7, --С��
           a.char8, --��Ʒ����
           a.char9, --��Ʒ����
           a.int1, --��Ʒgid
           a.char10, --��Ʒ����
           a.num1, --��Ʒ�۸�
           a.num7, --����
           a.char11, --����
           a.char12, --��������
           b.char3, --�����
           a.char13, --��������
           a.char14 --��ˮ��
;

  commit;

end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>tmp_test3</TABLE>
    <ALIAS>tmp_test3</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
</TABLELIST>
<JOINLIST>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>4</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char1</COLUMN>
    <TITLE>ʡ��</TITLE>
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
    <TITLE>���</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
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
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
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
    <COLUMN>int2</COLUMN>
    <TITLE>�ŵ�gid</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char4</COLUMN>
    <TITLE>Ʒ��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
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
    <TITLE>����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char6</COLUMN>
    <TITLE>����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char7</COLUMN>
    <TITLE>С��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
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
    <TITLE>��Ʒ����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
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
    <TITLE>��Ʒ����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char9</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>int1</COLUMN>
    <TITLE>��Ʒgid</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
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
    <COLUMN>char10</COLUMN>
    <TITLE>��Ʒ����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char10</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>num1</COLUMN>
    <TITLE>��Ʒ�۸�</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>num7</COLUMN>
    <TITLE>����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num7</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char11</COLUMN>
    <TITLE>����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char13</COLUMN>
    <TITLE>��������</TITLE>
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
    <COLUMN>char14</COLUMN>
    <TITLE>�����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char14</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char12</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char12</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>num2</COLUMN>
    <TITLE>�����������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>num3</COLUMN>
    <TITLE>�Żݽ��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>num4</COLUMN>
    <TITLE>����������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>num5</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>num6</COLUMN>
    <TITLE>���۽��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num6</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char15</COLUMN>
    <TITLE>��ˮ��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char15</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>38</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>62</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>86</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>86</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>242</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>32</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>141</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>97</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>122</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>83</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>84</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>74</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>86</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>77</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>��������</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>char15</LEFT>
    <OPERATOR>></OPERATOR>
    <RIGHT>
      <RIGHTITEM>201706010000</RIGHTITEM>
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
    <DEFAULTVALUE>201706010000</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>char15</LEFT>
    <OPERATOR><</OPERATOR>
    <RIGHT>
      <RIGHTITEM>201706020000</RIGHTITEM>
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
    <DEFAULTVALUE>201706020000</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>char2</LEFT>
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
      <PICKNAMEITEM>#TABLE
</PICKNAMEITEM>
      <PICKNAMEITEM>province</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>select province from province</PICKVALUEITEM>
      <PICKVALUEITEM>province</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>char4</LEFT>
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
      <PICKNAMEITEM>#TABLE</PICKNAMEITEM>
      <PICKNAMEITEM>asname</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>select distinct asname from h4v_goodssort</PICKVALUEITEM>
      <PICKVALUEITEM>asname</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>char8</LEFT>
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
    <LEFT>char9</LEFT>
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
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>135</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>134</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>201706010000</SGLINEITEM>
    <SGLINEITEM>201706020000</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
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
  <NUMOFNEXTQRY>4</NUMOFNEXTQRY>
  <NCRITERIALIST>
    <NEXTQUERY>�ŵ����ڶ���Ʒ������ϸ.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>�������ڴ��ڵ���</LEFT>
      <RIGHT>�������ڴ��ڵ���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>��������С��</LEFT>
      <RIGHT>��������С��</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>�ŵ�������</LEFT>
      <RIGHT>�ŵ����</RIGHT>
    </NCRITERIAITEM>
  </NCRITERIALIST>
  <NCRITERIALIST>
    <NEXTQUERY>�ŵ����ڶ�������ۻ���(����).sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>�������ڴ��ڵ���</LEFT>
      <RIGHT>�������ڴ��ڵ���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>��������С��</LEFT>
      <RIGHT>��������С��</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>�ŵ�������</LEFT>
      <RIGHT>�ŵ����</RIGHT>
    </NCRITERIAITEM>
  </NCRITERIALIST>
  <NCRITERIALIST>
    <NEXTQUERY>�ŵ����ڶ�������ۻ���(����).sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>�������ڴ��ڵ���</LEFT>
      <RIGHT>�������ڴ��ڵ���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>��������С��</LEFT>
      <RIGHT>��������С��</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>�ŵ�������</LEFT>
      <RIGHT>�ŵ����</RIGHT>
    </NCRITERIAITEM>
  </NCRITERIALIST>
  <NCRITERIALIST>
    <NEXTQUERY>�ŵ����ڶ�������ۻ���(С��).sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>�������ڴ��ڵ���</LEFT>
      <RIGHT>�������ڴ��ڵ���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>��������С��</LEFT>
      <RIGHT>��������С��</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>�ŵ�������</LEFT>
      <RIGHT>�ŵ����</RIGHT>
    </NCRITERIAITEM>
  </NCRITERIALIST>
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
  <DXCOLORODDROW>16777215</DXCOLORODDROW>
  <DXCOLOREVENROW>15921906</DXCOLOREVENROW>
  <DXFILTERNAME></DXFILTERNAME>
  <DXFILTERTYPE></DXFILTERTYPE>
  <DXFILTERLIST>
  </DXFILTERLIST>
  <DXSHOWGRIDLINE>1</DXSHOWGRIDLINE>
</DXDBGRIDITEM>
</SQLQUERY>
<SQLREPORT>
<RPTTITLE>�ŵ����ڶ����ۻ���</RPTTITLE>
<RPTGROUPCOUNT>0</RPTGROUPCOUNT>
<RPTGROUPLIST>
</RPTGROUPLIST>
<RPTCOLUMNCOUNT>8</RPTCOLUMNCOUNT>
<RPTCOLUMNWIDTHLIST>
  <RPTCOLUMNWIDTHITEM>73</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>58</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>58</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>79</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>99</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>162</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>142</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>125</RPTCOLUMNWIDTHITEM>
</RPTCOLUMNWIDTHLIST>
<RPTLEFTMARGIN>40</RPTLEFTMARGIN>
<RPTORIENTATION>0</RPTORIENTATION>
<RPTCOLUMNS>1</RPTCOLUMNS>
<RPTHEADERLEVEL>0</RPTHEADERLEVEL>
<RPTPRINTCRITERIA>TRUE</RPTPRINTCRITERIA>
<RPTVERSION></RPTVERSION>
<RPTNOTE></RPTNOTE>
<RPTFONTSIZE>9</RPTFONTSIZE>
<RPTLINEHEIGHT>����</RPTLINEHEIGHT>
<RPTPAGEHEIGHT>66</RPTPAGEHEIGHT>
<RPTPAGEWIDTH>80</RPTPAGEWIDTH>
<RPTTITLETYPE>0</RPTTITLETYPE>
<RPTCURREPORT></RPTCURREPORT>
<RPTREPORTLIST>
</RPTREPORTLIST>
</SQLREPORT>

