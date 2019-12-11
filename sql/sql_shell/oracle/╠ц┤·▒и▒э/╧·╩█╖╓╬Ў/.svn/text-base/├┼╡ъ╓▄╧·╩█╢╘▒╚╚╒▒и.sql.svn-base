<VERSION>4.1.0</VERSION>
<SQLQUERY>
<REMARK>
[标题]

[应用背景]

[结果列描述]
销售环比：本周销售额-上周销售额/上周销售额
客单价环比：本周客单价-上周客单价/上周客单价
客流量环比：本周客流量-上周客流量/上周客流量
[必要的查询条件]

[实现方法]

[其它]
</REMARK>
<BEFORERUN>
declare
  vDate date;
  vWeekEndDate date;
  vWeekBegDate date;
  vlstWeekEndDate date;
  vlstWeekBegDate date;
  vday date;
  vweekday int;
  cursor c_thisweek is  --本周的销售汇总
    SELECT  t.FILDATE, SUM(t.saleqty) I,
      SUM(t.saleamt + t.saletax) sale0, 
      SUM(t.salecamt + t.salectax ) cb0, 
      SUM((t.saleamt + t.saletax) - (t.salecamt +  t.salectax)) ml0
    FROM STORE, hdtmp_SalDrpt t
    WHERE t.orgkey = STORE.GID      
     and t.FILDATE >= vWeekBegDate 
     and t.FILDATE <=  vWeekEndDate  
    GROUP BY t.FILDATE
    ORDER BY FILDATE ASC; 

   cursor c_lstweek is  --上周的销售汇总
    SELECT  t.FILDATE, SUM(t.saleqty) I,
      SUM(t.saleamt + t.saletax) sale1, 
      SUM(t.salecamt + t.salectax ) cb1, 
      SUM((t.saleamt + t.saletax) - (t.salecamt +  t.salectax)) ml1    
    FROM STORE, hdtmp_SalDrpt t
    WHERE t.orgkey = STORE.GID      
     and t.FILDATE >= vlstWeekBegDate
     and t.FILDATE <=  vlstWeekEndDate  
    GROUP BY t.FILDATE
    ORDER BY FILDATE ASC;
  
  cursor c_thiskd is
    select t.adate fildate, sum(t.dn1) kdl0, round(sum(dt1) / sum(dn1), 2) kdj0
      from cshdrpt t
     where t.adate >= vWeekBegDate
       and t.adate <= vWeekEndDate
     group by t.adate;
  
  cursor c_lstkd is
    select t.adate fildate, sum(t.dn1) kdl1, round(sum(dt1) / sum(dn1), 2) kdj1
      from cshdrpt t
     where t.adate >= vlstWeekBegDate
       and t.adate <= vlstWeekEndDate
     group by t.adate;     
  
begin
  --vDate := to_date('2011.05.11','yyyy.mm.dd');
  vDate := '\(1,1)';
  vWeekEndDate := hdrpt_basic.getWeekEnddateByday(vDate)+1;
  vWeekBegDate := vWeekEndDate - 7;
  vlstWeekBegDate := vWeekEndDate - 14;
  vlstWeekEndDate := vWeekEndDate - 7;
  delete from hdtmp_SalDrpt;  commit;

  insert into hdtmp_SalDrpt(cls,orgkey,pdkey,vdrkey,brdkey,fildate,
                            saleqty,saleamt,saletax,salecamt,salectax,
                            saleqty7,saleamt7,saletax7,salecamt7,salectax7,
                            saleqty14,saleamt14,saletax14,salecamt14,salectax14,
                            saleqty30,saleamt30,saletax30,salecamt30,salectax30,
                            saleqty60,saleamt60,saletax60,salecamt60,salectax60,
                            saleqty90,saleamt90,saletax90,salecamt90,salectax90)
    select null,r.orgkey,null,null,null,(r.fildate),
           sum(r.saleqty),sum(r.saleamt),sum(r.saletax),sum(r.salecamt),
