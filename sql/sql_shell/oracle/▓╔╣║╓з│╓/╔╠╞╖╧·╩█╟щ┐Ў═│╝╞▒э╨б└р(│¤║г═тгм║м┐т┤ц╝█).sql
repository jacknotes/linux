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
--最终版
/*20150528
1.增加包装规格
2.增加销售金额
3.增加首销首配数据整理功能
  20150605 
增加季节属性  吴伟
  20150609 
增加类别属性 品类 大类 小类1 小类2
 20170525
增加了国际‘在单量’
 20170605
 剔掉了80001的数据
 
 1、现在请将字段：“在单量”，改为只含“商品仓在单量”；“未审核订单量”改为只含 “商品仓未审核订单量”。(提出人王娟 20170613)

2、新增字段：越南仓在单量，菲律宾仓在单量，木槿家族仓在单量，木槿家族仓库存(提出人王娟 20170613)

20170628
增加库存价，各个仓位库存
*/
declare
  days  integer;
  SortA varchar2(20);

  Bfiledate  date;
  Efiledate  date;
  vendorcode varchar2(200);

  GDGID     integer;
  cls       varchar2(40);
  date1     date;
  begindate date;
  enddate   date;

  isOut1 varchar2(4);

  gid1     integer; ---商品ID
  SortAmt1 number(18, 2); ---销售总额
  AMT1     number(18, 2); ---单品销售总额
  ASORT1   varchar2(80); ---类别
  ASORT    varchar2(80); ---类别

  TMoney number(18, 2); ---统计金额

  cursor cr1 is
    select tmp_test2.int18 gid,
           A.AMT SortAmt,
           nvl(tmp_test2.num3, 0) AMT,
           A.char2 ASORT
      from (select sum(num3) AMT, char2
              from tmp_test2
             where char13 = '否'
             group by char2) A,
           tmp_test2
     where tmp_test2.char2 = A.char2
       and tmp_test2.char13 = '否'
     order by A.char2, nvl(tmp_test2.num3, 0) desc, tmp_test2.int18 desc;

