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
    vdatetype varchar2(20);
    vbgndate  date ;
    venddate  date ;
begin
  
  vdatetype := '\(3,1)';
  vbgndate := to_date('\(1,1)','yyyy.mm.dd');
  venddate := to_date('\(2,1)','yyyy.mm.dd');

  delete from H4RTMP_storebill ; commit ;
  delete from H4RTMP_storebill_total ; commit;
   --配货单
 if vdatetype = '填单日期' then --填单日期
   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate , ALCIVCREG ,
     alctotal , alcamt , alctax)
   select sender , client , sender , num , cls ,stat , ocrdate ,fildate , paydate , ALCIVCREG ,
    total as alctotal , (total - tax) as alcamt , tax as alctax
       from stkout 
    where  stat in (700,300)
    and fildate < venddate 
    and fildate >=  vbgndate
    
      ;
    --配货差异
   insert into H4RTMP_storebill 
   (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate , ALCIVCREG ,
     alcdiftotal , alcdifamt , alcdiftax)
   select sender , store , sender , num , cls , stat , createtime , lstupdtime , lstupdtime , ALCIVCREG,
     total as alcdiftotal , (total- tax) as alcdifamt , tax as alcdiftax
    from alcdiff mst  
     where Stat in (400,300)
       and mst.lstupdtime < venddate 
       and mst.lstupdtime >= vbgndate
    ;
   
   --统配出退
   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     alcbcktotal , alcbckamt , alcbcktax)
   select receiver , client , receiver , num , cls ,stat , ocrdate ,fildate , paydate , ALCIVCREG ,
    total as alcbcktotal , (total - tax) as alcbckamt , tax as alcbcktax
       from stkoutbck
    where STAT IN (1000,300)
    and fildate < venddate 
    and fildate >=  vbgndate;

   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     diralctotal , diralcamt , diralctax , diralcbcktotal , diralcbckamt , diralcbcktax)
   select sender , receiver , vendor , num , cls ,stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    decode( cls , '直配出' , alctotal , 0)  as diralctotal , decode( cls , '直配出' , alctotal - alctax , 0) as diralcamt ,  decode( cls , '直配出' , alctax , 0) as diralctax , 
    decode( cls , '直配出退' , alctotal , 0)  as diralctotal , decode( cls , '直配出退' , alctotal - alctax , 0) as diralcamt ,  decode( cls , '直配出退' , alctax , 0) as diralctax 
       from diralc
    where STAT IN (700,1000, 300)
    and fildate < venddate 
    and fildate >=  vbgndate ;
    
  elsif vdatetype = '发生日期' then --发生日期
  
   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     alctotal , alcamt , alctax)
   select sender , client , sender , num , cls ,stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    total as alctotal , (total - tax) as alcamt , tax as alctax
       from stkout 
    where Stat in (700,300)
    and ocrdate < venddate 
    and ocrdate >=  vbgndate
      ;
    --配货差异
   insert into H4RTMP_storebill 
   (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     alcdiftotal , alcdifamt , alcdiftax)
   select sender , store , sender , num , cls , stat , createtime , lstupdtime , lstupdtime ,ALCIVCREG ,
     total as alcdiftotal , (total- tax) as alcdifamt , tax as alcdiftax
    from alcdiff mst  
     where Stat in (400,300)
       and mst.createtime < venddate 
       and mst.createtime >= vbgndate
    ;
   
   --统配出退
   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     alcbcktotal , alcbckamt , alcbcktax)
   select receiver , client , receiver , num , cls ,stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    total as alcbcktotal , (total - tax) as alcbckamt , tax as alcbcktax
       from stkoutbck
    where STAT IN (1000,300)
    and ocrdate < venddate 
    and ocrdate >=  vbgndate ;

   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     diralctotal , diralcamt , diralctax , diralcbcktotal , diralcbckamt , diralcbcktax)
   select sender , receiver , vendor , num , cls ,stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    decode( cls , '直配出' , alctotal , 0)  as diralctotal , decode( cls , '直配出' , alctotal - alctax , 0) as diralcamt ,  decode( cls , '直配出' , alctax , 0) as diralctax , 
    decode( cls , '直配出退' , alctotal , 0)  as diralctotal , decode( cls , '直配出退' , alctotal - alctax , 0) as diralcamt , 
     decode( cls , '直配出退' , alctax , 0) as diralctax  
       from diralc
    where STAT IN (700,1000,300)
    and ocrdate < venddate 
    and ocrdate >=  vbgndate ;    
    ------
  else  --记账日期 和日报一致
    ------
   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     alctotal , alcamt , alctax)
   select mst.sender , mst.client , mst.sender , mst.num , mst.cls , mst.stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    total as alctotal , (total - tax) as alcamt , tax as alctax
       from stkout mst , stkoutlog log
     where mst.CLS = log.CLS  
         AND mst.NUM = log.NUM
         AND log.CLS = '统配出'
         AND log.STAT IN (700,720,740,320,340)
         AND log.TIME < venddate
         AND log.TIME >= vbgndate
      ;
    --配货差异
   insert into H4RTMP_storebill 
   (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     alcdiftotal , alcdifamt , alcdiftax)
   select sender , store , sender , mst.num , mst.cls , mst.stat , mst.createtime , lstupdtime , lstupdtime ,ALCIVCREG ,
     total as alcdiftotal , (total- tax) as alcdifamt , tax as alcdiftax
    from alcdiff mst , alcdifflog log  
     where  log.cls = mst.cls
        and log.num = mst.num
        and Log.Stat in (400,420,440,320,340)
        AND Log.time <  venddate
        and Log.time >= vbgndate
    ;
   
   --统配出退
   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     alcbcktotal , alcbckamt , alcbcktax)
   select receiver , client , receiver , mst.num , mst.cls ,mst.stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    total as alcbcktotal , (total - tax) as alcbckamt , tax as alcbcktax
       from stkoutbck mst , stkoutbcklog log
    where Mst.CLS = log.CLS
           AND Mst.NUM = log.NUM
           AND Mst.CLS = '统配出退'
           AND log.STAT IN (1000,1020,1040,320,340)
           AND log.TIME < venddate
           AND log.TIME >= vbgndate ;

   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     diralctotal , diralcamt , diralctax , diralcbcktotal , diralcbckamt , diralcbcktax)
   select sender , receiver , vendor , m.num , m.cls ,m.stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    decode( m.cls , '直配出' , alctotal , 0)  as diralctotal , decode( m.cls , '直配出' , alctotal - alctax , 0) as diralcamt ,  decode( m.cls , '直配出' , alctax , 0) as diralctax , 
    decode( m.cls , '直配出退' , alctotal , 0)  as diralctotal , decode( m.cls , '直配出退' , alctotal - alctax , 0) as diralcamt , 
     decode( m.cls , '直配出退' , alctax , 0) as diralctax  
       from diralc m , diralclog mm
    where  M.CLS = MM.CLS
         AND M.NUM = MM.NUM
         AND MM.CLS = '直配出'
         AND MM.STAT IN (1000, 1020, 1040, 320 ,340)
       AND MM.TIME < venddate
       AND MM.TIME >= vbgndate ;
       
   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     diralctotal , diralcamt , diralctax , diralcbcktotal , diralcbckamt , diralcbcktax)
   select sender , receiver , vendor , m.num , m.cls ,m.stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    decode( m.cls , '直配出' , alctotal , 0)  as diralctotal , decode( m.cls , '直配出' , alctotal - alctax , 0) as diralcamt ,  decode( m.cls , '直配出' , alctax , 0) as diralctax , 
    decode( m.cls , '直配出退' , alctotal , 0)  as diralctotal , decode( m.cls , '直配出退' , alctotal - alctax , 0) as diralcamt , 
     decode( m.cls , '直配出退' , alctax , 0) as diralctax  
       from diralc m , diralclog mm
    where  M.CLS = MM.CLS
         AND M.NUM = MM.NUM
         AND MM.CLS = '直配出退'
         AND MM.STAT IN (700,720,740,320,340)
         AND MM.TIME < venddate
         AND MM.TIME >= vbgndate ;       
       
  end if;


   --合计：
   insert into H4RTMP_storebill_total
    ( store , bgndate , enddate ,fildate , datetype , stat,ALCIVCREG ,
       alctotal , alcamt , alctax , 
       alcbcktotal , alcbckamt , alcbcktax ,
       alcdiftotal , alcdifamt , alcdiftax ,
       diralctotal , diralcamt , diralctax , 
       diralcbcktotal , diralcbckamt , diralcbcktax)
    select store  , vbgndate , venddate - 1, vbgndate , vdatetype  , stat,nvl(ALCIVCREG,0) ,
     sum(nvl(alctotal,0)) as alctotal , sum(nvl(alcamt,0)) as alcamt , sum(nvl(alctax,0)) as alctax ,
     sum(nvl(alcbcktotal,0)) as alcbcktotal , sum(nvl(alcbckamt,0)) as alcbckamt , sum(nvl(alcbcktax,0)) as alcbcktax ,
     sum(nvl(alcdiftotal,0)) as alcdiftotal , sum(nvl(alcdifamt,0)) as alcdifamt , sum(nvl(alcdiftax,0)) as alcdiftax ,
     sum(nvl(diralctotal,0)) as diralctotal ,sum(nvl(diralcamt,0)) as diralcamt , sum(nvl(diralctax,0)) as diralctax ,
     sum(nvl(diralcbcktotal,0)) as diralcbcktotal , sum(nvl(diralcbckamt,0)) as diralcbckamt , sum(nvl(diralcbcktax,0)) as diralcbcktax
    from 
     H4RTMP_storebill
    group by store , stat,nvl(ALCIVCREG,0) ;
       
   commit;
   
