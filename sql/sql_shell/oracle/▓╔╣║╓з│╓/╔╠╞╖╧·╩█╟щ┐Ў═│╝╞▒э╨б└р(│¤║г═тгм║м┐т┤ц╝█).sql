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
--���հ�
/*20150528
1.���Ӱ�װ���
2.�������۽��
3.����������������������
  20150605 
���Ӽ�������  ��ΰ
  20150609 
����������� Ʒ�� ���� С��1 С��2
 20170525
�����˹��ʡ��ڵ�����
 20170605
 �޵���80001������
 
 1�������뽫�ֶΣ����ڵ���������Ϊֻ������Ʒ���ڵ���������δ��˶���������Ϊֻ�� ����Ʒ��δ��˶���������(��������� 20170613)

2�������ֶΣ�Խ�ϲ��ڵ��������ɱ����ڵ�����ľ�ȼ�����ڵ�����ľ�ȼ���ֿ��(��������� 20170613)

20170628
���ӿ��ۣ�������λ���
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

  gid1     integer; ---��ƷID
  SortAmt1 number(18, 2); ---�����ܶ�
  AMT1     number(18, 2); ---��Ʒ�����ܶ�
  ASORT1   varchar2(80); ---���
  ASORT    varchar2(80); ---���

  TMoney number(18, 2); ---ͳ�ƽ��

  cursor cr1 is
    select tmp_test2.int18 gid,
           A.AMT SortAmt,
           nvl(tmp_test2.num3, 0) AMT,
           A.char2 ASORT
      from (select sum(num3) AMT, char2
              from tmp_test2
             where char13 = '��'
             group by char2) A,
           tmp_test2
     where tmp_test2.char2 = A.char2
       and tmp_test2.char13 = '��'
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
    (char1, --- Ʒ��
     char2, --- С��2
     char3, --��Ʒ����
     char4, --��Ʒ����
     num1, --���ۼ�
     int1, ---��x����������
     int2, ---������
     num2, --�վ���
     int3, ---�ŵ���
     int4, ---�ֿ���
     int23,---ľ�ȼ���ֿ��
     int5, ---�ڵ�������Ʒ���ڵ�����
     int19,---�����ڵ���--��20170525��������ֶ�
     int20,--Խ�ϲ��ڵ���
     int21,--���ɱ����ڵ���
     int22,--ľ�ȼ�����ڵ���
     int6, ---������
     int7, ---��������
     char5, --��Ӧ�̴���
     char6, --��Ӧ������
     date1, --����ʱ��
     date2, ---����ʱ��
     int8, ---ͳ������
     date3, ---ͳ������
     char7, --��Ʒ����
     num3, --��x�����۶�
     char8, --��Ʒ��װ���
     char9, --��������
     char10, --����
     char11, --С��2
     date4, ---�״����ʱ��
     int9, --��������
     int10, --��������
     char12, --����
     char13, --��̭
     int11, --��С����
     int12, --����ǰ����
     num4, --��׼������
     char14, --�µ���
     int13, --��������    
     char19, --��Ʒ  
     int14, ---�����������
     num5, --�վ�����
     int15, ---��X�����۶�����
     date5, ---����������
     int16, ---����������   
     int17, --δ��˶�����  ��Ʒ��
     int18, --��ƷGID    
     char20, --С��1  80%���
     CHAR21, ---��Ʒ״̬
     CHAR22, ---ͣ����
     char23 , ---Ʒ��
     
     --�����Ǳ��������ֶ�
     num6,--�ɱ���
     num7,--��Ʒ�ֿ��
     num8,--���ʲֿ��    
     num9,--Խ�ϲֿ��
     num10,--�µ�ֿ��
     num11,--�˻��ֿ���
     num12,--����ֿ��
     num13--�������ֿ��
     )
    select AA.s1name, --- Ʒ��
           AA.s2name, --- С��2
           AA.gcode, --��Ʒ����
           AA.gname, --��Ʒ����
           AA.RTLPRC, --���ۼ�
           BB.qty Salqty, ---��x������
           CC.storeNum, ---������
           
           round(BB.daysalnum, 2) des, --�վ���
           
           CC.qty    storeqty, ---�ŵ���
           DD.qty    stoqty, ---�ֿ���
           DD.qty_MF  qty_MF,---ľ�ȼ���ֿ��
           DD.ORDQTY, ---�ڵ��� ��Ʒ���ڵ���
           DD.ORDQTY_GJ, ---�����ڵ���--��20170525��������ֶ�
           DD.ORDQTY_YN,----Խ�ϲ��ڵ���
           DD.ORDQTY_FLB,----���ɱ����ڵ���
           DD.ORDQTY_MF,----ľ�ȼ�����ڵ���
           DD.ALCQTY, ---������
           EE.xqty, ---��������
           
           AA.vendorcode, --��Ӧ�̴���
           AA.vendorname, ---��Ӧ������
           GOODSOutSaleDate.Fsaledate, ---����ʱ��
           GOODSOutSaleDate.Foutdate, ---����ʱ��
           days, ---ͳ������
           Bfiledate, --ͳ����С����
           AA.gcode2, ---��Ʒ����
           BB.amt, --��x�����۶�
           EE.qpcstr, --��Ʒ��װ���
           AA.c_faseason, --�������� 
           AA.s3name, --����
           AA.s4name, --С��2
           GOODSOutSaleDate.FINDATE, ---�״����ʱ��
           FF.qty, --��������
           FF.acvqty, --��������      
           AA.unsalable, ---����  
           AA.IsOut, ---��̭
           AA.buyminnum, --��С����
           AA.beforedays, --����ǰ����
           AA.c_stdshow, --��׼������
           AA.orderweek, --�µ���
           AA.orderdays, --��������           
           case
             when GOODSOutSaleDate.Stat = 2 then
              '��'
             else
              ''
           end NewType, ---��Ʒ
           GG.Stors, ---�����������
           round(BB.daysalMoney, 2) desm, --�վ�����
           BB.orderkey, ---��X�����۶�����
           KK.zjrkri, ---����������
           KK.zjrksl, ---����������
           mm.wshqty, --δ��˶�����  ��Ʒ��  
           AA.gid, --��Ʒ����       
           '', --С��1  80%���     
           AA.gstat, --��Ʒ״̬
           AA.tingzhiqi,  ---ͣ����
           AA.brand,      --Ʒ��
           --�����Ǳ��������ֶ�
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
                   left join  sort sort1 on substr(goods.sort, 0, 2) = sort1.code --Ʒ��
                   left join  sort sort2 on substr(goods.sort, 0, 6) = sort2.code --С��1
                   left join  sort sort3 on substr(goods.sort, 0, 4) = sort3.code --���� 
                   left join  sort sort4 on substr(goods.sort, 0, 8) = sort4.code --С��2
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
                        sum(decode(SDRPTS.Cls, '����', 1, '������', -1, 0) *
                            SDRPTS.QTY) qty,
                        sum(decode(SDRPTS.Cls, '����', 1, '������', -1, 0) *
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
                          and SDRPTS.Cls in ('����', '������')
                          and SDRPTS.Snd not in (select gid from store where code in ('40127','40144','40223','80001'))
                        group by SDRPTS.Snd, SDRPTS.GDGID) salNum
                group by GDGID
                order by amt desc)
      
      ) BB
    
        on AA.gid = BB.gdgid
    
      left join
    
     (select BUSINVS.GDGID,
             count(BUSINVS.STORE) storeNum,
             sum(BUSINVS.qty) qty ------�̵���,�ŵ���
      
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
                   when WRH in (1000020, 1000140) then qty else 0 end) qty,--��Ʒ�ֺͲ�����
             sum(case
                   when WRH =1000020 then qty else 0 end) qty_SP,--��Ʒ�ֿ��     
             sum(case
                   when WRH=1000234 then qty else 0 end) qty_GJ,--���ʲֿ��
             sum(case
                   when WRH=1000194 then qty else 0 end) qty_YN,--Խ�ϲֿ��       
             sum(case
                   when WRH=1000214 then qty else 0 end) qty_XD,--�µ�ֿ��
             sum(case
                   when WRH=1000021 then qty else 0 end) qty_TH,--�˻��ֿ���
             sum(case
                   when WRH=1000254 then qty else 0 end) qty_QH,--����ֿ��
             sum(case
                   when WRH=1000294 then qty else 0 end) qty_QHKP,--�������ֿ��                      
                           
             sum(case when WRH=1000314 then qty else 0 end) qty_MF,  --ľ�ȼ�����Ʒ�� 
             
             sum(case when wrh=1000020 then ORDQTY else 0 end ) ORDQTY, ---��Ʒ���ڵ���
             
            sum(case
                when WRH =1000234 then ORDQTY else 0 end) ORDQTY_GJ  , ---�����ڵ���--��20170525��������ֶ�
            sum(case
                when WRH =1000194 then ORDQTY else 0 end) ORDQTY_YN  , ---Խ�ϲ��ڵ���-��20170616��������ֶ�
            sum(case
                when WRH =1000174 then ORDQTY else 0 end) ORDQTY_FLB  , ---���ɱ����ڵ���--��20170616��������ֶ�
            sum(case
                when WRH =1000314 then ORDQTY else 0 end) ORDQTY_MF  , ---ľ�ȼ�����ڵ���--��20170616��������ֶ�

             sum(ALCQTY) ALCQTY ------�ֿ�������
        from BUSINVS
      
       where STORE = 1000000
       group by GDGID) DD
    
        on AA.gid = DD.GDGID
    
      left join
    
     (select gid,
             max��qpc��xqty, ---��������
             max(qpcstr) qpcstr --��Ʒ��װ��� ���� 20150528  ����  ���걦 
      
        from GDQPC
       where ISPU = 2
       group by gid) EE
    
        on AA.gid = EE.gid
    
      left join ( --�ɹ��ƻ���  ��������qty   �������� acvqty   20150702  ��ΰ  �ƻ��ڵ���=��������-��������
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
                    and mst.CLS = '��Ӫ��'
                       /*and mst.num='88881603090004'*/
                    and mst.PURORDTYPE <> 1
                    group by dtl.gdgid,
                        goods.code,
                        goods.name) mm
        on AA.gid = mm.gdgid
    
     where (AA.vendorcode = vendorcode or vendorcode is null);

  commit;

  ----������Ʒ״̬
  update tmp_test2
     set char19 = ''
   where char13 = '��'
     and char19 = '��'
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
      update tmp_test2 set char20 = '��' where int18 = gid1;
      commit;
    end if;
  
  END LOOP;
  CLOSE cr1;

  commit;


  delete from tmp_test3;
  commit;

  insert into tmp_test3
    (int8, ---ͳ������
       char1, --- Ʒ��
       char2, --- С��2
       char10, --����
       char11, --С��2
  /*     num6,--�ɱ���
       num1, --���ۼ�
       int18, --��ƷGID */ 
       num6,--�վ���
       date3, ---ͳ������
       char9, --��������
       char13, --��̭   
       char19, --��Ʒ
       CHAR21, ---��Ʒ״̬
       CHAR22, ---ͣ����
       char23 , ---Ʒ�� 
     int1, ---��x����������
     int5, ---�ڵ�������Ʒ���ڵ�����
     int19,---�����ڵ���--��20170525��������ֶ�
     int20,--Խ�ϲ��ڵ���
     int21,--���ɱ����ڵ���
     int22,--ľ�ȼ�����ڵ���
     int6, ---������
     num3, --��x�����۶�
     num4, --��x�����۳ɱ���
     
     num25,--���ܾ�����
     num2,   --�����ܾ�����
     int17, --δ��˶�����  ��Ʒ�� 
     int3, ---�ŵ���
     num7,---�ŵ����
     num8,---�ŵ���ɱ���  
     int23,---ľ�ȼ���ֿ��
     num9,---ľ�ȼ���ֿ���
     num10,---ľ�ȼ���ֿ��ɱ���
     int9, --��Ʒ�ֿ��
     num11,---��Ʒ�ֿ���
     num12,---��Ʒ�ֿ��ɱ���
     int10, --���ʲֿ��  
     num13,---���ʲֿ���
     num14,---���ʲֿ��ɱ���  
     int11, --Խ�ϲֿ��
     num15,---Խ�ϲֿ���
     num16,---Խ�ϲֿ��ɱ���
     int12, --�µ�ֿ��
     num17,---�µ�ֿ���
     num18,---�µ�ֿ��ɱ���
     int13, --�˻��ֿ���
     num19,---�˻��ֿ����
     num20,---�˻��ֿ���ɱ���
     int14, --����ֿ��
     num21,---����ֿ���
     num22,---����ֿ���ɱ���
     int15, --�������ֿ��
     num23,---�������ֿ���
     num24---�������ֿ��ɱ���
     )
   select int8, ---ͳ������
       char1, --- Ʒ��
       char2, --- С��2
       char10, --����
       char11, --С��2
