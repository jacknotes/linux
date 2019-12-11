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

  SETNO integer;
  SETNOE integer;
begin

  SETNO := '\(1,1)';
  SETNOE:= '\(2,1)';

 
  delete from tmp_test1;
  commit;
  delete from tmp_test2;
  commit;
  delete from tmp_test3;
  commit;

  insert into tmp_test1
    (char1, --Ʒ��
     num1, --�ֿܲ�����ڳ���
     num2, --�ֿܲ������ĩ��
     num3, --�ŵ������ڳ���
     num4, --�ŵ�������ĩ��
     num5) --���۳ɱ�
  
    select d.asname, --Ʒ��
           case
             when a.SETTLENO = SETNO then
              sum(a.qctax) + sum(a.qcamt)
           end a1, --�ֿܲ�����ڳ���
           case
             when a.SETTLENO = SETNOE then
              sum(a.qmamt) + sum(a.qmtax)
           end a2, --�ֿܲ������ĩ��
           null,
           null,
           null
    
      from HDSETTLE.ZBJXC a, h4v_goodssort d
     where a.gdgid = d.gid
       and (a.settleno = SETNO or a.settleno = SETNOE)
       and (d.ascode like '1%' or d.ascode='24')
     group by a.SETTLENO, d.asname;

  insert into tmp_test3
    (char1, --Ʒ��
     num1, --�ֿܲ�����ڳ���
     num2, --�ֿܲ������ĩ��
     num3, --�ŵ������ڳ���
     num4, --�ŵ�������ĩ��
     num5) --���۳ɱ�
    select d.asname, --Ʒ��
           null,
           null,
           case
             when a.SETTLENO = SETNO then
              sum(a.qctax) + sum(a.qcamt)
           end b1, --�ŵ������ڳ���
           case
             when a.SETTLENO = SETNOE then
              sum(a.qmamt) + sum(a.qmtax)
           end b2, --�ŵ�������ĩ��
           sum(lstax) + sum(lsamt) - sum(lsttax) - sum(lstamt) b3 --���۶�
      from JXCSMRPT a, store b, h4v_goodssort d
     where a.storegid = b.gid
       and a.gdgid = d.gid
       and a.settleno >= SETNO
       and a.settleno <= SETNOE
       and (d.ascode like '1%' or d.ascode='24')
       and b.name not like '%���ɱ�%'
       and b.name not like '%Խ��%'
       and b.code != '40020'
     group by a.settleno, d.asname;

   insert into tmp_test2
    (int1,
     int2,
     char1, --Ʒ��
     num1, --�ֿܲ�����ڳ���
     num2, --�ֿܲ������ĩ��
     num3, --�ŵ������ڳ���
     num4, --�ŵ�������ĩ��
     num5) --���۳ɱ�
    select SETNO,
           SETNOE,
           tmp_test1.char1, --Ʒ��
           tmp_test1.num1, --�ֿܲ�����ڳ���
           tmp_test1.num2, --�ֿܲ������ĩ��
           tmp_test3.num3, --�ŵ������ڳ���
           tmp_test3.num4, --�ŵ�������ĩ��
           tmp_test3.num5
      from (select char1, --Ʒ��
                   sum(num1) num1, --�ֿܲ�����ڳ���
                   sum(num2) num2 --�ֿܲ������ĩ��
              from tmp_test1
             group by char1) tmp_test1,
           (select char1, --Ʒ��
                   sum(num3) num3, --�ŵ������ڳ���
                   sum(num4) num4, --�ŵ�������ĩ��
                   sum(num5) num5
              from tmp_test3
             group by char1) tmp_test3
     where tmp_test1.char1 = tmp_test3.char1;

 insert into tmp_test2
    (int1,
     int2,
     char1, --Ʒ��
     num1, --�ֿܲ�����ڳ���
     num2, --�ֿܲ������ĩ��
     num3, --�ŵ������ڳ���
     num4, --�ŵ�������ĩ��
     num5) --���۳ɱ�
    select SETNO,
           SETNOE,
           '�ܼ�', --Ʒ��
          sum(num1), --�ֿܲ�����ڳ���
          sum(num2), --�ֿܲ������ĩ��
          sum(num3), --�ŵ������ڳ���
          sum(num4), --�ŵ�������ĩ��
          sum(num5)
      from tmp_test2
      group by '�ܼ�';



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
  <JOINITEM>
    <LEFT>1</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>1</RIGHT>
  </JOINITEM>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.int1</COLUMN>
    <TITLE>�ڳ�</TITLE>
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
    <COLUMN>tmp_test2.int2</COLUMN>
    <TITLE>��ĩ</TITLE>
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
    <COLUMN>tmp_test2.char1</COLUMN>
    <TITLE>Ʒ��</TITLE>
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
    <COLUMN>tmp_test2.num1</COLUMN>
    <TITLE>�ֿܲ�����ڳ���</TITLE>
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
    <COLUMN>tmp_test2.num2</COLUMN>
    <TITLE>�ֿܲ������ĩ��</TITLE>
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
    <COLUMN>tmp_test2.num3</COLUMN>
    <TITLE>�ŵ������ڳ���</TITLE>
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
    <COLUMN>tmp_test2.num4</COLUMN>
    <TITLE>�ŵ�������ĩ��</TITLE>
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
    <COLUMN>tmp_test2.num5</COLUMN>
    <TITLE>���۳ɱ�</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN> (num5*2)/(num1+num2+num3+num4) </COLUMN>
    <TITLE>�����ת��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>AVG</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>Column1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0000</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>360*(num1+num2+num3+num4) / (num5*2)</COLUMN>
    <TITLE>�����ת����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>AVG</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>Column2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>128</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>128</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>128</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>144</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>77</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>130</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>113</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>Ʒ��</COLUMN>
    <ORDER>DESC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>tmp_test2.int1</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>201608</RIGHTITEM>
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
    <DEFAULTVALUE>201608</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test2.int2</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>201610</RIGHTITEM>
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
    <DEFAULTVALUE>201610</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>124</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>201608</SGLINEITEM>
    <SGLINEITEM>201610</SGLINEITEM>
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

