<VERSION>4.1.0</VERSION>
<SQLQUERY>
<REMARK>
[����]

[Ӧ�ñ���]

[���������]
   ͳ�ƿ�Ŀ:
     ���ڵǼ����� �� �ں�ƥ��֮��ƥ�䲻�ϵ��嵥
     �������     �� ���ں���һ�ڵ� ƥ�����
[��Ҫ�Ĳ�ѯ����]
  ��ת�ںţ������ת�ںű�ʾ��ͬ�Ľ�ת���
[ʵ�ַ���]
  ��ѯָ���ں��ڣ��������������ȼ���Ľ����
  ��������������ԭ������ָ���ں�=5���˻������ȼ��㣨ϵͳĬ��ѡ�
   1.��ѯ�ں�=4 �ġ����ڵǼ��������������Ʒ��δƥ��������
   2.��ѯ�ں�=5 ���ʱ����ڵ� ����������
   3.��ѯ�ں�=5 ���ʱ�������ɵ� �˻�������Ӫ���ˡ�ֱ����ˣ���������
   4.������3����ͳ������֮�ͣ��Խ���������Ӫ������ֱ��������������ʱ�䣬�������ε�
�Ǽǡ�
   5.����4�����ǼǵĽ������ĳɱ�����ͣ��õ��ں�=5����һ�ڹ�Ӧ�̵Ŀɽ����ȡ�
   

[����]  20101105 + liukai
create global temporary table h4rtmp_purchasebysalebill
(
enddate date,
vdrcode varchar2(15),
vdrname varchar2(60),
cls varchar2(15),
num varchar2(20),
line int,
gdcode varchar2(15),
gdname varchar2(80),
inqty number(24,4),
ctbregqty number(24,4),
itotal number(24,2)
)
on commit preserve rows;
exec hdcreatesynonym('h4rtmp_purchasebysalebill')
exec granttoqryrole('h4rtmp_purchasebysalebill')

EXEC hdaddcolumn('h4rtmp_purchasebysalebill','no','int');
alter table HD_REPORT.h4rtmp_purchasebysalebill add (bgndate 
date );
</REMARK>
<BEFORERUN>
declare

  vvdrcode varchar2(15);
  venddate date;
  vbegdate date;
  v_no     int;
  
begin
  
  delete from h4rtmp_purchasebysalebill;
  commit;
  
  vvdrcode := trim('\(1,1)');
  --venddate := to_date('\(2,1)','yyyy.mm.dd');
  v_no     := trim('\(2,1)');

  select max(enddate) into vbegdate from PurchaseBySaleno where no < v_no ;
  if vbegdate is null then
    vbegdate := to_date('2011.11.01','yyyy.mm.dd');
  end if;
  
 
  --- �ں��� �Ѿ�ƥ������
  insert into h4rtmp_purchasebysalebill(bgndate,enddate,vdrcode,vdrname,cls,num,line,gdcode,gdname,inqty,ctbregqty,itotal,no)
  select vbegdate,P.enddate,v.code,v.name,p.bill,p.num,p.billline,g.code,g.name,h.qty,p.qty,p.itotal, p.no
  from PurchaseBySaleInvRegDtl p,h4v_PurchaseBySalebill h,vendor v,goodsh g
  where decode(p.bill,'��Ӫ����','��Ӫ��','ֱ�����','ֱ���',p.bill) = h.cls(+)
        and p.num = h.num(+) and p.billline = h.line(+)
        and p.no = v_no and p.gdgid = g.gid
        and p.vdrgid = v.gid and (v.code = vvdrcode or vvdrcode is null)
        and p.bill in ('��Ӫ����','��Ӫ����','ֱ�����','ֱ�����')
  union all
  select vbegdate,P.enddate,v.code,v.name,'�������',null,null,null,null,null,null,p.itotal, p.no
  from PurchaseBySaleInvRegDtl p,vendor v
  where p.vdrgid = v.gid and p.no = v_no and p.bill in ('�������')
  union all
  SELECT vbegdate,dtl.ENDDATE, V.CODE, V.NAME, DTL.BILL, '��������', NULL, G.CODE, G.NAME, NULL, SUM(DTL.QTY), SUM(ITOTAL), DTL.NO 
  FROM PurchaseBySaleInvRegDtl DTL, VENDOR V, GOODSH G 
  WHERE DTL.GDGID = G.GID
  AND V.GID = G.VDRGID
  AND DTL.BILL = '��������' 
  --AND DTL.no = v_no
  AND DTL.NO = V_NO
  and DTL.GDGID IN (
  SELECT GDGID FROM PurchaseBySaleInvRegDtl WHERE 
  NO = DTL.NO AND BILL IN ('��Ӫ����','ֱ�����'))
  GROUP BY dtl.ENDDATE, V.CODE, V.NAME, DTL.BILL, G.CODE, G.NAME,DTL.NO
  UNION ALL
  SELECT vbegdate,p.ENDDATE, V.CODE, V.NAME, P.BILL, P.BILL, NULL, G.CODE, G.NAME, NULL, SUM(P.QTY), SUM(P.ITOTAL), P.NO  
  FROM purchasebysaleinvregdtl_unused P, VENDOR V, GOODSH G, PurchaseBySaleInvRegDtl DTL
  WHERE G.VDRGID = V.GID
  AND  P.GDGID = G.GID
  AND  P.GDGID = DTL.GDGID
  AND  P.NO = DTL.NO
  AND  DTL.NO = V_NO
  --AND  DTL.ENDDATE = VENDDATE
  AND  P.BILL = '���ڵǼ�����'
  AND  DTL.BILL IN ('��Ӫ����','ֱ�����')
  GROUP BY p.ENDDATE, V.CODE, V.NAME, P.BILL, G.CODE, G.NAME,P.NO ;
  
  
