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
  vBeginDate date;
  vEndDate Date;
  conType varchar2(20);
begin
  vBeginDate := to_date('\(1,1)','yyyy.mm.dd');
  vEndDate := to_date('\(2,1)','yyyy.mm.dd');
  conType := '\(6,1)';
  
  delete from hdtmp_hd_standard_temp;
  delete from hdtmp_hd_standard;
  COMMIT;
  
  if conType is null or conType = '自营进' then
    --自营进
    insert into hdtmp_hd_standard_temp(vdrgid,gdgid,qty,rtotal,storegid,var_0,fildate,cls)
         select m.vendor,d.gdgid,sum(d.qty),sum(d.total),m.wrh,m.psr,trunc(l.time),'自营进'
           from stkin m,stkindtl d,stkinlog l
          where m.num = d.num and m.cls = d.cls
            and m.num = l.num and m.cls = l.cls
            and m.cls = '自营进'
            and l.stat in (1000,1020,1040,320,340)
            and l.time >= vbegindate
            and l.time < venddate + 1
       group by m.vendor,d.gdgid,m.wrh,m.psr,trunc(l.time);
    commit;
       
    --自营进退
    insert into hdtmp_hd_standard_temp(vdrgid,gdgid,qty,rtotal,storegid,var_0,fildate,cls)
         select m.vendor,d.gdgid,-sum(d.qty),-sum(d.total),m.wrh,m.psr,trunc(l.time),'自营进'
           from stkinbck m,stkinbckdtl d,stkinbcklog l
          where m.num = d.num and m.cls = d.cls
            and m.num = l.num and m.cls = l.cls
            and m.cls = '自营进退'
            and l.stat in (700,720,740,320,340)
            and l.time >= vbegindate
            and l.time < venddate + 1
       group by m.vendor,d.gdgid,m.wrh,m.psr,trunc(l.time);
    commit;
    
  end if;
  if conType is null or conType = '直配出' then   
    --直配出货单
    insert into hdtmp_hd_standard_temp(vdrgid,gdgid,qty,rtotal,storegid,var_0,VAR_1,fildate,cls)
         select m.vendor,d.gdgid,sum(d.qty),sum(d.total),m.receiver,M.PSR,m.filler,trunc(l.time),'直配出'
           from diralc m,diralcdtl d,diralclog l
          where m.num = d.num and m.cls = d.cls
            and m.num = l.num and m.cls = l.cls
            and m.cls = '直配出'
            and l.stat in (1000,1020,1040,320,340)
            and l.time >= vbegindate
            and l.time < venddate + 1
       group by m.vendor,d.gdgid,m.receiver,M.PSR,m.filler,trunc(l.time);
    commit;
      
    --直配出退单
    insert into hdtmp_hd_standard_temp(vdrgid,gdgid,qty,rtotal,storegid,var_0,VAR_1,fildate,cls)
         select m.vendor,d.gdgid,-sum(d.qty),-sum(d.total),m.receiver,M.PSR,m.filler,trunc(l.time),'直配出'
           from diralc m,diralcdtl d,diralclog l
          where m.num = d.num and m.cls = d.cls
            and m.num = l.num and m.cls = l.cls
            and m.cls = '直配出退'
            and l.stat in (700,720,740,320,340)
            and l.time >= vbegindate
            and l.time < venddate + 1
       group by m.vendor,d.gdgid,m.receiver,M.PSR,m.filler,trunc(l.time);
    commit;
  end if;
  
  if conType is null or conType = '统配出' then   
    --统配出
    insert into hdtmp_hd_standard_temp(vdrgid,gdgid,qty,rtotal,storegid,var_1,fildate,cls)
         select 1,d.gdgid,sum(d.qty),sum(d.total),m.client,m.filler,trunc(l.time),'统配出'
           from stkout m,stkoutdtl d,stkoutlog l
          where m.num = d.num and m.cls = d.cls
            and m.num = l.num and m.cls = l.cls
            and m.cls = '统配出'
            and l.stat in (700,720,740,320,340)
            and l.time >= vbegindate
            and l.time < venddate + 1
       group by 1,d.gdgid,m.client,m.filler,trunc(l.time);
    commit;   
    --统配出退
    insert into hdtmp_hd_standard_temp(vdrgid,gdgid,qty,rtotal,storegid,var_1,fildate,cls)
         select 1,d.gdgid,-sum(d.qty),-sum(d.total),m.client,m.filler,trunc(l.time),'统配出'
           from stkoutbck m,stkoutbckdtl d,stkoutbcklog l
          where m.num = d.num and m.cls = d.cls
            and m.num = l.num and m.cls = l.cls
            and m.cls = '统配出退'
            and l.stat in (1000,1020,1040,320,340)
            and l.time >= vbegindate
            and l.time < venddate + 1
       group by 1,d.gdgid,m.client,m.filler,trunc(l.time);
    commit;
  
    --配货差异
    insert into hdtmp_hd_standard_temp(vdrgid,gdgid,qty,rtotal,storegid,var_1,fildate,cls)
         Select 1,d.gdgid,sum(d.qty),sum(d.total),m.store,m.createoper,trunc(l.time),'统配出'
           from alcdiff m,alcdiffdtl d,alcdifflog l
          where m.num = d.num and m.cls = d.cls
            and m.num = l.num and m.cls = l.cls
            and m.cls = '配货差异'
            and l.stat in (400,420,440,320,340)
            and l.time >= vbegindate
            and l.time < venddate + 1
       group by d.gdgid,m.store,m.createoper,trunc(l.time);
    commit;
  end if;
  
  insert into hdtmp_hd_standard(vdrgid,vdrcode,vdrname,gdgid,gdcode,gdname,var,var_2,qty,qty_0,amt,amt_0,rtotal,storegid,var_0,VAR_1,fildate,cls,sortcode,sortname)
       Select v.gid,v.code,v.name,g.gid,g.code,g.name,m.var,m.var_2,sum(m.qty),sum(m.qty_0),m.amt,m.amt_0,sum(m.rtotal),m.storegid,m.var_0,M.VAR_1,m.fildate,m.cls,a.code,a.name
         from hdtmp_hd_standard_temp m,goodsh g,vendorh v,v_sorta a
        where m.gdgid = g.gid and m.vdrgid = v.gid
          and substr(g.sort,1,2)= a.code 
     group by v.gid,v.code,v.name,g.gid,g.code,g.name,m.var,m.var_2,m.amt,m.amt_0,m.storegid,m.var_0,M.VAR_1,m.fildate,m.cls,a.code,a.name;
  commit;
  
  update hdtmp_hd_standard m set (storecode,storename)= (select code,name from store where gid = m.storegid)
    where exists (select 1 from store where gid = m.storegid) and cls <> '自营进';
  update hdtmp_hd_standard m set (storecode,storename)= (select code,name from warehouseh where gid = m.storegid)
    where exists (select 1 from warehouseh where gid = m.storegid) and cls = '自营进';
  commit; 
