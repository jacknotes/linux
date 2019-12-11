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
  ClientCode varchar2(10);
begin
  ClientCode := '\(1,1)';
  --ClientCode := '000002';

  delete from tmp_test1;
  commit;
  delete from tmp_test2;
  commit;

  insert into tmp_test1
    (char1, --�ͻ�����
     char2, --�ͻ�����
     char3, --��λ����
     char4, --��λ����
     char5, --Ʒ����� 
     char6, --Ʒ������
     char7, --��������
     char8, --��������
     char9, --С������
     char10, --��Ʒ����
     char11, --��Ʒ����
     char12, --��Ʒ����
     char13, --��ƷӢ������
     num1, --��Ʒ����
     num2, --�ۼ�
     num3, --�ڵ�����
     num4, --�ܿ��
     num5, --�ܽ��
     num6  --������
     )
  ---ͳ��
    SELECT case
             when store.code in ('40127', '40144') then
              '000001'
             else
              '000002'
           end Scode, --�ͻ�����
           case
             when store.name like '%���ɱ�%' then
              '���ɱ�'
             else
              'Խ��'
           end Sname, --�ͻ�����       
           warehouse.code, --��λ����
           warehouse.name, --��λ����
           h4v_goodssort.ascode, --Ʒ����� 
           h4v_goodssort.asname, --Ʒ������
           h4v_goodssort.bsname, --��������
           h4v_goodssort.csname, --��������
           h4v_goodssort.dsname, --С������
           goods.code, --��Ʒ����
           goods.code2, --��Ʒ����
           goods.name, --��Ʒ����
           goods.ename, --��ƷӢ������
           sum(STKOUTDTL.qty), --��Ʒ����
           goods.rtlprc, --�ۼ�
           0, --�ڵ����� ����Ϊ�����г��Ѿ�������ģ�飬ͳ����û�е��ݣ�
           sum(STKOUTDTL.qty), --�ܿ�� ���ڵ���+����������
           sum(STKOUTDTL.qty * goods.rtlprc), --�ܽ��
           sum(STKOUTDTL.Total)--������
      FROM STKOUT        STKOUT,
           STKOUTDTL     STKOUTDTL,
           MODULESTAT    MODULESTAT,
           STORE         STORE,
           GOODS         GOODS,
           h4v_goodssort h4v_goodssort,
           warehouse     warehouse
     WHERE STKOUT.NUM = STKOUTDTL.NUM
       and STKOUT.Cls = STKOUTDTL.Cls
       and STKOUT.CLS = 'ͳ���'
       and Stkout.Stat in (300, 700, 1000) --���ջ� ״̬
       and STKOUT.STAT = MODULESTAT.NO
       and STKOUT.BILLTO = STORE.GID
       and STKOUTDTL.GDGID = GOODS.GID
       and GOODS.GID = h4v_goodssort.gid
       and GOODS.Wrh = warehouse.gid
       and STORE.CODE in ('40127', '40144', '40223')
       and h4v_goodssort.ascode in
           ('10', '11', '12', '13', '14,','15', '16', '17', '18', '19', '26')
     group by case
                when store.code in ('40127', '40144') then
                 '000001'
                else
                 '000002'
              end, --�ͻ�����
              case
                when store.name like '%���ɱ�%' then
                 '���ɱ�'
                else
                 'Խ��'
              end, --�ͻ�����
              warehouse.code, --��λ����
              warehouse.name, --��λ����
              h4v_goodssort.ascode, --Ʒ����� 
              h4v_goodssort.asname, --Ʒ������
              h4v_goodssort.bsname, --��������
              h4v_goodssort.csname, --��������
              h4v_goodssort.dsname, --С������
              goods.code, --��Ʒ����
              goods.code2, --��Ʒ����
              goods.name, --��Ʒ����
              goods.ename, --��ƷӢ������
              goods.rtlprc
    
    union all
    --ֱ��
    
    SELECT '000002', --�ͻ�����
           'Խ��', --�ͻ�����
           warehouse.code, --��λ����
           warehouse.name, --��λ����
           h4v_goodssort.ascode, --Ʒ����� 
           h4v_goodssort.asname, --Ʒ������
           h4v_goodssort.bsname, --��������
           h4v_goodssort.csname, --��������
           h4v_goodssort.dsname, --С������
           goods.code, --��Ʒ����
           goods.code2, --��Ʒ����
           goods.name, --��Ʒ����
           goods.ename, --��ƷӢ������
           sum(DirAlcDTL.qty), --��Ʒ����
           goods.rtlprc, --�ۼ�
           0, --�ڵ����� ����Ϊ�����г��Ѿ�������ģ�飬ͳ����û�е��ݣ�
           sum(DirAlcDTL.qty), --�ܿ�� ���ڵ���+����������
           sum(DirAlcDTL.qty * goods.rtlprc) ,--�ܽ��
           sum(DirAlcDTL.Total)--������
      FROM DirAlc        DirAlc,
           DirAlcDTL     DirAlcDTL,
           MODULESTAT    MODULESTAT,
           STORE         STORE,
           GOODS         GOODS,
           h4v_goodssort h4v_goodssort,
           warehouse     warehouse
     WHERE DirAlc.NUM = DirAlcDTL.NUM
       and DirAlc.Cls = DirAlcDTL.Cls
       and DirAlc.CLS = 'ֱ���'
       and DirAlc.Stat in (300, 700, 1000) --���ջ� ״̬
       and DirAlc.STAT = MODULESTAT.NO
       and DirAlc.RECEIVER = STORE.GID
       and DirAlcDTL.GDGID = GOODS.GID
       and GOODS.GID = h4v_goodssort.gid
       and GOODS.Wrh = warehouse.gid
       and STORE.CODE in ('40127', '40144', '40223')
       and h4v_goodssort.ascode in
           ('10', '11', '12', '13', '14,','15', '16', '17', '18', '19', '26')
     group by warehouse.code, --��λ����
              warehouse.name, --��λ����
              h4v_goodssort.ascode, --Ʒ����� 
              h4v_goodssort.asname, --Ʒ������
              h4v_goodssort.bsname, --��������
              h4v_goodssort.csname, --��������
              h4v_goodssort.dsname, --С������
              goods.code, --��Ʒ����
              goods.code2, --��Ʒ����
              goods.name, --��Ʒ����
              goods.ename, --��ƷӢ������
              goods.rtlprc
    
    union all
    --����
    
    SELECT client.code, --�ͻ�����
           client.name, --�ͻ�����
           warehouse.code, --��λ����
           warehouse.name, --��λ����
           h4v_goodssort.ascode, --Ʒ����� 
           h4v_goodssort.asname, --Ʒ������
           h4v_goodssort.bsname, --��������
           h4v_goodssort.csname, --��������
           h4v_goodssort.dsname, --С������
           goods.code, --��Ʒ����
           goods.code2, --��Ʒ����
           goods.name, --��Ʒ����
           goods.ename, --��ƷӢ������
           sum(case
                 when Stkout.Stat in (300, 700, 1000) then
                  STKOUTDTL.qty
                 else
                  0
               end) qty, --��Ʒ����
           goods.rtlprc, --�ۼ�
           
           sum(case
                 when Stkout.Stat = 100 then
                  STKOUTDTL.qty
                 else
                  0
               end) qty_zd, --�ڵ����� 
           
           sum(STKOUTDTL.qty), --�ܿ�� ���ڵ���+����������
           sum(STKOUTDTL.qty * goods.rtlprc), --�ܽ��
           sum(STKOUTDTL.Total)--������
      FROM STKOUT        STKOUT,
           STKOUTDTL     STKOUTDTL,
           MODULESTAT    MODULESTAT,
           client        client,
           GOODS         GOODS,
           h4v_goodssort h4v_goodssort,
           warehouse     warehouse
     WHERE STKOUT.NUM = STKOUTDTL.NUM
       and STKOUT.Cls = STKOUTDTL.Cls
       and STKOUT.CLS = '����'
       and Stkout.Stat in (100, 300, 700, 1000) --���ջ� ״̬
       and STKOUT.STAT = MODULESTAT.NO
       and STKOUT.BILLTO = client.GID
       and STKOUTDTL.GDGID = GOODS.GID
       and GOODS.GID = h4v_goodssort.gid
       and GOODS.Wrh = warehouse.gid
       and (ClientCode is null or client.CODE = ClientCode)
       and h4v_goodssort.ascode in
           ('10', '11', '12', '13', '14,','15', '16', '17', '18', '19', '26')
     group by client.code, --�ͻ�����
              client.name, --�ͻ�����
              warehouse.code, --��λ����
              warehouse.name, --��λ����
              h4v_goodssort.ascode, --Ʒ����� 
              h4v_goodssort.asname, --Ʒ������
              h4v_goodssort.bsname, --��������
              h4v_goodssort.csname, --��������
              h4v_goodssort.dsname, --С������
              goods.code, --��Ʒ����
              goods.code2, --��Ʒ����
              goods.name, --��Ʒ����
              goods.ename, --��ƷӢ������
              goods.rtlprc --�ۼ�
    ;

  insert into tmp_test2
    (char1, --�ͻ�����
     char2, --�ͻ�����
     char3, --��λ����
     char4, --��λ����
     char5, --Ʒ����� 
     char6, --Ʒ������
     char7, --��������
     char8, --��������
     char9, --С������
     char10, --��Ʒ����
     char11, --��Ʒ����
     char12, --��Ʒ����
     char13, --��ƷӢ������
     num1, --��Ʒ����
     num2, --�ۼ�
     num3, --�ڵ�����
     num4, --�ܿ��
     num5, --�ܽ��
     num6  --������
     )
    select char1, --�ͻ�����
           char2, --�ͻ�����
           char3, --��λ����
           char4, --��λ����
           char5, --Ʒ����� 
           char6, --Ʒ������
           char7, --��������
           char8, --��������
           char9, --С������
           char10, --��Ʒ����
           char11, --��Ʒ����
           char12, --��Ʒ����
           char13, --��ƷӢ������
           sum(num1), --��Ʒ����
           num2, --�ۼ�
           sum(num3), --�ڵ�����
           sum(num4), --�ܿ��
           sum(num5), --�ܽ��
           sum(num6)--������
      from tmp_test1
      where (ClientCode is null or char1= ClientCode)
     group by char1, --�ͻ�����
              char2, --�ͻ�����
              char3, --��λ����
              char4, --��λ����
              char5, --Ʒ����� 
              char6, --Ʒ������
              char7, --��������
              char8, --��������
              char9, --С������
              char10, --��Ʒ����
              char11, --��Ʒ����
              char12, --��Ʒ����
              char13, --��ƷӢ������
              num2 --�ۼ�
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
    <COLUMN>char1</COLUMN>
    <TITLE>�ͻ�����</TITLE>
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
    <TITLE>�ͻ�����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <TITLE>��λ����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <COLUMN>char4</COLUMN>
    <TITLE>��λ����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <TITLE>Ʒ�����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <TITLE>Ʒ������</TITLE>
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
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char7</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <TITLE>��������</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <TITLE>С������</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <COLUMN>char10</COLUMN>
    <TITLE>��Ʒ����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <COLUMN>char11</COLUMN>
    <TITLE>��Ʒ����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <COLUMN>char12</COLUMN>
    <TITLE>��Ʒ����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <COLUMN>char13</COLUMN>
    <TITLE>��ƷӢ������</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <COLUMN>num1</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
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
    <COLUMN>num2</COLUMN>
    <TITLE>�ۼ�</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
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
    <TITLE>�ڵ�����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
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
    <TITLE>�ܿ��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
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
    <TITLE>�ܽ��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
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
    <TITLE>������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
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
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>122</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>38</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>145</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>146</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>103</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>55</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>94</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>51</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
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
    <LEFT>char1</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>000005</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
      <PICKNAMEITEM>#TABLE</PICKNAMEITEM>
      <PICKNAMEITEM>code</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>select code from client</PICKVALUEITEM>
      <PICKVALUEITEM>code</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
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
      <PICKNAMEITEM>#TABLE</PICKNAMEITEM>
      <PICKNAMEITEM>name</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>select name from client</PICKVALUEITEM>
      <PICKVALUEITEM>name</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>char10</LEFT>
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
    <LEFT>char11</LEFT>
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
    <LEFT>char6</LEFT>
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
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>000005</SGLINEITEM>
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
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 3��</SGLINEITEM>
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

