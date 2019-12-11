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

  Bdate     date;
  Edate     date;
  Vseason   varchar2(100);
  Vclass    varchar2(100);
  Vcode     varchar2(100);
  Vprovince varchar2(100);
begin

  Bdate :='\(1,1)';
  Edate :='\(2,1)';
  Vseason :='\(3,1)';
  Vclass  :='\(4,1)';
  Vcode   :='\(5,1)';
  Vprovince :='\(6,1)';

  /*Bdate     := date '2017-2-26';
  Edate     := date '2017-2-26';
  Vseason   := '';
  Vclass    := '';
  Vcode     := '';
  Vprovince := '浙江省';*/

  delete from tmp_test1;
  commit;
  delete from tmp_test2;
  commit;
  delete from tmp_test3;
  commit;
  --架子 368

  insert into tmp_test1
    (char1,
     char2,
     char3,
     char4,
     char5,
     char6,
     char7,
     char8,
     char9,
     char10,
     char11,
     char12,
     char13)
    select store.province, store.code, store.name, b.*
      from store
      left join (select distinct goods.c_faseason,
                                 case
                                   when trunc(GOODSOutSaleDate.Findate, 'MM') between
                                        trunc(Bdate, 'MM') and
                                        trunc(Edate, 'MM') then
                                    '是'
                                   else
                                    '否'
                                 end --当月入库产品
                                ,
                                 h4v_goodssort.ascode --品类代码
                                ,
                                 h4v_goodssort.asname --品类
                                ,
                                 h4v_goodssort.bscode --大类代码
                                ,
                                 h4v_goodssort.bsname --大类
                                ,
                                 h4v_goodssort.cscode --中类代码
                                ,
                                 h4v_goodssort.csname --中类
                                ,
                                 h4v_goodssort.dscode --小类代码
                                ,
                                 h4v_goodssort.dsname --小类
                 
                   from h4v_goodssort, GOODSOutSaleDate, goods
                  where h4v_goodssort.gid = GOODSOutSaleDate.Gid
                    and h4v_goodssort.gid = goods.gid
                    and h4v_goodssort.ascode like '1%') b
        on 1 = 1
     where store.stat = 0
          
       and (Vseason is null or Vseason = b.c_faseason)
       and (Vprovince is null or Vprovince = Store.Province)
       and (Vclass is null or Vclass=b.asname)
       and (Vcode is null or Vcode=store.code);
                              

--销量 19069
          
insert into tmp_test2
  (char2,
   char4,
   char5,
   char6,
   char7,
   char8,
   char9,
   char10,
   char11,
   char12,
   char13,
   num1,
   int1)
  select store.code,
         goods.c_faseason,
         case
           when trunc(GOODSOutSaleDate.Findate, 'MM') between
                trunc(Bdate, 'MM') and
                trunc(Edate, 'MM') then
            '是'
           else
            '否'
         end, --当月入库产品
         h4v_goodssort.ascode --品类代码
        ,
         h4v_goodssort.asname --品类
        ,
         h4v_goodssort.bscode --大类代码
        ,
         h4v_goodssort.bsname --大类
        ,
         h4v_goodssort.cscode --中类代码
        ,
         h4v_goodssort.csname --中类
        ,
         h4v_goodssort.dscode --小类代码
        ,
         h4v_goodssort.dsname --小类
        ,
         sum(case
               when sdrpts.fildate >= Bdate and sdrpts.fildate <= Edate then
                (decode(sdrpts.cls,
                        '零售',
                        1,
                        '批发',
                        1,
                        '成本差异',
                        0,
                        '成本调整',
                        0,
                        -1) * (sdrpts.amt + sdrpts.tax))
             end) weekamt,
         sum(case
               when sdrpts.fildate >= Bdate and sdrpts.fildate <= Edate then
                (decode(sdrpts.cls,
                        '零售',
                        1,
                        '批发',
                        1,
                        '成本差异',
                        0,
                        '成本调整',
                        0,
                        -1) * (sdrpts.qty))
             end) weekqty
  
    from sdrpts, h4v_goodssort, store, GOODSOutSaleDate,goods
   where sdrpts.gdgid = h4v_goodssort.gid
     and sdrpts.snd = store.gid
     and sdrpts.gdgid = GOODSOutSaleDate.gid
     and sdrpts.gdgid =goods.gid
     and (Vseason is null or Vseason = goods.c_faseason)
     and (Vprovince is null or VProvince = Store.Province)
     and (Vclass is null or h4v_goodssort.asname = Vclass)
     and (Vcode is null or store.code = Vcode)
     and sdrpts.cls in
         ('零售', '零售退', '批发', '批发退', '成本差异', '成本调整')
     and h4v_goodssort.ascode like '1%'
   group by store.code,
            h4v_goodssort.ascode --品类代码
           ,
            h4v_goodssort.asname --品类
           ,
            h4v_goodssort.bscode --大类代码
           ,
            h4v_goodssort.bsname --大类
           ,
            h4v_goodssort.cscode --中类代码
           ,
            h4v_goodssort.csname --中类
           ,
            h4v_goodssort.dscode --小类代码
           ,
            h4v_goodssort.dsname --小类
           ,
            trunc(GOODSOutSaleDate.Findate, 'MM'),goods.c_faseason;
            
         
  --汇总销售数据          
  insert into tmp_test3
    (char2,char4,char5,char6,char7,char8,char9,char10,char11,char12,char13,num1,int1)
  select char2,char4,char5,char6,char7,char8,char9,char10,char11,char12,char13,sum(num1),sum(int1)
  from tmp_test2
  group by char2,char4,char5,char6,char7,char8,char9,char10,char11,char12,char13;
  

 
  delete from tmp_test2;
  commit;

