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
  vendorcode1 varchar2(10);
  vendorid1   integer;
  vendorName1 varchar2(80);
begin
  vendorcode1 := to_char('\(1,1)');

  delete tmp_test2;
  commit;

  select gid, name
    into vendorid1, vendorName1
    from vendorh
   where code = vendorcode1;

  insert into tmp_test2
    (num3, ---˳��
     char1, ------��������
     char2, ---���ݺ�
     num1, ---�����
     num2, ---�������
     int1, ---��Ӧ��ID
     date1, ---����ʱ��
     char3, ---��Ӧ�̴���
     char4 ---��Ӧ������
     )

  
    select 1 o,
           '�����' Name,
           '' orderNum,
           sum(ACTINVS.AMT + ACTINVS.TAX) Money,
           0 fsMoney,
           goods.VDRGID,
           null d,
           vendorcode1,
           vendorName1
      from ACTINVS
      left join goods
        on ACTINVS.GDGID = goods.gid
     where goods.VDRGID = vendorid1
     group by goods.VDRGID
    
    union
    
    select x.o,
           x.name,
           x.ordnum,
           0,
           sum(x.ototal),
           x.vendor,
           x.d,
           vendorcode1,
           vendorName1
      from (select 5 o,
                   '�������' name,
                   '��Ӫ��������:' || ord.num ordnum,
                   0,
                   orddtl.ADALCPRC * orddtl.ACVQTY ototal,
                   ord.vendor,
                   min(ordlog.time) d
              from ord
              left join orddtl
                on ord.num = orddtl.num
               and ord.cls = orddtl.cls
              left join ordlog
                on ord.num = orddtl.num
               and ord.cls = orddtl.cls
             where PURORDTYPE <> 1
               and ord.vendor = vendorid1
             group by ord.vendor, ord.num, orddtl.ADALCPRC, orddtl.ACVQTY) x
     group by x.o, x.name, x.ordnum, x.vendor, x.d
    
    union
    
    select 3 o,
           '��Ԥ������' name,
           'Ԥ�����:' || CntrPrePay.Num orderNum,
           0,
           -CntrPrePay.Total YFtotal,
           CntrPrePay.Vendor,
           max(CNTRPREPAYCHKLOG.ATIME) d,
           vendorcode1,
           vendorName1
      from CntrPrePay, CNTRPREPAYCHKLOG
     where CntrPrePay.Vendor = vendorid1
       and CntrPrePay.num = CNTRPREPAYCHKLOG.Num
       and stat in (300, 900)
     group by CntrPrePay.Num,
           CntrPrePay.Total,
           CntrPrePay.Vendor
              
    
    union
    
    select 4 o,
           '�����Ԥ������' name,
           'Ԥ�����:' || CntrPrePay.Num orderNum,
           0,
           -CntrPrePay.Total YFtotal,
           CntrPrePay.Vendor,
           CNTRPREPAYCHKLOG.ATIME d,
           vendorcode1,
           vendorName1
      from CntrPrePay, CNTRPREPAYCHKLOG
     where CntrPrePay.Vendor = vendorid1
       and CntrPrePay.num = CNTRPREPAYCHKLOG.Num
       and stat = 100

    
    union
    
    select 6 o,
           '������' name,
           '�����:' || CNTRPAYCASH.Num,
           0,
           -CNTRPAYCASH.PAYTOTAL FKtotal,
           CNTRPAYCASH.Vdrgid,
           max(CNTRPAYCASHCHKLOG.ATIME) d,
           vendorcode1,
           vendorName1
      from CNTRPAYCASH, CNTRPAYCASHCHKLOG
     where CNTRPAYCASH.Vdrgid = vendorid1
       and CNTRPAYCASH.NUM = CNTRPAYCASHCHKLOG.NUM
       and CNTRPAYCASH.Chkflag = CNTRPAYCASHCHKLOG.Chkflag
       and CNTRPAYCASH.stat = 900
     group by CNTRPAYCASH.Vdrgid, CNTRPAYCASH.Num, CNTRPAYCASH.PAYTOTAL
    union
    
    select 7 o,
           '����˸�����' name,
           '�����:' || CNTRPAYCASH.Num,
           0,
           -CNTRPAYCASH.PAYTOTAL FKtotal,
           CNTRPAYCASH.Vdrgid,
           max(CNTRPAYCASHCHKLOG.ATIME) d,
           vendorcode1,
           vendorName1
      from CNTRPAYCASH, CNTRPAYCASHCHKLOG
     where CNTRPAYCASH.Vdrgid = vendorid1
       and CNTRPAYCASH.NUM = CNTRPAYCASHCHKLOG.NUM
       and CNTRPAYCASH.Chkflag = CNTRPAYCASHCHKLOG.Chkflag
       and stat = 100
     group by CNTRPAYCASH.Vdrgid, CNTRPAYCASH.Num, CNTRPAYCASH.PAYTOTAL
    
    union
    
    select 8 o,
           '��Ӫ���˽��' name,
           '��Ӫ���˵���:' || STKINBCK.Num,
           0,
           -TOTAL,
           STKINBCK.Vendor,
           max(STKINBCKLOG.TIME) d,
           vendorcode1,
           vendorName1
      from STKINBCK, STKINBCKLOG
     where STKINBCK.Vendor = vendorid1
       and STKINBCK.NUM = STKINBCKLOG.NUM
       and STKINBCK.CLS = STKINBCKLOG.Cls
       and STKINBCKLOG.STAT in (100, 300, 700)
       and STKINBCK.Stat in (100, 300, 700)
       and STKINBCK.cls = '��Ӫ����'
     group by STKINBCK.Num, TOTAL, STKINBCK.Vendor
    union
    select 9 o,
           'ֱ����˽��' name,
           'ֱ����˵���:' || DirAlc.Num,
           0,
           -TOTAL,
           DirAlc.Vendor,
           max(DirAlcLOG.Time) d,
           vendorcode1,
           vendorName1
      from DirAlc, DirAlcLOG
     where DirAlc.Vendor = vendorid1
       and DirAlc.Num = DirAlcLOG.Num
       and DirAlc.Cls = DirAlcLOG.Cls
       and DirAlcLOG.Stat in (100, 300, 700)
       and DirAlc.Stat in (100, 300, 700)
       and DirAlc.cls = 'ֱ�����'
     group by DirAlc.Num, DirAlc.Vendor, TOTAL
    
    union
    select 10 o,
           '���õ�' name,
           '���õ�����:' || ChgBook.Num,
           0,
           -RealAmt,
           ChgBook.Billto Vendor,
           max(ChgBookLOG.Time) d,
           vendorcode1,
           vendorName1
      from ChgBook, ChgBookLOG
     where ChgBook.Billto = vendorid1
       and ChgBook.Num = ChgBookLOG.Num
       and ChgBookLOG.Stat = 300
       and ChgBook.Stat = 300
     group by ChgBook.Num, RealAmt, ChgBook.Billto;



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
    <COLUMN>tmp_test2.char1</COLUMN>
    <TITLE>��������</TITLE>
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
    <COLUMN>tmp_test2.Num3</COLUMN>
    <TITLE>˳��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>Num3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char2</COLUMN>
    <TITLE>���ݺ�</TITLE>
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
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.Num1</COLUMN>
    <TITLE>�����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>Num1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.Num2</COLUMN>
    <TITLE>�������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>Num2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char3</COLUMN>
    <TITLE>��Ӧ�̴���</TITLE>
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
    <COLUMN>tmp_test2.char4</COLUMN>
    <TITLE>��Ӧ������</TITLE>
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
    <COLUMN>tmp_test2.date1</COLUMN>
    <TITLE>����ʱ��</TITLE>
    <FIELDTYPE>11</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>190</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>61</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>228</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>98</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>255</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>1534</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>1534</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>112</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
  <GROUPITEM>
    <COLUMN>tmp_test2.char1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.Num3</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char2</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char3</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char4</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.date1</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>˳��</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
  <ORDERITEM>
    <COLUMN>�����</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>tmp_test2.char3</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>204224</RIGHTITEM>
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
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>204224</SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 2��</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 3��</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 4��</SGLINEITEM>
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
  <DXSHOWFILTER>TRUE</DXSHOWFILTER>
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
<RPTTITLE>Ӧ����Ӧ�̽����ϸ</RPTTITLE>
<RPTGROUPCOUNT>0</RPTGROUPCOUNT>
<RPTGROUPLIST>
</RPTGROUPLIST>
<RPTCOLUMNCOUNT>6</RPTCOLUMNCOUNT>
<RPTCOLUMNWIDTHLIST>
  <RPTCOLUMNWIDTHITEM>99</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>188</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>68</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>98</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>255</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>1534</RPTCOLUMNWIDTHITEM>
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

