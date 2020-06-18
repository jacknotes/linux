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
  vendorcode varchar2(10);
  vendorname varchar2(20);
begin
  vendorcode := to_char('\(1,1)');
  vendorname := to_char('\(2,1)');

  delete tmp_test2;
  commit;

  insert into tmp_test2
    (char1, ------供应商代码
     char2, ---供应商名称
     char3, ---供应商状态
     num1, ---库存金额
     num2, ---在单金额 
     num3, --已预付款金额
     num4, ---历史入库金额
     num5, ----付款金额  
     num6, ---退货金额
     num11, ---费用金额
     num7, ---未付款金额
     num8, ---已审核预付款金额
     num9, ---已审核付款金额
     num10, ---未审核金额
     num12  ---预付款退款
     
     )
  
    select vendor.code, ---供应商代码
           vendor.name, ---供应商名称
           '正常', ---供应商状态
           nvl(ckMoney.Money, 0), ---库存金额    
           nvl(zdMoney.ototal, 0), --在单金额    
           nvl(YFmoney.YFtotal, 0), --已预付款金额
           nvl(rkMoney.ototal, 0), ---历史入库金额
           nvl(FKMoney.FKtotal, 0), --付款金额   
           nvl(Tmoney.toMoney, 0), ---退货金额
           nvl(fy.amt, 0), ---费用金额
           nvl(nvl(rkMoney.ototal, 0) - nvl(YFmoney.YFtotal, 0) -
               nvl(FKMoney.FKtotal, 0) - nvl(Tmoney.toMoney, 0) -
               nvl(fy.amt, 0)+ nvl(YFHmoney.yfTMoney,0),
               0) , ---未付款金额
           nvl(YFmoney.CYFtotal, 0), --已审核预付款金额
           nvl(FKMoney.CFKtotal, 0), --已审核付款金额  
           nvl(nvl(rkMoney.ototal, 0) - nvl(YFmoney.YFtotal, 0) -
               nvl(FKMoney.FKtotal, 0) - nvl(Tmoney.toMoney, 0) -
               nvl(YFmoney.CYFtotal, 0) - nvl(FKMoney.CFKtotal, 0) -
               nvl(fy.amt, 0) + nvl(YFHmoney.yfTMoney,0),
               0), --未审核金额  
           nvl(YFHmoney.yfTMoney,0) ---预付退金额
      from vendor
      left join
    
     (select sum(ACTINVS.AMT + ACTINVS.TAX) Money, goods.VDRGID
        from ACTINVS
        left join goods
          on ACTINVS.GDGID = goods.gid
       group by goods.VDRGID) ckMoney ---库存金额
        on vendor.gid = ckMoney.VDRGID
    
      left join (select ord.vendor,
                        sum(orddtl.ADALCPRC * orddtl.LACKQTY) ototal
                 
                   from ord
                   left join orddtl
                     on ord.num = orddtl.num
                    and ord.cls = orddtl.cls
                  where PURORDTYPE <> 1
                    and (ord.stat = 200 or
                        (ord.stat = 100 and ord.FINSTAT in ('P')))
                 
                  group by ord.vendor) zdMoney ---在单金额
        on vendor.gid = zdMoney.vendor
    
      left join
    
     (select sum(decode(stat, 900, CntrPrePay.Total,300, CntrPrePay.Total, 0)) YFtotal,
             sum(decode(stat, 100, CntrPrePay.Total, 0)) CYFtotal,
             CntrPrePay.Vendor
        from CntrPrePay
       where stat in (900,100,300)
       group by CntrPrePay.Vendor) YFmoney --已预付款金额
        on vendor.gid = YFmoney.Vendor

     left join
     (select sum(total) yfTMoney,M.Vendor from CTPrePayRtn M where  Stat=900 group by M.Vendor) YFHmoney ---预付款退款金额
     on vendor.gid = YFHmoney.Vendor
    
      left join (select sum(stkin.total) ototal, stkin.vendor
                    from stkin
                   group by stkin.vendor) rkMoney ---入库金额
        on vendor.gid = rkMoney.vendor
    
    /*      left join
    
    (select sum(STKIN.total) SHtotal, STKIN.Vendor
       from STKIN
      where stat in (1000, 300)
      group by STKIN.Vendor) SH --收货金额
       on SH.Vendor = vendor.gid*/
    
      left join (select sum(decode(stat, 900, CNTRPAYCASH.PAYTOTAL, 0)) FKtotal,
                        sum(decode(stat, 100, CNTRPAYCASH.PAYTOTAL, 0)) CFKtotal,
                        CNTRPAYCASH.Vdrgid
                   from CNTRPAYCASH
                  where stat in (100, 900)
                  group by CNTRPAYCASH.Vdrgid) FKMoney --付款金额
        on vendor.gid = FKMoney.Vdrgid
    
      left join
    
     (select sum(TOTAL) toMoney, Vendor
        from (select TOTAL, STKINBCK.Vendor
                from STKINBCK
               where Stat in (100, 300, 700)
                 and cls = '自营进退'
              union all
              select TOTAL, DirAlc.Vendor
                from DirAlc
               where Stat in (100, 300, 700)
                 and cls = '直配出退')
       group by Vendor) Tmoney
        on vendor.gid = Tmoney.Vendor
      left join (select sum(RealAmt) amt, ChgBook.Billto
                   from ChgBook
                  where ChgBook.Stat = 300
                  group by ChgBook.Billto) fy
        on vendor.gid = fy.Billto
    
     where (vendorcode is null or vendor.code = vendorcode)
        or (vendorname is null or vendor.name like vendorname || '%');

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
    <TITLE>供应商代码</TITLE>
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
    <TITLE>供应商名称</TITLE>
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
    <COLUMN>tmp_test2.char3</COLUMN>
    <TITLE>供应商状态</TITLE>
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
    <COLUMN>tmp_test2.num1</COLUMN>
    <TITLE>库存金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
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
    <TITLE>在单金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num4</COLUMN>
    <TITLE>历史入库金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num3</COLUMN>
    <TITLE>历史预付款金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num12</COLUMN>
    <TITLE>历史预付款退款金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num12</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num5</COLUMN>
    <TITLE>历史付款金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num6</COLUMN>
    <TITLE>历史退货金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num6</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num11</COLUMN>
    <TITLE>费用金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num7</COLUMN>
    <TITLE>未付款金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num7</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num8</COLUMN>
    <TITLE>已审核预付款金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num8</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num9</COLUMN>
    <TITLE>已审核付款金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num9</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num10</COLUMN>
    <TITLE>未审核金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num10</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>188</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>98</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>109</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>102</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>66</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>102</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>98</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>66</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>66</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>tmp_test2.char1</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>208010</RIGHTITEM>
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
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>172</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>208010</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
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
  <NUMOFNEXTQRY>1</NUMOFNEXTQRY>
  <NCRITERIALIST>
    <NEXTQUERY>应付供应商金额明细.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>供应商代码等于</LEFT>
      <RIGHT>供应商代码</RIGHT>
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

