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
  vdate varchar2(255);
  vstorecode varchar2(2000);
  vstore varchar2(2000);
begin
  vdate := '\(1,1)';
  vstore := '\(2,1)';
  if vstore is not null then
    PPS_CONVERSTR(vstore ,',',vstorecode);
    chk_sdrpt_right_yzl_test(vdate,vstorecode);
  else
    chk_sdrpt_right_yzl(vdate);
  end if;
end;

/*

create or replace procedure PPS_CONVERSTR(
  piStr    IN varchar2,
  piFilter IN varchar2,
  poStr    OUT varchar2) is
  I     int;
  J     int;
  pTemp varchar2(2550);
  sTemp varchar2(200);
  sTemp1 varchar2(2000);
  sTemp2 varchar2(2000);
begin
  poStr := '';
  if piStr is null then
    return;
  end if;
  if piFilter is null then
    return;
  end if;
  pTemp := piStr;
  I     := LENGTH(pTemp);
  WHILE I <> 0 LOOP
    J := InSTR(pTemp,piFilter);
    if J <> 0 then
      sTemp1 :=SUBSTR(pTemp,1,j-1);
      sTemp2 :=SUBSTR(pTemp,j,1);
      poStr := poStr || '''' || sTemp1 ||'''' || sTemp2;
      pTemp :=SUBSTR(pTemp,j+1,I);
    else
      sTemp1 :=SUBSTR(pTemp,1,i);
      poStr := poStr || '''' || sTemp1 ||'''';
      poStr :='(' || '''' || substr(poStr,2,length(postr)-2)|| '''' || 
')';
      return;
    end if;
    I := LENGTH(pTemp);
  END LOOP;
  return;
end;
/
exec hdcreatesynonym('PPS_CONVERSTR');
/
grant execute on PPS_CONVERSTR to ROLE_HDQRY;
/
create global temporary table CHK_RESULT_YZL
(
  ADATE     DATE,
  STORE     NUMBER,
  BUYTOTAL  NUMBER(24,2),
  STOTAL    NUMBER(24,2),
  SCOUNT    NUMBER,
  SMAXFLNO  NUMBER,
  ALOWRECA  NUMBER,
  BUY1TOTAL NUMBER,
  BUY2TOTAL NUMBER
)
on commit preserve rows;
/
exec hdcreatesynonym('CHK_RESULT_YZL');
exec granttoqryrole('CHK_RESULT_YZL');
/

create table CHK_RESULT_YZL_RECA
(
  ADATE    DATE,
  STORE    NUMBER,
  BUYTOTAL NUMBER(24,2),
  STOTAL   NUMBER(24,2),
  SCOUNT   NUMBER,
  SMAXFLNO NUMBER,
  ALOWRECA NUMBER
)
;
/
exec hdcreatesynonym('CHK_RESULT_YZL_RECA');
exec granttoqryrole('CHK_RESULT_YZL_RECA');
/

create or replace procedure chk_sdrpt_right_yzl
(
  pidate date
)
is
cursor c is
select gid from t_store;
cursor reca is
  select code,gid,adate from chk_result_yzl, store where store = gid
  group by adate,code,gid
  having sum(buytotal)<>sum(stotal);
begin
 delete from t_store;
 insert into t_store
 select gid from store;
 commit;

  delete from chk_result_yzl where adate = pidate;
  commit;
  for s in c loop
    insert into chk_result_yzl(adate,store,buytotal,stotal)
    select pidate, w.storegid, sum(b1.realamt), 0 
    from workstation w,buy1s b1
    where b1.posno = w.no
      and w.storegid = s.gid
      and trunc(b1.busdate) = pidate
    group by storegid;

    insert into chk_result_yzl(adate,store,scount,smaxflno)
      select pidate,storegid,count(*),substr(max(flowno),9,4) from workstation,buy1s
        where flowno like to_char(pidate,'yyyymmdd')||'%' and posno = no
        and storegid = s.gid
      group by storegid,posno;

  end loop;
  commit;

  insert into chk_result_yzl(adate,store,stotal,buytotal)
  select pidate,snd,sum(decode(cls,'零售',amt+tax,'零售退',-amt-tax)),0
  from sdrpts where sdrpts.fildate = pidate and cls in ('零售','零售退')
  AND BNUM <> '订奶'
  group by snd;
  commit;

  for s in reca loop
    delete from chk_result_yzl_reca where store = s.gid and adate = s.adate;
    commit;

    insert into chk_result_yzl_reca(adate,store,buytotal,stotal)
      select adate,gid,sum(buytotal),sum(stotal) from chk_result_yzl, store where store = gid and gid = s.gid and adate = s.adate-- and adate < to_date('2006.1.1','yyyy.mm.dd')
      group by adate,gid
      having sum(buytotal)<>sum(stotal);
   commit;
 end loop;
end;
/
exec hdcreatesynonym('chk_sdrpt_right_yzl');
/
grant execute on chk_sdrpt_right_yzl to role_hdqry;
/


create or replace procedure chk_sdrpt_right_yzl_test
(
  pidate date,
  pistorecode varchar2
)
is
--added by fcl 2008.01.15
--可以输入门店代码范围，若不输入则默认全部
--传入的门店代码已经转化为('0101','0102')
vCmd varchar2(2048);
cursor c is
select gid from t_store;
cursor reca is
  select store.code,store.gid,adate from chk_result_yzl, store,t_store
  where store = store.gid-- and adate < to_date('2006.1.1','yyyy.mm.dd')
  and t_store.gid=store.gid
  group by adate,store.code,store.gid
  having sum(buytotal)<>sum(stotal);
begin
 delete from t_store;
 commit;
 if pistorecode is null then
   insert into t_store
   select gid from store where property = 2;
   commit;
 else
   vCmd :='INSERT INTO t_store'
    || ' select GID from store  where CODE in '
    || pistorecode  ;
   execute immediate vCmd;
   commit;
 end if;

  delete from chk_result_yzl where adate = pidate;
  commit;
  for s in c loop
    insert into chk_result_yzl(adate,store,buytotal,stotal)
    select pidate, w.storegid, sum(b1.realamt), 0 
    from workstation w, buy1s b1
    where b1.posno = w.no
      and w.storegid = s.gid
      and trunc(b1.busdate) = pidate
    group by storegid;

    insert into chk_result_yzl(adate,store,scount,smaxflno)
      select pidate,storegid,count(*),substr(max(flowno),9,4) from
workstation,buy1s
        where flowno like to_char(pidate,'yyyymmdd')||'%' and posno = no
        and storegid = s.gid
      group by storegid,posno;

  end loop;
  commit;

  insert into chk_result_yzl(adate,store,stotal,buytotal)
  select pidate,snd,sum(decode(cls,'零售',amt+tax,'零售退',-amt-tax)),0
  from sdrpts where sdrpts.fildate = pidate and cls in ('零售','零售退')
  AND BNUM <> '订奶'
  group by snd;
  commit;

  for s in reca loop
    delete from chk_result_yzl_reca where store = s.gid and adate =
s.adate;
    commit;

    insert into chk_result_yzl_reca(adate,store,buytotal,stotal)
      select adate,gid,sum(buytotal),sum(stotal) from chk_result_yzl,
store where store = gid and gid = s.gid and adate = s.adate-- and adate < to_date('2006.1.1','yyyy.mm.dd')
      group by adate,gid
      having sum(buytotal)<>sum(stotal);
   commit;
 end loop;
end;
/
exec hdcreatesynonym('chk_sdrpt_right_yzl_test');
/
grant execute on chk_sdrpt_right_yzl_test to role_hdqry;
/
*/
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>STORE</TABLE>
    <ALIAS>STORE</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>chk_result_yzl</TABLE>
    <ALIAS>chk_result_yzl</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
