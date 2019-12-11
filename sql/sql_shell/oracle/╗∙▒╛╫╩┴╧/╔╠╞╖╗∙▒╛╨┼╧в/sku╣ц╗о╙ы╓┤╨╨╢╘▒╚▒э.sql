<VERSION>4.1.0</VERSION>
<SQLQUERY>
<REMARK>
[标题]
 [应用背景] ：
 [结果列描述] ：
 [必要的查询条件] ：  
1、分类标识如果不填，默认为按小类查询
2、本报表反映的是可经营商品sku，可经营商品的范围由项目定制视图v_goodssort；
3、虎彩项目的可经营商品不包含淘汰期、废除期
4、库存sku数：当前01仓有库存的sku数，生命周期不包括淘汰和废除的，实时变化（仓库查看）

 [实现方法] ：
 [临时表结构]：
create global temporary table H4RTMP_GOODSSORT
(
  SORTCODE VARCHAR2(10),
  SORTNAME VARCHAR2(40),
  MAXQTY   NUMBER,
  ACVQTY   NUMBER,
  FLAG     VARCHAR2(10)
)
on commit preserve rows;
-- Grant/Revoke object privileges 
grant insert, update, delete on H4RTMP_GOODSSORT to ROLE_HDAPP;
grant insert, update, delete on H4RTMP_GOODSSORT to ROLE_HDQRY;
 [版本记录]： 20101002 + liukai
 [其它]：
</REMARK>
<BEFORERUN>
declare
  vflag varchar2(10);