/*       num6,--�ɱ���
       num1, --���ۼ�
       int18, --��ƷGID */
       sum(num2),--�վ���
       date3, ---ͳ������
       char9, --��������
       char13, --��̭   
       char19, --��Ʒ
       CHAR21, ---��Ʒ״̬
       CHAR22, ---ͣ����
       char23 , ---Ʒ�� 
     sum(int1), ---��x����������
     sum(int5), ---�ڵ�������Ʒ���ڵ�����
     sum(int19),---�����ڵ���--��20170525��������ֶ�
     sum(int20),--Խ�ϲ��ڵ���
     sum(int21),--���ɱ����ڵ���
     sum(int22),--ľ�ȼ�����ڵ���
     sum(int6), ---������
     sum(num3), --��x�����۶�
     sum(int1*num6),--��x�����۳ɱ���
     case when tmp_test2.int2=0 then 0 else sum( round(tmp_test2.num5*7/tmp_test2.int2,2)) end,--���ܾ�����
     case when tmp_test2.int2=0 then 0 else sum( round(tmp_test2.num2*7/tmp_test2.int2,2)) end,--�����ܾ�����
     sum(int17), --δ��˶�����  ��Ʒ��  
     sum(int3), ---�ŵ���
     sum(int3*num1),--
     sum(int3*num6),--
     sum(int23),---ľ�ȼ���ֿ��
     sum(int23*num1),--
     sum(int23*num6),--
     sum(num7),--��Ʒ�ֿ��
     sum(num7*num1),--
     sum(num7*num6),--
     sum(num8),--���ʲֿ�� 
     sum(num8*num1),--
     sum(num8*num6),--   
     sum(num9),--Խ�ϲֿ��
     sum(num9*num1),--
     sum(num9*num6),--
     sum(num10),--�µ�ֿ��
     sum(num10*num1),--
     sum(num10*num6),--
     sum(num11),--�˻��ֿ���
     sum(num11*num1),--
     sum(num11*num6),--
     sum(num12),--����ֿ��
     sum(num12*num1),--
     sum(num12*num6),--
     sum(num13),--�������ֿ��
     sum(num13*num1),--
     sum(num13*num6)--
