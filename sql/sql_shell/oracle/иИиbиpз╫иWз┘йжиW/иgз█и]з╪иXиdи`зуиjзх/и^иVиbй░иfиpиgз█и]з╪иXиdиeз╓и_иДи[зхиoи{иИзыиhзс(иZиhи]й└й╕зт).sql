<VERSION>4.1.0</VERSION>
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
vbegdate date;
venddate date;
vvdrcode varchar2(50);
begin
  vbegdate := to_date('\(1,1)','yyyy.mm.dd');
  venddate := to_date('\(2,1)','yyyy.mm.dd');
  vvdrcode := trim('\(3,1)')||'%';

     --进货
    insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
    select s.billto,'自营进','自营进',s.num,l.stat,trunc(l.time),s.total,s.stat
    from stkin s , stkinlog l
    where s.num=l.num
      and s.cls=l.cls
      and l.stat in (1000, 1020, 1040, 320 ,340)
      and l.time < venddate + 1
      and l.time >= vbegdate
      and s.billto in (select gid from vendorh where code like vvdrcode );

    --进货
    insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
    select d.billto,'直配出','直配出',d.num,l.stat,trunc(l.time),d.total,d.stat
    from DIRALC d,diralclog l
    where d.num =l.num
      and d.cls=l.cls
      and l.stat in (1000, 1020, 1040, 320, 340)
      and l.cls='直配出'
      and l.time < venddate + 1
      and l.time >= vbegdate
      and d.billto in (select gid from vendorh where code like vvdrcode );

     --退货金额
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     select s.billto,'自营进退','自营进退',s.num,l.stat,trunc(l.time),s.total,s.stat
     from stkinbck s,stkinbcklog l
     where s.num=l.num
       and s.cls=l.cls
       and l.stat in (700,720,740,320,340)
      and l.time < venddate + 1
      and l.time >= vbegdate
      and s.billto in (select gid from vendorh where code like vvdrcode );

     --退货金额
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     select d.billto,'直配出退','直配出退',d.num,l.stat,trunc(l.time),d.total,d.stat
     from DIRALC d,diralclog l
     where d.num =l.num
       and d.cls=l.cls
       and l.stat in (700, 720, 740, 320, 340)
       and l.cls='直配出退'
      and l.time < venddate + 1
      and l.time >= vbegdate
      and d.billto in (select gid from vendorh where code like vvdrcode );

     --已付货款
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     select a.vdrgid,'付款单','货款',a.num,l.chkflag,trunc(l.atime),a.SALETOTAL,a.stat
     from cntrpaycash a ,CNTRPAYCASHCHKLOG l
     where a.num = l.num
       and l.chkflag in (900,920,940,320,340)
       and l.atime< venddate + 1
       and l.atime>= vbegdate
       and A.vdrgid in (select gid from vendorh where code like vvdrcode );

     --费用发生
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     SELECT c.BILLTO,'费用单',c.chgcode,c.num,l.stat,trunc(l.time),c.REALAMT*c.paydirect,c.stat
     FROM CHGBOOK c,CHGBOOKlog l
     WHERE c.num =l.num
      and l.STAT in (500,520,540,320,340)
      and l.time< venddate + 1
      and l.time>= vbegdate
      and c.billto in (select gid from vendorh where code like vvdrcode );

     --费用交款
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     select a.vgid,'交款单','交款单',a.num,l.stat,trunc(l.time),a.paytotal,a.stat
       from VDRPAY a,Vdrpaylog l
      where a.num =l.num
      and l.stat in (1800,1820,1840,320,340)
      and l.time< venddate + 1
      and l.time>= vbegdate
      and a.vgid in (select gid from vendorh where code like vvdrcode );

     --费用退款
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     select a.vendor,'退款单','退款单',a.num,l.tostat,trunc(l.opertime),a.total,a.stat
     from CTVDRPAYRTN a,CTVDRPAYRTNlog l
     where a.num =l.num
       and l.tostat in(900,920,940,320,340)
       and l.opertime< venddate + 1
       and l.opertime>= vbegdate
       and a.vendor in (select gid from vendorh where code like vvdrcode);

     --费用抵扣-货款抵扣
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     select a.vdrgid,'付款单','费用',a.num,l.chkflag,trunc(l.atime),a.feetotal,a.stat
     from cntrpaycash a ,CNTRPAYCASHCHKLOG l
     where a.num = l.num
       and l.chkflag in (900,920,940,320,340)
       and l.atime< venddate + 1
       and l.atime>= vbegdate
       and A.vdrgid in (select gid from vendorh where code like vvdrcode);
     --费用抵扣-进货抵扣？？？

     --预付付款
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     SELECT a.VENDOR,'预付付款单','预付付款单',a.num,l.chkflag,trunc(l.atime),a.TOTAL,a.stat
     FROM CNTRPREPAY a,Cntrprepaychklog l
     WHERE a.num = l.num
       and l.chkflag in (900,920,940,320,340)
       and l.atime< venddate + 1
       and l.atime>= vbegdate
       and A.VENDOR in (select gid from vendorh where code like vvdrcode);

     --预付还款
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     SELECT a.VENDOR,'预付还款单','预付还款单',a.num,l.tostat,trunc(l.opertime),a.TOTAL,a.stat
     FROM CTPrePayRtn a,Ctprepayrtnlog l
     WHERE a.num = l.num
       and l.tostat in (900,920,940,320,340)
       and l.opertime< venddate + 1
       and l.opertime>= vbegdate
       and A.VENDOR in (select gid from vendorh where code like vvdrcode) ;

     --预付使用
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     select a.vdrgid,'付款单','预付款',a.num,l.chkflag,trunc(l.atime),a.prepaytotal,a.stat
     from cntrpaycash a ,CNTRPAYCASHCHKLOG l
     where a.num = l.num
       and l.chkflag in (900,920,940,320,340)
       and l.atime< venddate + 1
       and l.atime>= vbegdate
       and A.vdrgid in (select gid from vendorh where code like vvdrcode);

     --压库收取
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     SELECT a.vENDOR,'压库收款单','压库收款单',a.num,l.stat,trunc(l.time),a.TOTAL,a.stat
     FROM CNTRDPTBILL a,CNTRDPTBILLlog l
     WHERE a.num = l.num
       and a.cls = l.cls
       and a.cls = '收'
       and l.STAT in (1800,1820,1840,900,920,940,320,340)
      and l.time< venddate + 1
      and l.time>= vbegdate
      and A.VENDOR in (select gid from vendorh where code like vvdrcode);


     --压库退还
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     SELECT a.vENDOR,'压库付款单','压库付款单',a.num,l.stat,trunc(l.time),a.TOTAL,a.stat
     FROM CNTRDPTBILL a,CNTRDPTBILLlog l
     WHERE a.num = l.num
       and a.cls = l.cls
       and a.cls = '付'
       and l.STAT in (1800,1820,1840,900,920,940,320,340)
      and l.time< venddate + 1
      and l.time>= vbegdate
      and A.VENDOR in (select gid from vendorh where code like vvdrcode);

     commit;

end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>H4RTMP_VDRDocuments</TABLE>
    <ALIAS>H4RTMP_VDRDocuments</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD>abc</INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>VENDORH</TABLE>
    <ALIAS>VENDORH</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>MODULESTAT</TABLE>
    <ALIAS>MODULESTAT</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>MODULESTAT</TABLE>
    <ALIAS>MODULESTAT__1</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>CTCHGDEF</TABLE>
    <ALIAS>CTCHGDEF</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
</TABLELIST>
<JOINLIST>
  <JOINITEM>
    <LEFT>H4RTMP_VDRDocuments.vdrkey</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>VENDORH.GID</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>MODULESTAT.NO</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>H4RTMP_VDRDocuments.ocrstat</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>MODULESTAT__1.NO</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>H4RTMP_VDRDocuments.stat</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>H4RTMP_VDRDocuments.subject</LEFT>
    <OPERATOR>*=</OPERATOR>
    <RIGHT>CTCHGDEF.CODE</RIGHT>
  </JOINITEM>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>2</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>VENDORH.CODE</COLUMN>
    <TITLE>供应商代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>CODE</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>VENDORH.NAME</COLUMN>
    <TITLE>供应商名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>NAME</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_VDRDocuments.cls</COLUMN>
    <TITLE>单据类型</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>cls</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>nvl( CTCHGDEF.NAME ,H4RTMP_VDRDocuments.subject)</COLUMN>
    <TITLE>科目</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>subject</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_VDRDocuments.num</COLUMN>
    <TITLE>单据号</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_VDRDocuments.ocrdate</COLUMN>
    <TITLE>业务发生日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>ocrdate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>MODULESTAT.STATNAME</COLUMN>
    <TITLE>业务发生状态</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>STATNAME</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_VDRDocuments.total</COLUMN>
    <TITLE>发生金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>total</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>MODULESTAT__1.STATNAME</COLUMN>
    <TITLE>单据当前状态</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>STATNAME1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>170</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>97</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>109</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>136</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>122</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>118</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>125</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>业务发生日期</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>H4RTMP_VDRDocuments.ocrdate</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2010.10.05</RIGHTITEM>
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
    <LEFT>H4RTMP_VDRDocuments.ocrdate</LEFT>
    <OPERATOR><=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2010.10.05</RIGHTITEM>
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
    <LEFT>VENDORH.CODE</LEFT>
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
  <CRITERIAITEM>
    <LEFT>H4RTMP_VDRDocuments.cls</LEFT>
    <OPERATOR>IN</OPERATOR>
    <RIGHT>
      <RIGHTITEM>费用单,交款单,退款单</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
      <PICKNAMEITEM>费用类</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>费用单,交款单,退款单</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE>费用类</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>138</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>149</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>121</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>118</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>2010.10.05</SGLINEITEM>
    <SGLINEITEM>2010.10.05</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM>费用类</SGLINEITEM>
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
  <DXCOLORODDROW>16777215</DXCOLORODDROW>
  <DXCOLOREVENROW>15921906</DXCOLOREVENROW>
  <DXFILTERNAME></DXFILTERNAME>
  <DXFILTERLIST>
  </DXFILTERLIST>
  <DXSHOWGRIDLINE>1</DXSHOWGRIDLINE>
</DXDBGRIDITEM>
</SQLQUERY>
<SQLREPORT>
<RPTTITLE>日期段供应商单据汇总查询</RPTTITLE>
<RPTGROUPCOUNT>0</RPTGROUPCOUNT>
<RPTGROUPLIST>
</RPTGROUPLIST>
<RPTCOLUMNCOUNT>23</RPTCOLUMNCOUNT>
<RPTCOLUMNWIDTHLIST>
  <RPTCOLUMNWIDTHITEM>90</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>170</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>97</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>92</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>79</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>109</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>101</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>103</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>89</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>88</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>104</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>92</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>101</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>90</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>105</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>89</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>102</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>106</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>109</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>85</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>80</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>87</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>90</RPTCOLUMNWIDTHITEM>
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

