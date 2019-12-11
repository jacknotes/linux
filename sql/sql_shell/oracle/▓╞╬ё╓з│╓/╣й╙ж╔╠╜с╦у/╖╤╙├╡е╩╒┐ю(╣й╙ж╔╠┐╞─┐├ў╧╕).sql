<VERSION>4.1.0</VERSION>
<SQLQUERY>
<REMARK>
[标题]

[应用背景]
该报表用于查看费用单的 应收金额，已收金额，待收金额。

[结果列描述]
应收金额 = 已审核 或者 已完成 的费用单金额；
已收金额 = 已收款的交款单费用金额 + 已付款付款单费用金额；
待收金额 = 应收金额 - 已收金额；

[必要的查询条件]
日期：取值为费用单的“发生日期”

[实现方法]

[其它]
该报表为汇总，另外有一明细报表配合使用。

create global temporary table h4rtmp_chgbookview
(
fildate date, 
vendor varchar2(80), 
billnum varchar2(20), 
stat varchar2(30), 
chginfo varchar2(40), 
shouldpay number(24,2), 
realamt number(24,2), 
paydirect varchar2(10), 
gatheringmode varchar2(20),
flag varchar2(20)
)
on commit preserve rows;
grant insert,delete,update on h4rtmp_chgbookview to ROLE_HDAPP;
grant insert,delete,update on h4rtmp_chgbookview to ROLE_HDQRY;
/
exec hdcreatesynonym('h4rtmp_chgbookview');
exec granttoqryrole('h4rtmp_chgbookview');

create global temporary table h4rtmp_chgbookviewex
(
fildate date, 
vendor varchar2(80), 
billnum varchar2(20), 
stat varchar2(30), 
chginfo varchar2(40), 
shouldpay number(24,2), 
realamt number(24,2), 
paydirect varchar2(10), 
gatheringmode varchar2(20),
flag varchar2(20)
)
on commit preserve rows;
grant insert,delete,update on h4rtmp_chgbookviewex to ROLE_HDAPP;
grant insert,delete,update on h4rtmp_chgbookviewex to ROLE_HDQRY;
/
exec hdcreatesynonym('h4rtmp_chgbookviewex');
exec granttoqryrole('h4rtmp_chgbookviewex');
</REMARK>
<BEFORERUN>
declare
	vbdate	date;
	vedate	date;
	vtimeflag	varchar2(20);

begin

	delete from h4rtmp_chgbookview; 
	delete from h4rtmp_chgbookviewex; 
	commit;
	
	vbdate := to_date(trim('\(2,1)'),'YYYY.MM.DD');
	vedate := to_date(trim('\(3,1)'),'YYYY.MM.DD');
	vtimeflag := trim('\(4,1)');
	
	if vtimeflag = '按发生日期' then
		--- 应收
		insert into h4rtmp_chgbookviewex(vendor,CHGINFO,shouldpay)
		select v.name||'['||v.code||']',D.name||'['||D.code||']', sum(c.paydirect * c.realamt)
		from chgbook c, vendor v,CTCHGDEF D
		where c.vendor = v.gid AND C.CHGCODE=D.CODE
			and c.stat in (500,300)
			and (c.ocrdate < vedate or vedate is null)
			and (c.ocrdate >= vbdate or vbdate is null)
		group by v.code, v.name,d.code,d.name;

		-- 已收
		insert into h4rtmp_chgbookviewex(vendor,CHGINFO,realamt)
		select v.name||'['||v.code||']',D.name||'['||D.code||']', sum(c.paydirect * c.paytotal)
		from chgbook c, vendor v,CTCHGDEF D
		where c.vendor = v.gid AND C.CHGCODE=D.CODE
			and c.stat in (500,300)
			and (c.ocrdate < vedate or vedate is null)
			and (c.ocrdate >= vbdate or vbdate is null)
		group by v.code, v.name,d.code,d.name;
	
	else
	
	--- 按填单日期
			--- 应收
		insert into h4rtmp_chgbookviewex(vendor,CHGINFO,shouldpay)
		select v.name||'['||v.code||']',D.name||'['||D.code||']', sum(c.paydirect * c.realamt)
		from chgbook c, vendor v,CTCHGDEF D
		where c.vendor = v.gid AND C.CHGCODE=D.CODE
			and c.stat in (500,300)
			and (c.fildate < vedate or vedate is null)
			and (c.fildate >= vbdate or vbdate is null)
		group by v.code, v.name,d.code,d.name;

		-- 已收
		insert into h4rtmp_chgbookviewex(vendor,CHGINFO,realamt)
		select v.name||'['||v.code||']',D.name||'['||D.code||']', sum(c.paydirect * c.paytotal)
		from chgbook c, vendor v,CTCHGDEF D
		where c.vendor = v.gid AND C.CHGCODE=D.CODE
			and c.stat in (500,300)
			and (c.fildate < vedate or vedate is null)
			and (c.fildate >= vbdate or vbdate is null)
		group by v.code, v.name,d.code,d.name;

	end if;
	/*
		--- 交款单
	select '['||v.code||']'||v.name, sum(dtl.paytotal)
	from chgbook c, vendor v, vdrpay mst, vdrpaydtl dtl
	where c.vendor = v.gid
		and dtl.chgnum = c.num
		and dtl.num = mst.num
		and c.stat in (500,300)
		and mst.stat = 1800
		and (c.ocrdate < vedate or vedate is null)
		and (c.ocrdate >= vbdate or vbdate is null)
	group by v.code, v.name
	union all
	--- 付款单
	select '['||v.code||']'||v.name, sum(dtl.paytotal)
	from chgbook c, cntrpaycashdtl dtl, cntrpaycash mst, vendor v
	where c.num = dtl.ivccode
		and dtl.num = mst.num
		and c.vendor = v.gid
		and c.vendor = mst.vdrgid
		and dtl.chgtype = '费用单'
		and mst.stat = 900
		and c.stat in (500,300)
		and (c.ocrdate < vedate or vedate is null)
		and (c.ocrdate >= vbdate or vbdate is null)
	group by v.code, v.name;
	*/

	insert into h4rtmp_chgbookview(vendor,chginfo, shouldpay, realamt, fildate, flag)
	select t.vendor,t.chginfo, sum(nvl(t.shouldpay,0)), sum(nvl(t.realamt,0)), vbdate, vtimeflag
	from h4rtmp_chgbookviewex t
	group by t.vendor,t.chginfo;

