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
VQTY  varchar2(20);    /* 界定值 报表上输入界定值 */
outdate date;
begin

VQTY := '\(1,1)';
outdate :=to_date('\(2,1)', 'yyyy.mm.dd');


  delete from tmp_businvstat; 
  commit;
  delete from tmp_businvstat1; 
  commit;

/*充足sku  充足sku金额  库存数量大于Vqty 为库存充足*/
insert into tmp_businvstat(sort1,sort2,sort3,sort4,gdcode,gdname,sku1,total1)
select substr(g.sort, 1, 2),
       substr(g.sort, 1, 4),
       substr(g.sort, 1, 6),
       substr(g.sort, 1, 8),
       g.code,
       g.name,
       count(b.gdgid),
       sum(b.qty*r.rtlprc)
  from businv b, goods g,RPGGD r,warehouse w
 where b.gdgid = g.gid
   and g.code = r.inputcode
   and b.wrh =w.gid
   and b.STORE = 1000000
   and b.qty > VQTY 
 group by substr(g.sort, 1, 2),
          substr(g.sort, 1, 4),
          substr(g.sort, 1, 6),
           substr(g.sort, 1, 8),
           g.code,
          g.name;
 commit;
 
/*缺货sku  缺货sku金额  库存数量大于0 小于界定值 vqty   */          
insert into tmp_businvstat(sort1,sort2,sort3,sort4,gdcode,gdname,sku2,total2)          
select substr(g.sort, 1, 2),
       substr(g.sort, 1, 4),
       substr(g.sort, 1, 6),
       substr(g.sort, 1, 8),
       g.code,
       g.name,
       count(b.gdgid),
        sum(b.qty*r.rtlprc)
  from businv b, goods g,RPGGD r,warehouse w
 where b.gdgid = g.gid
   and g.code = r.inputcode
   and b.wrh =w.gid
   and b.STORE = 1000000
   and b.qty > 100         --20150708  余海扬调整大于100小于vqty为缺货
   and b.qty <= VQTY 
 group by substr(g.sort, 1, 2),
          substr(g.sort, 1, 4),
          substr(g.sort, 1, 6),
           substr(g.sort, 1, 8),
          g.name,
          g.code;
  commit;        
          

/*库存数量小于0 为断货的sku */          
insert into tmp_businvstat(sort1,sort2,sort3,sort4,gdcode,gdname,sku3,total3)          
select substr(g.sort, 1, 2),
       substr(g.sort, 1, 4),
       substr(g.sort, 1, 6),
        substr(g.sort, 1, 8),
       g.code,
       g.name,
       count(b.gdgid),
       sum(b.qty*r.rtlprc)
  from businv b, goods g,RPGGD r,warehouse w
 where b.gdgid = g.gid
   and g.code = r.inputcode
   and b.wrh =w.gid
   and b.STORE = 1000000
   and b.qty <= 100         --20150708  余海扬调整小于100为断货
   and not exists (select 1 from orddtl u,ord o where o.num=u.num and o.cls = u.cls and  o.stat in (100,200) and u.GDGID = b.gdgid and u.lackqty>0)
 group by substr(g.sort, 1, 2),
          substr(g.sort, 1, 4),
          substr(g.sort, 1, 6),
           substr(g.sort, 1, 8),
           g.code,
          g.name;
commit;          
 
/*在单sku sku金额*/         
insert into tmp_businvstat(sort1,sort2,sort3,sort4,gdcode,gdname,sku4,total4)   
 /*      
select 
       substr(g.sort, 1, 2),
       substr(g.sort, 1, 4),
       substr(g.sort, 1, 6),
       substr(g.sort, 1, 8),
       g.code,
       g.name,
       count(distinct b.gdgid),
       sum(b.lackqty*r.rtlprc)
  from ord o ,orddtl b, goods g,RPGGD r,warehouse w
 where b.gdgid = g.gid
    and g.code = r.inputcode
   and b.wrh =w.gid
   and o.num=b.num
   and o.cls=b.cls
   and o.stat in (100,200)
   and b.lackqty >0   --缺货数大于0
   and not exists (select 1 from businv u where u.qty > 0 and u.GDGID = b.gdgid  and u.STORE = 1000000)
 group by substr(g.sort, 1, 2),
          substr(g.sort, 1, 4),
          substr(g.sort, 1, 6), 
           substr(g.sort, 1, 8),
          g.name,
          g.code;
     */

select 
       substr(g.sort, 1, 2),
       substr(g.sort, 1, 4),
       substr(g.sort, 1, 6),
       substr(g.sort, 1, 8),
       g.code,
       g.name,
       count(distinct b.GDGID),
       sum(b.ORDQTY * r.rtlprc)
  from businv b, goods g,RPGGD r,warehouse w
 where b.GDGID = g.gid
   and g.code = r.inputcode
   and b.wrh =w.gid
   and b.STORE = 1000000
   and b.ORDQTY > 0    
 group by substr(g.sort, 1, 2),
          substr(g.sort, 1, 4),
          substr(g.sort, 1, 6), 
           substr(g.sort, 1, 8),
          g.name,
          g.code;     
     
          