end;
/*
--当家人报表 created by zxf 2010.06.09
drop table H4RTMP_storebill cascade constraints;
create global temporary table H4RTMP_storebill
(
  datetype varchar2(20) , --日期类型
  bgndate  date ,--起始日期
  enddate  date , --截止日期
  snd      int ,
  store    int ,--门店
  vendor   int ,--供应商
  num      varchar2(24),--单号
  cls      varchar2(24),--单据类型
  stat     int ,  
  ocrdate  date , --发生日期
  fildate  date , --填单日期
  paydate  date , --付款日期
  ALCIVCREG int , --开票标识
  alctotal number(24,4), --含税统配出货金额
  alcamt   number(24,4),--去税统配出货金额
  alctax   number(24,4),--统配出货税额
  alcdiftotal number(24,4), --含税统配出货金额
  alcdifamt   number(24,4),--去税统配出货金额
  alcdiftax   number(24,4),--统配出货税额
  alcbcktotal number(24,4), --含税统配出货退货金额
  alcbckamt   number(24,4),--去税统配出货退货金额
  alcbcktax   number(24,4),--统配出货退货税额
  diralctotal number(24,4),--含税直配/直送出货金额
  diralcamt   number(24,4),--去税直配/直送出货金额
  diralctax   number(24,4),--直配/直送出货税额
  diralcbcktotal number(24,4), -- 含税直配/直送出货退货金额
  diralcbckamt   number(24,4), --去税直配/直送出货退货金额
  diralcbcktax   number(24,4) --直配/直送出货退货税额
)
on commit preserve rows;
exec hdcreatesynonym('H4RTMP_storebill');
exec granttoqryrole('H4RTMP_storebill');

drop table H4RTMP_storebill_total cascade constraints;
create global temporary table H4RTMP_storebill_total
(
  datetype varchar2(20) , --日期类型
  bgndate  date ,--起始日期
  enddate  date , --截止日期
  snd      int ,
  store    int ,--门店
  vendor   int ,--供应商
  num      varchar2(24),--单号
  cls      varchar2(24),--单据类型
  stat     int ,  
  ocrdate  date , --发生日期
  fildate  date , --填单日期
  paydate  date , --付款日期
  ALCIVCREG int , --开票标识
  alctotal number(24,4), --含税统配出货金额
  alcamt   number(24,4),--去税统配出货金额
  alctax   number(24,4),--统配出货税额
  alcdiftotal number(24,4), --含税统配出货金额
  alcdifamt   number(24,4),--去税统配出货金额
  alcdiftax   number(24,4),--统配出货税额
  alcbcktotal number(24,4), --含税统配出货退货金额
  alcbckamt   number(24,4),--去税统配出货退货金额
  alcbcktax   number(24,4),--统配出货退货税额
  diralctotal number(24,4),--含税直配/直送出货金额
  diralcamt   number(24,4),--去税直配/直送出货金额
  diralctax   number(24,4),--直配/直送出货税额
  diralcbcktotal number(24,4), -- 含税直配/直送出货退货金额
  diralcbckamt   number(24,4), --去税直配/直送出货退货金额
  diralcbcktax   number(24,4) --直配/直送出货退货税额
)
on commit preserve rows;
exec hdcreatesynonym('H4RTMP_storebill_total');
exec granttoqryrole('H4RTMP_storebill_total');

*/
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>H4RTMP_storebill_total</TABLE>
    <ALIAS>H4RTMP_storebill_total</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>STORE</TABLE>
    <ALIAS>STORE</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>AREA</TABLE>
    <ALIAS>AREA</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>STORE</TABLE>
    <ALIAS>STORE__1</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