end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>hdtmp_hd_standard</TABLE>
    <ALIAS>hdtmp_hd_standard</ALIAS>
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
    <COLUMN>hdtmp_hd_standard.cls</COLUMN>
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
    <COLUMN>hdtmp_hd_standard.vdrcode</COLUMN>
    <TITLE>供应商代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <COLUMN>hdtmp_hd_standard.vdrname</COLUMN>
    <TITLE>供应商名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <COLUMN>hdtmp_hd_standard.storecode</COLUMN>
    <TITLE>门店(仓位)代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>storecode</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>hdtmp_hd_standard.storename</COLUMN>
    <TITLE>门店(仓位)名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>storename</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>hdtmp_hd_standard.var_0</COLUMN>
    <TITLE>采购员</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>var_0</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>hdtmp_hd_standard.var_1</COLUMN>
    <TITLE>收货人</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>var_1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>hdtmp_hd_standard.sortcode</COLUMN>
    <TITLE>大类代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sortcode</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>hdtmp_hd_standard.sortname</COLUMN>
    <TITLE>大类名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sortname</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>hdtmp_hd_standard.qty</COLUMN>
    <TITLE>净数量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>qty</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>hdtmp_hd_standard.rtotal</COLUMN>
    <TITLE>金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>rtotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>hdtmp_hd_standard.fildate</COLUMN>
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
  <COLUMNWIDTHITEM>73</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>117</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>77</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>89</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>94</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
  <GROUPITEM>
    <COLUMN>hdtmp_hd_standard.cls</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>hdtmp_hd_standard.vdrcode</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>hdtmp_hd_standard.vdrname</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>hdtmp_hd_standard.storecode</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>hdtmp_hd_standard.storename</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>hdtmp_hd_standard.var_0</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>hdtmp_hd_standard.var_1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>hdtmp_hd_standard.sortcode</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>hdtmp_hd_standard.sortname</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>单据类型</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>hdtmp_hd_standard.fildate</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2015.03.09</RIGHTITEM>
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
    <LEFT>hdtmp_hd_standard.fildate</LEFT>
    <OPERATOR><=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2015.03.09</RIGHTITEM>
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
    <LEFT>hdtmp_hd_standard.sortcode</LEFT>
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
      <PICKNAMEITEM>#TABLE</PICKNAMEITEM>
      <PICKNAMEITEM>NAME</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>SELECT '['||CODE||']'||NAME NAME,CODE FROM V_SORTA ORDER BY CODE</PICKVALUEITEM>
      <PICKVALUEITEM>CODE</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>hdtmp_hd_standard.vdrcode</LEFT>
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
      <PICKNAMEITEM>#TABLE</PICKNAMEITEM>
      <PICKNAMEITEM>NAME</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>SELECT '['||CODE||']'||NAME NAME,CODE FROM VENDOR ORDER BY CODE</PICKVALUEITEM>
      <PICKVALUEITEM>CODE</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>hdtmp_hd_standard.storecode</LEFT>
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
      <PICKNAMEITEM>#TABLE</PICKNAMEITEM>
      <PICKNAMEITEM>NAME</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>SELECT NAME,CODE FROM (SELECT 'S['||CODE||']'||NAME NAME,CODE FROM STORE UNION ALL SELECT 'W['||CODE||']'||NAME NAME,CODE FROM WAREHOUSE) ORDER BY NAME</PICKVALUEITEM>
      <PICKVALUEITEM>CODE</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>hdtmp_hd_standard.cls</LEFT>
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
      <PICKNAMEITEM>自营进</PICKNAMEITEM>
      <PICKNAMEITEM>统配出</PICKNAMEITEM>
      <PICKNAMEITEM>直配出</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>自营进</PICKVALUEITEM>
      <PICKVALUEITEM>统配出</PICKVALUEITEM>
      <PICKVALUEITEM>直配出</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>124</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>2015.03.09</SGLINEITEM>
    <SGLINEITEM>2015.03.09</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 2：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
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
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 4：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
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