commit;



insert into tmp_businvstat(sort1,sort2,sort3,sort4,gdcode,gdname,SKU,OUTMONEY)
 select AA.sort1, AA.sort2, AA.sort3, AA.sort4,AA.code,AA.name,AA.GDGID,sum(AA.TOTAL) Total   from
(SELECT substr(GOODS.sort, 1, 2) sort1,
       substr(GOODS.sort, 1, 4) sort2,
       substr(GOODS.sort, 1, 6) sort3,
       substr(GOODS.sort, 1, 8) sort4,
       GOODS.code,
       GOODS.name,
       STKOUTDTL.GDGID,
       STKOUTDTL.QTY,
       STKOUTDTL.TOTAL,
       STKOUTLOG.TIME
  FROM STKOUT     STKOUT,
       STKOUTLOG  STKOUTLOG,
       STKOUTDTL  STKOUTDTL,
       GOODS      GOODS,
       MODULESTAT MODULESTAT,
       STORE      STORE,
       sortstore,
       gdstore
 WHERE (STKOUT.NUM = STKOUTDTL.NUM)
   and (STKOUT.CLS = STKOUTDTL.CLS)
   and (STKOUT.NUM = STKOUTLOG.NUM)
   and (STKOUT.CLS = STKOUTLOG.CLS)
   and (STKOUT.STAT = MODULESTAT.NO)
   and (STKOUTDTL.GDGID = GOODS.GID)
   and (STKOUT.BILLTO = STORE.GID)
   and (STKOUTLOG.STAT = 700)
   and store.gid = sortstore.gid
   and gdstore.storegid = store.gid
   and gdstore.gdgid = GOODS.gid

---统配出
union all

SELECT substr(GOODS.sort, 1, 2),
       substr(GOODS.sort, 1, 4),
       substr(GOODS.sort, 1, 6),
       substr(GOODS.sort, 1, 8),
       GOODS.code,
       GOODS.name,
       STKOUTDTL.GDGID,
       -STKOUTDTL.QTY,
       -STKOUTDTL.TOTAL,
       STKOUTLOG.TIME
  FROM STKOUTBCK    STKOUT,
       STKOUTBCKLOG STKOUTLOG,
       STKOUTBCKDTL STKOUTDTL,
       GOODS        GOODS,
       MODULESTAT   MODULESTAT,
       STORE        STORE,
       sortstore
 WHERE (STKOUT.NUM = STKOUTDTL.NUM)
   and (STKOUT.CLS = STKOUTDTL.CLS)
   and (STKOUT.NUM = STKOUTLOG.NUM)
   and (STKOUT.CLS = STKOUTLOG.CLS)
   and (STKOUT.STAT = MODULESTAT.NO)
   and (STKOUTDTL.GDGID = GOODS.GID)
   and (STKOUT.BILLTO = STORE.GID)
   and (STKOUTLOG.STAT = 300)
   and store.gid = sortstore.gid

--统配出退
union all

SELECT substr(GOODS.sort, 1, 2),
       substr(GOODS.sort, 1, 4),
       substr(GOODS.sort, 1, 6),
       substr(GOODS.sort, 1, 8),
       GOODS.code,
       GOODS.name,
      /* STORE.NAME,*/
       diralcDTL.GDGID,
       diralcDTL.QTY,
       diralcDTL.TOTAL,
       diralcLOG.TIME
  FROM diralc     diralc,
       diralcLOG  diralcLOG,
       diralcDTL  diralcDTL,
       GOODS      GOODS,
       MODULESTAT MODULESTAT,
       STORE      STORE,
       sortstore,
       gdstore
 WHERE (diralc.NUM = diralcDTL.NUM)
   and (diralc.CLS = diralcDTL.CLS)
   and (diralc.NUM = diralcLOG.NUM)
   and (diralc.CLS = diralcLOG.CLS)
   and (diralc.STAT = MODULESTAT.NO)
   and (diralcDTL.GDGID = GOODS.GID)
   and (diralc.BILLTO = STORE.GID)
   and (diralcLOG.STAT = 700)
   and store.gid = sortstore.gid
   and gdstore.storegid = store.gid
   and gdstore.gdgid = GOODS.gid

--直配出
union all

SELECT substr(GOODS.sort, 1, 2),
       substr(GOODS.sort, 1, 4),
       substr(GOODS.sort, 1, 6),
       substr(GOODS.sort, 1, 8),
       GOODS.code,
       GOODS.name,
       diralcDTL.Gdgid,
       -diralcDTL.QTY,
       -diralcDTL.TOTAL,
       diralcLOG.TIME
  FROM diralc     diralc,
       diralcLOG  diralcLOG,
       diralcdtl  diralcDTL,
       GOODS      GOODS,
       MODULESTAT MODULESTAT,
       STORE      STORE,
       sortstore
 WHERE (diralc.NUM = diralcDTL.NUM)
   and (diralc.CLS = diralcDTL.CLS)
   and (diralc.NUM = diralcLOG.NUM)
   and (diralc.CLS = diralcLOG.CLS)
   and (diralc.STAT = MODULESTAT.NO)
   and (diralcDTL.GDGID = GOODS.GID)
   and (diralc.BILLTO = STORE.GID)
   and (diralcLOG.STAT = 300)
   and store.gid = sortstore.gid
   ) AA
   where AA.TIME>=outdate and AA.TIME<=outdate +1
   group by AA.sort1, AA.sort2, AA.sort3, AA.sort4,AA.GDGID,AA.code,AA.name;