begin
 /* SortA      := trim('');
  vendorcode := trim('');
  Bfiledate  := to_date('2017-6-9', 'yyyy.mm.dd');
  Efiledate  := to_date('2017-6-15', 'yyyy.mm.dd');

  isOut1 := trim('') || '%';*/
  
  SortA      := trim('\(1,1)');
  Bfiledate  := to_date('\(2,1)', 'yyyy.mm.dd');
  Efiledate  := to_date('\(3,1)', 'yyyy.mm.dd');

  isOut1 := trim('\(6,1)') || '%';

  select to_date(Efiledate) - to_date(Bfiledate) + 1 into days from dual;

  delete from tmp_test2;
  commit;

  insert into tmp_test2
    (char1, --- 品类
     char2, --- 小类2
     char3, --商品代码
     char4, --商品名称
     num1, --零售价
     int1, ---近x天销售数量
     int2, ---店铺数
     num2, --日均销
     int3, ---门店库存
     int4, ---仓库库存
     int23,---木槿家族仓库存
     int5, ---在单量（商品仓在单量）
     int19,---国际在单量--于20170525日新添加字段
     int20,--越南仓在单量
     int21,--菲律宾仓在单量
     int22,--木槿家族仓在单量
     int6, ---已配数
     int7, ---整箱数量
     char5, --供应商代码
     char6, --供应商名称
     date1, --首销时间
     date2, ---首配时间
     int8, ---统计天数
     date3, ---统计日期
     char7, --商品条码
     num3, --近x天销售额
     char8, --商品包装规格
     char9, --季节属性
     char10, --大类
     char11, --小类2
     date4, ---首次入库时间
     int9, --定货数量
     int10, --到货数量
     char12, --滞销
     char13, --淘汰
     int11, --最小起订量
     int12, --生产前置期
     num4, --标准陈列量
     char14, --下单日
     int13, --订货周期    
     char19, --新品  
     int14, ---允许配货店数
     num5, --日均销额
     int15, ---近X天销售额排名
     date5, ---最近入库日期
     int16, ---最近入库数量   
     int17, --未审核定单量  商品仓
     int18, --商品GID    
     char20, --小类1  80%标记
     CHAR21, ---商品状态
     CHAR22, ---停滞期
     char23 , ---品牌
     
     --以下是本次新增字段
     num6,--成本价
     num7,--商品仓库存
     num8,--国际仓库存    
     num9,--越南仓库存
     num10,--新店仓库存
     num11,--退货仓库库存
     num12,--清货仓库存
     num13--清货可配仓库存
     )
    select AA.s1name, --- 品类
           AA.s2name, --- 小类2
           AA.gcode, --商品代码
           AA.gname, --商品名称
           AA.RTLPRC, --零售价
           BB.qty Salqty, ---近x天销售
           CC.storeNum, ---店铺数
           
           round(BB.daysalnum, 2) des, --日均销
           
           CC.qty    storeqty, ---门店库存
           DD.qty    stoqty, ---仓库库存
           DD.qty_MF  qty_MF,---木槿家族仓库存
           DD.ORDQTY, ---在单量 商品仓在单量
           DD.ORDQTY_GJ, ---国际在单量--于20170525日新添加字段
           DD.ORDQTY_YN,----越南仓在单量
           DD.ORDQTY_FLB,----菲律宾仓在单量
           DD.ORDQTY_MF,----木槿家族仓在单量
           DD.ALCQTY, ---已配数
           EE.xqty, ---整箱数量
           
           AA.vendorcode, --供应商代码
           AA.vendorname, ---供应商名称
           GOODSOutSaleDate.Fsaledate, ---首销时间
           GOODSOutSaleDate.Foutdate, ---首配时间
           days, ---统计天数
           Bfiledate, --统计最小日期
           AA.gcode2, ---商品条码
           BB.amt, --近x天销售额
           EE.qpcstr, --商品包装规格
           AA.c_faseason, --季节属性 
           AA.s3name, --大类
           AA.s4name, --小类2
           GOODSOutSaleDate.FINDATE, ---首次入库时间
           FF.qty, --订货数量
           FF.acvqty, --到货数量      
           AA.unsalable, ---滞销  
           AA.IsOut, ---淘汰
           AA.buyminnum, --最小起订量
           AA.beforedays, --生产前置期
           AA.c_stdshow, --标准陈列量
           AA.orderweek, --下单日
           AA.orderdays, --订货周期           
           case
             when GOODSOutSaleDate.Stat = 2 then
              '是'
             else
              ''
           end NewType, ---新品
           GG.Stors, ---允许配货店数
           round(BB.daysalMoney, 2) desm, --日均销额
           BB.orderkey, ---近X天销售额排名
           KK.zjrkri, ---最近入库日期
           KK.zjrksl, ---最近入库数量
           mm.wshqty, --未审核定单量  商品仓  
           AA.gid, --商品代码       
           '', --小类1  80%标记     
           AA.gstat, --商品状态
           AA.tingzhiqi,  ---停滞期
           AA.brand,      --品牌
           --以下是本次新增字段
           AA.INVPRC,
           DD.qty_SP,
           DD.qty_GJ,
           DD.qty_YN,
           DD.qty_XD,
           DD.qty_TH,
           DD.qty_QH,
           DD.qty_QHKP
           
      from (select goods.gid,
                   goods.sort,
                   sort1.name       s1name,
                   sort2.name       s2name,
                   goods.code       gcode,
                   goods.code2      gcode2,
                   goods.name       gname,
                   goods.unsalable  unsalable,
                   goods.IsOut      IsOut,
                   rpggd.RTLPRC,
                   actinv.INVPRC,
                   vendor.code      vendorcode,
                   vendor.name      vendorname,
                   goods.c_faseason c_faseason,
                   sort3.name       s3name,
                   sort4.name       s4name,
                   goods.buyminnum,
                   goods.beforedays,
                   goods.c_stdshow,
                   vendor.orderweek,
                   vendor.orderdays,
                   goods.gstat,
                   goods.tingzhiqi,
                   goods.brand
              from goods 
                   left join  sort sort1 on substr(goods.sort, 0, 2) = sort1.code --品类
                   left join  sort sort2 on substr(goods.sort, 0, 6) = sort2.code --小类1
                   left join  sort sort3 on substr(goods.sort, 0, 4) = sort3.code --大类 
                   left join  sort sort4 on substr(goods.sort, 0, 8) = sort4.code --小类2
                   left join  rpggd  on (goods.gid = rpggd.gdgid and goods.code = rpggd.inputcode)
                   left join  vendor on goods.VDRGID = vendor.gid
                   left join  (select * from actinv where store=1000000 and wrh=1000020) actinv 
                   on goods.gid=actinv.GDGID
             where  goods.sort like '1%'
               and (SortA is null or sort1.name = SortA)
               and goods.IsOut like isOut1
               ) AA
    
      left join
    
     (
      
      select rownum orderkey, GDGID, qty, amt, daysalnum, daysalMoney
        from (select salNum.GDGID,
                      sum(salNum.qty) qty,
                      sum(salNum.amt) amt,
                      sum(case
                            when Efiledate <= salNum.mindate then
                             0
                            else
                             salNum.qty / (Efiledate - salNum.mindate + 1)
                          end) daysalnum,
                      sum(case
                            when Efiledate <= salNum.mindate then
                             0
                            else
                             salNum.amt / (Efiledate - salNum.mindate + 1)
                          end) daysalMoney
                 from (select
                       
                        SDRPTS.Snd,
                        SDRPTS.GDGID,
                        sum(decode(SDRPTS.Cls, '零售', 1, '零售退', -1, 0) *
                            SDRPTS.QTY) qty,
                        sum(decode(SDRPTS.Cls, '零售', 1, '零售退', -1, 0) *
                            (SDRPTS.amt + SDRPTS.tax)) amt,
                        case
                          when min(GOODSOUTSALEDATESTORE.Indate) < Bfiledate then
                           Bfiledate
                          else
                           trunc(min(GOODSOUTSALEDATESTORE.Indate))
                        end mindate
                       
                         from SDRPTS
                       
                         left join GOODSOUTSALEDATESTORE
                           on SDRPTS.GDGID = GOODSOUTSALEDATESTORE.Gid
                          and SDRPTS.Snd = GOODSOUTSALEDATESTORE.Store
                       
                        where SDRPTS.FILDATE >= Bfiledate
                          and SDRPTS.FILDATE <= Efiledate
                          and SDRPTS.Cls in ('零售', '零售退')
                          and SDRPTS.Snd not in (select gid from store where code in ('40127','40144','40223','80001'))
                        group by SDRPTS.Snd, SDRPTS.GDGID) salNum
                group by GDGID
                order by amt desc)
      
      ) BB
    
        on AA.gid = BB.gdgid
    
      left join
    
     (select BUSINVS.GDGID,
             count(BUSINVS.STORE) storeNum,
             sum(BUSINVS.qty) qty ------铺店数,门店库存
      
        from BUSINVS, store, GOODSOUTSALEDATESTORE
      
       where BUSINVS.STORE != 1000000
         and BUSINVS.store = store.gid
         and GOODSOUTSALEDATESTORE.Store = store.gid
         and GOODSOUTSALEDATESTORE.Gid = BUSINVS.Gdgid
         and BUSINVS.qty > 0
         and store.stat = 0
         and store.gid not in (select gid from store where code in ('40127','40144','40223','80001'))
       group by GDGID) CC
    
        on AA.gid = CC.GDGID
    
      left join
    
     (select GDGID,
             sum(case
                   when WRH in (1000020, 1000140) then qty else 0 end) qty,--商品仓和补货仓
             sum(case
                   when WRH =1000020 then qty else 0 end) qty_SP,--商品仓库存     
             sum(case
                   when WRH=1000234 then qty else 0 end) qty_GJ,--国际仓库存
             sum(case
                   when WRH=1000194 then qty else 0 end) qty_YN,--越南仓库存       
             sum(case
                   when WRH=1000214 then qty else 0 end) qty_XD,--新店仓库存
             sum(case
                   when WRH=1000021 then qty else 0 end) qty_TH,--退货仓库库存
             sum(case
                   when WRH=1000254 then qty else 0 end) qty_QH,--清货仓库存
             sum(case
                   when WRH=1000294 then qty else 0 end) qty_QHKP,--清货可配仓库存                      
                           
             sum(case when WRH=1000314 then qty else 0 end) qty_MF,  --木槿家族商品仓 
             
             sum(case when wrh=1000020 then ORDQTY else 0 end ) ORDQTY, ---商品仓在单量
             
            sum(case
                when WRH =1000234 then ORDQTY else 0 end) ORDQTY_GJ  , ---国际在单量--于20170525日新添加字段
            sum(case
                when WRH =1000194 then ORDQTY else 0 end) ORDQTY_YN  , ---越南仓在单量-于20170616日新添加字段
            sum(case
                when WRH =1000174 then ORDQTY else 0 end) ORDQTY_FLB  , ---菲律宾仓在单量--于20170616日新添加字段
            sum(case
                when WRH =1000314 then ORDQTY else 0 end) ORDQTY_MF  , ---木槿家族仓在单量--于20170616日新添加字段

             sum(ALCQTY) ALCQTY ------仓库已配数
        from BUSINVS
      
       where STORE = 1000000
       group by GDGID) DD
    
        on AA.gid = DD.GDGID
    
      left join
    
     (select gid,
             max（qpc）xqty, ---整箱数量
             max(qpcstr) qpcstr --商品包装规格 大箱 20150528  新增  王宏宝 
      
        from GDQPC
       where ISPU = 2
       group by gid) EE
    
        on AA.gid = EE.gid
    
      left join ( --采购计划单  订货数量qty   到货数量 acvqty   20150702  吴伟  计划在单量=订货数量-到货数量
                 select orddtl.gdgid,
                         sum(orddtl.qty) qty,
                         sum(orddtl.acvqty) acvqty
                   from ord, orddtl
                  where ord.num = orddtl.num
                    and ord.cls = orddtl.cls
                    and trunc(ord.fildate) >= Bfiledate
                    and trunc(ord.fildate) <= Efiledate
                    and ord.stat = 100
                    and ord.purordtype = 1
                  group by orddtl.gdgid) FF
        on AA.gid = FF.gdgid
    
      left join GOODSOutSaleDate
    
        on AA.gid = GOODSOutSaleDate.gid
    
      left join
    
     (select count(storegid) Stors, gdgid
        from V_GDSTOREBUSGATE, store
       where V_GDSTOREBUSGATE.ALWSTKOUT = 1
         and V_GDSTOREBUSGATE.storegid != 1000000
         and V_GDSTOREBUSGATE.storegid = store.gid
         and store.stat = 0
       group by gdgid) GG
    
        on AA.gid = GG.GDGID
    
      left join (select A.gdgid,
                        to_date('20' || substr(A.num, 5, 6), 'yyyy-mm-dd') zjrkri,
                        B.qty zjrksl
                   from (select gdgid, max(Num) Num
                           from stkindtl
                          where num like '8888%'
                          group by gdgid) A,
                        stkindtl B
                  where A.gdgid = B.Gdgid
                    and A.Num = B.Num) kk
        on AA.gid = kk.GDGID
    
      left join (select dtl.gdgid,
                        goods.code,
                        goods.name,
                        sum(case when dtl.wrh=1000020 then dtl.qty else 0 end)  wshqty,
                        sum(dtl.total)  wshtotal
                   from ord mst,
                        orddtl dtl,
                        (select cls, num, trunc(time) time
                           from ordlog
                          where stat in ('0')) og,
                        goods
                  where mst.num = dtl.num
                    and mst.cls = dtl.cls
                    and mst.cls = og.cls
                    and mst.num = og.num
                       /*and trunc(mst.fildate) between Bfiledate and Efiledate*/
                    and mst.stat in (0)
                    and dtl.gdgid = goods.gid
                    and mst.CLS = '自营进'
                       /*and mst.num='88881603090004'*/
                    and mst.PURORDTYPE <> 1
                    group by dtl.gdgid,
                        goods.code,
                        goods.name) mm
        on AA.gid = mm.gdgid
    
     where (AA.vendorcode = vendorcode or vendorcode is null);

  commit;

  ----更新新品状态
  update tmp_test2
     set char19 = ''
   where char13 = '是'
     and char19 = '是'
     and nvl(int3, 0) + nvl(int4, 0) + nvl(int5, 0) + nvl(int17, 0) = 0
     and date1 is null;

  commit;

  gid1     := 0;
  SortAmt1 := 0;
  AMT1     := 0;
  ASORT1   := 'ok';

  TMoney := 0;

  ASORT := 'ok';

  OPEN cr1;
  LOOP
    FETCH cr1
      INTO gid1, SortAmt1, AMT1, ASORT1;
    EXIT WHEN cr1%NOTFOUND;
  
    if (ASORT != ASORT1) then
      ASORT  := ASORT1;
      Tmoney := 0;
    end if;
  
    Tmoney := Tmoney + AMT1;
  
    if  SortAmt1 != 0 and Tmoney / SortAmt1 < 0.8  then
      update tmp_test2 set char20 = '是' where int18 = gid1;
      commit;
    end if;
  
  END LOOP;
  CLOSE cr1;

  commit;


  delete from tmp_test3;
  commit;

  insert into tmp_test3
    (int8, ---统计天数
       char1, --- 品类
       char2, --- 小类2
       char10, --大类
       char11, --小类2
  /*     num6,--成本价
       num1, --零售价
       int18, --商品GID */ 
       num6,--日均销
       date3, ---统计日期
       char9, --季节属性
       char13, --淘汰   
       char19, --新品
       CHAR21, ---商品状态
       CHAR22, ---停滞期
       char23 , ---品牌 
     int1, ---近x天销售数量
     int5, ---在单量（商品仓在单量）
     int19,---国际在单量--于20170525日新添加字段
     int20,--越南仓在单量
     int21,--菲律宾仓在单量
     int22,--木槿家族仓在单量
     int6, ---已配数
     num3, --近x天销售额
     num4, --近x天销售成本额
     
     num25,--单周均销额
     num2,   --单店周均销量
     int17, --未审核定单量  商品仓 
     int3, ---门店库存
     num7,---门店库存额
     num8,---门店库存成本额  
     int23,---木槿家族仓库存
     num9,---木槿家族仓库存额
     num10,---木槿家族仓库存成本额
     int9, --商品仓库存
     num11,---商品仓库存额
     num12,---商品仓库存成本额
     int10, --国际仓库存  
     num13,---国际仓库存额
     num14,---国际仓库存成本额  
     int11, --越南仓库存
     num15,---越南仓库存额
     num16,---越南仓库存成本额
     int12, --新店仓库存
     num17,---新店仓库存额
     num18,---新店仓库存成本额
     int13, --退货仓库库存
     num19,---退货仓库库存额
     num20,---退货仓库库存成本额
     int14, --清货仓库存
     num21,---清货仓库存额
     num22,---清货仓库存额成本额
     int15, --清货可配仓库存
     num23,---清货可配仓库存额
     num24---清货可配仓库存成本额
     )
   select int8, ---统计天数
       char1, --- 品类
       char2, --- 小类2
       char10, --大类
       char11, --小类2
