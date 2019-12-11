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
DECLARE

  VPOSNO  VARCHAR2(20);
  vbdate  DATE;
  vedate  date;
  VMINFNUM  VARCHAR2(20);
  VMAXFNUM  VARCHAR2(20);
  VFNUM  VARCHAR2(20);
  vline  number(24);
  vmaxconflowno number(24);
  vminconflowno number(24);
  vtempposno   varchar2(20);
  
  Cursor C Is
    select rownum line , H4RTMP_MSDFLOWNUMex.*  from H4RTMP_MSDFLOWNUMex 
      order by posno , msdate desc ; --按照日期倒序来安排

BEGIN
  DELETE FROM H4RTMP_MSDFLOWNUM;
  DELETE FROM H4RTMP_MSDFLOWNUMex;
  DELETE FROM H4RTMP_MSDFLOWNUMex2;
  COMMIT;

  vbdate := to_date(TRIM('\(1,1)'),'YYYY.MM.DD');
  vedate := to_date(TRIM('\(2,1)'),'YYYY.MM.DD');
  VPOSNO := TRIM('\(3,1)');
  
  if vbdate is null then
    begin
      select to_date(substr(min(flowno), 1, 8), 'YYYY.MM.DD') into vbdate from buy1s;
    exception
      when no_data_found  then
        vbdate := to_date('1899.01.01', 'YYYY.MM.DD');
    end;
  end if;
  
  if vedate is null then
    vedate := trunc(sysdate);
  end if;
  
  insert into H4RTMP_MSDFLOWNUMex(msdate, posno, minflowno,maxflowno,
mincontflowno,maxcontflowno,firstflowtime,lastflowtime,flownocnt)
  select trunc(b1.fildate) , b1.posno, min(b1.flowno) , max(b1.flowno) ,
min(substr(b1.continuousflowno,-10,10)) , max(substr(b1.continuousflowno,-10,10)),
   min(fildate) firstflowtime,max(fildate) lastflowtime, count(flowno)
  from buy1s b1
  where fildate < vedate+1
    and fildate >= vbdate - 1  --为了检查 查询时间段
    and (b1.posno = vposno or vposno is null)
  group by trunc(b1.fildate), b1.posno
  order by b1.posno , trunc(b1.fildate);
  commit;
  
   
/*除了当天的销售需要核对，还要核对昨天和今天的流水有没有异常，通过buy1s里面的 
continuousflowno，这个流水是前台不间断的流水号
         
算法：目前这个不间断流水号也有可能断号，主要的原因是，1、前台机器进行了更换或者程序重新安装了，没有在新版本的程序下 
调整continuousflowno
           2、前台冲账 ，buy1s里面的 continuousflowno 
为空，但是号码还是正常+1的。
           因此，目前的主要做法是，检查 
查询的时间段的前一天最后一笔流水的不间断流水和后一天 的第一笔不间断流水 
与查询时间段相临的流水里面的不间断流水号的差值是否不为1.
           由于 continuousflowno是 
按照门店操作来记录的：比如关机、退出等都会导致continuousflowno+1，
           这样第2天开机之后，第一笔流水号的continuousflowno 
和前一天最后一笔差异最大的可以达到7。
           因此暂定，差异7以上，提示有异常，人工核对
         */
  --核对不间断流水号
  /*
    通过游标来处理：
    这一种对某台电脑中间某几天不销售会出现假警报,
         因此在查询条件里面,通过日期关联时,使用全关联有遗漏
         */
  for r in c loop
      if vtempposno = r.posno and vminconflowno - nvl(r.maxcontflowno,0) > 7 then 
         -- 游标按照POS号 和 日期倒序排列，如果 上一条记录(日期T) 最小不间断流水号 和 本条记录 最大不间断流水号相差5以上，则认为有异常
        insert into H4RTMP_MSDFLOWNUM(msdate, posno, minflowno,maxflowno,mincontflowno,maxcontflowno,
          firstflowtime,lastflowtime,flownocnt,note)
        select r.msdate , r.posno , r.minflowno, r.maxflowno,r.mincontflowno, r.maxcontflowno ,
           r.firstflowtime,r.lastflowtime,r.flownocnt, '前一天不间断流水异常,人工核对'||to_char(r.msdate,'yyyy.mm.dd')||'销售是否上传完成' note
          from dual ;
       else  
        if to_number(substr(r.maxflowno,-4,4)) <> r.flownocnt then 
            insert into H4RTMP_MSDFLOWNUM(msdate, posno, minflowno,maxflowno,mincontflowno,maxcontflowno,
              firstflowtime,lastflowtime,flownocnt,note)
            select r.msdate , r.posno , r.minflowno, r.maxflowno,r.mincontflowno, r.maxcontflowno ,
               r.firstflowtime,r.lastflowtime,r.flownocnt, to_char(r.msdate,'yyyy.mm.dd')||'流水断号'||to_char(to_number(substr(r.maxflowno,-4,4)) - r.flownocnt)||'笔' note
              from dual ;  
         else
            insert into H4RTMP_MSDFLOWNUM(msdate, posno, minflowno,maxflowno,mincontflowno,maxcontflowno,
              firstflowtime,lastflowtime,flownocnt,note)
            select r.msdate , r.posno , r.minflowno, r.maxflowno,r.mincontflowno, r.maxcontflowno ,
               r.firstflowtime,r.lastflowtime,r.flownocnt, '流水正常' note
              from dual ;           
         end if;     
       end if;
       
       vtempposno := r.posno ; --记录上次POSNO
       vmaxconflowno := r.maxcontflowno ;
       vminconflowno := r.mincontflowno ;   
      
       commit;    
  end loop;
  
