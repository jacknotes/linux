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
  v_scode varchar2(100);        --�ŵ����
  v_gcode varchar2(100);        --��Ʒ����
  v_vcode varchar2(100);        --��Ӧ�̴���
  v_bdate date;                 --��ѯ��ʼʱ��
  v_edate date;                 --��ѯ����ʱ��
  v_vgcode varchar2(100);       --��Ʒ����
  v_vgcode2 varchar2(100);      --��Ʒ����
  V_PSRcode varchar2(100);      --�ɹ�Աcode
  V_PSRGID varchar2(100);       --�ɹ�Աgid
  v_property varchar2(100);     --�ŵ�����
  v_sql varchar2(4000);
  v_sql2 varchar2(4000);
begin
  v_bdate := to_date('\(1,1)','yyyy.mm.dd');
  v_edate := to_date('\(2,1)','yyyy.mm.dd');
  v_scode := '\(3,1)';
  select '(' || '''' || replace ('\(4,1)',',',''',''') || '''' || ')' into v_vgcode from dual;
  select substr(v_vgcode,3,INSTR(v_vgcode,',',1,1)-4) into v_vgcode2 from dual;
  
  --�ȰѶ�̬sql������׼����
  if v_scode is not null then
    v_sql2 := 'and (s.code = '||''''||v_scode||''''||')';
  elsif v_scode is null then
    v_sql2 := 'and (1=1)';
  end if;
  if v_vgcode <> '('''')' then
    v_sql2 := v_sql2 ||' and (vg.ascode in '||v_vgcode||')';
  elsif v_vgcode = '('''')' then
    v_sql2 := v_sql2 ||' and (1=1)';
  end if;


  delete from H4RTMP_OT_maolilv;
  delete from H4RTMP_OT_kedanliang;

  insert into H4RTMP_OT_kedanliang(�ŵ����,������)
  select  s.code,sum(dn1+dn2) dn from Cshdrpts c,workstation w,store s
    where c.posno = w.no and w.storegid = s.gid
      and c.adate >= v_bdate 
      and c.adate < v_edate 
  group by s.code;


  --��̬sql���
  v_sql :='insert into H4RTMP_OT_maolilv( �ŵ����,�ŵ�����,�ŵ�����/*,�ڳ����,��ĩ���*/,�������� ,���۽��,���۳ɱ�,����ë��,ë����)
  select �ŵ����,�ŵ�����,�ŵ�����/*,sum(�ڳ��ۼ۽��),sum(��ĩ�ۼ۽��)*/,sum(������),sum(���۶�),sum(���۳ɱ�),sum(����ë��),sum(ë����) from  (
      
      select /*a.fildate �ʱ��,*/s.code �ŵ����,s.name �ŵ�����,s.property �ŵ�����/*,0 ,0*/,sum(a.saleqty) ������,sum(a.saleamt)+sum(a.saletax) ���۶�,sum(a.salecamt)+sum(salectax) ���۳ɱ�,(sum(a.saleamt)+sum(a.saletax)) - (sum(a.salecamt)+sum(a.salectax)) ����ë��,decode(sum(a.saleamt)+sum(a.saletax),0,0,round(((sum(saleamt)+sum(a.saletax)) - (sum(a.salecamt)+sum(a.salectax))) / (sum(a.saleamt)+sum(a.saletax)),2)) ë���� 
        from rpt_storesaldrpt a ,store s,goodsh g,vendorh v,H4V_GOODSSORT vg
          where a.orgkey = s.gid and a.pdkey = g.gid and g.vdrgid = v.gid and g.gid = vg.gid
            and a.fildate >= '||'to_date('||''''||v_bdate||''''||','||''''||'yyyy.mm.dd hh24:mi:ss'||''''||')
            and a.fildate <' ||'to_date('||''''||v_edate||''''||','||''''||'yyyy.mm.dd hh24:mi:ss'||''''||')
            '||v_sql2||'
     group by s.code,s.name,s.property

      )
   group by �ŵ����,�ŵ�����,�ŵ�����';
    --dbms_output.put_line(v_sql);
    EXECUTE IMMEDIATE v_sql;
    --dbms_output.put_line('-----------------------------------------');
   update H4RTMP_OT_maolilv set ��ѯ���� = v_bdate,��Ʒ���� = v_gcode,��Ӧ�̱��� = v_vcode,��Ʒ���� = v_vgcode2,�ɹ�Ա���� = V_PSRcode;
   commit;