--销售数据添加到框架中

  insert into tmp_test2
 (char1, char2, char3, char4, char5, char6, char7, char8, char9,char10,char11,char12,char13,num1,int1)
 select a.char1, a.char2, a.char3, a.char4, a.char5, a.char6, a.char7, a.char8,
  a.char9,a.char10,a.char11,a.char12,a.char13,sum(b.num1),sum(b.int1)
 from tmp_test1 a left join tmp_test3 b
 on a.char2=b.char2 
 and a.char4=b.char4 
 and a.char5=b.char5 
 and a.char6=b.char6 
 and a.char8=b.char8 
 and a.char10=b.char10
 and a.char12=b.char12
 group by a.char1, a.char2, a.char3, a.char4, a.char5, a.char6, a.char7, a.char8,
 a.char9,a.char10,a.char11,a.char12,a.char13;
  

 --门店库存 19767 5422
 delete from tmp_test3;
  commit;

 insert into tmp_test3
  (char2,char4,char5,char6,char7,char8,char9,char10,char11,char12,char13,int2,num1,int1)
           select store.code,
                  goods.c_faseason,--季节
                  case
                    when trunc(GOODSOutSaleDate.Findate, 'MM') between
                         trunc(Bdate, 'MM') and
                         trunc(Edate, 'MM') then
                     '是'
                    else
                     '否'
                  end, --当月入库产品
                  h4v_goodssort.ascode --品类代码
                 ,
                  h4v_goodssort.asname --品类
                 ,
                  h4v_goodssort.bscode --大类代码
                 ,
                  h4v_goodssort.bsname --大类
                 ,
                  h4v_goodssort.cscode --中类代码
                 ,
                  h4v_goodssort.csname --中类
                 ,
                  h4v_goodssort.dscode --小类代码
                 ,
                  h4v_goodssort.dsname --小类
                 ,
                  
                  count(distinct(case
                                   when businvs.qty > 0 and businvs.store <> '1000000' then
                                    businvs.gdgid
                                 end)) kcSKU --门店在库sku数
                 ,
                  sum(case
                        when businvs.qty > 0 and businvs.store <> '1000000' then
                         (businvs.qty * goods.rtlprc)
                      end) kcAmt --门店库存金额
                 ,
                  sum(case
                        when businvs.qty > 0 and businvs.store <> '1000000' then
                         businvs.qty
                      end) kcqty --门店库存数量 
             from businvs, h4v_goodssort, store,GOODSOutSaleDate,goods
            where businvs.gdgid = h4v_goodssort.gid
              and businvs.STORE = store.gid
              and businvs.gdgid=GOODSOutSaleDate.Gid
              and businvs.gdgid=goods.gid
              and h4v_goodssort.ascode like '1%'

              and (Vseason is null or Vseason = goods.c_faseason)
              and (Vprovince is null or VProvince = Store.Province)
              and (Vclass is null or h4v_goodssort.asname = Vclass)
              and (Vcode is null or store.code = Vcode)
              
            group by store.code,
                     h4v_goodssort.ascode --品类代码
                    ,
                     h4v_goodssort.asname --品类
                    ,
                     h4v_goodssort.bscode --大类代码
                    ,
                     h4v_goodssort.bsname --大类
                    ,
                     h4v_goodssort.cscode --中类代码
                    ,
                     h4v_goodssort.csname --中类
                    ,
                     h4v_goodssort.dscode --小类代码
                    ,
                     h4v_goodssort.dsname --小类
                    ,
                     trunc(GOODSOutSaleDate.Findate, 'MM'),goods.c_faseason;
   
  --汇总门店库存数据                  
   delete from tmp_test1;
  commit;                  
   insert into tmp_test1
   (char2,char4,char5,char6,char7,char8,char9,char10,char11,char12,char13,int2,num1,int1)                  
  select char2,char4,char5,char6,char7,char8,char9,char10,char11,char12,
         char13,sum(int2),sum(num1),sum(int1)
    from tmp_test3
   group by char2,char4,char5,char6,char7,char8,char9,char10,char11,char12,char13;
   
  /* select sum(int2),sum(num1),sum(int1) from tmp_test1;*/
  
  ----门店库存数据添加到框架中
   delete from tmp_test3;
  commit;
   insert into tmp_test3
 (char1, char2, char3, char4, char5, char6, char7, char8, char9,char10,char11,char12,char13,num1,int1,int2,num2,int3)
 select a.char1, a.char2, a.char3, a.char4, a.char5, a.char6, a.char7, a.char8,
  a.char9,a.char10,a.char11,a.char12,a.char13,sum(a.num1),sum(a.int1),sum(b.int2),sum(b.num1),sum(b.int1)
 from tmp_test2 a left join tmp_test1 b
 on a.char2=b.char2 
 and a.char4=b.char4 
 and a.char5=b.char5 
 and a.char6=b.char6 
 and a.char8=b.char8 
 and a.char10=b.char10
 and a.char12=b.char12
 group by a.char1, a.char2, a.char3, a.char4, a.char5, a.char6, a.char7, a.char8,
 a.char9,a.char10,a.char11,a.char12,a.char13;
                     
                     
