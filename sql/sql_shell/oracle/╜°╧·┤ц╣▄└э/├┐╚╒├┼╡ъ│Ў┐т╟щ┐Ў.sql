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
DECLARE
  seldate date;
  sortcode varchar2(15);
  sortcode2 varchar2(15);
begin
  seldate := TO_DATE('\(1,1)', 'YYYY.MM.DD');
  sortcode := trim('\(2,1)')||'%';
  sortcode2 := trim('\(2,1)');

  insert into TMP_TEST2
    (id, char1, int1, int2, Num1,date1 , char2, char3)
    select 1,
           NAME,
           count(distinct GDGID) sku3,
           sum(QTY) QTY,
           sum(TOTAL) TOTAL,
           seldate ,
           controlm,
           replace(sortcode,'%','') 
      from (
      
           SELECT  STORE.NAME,
                   STKOUTDTL.GDGID,
                   STKOUTDTL.QTY,
                   STKOUTDTL.TOTAL,
                   STKOUTLOG.TIME,
                   store.controlm,   --添加商控人员
                   GOODSH.Sort
              FROM STKOUT     STKOUT,
                   STKOUTLOG  STKOUTLOG,
                   STKOUTDTL  STKOUTDTL,
                   GOODSH     GOODSH,
                   MODULESTAT MODULESTAT,
                   STORE      STORE,
                   sortstore,
                   gdstore
             WHERE (STKOUT.NUM = STKOUTDTL.NUM)
               and (STKOUT.CLS = STKOUTDTL.CLS)
               and (STKOUT.NUM = STKOUTLOG.NUM)
               and (STKOUT.CLS = STKOUTLOG.CLS)
               and (STKOUT.STAT = MODULESTAT.NO)
               and (STKOUTDTL.GDGID = GOODSH.GID)
               and (STKOUT.BILLTO = STORE.GID)
               and (STKOUTLOG.STAT = 700)   
               and store.gid = sortstore.gid
               and gdstore.storegid = store.gid
               and gdstore.gdgid = goodsh.gid
            
            ---统配出
            union all
            
            SELECT STORE.NAME,
                   STKOUTDTL.GDGID,
                   -STKOUTDTL.QTY,
                   -STKOUTDTL.TOTAL,
                   STKOUTLOG.TIME,
                   store.controlm,   --添加商控人员
                   GOODSH.Sort
              FROM STKOUTBCK    STKOUT,
                   STKOUTBCKLOG STKOUTLOG,
                   STKOUTBCKDTL STKOUTDTL,
                   GOODSH       GOODSH,
                   MODULESTAT   MODULESTAT,
                   STORE        STORE,
                   sortstore
             WHERE (STKOUT.NUM = STKOUTDTL.NUM)
               and (STKOUT.CLS = STKOUTDTL.CLS)
               and (STKOUT.NUM = STKOUTLOG.NUM)
               and (STKOUT.CLS = STKOUTLOG.CLS)
               and (STKOUT.STAT = MODULESTAT.NO)
               and (STKOUTDTL.GDGID = GOODSH.GID)
               and (STKOUT.BILLTO = STORE.GID)
               and (STKOUTLOG.STAT = 300)
               and store.gid = sortstore.gid
            
            --统配出退
            union all
            
            SELECT STORE.NAME,
                   diralcDTL.GDGID,
                   diralcDTL.QTY,
                   diralcDTL.TOTAL,
                   diralcLOG.TIME,
                   store.controlm,   --添加商控人员
                   GOODSH.Sort
              FROM diralc     diralc,
                   diralcLOG  diralcLOG,
                   diralcDTL  diralcDTL,
                   GOODSH     GOODSH,
                   MODULESTAT MODULESTAT,
                   STORE      STORE,
                   sortstore,
                   gdstore
             WHERE (diralc.NUM = diralcDTL.NUM)
               and (diralc.CLS = diralcDTL.CLS)
               and (diralc.NUM = diralcLOG.NUM)
               and (diralc.CLS = diralcLOG.CLS)
               and (diralc.STAT = MODULESTAT.NO)
               and (diralcDTL.GDGID = GOODSH.GID)
               and (diralc.BILLTO = STORE.GID)
               and (diralcLOG.STAT = 700)
               and store.gid = sortstore.gid
               and gdstore.storegid = store.gid
               and gdstore.gdgid = goodsh.gid
            
            --直配出
            union all
            
            SELECT STORE.NAME,
                   diralcDTL.Gdgid,
                   -diralcDTL.QTY,
                   -diralcDTL.TOTAL,
                   diralcLOG.TIME,
                   store.controlm,   --添加商控人员
                   GOODSH.Sort
              FROM diralc     diralc,
                   diralcLOG  diralcLOG,
                   diralcdtl  diralcDTL,
                   GOODSH     GOODSH,
                   MODULESTAT MODULESTAT,
                   STORE      STORE,
                   sortstore
             WHERE (diralc.NUM = diralcDTL.NUM)
               and (diralc.CLS = diralcDTL.CLS)
               and (diralc.NUM = diralcLOG.NUM)
               and (diralc.CLS = diralcLOG.CLS)
               and (diralc.STAT = MODULESTAT.NO)
               and (diralcDTL.GDGID = GOODSH.GID)
               and (diralc.BILLTO = STORE.GID)
               and (diralcLOG.STAT = 300)
               and store.gid = sortstore.gid
               ) AA
     where AA.TIME >=seldate
       and AA.TIME < seldate + 1
       and (Sort like sortcode  
            or (sortcode2='4' and Sort like '50%'))
     group by AA.NAME ,AA.controlm
     order by AA.NAME
     ;
end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>TMP_TEST2</TABLE>
    <ALIAS>TMP_TEST2</ALIAS>
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
    <TITLE>店名名称</TITLE>
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
    <COLUMN>int1</COLUMN>
    <TITLE>SKU数量</TITLE>
    <FIELDTYPE>3</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>int2</COLUMN>
    <TITLE>配货数量</TITLE>
    <FIELDTYPE>3</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>Num1/10000</COLUMN>
    <TITLE>当日配货量(万)</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>Column1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>TMP_TEST2.char2</COLUMN>
    <TITLE>商控人员</TITLE>
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
    <COLUMN>date1</COLUMN>
    <TITLE>统计日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>TMP_TEST2.char3</COLUMN>
    <TITLE>品类</TITLE>
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
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>179</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>107</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>50</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>date1</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2015.07.09</RIGHTITEM>
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
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>TMP_TEST2.char3</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>4</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
      <PICKNAMEITEM>#TABLE</PICKNAMEITEM>
      <PICKNAMEITEM>'['||CODE||']'||NAME</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>select *
  from (select CODE, '[' || CODE || ']' || NAME
          from sort
         where length(trim(code)) = 2
        union all
        select '', '所有'
          from dual
        union all
        select '4', '售品'
          from dual) aa

 order by length(CODE), CODE</PICKVALUEITEM>
      <PICKVALUEITEM>CODE</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE>所有</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>131</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>119</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>2015.07.09</SGLINEITEM>
    <SGLINEITEM>售品</SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 2：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 3：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 4：</SGLINEITEM>
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