/*  select venddate,v.code,v.name,'��������' bill,'�ܲ�����',null,g.code,g.name,null,
         sum(decode(cls,'����',qty,'����',qty,-qty)),
         sum(decode(cls,'����',(amt+tax),'����',(amt+tax),-(amt+tax)))
  from drpt d,vendor v,goodsh g
  where d.cls in ('����','������','����','������')
        and d.vdrgid = v.gid and d.gdgid = g.gid
        and (v.code = vvdrcode or vvdrcode is null)
        and d.fildate >= vbegdate and d.fildate < venddate 
  group by v.code,v.name,g.code,g.name
  union all
  select venddate,v.code,v.name,'��������' bill,'�ŵ�����',null,g.code,g.name,null,
         sum(decode(cls,'����',qty,'����',qty,-qty)),
         sum(decode(cls,'����',(amt+tax),'����',(amt+tax),-(amt+tax)))
  from sdrpt d,vendor v,goodsh g
  where d.cls in ('����','������','����','������')
        and d.vdrgid = v.gid and d.gdgid = g.gid
        and (v.code = vvdrcode or vvdrcode is null)
        and d.fildate >= vbegdate and d.fildate < venddate
  group by v.code,v.name,g.code,g.name;*/
        
  commit;
end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>h4rtmp_purchasebysalebill</TABLE>
    <ALIAS>h4rtmp_purchasebysalebill</ALIAS>
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
    <COLUMN>h4rtmp_purchasebysalebill.bgndate</COLUMN>
    <TITLE>ͳ�ƿ�ʼ����</TITLE>
    <FIELDTYPE>11</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>bgndate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy.MM.dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_purchasebysalebill.enddate</COLUMN>
    <TITLE>ͳ�ƽ�ֹ����</TITLE>
    <FIELDTYPE>11</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>enddate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy.MM.dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_purchasebysalebill.no</COLUMN>
    <TITLE>��ת�ں�</TITLE>
    <FIELDTYPE>3</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>no</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_purchasebysalebill.vdrcode</COLUMN>
    <TITLE>��Ӧ�̴���</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>vdrcode</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_purchasebysalebill.vdrname</COLUMN>
    <TITLE>��Ӧ������</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>vdrname</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_purchasebysalebill.cls</COLUMN>
    <TITLE>ͳ�ƿ�Ŀ</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <COLUMN>h4rtmp_purchasebysalebill.num</COLUMN>
    <TITLE>���ݺ�</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <COLUMN>h4rtmp_purchasebysalebill.line</COLUMN>
    <TITLE>�����к�</TITLE>
    <FIELDTYPE>3</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>line</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_purchasebysalebill.gdcode</COLUMN>
    <TITLE>��Ʒ����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>gdcode</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_purchasebysalebill.gdname</COLUMN>
    <TITLE>��Ʒ����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>gdname</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_purchasebysalebill.inqty</COLUMN>
    <TITLE>���ݽ�����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>inqty</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_purchasebysalebill.ctbregqty</COLUMN>
    <TITLE>���εǼ���</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>ctbregqty</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_purchasebysalebill.itotal</COLUMN>
    <TITLE>�Ǽǳɱ���</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>itotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>105</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>85</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>79</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>156</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>151</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>103</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>74</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>140</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>122</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>132</COLUMNWIDTHITEM>
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
    <LEFT>h4rtmp_purchasebysalebill.vdrcode</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>00214</RIGHTITEM>
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
    <LEFT>h4rtmp_purchasebysalebill.no</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>4</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>1</ISQUOTED>
    <PICKNAME>
      <PICKNAMEITEM>#TABLE</PICKNAMEITEM>
      <PICKNAMEITEM>NO</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>SELECT DISTINCT NO FROM PurchaseBySaleInvRegDtl ORDER BY NO DESC</PICKVALUEITEM>
      <PICKVALUEITEM>NO</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>h4rtmp_purchasebysalebill.cls</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>���ڵǼ�����</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
      <PICKNAMEITEM>#TABLE</PICKNAMEITEM>
      <PICKNAMEITEM>BILL</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>select distinct bill from PurchaseBySaleINVREGDTL</PICKVALUEITEM>
      <PICKVALUEITEM>BILL</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>h4rtmp_purchasebysalebill.num</LEFT>
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
    <LEFT>h4rtmp_purchasebysalebill.gdcode</LEFT>
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
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>123</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>121</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>115</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>108</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>112</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>00214</SGLINEITEM>
    <SGLINEITEM>4</SGLINEITEM>
    <SGLINEITEM>���ڵǼ�����</SGLINEITEM>
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