from tmp_test2
group by int8, ---ͳ������
       char1, --- Ʒ��
       char2, --- С��2
       char10, --����
       char11, --С��2
       int2,
       date3, ---ͳ������
       char9, --��������
       char13, --��̭   
       char19, --��Ʒ
       CHAR21, ---��Ʒ״̬
       CHAR22, ---ͣ����
       char23  ---Ʒ�� 
     ;

 delete from tmp_test1;
  commit;

  insert into tmp_test1
    (int8, ---ͳ������
       char1, --- Ʒ��
       char2, --- С��2
       char10, --����
       char11, --С��2
       num6,--�վ���
       date3, ---ͳ������
       char9, --��������
       char13, --��̭   
       char19, --��Ʒ
       CHAR21, ---��Ʒ״̬
       CHAR22, ---ͣ����
       char23 , ---Ʒ�� 
     int1, ---��x����������
     int5, ---�ڵ�������Ʒ���ڵ�����
     int19,---�����ڵ���--��20170525��������ֶ�
     int20,--Խ�ϲ��ڵ���
     int21,--���ɱ����ڵ���
     int22,--ľ�ȼ�����ڵ���
     int6, ---������
     num3, --��x�����۶�
     num4, --��x�����۳ɱ���
     
     num25,--���ܾ�����
     num2,   --�����ܾ�����
     int17, --δ��˶�����  ��Ʒ�� 
     int3, ---�ŵ���
     num7,---�ŵ����
     num8,---�ŵ���ɱ���  
     int23,---ľ�ȼ���ֿ��
     num9,---ľ�ȼ���ֿ���
     num10,---ľ�ȼ���ֿ��ɱ���
     int9, --��Ʒ�ֿ��
     num11,---��Ʒ�ֿ���
     num12,---��Ʒ�ֿ��ɱ���
     int10, --���ʲֿ��  
     num13,---���ʲֿ���
     num14,---���ʲֿ��ɱ���  
     int11, --Խ�ϲֿ��
     num15,---Խ�ϲֿ���
     num16,---Խ�ϲֿ��ɱ���
     int12, --�µ�ֿ��
     num17,---�µ�ֿ���
     num18,---�µ�ֿ��ɱ���
     int13, --�˻��ֿ���
     num19,---�˻��ֿ����
     num20,---�˻��ֿ���ɱ���
     int14, --����ֿ��
     num21,---����ֿ���
     num22,---����ֿ���ɱ���
     int15, --�������ֿ��
     num23,---�������ֿ���
     num24---�������ֿ��ɱ���
     )
     select int8, ---ͳ������
       char1, --- Ʒ��
       char2, --- С��2
       char10, --����
       char11, --С��2
       sum(num6),--�վ���
       date3, ---ͳ������
       char9, --��������
       char13, --��̭   
       char19, --��Ʒ
       CHAR21, ---��Ʒ״̬
       CHAR22, ---ͣ����
       char23 , ---Ʒ�� 
     sum(int1), ---��x����������
     sum(int5), ---�ڵ�������Ʒ���ڵ�����
     sum(int19),---�����ڵ���--��20170525��������ֶ�
     sum(int20),--Խ�ϲ��ڵ���
     sum(int21),--���ɱ����ڵ���
     sum(int22),--ľ�ȼ�����ڵ���
     sum(int6), ---������
     sum(num3), --��x�����۶�
     sum(num4), --��x�����۳ɱ���
     
     sum(num25),--���ܾ�����
     sum(num2),   --�����ܾ�����
     sum(int17), --δ��˶�����  ��Ʒ�� 
     sum(int3), ---�ŵ���
     sum(num7),---�ŵ����
     sum(num8),---�ŵ���ɱ���  
     sum(int23),---ľ�ȼ���ֿ��
     sum(num9),---ľ�ȼ���ֿ���
     sum(num10),---ľ�ȼ���ֿ��ɱ���
     sum(int9), --��Ʒ�ֿ��
     sum(num11),---��Ʒ�ֿ���
     sum(num12),---��Ʒ�ֿ��ɱ���
     sum(int10), --���ʲֿ��  
     sum(num13),---���ʲֿ���
     sum(num14),---���ʲֿ��ɱ���  
     sum(int11), --Խ�ϲֿ��
     sum(num15),---Խ�ϲֿ���
     sum(num16),---Խ�ϲֿ��ɱ���
     sum(int12), --�µ�ֿ��
     sum(num17),---�µ�ֿ���
     sum(num18),---�µ�ֿ��ɱ���
     sum(int13), --�˻��ֿ���
     sum(num19),---�˻��ֿ����
     sum(num20),---�˻��ֿ���ɱ���
     sum(int14), --����ֿ��
     sum(num21),---����ֿ���
     sum(num22),---����ֿ���ɱ���
     sum(int15), --�������ֿ��
     sum(num23),---�������ֿ���
     sum(num24)---�������ֿ��ɱ���
     from tmp_test3
     group by int8, ---ͳ������
       char1, --- Ʒ��
       char2, --- С��2
       char10, --����
       char11, --С��2
       date3, ---ͳ������
       char9, --��������
       char13, --��̭   
       char19, --��Ʒ
       CHAR21, ---��Ʒ״̬
       CHAR22, ---ͣ����
       char23  ---Ʒ��
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
    <TITLE>ͳ������</TITLE>
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
    <COLUMN>tmp_test1.char10</COLUMN>
    <TITLE>����</TITLE>
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
    <COLUMN>tmp_test1.char11</COLUMN>
    <TITLE>С��</TITLE>
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
tmp_test1.char23='01' then 'ľ������'
     when 
