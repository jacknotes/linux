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
  Fbegdate date;
  AreaA    varchar2(50);
  Province varchar2(50);
  Codec     varchar2(50);
  --Calss    varchar2(50);
  --Season   varchar2(50);
  --SID      integer;
begin

   Fbegdate :=to_date('\(1,1)', 'yyyy.mm.dd');
  AreaA    := '\(2,1)';
  Province := '\(3,1)';
  Codec    := '\(4,1)';
  --Calss  := '\(5,1)';
  --Sname := '\(6,1)';

  --select gid into SID from store where code=Codec;

  delete from tmp_test2;
  commit;
  delete from tmp_test1;
  commit;

  insert into tmp_test2
    (char1, --����
     char2, --ʡ�� 
     char3, --��� 
     char4, ---����
     char5, ---���̼���
     char6, ----�������� 
     num1, ---TOP800�ڿ���(30��)
     num2, ----15�����۶� 
     num3, ----15���վ�����
     --num4, ----15��ת���� 
     num5, ---30�����۶�
     num6, ----30���վ�����
     --num7 ----30��ת���� 
     num8,--�ŵ���
     num9,--15������
     num10,--30������
     date1--����
     )
  
    select area.name, ---����
       c.PROVINCE, --ʡ��
       c.code, --���
       c.name, --����
       c.STORELEVEL, --���̼���
       c.STORESCALE, --��������   
       case
         when A.orderkey_1 < 801 then
          nvl(bv.Qty, 0) * nvl(g.rtlprc, 0)
         else
          Null
       end kc, --TOP800�ڿ���
       sum(nvl(A.NWeekQty, 0) * nvl(g.rtlprc, 0)) NWeekQty_15, --15�����۶� 
       
       sum(nvl(A.NWeekQty, 0) * nvl(g.rtlprc, 0)) / 15 NWeekQty_15, --TOP800 15���վ�����
       
       --sum(bv.Qty) / (sum(b.NWeekQty) / 15) zz_day_15, --15��ת���� 
       
       sum(nvl(A.NWeekQty_1, 0) * nvl(g.rtlprc, 0)) NWeekQty_30, --30�����۶�
       
       sum(nvl(A.NWeekQty_1, 0) * nvl(g.rtlprc, 0)) / 30 NWeekQty_30, --TOP800 30���վ�����
       
       --sum(bv.Qty) / (sum(d.NWeekQty) / 30) zz_day_30, --30��ת���� 
       sum(bv.Qty) md_qty, --�ŵ���
       sum(nvl(A.NWeekQty, 0)) NWeekQty_15, --15������
       sum(nvl(A.NWeekQty_1, 0)) NWeekQty_30, --30������
       Fbegdate
  from (
        
        select nvl(d.snd, b.snd) snd,
                nvl(d.Gdgid, b.Gdgid) Gdgid,
                d.orderkey_1,
                nvl(d.NWeekQty, 0) NWeekQty_1,
                b.orderkey,
                nvl(b.NWeekQty, 0) NWeekQty
          from (
                 
                 select *
                   from (select row_number() over(partition by snd order by NWeekQty desc) as orderkey_1,
                                 snd,
                                 Gdgid,
                                 NWeekQty
                            from (select a.snd,
                                         a.gdgid,
                                         sum(decode(a.cls, '����', 1, '������', -1) *
                                             a.qty) NWeekQty
                                    from sdrpts a, h4v_goodssort Sor
                                   where a.gdgid = Sor.gid
                                     and Sor.ascode in
                                         ('10' �� '11' �� '12' �� '13' �� '14' �� '15' �� '16' �� '17' �� '18' �� '19')
                                     and a.cls in ('����', '������')
                                     and a.fildate  between Fbegdate-29 and Fbegdate
                                   group by a.gdgid, a.snd
                                   order by NWeekQty desc) x) y
                  where y.orderkey_1 < 801
                 
                 ) d
          full join (
                     
                     select *
                       from (
                              
                              select row_number() over(partition by snd order by NWeekQty desc) as orderkey,
                                      snd,
                                      Gdgid,
                                      NWeekQty
                                from (select a.snd,
                                              a.gdgid,
                                              sum(decode(a.cls,
                                                         '����',
                                                         1,
                                                         '������',
                                                         -1) * a.qty) NWeekQty
                                         from sdrpts a, h4v_goodssort Sor
                                        where a.gdgid = Sor.gid
                                          and Sor.ascode in
                                              ('10' �� '11' �� '12' �� '13' �� '14' �� '15' �� '16' �� '17' �� '18' �� '19')
                                          and a.cls in ('����', '������')
                                          and a.fildate  between Fbegdate-14 and Fbegdate
                                        group by a.gdgid, a.snd
                                        order by NWeekQty desc) x) y
                      where y.orderkey < 801) b
            ON b.Gdgid = d.Gdgid
           AND b.Snd = d.Snd
        
        ) A

  left join store c
    on A.snd = c.gid
  left join h4v_goodssort Sor
    on A.Gdgid = Sor.gid
  left join goods g
    on A.Gdgid = g.gid
  left join Area area
    on c.Area = area.code

  left join (select STORE, GDGID, sum(Qty) Qty
               from Businv
              group by STORE, GDGID) bv
    ON A.Gdgid = bv.GDGID
   AND A.Snd = bv.STORE

 where Sor.ascode in
       ('10' �� '11' �� '12' �� '13' �� '14' �� '15' �� '16' �� '17' �� '18' �� '19')
      --and nvl(b.snd, bv.store) = 1000120
      /* and (AreaA is null or AreaA like '%' || area.name || '%')
             and (Province is null or Province like '%' || c.PROVINCE || '%')
             and (Sname is null or Sname like '%' || c.name || '%')
      */
   --and c.code = '10010'
      --  and (b.NWeekQty is not null  or d.NWeekQty is not null )
