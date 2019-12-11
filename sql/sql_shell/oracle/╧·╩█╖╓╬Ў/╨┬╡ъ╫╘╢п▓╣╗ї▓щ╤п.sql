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

  adate date;
  bdate date;

  flag      integer;
  begindate date; ---统计销售排名 开始时间
  enddate   date; ---统计销售排名 结束时间

  Safedays1 integer; ---安全库存天数
  /* declare*/
  gid1     integer; ---商品ID
  SortAmt1 number(18, 2); ---销售总额
  AMT1     number(18, 2); ---单品销售总额
  ASORT1   varchar2(80); ---类别
  ASORT    varchar2(80); ---类别

  TMoney number(18, 2); ---统计金额

  storeCode varchar2(10);
  cursor cr1 is
    select gid, SortAmt, AMT, ASORT
      from t_SysStorePeiHuoNew
     group by gid, SortAmt, AMT, ASORT
     order by Asort, AMT desc;

begin

  storeCode := trim('\(1,1)');

  select to_char(sysdate, 'dd') into flag from dual;
  if (flag <= 15) then
    begindate := add_months(to_date(to_char(sysdate, 'yyyy-mm') || '-16',
                                    'yyyy-mm-dd'),
                            -1);
    enddate   := to_date(to_char(sysdate, 'yyyy-mm') || '-01', 'yyyy-mm-dd') - 1;
  else
    begindate := to_date(to_char(sysdate, 'yyyy-mm') || '-01', 'yyyy-mm-dd');
    enddate   := to_date(to_char(sysdate - 1, 'yyyy-mm') || '-15',
                         'yyyy-mm-dd');
  end if;

  adate     := to_date('\(2,1)', 'yyyy-mm-dd'); --trunc(sysdate - 15);
  bdate     := to_date('\(3,1)', 'yyyy-mm-dd'); --trunc(sysdate - 1);
  Safedays1 := trim('\(4,1)');

  delete t_SysStorePeiHuoNew;
  commit;

  ---------下面 为强制配发商品信息 ----
  insert into t_SysStorePeiHuoNew
    (char1, ----品类
     char2, ----大类
     char3, ----小类1
     char4, ----小类2
     num1, ---零售价
     char5, ---季节
     char6, ---商品代码
     char7, ---商品名称
     date1, ---首配审核时间
     date2, ---首批发货时间
     date3, ---首批到店时间
     date4, ---首批销售时间
     char8, ----店铺代码
     char9, -------店铺名称
     int1, -----在店库存量
     num2, -----在店库存金额
     int2, ----销售数量
     num3, ----实际销售金额
     int3, ---已审核未配发量
     num4, ----已审核未配发金额
     num5, ---售馨率
     num6, ----可周转天数
     date5, ---门店记账日期
     int4, ---销售天数
     int5, ---运输天数
     num7, ----中包装箱规
     num8, ----整箱箱规
     int6, --- 总仓库存
     int7, ---安全库存天数
     char10, ---ABC
     int10, ---下单周期
     int11, ---运输周期
     -- int13,  ---安全库存天数
     char13, --sort
     char14, ---区域代码
     char15, ---区域
     char16, ---省份
     char17, --- 城市
     char18, --- 货道
     char19, --配货状态
     char20, ---店铺配货日
     char21, ---店铺销售级别
     int12, ---销售排名
     StoreID, ---店铺ID
     Gid, ----商品ID
     qzph, ---强制配货
     SortPercent, ---商品在品类中的销售占比
     code2, ---商品条码
     SortAmt, ---15天品类销售总额
     Amt, ---15天单品销售总额
     ASORT, ---大品类编码
     IsOut, ---淘汰
     UnSalable, ---滞销
     StoreScale, ---门店类型
     jyQty ---建议配货量
     )
  
    SELECT /*+ rule */
    
     SORT.NAME NAME, ----品类
     SORT__1.NAME NAME1, ----大类
     SORT__2.NAME NAME11, ----小类1
     SORT__3.NAME NAME111, ----小类2
     RPGGD.RTLPRC, ---零售价
     GOODS.C_FASEASON C_FASEASON, ---季节
     GOODS.CODE CODE, ---商品代码
     GOODS.NAME NAME1111, ---商品名称
     GOODSOUTSALEDATESTORE.FILLDATE FILLDATE, ---首配审核时间
     GOODSOUTSALEDATESTORE.OUTDATE OUTDATE, ---首批发货时间
     GOODSOUTSALEDATESTORE.INDATE INDATE, ---首批到店时间
     GOODSOUTSALEDATESTORE.SALEDATE SALEDATE, ---首批销售时间
     STORE.CODE CODE1, ---店铺代码
     STORE.NAME NAME11111, ---店铺名称
     SUM(BUSINV.QTY) QTY, ---在店库存量
     
     0 TOTAL, ----在店库存金额
     SUM(nvl(SDRPTS.QTY, 0)) QTY1, ---销售数量
     SUM(nvl(SDRPTS.AMT, 0)) AMT, ---实际销售金额
     SUM(nvl(noru.qty, 0)) INT3, ---已审核未配发量
     SUM(nvl(noru.qty * RPGGD.RTLPRC, 0)) NUM1, ---已审核未配发金额
     round(case
             when (SUM(nvl(BUSINV.QTY, 0)) + SUM(nvl(SDRPTS.QTY, 0)) +
                  SUM(nvl(noru.qty, 0))) = 0 then
              0
             else
              SUM(nvl(SDRPTS.QTY, 0)) /
              (SUM(nvl(BUSINV.QTY, 0)) + SUM(nvl(SDRPTS.QTY, 0)) +
               SUM(nvl(noru.qty, 0)))
           end,
           2) 售馨率, -----售馨率
     round(case
             when SUM(nvl(SDRPTS.QTY, 0)) = 0 then
              1000000
             else
              (SUM(nvl(BUSINV.QTY, 0)) + SUM(nvl(noru.qty, 0))) * (case
                when trunc(nvl(GOODSOUTSALEDATESTORE.SALEDATE,
                               to_date('2014-01-01', 'yyyy-mm-dd'))) < adate then
                 bdate - adate + 1
                else
                 bdate - trunc(nvl(GOODSOUTSALEDATESTORE.SALEDATE,
                                   to_date('2014-01-01', 'yyyy-mm-dd'))) + 1
              end) / SUM(nvl(SDRPTS.QTY, 0))
           end,
           0) 可周转天数, ------可周转天数
     adate, ---查询开始时间
     
     case
       when trunc(nvl(GOODSOUTSALEDATESTORE.SALEDATE,
                      to_date('2014-01-01', 'yyyy-mm-dd'))) < adate then
        bdate - adate + 1
       else
        bdate - trunc(nvl(GOODSOUTSALEDATESTORE.SALEDATE,
                          to_date('2014-01-01', 'yyyy-mm-dd'))) + 1
     end saldays, ---销售天数
     nvl(STORE.receiverdays, 0) receiverdays, --运输天数
     max(GDQPC.QPC) QPC, ---中包装箱规
     max(GDQPC2.QPC) QPC2, ---整箱箱规
     max(BUSINVZ.QTY) QTYZ, -- 总仓库存
     Safedays1 Safedays, ---安全库存天数
     case max(GOODSOUTSALEDATESTORE.Stat)
       when 0 then
        '正常'
       when 1 then
        '滞销'
       when 2 then
        '新品'
     end ABC,
     max(STORE.Downdays) Downdays, ---下单周期默认4天
     max(STORE.RECEIVERDAYS), --- 运输周期
     -- 7,   ---安全库存天数
     max(GOODS.SORT), ----类sort
     max(AREA.Code), ----区域代码
     max(AREA.Name), ----区域名称
     max(STORE.province), ---省份
     max(STORE.city), --- 城市
     substr(max(GOODS.Slot), 0, 3), --- 货道
     case
       when max(V_GDSTOREBUSGATE.ALWSTKOUT) = 1 then
        '正常'
       else
        '禁止'
     end, --配货状态
     max(STORE.phweek) phweek, ---店铺配货日
     max(STORE.storelevel) storelevel, ---店铺销售级别
     max(gdOrd.orderkey) orderkey, ---销售排名
     max(STORE.GID) storeID, -----店铺ID
     max(GOODS.GID) gid, -----商品ID
     '', ---强制配货
     max(round(gdOrd.Amt * 100 / SortAmt.AMT, 4)) SortPercent, ---商品在品类中的销售占比
     max(GOODS.Code2) Code2, ---商品条码
     max(nvl(SortAmt.AMT, 0)), ---15天大类销售总额
     max(nvl(gdOrd.Amt, 0)), --- 15天单品销售总额
     max(substr(GOODS.SORT, 0, 2)), ----大类sort
     max(GOODS.IsOut), ---淘汰
     max(GOODS.UnSalable), ---滞销
     max(STORE.STORESCALE), ---门店类型
     case
       when nvl(decode(max(STORE.storelevel),
                       'A',
                       max(GOODS.A),
                       'B',
                       max(GOODS.B),
                       'C',
                       max(GOODS.C),
                       'D',
                       max(GOODS.D),
                       'N',
                       max(GOODS.Xin),
                       0),
                0) = 0 then
        nvl(decode(max(STORE.STORESCALE),
                   '超大型店',
                   max(GOODS.Chaoda),
                   '大型店',
                   max(GOODS.Daxing),
                   '中型店',
                   max(GOODS.Zhongxing),
                   '小型店',
                   max(GOODS.Xiaoxing),
                   max(GOODS.Zhengchang)),
            0)
       else
        nvl(decode(max(STORE.storelevel),
                   'A',
                   max(GOODS.A),
                   'B',
                   max(GOODS.B),
                   'C',
                   max(GOODS.C),
                   'D',
                   max(GOODS.D),
                   'N',
                   max(GOODS.Xin),
                   0),
            0)
     end
      FROM GOODSOUTSALEDATESTORE GOODSOUTSALEDATESTORE
    
      full join BUSINV BUSINV
        on GOODSOUTSALEDATESTORE.GID = BUSINV.GDGID
       and GOODSOUTSALEDATESTORE.STORE = BUSINV.STORE
    
      left join STORE STORE
        on nvl(BUSINV.Store, GOODSOUTSALEDATESTORE.Store) = STORE.GID
      left join AREA
        on STORE.AREA = AREA.Code
      left join GOODS GOODS
        on nvl(BUSINV.GDGID, GOODSOUTSALEDATESTORE.GID) = GOODS.Gid
      left join SORT SORT
        on (substr(GOODS.SORT, 0, 2) = SORT.CODE)
    
      left join SORT SORT__1
        on (substr(GOODS.SORT, 0, 4) = SORT__1.CODE)
      left join SORT SORT__2
        on (substr(GOODS.SORT, 0, 6) = SORT__2.CODE)
      left join SORT SORT__3
        on (substr(GOODS.SORT, 0, 8) = SORT__3.CODE)
      left join (select sum(decode(SDRPTS.Cls, '零售', 1, '零售退', -1, 0) * QTY) qty,
                        sum(decode(SDRPTS.Cls, '零售', 1, '零售退', -1, 0) *
                            (AMT + tax)) AMT,
                        SDRPTS.SND,
                        SDRPTS.GDGID
                   from SDRPTS
                  where SDRPTS.FILDATE >= adate
                    and SDRPTS.FILDATE <= bdate
                  group by SDRPTS.SND, SDRPTS.GDGID) SDRPTS
        on nvl(BUSINV.Store, GOODSOUTSALEDATESTORE.Store) = SDRPTS.SND
       and nvl(BUSINV.GDGID, GOODSOUTSALEDATESTORE.GID) = SDRPTS.GDGID
    
      left join (select STKOUT.CLIENT storeid,
                        STKOUTDTL.GDGID,
                        sum(STKOUTDTL.QTY) qty,
                        sum(STKOUTDTL.TOTAL) TOTAL
                   from STKOUT, STKOUTDTL, store
                  where STKOUt.Num = STKOUTDTL.Num
                    and STKOUt.cls = STKOUTDTL.cls
                    and STKOUT.CLIENT = store.gid
                       --   and (vstorecode is null or store.code = vstorecode)
                    and STKOUT.cls = '统配出'
                    and STKOUT.STAT = 100
                  group by STKOUT.CLIENT, STKOUTDTL.GDGID) noru
        on nvl(BUSINV.Store, GOODSOUTSALEDATESTORE.Store) = noru.storeid
       and nvl(BUSINV.GDGID, GOODSOUTSALEDATESTORE.GID) = noru.GDGID
      left join RPGGD RPGGD
        on (GOODS.GID = RPGGD.GDGID)
       and (GOODS.CODE = RPGGD.INPUTCODE)
      left join GDQPC
        on GDQPC.GID = GOODS.GID
       and GDQPC.Isdu = 2
      left join GDQPC GDQPC2
        on GDQPC2.GID = GOODS.GID
       and GDQPC2.Ispu = 2
      left join (select sum(qty) qty, GDGID
                   from BUSINV
                  where STORE = 1000000
                    and Wrh = 1000020
                  group by GDGID) BUSINVZ
        on GOODS.GID = BUSINVZ.GDGID
      left join V_GDSTOREBUSGATE
        on STORE.gid = V_GDSTOREBUSGATE.STOREGID
       and GOODS.gid = V_GDSTOREBUSGATE.GDGID
    
      left join (select rownum orderkey, Gdgid, AMT
                   from (select Gdgid,
                                sum(decode(SDRPTS.Cls,
                                           '零售',
                                           1,
                                           '零售退',
                                           -1,
                                           0) * (AMT + tax)) AMT
                           from SDRPTS
                          where fildate between begindate and enddate
                          group by Gdgid
                          order by AMT desc)) gdOrd
        on GOODS.gid = gdOrd.Gdgid
    
      left join (select substr(goods.sort, 0, 2) codeA,
                        sum(decode(SDRPTS.Cls, '零售', 1, '零售退', -1, 0) *
                            (AMT + tax)) AMT
                   from sdrpts, goods
                  where sdrpts.Gdgid = goods.gid
                    and goods.sort like '1%'
                    and sdrpts.fildate between begindate and enddate
                  group by substr(goods.sort, 0, 2)) SortAmt
        on substr(GOODS.sort, 0, 2) = SortAmt.codeA
    
     WHERE GOODS.Sort like '1%'
       and V_GDSTOREBUSGATE.ALWSTKOUT = 1
       and store.code = storeCode
     GROUP BY SORT.NAME, ----品类
              SORT__1.NAME, ----大类
              SORT__2.NAME, ----小类1
              SORT__3.NAME, ----小类2
              RPGGD.RTLPRC, ---零售价
              GOODS.C_FASEASON, ---季节
              GOODS.CODE, ---商品代码
              GOODS.NAME, ---商品名称
              GOODSOUTSALEDATESTORE.FILLDATE, ---首配审核时间
              GOODSOUTSALEDATESTORE.OUTDATE, ---首批发货时间
              GOODSOUTSALEDATESTORE.INDATE, ---首批到店时间
              GOODSOUTSALEDATESTORE.SALEDATE, ---首批销售时间
              STORE.CODE, ---店铺代码
              STORE.NAME, ---店铺名称;
              STORE.receiverdays; --店铺到货天数
  commit;

  update t_SysStorePeiHuoNew
     set num10 = nvl(case
                       when int4 = 0 then
                        0
                       else
                        int2 / int4
                     end,
                     0); ---日均销
  commit;

  update t_SysStorePeiHuoNew
     set num9 = case
                  when t_SysStorePeiHuoNew.char19 = '禁止' then
                   0
                  when t_SysStorePeiHuoNew.int1 <= 0 then
                   case
                     when t_SysStorePeiHuoNew.num7 - t_SysStorePeiHuoNew.int3 < 0 then
                      0
                     else
                      t_SysStorePeiHuoNew.num7 - t_SysStorePeiHuoNew.int3
                   end
                  when t_SysStorePeiHuoNew.int4 < 5 and num5 < 0.4 then
                   0
                  when t_SysStorePeiHuoNew.char1 in ('美容清洁', '食品') and
                       nvl(t_SysStorePeiHuoNew.int1, 0) < 5 and
                       nvl(t_SysStorePeiHuoNew.int2, 0) <= 0 then
                   case
                     when t_SysStorePeiHuoNew.num7 - t_SysStorePeiHuoNew.int3 < 0 then
                      0
                     else
                      t_SysStorePeiHuoNew.num7 - t_SysStorePeiHuoNew.int3
                   end
                  when t_SysStorePeiHuoNew.char1 = '时尚饰品' and
                       nvl(t_SysStorePeiHuoNew.int1, 0) < 3 and
                       nvl(t_SysStorePeiHuoNew.int2, 0) <= 0 then
                   case
                     when t_SysStorePeiHuoNew.num7 - t_SysStorePeiHuoNew.int3 < 0 then
                      0
                     else
                      t_SysStorePeiHuoNew.num7 - t_SysStorePeiHuoNew.int3
                   end
                  else
                   round(((t_SysStorePeiHuoNew.int7 +
                         t_SysStorePeiHuoNew.int10 +
                         t_SysStorePeiHuoNew.int11) *
                         t_SysStorePeiHuoNew.num10 -
                         t_SysStorePeiHuoNew.int1 - t_SysStorePeiHuoNew.int3) /
                         t_SysStorePeiHuoNew.num7) * t_SysStorePeiHuoNew.num7
                end; -------补货量
  commit;

  ---------下面 为强制配发商品信息 ----
  insert into t_SysStorePeiHuoNew
    (char1, ----品类
     char2, ----大类
     char3, ----小类1
     char4, ----小类2
     num1, ---零售价
     char5, ---季节
     char6, ---商品代码
     char7, ---商品名称
     date1, ---首配审核时间
     date2, ---首批发货时间
     date3, ---首批到店时间
     date4, ---首批销售时间
     char8, ----店铺代码
     char9, -------店铺名称
     int1, -----在店库存量
     num2, -----在店库存金额
     int2, ----销售数量
     num3, ----实际销售金额
     int3, ---已审核未配发量
     num4, ----已审核未配发金额
     num5, ---售馨率
     num6, ----可周转天数
     date5, ---门店记账日期
     int4, ---销售天数
     int5, ---运输天数
     num7, ----中包装箱规
     num8, ----整箱箱规
     int6, --- 总仓库存
     int7, ---安全库存天数
     char10, ---ABC
     int10, ---下单周期
     int11, ---运输周期
     -- int13,  ---安全库存天数
     char13, --sort
     char14, ---区域代码
     char15, ---区域
     char16, ---省份
     char17, --- 城市
     char18, --- 货道
     char19, --配货状态
     char20, ---店铺配货日
     char21, ---店铺销售级别
     int12, ---销售排名
     StoreID, ---店铺ID
     Gid, ----商品ID
     num9, ---补货量
     qzph, ---强制配货
     SortPercent, ---商品在品类中的销售占比
     Code2, ---商品条码
     SortAmt, ---15天品类销售总额
     Amt, ---15天单品销售总额
     ASORT, ---大类编码
     IsOut, ---淘汰
     UnSalable, ---滞销
     StoreScale, ---门店类型
     jyQty ---建议配货量
     )
  
    select max(sort.name), ---品类
           max(sort1.name), ----大类
           max(sort2.name), ----小类1
           max(sort3.name), ----小类2
           max(RPGGD.RTLPRC), ---零售价
           max(goods.C_FASEASON) C_FASEASON, ---季节
           max(goods.code), ---商品代码
           max(goods.name), ---商品名称
           
           max(stoG.FILLDATE) FILLDATE, ---首配审核时间
           max(stoG.OUTDATE) OUTDATE, ---首批发货时间
           max(stoG.INDATE) INDATE, ---首批到店时间
           max(stoG.SALEDATE) SALEDATE, ---首批销售时间
           max(A.code), ----店铺代码
           max(A.name), ----店铺名称
           0, ---在店库存量
           0, ---在店库存金额
           0, ----销售数量
           0, ----实际销售金额
           0, ---已审核未配发量
           0, ----已审核未配发金额
           0, ---售馨率
           0, ----可周转天数
           adate, ---门店记账日期
           0, ---销售天数
           nvl(max(A.receiverdays), 0) receiverdays, --运输天数
           
           max(GDQPC.QPC) QPC, ---中包装箱规
           max(GDQPC2.QPC) QPC2, ---整箱箱规
           max(BUSINVZ.QTY) QTYZ, -- 总仓库存
           Safedays1 Safedays, ---安全库存天数
           '', --ABC
           max(A.Downdays) Downdays, ---下单周期默认4天
           max(A.RECEIVERDAYS), --- 运输周期
           max(GOODS.SORT), ----类sort
           max(AREA.Code), ----区域代码
           max(AREA.Name), ----区域名称
           max(A.province), ---省份
           max(A.city), --- 城市
           substr(max(GOODS.Slot), 0, 3), --- 货道
           '正常', --配货状态
           max(A.phweek) phweek, ---店铺配货日
           max(A.storelevel) storelevel, ---店铺销售级别
           max(gdOrd.orderkey) orderkey, ---销售排名
           
           A.storeid storeID, -----店铺ID
           A.gdgid gid, -----商品ID
           case
             when max(BUSINVZ.QTY) > 0 then
              max(GDQPC.QPC)
             else
              0
           end, ---补货量
           case
             when max(BUSINVZ.QTY) > 0 then
              '是'
             else
              ''
           end, ---强制配货
           max(round(gdOrd.Amt * 100 / SortAmt.AMT, 4)) SortPercent, ---商品在品类中的销售占比
           max(GOODS.Code2) Code2, ---商品条码
           max(nvl(SortAmt.AMT, 0)), ---15天大类销售总额
           max(nvl(gdOrd.Amt, 0)), --- 15天单品销售总额
           max(substr(GOODS.SORT, 0, 2)), ----大类sort
           max(GOODS.IsOut), ---淘汰
           max(GOODS.UnSalable), ---滞销
           max(A.STORESCALE), ---门店类型
           case
             when nvl(decode(max(A.storelevel),
                             'A',
                             max(GOODS.A),
                             'B',
                             max(GOODS.B),
                             'C',
                             max(GOODS.C),
                             'D',
                             max(GOODS.D),
                             'N',
                             max(GOODS.Xin),
                             0),
                      0) = 0 then
              nvl(decode(max(A.STORESCALE),
                         '超大型店',
                         max(GOODS.Chaoda),
                         '大型店',
                         max(GOODS.Daxing),
                         '中型店',
                         max(GOODS.Zhongxing),
                         '小型店',
                         max(GOODS.Xiaoxing),
                         max(GOODS.Zhengchang)),
                  0)
             else
              nvl(decode(max(A.storelevel),
                         'A',
                         max(GOODS.A),
                         'B',
                         max(GOODS.B),
                         'C',
                         max(GOODS.C),
                         'D',
                         max(GOODS.D),
                         'N',
                         max(GOODS.Xin),
                         0),
                  0)
           end
      from (select store.code,
                   store.name,
                   store.AREA,
                   store.receiverdays,
                   store.province,
                   store.city,
                   store.Downdays,
                   --    Safedays1,
                   store.phweek,
                   store.storelevel,
                   store.GID storeid,
                   store.STORESCALE,
                   V_GDSTOREBUSGATE.gdgid
            
              from store, V_GDSTOREBUSGATE
            
             where store.gid = V_GDSTOREBUSGATE.storegid
               and V_GDSTOREBUSGATE.ALWSTKOUT = 1
               and store.code = storeCode
               and store.gid != 1000000) A
      left join t_SysStorePeiHuoNew B
        on A.storeid = B.Storeid
       and A.gdgid = B.Gid
    
      left join goods
        on A.GDGID = goods.gid
    
      left join sort
        on substr(goods.sort, 0, 2) = sort.code
      left join sort sort1
        on substr(goods.sort, 0, 4) = sort1.code
      left join sort sort2
        on substr(goods.sort, 0, 6) = sort2.code
      left join sort sort3
        on substr(goods.sort, 0, 8) = sort3.code
      left join RPGGD RPGGD
        on (goods.GID = RPGGD.GDGID)
       and (goods.CODE = RPGGD.INPUTCODE)
    
      left join GOODSOUTSALEDATESTORE stoG
        on A.STOREID = stoG.Store
       and A.Gdgid = stoG.Gid
    
      left join GDQPC
        on GDQPC.GID = GOODS.GID
       and GDQPC.Isdu = 2
      left join GDQPC GDQPC2
        on GDQPC2.GID = GOODS.GID
       and GDQPC2.Ispu = 2
      left join AREA
        on A.AREA = AREA.Code
    
      left join (select rownum orderkey, Gdgid, AMT
                   from (select Gdgid,
                                sum(decode(SDRPTS.Cls,
                                           '零售',
                                           1,
                                           '零售退',
                                           -1,
                                           0) * (AMT + tax)) AMT
                           from SDRPTS
                          where fildate between begindate and enddate
                          group by Gdgid
                          order by AMT desc)) gdOrd
    
        on GOODS.gid = gdOrd.Gdgid
    
      left join (select substr(goods.sort, 0, 2) codeA,
                        sum(decode(SDRPTS.Cls, '零售', 1, '零售退', -1, 0) *
                            (AMT + tax)) AMT
                   from sdrpts, goods
                  where sdrpts.Gdgid = goods.gid
                    and goods.sort like '1%'
                    and sdrpts.fildate between begindate and enddate
                  group by substr(goods.sort, 0, 2)) SortAmt
        on substr(GOODS.sort, 0, 2) = SortAmt.codeA
    
      left join (select sum(qty) qty, GDGID
                   from BUSINV
                  where STORE = 1000000
                    and (Wrh in (1000020, 1000140))
                  group by GDGID) BUSINVZ
        on A.gdgid = BUSINVZ.GDGID
     where B.Gid is null
          
       and goods.sort like '1%'
     group by A.storeid, -----店铺ID
              A.gdgid; -----商品ID

  update t_SysStorePeiHuoNew set kcpd = '有' where int6 > 50; ---库存判断

  update t_SysStorePeiHuoNew
     set NUM9 = NUM7
   where QZPH is null
     and nvl(NUM9, 0) = 0
     and NUM7 < 18
     and INT6 > 0
     and char1 = '美容清洁'
     and nvl(NUM6, 0) < nvl(INT7, 0) + nvl(INT10, 0) + nvl(INT11, 0);
  commit;

  update t_SysStorePeiHuoNew
     set num9 = (case
                  when t_SysStorePeiHuoNew.char21 in ('A', 'B') then
                   t_SysStorePeiHuoNew.NUM7 * 3
                  else
                   t_SysStorePeiHuoNew.NUM7 * 2
                end)
  
   where t_SysStorePeiHuoNew.char2 = '彩妆香水'
     and t_SysStorePeiHuoNew.QZPH = '是'
     and t_SysStorePeiHuoNew.NUM7 <= 12
     and t_SysStorePeiHuoNew.num9 = t_SysStorePeiHuoNew.NUM7;
  commit;

  -- 强制配货中的商品-大类为彩妆香水的，商品的中包数小于等于12，A/B店铺补货量变为3个中包，其他店铺变为2个中包；

  update t_SysStorePeiHuoNew
     set num9 = (case
                  when t_SysStorePeiHuoNew.char21 = 'A' then
                   t_SysStorePeiHuoNew.NUM7 * 3
                  when t_SysStorePeiHuoNew.char21 in ('B', 'C') then
                   t_SysStorePeiHuoNew.NUM7 * 2
                  else
                   num9
                end)
   where t_SysStorePeiHuoNew.char1 = '美容清洁'
     and t_SysStorePeiHuoNew.num9 = t_SysStorePeiHuoNew.NUM7
     and t_SysStorePeiHuoNew.NUM7 <= 12;
  commit;

  --- 在商品品类为美容清洁的商品中，原补货量为一个中包装数且商品的中包数小于等于12的，
  --- 根据店铺等级：A类店铺增加至3个中包，B/C/新店类店铺增加至2个中包；

  update t_SysStorePeiHuoNew
     set num9 = t_SysStorePeiHuoNew.NUM7
  
   where t_SysStorePeiHuoNew.QZPH = '是'
     and t_SysStorePeiHuoNew.INT6 > 0
     and t_SysStorePeiHuoNew.num9 is null;
  commit;

  update t_SysStorePeiHuoNew
     set charX = case
                   when char1 in ('美容清洁', '食品') then
                    '健康美容'
                   when char1 in ('手机数码') then
                    '数码产品'
                   when char1 in ('家居日用', '家纺', '文具', '儿童用品') then
                    '时尚家居'
                   when char1 in ('时尚饰品', '服饰配件', '箱包') then
                    '服饰配件'
                 end;
  commit;

  update t_SysStorePeiHuoNew -----补货sku数
     set BHsku = case
                   when num9 > 0 then
                    1
                   else
                    0
                 end;
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
  
    if (Tmoney / SortAmt1 < 0.8) then
      update t_SysStorePeiHuoNew set P80 = '是' where gid = gid1;
      commit;
    end if;
  
  END LOOP;
  CLOSE cr1;