</TABLELIST>
<JOINLIST>
  <JOINITEM>
    <LEFT>H4RTMP_storebill_total.store</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>STORE.GID</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>STORE.AREA</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>AREA.CODE</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>STORE__1.GID</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>STORE.BILLTO</RIGHT>
  </JOINITEM>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>AREA.CODE</COLUMN>
    <TITLE>区域代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>CODE1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>AREA.NAME</COLUMN>
    <TITLE>区域名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>NAME1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>STORE__1.CODE</COLUMN>
    <TITLE>结算门店代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>CODE11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>STORE__1.NAME</COLUMN>
    <TITLE>结算门店名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>NAME11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>(case when 
                  (DECODE(BITAND(STORE.PROPERTY, 4), 4, 1, 0)
       		+ DECODE(BITAND(STORE.PROPERTY,  64),  64, 1, 0)
       		+ DECODE(BITAND(STORE.PROPERTY, 256), 256, 1, 0)) = 0 then '直营' 
                  else '加盟' end) 
</COLUMN>
    <TITLE>门店类型</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>storetype</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>STORE.CODE</COLUMN>
    <TITLE>门店代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
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
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>NAME</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alctotal</COLUMN>
    <TITLE>统配出货额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alctotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcamt</COLUMN>
    <TITLE>去税统配出货额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcamt</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alctax</COLUMN>
    <TITLE>统配出货税额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alctax</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcdiftotal</COLUMN>
    <TITLE>配货差异额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcdiftotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcdifamt</COLUMN>
    <TITLE>去税配货差异额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcdifamt</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcdiftax</COLUMN>
    <TITLE>配货差异税额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcdiftax</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcbcktotal</COLUMN>
    <TITLE>统配出退额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcbcktotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcbckamt</COLUMN>
    <TITLE>去税统配出退额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcbckamt</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcbcktax</COLUMN>
    <TITLE>统配出退税额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcbcktax</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alctotal-H4RTMP_storebill_total.alcbcktotal+H4RTMP_storebill_total.alcdiftotal</COLUMN>
    <TITLE>净统配出货额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcbcktotal1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711680</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcamt-H4RTMP_storebill_total.alcbckamt+H4RTMP_storebill_total.alcdifamt</COLUMN>
    <TITLE>净去税统配出货额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcbckamt1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711680</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alctax-H4RTMP_storebill_total.alcbcktax+H4RTMP_storebill_total.alcdiftax</COLUMN>
    <TITLE>净统配出税额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcbcktax1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711680</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralctotal</COLUMN>
    <TITLE>直配出货额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralctotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralcamt</COLUMN>
    <TITLE>去税直配出货额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralcamt</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralctax</COLUMN>
    <TITLE>直配出货税额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralctax</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralcbcktotal</COLUMN>
    <TITLE>直配出货退货额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralcbcktotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralcbckamt</COLUMN>
    <TITLE>去税直配出货退货额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralcbckamt</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralcbcktax</COLUMN>
    <TITLE>直配出货退货税额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralcbcktax</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralctotal-H4RTMP_storebill_total.diralcbcktotal</COLUMN>
    <TITLE>净直配出货额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralctotal1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711680</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralcamt-H4RTMP_storebill_total.diralcbckamt</COLUMN>
    <TITLE>净去税直配出货额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralcamt1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711680</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralctax-H4RTMP_storebill_total.diralcbcktax</COLUMN>
    <TITLE>净直配出货税额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralctax1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711680</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.datetype</COLUMN>
    <TITLE>日期类型</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>datetype</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.bgndate</COLUMN>
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
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.bgndate</COLUMN>
    <TITLE>起始日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>bgndate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.enddate</COLUMN>
    <TITLE>截止日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>enddate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>124</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>54</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>304</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>91</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>66</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>78</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>78</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>119</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>102</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>78</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>66</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>78</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>114</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>102</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>78</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>102</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
  <GROUPITEM>
    <COLUMN>AREA.CODE</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>AREA.NAME</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>H4RTMP_storebill_total.bgndate</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>H4RTMP_storebill_total.enddate</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>净统配出货额</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>H4RTMP_storebill_total.bgndate</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM></RIGHTITEM>
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
    <LEFT>H4RTMP_storebill_total.bgndate</LEFT>
    <OPERATOR><</OPERATOR>
    <RIGHT>
      <RIGHTITEM></RIGHTITEM>
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
    <LEFT>H4RTMP_storebill_total.datetype</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>记账日期</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
      <PICKNAMEITEM>填单日期</PICKNAMEITEM>
      <PICKNAMEITEM>发生日期</PICKNAMEITEM>
      <PICKNAMEITEM>记账日期</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>填单日期</PICKVALUEITEM>
      <PICKVALUEITEM>发生日期</PICKVALUEITEM>
      <PICKVALUEITEM>记账日期</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE>记账日期</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>(case when 
                  (DECODE(BITAND(STORE.PROPERTY, 4), 4, 1, 0)
       		+ DECODE(BITAND(STORE.PROPERTY,  64),  64, 1, 0)
       		+ DECODE(BITAND(STORE.PROPERTY, 256), 256, 1, 0)) = 0 then '直营' 
                  else '加盟' end) 