--总仓库存
  delete from tmp_test2;
  commit; 
  insert into tmp_test2
    (char2,char4,char5,char6,char7,char8,char9,char10,char11,char12,char13,num1,int1)
    select store.code,
           goods.c_faseason,
           case
             when trunc(GOODSOutSaleDate.Findate, 'MM') between
                  trunc(Bdate, 'MM') and
                  trunc(Edate, 'MM') then
              '是'
             else
              '否'
           end, --当月入库产品
           h4v_goodssort.ascode --品类代码
          ,
           h4v_goodssort.asname --品类
          ,
           h4v_goodssort.bscode --大类代码
          ,
           h4v_goodssort.bsname --大类
          ,
           h4v_goodssort.cscode --中类代码
          ,
           h4v_goodssort.csname --中类
          ,
           h4v_goodssort.dscode --小类代码
          ,
           h4v_goodssort.dsname --小类
          ,
           sum(case
                 when businvs.qty > 0 and businvs.store = '1000000' and
                      businvs.wrh = '1000020' then
                  (businvs.qty * goods.rtlprc)
               end) zkcAmt --总仓库存金额
          ,
           sum(case
                 when businvs.qty > 0 and businvs.store = '1000000' and
                      businvs.wrh = '1000020' then
                  businvs.qty
               end) zkcqty --总仓库存数量   
      from businvs, h4v_goodssort, store, GOODSOutSaleDate, goods
     where businvs.gdgid = h4v_goodssort.gid
       and businvs.STORE = store.gid
       and businvs.gdgid = GOODSOutSaleDate.Gid
       and businvs.gdgid = goods.gid
       and h4v_goodssort.ascode like '1%'
       and store.code = '8888'
       and (Vseason is null or Vseason = goods.c_faseason)
       and (Vclass is null or h4v_goodssort.asname = Vclass)
       
     group by store.code,
              h4v_goodssort.ascode --品类代码
             ,
              h4v_goodssort.asname --品类
             ,
              h4v_goodssort.bscode --大类代码
             ,
              h4v_goodssort.bsname --大类
             ,
              h4v_goodssort.cscode --中类代码
             ,
              h4v_goodssort.csname --中类
             ,
              h4v_goodssort.dscode --小类代码
             ,
              h4v_goodssort.dsname --小类
             ,
              trunc(GOODSOutSaleDate.Findate, 'MM'),
              goods.c_faseason;
              
         
              
   --汇总总仓库存数据               
  delete from tmp_test1;
  commit; 
  insert into tmp_test1
    (char2,char4,char5,char6,char7,char8,char9,char10,char11,char12,char13,num1,int1)             
  select char2,char4,char5,char6,char7,char8,char9,char10,char11,char12,char13,sum(num1),sum(int1)
  from tmp_test2 
  group by char2,char4,char5,char6,char7,char8,char9,char10,char11,char12,char13;           
  
  --总仓库存数据添加到框架中
 delete from tmp_test2;
  commit;    
  insert into tmp_test2
 (char1, char2, char3, char4, char5, char6, char7, char8, char9,char10,char11,char12,char13,num1,int1,int2,num2,int3,num3,int4,date1,date2)
 select a.char1, a.char2, a.char3, a.char4, a.char5, a.char6, a.char7, a.char8,a.char9,a.char10,a.char11,a.char12,a.char13,
 sum(a.num1),sum(a.int1),sum(a.int2),sum(a.num2),sum(a.int3),sum(b.num1),sum(b.int1),Bdate,Edate
 from tmp_test3 a left join tmp_test1 b
 on a.char4=b.char4 
 and a.char5=b.char5 
 and a.char6=b.char6 
 and a.char8=b.char8 
 and a.char10=b.char10
 and a.char12=b.char12
 group by a.char1, a.char2, a.char3, a.char4, a.char5, a.char6, a.char7, a.char8,
 a.char9,a.char10,a.char11,a.char12,a.char13;   
 
  
 
 -- 销量，销额汇总
   delete from tmp_test3;
  commit; 
  insert into  tmp_test3        
  (char2,--店号
   num1,--销额汇总
   int1--销量汇总
  )select char2,sum(num1),sum(int1)
  from tmp_test2
  group by char2;
  