end;

/*
-- Create table
create global temporary table H4RTMP_OT_maolilv
(
  �ŵ����  VARCHAR2(13),
  �ŵ�����  VARCHAR2(100),
  �ڳ����  number(24,2),
  ��ĩ���  number(24,2),
  ��������  number(24,4),
  ���۽��  number(24,2),
  ���۳ɱ�  number(24,2),
  ����ë��  number(24,2),
  ë����  number(24,2),
  ��ѯ���� date,
  ��Ʒ���� VARCHAR2(20),
  ��Ӧ�̱��� VARCHAR2(20),
  �ŵ����� VARCHAR2(20),
  ��Ʒ���� VARCHAR2(20)
)
on commit preserve rows;
-- Grant/Revoke object privileges 
grant select, insert, update, delete on H4RTMP_OT_maolilv to HD40;
grant select, insert, update, delete on H4RTMP_OT_maolilv to ROLE_HDAPP;
grant select, insert, update, delete on H4RTMP_OT_maolilv to ROLE_HDQRY;

begin
  hdcreatesynonym('H4RTMP_OT_maolilv');
end;

*/
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>H4RTMP_OT_maolilv</TABLE>
    <ALIAS>H4RTMP_OT_maolilv</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>H4RTMP_OT_kedanliang</TABLE>
    <ALIAS>H4RTMP_OT_kedanliang</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
</TABLELIST>
<JOINLIST>
  <JOINITEM>
    <LEFT>H4RTMP_OT_kedanliang.�ŵ����</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>H4RTMP_OT_maolilv.�ŵ����</RIGHT>
  </JOINITEM>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_OT_maolilv.�ŵ����</COLUMN>
    <TITLE>�ŵ����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>�ŵ����</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_OT_maolilv.�ŵ�����</COLUMN>
    <TITLE>�ŵ�����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>�ŵ�����</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_OT_maolilv.���۽��</COLUMN>
    <TITLE>���۽��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>���۽��</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_OT_maolilv.��������</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>��������</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_OT_maolilv.���۳ɱ�</COLUMN>
    <TITLE>���۳ɱ�</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>���۳ɱ�</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_OT_maolilv.����ë��</COLUMN>
    <TITLE>����ë��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>����ë��</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>round(decode(H4RTMP_OT_maolilv.���۽��,0,0,H4RTMP_OT_maolilv.����ë��/H4RTMP_OT_maolilv.���۽��),4)*100</COLUMN>
    <TITLE>ë����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>ë����</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00%</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>round(decode(H4RTMP_OT_kedanliang.������,0,0,H4RTMP_OT_maolilv.���۽��/H4RTMP_OT_kedanliang.������),2)</COLUMN>
    <TITLE>�͵���</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>�͵���</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_OT_maolilv.��ѯ����</COLUMN>
    <TITLE>��ѯ����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>��ѯ����</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_OT_maolilv.��Ʒ����</COLUMN>
    <TITLE>��Ʒ����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>��Ʒ����</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_OT_kedanliang.������</COLUMN>
    <TITLE>������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>������1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.###</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>82</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>238</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>93</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>120</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>91</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>131</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>�ŵ����</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>H4RTMP_OT_maolilv.��ѯ����</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2014.11.03</RIGHTITEM>
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
    <DEFAULTVALUE>���³�</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>H4RTMP_OT_maolilv.��ѯ����</LEFT>
    <OPERATOR><</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2014.11.04</RIGHTITEM>
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
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>H4RTMP_OT_maolilv.�ŵ����</LEFT>
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
    <LEFT>H4RTMP_OT_maolilv.��Ʒ����</LEFT>
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
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>105</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>116</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>2014.11.03</SGLINEITEM>
    <SGLINEITEM>2014.11.04</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 2��</SGLINEITEM>
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
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 4��</SGLINEITEM>
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

