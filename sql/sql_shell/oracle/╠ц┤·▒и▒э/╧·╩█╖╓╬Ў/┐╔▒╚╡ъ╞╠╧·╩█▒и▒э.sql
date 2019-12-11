<VERSION>4.1.1</VERSION>
<SQLQUERY>
<REMARK>
[����]

[Ӧ�ñ���]

[���������]

[��Ҫ�Ĳ�ѯ����]

[ʵ�ַ���]

[����]
modify on 2010.07.01 by ym
ע�͵�---      and (r.fildate = vdate or vdate is null)�����������

modify on 2010.10.11 by liukai
-- Create table
create global temporary table HDTMP_SALDRPT0
(
  ORGKEY        INTEGER,
  SALEDATE      DATE,
  SALEQTY       NUMBER(24,4),
  SALEAMT       NUMBER(24,4),
  SALETAX       NUMBER(24,4),
  SALECAMT      NUMBER(24,4),
  SALECTAX      NUMBER(24,4),
  SALECOUNTS    INTEGER,
  CLIENTPERSALE NUMBER(24,4)
)
on commit preserve rows;
-- Grant/Revoke object privileges 
grant insert, update, delete on HDTMP_SALDRPT0 to ROLE_HDAPP;
grant insert, update, delete on HDTMP_SALDRPT0 to ROLE_HDQRY;
</REMARK>
<BEFORERUN>
declare

  vbegdate   date;
  venddate   date;
  vstorecode varchar2(200);
  vprovince   varchar2(200);
  vstoremanagertype varchar2(200);

begin

  vbegdate := to_date('\(1,1)','yyyy.mm.dd');
  venddate := to_date('\(2,1)','yyyy.mm.dd');
  vstorecode :=trim('\(3,1)')||'%';
  vprovince := trim('\(4,1)')||'%';
  vstoremanagertype := trim('\(5,1)')||'%';

  delete from tmp_test1;
  commit;
  delete from tmp_test2;
  commit;
