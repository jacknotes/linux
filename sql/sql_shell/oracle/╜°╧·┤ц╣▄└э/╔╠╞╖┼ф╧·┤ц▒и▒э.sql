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
--�����޸�20170524���޳��������ݣ����н����޷��޳������۱��Ͳ����������ݣ������ŵ��潫�ڱ������㣬�ȴ����ˣ�ֻ��Ҫ��������޳������Ϳ�����
--�����޸�20170605���޳�80001������
declare
  Vdate  date;
    
begin 
  Vdate:='\(1,1)';
  --Vdate:=date'2017-5-31'; 

  delete from tmp_test2;
  commit;

  insert into tmp_test2
    (int1 --gid
    ,
     char1 --��Ʒ����
    ,
     char2 --��Ʒ����
    ,
     char5 --��Ʒ�¾�
    ,
     char3 --�������
    ,
     char4 --����
    ,
     int2 --�����ۼƽ�����
    ,
     int3 --�����ۼƽ�����
    ,
     int4 --�����ۼ�����
    ,
     int5 --�����ۼ�����
    ,
     int6 --��������
     --  ,
     --  num1 --��������
    ,
     int7 --ǰһ������
    ,
     int8 --ǰ��������
    ,
     int9 --���������
    ,
     int10 --ǰһ�������
    ,
     int11 --ǰ���������
     --    ,int12        --�ڿ�sku��
    ,
     num2 --�����
    ,
     int13 --�������
    ,
     num3 --�վ���
    ,
     int14 --������
    ,
     int15 --����������
    ,
     date1 --��ѯ����
     
     )
    select goods.gid --gid
          ,
           goods.code --��Ʒ����
          ,
           goods.name --��Ʒ����
          ,
           goods.isNew --��Ʒ����Ʒ
          ,
           h4v_goodssort.ascode --�������
          ,
           h4v_goodssort.asname --����
          ,
           nvl(AA.STKINDTLQTYMonth,0) --�����ۼƽ�����
          ,
           nvl(AA.STKINDTLQTYYear,0) --�����ۼƽ�����  
          ,
           nvl(BB.salmonthqty,0) --�����ۼ�����
          ,
           nvl(BB.salyearqty,0) --�����ۼ�����
          ,
           nvl(BB.salweekqty,0) --��������
           --    ,
           --     BB.salweekamt --��������
          ,
           nvl(BB.salweek1qty,0) --ǰһ������
          ,
           nvl(BB.salweek2qty,0) --ǰ��������
          ,
           nvl(CC.stkoutqtyweek,0) --���������
          ,
           nvl(CC.stkoutqtyweek1,0) --ǰһ�������
          ,
           nvl(CC.stkoutqtyweek2,0) --ǰ���������
           --   ,DD.kcSKU              --�ڿ�sku��
          ,
           nvl(DD.kcAmt,0) --�����
          ,
           nvl(DD.kcqty,0) --������� 
          ,
           round(nvl(BB.salweekamt,0) / 7, 2) --�����վ���
          ,
           nvl(goods.storenum,0) --������
          ,
           nvl(FF.dxstorenum,0) --����������
          ,
           Vdate --��ѯ���� 
    
      from (select * from goods where goods.sort like '1%') goods 
        
      left join h4v_goodssort
        on goods.gid = h4v_goodssort.gid
      left join ( /*�ۼƽ�����=ȡ���߼�ͬ�ɹ�����ѯ��ʵ������*/
                 select STKINDTL.Gdgid,
                         sum(case
                               when trunc(STKIN.Ocrdate) >= trunc(Vdate, 'MM') and
                                    trunc(STKIN.Ocrdate) <= Vdate then
                                STKINDTL.Qty
                             end) STKINDTLQTYMonth --�����ۼƽ�����
                        ,
                         sum(case
                               when trunc(STKIN.Ocrdate) >= trunc(Vdate, 'YYYY') and
                                    trunc(STKIN.Ocrdate) <= Vdate then
                                STKINDTL.Qty
                             end) STKINDTLQTYYear --�����ۼƽ�����               
                   from STKIN, STKINDTL
                  where STKIN.Num = STKINDTL.Num
                    and STKIN.Cls = STKINDTL.Cls
                  group by STKINDTL.Gdgid) AA
        on goods.gid = AA.Gdgid
    
      left join ( /*����*/
                 select goods.gid,
                         sum(case
                               when sdrpts.fildate >= trunc(Vdate, 'MM') and
                                    sdrpts.fildate <= Vdate then
                                (decode(sdrpts.cls,
                                        '����',
                                        1,
                                        '����',
                                        1,
                                        '�ɱ�����',
                                        0,
                                        '�ɱ�����',
                                        0,
                                        -1) * (sdrpts.qty))
                             end) salmonthqty --�����ۼ�����
                        ,
                         sum(case
                               when sdrpts.fildate >= trunc(Vdate, 'YYYY') and
                                    sdrpts.fildate <= Vdate then
                                (decode(sdrpts.cls,
                                        '����',
                                        1,
                                        '����',
                                        1,
                                        '�ɱ�����',
                                        0,
                                        '�ɱ�����',
                                        0,
                                        -1) * (sdrpts.qty))
                             end) salyearqty --�����ۼ�����
                        ,
                         sum(case
                               when sdrpts.fildate >= Vdate - 6 and
                                    sdrpts.fildate <= Vdate then
                                (decode(sdrpts.cls,
                                        '����',
                                        1,
                                        '����',
                                        1,
                                        '�ɱ�����',
                                        0,
                                        '�ɱ�����',
                                        0,
                                        -1) * (sdrpts.qty))
                             end) salweekqty --�������� 
                        ,
                         sum(case
                               when sdrpts.fildate >= Vdate - 6 and
                                    sdrpts.fildate <= Vdate then
                                (decode(sdrpts.cls,
                                        '����',
                                        1,
                                        '����',
                                        1,
                                        '�ɱ�����',
                                        0,
                                        '�ɱ�����',
                                        0,
                                        -1) * (sdrpts.amt + sdrpts.tax))
                             end) salweekamt --��������
                        ,
                         sum(case
                               when sdrpts.fildate >= Vdate - 13 and
                                    sdrpts.fildate <= Vdate - 7 then
                                (decode(sdrpts.cls,
                                        '����',
                                        1,
                                        '����',
                                        1,
                                        '�ɱ�����',
                                        0,
                                        '�ɱ�����',
                                        0,
                                        -1) * (sdrpts.qty))
                             end) salweek1qty --ǰһ������
                        ,
                         sum(case
                               when sdrpts.fildate >= Vdate - 20 and
                                    sdrpts.fildate <= Vdate - 14 then
                                (decode(sdrpts.cls,
                                        '����',
                                        1,
                                        '����',
                                        1,
                                        '�ɱ�����',
                                        0,
                                        '�ɱ�����',
                                        0,
                                        -1) * (sdrpts.qty))
                             end) salweek2qty --ǰ��������
                 
                   from sdrpts, goods
                  where sdrpts.gdgid = goods.gid
                    and sdrpts.cls in ('����',
                                       '������',
                                       '����',
                                       '������',
                                       '�ɱ�����',
                                       '�ɱ�����')
                    and goods.sort like '1%'
                    and sdrpts.snd !=(select gid from store where code=80001)--��20170605�����Ӹ�����
                  group by goods.gid) BB
        on goods.gid = BB.gid
    
      left join ( /*�����ȡ�ֿ�ʵ����*/
                 select stkoutdtl.gdgid,
                         sum(case
                               when trunc(stkout.OCRDATE) >= Vdate - 6 and
                                    trunc(stkout.OCRDATE) <= Vdate then
                                (stkoutdtl.qty)
                             end) stkoutqtyweek --���������
                        ,
                         sum(case
                               when trunc(stkout.OCRDATE) >= Vdate - 13 and
                                    trunc(stkout.OCRDATE) <= Vdate - 7 then
                                (stkoutdtl.qty)
                             end) stkoutqtyweek1 --ǰһ�������
                        ,
                         sum(case
                               when trunc(stkout.OCRDATE) >= Vdate - 20 and
                                    trunc(stkout.OCRDATE) <= Vdate - 14 then
                                (stkoutdtl.qty)
                             end) stkoutqtyweek2 --ǰ���������
                 
                   from stkoutdtl,
                         stkout,
                         (select * from stkoutlog where stat = 700 and cls='ͳ���') stkoutlog --�ѷ��� ��20170524�����Ӹ�����
                  where stkout.num = stkoutdtl.num
                    and stkout.cls = stkoutdtl.cls
                    and STKOUT.num = stkoutlog.num
                    and STKOUT.Cls = stkoutlog.cls --�ѷ���  
                    and stkoutdtl.cls='ͳ���'--��20170524�����Ӹ�����
                    and stkout.cls='ͳ���'--��20170524�����Ӹ�����
                    and stkout.client!=(select gid from store where code=80001)--��20170605�����Ӹ�����
                  group by stkoutdtl.gdgid) CC
        on goods.gid = CC.gdgid
    
      left join ( /*���SKU��*/
                  select goods.gid gdgid
                        ,h4v_goodssort.ascode 
                        ,h4v_goodssort.asname
                        /*,count(distinct (case when businvs.qty > 0 then businvs.gdgid end)) kcSKU  --�ڿ�sku��*/
                        ,sum(case when businvs.qty > 0 then (businvs.qty*goods.rtlprc) end) kcAmt  --�����
                        ,sum(case when businvs.qty > 0 then businvs.qty end) kcqty     --�������     
                  from goods
                  left join h4v_goodssort on goods.gid = h4v_goodssort.gid
                  --left join (select * from businvs where businvs.store <> '1000000') businvs ��20170524���޸�Ϊ���д��룬ȥ������Ŀ��
                  left join (select a.* from businvs  a 
         left join (select * from store where code !=80001/*��20170605���޸�*/) b on a.store=b.gid
         where (b.name not like'%���ɱ�%' and b.name not like'%����˹%'and b.name not like'%̩��%'
               and b.name  not like'%ӡ��%' and b.name not like'%Խ��%') and a.store <> '1000000') businvs--��20170524���޸�

                            on goods.gid = businvs.gdgid
                  where h4v_goodssort.ascode in ( '10','11','12','13','14','15','16','17','18','19')
                  group by goods.gid
                          ,h4v_goodssort.ascode 
                          ,h4v_goodssort.asname
                 ) DD
        on goods.gid = DD.gdgid
    
    /*      left join ( \*�̵�����ֻҪ�����״��̻�ʱ�������ݣ���Ϊ��Ʒ���̵�*\
             
             select stkoutdtl.gdgid,
                     count(distinct stkout.client) storenum
               from stkoutdtl,
                     (select * from stkoutlog where stat = 700) stkoutlog,
                     stkout,
                     store
              where stkoutdtl.num = stkoutlog.num
                and stkoutdtl.cls = stkoutlog.cls
                and stkoutdtl.num = stkout.num
                and stkoutdtl.cls = stkout.cls
                and stkoutdtl.qty > 0
                and store.stat = 0 --����Ӫҵ����
              group by stkoutdtl.gdgid) EE
    on goods.gid = EE.gdgid*/
    
      left join ( /*���������������ܲ����������ݵ��ŵ�*/
                 select goods.gid, count(distinct sdrpts.snd) dxstorenum
                   from sdrpts, goods
                  where sdrpts.gdgid = goods.gid
                    and sdrpts.cls in ('����',
                                       '������',
                                       '����',
                                       '������',
                                       '�ɱ�����',
                                       '�ɱ�����')
                    and goods.sort like '1%'
                    and sdrpts.fildate >= Vdate - 6
                    and sdrpts.fildate <= Vdate
                    and sdrpts.qty <> 0
                  group by goods.gid) FF
        on goods.gid = FF.gid;

  commit;
