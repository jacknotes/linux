<VERSION>4.1.0</VERSION>
<SQLQUERY>
<REMARK>
[����]

[Ӧ�ñ���]
�ñ������ڲ鿴���õ��� Ӧ�ս����ս����ս�

[���������]
Ӧ�ս�� = ����� ���� ����� �ķ��õ���
���ս�� = ���տ�Ľ�����ý�� + �Ѹ������ý�
���ս�� = Ӧ�ս�� - ���ս�

[��Ҫ�Ĳ�ѯ����]
���ڣ�ȡֵΪ���õ��ġ��������ڡ�

[ʵ�ַ���]

[����]
�ñ���Ϊ���ܣ�������һ��ϸ�������ʹ�á�

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
	
	if vtimeflag = '����������' then
		--- Ӧ��
		insert into h4rtmp_chgbookviewex(vendor,CHGINFO,shouldpay)
		select v.name||'['||v.code||']',D.name||'['||D.code||']', sum(c.paydirect * c.realamt)
		from chgbook c, vendor v,CTCHGDEF D
		where c.vendor = v.gid AND C.CHGCODE=D.CODE
			and c.stat in (500,300)
			and (c.ocrdate < vedate or vedate is null)
			and (c.ocrdate >= vbdate or vbdate is null)
		group by v.code, v.name,d.code,d.name;

		-- ����
		insert into h4rtmp_chgbookviewex(vendor,CHGINFO,realamt)
		select v.name||'['||v.code||']',D.name||'['||D.code||']', sum(c.paydirect * c.paytotal)
		from chgbook c, vendor v,CTCHGDEF D
		where c.vendor = v.gid AND C.CHGCODE=D.CODE
			and c.stat in (500,300)
			and (c.ocrdate < vedate or vedate is null)
			and (c.ocrdate >= vbdate or vbdate is null)
		group by v.code, v.name,d.code,d.name;
	
	else
	
	--- �������
			--- Ӧ��
		insert into h4rtmp_chgbookviewex(vendor,CHGINFO,shouldpay)
		select v.name||'['||v.code||']',D.name||'['||D.code||']', sum(c.paydirect * c.realamt)
		from chgbook c, vendor v,CTCHGDEF D
		where c.vendor = v.gid AND C.CHGCODE=D.CODE
			and c.stat in (500,300)
			and (c.fildate < vedate or vedate is null)
			and (c.fildate >= vbdate or vbdate is null)
		group by v.code, v.name,d.code,d.name;

		-- ����
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
		--- ���
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
	--- ���
	select '['||v.code||']'||v.name, sum(dtl.paytotal)
	from chgbook c, cntrpaycashdtl dtl, cntrpaycash mst, vendor v
	where c.num = dtl.ivccode
		and dtl.num = mst.num
		and c.vendor = v.gid
		and c.vendor = mst.vdrgid
		and dtl.chgtype = '���õ�'
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
    <TITLE>��Ӧ��</TITLE>
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
    <TITLE>��Ŀ</TITLE>
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
    <TITLE>Ӧ�ս��</TITLE>
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
    <TITLE>���ս��</TITLE>
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
    <TITLE>���ս��</TITLE>
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
    <TITLE>����</TITLE>
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
    <TITLE>��������</TITLE>
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
    <COLUMN>��Ӧ��</COLUMN>
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
    <DEFAULTVALUE>�³�</DEFAULTVALUE>
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
    <DEFAULTVALUE>����</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>h4rtmp_chgbookview.flag</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>�������</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
      <PICKNAMEITEM>�����õ���������</PICKNAMEITEM>
      <PICKNAMEITEM>�����õ������</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>����������</PICKVALUEITEM>
      <PICKVALUEITEM>�������</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE>�������</DEFAULTVALUE>
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
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>%%</SGLINEITEM>
    <SGLINEITEM>2010.07.01</SGLINEITEM>
    <SGLINEITEM>2010.07.20</SGLINEITEM>
    <SGLINEITEM>�������</SGLINEITEM>
    <SGLINEITEM>%%</SGLINEITEM>
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
  <NUMOFNEXTQRY>1</NUMOFNEXTQRY>
  <NCRITERIALIST>
    <NEXTQUERY>\\192.168.200.71\hdupdate\QUERY\��Ӧ�̽���\���õ��տ��ѯ����ϸ��.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>��Ӧ��������</LEFT>
      <RIGHT>��Ӧ��</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>���ڴ��ڵ���</LEFT>
      <RIGHT>���ڴ��ڵ���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>����С��</LEFT>
      <RIGHT>����С��</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>�������͵���</LEFT>
      <RIGHT>�������͵���</RIGHT>
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
<RPTLINEHEIGHT>����</RPTLINEHEIGHT>
<RPTPAGEHEIGHT>66</RPTPAGEHEIGHT>
<RPTPAGEWIDTH>80</RPTPAGEWIDTH>
<RPTTITLETYPE>0</RPTTITLETYPE>
<RPTCURREPORT></RPTCURREPORT>
<RPTREPORTLIST>
</RPTREPORTLIST>
</SQLREPORT>

