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
  yearNum VARCHAR2(10);
  week1   integer;
  week2   integer;

  begindate1 date;
  enddate1   date;
  begindate2 date;
  enddate2   date;
  newold VARCHAR2(10);

begin
  yearNum :=trim('\(1,1)')||'-01-01';

  week1 := trim('\(2,1)');
  week2 := trim('\(3,1)');
  
  newold:= trim('\(4,1)');

 if newold = '��' then
  
    ---��ȡ���ܿ�ʼ����ʱ�� ---
    delete tmp_test2;
    commit;
  
    insert into tmp_test2
      (INT1, DATE1, DATE2)
      WITH PARAMS AS
       (SELECT TRUNC(TO_DATE(yearNum, 'YYYY-MM-DD'), 'YYYY') AS SD FROM DUAL)
      select �ܴ�,
             case
               when ���ܵ�һ�� > sysdate then
                trunc(sysdate)
               else
                ���ܵ�һ��
             end,
             case
               when �������һ�� > sysdate then
                trunc(sysdate)
               else
                �������һ��
             end
        from (SELECT LEVEL �ܴ�,
                     DECODE(SIGN(5 - DECODE(TO_CHAR(PM.SD, 'D'),
                                            '1',
                                            '7',
                                            TO_CHAR(PM.SD, 'D'))),
                            -1,
                            NEXT_DAY(PM.SD + (LEVEL - 1) * 7, 2),
                            NEXT_DAY(PM.SD + (LEVEL - 1) * 7 - 7, 2)) ���ܵ�һ��,
                     DECODE(SIGN(5 - DECODE(TO_CHAR(PM.SD, 'D'),
                                            '1',
                                            '7',
                                            TO_CHAR(PM.SD, 'D'))),
                            -1,
                            NEXT_DAY(PM.SD + (LEVEL - 1) * 7, 2),
                            NEXT_DAY(PM.SD + (LEVEL - 1) * 7 - 7, 2)) + 6 �������һ��
                FROM DUAL D
                LEFT JOIN PARAMS PM
                  ON 1 = 1
              CONNECT BY LEVEL <= 53) zhou
       where zhou.�ܴ� = week1
          OR zhou.�ܴ� = week2;
  
    ----��ֵ���ܿ�ʼ����ʱ��----
    select date1, date2
      into begindate1, enddate1
      from tmp_test2
     where int1 = week1;
    select date1, date2
      into begindate2, enddate2
      from tmp_test2
     where int1 = week2;
  
    delete tmp_test2;
  
    insert into tmp_test2
      (date1, ---��ҵʱ��
       char1, --�ŵ�����
       char2, --�ŵ����
       int1, ---��������
       int2, ---A����������
       int3, ---B��������
       num1, ----B��������������������
       int4, ---�վ�����
       
       num2, ---A�ܺ�˰�����۶�
       num3, ---B�ܺ�˰�����۶�
       num4, ---B�ܺ�˰�����۶��������
       num5, ----�վ���˰�����۶�
       int5, ----A���ŵ꽻�ױ���
       int6, ----B���ŵ꽻�ױ���
       num6, ----B���ŵ꽻�ױ�������������
       
       num7, ----A�ܿ͵���
       num8, ----B�ܿ͵���
       num9, ----�͵�����������
       
       num10, ----A�ܿ͵���
       num11, ----B�ܿ͵���
       num12, ----�͵��ۻ�������
       int9, ----��ѯ���
       int7, -----week1
       int8 -----week2
       )
      select nvl(AA.BUSDATE, BB.BUSDATE) BUSDATE, ---��ҵʱ��
             nvl(AA.NAME, BB.NAME) NAME, ---�ŵ�����
             nvl(AA.code, BB.code) code, ---�ŵ����
             nvl(AA.days, 0) + nvl(BB.days, 0) days, ---��������
             AA.qty, ---A����������
             BB.qty, ---B����������
             case
               when nvl(AA.qty, 0) = 0 or nvl(BB.qty, 0) = 0 then
                0
               else
                ((BB.qty - AA.qty) / AA.qty) * 100
             end Rqty, ---B��������������������
             (nvl(AA.qty, 0) + nvl(BB.qty, 0)) / (nvl(AA.days, 0) +
             nvl(BB.days, 0)) DaySal, ----�վ�����
             
             AA.REALAMT, ---A�ܺ�˰�����۶�
             BB.REALAMT, ---B�ܺ�˰�����۶�
             case
               when nvl(AA.REALAMT, 0) = 0 or nvl(BB.REALAMT, 0) = 0 then
                0
               else
                ((BB.REALAMT - AA.REALAMT) / AA.REALAMT) * 100
             end RREALAMT, ---B�ܺ�˰�����۶��������
             (nvl(AA.REALAMT, 0) + nvl(BB.REALAMT, 0)) / (nvl(AA.days, 0) +
             nvl(BB.days, 0)) DaySal, ----�վ���˰�����۶�
             
             AA.buyNum, ---A���ŵ꽻�ױ���
             BB.buyNum, ---B���ŵ꽻�ױ���
             case
               when nvl(AA.buyNum, 0) = 0 or nvl(BB.buyNum, 0) = 0 then
                0
               else
                ((BB.buyNum - AA.buyNum) / AA.buyNum) * 100
             end RbuyNum, ---B���ŵ꽻�ױ�������������
             
             case
               when nvl(AA.qty, 0) = 0 or nvl(AA.buyNum, 0) = 0 then
                0
               else
                AA.qty / AA.buyNum
             end Akdl, ---A�ܿ͵���
             case
               when nvl(BB.qty, 0) = 0 or nvl(BB.buyNum, 0) = 0 then
                0
               else
                BB.qty / BB.buyNum
             end Bkdl, ---B�ܿ͵���
             case
               when case
                      when nvl(AA.qty, 0) = 0 or nvl(AA.buyNum, 0) = 0 then
                       0
                      else
                       AA.qty / AA.buyNum
                    end = 0 or case
                      when nvl(BB.qty, 0) = 0 or nvl(BB.buyNum, 0) = 0 then
                       0
                      else
                       BB.qty / BB.buyNum
                    end = 0 then
                0
               else
                ((BB.qty / BB.buyNum) - (AA.qty / AA.buyNum)) * 100 /
                (AA.qty / AA.buyNum)
             end Rkdl, -----�͵�����������
             
             case
               when nvl(AA.REALAMT, 0) = 0 or nvl(AA.buyNum, 0) = 0 then
                0
               else
                AA.REALAMT / AA.buyNum
             end Akdj, ---A�ܿ͵���
             case
               when nvl(BB.REALAMT, 0) = 0 or nvl(BB.buyNum, 0) = 0 then
                0
               else
                BB.REALAMT / BB.buyNum
             end Bkdj, ---B�ܿ͵���
             case
               when case
                      when nvl(AA.REALAMT, 0) = 0 or nvl(AA.buyNum, 0) = 0 then
                       0
                      else
                       AA.REALAMT / AA.buyNum
                    end = 0 or case
                      when nvl(BB.REALAMT, 0) = 0 or nvl(BB.buyNum, 0) = 0 then
                       0
                      else
                       BB.REALAMT / BB.buyNum
                    end = 0 then
                0
               else
                ((BB.REALAMT / BB.buyNum) - (AA.REALAMT / AA.buyNum)) * 100 /
                (AA.REALAMT / AA.buyNum)
             end Rkdj, -----�͵��ۻ�������
             substr(yearNum,0,4), -----��ѯ���
             week1, -----��A��
             week2 -----��B��
      
        from ��select store.BUSDATE, ---��ҵʱ��
             store.NAME, --�ŵ�����
             store.code, --�ŵ����
             count(distinct trunc(RCVTIME)) days, ---��������
             count(distinct flowno) buyNum, ---���ױ���
             sum(QTY) qty, ---��������  �������� /���ױ��� =�͵���
             sum(REALAMT) REALAMT ---���׽��  ���׽�� /���ױ��� =�͵���
        from BUY2S, store
       where BUY2S.RCVTIME between begindate1 and enddate1 + 1
         and substr(BUY2S.posNo, 0, 5) = store.code
       group by substr(posNo, 0, 5),
                store.BUSDATE,
                store.NAME,
                store.code�� AA
      
        full join
      
      ��select store.BUSDATE, ---��ҵʱ��
      store.NAME, --�ŵ�����
      store.code, --�ŵ����
      count(distinct trunc(RCVTIME)) days, ---��������
      count(distinct flowno) buyNum, ---���ױ���
      sum(QTY) qty, ---��������  �������� /���ױ��� =�͵���
      sum(REALAMT) REALAMT ---���׽��  ���׽�� /���ױ��� =�͵���
        from BUY2S, store
       where BUY2S.RCVTIME between begindate2 and enddate2 + 1
         and substr(BUY2S.posNo, 0, 5) = store.code
       group by substr(posNo, 0, 5),
                store.BUSDATE,
                store.NAME,
                store.code��BB
      
          on AA.code = BB.code;
  
    update tmp_test2
       set char3 = '��'
     where int1 = (select max(int1) from tmp_test2);
  
    update tmp_test2 set char3 = '��' where char3 is null;
  
    commit;
  end if;
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
</TABLELIST>
<JOINLIST>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.date1</COLUMN>
    <TITLE>��ҵʱ��</TITLE>
    <FIELDTYPE>11</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy.MM.dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char1</COLUMN>
    <TITLE>�ŵ�����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <COLUMN>tmp_test2.char2</COLUMN>
    <TITLE>�ŵ����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <COLUMN>tmp_test2.int1</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>3</FIELDTYPE>
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
    <COLUMN>tmp_test2.int2</COLUMN>
    <TITLE>A����������</TITLE>
    <FIELDTYPE>3</FIELDTYPE>
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
    <COLUMN>tmp_test2.int3</COLUMN>
    <TITLE>B����������</TITLE>
    <FIELDTYPE>3</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
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
    <COLUMN>tmp_test2.num1</COLUMN>
    <TITLE>������������������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>AVG</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00%</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.int4</COLUMN>
    <TITLE>�վ�����</TITLE>
    <FIELDTYPE>3</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>AVG</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num2</COLUMN>
    <TITLE>A�ܺ�˰�����۶�</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
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
    <COLUMN>tmp_test2.num3</COLUMN>
    <TITLE>B�ܺ�˰�����۶�</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num4</COLUMN>
    <TITLE>��˰�����۶��������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>AVG</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00%</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num5</COLUMN>
    <TITLE>�վ���˰�����۶�</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>AVG</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.int5</COLUMN>
    <TITLE>A���ŵ꽻�ױ���</TITLE>
    <FIELDTYPE>3</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.int6</COLUMN>
    <TITLE>B���ŵ꽻�ױ���</TITLE>
    <FIELDTYPE>3</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int6</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num6</COLUMN>
    <TITLE>�ŵ꽻�ױ�������������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>AVG</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num6</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00%</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num7</COLUMN>
    <TITLE>A�ܿ͵���</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>AVG</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num7</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num8</COLUMN>
    <TITLE>B�ܿ͵���</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>AVG</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num8</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num9</COLUMN>
    <TITLE>�͵�����������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>AVG</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num9</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00%</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num10</COLUMN>
    <TITLE>A�ܿ͵���</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>AVG</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num10</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num11</COLUMN>
    <TITLE>B�ܿ͵���</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>AVG</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num12</COLUMN>
    <TITLE>�͵��ۻ�������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>AVG</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num12</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00%</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.int9</COLUMN>
    <TITLE>���</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int9</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.int7</COLUMN>
    <TITLE>A��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
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
    <COLUMN>tmp_test2.int8</COLUMN>
    <TITLE>B��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
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
    <COLUMN>tmp_test2.char3</COLUMN>
    <TITLE>�����¾�</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>86</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>116</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>69</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>98</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>97</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>83</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>63</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>102</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>96</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>96</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>138</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>tmp_test2.int9</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2015</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>1</ISQUOTED>
    <PICKNAME>
      <PICKNAMEITEM>2014</PICKNAMEITEM>
      <PICKNAMEITEM>2015</PICKNAMEITEM>
      <PICKNAMEITEM>2016</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>2014</PICKVALUEITEM>
      <PICKVALUEITEM>2015</PICKVALUEITEM>
      <PICKVALUEITEM>2016</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE>2015</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test2.int7</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>20</RIGHTITEM>
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
    <DEFAULTVALUE>20</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test2.int8</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>21</RIGHTITEM>
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
    <DEFAULTVALUE>21</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test2.char3</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>��</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
      <PICKNAMEITEM>��</PICKNAMEITEM>
      <PICKNAMEITEM>��</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>��</PICKVALUEITEM>
      <PICKVALUEITEM>��</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE>��</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>2015</SGLINEITEM>
    <SGLINEITEM>20</SGLINEITEM>
    <SGLINEITEM>21</SGLINEITEM>
    <SGLINEITEM>��</SGLINEITEM>
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