/*       num6,--成本价
       num1, --零售价
       int18, --商品GID */
       sum(num2),--日均销
       date3, ---统计日期
       char9, --季节属性
       char13, --淘汰   
       char19, --新品
       CHAR21, ---商品状态
       CHAR22, ---停滞期
       char23 , ---品牌 
     sum(int1), ---近x天销售数量
     sum(int5), ---在单量（商品仓在单量）
     sum(int19),---国际在单量--于20170525日新添加字段
     sum(int20),--越南仓在单量
     sum(int21),--菲律宾仓在单量
     sum(int22),--木槿家族仓在单量
     sum(int6), ---已配数
     sum(num3), --近x天销售额
     sum(int1*num6),--近x天销售成本额
     case when tmp_test2.int2=0 then 0 else sum( round(tmp_test2.num5*7/tmp_test2.int2,2)) end,--单周均销额
     case when tmp_test2.int2=0 then 0 else sum( round(tmp_test2.num2*7/tmp_test2.int2,2)) end,--单店周均销量
     sum(int17), --未审核定单量  商品仓  
     sum(int3), ---门店库存
     sum(int3*num1),--
     sum(int3*num6),--
     sum(int23),---木槿家族仓库存
     sum(int23*num1),--
     sum(int23*num6),--
     sum(num7),--商品仓库存
     sum(num7*num1),--
     sum(num7*num6),--
     sum(num8),--国际仓库存 
     sum(num8*num1),--
     sum(num8*num6),--   
     sum(num9),--越南仓库存
     sum(num9*num1),--
     sum(num9*num6),--
     sum(num10),--新店仓库存
     sum(num10*num1),--
     sum(num10*num6),--
     sum(num11),--退货仓库库存
     sum(num11*num1),--
     sum(num11*num6),--
     sum(num12),--清货仓库存
     sum(num12*num1),--
     sum(num12*num6),--
     sum(num13),--清货可配仓库存
     sum(num13*num1),--
     sum(num13*num6)--