sum(r.salectax),
           sum(r.saleqty7),sum(r.saleamt7),sum(r.saletax7),sum(r.salecamt7),
sum(r.salectax7),
           sum(r.saleqty14),sum(r.saleamt14),sum(r.saletax14),sum(r.salecamt14),
sum(r.salectax14),
           sum(r.saleqty30),sum(r.saleamt30),sum(r.saletax30),sum(r.salecamt30),
sum(r.salectax30),
           sum(r.saleqty60),sum(r.saleamt60),sum(r.saletax60),sum(r.salecamt60),
sum(r.salectax60),
           sum(r.saleqty90),sum(r.saleamt90),sum(r.saletax90),sum(r.salecamt90),
sum(r.salectax90)
     from rpt_storedrpt r,store s
    where r.orgkey = s.gid
      and r.cls in ('零售','成本调整')   
    --  and r.saleqty <> 0
      and (r.fildate <= vWeekEndDate)
      and (r.fildate >= vlstWeekBegDate)
      and s.gid <> 1000000
    group by r.orgkey,(r.fildate);

   insert into hdtmp_SalDrpt(cls,orgkey,pdkey,vdrkey,brdkey,fildate,
                            saleqty,saleamt,saletax,salecamt,salectax)
     select null,r.snd,'',null,null,(r.fildate),
           sum(decode(r.cls,'零售',1,'批发',1,'成本差异',0,'成本调整',0,
-1)*r.qty),sum(decode(r.cls,'零售',1,'批发',1,'成本差异',0,'成本调整',0,
-1)*r.amt),
           sum(decode(r.cls,'零售',1,'批发',1,'成本差异',0,'成本调整',0,
-1)*r.tax),
           sum(decode(r.cls,'零售',1,'批发',1,'成本差异',1,'成本调整',1,
-1)*r.iamt),sum(decode(r.cls,'零售',1,'批发',1,'成本差异',1,'成本调整',1,
-1)*r.itax)          
    from sdrpts r,store s
    where r.snd = s.gid 
      and s.gid <> 1000000
      and r.cls in ( '零售','零售退','批发','批发退','成本差异','成本调整')
      and (r.ocrdate >= trunc(sysdate))
      and (r.fildate < vWeekEndDate)
      and (r.fildate >= vlstWeekBegDate)
    group by r.snd,(r.fildate); 
   commit;
  
  vday:= vWeekBegDate;
  vweekday := 1;
  delete from h4rtmp_salebyweek;COMMIT;
  while vday < vWeekEndDate loop
    insert into h4rtmp_salebyweek(fildate,querydate,isweek,weekday) values (vday,vdate,0,vweekday);
    vday := vday+1;
    vweekday := vweekday+1;  
  end loop; 
  
  vday:= vlstWeekBegdate;
  while vday < vlstWeekEndDate loop
    update h4rtmp_salebyweek set lstfildate = vday where fildate = vday+7; 
    vday := vday+1;  
  end loop; 
   
  for r in c_thisweek loop
     update h4rtmp_salebyweek set sale0 = r.sale0, cb0 = r.cb0, ml0 = r.ml0 where fildate = r.fildate;
  end loop;
  
  for rl in c_lstweek loop
     update h4rtmp_salebyweek set sale1 = rl.sale1, cb1 = rl.cb1, ml1 = rl.ml1 where lstfildate = rl.fildate;
  end loop;  
  
  for p in c_thiskd loop
     update h4rtmp_salebyweek set kdj0 = p.kdj0, kdl0 = p.kdl0 where fildate = p.fildate;
  end loop;  
  
  for p1 in c_lstkd loop
     update h4rtmp_salebyweek set kdj1 = p1.kdj1, kdl1 = p1.kdl1 where lstfildate = p1.fildate;
  end loop;    
  insert into h4rtmp_salebyweek(querydate,sale0,sale1,kdj0,kdj1,kdl0,kdl1,cb0,cb1,ml0,ml1,isweek)
    select vdate,sum(sale0),sum(sale1),avg(kdj0),avg(kdj1),sum(kdl0),sum(kdl1),sum(cb0),sum(cb1),sum(ml0),sum(ml1),1 from h4rtmp_salebyweek group by vdate;
  update h4rtmp_salebyweek t set t.salehb = decode(t.sale1,0,0,round((t.sale0-t.sale1)/t.sale1,4)*100),t.kdjhb = decode(t.kdj1,0,0,round((t.kdj0-t.kdj1)/t.kdj1,4)*100),  
    t.mlhb = decode(t.ml1,0,0,round((t.ml0-t.ml1)/t.ml1,4)*100),t.kdlhb = decode(t.kdl1,0,0,round((t.kdl0-t.kdl1)/t.kdl1,4)*100),t.cbhb = decode(t.cb1,0,0,round((t.cb0-t.cb1)/t.cb1,4)*100),
     t.sale0 = t.sale0/10000, t.sale1 =  t.sale1/10000;
  COMMIT;