end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>t_SysStorePeiHuoNew</TABLE>
    <ALIAS>t_SysStorePeiHuoNew</ALIAS>
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
    <COLUMN>t_SysStorePeiHuoNew.char21</COLUMN>
    <TITLE>店铺销售级别</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char21</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.char8</COLUMN>
    <TITLE>店铺代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char8</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.char9</COLUMN>
    <TITLE>店铺名称</TITLE>
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
    <COLUMN>t_SysStorePeiHuoNew.char6</COLUMN>
    <TITLE>商品代码</TITLE>
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
    <COLUMN>t_SysStorePeiHuoNew.Code2</COLUMN>
    <TITLE>商品条码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>Code2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.char7</COLUMN>
    <TITLE>商品名称</TITLE>
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
    <COLUMN>t_SysStorePeiHuoNew.num1</COLUMN>
    <TITLE>零售价</TITLE>
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
    <COLUMN>t_SysStorePeiHuoNew.char5</COLUMN>
    <TITLE>季节</TITLE>
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
    <COLUMN>t_SysStorePeiHuoNew.int12</COLUMN>
    <TITLE>销售排名</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int12</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.SORTPERCENT</COLUMN>
    <TITLE>销售占比</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>SORTPERCENT</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0000%</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.P80</COLUMN>
    <TITLE>品类80%判断</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>P80</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.int1</COLUMN>
    <TITLE>在店库存量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.int1 * t_SysStorePeiHuoNew.num1</COLUMN>
    <TITLE>在店库存金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.int2</COLUMN>
    <TITLE>销售数量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.num3</COLUMN>
    <TITLE>实际销售金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.int3</COLUMN>
    <TITLE>已审核未配发量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.num4</COLUMN>
    <TITLE>已审核未配发金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>case when t_SysStorePeiHuoNew.num5<0 then '负库存'