tmp_test1.char23='02' then 'MUMUSO FAMILY'
     else 'δ֪' end</COLUMN>
    <TITLE>Ʒ��</TITLE>
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
    <TITLE>��Ʒ</TITLE>
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
         when tmp_test1.char22 = '��' then
          'ͣ����'
         when tmp_test1.char13 = '��' and
              nvl(tmp_test1.int3,0) + nvl(tmp_test1.int4,0) <= 200 then
          '�ϳ���'
         when tmp_test1.char13 = '��' and
              nvl(tmp_test1.int4,0) + nvl(tmp_test1.int5,0) <= 300 then
          '��̭��'
         when tmp_test1.char13 = '��' and
              nvl(tmp_test1.int4,0) + nvl(tmp_test1.int5,0) > 300 then
          'Ԥ��̭��'
         when tmp_test1.char13 = '��' and tmp_test1.date2 is null then
          '������'
         when tmp_test1.char13 = '��' and
              trunc(sysdate) - tmp_test1.date2 <= 45 then
          '��Ʒ��'
         when tmp_test1.char13 = '��' and
              trunc(sysdate) - tmp_test1.date2 > 45 then
          '������'
       
       end</COLUMN>
    <TITLE>��������</TITLE>
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
    <TITLE>��̭</TITLE>
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
    <TITLE>��x����������</TITLE>
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
    <TITLE>��x�����۶�</TITLE>
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
    <TITLE>��x�����۳ɱ���</TITLE>
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
    <TITLE>�����ܾ�����</TITLE>
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
    <TITLE>�����ܾ�����</TITLE>
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
    <TITLE>�ŵ���</TITLE>
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
    <TITLE>�ŵ����</TITLE>
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
    <TITLE>�ŵ���ɱ���</TITLE>
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
    <TITLE>ľ�ȼ���ֿ��</TITLE>
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
    <TITLE>ľ�ȼ���ֿ����</TITLE>
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
    <TITLE>ľ�ȼ���ֿ��ɱ���</TITLE>
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
    <TITLE>��Ʒ�ֿ��</TITLE>
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
    <TITLE>��Ʒ�ֿ����</TITLE>
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
    <TITLE>��Ʒ�ֿ��ɱ���</TITLE>
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
    <TITLE>���ʲֿ��</TITLE>
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
    <TITLE>���ʲֿ����</TITLE>
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
    <TITLE>���ʲֿ��ɱ���</TITLE>
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
    <TITLE>Խ�ϲֿ��</TITLE>
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
    <TITLE>Խ�ϲֿ����</TITLE>
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
    <TITLE>Խ�ϲֿ��ɱ���</TITLE>
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
    <TITLE>�µ�ֿ��</TITLE>
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
    <TITLE>�µ�ֿ����</TITLE>
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
    <TITLE>�µ�ֿ��ɱ���</TITLE>
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
    <TITLE>�˻��ֿ���</TITLE>
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
    <TITLE>�˻��ֿ����</TITLE>
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
    <TITLE>�˻��ֿ��ɱ���</TITLE>
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
    <TITLE>����ֿ��</TITLE>
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
    <TITLE>����ֿ����</TITLE>
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
    <TITLE>����ֿ��ɱ���</TITLE>
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
    <TITLE>�������ֿ��</TITLE>
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
    <TITLE>�������ֿ����</TITLE>
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
    <TITLE>�������ֿ��ɱ���</TITLE>
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
    <TITLE>������</TITLE>
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
    <TITLE>�����ת����</TITLE>
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
    <TITLE>��Ʒ���ڵ���</TITLE>
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
    <TITLE>�����ڵ���</TITLE>
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
    <TITLE>Խ�ϲ��ڵ���</TITLE>
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
    <TITLE>���ɱ����ڵ���</TITLE>
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
    <TITLE>ľ�ȼ�����ڵ���</TITLE>
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
    <TITLE>��Ʒ��δ��˶�����</TITLE>
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
    <COLUMN>tmp_test1.date3</COLUMN>
    <TITLE>ͳ������</TITLE>
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
    <TITLE>��Ʒ״̬</TITLE>
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
tmp_test1.char23='01' then 'ľ������'
     when 