begin
  delete from h4rtmp_goodssort;
  commit;
  select decode('\(1,1)','小类','6','中类','4','大类','2',null) into vflag from dual;
  if vflag is not null then
  insert into h4rtmp_goodssort(sortcode,sortname,maxqty,flag,acvqty,count1,count2,count3,count4,count5,count6,count7,count8,count9)
  select s.scode,s.sname,s.maxqty,'\(1,1)',
       nvl(v.count,0),nvl(a.count,0),nvl(b.count,0),nvl(c.count,0),nvl(d.count,0),nvl(e.count,0),nvl(f.count,0),nvl(g.count,0),nvl(h.count,0),nvl(i.count,0)
  from sortname s , 
      (select substr(sort,1,vflag) sort,count(gid) count from v_goodssort group by substr(sort,1,vflag)) v,
      (select substr(sort,1,vflag) sort,count(gid) count from v_goodssort where lifecycle = '申请期' group by substr(sort,1,vflag)) a,
      (select substr(sort,1,vflag) sort,count(gid) count from v_goodssort where lifecycle = '导入期' group by substr(sort,1,vflag)) b,
      (select substr(sort,1,vflag) sort,count(gid) count from v_goodssort where lifecycle = '成长期' group by substr(sort,1,vflag)) c,
      (select substr(sort,1,vflag) sort,count(gid) count from v_goodssort where lifecycle = '成熟期' group by substr(sort,1,vflag)) d,
      (select substr(sort,1,vflag) sort,count(gid) count from v_goodssort where lifecycle = '衰退期' group by substr(sort,1,vflag)) e,
      (select substr(sort,1,vflag) sort,count(gid) count from v_goodssort where lifecycle = '淘汰期' group by substr(sort,1,vflag)) f,
      (select substr(sort,1,vflag) sort,count(gid) count from v_goodssort where lifecycle = '废除期' group by substr(sort,1,vflag)) g,
      (select substr(goodsh.sort,1,vflag) sort,count(bus.gdgid) count from businv bus,goodsh goodsh  --下列h、i为虎彩定制
           where bus.gdgid(+) = goodsh.gid and bus.wrh='1000000' and bus.qty >0 and goodsh.lifecycle not in ('淘汰期','废除期') group by  substr(goodsh.sort,1,vflag) ) h,
      (select substr(sort,1,vflag) sort,count(gid) count from goodsh where lifecycle = '淘汰期' group by substr(sort,1,vflag)) i
    where s.acode = '0000' and scode <> '-' and length(s.scode) = vflag 
          and s.scode = v.sort(+) and s.scode = a.sort(+)
          and s.scode = b.sort(+) and s.scode = c.sort(+) and s.scode = d.sort(+) 
          and s.scode = e.sort(+) and s.scode = f.sort(+) and s.scode = g.sort(+)
          and s.scode = h.sort(+) and s.scode = i.sort(+)
      order by s.scode;
  else 
  insert into h4rtmp_goodssort(sortcode,sortname,maxqty,flag,acvqty,count1,count2,count3,count4,count5,count6,count7,count8,count9)
  select s.scode,s.sname,s.maxqty,null,
       nvl(v.count,0),nvl(a.count,0),nvl(b.count,0),nvl(c.count,0),nvl(d.count,0),nvl(e.count,0),nvl(f.count,0),nvl(g.count,0),nvl(h.count,0),nvl(i.count,0)
  from sortname s , 
      (select substr(sort,1,2) sort,count(gid) count from v_goodssort group by substr(sort,1,2)) v,
      (select substr(sort,1,2) sort,count(gid) count from v_goodssort where lifecycle = '申请期' group by substr(sort,1,2)) a,
      (select substr(sort,1,2) sort,count(gid) count from v_goodssort where lifecycle = '导入期' group by substr(sort,1,2)) b,
      (select substr(sort,1,2) sort,count(gid) count from v_goodssort where lifecycle = '成长期' group by substr(sort,1,2)) c,
      (select substr(sort,1,2) sort,count(gid) count from v_goodssort where lifecycle = '成熟期' group by substr(sort,1,2)) d,
      (select substr(sort,1,2) sort,count(gid) count from v_goodssort where lifecycle = '衰退期' group by substr(sort,1,2)) e,
      (select substr(sort,1,2) sort,count(gid) count from v_goodssort where lifecycle = '淘汰期' group by substr(sort,1,2)) f,
      (select substr(sort,1,2) sort,count(gid) count from v_goodssort where lifecycle = '废除期' group by substr(sort,1,2)) g,
      (select substr(goodsh.sort,1,2) sort,count(bus.gdgid) count from businv bus,goodsh goodsh  --下列h、i为虎彩定制
           where bus.gdgid(+) = goodsh.gid and bus.wrh='1000000' and bus.qty >0 and goodsh.lifecycle not in ('淘汰期','废除期') group by  substr(goodsh.sort,1,2) ) h,
      (select substr(sort,1,2) sort,count(gid) count from goodsh where lifecycle = '淘汰期' group by substr(sort,1,2)) i
    where s.acode = '0000' and scode <> '-' and length(s.scode) = 2 
          and s.scode = v.sort(+) and s.scode = a.sort(+)
          and s.scode = b.sort(+) and s.scode = c.sort(+) and s.scode = d.sort(+) 
          and s.scode = e.sort(+) and s.scode = f.sort(+) and s.scode = g.sort(+)
          and s.scode = h.sort(+) and s.scode = i.sort(+)
      order by s.scode;
  insert into h4rtmp_goodssort(sortcode,sortname,maxqty,flag,acvqty,count1,count2,count3,count4,count5,count6,count7,count8,count9)
  select s.scode,s.sname,s.maxqty,null,
       nvl(v.count,0),nvl(a.count,0),nvl(b.count,0),nvl(c.count,0),nvl(d.count,0),nvl(e.count,0),nvl(f.count,0),nvl(g.count,0),nvl(h.count,0),nvl(i.count,0)
  from sortname s , 
      (select substr(sort,1,4) sort,count(gid) count from v_goodssort group by substr(sort,1,4)) v,
      (select substr(sort,1,4) sort,count(gid) count from v_goodssort where lifecycle = '申请期' group by substr(sort,1,4)) a,
      (select substr(sort,1,4) sort,count(gid) count from v_goodssort where lifecycle = '导入期' group by substr(sort,1,4)) b,
      (select substr(sort,1,4) sort,count(gid) count from v_goodssort where lifecycle = '成长期' group by substr(sort,1,4)) c,
      (select substr(sort,1,4) sort,count(gid) count from v_goodssort where lifecycle = '成熟期' group by substr(sort,1,4)) d,
      (select substr(sort,1,4) sort,count(gid) count from v_goodssort where lifecycle = '衰退期' group by substr(sort,1,4)) e,
      (select substr(sort,1,4) sort,count(gid) count from v_goodssort where lifecycle = '淘汰期' group by substr(sort,1,4)) f,
      (select substr(sort,1,4) sort,count(gid) count from v_goodssort where lifecycle = '废除期' group by substr(sort,1,4)) g,
      (select substr(goodsh.sort,1,4) sort,count(bus.gdgid) count from businv bus,goodsh goodsh  --下列h、i为虎彩定制
           where bus.gdgid(+) = goodsh.gid and bus.wrh='1000000' and bus.qty >0 and goodsh.lifecycle not in ('淘汰期','废除期') group by  substr(goodsh.sort,1,4) ) h,
      (select substr(sort,1,4) sort,count(gid) count from goodsh where lifecycle = '淘汰期' group by substr(sort,1,4)) i
    where s.acode = '0000' and scode <> '-' and length(s.scode) = 4 
          and s.scode = v.sort(+) and s.scode = a.sort(+)
          and s.scode = b.sort(+) and s.scode = c.sort(+) and s.scode = d.sort(+) 
          and s.scode = e.sort(+) and s.scode = f.sort(+) and s.scode = g.sort(+)
          and s.scode = h.sort(+) and s.scode = i.sort(+)
      order by s.scode;
  insert into h4rtmp_goodssort(sortcode,sortname,maxqty,flag,acvqty,count1,count2,count3,count4,count5,count6,count7,count8,count9)
  select s.scode,s.sname,s.maxqty,null,
       nvl(v.count,0),nvl(a.count,0),nvl(b.count,0),nvl(c.count,0),nvl(d.count,0),nvl(e.count,0),nvl(f.count,0),nvl(g.count,0),nvl(h.count,0),nvl(i.count,0)
  from sortname s , 
      (select substr(sort,1,6) sort,count(gid) count from v_goodssort group by substr(sort,1,6)) v,
      (select substr(sort,1,6) sort,count(gid) count from v_goodssort where lifecycle = '申请期' group by substr(sort,1,6)) a,
      (select substr(sort,1,6) sort,count(gid) count from v_goodssort where lifecycle = '导入期' group by substr(sort,1,6)) b,
      (select substr(sort,1,6) sort,count(gid) count from v_goodssort where lifecycle = '成长期' group by substr(sort,1,6)) c,
      (select substr(sort,1,6) sort,count(gid) count from v_goodssort where lifecycle = '成熟期' group by substr(sort,1,6)) d,
      (select substr(sort,1,6) sort,count(gid) count from v_goodssort where lifecycle = '衰退期' group by substr(sort,1,6)) e,
      (select substr(sort,1,6) sort,count(gid) count from v_goodssort where lifecycle = '淘汰期' group by substr(sort,1,6)) f,
      (select substr(sort,1,6) sort,count(gid) count from v_goodssort where lifecycle = '废除期' group by substr(sort,1,6)) g,
      (select substr(goodsh.sort,1,6) sort,count(bus.gdgid) count from businv bus,goodsh goodsh  --下列h、i为虎彩定制
           where bus.gdgid(+) = goodsh.gid and bus.wrh='1000000' and bus.qty >0 and goodsh.lifecycle not in ('淘汰期','废除期') group by  substr(goodsh.sort,1,6) ) h,
      (select substr(sort,1,6) sort,count(gid) count from goodsh where lifecycle = '淘汰期' group by substr(sort,1,6)) i
    where s.acode = '0000' and scode <> '-' and length(s.scode) = 6 
          and s.scode = v.sort(+) and s.scode = a.sort(+)
          and s.scode = b.sort(+) and s.scode = c.sort(+) and s.scode = d.sort(+) 
          and s.scode = e.sort(+) and s.scode = f.sort(+) and s.scode = g.sort(+)
          and s.scode = h.sort(+) and s.scode = i.sort(+)
      order by s.scode;
  end if;
