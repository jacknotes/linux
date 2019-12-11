<VERSION>4.1.1</VERSION>
<SQLQUERY>
<REMARK>
[����]

[Ӧ�ñ���]

[���������]

[��Ҫ�Ĳ�ѯ����]

[ʵ�ַ���]

[����]
</REMARK>
<BEFORERUN>
declare

  adate date;
  bdate date;

  flag      integer;
  begindate date; ---ͳ���������� ��ʼʱ��
  enddate   date; ---ͳ���������� ����ʱ��

  Safedays1 integer; ---��ȫ�������
  /* declare*/
  gid1     integer; ---��ƷID
  SortAmt1 number(18, 2); ---�����ܶ�
  AMT1     number(18, 2); ---��Ʒ�����ܶ�
  ASORT1   varchar2(80); ---���
  ASORT    varchar2(80); ---���

  TMoney number(18, 2); ---ͳ�ƽ��

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

  ---------���� Ϊǿ���䷢��Ʒ��Ϣ ----
  insert into t_SysStorePeiHuoNew
    (char1, ----Ʒ��
     char2, ----����
     char3, ----С��1
     char4, ----С��2
     num1, ---���ۼ�
     char5, ---����
     char6, ---��Ʒ����
     char7, ---��Ʒ����
     date1, ---�������ʱ��
     date2, ---��������ʱ��
     date3, ---��������ʱ��
     date4, ---��������ʱ��
     char8, ----���̴���
     char9, -------��������
     int1, -----�ڵ�����
     num2, -----�ڵ�����
     int2, ----��������
     num3, ----ʵ�����۽��
     int3, ---�����δ�䷢��
     num4, ----�����δ�䷢���
     num5, ---��ܰ��
     num6, ----����ת����
     date5, ---�ŵ��������
     int4, ---��������
     int5, ---��������
     num7, ----�а�װ���
     num8, ----�������
     int6, --- �ֿܲ��
     int7, ---��ȫ�������
     char10, ---ABC
     int10, ---�µ�����
     int11, ---��������
     -- int13,  ---��ȫ�������
     char13, --sort
     char14, ---�������
     char15, ---����
     char16, ---ʡ��
     char17, --- ����
     char18, --- ����
     char19, --���״̬
     char20, ---���������
     char21, ---�������ۼ���
     int12, ---��������
     StoreID, ---����ID
     Gid, ----��ƷID
     qzph, ---ǿ�����
     SortPercent, ---��Ʒ��Ʒ���е�����ռ��
     code2, ---��Ʒ����
     SortAmt, ---15��Ʒ�������ܶ�
     Amt, ---15�쵥Ʒ�����ܶ�
     ASORT, ---��Ʒ�����
     IsOut, ---��̭
     UnSalable, ---����
     StoreScale, ---�ŵ�����
     jyQty ---���������
     )
  
    SELECT /*+ rule */
    
     SORT.NAME NAME, ----Ʒ��
     SORT__1.NAME NAME1, ----����
     SORT__2.NAME NAME11, ----С��1
     SORT__3.NAME NAME111, ----С��2
     RPGGD.RTLPRC, ---���ۼ�
     GOODS.C_FASEASON C_FASEASON, ---����
     GOODS.CODE CODE, ---��Ʒ����
     GOODS.NAME NAME1111, ---��Ʒ����
     GOODSOUTSALEDATESTORE.FILLDATE FILLDATE, ---�������ʱ��
     GOODSOUTSALEDATESTORE.OUTDATE OUTDATE, ---��������ʱ��
     GOODSOUTSALEDATESTORE.INDATE INDATE, ---��������ʱ��
     GOODSOUTSALEDATESTORE.SALEDATE SALEDATE, ---��������ʱ��
     STORE.CODE CODE1, ---���̴���
     STORE.NAME NAME11111, ---��������
     SUM(BUSINV.QTY) QTY, ---�ڵ�����
     
     0 TOTAL, ----�ڵ�����
     SUM(nvl(SDRPTS.QTY, 0)) QTY1, ---��������
     SUM(nvl(SDRPTS.AMT, 0)) AMT, ---ʵ�����۽��
     SUM(nvl(noru.qty, 0)) INT3, ---�����δ�䷢��
     SUM(nvl(noru.qty * RPGGD.RTLPRC, 0)) NUM1, ---�����δ�䷢���
     round(case
             when (SUM(nvl(BUSINV.QTY, 0)) + SUM(nvl(SDRPTS.QTY, 0)) +
                  SUM(nvl(noru.qty, 0))) = 0 then
              0
             else
              SUM(nvl(SDRPTS.QTY, 0)) /
              (SUM(nvl(BUSINV.QTY, 0)) + SUM(nvl(SDRPTS.QTY, 0)) +
               SUM(nvl(noru.qty, 0)))
           end,
           2) ��ܰ��, -----��ܰ��
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
           0) ����ת����, ------����ת����
     adate, ---��ѯ��ʼʱ��
     
     case
       when trunc(nvl(GOODSOUTSALEDATESTORE.SALEDATE,
                      to_date('2014-01-01', 'yyyy-mm-dd'))) < adate then
        bdate - adate + 1
       else
        bdate - trunc(nvl(GOODSOUTSALEDATESTORE.SALEDATE,
                          to_date('2014-01-01', 'yyyy-mm-dd'))) + 1
     end saldays, ---��������
     nvl(STORE.receiverdays, 0) receiverdays, --��������
     max(GDQPC.QPC) QPC, ---�а�װ���
     max(GDQPC2.QPC) QPC2, ---�������
     max(BUSINVZ.QTY) QTYZ, -- �ֿܲ��
     Safedays1 Safedays, ---��ȫ�������
     case max(GOODSOUTSALEDATESTORE.Stat)
       when 0 then
        '����'
       when 1 then
        '����'
       when 2 then
        '��Ʒ'
     end ABC,
     max(STORE.Downdays) Downdays, ---�µ�����Ĭ��4��
     max(STORE.RECEIVERDAYS), --- ��������
     -- 7,   ---��ȫ�������
     max(GOODS.SORT), ----��sort
     max(AREA.Code), ----�������
     max(AREA.Name), ----��������
     max(STORE.province), ---ʡ��
     max(STORE.city), --- ����
     substr(max(GOODS.Slot), 0, 3), --- ����
     case
       when max(V_GDSTOREBUSGATE.ALWSTKOUT) = 1 then
        '����'
       else
        '��ֹ'
     end, --���״̬
     max(STORE.phweek) phweek, ---���������
     max(STORE.storelevel) storelevel, ---�������ۼ���
     max(gdOrd.orderkey) orderkey, ---��������
     max(STORE.GID) storeID, -----����ID
     max(GOODS.GID) gid, -----��ƷID
     '', ---ǿ�����
     max(round(gdOrd.Amt * 100 / SortAmt.AMT, 4)) SortPercent, ---��Ʒ��Ʒ���е�����ռ��
     max(GOODS.Code2) Code2, ---��Ʒ����
     max(nvl(SortAmt.AMT, 0)), ---15����������ܶ�
     max(nvl(gdOrd.Amt, 0)), --- 15�쵥Ʒ�����ܶ�
     max(substr(GOODS.SORT, 0, 2)), ----����sort
     max(GOODS.IsOut), ---��̭
     max(GOODS.UnSalable), ---����
     max(STORE.STORESCALE), ---�ŵ�����
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
                   '�����͵�',
                   max(GOODS.Chaoda),
                   '���͵�',
                   max(GOODS.Daxing),
                   '���͵�',
                   max(GOODS.Zhongxing),
                   'С�͵�',
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
      left join (select sum(decode(SDRPTS.Cls, '����', 1, '������', -1, 0) * QTY) qty,
                        sum(decode(SDRPTS.Cls, '����', 1, '������', -1, 0) *
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
                    and STKOUT.cls = 'ͳ���'
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
                                           '����',
                                           1,
                                           '������',
                                           -1,
                                           0) * (AMT + tax)) AMT
                           from SDRPTS
                          where fildate between begindate and enddate
                          group by Gdgid
                          order by AMT desc)) gdOrd
        on GOODS.gid = gdOrd.Gdgid
    
      left join (select substr(goods.sort, 0, 2) codeA,
                        sum(decode(SDRPTS.Cls, '����', 1, '������', -1, 0) *
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
     GROUP BY SORT.NAME, ----Ʒ��
              SORT__1.NAME, ----����
              SORT__2.NAME, ----С��1
              SORT__3.NAME, ----С��2
              RPGGD.RTLPRC, ---���ۼ�
              GOODS.C_FASEASON, ---����
              GOODS.CODE, ---��Ʒ����
              GOODS.NAME, ---��Ʒ����
              GOODSOUTSALEDATESTORE.FILLDATE, ---�������ʱ��
              GOODSOUTSALEDATESTORE.OUTDATE, ---��������ʱ��
              GOODSOUTSALEDATESTORE.INDATE, ---��������ʱ��
              GOODSOUTSALEDATESTORE.SALEDATE, ---��������ʱ��
              STORE.CODE, ---���̴���
              STORE.NAME, ---��������;
              STORE.receiverdays; --���̵�������
  commit;

  update t_SysStorePeiHuoNew
     set num10 = nvl(case
                       when int4 = 0 then
                        0
                       else
                        int2 / int4
                     end,
                     0); ---�վ���
  commit;

  update t_SysStorePeiHuoNew
     set num9 = case
                  when t_SysStorePeiHuoNew.char19 = '��ֹ' then
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
                  when t_SysStorePeiHuoNew.char1 in ('�������', 'ʳƷ') and
                       nvl(t_SysStorePeiHuoNew.int1, 0) < 5 and
                       nvl(t_SysStorePeiHuoNew.int2, 0) <= 0 then
                   case
                     when t_SysStorePeiHuoNew.num7 - t_SysStorePeiHuoNew.int3 < 0 then
                      0
                     else
                      t_SysStorePeiHuoNew.num7 - t_SysStorePeiHuoNew.int3
                   end
                  when t_SysStorePeiHuoNew.char1 = 'ʱ����Ʒ' and
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
                end; -------������
  commit;

  ---------���� Ϊǿ���䷢��Ʒ��Ϣ ----
  insert into t_SysStorePeiHuoNew
    (char1, ----Ʒ��
     char2, ----����
     char3, ----С��1
     char4, ----С��2
     num1, ---���ۼ�
     char5, ---����
     char6, ---��Ʒ����
     char7, ---��Ʒ����
     date1, ---�������ʱ��
     date2, ---��������ʱ��
     date3, ---��������ʱ��
     date4, ---��������ʱ��
     char8, ----���̴���
     char9, -------��������
     int1, -----�ڵ�����
     num2, -----�ڵ�����
     int2, ----��������
     num3, ----ʵ�����۽��
     int3, ---�����δ�䷢��
     num4, ----�����δ�䷢���
     num5, ---��ܰ��
     num6, ----����ת����
     date5, ---�ŵ��������
     int4, ---��������
     int5, ---��������
     num7, ----�а�װ���
     num8, ----�������
     int6, --- �ֿܲ��
     int7, ---��ȫ�������
     char10, ---ABC
     int10, ---�µ�����
     int11, ---��������
     -- int13,  ---��ȫ�������
     char13, --sort
     char14, ---�������
     char15, ---����
     char16, ---ʡ��
     char17, --- ����
     char18, --- ����
     char19, --���״̬
     char20, ---���������
     char21, ---�������ۼ���
     int12, ---��������
     StoreID, ---����ID
     Gid, ----��ƷID
     num9, ---������
     qzph, ---ǿ�����
     SortPercent, ---��Ʒ��Ʒ���е�����ռ��
     Code2, ---��Ʒ����
     SortAmt, ---15��Ʒ�������ܶ�
     Amt, ---15�쵥Ʒ�����ܶ�
     ASORT, ---�������
     IsOut, ---��̭
     UnSalable, ---����
     StoreScale, ---�ŵ�����
     jyQty ---���������
     )
  
    select max(sort.name), ---Ʒ��
           max(sort1.name), ----����
           max(sort2.name), ----С��1
           max(sort3.name), ----С��2
           max(RPGGD.RTLPRC), ---���ۼ�
           max(goods.C_FASEASON) C_FASEASON, ---����
           max(goods.code), ---��Ʒ����
           max(goods.name), ---��Ʒ����
           
           max(stoG.FILLDATE) FILLDATE, ---�������ʱ��
           max(stoG.OUTDATE) OUTDATE, ---��������ʱ��
           max(stoG.INDATE) INDATE, ---��������ʱ��
           max(stoG.SALEDATE) SALEDATE, ---��������ʱ��
           max(A.code), ----���̴���
           max(A.name), ----��������
           0, ---�ڵ�����
           0, ---�ڵ�����
           0, ----��������
           0, ----ʵ�����۽��
           0, ---�����δ�䷢��
           0, ----�����δ�䷢���
           0, ---��ܰ��
           0, ----����ת����
           adate, ---�ŵ��������
           0, ---��������
           nvl(max(A.receiverdays), 0) receiverdays, --��������
           
           max(GDQPC.QPC) QPC, ---�а�װ���
           max(GDQPC2.QPC) QPC2, ---�������
           max(BUSINVZ.QTY) QTYZ, -- �ֿܲ��
           Safedays1 Safedays, ---��ȫ�������
           '', --ABC
           max(A.Downdays) Downdays, ---�µ�����Ĭ��4��
           max(A.RECEIVERDAYS), --- ��������
           max(GOODS.SORT), ----��sort
           max(AREA.Code), ----�������
           max(AREA.Name), ----��������
           max(A.province), ---ʡ��
           max(A.city), --- ����
           substr(max(GOODS.Slot), 0, 3), --- ����
           '����', --���״̬
           max(A.phweek) phweek, ---���������
           max(A.storelevel) storelevel, ---�������ۼ���
           max(gdOrd.orderkey) orderkey, ---��������
           
           A.storeid storeID, -----����ID
           A.gdgid gid, -----��ƷID
           case
             when max(BUSINVZ.QTY) > 0 then
              max(GDQPC.QPC)
             else
              0
           end, ---������
           case
             when max(BUSINVZ.QTY) > 0 then
              '��'
             else
              ''
           end, ---ǿ�����
           max(round(gdOrd.Amt * 100 / SortAmt.AMT, 4)) SortPercent, ---��Ʒ��Ʒ���е�����ռ��
           max(GOODS.Code2) Code2, ---��Ʒ����
           max(nvl(SortAmt.AMT, 0)), ---15����������ܶ�
           max(nvl(gdOrd.Amt, 0)), --- 15�쵥Ʒ�����ܶ�
           max(substr(GOODS.SORT, 0, 2)), ----����sort
           max(GOODS.IsOut), ---��̭
           max(GOODS.UnSalable), ---����
           max(A.STORESCALE), ---�ŵ�����
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
                         '�����͵�',
                         max(GOODS.Chaoda),
                         '���͵�',
                         max(GOODS.Daxing),
                         '���͵�',
                         max(GOODS.Zhongxing),
                         'С�͵�',
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
                                           '����',
                                           1,
                                           '������',
                                           -1,
                                           0) * (AMT + tax)) AMT
                           from SDRPTS
                          where fildate between begindate and enddate
                          group by Gdgid
                          order by AMT desc)) gdOrd
    
        on GOODS.gid = gdOrd.Gdgid
    
      left join (select substr(goods.sort, 0, 2) codeA,
                        sum(decode(SDRPTS.Cls, '����', 1, '������', -1, 0) *
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
     group by A.storeid, -----����ID
              A.gdgid; -----��ƷID

  update t_SysStorePeiHuoNew set kcpd = '��' where int6 > 50; ---����ж�

  update t_SysStorePeiHuoNew
     set NUM9 = NUM7
   where QZPH is null
     and nvl(NUM9, 0) = 0
     and NUM7 < 18
     and INT6 > 0
     and char1 = '�������'
     and nvl(NUM6, 0) < nvl(INT7, 0) + nvl(INT10, 0) + nvl(INT11, 0);
  commit;

  update t_SysStorePeiHuoNew
     set num9 = (case
                  when t_SysStorePeiHuoNew.char21 in ('A', 'B') then
                   t_SysStorePeiHuoNew.NUM7 * 3
                  else
                   t_SysStorePeiHuoNew.NUM7 * 2
                end)
  
   where t_SysStorePeiHuoNew.char2 = '��ױ��ˮ'
     and t_SysStorePeiHuoNew.QZPH = '��'
     and t_SysStorePeiHuoNew.NUM7 <= 12
     and t_SysStorePeiHuoNew.num9 = t_SysStorePeiHuoNew.NUM7;
  commit;

  -- ǿ������е���Ʒ-����Ϊ��ױ��ˮ�ģ���Ʒ���а���С�ڵ���12��A/B���̲�������Ϊ3���а����������̱�Ϊ2���а���

  update t_SysStorePeiHuoNew
     set num9 = (case
                  when t_SysStorePeiHuoNew.char21 = 'A' then
                   t_SysStorePeiHuoNew.NUM7 * 3
                  when t_SysStorePeiHuoNew.char21 in ('B', 'C') then
                   t_SysStorePeiHuoNew.NUM7 * 2
                  else
                   num9
                end)
   where t_SysStorePeiHuoNew.char1 = '�������'
     and t_SysStorePeiHuoNew.num9 = t_SysStorePeiHuoNew.NUM7
     and t_SysStorePeiHuoNew.NUM7 <= 12;
  commit;

  --- ����ƷƷ��Ϊ����������Ʒ�У�ԭ������Ϊһ���а�װ������Ʒ���а���С�ڵ���12�ģ�
  --- ���ݵ��̵ȼ���A�����������3���а���B/C/�µ������������2���а���

  update t_SysStorePeiHuoNew
     set num9 = t_SysStorePeiHuoNew.NUM7
  
   where t_SysStorePeiHuoNew.QZPH = '��'
     and t_SysStorePeiHuoNew.INT6 > 0
     and t_SysStorePeiHuoNew.num9 is null;
  commit;

  update t_SysStorePeiHuoNew
     set charX = case
                   when char1 in ('�������', 'ʳƷ') then
                    '��������'
                   when char1 in ('�ֻ�����') then
                    '�����Ʒ'
                   when char1 in ('�Ҿ�����', '�ҷ�', '�ľ�', '��ͯ��Ʒ') then
                    'ʱ�мҾ�'
                   when char1 in ('ʱ����Ʒ', '�������', '���') then
                    '�������'
                 end;
  commit;

  update t_SysStorePeiHuoNew -----����sku��
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
      update t_SysStorePeiHuoNew set P80 = '��' where gid = gid1;
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
    <TITLE>�������ۼ���</TITLE>
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
    <TITLE>���̴���</TITLE>
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
    <TITLE>��������</TITLE>
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
    <TITLE>��Ʒ����</TITLE>
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
    <TITLE>��Ʒ����</TITLE>
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
    <TITLE>��Ʒ����</TITLE>
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
    <TITLE>���ۼ�</TITLE>
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
    <TITLE>����</TITLE>
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
    <TITLE>��������</TITLE>
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
    <TITLE>����ռ��</TITLE>
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
    <TITLE>Ʒ��80%�ж�</TITLE>
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
    <TITLE>�ڵ�����</TITLE>
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
    <TITLE>�ڵ�����</TITLE>
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
    <TITLE>��������</TITLE>
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
    <TITLE>ʵ�����۽��</TITLE>
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
    <TITLE>�����δ�䷢��</TITLE>
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
    <TITLE>�����δ�䷢���</TITLE>
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
    <COLUMN>case when t_SysStorePeiHuoNew.num5<0 then '�����'
else to_char(t_SysStorePeiHuoNew.num5) end</COLUMN>
    <TITLE>��ܰ��</TITLE>
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
    <TITLE>�վ���</TITLE>
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
    <TITLE>�ֿܲ��</TITLE>
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
    <TITLE>ǿ�����</TITLE>
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
    <TITLE>����������</TITLE>
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
             when t_SysStorePeiHuoNew.qzph = '��' and t_SysStorePeiHuoNew.jyqty > 0 then
              t_SysStorePeiHuoNew.jyqty
             else
              case
                when t_SysStorePeiHuoNew.num9 < 0 then
                 0
                else
                 t_SysStorePeiHuoNew.num9
              end
           end</COLUMN>
    <TITLE>������</TITLE>
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
    <TITLE>�������</TITLE>
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
    <TITLE>���״̬</TITLE>
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
    <TITLE>��������</TITLE>
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
    <COLUMN>case when t_SysStorePeiHuoNew.num6= 1000000 then '������' else to_char(t_SysStorePeiHuoNew.num6) end </COLUMN>
    <TITLE>����ת����</TITLE>
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
    <TITLE>�а�װ���</TITLE>
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
    <TITLE>�������</TITLE>
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
    <TITLE>�������ʱ��</TITLE>
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
    <TITLE>��������ʱ��</TITLE>
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
    <TITLE>��������ʱ��</TITLE>
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
    <TITLE>��������ʱ��</TITLE>
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
    <TITLE>Ʒ��</TITLE>
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
    <TITLE>����</TITLE>
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
    <TITLE>С��1</TITLE>
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
    <TITLE>С��2</TITLE>
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
    <TITLE>��ȫ�������</TITLE>
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
    <TITLE>�µ�����</TITLE>
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
    <TITLE>��������</TITLE>
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
    <TITLE>��������</TITLE>
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
    <TITLE>ʡ��</TITLE>
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
    <TITLE>����</TITLE>
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
    <TITLE>�ŵ��������</TITLE>
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
    <TITLE>��Ʒ��</TITLE>
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
    <TITLE>�������</TITLE>
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
    <TITLE>����</TITLE>
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
    <TITLE>�����</TITLE>
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
    <TITLE>�ֿܲ���ж�(>50)</TITLE>
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
    <TITLE>����SKU��</TITLE>
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
    <TITLE>����</TITLE>
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
    <TITLE>��̭</TITLE>
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
    <COLUMN>case when t_SysStorePeiHuoNew.num5<0 then '�����'
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
    <COLUMN>case when t_SysStorePeiHuoNew.num6= 1000000 then '������' else to_char(t_SysStorePeiHuoNew.num6) end </COLUMN>
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
    <COLUMN>��Ʒ����</COLUMN>
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
    <DEFAULTVALUE>ǰ7��</DEFAULTVALUE>
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
    <DEFAULTVALUE>ǰ1��</DEFAULTVALUE>
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
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>10028</SGLINEITEM>
    <SGLINEITEM>2016.01.22</SGLINEITEM>
    <SGLINEITEM>2016.01.28</SGLINEITEM>
    <SGLINEITEM>7</SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 2��</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 3��</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 4��</SGLINEITEM>
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
<RPTLINEHEIGHT>����</RPTLINEHEIGHT>
<RPTPAGEHEIGHT>66</RPTPAGEHEIGHT>
<RPTPAGEWIDTH>80</RPTPAGEWIDTH>
<RPTTITLETYPE>0</RPTTITLETYPE>
<RPTCURREPORT></RPTCURREPORT>
<RPTREPORTLIST>
</RPTREPORTLIST>
</SQLREPORT>