END;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>H4RTMP_MSDFLOWNUM</TABLE>
    <ALIAS>H4RTMP_MSDFLOWNUM</ALIAS>
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
    <COLUMN>H4RTMP_MSDFLOWNUM.posno</COLUMN>
    <TITLE>收银机号</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>posno</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_MSDFLOWNUM.msdate</COLUMN>
    <TITLE>销售日期</TITLE>
    <FIELDTYPE>11</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>msdate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>to_char(H4RTMP_MSDFLOWNUM.minflowno)</COLUMN>
    <TITLE>最小流水</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>minflowno</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>to_char(H4RTMP_MSDFLOWNUM.maxflowno)</COLUMN>
    <TITLE>最大流水</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>maxflowno</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_MSDFLOWNUM.firstflowtime</COLUMN>
    <TITLE>最早销售时间</TITLE>
    <FIELDTYPE>11</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>firstflowtime</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_MSDFLOWNUM.lastflowtime</COLUMN>
    <TITLE>最晚销售时间</TITLE>
    <FIELDTYPE>11</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>maxcontflowno1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>to_char(H4RTMP_MSDFLOWNUM.mincontflowno)</COLUMN>
    <TITLE>mincontflowno</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>mincontflowno</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>to_char(H4RTMP_MSDFLOWNUM.maxcontflowno)</COLUMN>
    <TITLE>maxcontflowno</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>maxcontflowno</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_MSDFLOWNUM.flownocnt</COLUMN>
    <TITLE>记录数</TITLE>
    <FIELDTYPE>3</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>flownocnt</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_MSDFLOWNUM.maxflowno - H4RTMP_MSDFLOWNUM.minflowno - H4RTMP_MSDFLOWNUM.flownocnt + 1</COLUMN>
    <TITLE>断号流水记录</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>flownocnt1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_MSDFLOWNUM.note</COLUMN>
    <TITLE>结果说明</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>note</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>122</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>122</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>122</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>338</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>最早销售时间</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>H4RTMP_MSDFLOWNUM.msdate</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2011.04.01</RIGHTITEM>
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
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>H4RTMP_MSDFLOWNUM.msdate</LEFT>
    <OPERATOR><</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2011.04.21</RIGHTITEM>
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
    <DEFAULTVALUE>今天</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>H4RTMP_MSDFLOWNUM.posno</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>0291a</RIGHTITEM>
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
  <CRITERIAWIDTHITEM>108</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>115</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>99</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>2011.04.01</SGLINEITEM>
    <SGLINEITEM>2011.04.21</SGLINEITEM>
    <SGLINEITEM>0291a</SGLINEITEM>
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
    <SGLINEITEM>no</SGLINEITEM>
  </LINE>
</SG>
<CHECKLIST>
  <CAPTION>
    <CAPTIONITEM>有流水断号</CAPTIONITEM>
  </CAPTION>
  <EXPRESSION>
    <EXPRESSIONITEM>note <> '流水正常'</EXPRESSIONITEM>
  </EXPRESSION>
  <CHECKED>
    <CHECKEDITEM>no</CHECKEDITEM>
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