from tmp_test2
group by int8, ---统计天数
       char1, --- 品类
       char2, --- 小类2
       char10, --大类
       char11, --小类2
       int2,
       date3, ---统计日期
       char9, --季节属性
       char13, --淘汰   
       char19, --新品
       CHAR21, ---商品状态
       CHAR22, ---停滞期
       char23  ---品牌 
     ;

 delete from tmp_test1;
  commit;

  insert into tmp_test1
    (int8, ---统计天数
       char1, --- 品类
       char2, --- 小类2
       char10, --大类
       char11, --小类2
       num6,--日均销
       date3, ---统计日期
       char9, --季节属性
       char13, --淘汰   
       char19, --新品
       CHAR21, ---商品状态
       CHAR22, ---停滞期
       char23 , ---品牌 
     int1, ---近x天销售数量
     int5, ---在单量（商品仓在单量）
     int19,---国际在单量--于20170525日新添加字段
     int20,--越南仓在单量
     int21,--菲律宾仓在单量
     int22,--木槿家族仓在单量
     int6, ---已配数
     num3, --近x天销售额
     num4, --近x天销售成本额
     
     num25,--单周均销额
     num2,   --单店周均销量
     int17, --未审核定单量  商品仓 
     int3, ---门店库存
     num7,---门店库存额
     num8,---门店库存成本额  
     int23,---木槿家族仓库存
     num9,---木槿家族仓库存额
     num10,---木槿家族仓库存成本额
     int9, --商品仓库存
     num11,---商品仓库存额
     num12,---商品仓库存成本额
     int10, --国际仓库存  
     num13,---国际仓库存额
     num14,---国际仓库存成本额  
     int11, --越南仓库存
     num15,---越南仓库存额
     num16,---越南仓库存成本额
     int12, --新店仓库存
     num17,---新店仓库存额
     num18,---新店仓库存成本额
     int13, --退货仓库库存
     num19,---退货仓库库存额
     num20,---退货仓库库存成本额
     int14, --清货仓库存
     num21,---清货仓库存额
     num22,---清货仓库存额成本额
     int15, --清货可配仓库存
     num23,---清货可配仓库存额
     num24---清货可配仓库存成本额
     )
     select int8, ---统计天数
       char1, --- 品类
       char2, --- 小类2
       char10, --大类
       char11, --小类2
       sum(num6),--日均销
       date3, ---统计日期
       char9, --季节属性
       char13, --淘汰   
       char19, --新品
       CHAR21, ---商品状态
       CHAR22, ---停滞期
       char23 , ---品牌 
     sum(int1), ---近x天销售数量
     sum(int5), ---在单量（商品仓在单量）
     sum(int19),---国际在单量--于20170525日新添加字段
     sum(int20),--越南仓在单量
     sum(int21),--菲律宾仓在单量
     sum(int22),--木槿家族仓在单量
     sum(int6), ---已配数
     sum(num3), --近x天销售额
     sum(num4), --近x天销售成本额
     
     sum(num25),--单周均销额
     sum(num2),   --单店周均销量
     sum(int17), --未审核定单量  商品仓 
     sum(int3), ---门店库存
     sum(num7),---门店库存额
     sum(num8),---门店库存成本额  
     sum(int23),---木槿家族仓库存
     sum(num9),---木槿家族仓库存额
     sum(num10),---木槿家族仓库存成本额
     sum(int9), --商品仓库存
     sum(num11),---商品仓库存额
     sum(num12),---商品仓库存成本额
     sum(int10), --国际仓库存  
     sum(num13),---国际仓库存额
     sum(num14),---国际仓库存成本额  
     sum(int11), --越南仓库存
     sum(num15),---越南仓库存额
     sum(num16),---越南仓库存成本额
     sum(int12), --新店仓库存
     sum(num17),---新店仓库存额
     sum(num18),---新店仓库存成本额
     sum(int13), --退货仓库库存
     sum(num19),---退货仓库库存额
     sum(num20),---退货仓库库存成本额
     sum(int14), --清货仓库存
     sum(num21),---清货仓库存额
     sum(num22),---清货仓库存额成本额
     sum(int15), --清货可配仓库存
     sum(num23),---清货可配仓库存额
     sum(num24)---清货可配仓库存成本额
     from tmp_test3
     group by int8, ---统计天数
       char1, --- 品类
       char2, --- 小类2
       char10, --大类
       char11, --小类2
       date3, ---统计日期
       char9, --季节属性
       char13, --淘汰   
       char19, --新品
       CHAR21, ---商品状态
       CHAR22, ---停滞期
       char23  ---品牌
       ;


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
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int8</COLUMN>
    <TITLE>统计天数</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int8</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.char1</COLUMN>
    <TITLE>品类</TITLE>
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
    <COLUMN>tmp_test1.char10</COLUMN>
    <TITLE>大类</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char10</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.char2</COLUMN>
    <TITLE>中类</TITLE>
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
    <COLUMN>tmp_test1.char11</COLUMN>
    <TITLE>小类</TITLE>
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
    <COLUMN>case when 