tmp_test1.char23='02' then 'MUMUSO FAMILY'
     else 'δ֪' end</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.char19</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>case
         when tmp_test1.char22 = '��' then
          'ͣ����'
         when tmp_test1.char13 = '��' and
              nvl(tmp_test1.int3,0) + nvl(tmp_test1.int4,0) <= 200 then
          '�ϳ���'
         when tmp_test1.char13 = '��' and
              nvl(tmp_test1.int4,0) + nvl(tmp_test1.int5,0) <= 300 then
          '��̭��'
         when tmp_test1.char13 = '��' and
              nvl(tmp_test1.int4,0) + nvl(tmp_test1.int5,0) > 300 then
          'Ԥ��̭��'
         when tmp_test1.char13 = '��' and tmp_test1.date2 is null then
          '������'
         when tmp_test1.char13 = '��' and
              trunc(sysdate) - tmp_test1.date2 <= 45 then
          '��Ʒ��'
         when tmp_test1.char13 = '��' and
              trunc(sysdate) - tmp_test1.date2 > 45 then
          '������'
       
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
    <COLUMN>�������ֿ��</COLUMN>
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
      <RIGHTITEM>��ͯ��Ʒ</RIGHTITEM>
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
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>��ͯ��Ʒ</SGLINEITEM>
    <SGLINEITEM>2017.06.09</SGLINEITEM>
    <SGLINEITEM>2017.06.15</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 2��</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
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
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 4��</SGLINEITEM>
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
<RPTTITLE>��Ʒ�������ͳ�Ʊ�С��(�����⣬������)</RPTTITLE>
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
<RPTLINEHEIGHT>����</RPTLINEHEIGHT>
<RPTPAGEHEIGHT>66</RPTPAGEHEIGHT>
<RPTPAGEWIDTH>80</RPTPAGEWIDTH>
<RPTTITLETYPE>0</RPTTITLETYPE>
<RPTCURREPORT></RPTCURREPORT>
<RPTREPORTLIST>
</RPTREPORTLIST>
</SQLREPORT>

