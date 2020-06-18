<VERSION>4.1.0</VERSION>
<SQLQUERY>
<REMARK>
[标题]

[应用背景]
该报表用于查看费用单的 应收金额，已收金额，待收金额。

[结果列描述]
期初未收 + 开始时间~结束时间的应收 - 开始时间~结束时间的已收 = 未收
最终推导为：[结束时间之前的应收 - 开始时间之前的已收] - 开始时间~结束时间的已收 = 未收
日期取值为收款单的收款时间
应收的时间为费用单的审核日期、交款单的收款时间和付款单的付款时间
已收的时间为交款单的收款时间和付款单的付款时间

[必要的查询条件]


[实现方法]

[其它]
该报表为汇总，另外有一明细报表配合使用。

create global temporary table h4rtmp_chgbookview
(
fildate date, 
vendor varchar2(80), 
billnum varchar2(20), 
paycls	varchar2(40),
paybillnum	varchar2(20),
stat varchar2(30), 
chginfo varchar2(40), 
shouldpay number(24,2), 
realamt number(24,2), 
realamt1 number(24,2), 	-- 开始时间之前的交款单金额
realamt2 number(24,2), 	-- 开始时间之前的付款单金额
realamt3 number(24,2), 	-- 开始到结束之间的交款单金额
realamt4 number(24,2), 	-- 开始到结束之间的付款单金额
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
paycls	varchar2(40),
paybillnum	varchar2(20),
stat varchar2(30), 
chginfo varchar2(40), 
shouldpay number(24,2), 
realamt number(24,2), 
realamt1 number(24,2), 	-- 开始时间之前的交款单金额
realamt2 number(24,2), 	-- 开始时间之前的付款单金额
realamt3 number(24,2), 	-- 开始到结束之间的交款单金额
realamt4 number(24,2), 	-- 开始到结束之间的付款单金额
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
	
	
	--- 应收
		--- 统计结束时间之前的应收金额
		insert into h4rtmp_chgbookviewex(vendor,shouldpay)
		select '['||v.code||']'||v.name, sum(c.paydirect * c.realamt)
		from chgbook c, vendor v, chgbooklog log
		where c.vendor = v.gid
			and c.num = log.num
			and log.stat = 500
			and (log.time < vedate or vedate is null)
		group by v.code, v.name;
	
		--- 交款单
		--- 统计开始时间之前的已收金额
		insert into h4rtmp_chgbookviewex(vendor, realamt1)
		select '['||v.code||']'||v.name, sum(mst.paytotal)
		from vdrpay mst, vendor v, vdrpaylog log
		where mst.num = log.num
			and mst.vgid = v.gid
			and log.stat = 1800
			and (log.time < vbdate or vbdate is null)
		group by v.code, v.name;
	
		--- 付款单
		--- 统计开始之前的已冲扣货款的费用单金额
		insert into h4rtmp_chgbookviewex(vendor, realamt2)
		select '['||v.code||']'||v.name, sum(mst.feetotal)
		from cntrpaycash mst, vendor v, cntrpaycashchklog log
		where mst.vdrgid = v.gid
			and mst.num = log.num
			and log.chkflag = 900
			and (log.atime < vbdate or vbdate is null)
		group by v.code, v.name;
	
	--- 已收
		--- 交款单
		--- 统计开始时间~结束按时间的已收金额
		insert into h4rtmp_chgbookviewex(vendor, realamt3)
		select '['||v.code||']'||v.name, sum(mst.paytotal)
		from vdrpay mst, vendor v, vdrpaylog log
		where mst.num = log.num
			and mst.vgid = v.gid
			and log.stat = 1800
			and (log.time < vedate or vedate is null)
			and (log.time >= vbdate or vbdate is null)
		group by v.code, v.name;
	
		--- 付款单
		--- 统计开始时间~结束按时间的已冲扣货款的费用单金额
		insert into h4rtmp_chgbookviewex(vendor, realamt4)
		select '['||v.code||']'||v.name, sum(mst.feetotal)
		from cntrpaycash mst, vendor v, cntrpaycashchklog log
		where mst.vdrgid = v.gid
			and mst.num = log.num
			and log.chkflag = 900
			and (log.atime < vedate or vedate is null)
			and (log.atime >= vbdate or vbdate is null)
		group by v.code, v.name;
	

	insert into h4rtmp_chgbookview(vendor, shouldpay, 
									realamt, 
									fildate, flag)
	select t.vendor, sum(nvl(t.shouldpay,0)) - sum(nvl(t.realamt1,0)) - sum(nvl(t.realamt2,0)), 
		sum(nvl(t.realamt3,0)) + sum(nvl(t.realamt4,0)), 
		vbdate, vtimeflag
	from h4rtmp_chgbookviewex t
	group by t.vendor;

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
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>272</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>100</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>100</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>100</COLUMNWIDTHITEM>
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
      <RIGHTITEM>2010.08.01</RIGHTITEM>
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
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>h4rtmp_chgbookview.fildate</LEFT>
    <OPERATOR><</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2010.08.08</RIGHTITEM>
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
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>122</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>87</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>98</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>%%</SGLINEITEM>
    <SGLINEITEM>2010.08.01</SGLINEITEM>
    <SGLINEITEM>2010.08.08</SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 2：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 3：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 4：</SGLINEITEM>
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
  <NUMOFNEXTQRY>2</NUMOFNEXTQRY>
  <NCRITERIALIST>
    <NEXTQUERY>费用单收款查询（明细）.sql</NEXTQUERY>
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
  <NCRITERIALIST>
    <NEXTQUERY>费用单收款(供应商科目明细).sql</NEXTQUERY>
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