end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>h4rtmp_chgbookview</TABLE>
    <ALIAS>h4rtmp_chgbookview</ALIAS>
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
    <COLUMN>h4rtmp_chgbookview.vendor</COLUMN>
    <TITLE>供应商</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>vendor</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_chgbookview.chginfo</COLUMN>
    <TITLE>科目</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>chginfo</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_chgbookview.shouldpay</COLUMN>
    <TITLE>应收金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>shouldpay</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_chgbookview.realamt</COLUMN>
    <TITLE>已收金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>realamt</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_chgbookview.shouldpay - h4rtmp_chgbookview.realamt</COLUMN>
    <TITLE>待收金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>forpay</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_chgbookview.fildate</COLUMN>
    <TITLE>日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>fildate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_chgbookview.flag</COLUMN>
    <TITLE>日期类型</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>flag</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>272</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>100</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>100</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>100</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>供应商</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>h4rtmp_chgbookview.vendor</LEFT>
    <OPERATOR>LIKE</OPERATOR>
    <RIGHT>
      <RIGHTITEM>%%</RIGHTITEM>
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
    <DEFAULTVALUE>%%</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>h4rtmp_chgbookview.fildate</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2010.07.01</RIGHTITEM>
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
    <LEFT>h4rtmp_chgbookview.fildate</LEFT>
    <OPERATOR><</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2010.07.20</RIGHTITEM>
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
    <DEFAULTVALUE>明天</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>h4rtmp_chgbookview.flag</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>按填单日期</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
      <PICKNAMEITEM>按费用单发生日期</PICKNAMEITEM>
      <PICKNAMEITEM>按费用单填单日期</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>按发生日期</PICKVALUEITEM>
      <PICKVALUEITEM>按填单日期</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE>按填单日期</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>h4rtmp_chgbookview.chginfo</LEFT>
    <OPERATOR>LIKE</OPERATOR>
    <RIGHT>
      <RIGHTITEM>%%</RIGHTITEM>
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
    <DEFAULTVALUE>%%</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>122</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>87</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>98</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>118</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>%%</SGLINEITEM>
    <SGLINEITEM>2010.07.01</SGLINEITEM>
    <SGLINEITEM>2010.07.20</SGLINEITEM>
    <SGLINEITEM>按填单日期</SGLINEITEM>
    <SGLINEITEM>%%</SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 2：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
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
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 4：</SGLINEITEM>
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
  <NUMOFNEXTQRY>1</NUMOFNEXTQRY>
  <NCRITERIALIST>
    <NEXTQUERY>\\192.168.200.71\hdupdate\QUERY\供应商结算\费用单收款查询（明细）.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>供应商类似于</LEFT>
      <RIGHT>供应商</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>日期大于等于</LEFT>
      <RIGHT>日期大于等于</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>日期小于</LEFT>
      <RIGHT>日期小于</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>日期类型等于</LEFT>
      <RIGHT>日期类型等于</RIGHT>
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
  <DXCOLORODDROW>15921906</DXCOLORODDROW>
  <DXCOLOREVENROW>12632256</DXCOLOREVENROW>
  <DXFILTERNAME></DXFILTERNAME>
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