</TABLELIST>
<JOINLIST>
  <JOINITEM>
    <LEFT>chk_result_yzl.store</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>STORE.GID</RIGHT>
  </JOINITEM>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>STORE.CODE</COLUMN>
    <TITLE>门店代码</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <COLUMN>STORE.NAME</COLUMN>
    <TITLE>门店名称</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <COLUMN>chk_result_yzl.adate</COLUMN>
    <TITLE>日期</TITLE>
    <FIELDTYPE>11</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>adate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>chk_result_yzl.buytotal</COLUMN>
    <TITLE>销售表金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>buytotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>chk_result_yzl.stotal</COLUMN>
    <TITLE>日报金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>stotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>chk_result_yzl.scount</COLUMN>
    <TITLE>销售笔数</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>scount</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>chk_result_yzl.smaxflno</COLUMN>
    <TITLE>最大销售笔数</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>smaxflno</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>chk_result_yzl.alowreca</COLUMN>
    <TITLE>允许盘点</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alowreca</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>sum(chk_result_yzl.scount)-sum(chk_result_yzl.smaxflno)</COLUMN>
    <TITLE>销售笔数差异</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>cpa</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>sum(chk_result_yzl.buytotal)-sum(chk_result_yzl.stotal)</COLUMN>
    <TITLE>金额差异</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>cpa2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>122</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>103</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>95</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>62</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>98</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>97</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>79</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
  <GROUPITEM>
    <COLUMN>STORE.CODE</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>STORE.NAME</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>chk_result_yzl.adate</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>金额差异</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>chk_result_yzl.adate</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2010.05.29</RIGHTITEM>
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
    <LEFT>STORE.CODE</LEFT>
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
  <CRITERIAWIDTHITEM>179</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>142</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>2010.05.29</SGLINEITEM>
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
  <DXCOLORODDROW>12632256</DXCOLORODDROW>
  <DXCOLOREVENROW>15921906</DXCOLOREVENROW>
  <DXFILTERNAME></DXFILTERNAME>
  <DXFILTERLIST>
  </DXFILTERLIST>
  <DXSHOWGRIDLINE>1</DXSHOWGRIDLINE>
</DXDBGRIDITEM>
</SQLQUERY>
<SQLREPORT>
<RPTTITLE>检查销售表和日报差异</RPTTITLE>
<RPTGROUPCOUNT>0</RPTGROUPCOUNT>
<RPTGROUPLIST>
</RPTGROUPLIST>
<RPTCOLUMNCOUNT>9</RPTCOLUMNCOUNT>
<RPTCOLUMNWIDTHLIST>
  <RPTCOLUMNWIDTHITEM>69</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>158</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>68</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>66</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>97</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>64</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>78</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>103</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>95</RPTCOLUMNWIDTHITEM>
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