tmp_test1.char23='01' then '木槿生活'
     when 
tmp_test1.char23='02' then 'MUMUSO FAMILY'
     else '未知' end</COLUMN>
    <TITLE>品牌</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char23</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.char19</COLUMN>
    <TITLE>新品</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char19</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>case
         when tmp_test1.char22 = '是' then
          '停滞期'
         when tmp_test1.char13 = '是' and
              nvl(tmp_test1.int3,0) + nvl(tmp_test1.int4,0) <= 200 then
          '废除期'
         when tmp_test1.char13 = '是' and
              nvl(tmp_test1.int4,0) + nvl(tmp_test1.int5,0) <= 300 then
          '淘汰期'
         when tmp_test1.char13 = '是' and
              nvl(tmp_test1.int4,0) + nvl(tmp_test1.int5,0) > 300 then
          '预淘汰期'
         when tmp_test1.char13 = '否' and tmp_test1.date2 is null then
          '建档期'
         when tmp_test1.char13 = '否' and
              trunc(sysdate) - tmp_test1.date2 <= 45 then
          '新品期'
         when tmp_test1.char13 = '否' and
              trunc(sysdate) - tmp_test1.date2 > 45 then
          '正常期'
       
       end</COLUMN>
    <TITLE>生命周期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char22</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.char13</COLUMN>
    <TITLE>淘汰</TITLE>
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
    <COLUMN>tmp_test1.int1</COLUMN>
    <TITLE>近x天销售数量</TITLE>
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
    <COLUMN>tmp_test1.num3</COLUMN>
    <TITLE>近x天销售额</TITLE>
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
    <COLUMN>tmp_test1.num4</COLUMN>
    <TITLE>近x天销售成本额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num31</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num25