end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>tmp_test2</TABLE>
    <ALIAS>tmp_test2</ALIAS>
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
    <LEFT>tmp_test2.int1</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>GOODS.GID</RIGHT>
  </JOINITEM>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char3</COLUMN>
    <TITLE>�������</TITLE>
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
    <COLUMN>char4</COLUMN>
    <TITLE>����</TITLE>
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
    <COLUMN>int1</COLUMN>
    <TITLE>��Ʒgid</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>char1</COLUMN>
    <TITLE>��Ʒ����</TITLE>
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
    <COLUMN>char2</COLUMN>
    <TITLE>��Ʒ����</TITLE>
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
    <COLUMN>char5</COLUMN>
    <TITLE>�¾�</TITLE>
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
    <COLUMN>GOODS.C_FASEASON</COLUMN>
    <TITLE>����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>C_FASEASON</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>int14</COLUMN>
    <TITLE>������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int14</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>int15</COLUMN>
    <TITLE>����������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int15</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>int3</COLUMN>
    <TITLE>�����ۼƽ�����</TITLE>
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
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>int2</COLUMN>
    <TITLE>�����ۼƽ�����</TITLE>
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
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>int5</COLUMN>
    <TITLE>�����ۼ�����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>int4</COLUMN>
    <TITLE>�����ۼ�����</TITLE>
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
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>int11</COLUMN>
    <TITLE>ǰ���������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>int10</COLUMN>
    <TITLE>ǰһ�������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int10</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>int9</COLUMN>
    <TITLE>���������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int9</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>int8</COLUMN>
    <TITLE>ǰ��������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int8</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>int7</COLUMN>
    <TITLE>ǰһ������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int7</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>int6</COLUMN>
    <TITLE>��������</TITLE>
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
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>num1</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>int12</COLUMN>
    <TITLE>�ڿ�sku��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int12</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>int13</COLUMN>
    <TITLE>�ŵ�������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int13</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>num2</COLUMN>
    <TITLE>�ŵ�����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>num3</COLUMN>
    <TITLE>�����վ���</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(num3,0,0,num2/num3)</COLUMN>
    <TITLE>��ת����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>Column1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(
(nvl(int6,0)+nvl(int13,0)),0,0,
int6/(nvl(int6,0)+nvl(int13,0)))</COLUMN>
    <TITLE>������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>Column11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>date1</COLUMN>
    <TITLE>��ѯ����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy.MM.dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>165</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>212</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>107</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>94</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>110</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>108</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>115</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>118</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>105</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>103</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>94</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>103</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>106</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>103</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>89</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
  <GROUPITEM>
    <COLUMN>char3</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char4</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char2</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>char5</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>GOODS.C_FASEASON</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>int14</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>int15</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>decode(num3,0,0,num2/num3)</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>decode(
(nvl(int6,0)+nvl(int13,0)),0,0,
int6/(nvl(int6,0)+nvl(int13,0)))</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>���������</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>date1</LEFT>
    <OPERATOR><=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2017.06.04</RIGHTITEM>
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
    <DEFAULTVALUE>����</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>char3</LEFT>
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
    <LEFT>char1</LEFT>
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
    <LEFT>char2</LEFT>
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
    <LEFT>goods.c_faseason</LEFT>
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
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>2017.06.04</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
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
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 3��</SGLINEITEM>
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