commit;  

insert into tmp_businvstat1 
select  sort1,sort2,sort3,sort4,gdcode,gdname,sum(sku1),sum(total1),sum(sku2),sum(total2),sum(sku3),sum(total3),sum(sku4),sum(total4),outdate,VQTY,'',sum(nvl(OUTMONEY,0)),count(distinct Sku),0 
from tmp_businvstat  group by sort1,sort2,sort3,sort4,gdcode,gdname;
commit;


end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>tmp_businvstat1</TABLE>
    <ALIAS>tmp_businvstat1</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>h4v_goodssort</TABLE>
    <ALIAS>h4v_goodssort</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>GOODS</TABLE>
    <ALIAS>GOODS</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
</TABLELIST>
<JOINLIST>
  <JOINITEM>
    <LEFT>tmp_businvstat1.sort4</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>h4v_goodssort.dscode</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>tmp_businvstat1.gdcode</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>GOODS.CODE</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>GOODS.GID</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>h4v_goodssort.gid</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>h4v_goodssort.ascode</LEFT>
    <OPERATOR>in</OPERATOR>
    <RIGHT>('10','11','12','13','14','15','16','17','18','19')</RIGHT>
  </JOINITEM>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_businvstat1.sort1</COLUMN>
    <TITLE>大类代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sort1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4v_goodssort.asname</COLUMN>
    <TITLE>大类名称</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>asname</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_businvstat1.sort2</COLUMN>
    <TITLE>中类代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sort2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4v_goodssort.bsname</COLUMN>
    <TITLE>中类名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>bsname</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_businvstat1.sort3</COLUMN>
    <TITLE>小类代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sort3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4v_goodssort.csname</COLUMN>
    <TITLE>小类名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>csname</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_businvstat1.sort4</COLUMN>
    <TITLE>细类代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sort4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4v_goodssort.dsname</COLUMN>
    <TITLE>细类名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>dsname</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_businvstat1.gdcode</COLUMN>
    <TITLE>商品代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>gdcode</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_businvstat1.gdname</COLUMN>
    <TITLE>商品名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>gdname</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_businvstat1.sku1</COLUMN>
    <TITLE>充足SKU</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sku1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_businvstat1.total1/10000</COLUMN>
    <TITLE>充足金额（万）</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>total1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_businvstat1.sku2</COLUMN>
    <TITLE>缺货SKU</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sku2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_businvstat1.total2/10000</COLUMN>
    <TITLE>缺货金额（万）</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>total2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_businvstat1.sku3</COLUMN>
    <TITLE>断货SKU</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sku3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_businvstat1.total3/10000</COLUMN>
    <TITLE>断货金额(万)</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>total3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_businvstat1.sku4</COLUMN>
    <TITLE>在单SKU</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sku4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_businvstat1.total4/10000</COLUMN>
    <TITLE>在单金额（万）</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>total4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_businvstat1.VQTY</COLUMN>
    <TITLE>界定值</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>VQTY</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_businvstat1.fildate</COLUMN>
    <TITLE>出库日期</TITLE>
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
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_businvstat1.OUTMONEY/10000</COLUMN>
    <TITLE>当日出库金额(万)</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>OUTMONEY</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_businvstat1.SKU</COLUMN>
    <TITLE>当日出库SKU</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>SKU</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>case when sum(tmp_businvstat1.OUTMONEY)=0 then 0 else ( sum(tmp_businvstat1.Total1)+sum(tmp_businvstat1.Total2))/sum(tmp_businvstat1.OUTMONEY) end</COLUMN>
    <TITLE>周转天数</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>Days</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>71</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>138</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>116</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>110</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>101</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>50</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>105</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>50</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>93</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>105</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>84</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
  <GROUPITEM>
    <COLUMN>h4v_goodssort.asname</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>tmp_businvstat1.VQTY</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>500</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>1</ISQUOTED>
    <PICKNAME>
    </PICKNAME>
    <PICKVALUE>
    </PICKVALUE>
    <DEFAULTVALUE>500</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_businvstat1.fildate</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2015.09.21</RIGHTITEM>
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
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>500</SGLINEITEM>
    <SGLINEITEM>2015.09.21</SGLINEITEM>
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
<RPTTITLE>总仓库存断货情况大类查询x</RPTTITLE>
<RPTGROUPCOUNT>0</RPTGROUPCOUNT>
<RPTGROUPLIST>
</RPTGROUPLIST>
<RPTCOLUMNCOUNT>12</RPTCOLUMNCOUNT>
<RPTCOLUMNWIDTHLIST>
  <RPTCOLUMNWIDTHITEM>71</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>138</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>116</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>110</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>101</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>50</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>105</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>50</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>64</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>105</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>84</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>64</RPTCOLUMNWIDTHITEM>
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