</COLUMN>
    <TITLE>单店周均销额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num2</COLUMN>
    <TITLE>单店周均销量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int3</COLUMN>
    <TITLE>门店库存</TITLE>
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
    <COLUMN>tmp_test1.num7</COLUMN>
    <TITLE>门店库存额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int32</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num8</COLUMN>
    <TITLE>门店库存成本额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int31</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int23</COLUMN>
    <TITLE>木槿家族仓库存</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int23</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num9</COLUMN>
    <TITLE>木槿家族仓库存金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int231</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num10</COLUMN>
    <TITLE>木槿家族仓库存成本额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int232</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int9</COLUMN>
    <TITLE>商品仓库存</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num7</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num11</COLUMN>
    <TITLE>商品仓库存金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num71</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num12</COLUMN>
    <TITLE>商品仓库存成本额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num72</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int10</COLUMN>
    <TITLE>国际仓库存</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num8</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num13</COLUMN>
    <TITLE>国际仓库存金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num81</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num14</COLUMN>
    <TITLE>国际仓库存成本额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num82</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int11</COLUMN>
    <TITLE>越南仓库存</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num9</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num15</COLUMN>
    <TITLE>越南仓库存金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num91</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num16</COLUMN>
    <TITLE>越南仓库存成本额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num92</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int12</COLUMN>
    <TITLE>新店仓库存</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num10</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num17</COLUMN>
    <TITLE>新店仓库存金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num101</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num18</COLUMN>
    <TITLE>新店仓库存成本额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num102</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int13</COLUMN>
    <TITLE>退货仓库库存</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num19</COLUMN>
    <TITLE>退货仓库存金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num111</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num20</COLUMN>
    <TITLE>退货仓库存成本额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num112</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int14</COLUMN>
    <TITLE>清货仓库存</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num12</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num21</COLUMN>
    <TITLE>清货仓库存金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num121</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num22</COLUMN>
    <TITLE>清货仓库存成本额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num122</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int15</COLUMN>
    <TITLE>清货可配仓库存</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num13</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num23</COLUMN>
    <TITLE>清货可配仓库存金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num131</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.num24</COLUMN>
    <TITLE>清货可配仓库存成本额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num132</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int6</COLUMN>
    <TITLE>已配数</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int6</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>case when tmp_test1.num6=0 then 0 else (tmp_test1.int23+tmp_test1.int3+
tmp_test1.int9+tmp_test1.int10+tmp_test1.int11+tmp_test1.int12+tmp_test1.int13+tmp_test1.int14+tmp_test1.int15)/tmp_test1.num6 end</COLUMN>
    <TITLE>库存周转天数</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>zzts</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int5</COLUMN>
    <TITLE>商品仓在单量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int51</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int19</COLUMN>
    <TITLE>国际在单量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int19</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int20</COLUMN>
    <TITLE>越南仓在单量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int20</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int21</COLUMN>
    <TITLE>菲律宾仓在单量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int211</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.int22</COLUMN>
    <TITLE>木槿家族仓在单量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int22</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test1.int17</COLUMN>
    <TITLE>商品仓未审核订单量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int171</COLUMNNAME>
    <CFILTER>TRUE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.char9</COLUMN>
    <TITLE>季节属性</TITLE>
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
    <COLUMN>tmp_test1.date3</COLUMN>
    <TITLE>统计日期</TITLE>
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
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test1.char21</COLUMN>
    <TITLE>商品状态</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char21</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>86</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>86</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>98</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>76</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>32</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>74</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>70</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>126</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>82</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>112</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>97</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>114</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>108</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>116</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>128</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>116</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>128</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>110</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>146</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>131</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
  <GROUPITEM>
    <COLUMN>tmp_test1.int8</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.char1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.char10</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.char2</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.char11</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>case when 