--   and (A.orderkey < 801 or A.orderkey_1 < 801)
 group by area.name, ---����
          c.PROVINCE, --ʡ��
          c.code, --���
          c.name, --����
          c.STORELEVEL, --���̼���
          c.STORESCALE, --��������
          A.orderkey_1,
          bv.Qty,
          g.rtlprc,
  Fbegdate;


insert into tmp_test1
    (char1, --����
     char2, --ʡ�� 
     char3, --��� 
     char4, ---����
     char5, ---���̼���
     char6, ----�������� 
     num1, ---TOP800�ڿ���(30��)
     num2, ----15�����۶� 
     num3, ----15���վ�����
     num4, ----15��ת���� 
     num5, ---30�����۶�
     num6, ----30���վ�����
     num7,----30��ת���� 
     date1--����
     )
    select char1, --����
     char2, --ʡ�� 
     char3, --��� 
     char4, ---����
     char5, ---���̼���
     char6, ----�������� 
     sum(num1), ---TOP800�ڿ���(30��)
     sum(num2), ----15�����۶� 
     sum(num3), ----15���վ�����
     sum(num1) / (1500 / 15), ----15��ת���� 
     sum(num5), ---30�����۶�
     sum(num6), ----30���վ�����
     case when sum(num6)=0 then 0
       else
       sum(num1) / sum(num6) end , ----30��ת���� 
     date1
from tmp_test2
group by  char1, --����
     char2, --ʡ�� 
     char3, --��� 
     char4, ---����
     char5, ---���̼���
     char6,----�������� 
     date1
;

end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>tmp_test1</TABLE>
    <ALIAS>tmp_test1</ALIAS>
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
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.char1</COLUMN>
    <TITLE>����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <COLUMN>tmp_test1.char2</COLUMN>
    <TITLE>ʡ��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <COLUMN>tmp_test1.char3</COLUMN>
    <TITLE>���</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <COLUMN>tmp_test1.char4</COLUMN>
    <TITLE>����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <COLUMN>tmp_test1.char5</COLUMN>
    <TITLE>���̼���</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.char6</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char6</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num1</COLUMN>
    <TITLE>TOP800�ڿ���(30��)</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num2</COLUMN>
    <TITLE>15�����۶�</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num3</COLUMN>
    <TITLE>15���վ�����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num4</COLUMN>
    <TITLE>15��ת����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
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
    <COLUMN>tmp_test1.num5</COLUMN>
    <TITLE>30�����۶�</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num6</COLUMN>
    <TITLE>30���վ�����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num6</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num7</COLUMN>
    <TITLE>30��ת����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <COLUMN>tmp_test1.date1</COLUMN>
    <TITLE>����</TITLE>
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
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>32</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>38</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>200</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>128</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>76</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>���</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>tmp_test1.date1</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2016.10.07</RIGHTITEM>
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
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test1.char2</LEFT>
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
    <LEFT>tmp_test1.char3</LEFT>
    <OPERATOR>IN</OPERATOR>
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
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>91</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>151</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>125</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>2016.10.07</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM>10010</SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 2��</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 3��</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 4��</SGLINEITEM>
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
  <DXLOADMETHOD>TRUE</DXLOADMETHOD>
  <DXSHOWGROUP>TRUE</DXSHOWGROUP>
  <DXSHOWFOOTER>TRUE</DXSHOWFOOTER>
  <DXSHOWSUMMARY>TRUE</DXSHOWSUMMARY>
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