commit;
end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>h4rtmp_goodssort</TABLE>
    <ALIAS>h4rtmp_goodssort</ALIAS>
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
    <COLUMN>h4rtmp_goodssort.sortcode</COLUMN>
    <TITLE>类别代码</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>scode</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_goodssort.sortname</COLUMN>
    <TITLE>类别名称</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sname</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_goodssort.maxqty</COLUMN>
    <TITLE>SKU规划上限</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>maxqty</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_goodssort.acvqty</COLUMN>
    <TITLE>实际品项数</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>acvqty</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_goodssort.count8</COLUMN>
    <TITLE>库存SKU数</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>count8</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_goodssort.maxqty - h4rtmp_goodssort.acvqty</COLUMN>
    <TITLE>规划与实际差异数</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>cy</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_goodssort.flag</COLUMN>
    <TITLE>分类标识</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>flag</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_goodssort.count1</COLUMN>
    <TITLE>申请期</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>count1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_goodssort.count2</COLUMN>
    <TITLE>导入期</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>count2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_goodssort.count3</COLUMN>
    <TITLE>成长期</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>count3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_goodssort.count4</COLUMN>
    <TITLE>成熟期</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>count4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_goodssort.count5</COLUMN>
    <TITLE>衰退期</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>count5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_goodssort.count6</COLUMN>
    <TITLE>淘汰期</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>count6</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_goodssort.count9</COLUMN>
    <TITLE>淘汰期(全量)</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>count9</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_goodssort.count7</COLUMN>
    <TITLE>废除期</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>count7</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>116</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>97</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>63</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>67</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>h4rtmp_goodssort.flag</LEFT>
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
      <PICKNAMEITEM>小类</PICKNAMEITEM>
      <PICKNAMEITEM>中类</PICKNAMEITEM>
      <PICKNAMEITEM>大类</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>小类</PICKVALUEITEM>
      <PICKVALUEITEM>中类</PICKVALUEITEM>
      <PICKVALUEITEM>大类</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>h4rtmp_goodssort.sortcode</LEFT>
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
    </PICKNAME>
    <PICKVALUE>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>h4rtmp_goodssort.sortname</LEFT>
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
    </PICKNAME>
    <PICKVALUE>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>119</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>157</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>163</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
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