</LEFT>
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
      <PICKNAMEITEM>全部</PICKNAMEITEM>
      <PICKNAMEITEM>直营</PICKNAMEITEM>
      <PICKNAMEITEM>加盟</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM></PICKVALUEITEM>
      <PICKVALUEITEM>直营</PICKVALUEITEM>
      <PICKVALUEITEM>加盟</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE>全部</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>AREA.CODE</LEFT>
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
  <CRITERIAITEM>
    <LEFT>AREA.NAME</LEFT>
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
  <CRITERIAITEM>
    <LEFT>STORE.NAME</LEFT>
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
    <LEFT>STORE__1.CODE</LEFT>
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
  <CRITERIAITEM>
    <LEFT>STORE__1.NAME</LEFT>
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
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>112</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>112</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>112</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM>记账日期</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
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
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>no</SGLINEITEM>
    <SGLINEITEM>no</SGLINEITEM>
    <SGLINEITEM>no</SGLINEITEM>
  </LINE>
</SG>
<CHECKLIST>
  <CAPTION>
    <CAPTIONITEM>已收/已发货</CAPTIONITEM>
    <CAPTIONITEM>已完成/未开票</CAPTIONITEM>
    <CAPTIONITEM>已开票</CAPTIONITEM>
  </CAPTION>
  <EXPRESSION>
    <EXPRESSIONITEM>H4RTMP_storebill_total.stat in (700,1000,400)</EXPRESSIONITEM>
    <EXPRESSIONITEM>H4RTMP_storebill_total.stat in (300) and H4RTMP_storebill_total.ALCIVCREG = 0</EXPRESSIONITEM>
    <EXPRESSIONITEM>H4RTMP_storebill_total.ALCIVCREG = 1 and H4RTMP_storebill_total.stat in (300)</EXPRESSIONITEM>
  </EXPRESSION>
  <CHECKED>
    <CHECKEDITEM>no</CHECKEDITEM>
    <CHECKEDITEM>no</CHECKEDITEM>
    <CHECKEDITEM>no</CHECKEDITEM>
  </CHECKED>
  <ANDOR> or </ANDOR>
</CHECKLIST>
<UNIONLIST>
</UNIONLIST>
<NCRITERIAS>
  <NUMOFNEXTQRY>1</NUMOFNEXTQRY>
  <NCRITERIALIST>
    <NEXTQUERY>门店入库业务(按门店)汇总.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>日期大于等于</LEFT>
      <RIGHT>日期大于等于</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>日期小于</LEFT>
      <RIGHT>日期小于</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>日期类型等于</LEFT>
      <RIGHT>日期类型等于</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>门店类型等于</LEFT>
      <RIGHT>门店类型等于</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>区域代码在之中</LEFT>
      <RIGHT>区域代码</RIGHT>
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
  <DXCOLORODDROW>16775398</DXCOLORODDROW>
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