tmp_test1.char23='01' then '木槿生活'
     when 
tmp_test1.char23='02' then 'MUMUSO FAMILY'
     else '未知' end</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.char19</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>case
         when tmp_test1.char22 = '是' then
          '停滞期'
         when tmp_test1.char13 = '是' and
              nvl(tmp_test1.int3,0) + nvl(tmp_test1.int4,0) <= 200 then
          '废除期'
         when tmp_test1.char13 = '是' and
              nvl(tmp_test1.int4,0) + nvl(tmp_test1.int5,0) <= 300 then
          '淘汰期'
         when tmp_test1.char13 = '是' and
              nvl(tmp_test1.int4,0) + nvl(tmp_test1.int5,0) > 300 then
          '预淘汰期'
         when tmp_test1.char13 = '否' and tmp_test1.date2 is null then
          '建档期'
         when tmp_test1.char13 = '否' and
              trunc(sysdate) - tmp_test1.date2 <= 45 then
          '新品期'
         when tmp_test1.char13 = '否' and
              trunc(sysdate) - tmp_test1.date2 > 45 then
          '正常期'
       
       end</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.char13</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num3</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num4</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num25
</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num2</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int3</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num7</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num8</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int23</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num9</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num10</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int9</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num11</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num12</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int10</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num13</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num14</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int11</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num15</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num16</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int12</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num17</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num18</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int13</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num19</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num20</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int14</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num21</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num22</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int15</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num23</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.num24</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int6</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>case when tmp_test1.num6=0 then 0 else (tmp_test1.int23+tmp_test1.int3+
tmp_test1.int9+tmp_test1.int10+tmp_test1.int11+tmp_test1.int12+tmp_test1.int13+tmp_test1.int14+tmp_test1.int15)/tmp_test1.num6 end</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int5</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int19</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int20</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int21</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int22</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.char9</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.char21</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>清货可配仓库存</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>tmp_test1.char1</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>儿童用品</RIGHTITEM>
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
      <PICKVALUEITEM>select distinct asname from h4v_goodssort</PICKVALUEITEM>
      <PICKVALUEITEM>asname</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test1.date3</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2017.06.09</RIGHTITEM>
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
    <LEFT>tmp_test1.date3</LEFT>
    <OPERATOR><=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2017.06.15</RIGHTITEM>
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
    <LEFT>tmp_test1.char13</LEFT>
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
    </PICKNAME>
    <PICKVALUE>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test1.char11</LEFT>
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
    </PICKNAME>
    <PICKVALUE>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test1.char9</LEFT>
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
    </PICKNAME>
    <PICKVALUE>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>121</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>112</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>105</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>儿童用品</SGLINEITEM>
    <SGLINEITEM>2017.06.09</SGLINEITEM>
    <SGLINEITEM>2017.06.15</SGLINEITEM>
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
  <DXLOADMETHOD>TRUE</DXLOADMETHOD>
  <DXSHOWGROUP>FALSE</DXSHOWGROUP>
  <DXSHOWFOOTER>TRUE</DXSHOWFOOTER>
  <DXSHOWSUMMARY>FALSE</DXSHOWSUMMARY>
  <DXSHOWPREVIEW>FALSE</DXSHOWPREVIEW>
  <DXSHOWFILTER>TRUE</DXSHOWFILTER>
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
<RPTTITLE>商品销售情况统计表小类(除海外，含库存价)</RPTTITLE>
<RPTGROUPCOUNT>0</RPTGROUPCOUNT>
<RPTGROUPLIST>
</RPTGROUPLIST>
<RPTCOLUMNCOUNT>51</RPTCOLUMNCOUNT>
<RPTCOLUMNWIDTHLIST>
  <RPTCOLUMNWIDTHITEM>56</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>56</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>86</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>86</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>98</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>32</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>32</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>74</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>44</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>126</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>82</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>112</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>97</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>114</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>108</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>92</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>116</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>128</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>68</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>92</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>104</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>68</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>92</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>104</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>68</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>92</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>104</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>68</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>92</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>104</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>80</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>92</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>104</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>68</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>92</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>104</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>92</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>116</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>128</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>110</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>146</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>80</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>68</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>80</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>92</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>104</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>131</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>56</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>68</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>68</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>80</RPTCOLUMNWIDTHITEM>
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