-- 算销额，销额占比
 delete from tmp_test1;
  commit; 
  insert into  tmp_test1  
 (char1, char2, char3, char4, char5, char6, char7, char8, char9,char10,char11,char12,
 char13,num1,int1,int2,num2,int3,num3,int4,date1,date2,num4,int5)
  select  b.char1,  b.char2, b.char3, b.char4, b.char5, b.char6, b.char7, b.char8, b.char9,b.char10,b.char11,b.char12,
 b.char13,b.num1,b.int1,b.int2,b.num2,b.int3,b.num3,b.int4,b.date1,b.date2,a.num1,a.int1
  from tmp_test3 a left join tmp_test2 b
  on a.char2=b.char2;
 commit;
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
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>6</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.char1</COLUMN>
    <TITLE>省份</TITLE>
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
    <TITLE>店号</TITLE>
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
    <TITLE>店名</TITLE>
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
    <TITLE>季节</TITLE>
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
    <TITLE>是否查询月产品</TITLE>
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
    <COLUMN>tmp_test1.char7</COLUMN>
    <TITLE>品类</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char7</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.char9</COLUMN>
    <TITLE>大类</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char9</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.char11</COLUMN>
    <TITLE>中类</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.char13</COLUMN>
    <TITLE>小类</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char13</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num1</COLUMN>
    <TITLE>销额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
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
    <COLUMN>tmp_test1.int1</COLUMN>
    <TITLE>销量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int2</COLUMN>
    <TITLE>门店sku</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num2</COLUMN>
    <TITLE>门店库存金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
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
    <COLUMN>tmp_test1.int3</COLUMN>
    <TITLE>门店库存数量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num3</COLUMN>
    <TITLE>总仓库存金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
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
    <COLUMN>tmp_test1.int4</COLUMN>
    <TITLE>总仓库存数量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.date1</COLUMN>
    <TITLE>开始查询日期</TITLE>
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
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.date2</COLUMN>
    <TITLE>结束查询日期</TITLE>
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
    <COLUMN>tmp_test1.num4</COLUMN>
    <TITLE>各店销售汇总</TITLE>
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
    <COLUMN>tmp_test1.int5</COLUMN>
    <TITLE>各店销量汇总</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num1*100/tmp_test1.num4</COLUMN>
    <TITLE>销额占比</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>col1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0000</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int1*100/tmp_test1.int5</COLUMN>
    <TITLE>销量占比</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>col11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0000</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>95</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>95</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>66</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>86</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>187</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>211</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>143</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>122</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>126</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>69</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>66</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>100</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>81</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>小类</COLUMN>
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
      <RIGHTITEM>2017.03.01</RIGHTITEM>
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
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test1.date2</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2017.03.01</RIGHTITEM>
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
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test1.char4</LEFT>
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
      <PICKNAMEITEM>c_faseason</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>select distinct c_faseason  from goods </PICKVALUEITEM>
      <PICKVALUEITEM>c_faseason</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test1.char7</LEFT>
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
      <PICKNAMEITEM>asname</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>select distinct asname from h4v_goodssort
where h4v_goodssort.ascode like '1%'</PICKVALUEITEM>
      <PICKVALUEITEM>asname</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test1.char2</LEFT>
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
    <LEFT>tmp_test1.char1</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>浙江省</RIGHTITEM>
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
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>2017.03.01</SGLINEITEM>
    <SGLINEITEM>2017.03.01</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM>10010</SGLINEITEM>
    <SGLINEITEM>浙江省</SGLINEITEM>
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
<RPTLINEHEIGHT>宋体</RPTLINEHEIGHT>
<RPTPAGEHEIGHT>66</RPTPAGEHEIGHT>
<RPTPAGEWIDTH>80</RPTPAGEWIDTH>
<RPTTITLETYPE>0</RPTTITLETYPE>
<RPTCURREPORT></RPTCURREPORT>
<RPTREPORTLIST>
</RPTREPORTLIST>
</SQLREPORT>