end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>h4rtmp_salebyweek</TABLE>
    <ALIAS>h4rtmp_salebyweek</ALIAS>
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
    <COLUMN>decode(h4rtmp_salebyweek.weekday,1,'星期一',2,'星期二',3,'星期三',4,'星期四',5,'星期五',6,'星期六',7,'星期日','周汇总')</COLUMN>
    <TITLE>星期</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>weekday</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.querydate</COLUMN>
    <TITLE>查询日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>querydate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>8388672</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.fildate</COLUMN>
    <TITLE>本周日期</TITLE>
    <FIELDTYPE>11</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>fildate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.lstfildate</COLUMN>
    <TITLE>上周日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>lstfildate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.sale0</COLUMN>
    <TITLE>销售额（万）</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sale0</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.sale1</COLUMN>
    <TITLE>上周销售额（万）</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sale1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711808</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.salehb</COLUMN>
    <TITLE>销售环比（%）</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>salehb</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>255</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.kdj0</COLUMN>
    <TITLE>客单价</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>kdj0</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.kdj1</COLUMN>
    <TITLE>上周客单价</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>kdj1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711808</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.kdjhb</COLUMN>
    <TITLE>客单价环比（%）</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>kdjhb</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>255</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.kdl0</COLUMN>
    <TITLE>客流量</TITLE>
    <FIELDTYPE>3</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>kdl0</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.kdl1</COLUMN>
    <TITLE>上周客流量</TITLE>
    <FIELDTYPE>3</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>kdl1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711808</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.kdlhb</COLUMN>
    <TITLE>客流量环比（%）</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>kdlhb</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>255</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.cb0</COLUMN>
    <TITLE>成本额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>cb0</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.cb1</COLUMN>
    <TITLE>上周成本额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>cb1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711808</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.ml0</COLUMN>
    <TITLE>毛利额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>ml0</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.ml1</COLUMN>
    <TITLE>上周毛利额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>ml1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711808</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.cbhb</COLUMN>
    <TITLE>成本环比（%）</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>cbhb</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.mlhb</COLUMN>
    <TITLE>毛利额环比（%）</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>mlhb</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(h4rtmp_salebyweek.cb0,0,0,round(h4rtmp_salebyweek.ml0*100/(h4rtmp_salebyweek.cb0+h4rtmp_salebyweek.ml0),2))</COLUMN>
    <TITLE>毛利率</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>mll0</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(h4rtmp_salebyweek.cb1,0,0,round(h4rtmp_salebyweek.ml1*100/(h4rtmp_salebyweek.cb1+h4rtmp_salebyweek.ml1),2))</COLUMN>
    <TITLE>上周毛利率</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>mll1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>86</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>98</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>98</COLUMNWIDTHITEM>
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
    <LEFT>h4rtmp_salebyweek.querydate</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2011.05.10</RIGHTITEM>
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
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>110</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>2011.05.10</SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 2：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 3：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 4：</SGLINEITEM>
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
    <NEXTQUERY>门店周销售对比日报(按门店).sql</NEXTQUERY>
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
  <DXCOLOREVENROW>16777215</DXCOLOREVENROW>
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