else to_char(t_SysStorePeiHuoNew.num5) end</COLUMN>
    <TITLE>售馨率</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num5</COLUMNNAME>
    <CFILTER>TRUE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.num10</COLUMN>
    <TITLE>日均销</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num10</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.int6</COLUMN>
    <TITLE>总仓库存</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int6</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.qzph</COLUMN>
    <TITLE>强制配货</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>qzph</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.jyQty</COLUMN>
    <TITLE>建议首配量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>jyQty</COLUMNNAME>
    <CFILTER>TRUE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>case
             when t_SysStorePeiHuoNew.qzph = '是' and t_SysStorePeiHuoNew.jyqty > 0 then
              t_SysStorePeiHuoNew.jyqty
             else
              case
                when t_SysStorePeiHuoNew.num9 < 0 then
                 0
                else
                 t_SysStorePeiHuoNew.num9
              end
           end</COLUMN>
    <TITLE>补货量</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num9</COLUMNNAME>
    <CFILTER>TRUE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.num1*(case when t_SysStorePeiHuoNew.num9<0 then 0 else t_SysStorePeiHuoNew.num9 end)</COLUMN>
    <TITLE>补货金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>Column1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.char19</COLUMN>
    <TITLE>配货状态</TITLE>
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
    <COLUMN>t_SysStorePeiHuoNew.char10</COLUMN>
    <TITLE>ABC</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char10</COLUMNNAME>
    <CFILTER>TRUE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.int4</COLUMN>
    <TITLE>销售天数</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int4</COLUMNNAME>
    <CFILTER>TRUE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>case when t_SysStorePeiHuoNew.num6= 1000000 then '无销售' else to_char(t_SysStorePeiHuoNew.num6) end </COLUMN>
    <TITLE>可周转天数</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num6</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.num7</COLUMN>
    <TITLE>中包装箱规</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num7</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.num8</COLUMN>
    <TITLE>整箱箱规</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num8</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.date1</COLUMN>
    <TITLE>首配审核时间</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy-MM-dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.date2</COLUMN>
    <TITLE>首批发货时间</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy-MM-dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.date3</COLUMN>
    <TITLE>首批到店时间</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy-MM-dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.date4</COLUMN>
    <TITLE>首批销售时间</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy-MM-dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.char1</COLUMN>
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
    <COLUMN>t_SysStorePeiHuoNew.char2</COLUMN>
    <TITLE>大类</TITLE>
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
    <COLUMN>t_SysStorePeiHuoNew.char3</COLUMN>
    <TITLE>小类1</TITLE>
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
    <COLUMN>t_SysStorePeiHuoNew.char4</COLUMN>
    <TITLE>小类2</TITLE>
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
    <COLUMN>t_SysStorePeiHuoNew.int7</COLUMN>
    <TITLE>安全库存天数</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int7</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.int10</COLUMN>
    <TITLE>下单周期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int10</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.int11</COLUMN>
    <TITLE>运输周期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.char15</COLUMN>
    <TITLE>区域名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char15</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.char16</COLUMN>
    <TITLE>省份</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char16</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.char17</COLUMN>
    <TITLE>城市</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char17</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.date5</COLUMN>
    <TITLE>门店记账日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.char13</COLUMN>
    <TITLE>大品类</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char13</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.char14</COLUMN>
    <TITLE>区域代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char14</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.char18</COLUMN>
    <TITLE>货道</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char18</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.char20</COLUMN>
    <TITLE>配货日</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char20</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.kcpd</COLUMN>
    <TITLE>总仓库存判断(>50)</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>kcpd</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.BHsku</COLUMN>
    <TITLE>补货SKU数</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>BHsku</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.UnSalable</COLUMN>
    <TITLE>滞销</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>UnSalable</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>t_SysStorePeiHuoNew.IsOut</COLUMN>
    <TITLE>淘汰</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>IsOut</COLUMNNAME>
    <CFILTER>TRUE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>86</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>272</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>32</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>74</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>59</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>59</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>41</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>71</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>86</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>86</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>82</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>32</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>110</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>62</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>32</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>47</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char21</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char8</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char9</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char6</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.Code2</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char7</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.num1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char5</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.int12</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.SORTPERCENT</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.P80</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.int1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.int1 * t_SysStorePeiHuoNew.num1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.int2</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.num3</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.int3</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.num4</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>case when t_SysStorePeiHuoNew.num5<0 then '负库存'