--��rpt_storedrpt �� sdrpts ������һ�����嵥��һ���ǻ��ܣ�ע�͵������ݺ� �������ݵȼ�
  insert into tmp_test1
    (char1,
     char2,
     char3,
     char4,
     char5,
     int1,
     date1,
     num1,
     num2,
     num3,
     num4,date2,date3)
    select s.PROVINCE, --ʡ��
           s.code, --���
           s.name, --����
           case
             when s.storetype = 1 then
              '������'
             when s.storetype = 2 then
              '�ֹ�˾'
             when s.storetype = 3 then
              'ֱӪ��'
             when s.storetype = 4 then
              '���˵�'
           end as storetype --�ŵ�����
          ,
           s.storemanagertype --�ŵ����Ȩ�� 
          ,
           r.orgkey,
           nvl(r.fildate, vbegdate),
           case
             when r.fildate >= add_months(vbegdate, -12) and
                  r.fildate <= add_months(venddate, -12) then
              sum(r.saleqty)
           end,
           case
             when r.fildate >= add_months(vbegdate, -12) and
                  r.fildate <= add_months(venddate, -12) then
              sum(r.saleamt) + sum(r.saletax)
           end,
           case
             when r.fildate >= vbegdate and r.fildate <= venddate then
              sum(r.saleqty)
           end,
           case
             when r.fildate >= vbegdate and r.fildate <= venddate then
              sum(r.saleamt) + sum(r.saletax)
           end,
           vbegdate,venddate
      from rpt_storedrpt r, store s
     where r.orgkey = s.gid
       and r.cls in ('����', '�ɱ�����')
       and ((r.fildate >= vbegdate and r.fildate <= venddate) or
           (r.fildate >= add_months(vbegdate, -12) and
           r.fildate <= add_months(venddate, -12)))
       and s.BUSDATE < add_months(vbegdate, -12)
       and s.stat=0--����Ӫҵ�ŵ�
       and (s.code like vstorecode or vstorecode is null)
       and (s.PROVINCE like vprovince or vprovince is null )
       and (s.storemanagertype like vstoremanagertype or vstoremanagertype is null)

     group by r.orgkey,
              nvl(r.fildate, vbegdate),
              s.PROVINCE, --ʡ��
              s.code, --���
              s.name, --����
              case
                when s.storetype = 1 then
                 '������'
                when s.storetype = 2 then
                 '�ֹ�˾'
                when s.storetype = 3 then
                 'ֱӪ��'
                when s.storetype = 4 then
                 '���˵�'
              end --�ŵ�����
             ,
              s.storemanagertype,
              r.fildate;

 /* insert into tmp_test1
    (char1,
     char2,
     char3,
     char4,
     char5,
     int1,
     date1,
     num1,
     num2,
     num3,
     num4)
    select s.PROVINCE, --ʡ��
           s.code, --���
           s.name, --����
           case
             when s.storetype = 1 then
              '������'
             when s.storetype = 2 then
              '�ֹ�˾'
             when s.storetype = 3 then
              'ֱӪ��'
             when s.storetype = 4 then
              '���˵�'
           end as storetype --�ŵ�����
          ,
           s.storemanagertype --�ŵ����Ȩ��
          ,
           r.snd,
           nvl(r.fildate, vbegdate),
           case
             when r.fildate >= add_months(vbegdate, -12) and
                  r.fildate < add_months(venddate, -12) then
              sum(decode(r.cls,
                         '����',
                         1,
                         '����',
                         1,
                         '�ɱ�����',
                         0,
                         '�ɱ�����',
                         0,
                         -1) * r.qty)
           end,
           case
             when r.fildate >= add_months(vbegdate, -12) and
                  r.fildate < add_months(venddate, -12) then
              sum(decode(r.cls,
                         '����',
                         1,
                         '����',
                         1,
                         '�ɱ�����',
                         0,
                         '�ɱ�����',
                         0,
                         -1) * r.amt) +
              sum(decode(r.cls,
                         '����',
                         1,
                         '����',
                         1,
                         '�ɱ�����',
                         0,
                         '�ɱ�����',
                         0,
                         -1) * r.tax)
           end,
           case
             when r.fildate >= vbegdate and r.fildate < venddate then
              sum(decode(r.cls,
                         '����',
                         1,
                         '����',
                         1,
                         '�ɱ�����',
                         0,
                         '�ɱ�����',
                         0,
                         -1) * r.qty)
           end,
           case
             when r.fildate >= vbegdate and r.fildate < venddate then
              sum(decode(r.cls,
                         '����',
                         1,
                         '����',
                         1,
                         '�ɱ�����',
                         0,
                         '�ɱ�����',
                         0,
                         -1) * r.amt) +
              sum(decode(r.cls,
                         '����',
                         1,
                         '����',
                         1,
                         '�ɱ�����',
                         0,
                         '�ɱ�����',
                         0,
                         -1) * r.tax)
           end
    
      from sdrpts r, store s
     where r.snd = s.gid
       and r.cls in
           ('����', '������', '����', '������', '�ɱ�����', '�ɱ�����')
       and ((r.fildate >= vbegdate and r.fildate < venddate) or
           (r.fildate >= add_months(vbegdate, -12) and
           r.fildate < add_months(venddate, -12)))
       and s.BUSDATE >= add_months(vbegdate, -12)
     group by r.snd,
              r.gdgid,
              nvl(r.fildate, vbegdate),
              s.PROVINCE, --ʡ��
              s.code, --���
              s.name, --����
              case
                when s.storetype = 1 then
                 '������'
                when s.storetype = 2 then
                 '�ֹ�˾'
                when s.storetype = 3 then
                 'ֱӪ��'
                when s.storetype = 4 then
                 '���˵�'
              end --�ŵ�����
             ,
              s.storemanagertype,
              r.fildate;*/
insert into  tmp_test2 (char1, char2, char3, char4, char5, int1, date2, date3, num1, num2, num3, num4)
  select char1,
         char2,
         char3,
         char4,
         char5,
         int1,
         date2,
         date3,
         sum(nvl(num1, 0)),
         sum(nvl(num2, 0)),
         sum(nvl(num3, 0)),
         sum(nvl(num4, 0))
    from tmp_test1
   group by char1, char2, char3, char4, char5, int1, date2, date3;