else to_char(t_SysStorePeiHuoNew.num5) end</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.qzph</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.jyQty</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char19</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char10</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.int4</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>case when t_SysStorePeiHuoNew.num6= 1000000 then '无销售' else to_char(t_SysStorePeiHuoNew.num6) end </COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.num7</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.num8</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.date1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.date2</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.date3</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.date4</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char2</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char3</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char4</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.int7</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.int10</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.int11</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char15</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char16</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char17</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char18</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.char20</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.kcpd</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.UnSalable</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>t_SysStorePeiHuoNew.IsOut</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>商品名称</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>t_SysStorePeiHuoNew.char8</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>10028</RIGHTITEM>
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
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>t_SysStorePeiHuoNew.date5</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2016.01.22</RIGHTITEM>
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
    <DEFAULTVALUE>前7天</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>t_SysStorePeiHuoNew.date5</LEFT>
    <OPERATOR><=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2016.01.28</RIGHTITEM>
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
    <DEFAULTVALUE>前1天</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>t_SysStorePeiHuoNew.int7</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>7</RIGHTITEM>
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
    <DEFAULTVALUE>7</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>92</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>124</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>124</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>10028</SGLINEITEM>
    <SGLINEITEM>2016.01.22</SGLINEITEM>
    <SGLINEITEM>2016.01.28</SGLINEITEM>
    <SGLINEITEM>7</SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 2：</SGLINEITEM>
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
  </LINE>
  <LINE>
    <SGLINEITEM>  或 4：</SGLINEITEM>
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