commit;

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
  <FIXEDCOLUMNS>4</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char1</COLUMN>
    <TITLE>ʡ��</TITLE>
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
    <COLUMN>tmp_test2.char2</COLUMN>
    <TITLE>���</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
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
    <TITLE>����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
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
    <TITLE>��������</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char5</COLUMN>
    <TITLE>����Ȩ��</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num1</COLUMN>
    <TITLE>ȥ��ͬ������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num2</COLUMN>
    <TITLE>ȥ��ͬ������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num3</COLUMN>
    <TITLE>����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num4</COLUMN>
    <TITLE>����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.date2</COLUMN>
    <TITLE>��ʼ����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.date3</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>73</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>66</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>88</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>138</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>93</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>84</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>83</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>����Ȩ��</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>tmp_test2.date2</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2017.02.01</RIGHTITEM>
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
    <DEFAULTVALUE>������</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test2.date3</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2017.02.21</RIGHTITEM>
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
    <DEFAULTVALUE>���ܶ�</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test2.char2</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>10010</RIGHTITEM>
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
    <LEFT>tmp_test2.char1</LEFT>
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
      <PICKNAMEITEM>#TABLE</PICKNAMEITEM>
      <PICKNAMEITEM>province</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>select province from province</PICKVALUEITEM>
      <PICKVALUEITEM>province</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test2.char5</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>�Ϻ�ľ�ȹ���</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
      <PICKNAMEITEM>#TABLE</PICKNAMEITEM>
      <PICKNAMEITEM>storemanagertype</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>select storemanagertype from store</PICKVALUEITEM>
      <PICKVALUEITEM>storemanagertype</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE>�Ϻ�ľ�ȹ���</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>139</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>124</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>129</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>2017.02.01</SGLINEITEM>
    <SGLINEITEM>2017.02.21</SGLINEITEM>
    <SGLINEITEM>10010</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM>�Ϻ�ľ�ȹ���</SGLINEITEM>
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
  <NUMOFNEXTQRY>4</NUMOFNEXTQRY>
  <NCRITERIALIST>
    <NEXTQUERY>�ŵ����ڶ���Ʒ������ϸ.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>�������ڴ��ڵ���</LEFT>
      <RIGHT>�������ڴ��ڵ���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>��������С��</LEFT>
      <RIGHT>��������С��</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>�ŵ�������</LEFT>
      <RIGHT>�ŵ����</RIGHT>
    </NCRITERIAITEM>
  </NCRITERIALIST>
  <NCRITERIALIST>
    <NEXTQUERY>�ŵ����ڶ�������ۻ���(����).sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>�������ڴ��ڵ���</LEFT>
      <RIGHT>�������ڴ��ڵ���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>��������С��</LEFT>
      <RIGHT>��������С��</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>�ŵ�������</LEFT>
      <RIGHT>�ŵ����</RIGHT>
    </NCRITERIAITEM>
  </NCRITERIALIST>
  <NCRITERIALIST>
    <NEXTQUERY>�ŵ����ڶ�������ۻ���(����).sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>�������ڴ��ڵ���</LEFT>
      <RIGHT>�������ڴ��ڵ���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>��������С��</LEFT>
      <RIGHT>��������С��</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>�ŵ�������</LEFT>
      <RIGHT>�ŵ����</RIGHT>
    </NCRITERIAITEM>
  </NCRITERIALIST>
  <NCRITERIALIST>
    <NEXTQUERY>�ŵ����ڶ�������ۻ���(С��).sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>�������ڴ��ڵ���</LEFT>
      <RIGHT>�������ڴ��ڵ���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>��������С��</LEFT>
      <RIGHT>��������С��</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>�ŵ�������</LEFT>
      <RIGHT>�ŵ����</RIGHT>
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
  <DXCOLORODDROW>16777215</DXCOLORODDROW>
  <DXCOLOREVENROW>15921906</DXCOLOREVENROW>
  <DXFILTERNAME></DXFILTERNAME>
  <DXFILTERTYPE></DXFILTERTYPE>
  <DXFILTERLIST>
  </DXFILTERLIST>
  <DXSHOWGRIDLINE>1</DXSHOWGRIDLINE>
</DXDBGRIDITEM>
</SQLQUERY>
<SQLREPORT>
<RPTTITLE>�ŵ����ڶ����ۻ���</RPTTITLE>
<RPTGROUPCOUNT>0</RPTGROUPCOUNT>
<RPTGROUPLIST>
</RPTGROUPLIST>
<RPTCOLUMNCOUNT>8</RPTCOLUMNCOUNT>
<RPTCOLUMNWIDTHLIST>
  <RPTCOLUMNWIDTHITEM>73</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>58</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>58</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>79</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>99</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>162</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>142</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>125</RPTCOLUMNWIDTHITEM>
</RPTCOLUMNWIDTHLIST>
<RPTLEFTMARGIN>40</RPTLEFTMARGIN>
<RPTORIENTATION>0</RPTORIENTATION>
<RPTCOLUMNS>1</RPTCOLUMNS>
<RPTHEADERLEVEL>0</RPTHEADERLEVEL>
<RPTPRINTCRITERIA>TRUE</RPTPRINTCRITERIA>
<RPTVERSION></RPTVERSION>
<RPTNOTE></RPTNOTE>
<RPTFONTSIZE>9</RPTFONTSIZE>
<RPTLINEHEIGHT>����</RPTLINEHEIGHT>
<RPTPAGEHEIGHT>66</RPTPAGEHEIGHT>
<RPTPAGEWIDTH>80</RPTPAGEWIDTH>
<RPTTITLETYPE>0</RPTTITLETYPE>
<RPTCURREPORT></RPTCURREPORT>
<RPTREPORTLIST>
</RPTREPORTLIST>
</SQLREPORT>

