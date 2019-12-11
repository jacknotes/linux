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
/*20170413 ������һ���ֶ� num4�����ֶ�ȡֵ����������������ġ���˰�� num3���ŵ��ۼ۽�ȡ����Ʒ���ϵĺ����ۼۣ���*/
/*20170614 ������һ���ֶ�Ʒ��*/
declare
  Bfiledate  date;
  Efiledate  date;

begin
  Bfiledate  := to_date('\(1,1)', 'yyyy.mm.dd');
  Efiledate  := to_date('\(2,1)', 'yyyy.mm.dd');  
  /*Bfiledate  := to_date('2017-6-1', 'yyyy.mm.dd');
  Efiledate  := to_date('2017-6-13', 'yyyy.mm.dd'); */  

  delete from tmp_test2;
  commit;

insert into tmp_test2
(
       char1             --����gid
      ,char2             --���
      ,char3             --����
      ,char4             --����
      ,char5             --��������
      ,char6             --�ں�
      ,char7             --�ͻ���λgid
      ,char8             --�ͻ���λ
      ,char9             --Ʒ�����
      ,char10            --Ʒ��
      ,date1             --��������
      ,num1              --��������ʵ������
      ,num2              --�ɱ���ʵ���
      ,num3              --�ۼ۽��
      ,num4              --������
      ,date2             --��������
      ,char11            --��λ��
      ,char12            --��λ
      ,char13            --���
      ,char14            --״̬
      ,date3             --��ʼ����
      ,date4             --��������
      ,char15            --��ϵ��
      ,char16            --Ʒ��
)
select store.gid                     --����gid
      ,store.code                    --���
      ,store.name                    --����
      ,stkout.num                    --����
      ,stkout.cls                    --��������
      ,stkout.settleno               --�ں�
      ,stkout.sender                 --�ͻ���λgid
      ,sdr.name                      --�ͻ���λ
      ,sort.code                     --Ʒ�����
      ,sort.name                     --Ʒ��
      ,stkoutlog.time                --��������
      ,sum(stkoutdtl.qty)            --��������ʵ������
      ,sum(stkoutdtl.CAMT+stkoutdtl.CTAX)           --�ɱ���ʵ���
   
      ,sum(stkoutdtl.CRTOTAL)          --�ۼ۽��
      ,sum(stkoutdtl.total)          --������
      ,stkout.OCRDATE                --��������
      ,stkout.wrh                    --��λ��
      ,wrh.name                      --��λ
      ,stkout.filler                 --���
      ,ms.statname                   --״̬
      ,Bfiledate                     --��ʼ����
      ,Efiledate                     --��������
      ,cli.contactor                 --�ջ���
      ,goods.brand                   --Ʒ��  20170614 ������һ���ֶ�Ʒ��
from store , stkout , stkoutdtl , stkoutlog ,store sdr ,WarehouseH wrh ,goods , sort ,ModuleStat ms , store cli
where store.gid = stkout.client
  and stkout.num = stkoutdtl.num and stkout.cls = stkoutdtl.cls
  and STKOUT.num = stkoutlog.num and STKOUT.Cls = stkoutlog.cls
  and stkoutlog.stat IN(700, 720, 740, 320, 340)       
  and stkout.sender = sdr.gid  --������λ
  and stkout.wrh = wrh.gid     --��λ
  and stkoutdtl.gdgid = goods.gid
  and substr(goods.sort , 0 , 2) = sort.code
  and stkout.stat = ms.no
  and sort.code in ('20','21','22','23','27')
  and stkout.client = cli.gid   --�ջ���ϵ��
  /*and stkout.OCRDATE between Bfiledate and Efiledate*/
  and trunc(stkoutlog.time) between Bfiledate and Efiledate
group by store.gid
        ,store.code
        ,store.name 
        ,stkout.num
        ,stkout.cls
        ,stkout.settleno
        ,stkout.sender
        ,sdr.name
        ,stkoutlog.time
        ,sort.code
        ,sort.name
        ,stkout.OCRDATE
        ,stkout.wrh
        ,wrh.name
        ,stkout.filler
        ,ms.statname 
        ,cli.contactor
        ,goods.brand                   
--order by store.code , stkout.num  

union all

select store.gid                     --����gid
      ,store.code                    --���
      ,store.name                    --����
      ,STKOUTBCK.num                    --����
      ,STKOUTBCK.cls                    --��������
      ,STKOUTBCK.settleno               --�ں�
      ,STKOUTBCK.RECEIVER                 --�ջ���λgid
      ,sdr.name                      --�ջ���λ
      ,sort.code                     --Ʒ�����
      ,sort.name                     --Ʒ��
      ,STKOUTBCKlog.time                --��������
      ,-sum(STKOUTBCKdtl.qty)            --��������ʵ������
      ,-sum(STKOUTBCKdtl.CAMT+STKOUTBCKdtl.CTAX)           --�ɱ���ʵ���
      
      ,-sum(STKOUTBCKdtl.CRTOTAL)          --�ۼ۽��
      ,-sum(STKOUTBCKdtl.total)          --������
      ,STKOUTBCK.OCRDATE                --��������
      ,STKOUTBCK.wrh                    --��λ��
      ,wrh.name                      --��λ
      ,STKOUTBCK.filler                 --���
      ,ms.statname                   --״̬
      ,Bfiledate                     --��ʼ����
      ,Efiledate                     --��������
      ,cli.contactor                 --�ջ���
      ,goods.brand                   --Ʒ��  20170614 ������һ���ֶ�Ʒ��
from store , STKOUTBCK , STKOUTBCKdtl , STKOUTBCKlog ,store sdr ,WarehouseH wrh ,goods , sort ,ModuleStat ms , store cli
where store.gid = STKOUTBCK.client
  and STKOUTBCK.num = STKOUTBCKdtl.num and STKOUTBCK.cls = STKOUTBCKdtl.cls
  and STKOUTBCK.num = STKOUTBCKlog.num and STKOUTBCK.Cls = STKOUTBCKlog.cls
  and STKOUTBCKlog.stat IN(1000, 1020, 1040, 320, 340)       
  and STKOUTBCK.RECEIVER = sdr.gid  --������λ
  and STKOUTBCK.wrh = wrh.gid     --��λ
  and STKOUTBCKdtl.gdgid = goods.gid
  and substr(goods.sort , 0 , 2) = sort.code
  and STKOUTBCK.stat = ms.no
  and sort.code in ('20','21','22','23','27')
  and STKOUTBCK.client = cli.gid   --�ջ���ϵ��
  /*and STKOUTBCK.OCRDATE between Bfiledate and Efiledate*/
  and trunc(STKOUTBCKlog.time) between Bfiledate and Efiledate
group by store.gid
        ,store.code
        ,store.name 
        ,STKOUTBCK.num
        ,STKOUTBCK.cls
        ,STKOUTBCK.settleno
        ,STKOUTBCK.RECEIVER
        ,sdr.name
        ,STKOUTBCKlog.time
        ,sort.code
        ,sort.name
        ,STKOUTBCK.OCRDATE
        ,STKOUTBCK.wrh
        ,wrh.name
        ,STKOUTBCK.filler
        ,ms.statname 
        ,cli.contactor
        ,goods.brand                 
--order by store.code , STKOUTBCK.num  

 union all

--�������
select store.gid                     --����gid
      ,store.code                    --���
      ,store.name                    --����
      ,ALCDIFF.num                    --����
      ,ALCDIFF.cls                    --��������
      ,ALCDIFF.settleno               --�ں�
      ,ALCDIFF.SENDER                 --�ջ���λgid
      ,sdr.name                      --�ջ���λ
      ,sort.code                     --Ʒ�����
      ,sort.name                     --Ʒ��
      ,ALCDIFFlog.time                --��������
      ,sum(ALCDIFFdtl.qty)            --��������ʵ������
      ,sum(ALCDIFFdtl.CAMT+ALCDIFFdtl.Ctax)           --�ɱ���ʵ���
     
      ,sum(ALCDIFFdtl.CRTOTAL)          --�ۼ۽��
      ,sum(ALCDIFFdtl.total)          --������
      ,ALCDIFF.OCRDATE                --��������
      ,ALCDIFF.STKOUTWRH                    --��λ��
      ,wrh.name                      --��λ
      ,ALCDIFF.note                 --���
      ,ms.statname                   --״̬
      ,Bfiledate                     --��ʼ����
      ,Efiledate                     --��������
      ,cli.contactor                 --�ջ���
      ,goods.brand                   --Ʒ��  20170614 ������һ���ֶ�Ʒ��
from store , ALCDIFF , ALCDIFFdtl , ALCDIFFlog ,store sdr ,WarehouseH wrh ,goods , sort ,ModuleStat ms , store cli
where store.gid = ALCDIFF.store
  and ALCDIFF.num = ALCDIFFdtl.num and ALCDIFF.cls = ALCDIFFdtl.cls
  and ALCDIFF.num = ALCDIFFlog.num and ALCDIFF.Cls = ALCDIFFlog.cls
  and ALCDIFFlog.stat IN(400, 420, 440, 320, 340)       
  and ALCDIFF.SENDER = sdr.gid  --������λ
  and ALCDIFF.STKOUTWRH = wrh.gid     --��λ
  and ALCDIFFdtl.gdgid = goods.gid
  and substr(goods.sort , 0 , 2) = sort.code
  and ALCDIFF.stat = ms.no
  and sort.code in ('20','21','22','23','27')
  and ALCDIFF.store = cli.gid   --�ջ���ϵ��
  and trunc(ALCDIFFlog.time) between Bfiledate and Efiledate
group by store.gid
        ,store.code
        ,store.name 
        ,ALCDIFF.num
        ,ALCDIFF.cls
        ,ALCDIFF.settleno
        ,ALCDIFF.SENDER
        ,sdr.name
        ,ALCDIFFlog.time
        ,sort.code
        ,sort.name
        ,ALCDIFF.OCRDATE
        ,ALCDIFF.STKOUTWRH
        ,wrh.name
        ,ALCDIFF.note  
        ,ms.statname 
        ,cli.contactor
        ,goods.brand                   
--order by store.code , ALCDIFF.num
;

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
</TABLELIST>
<JOINLIST>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char2</COLUMN>
    <TITLE>���</TITLE>
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
    <COLUMN>tmp_test2.char3</COLUMN>
    <TITLE>����</TITLE>
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
    <COLUMN>tmp_test2.char8</COLUMN>
    <TITLE>������λ</TITLE>
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
    <COLUMN>tmp_test2.char4</COLUMN>
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
    <COLUMN>tmp_test2.char5</COLUMN>
    <TITLE>��������</TITLE>
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
    <COLUMN>tmp_test2.char6</COLUMN>
    <TITLE>�ں�</TITLE>
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
    <COLUMN>
case when tmp_test2.char16='01' 
     then 'ľ������'
     
  when tmp_test2.char16='02' 
     then 'MUMUSO FAMILY'

     else 'δ֪' end
</COLUMN>
    <TITLE>Ʒ��</TITLE>
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
    <COLUMN>tmp_test2.char9</COLUMN>
    <TITLE>Ʒ�����</TITLE>
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
    <COLUMN>tmp_test2.char10</COLUMN>
    <TITLE>Ʒ��</TITLE>
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
    <COLUMN>tmp_test2.date1</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num1</COLUMN>
    <TITLE>������</TITLE>
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
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num2</COLUMN>
    <TITLE>�ɱ����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0000</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num3</COLUMN>
    <TITLE>�ۼ۽��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0000</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num4</COLUMN>
    <TITLE>������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.0000</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char1</COLUMN>
    <TITLE>����gid</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char7</COLUMN>
    <TITLE>������λgid</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char7</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.date2</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy.MM.dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char11</COLUMN>
    <TITLE>��λ��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char12</COLUMN>
    <TITLE>��λ</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char12</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char13</COLUMN>
    <TITLE>���</TITLE>
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
    <COLUMN>tmp_test2.char14</COLUMN>
    <TITLE>״̬</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char14</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.date3</COLUMN>
    <TITLE>��ʼ����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy.MM.dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.date4</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy.MM.dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char15</COLUMN>
    <TITLE>�ջ���</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char15</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>38</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>152</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>152</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>85</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>87</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>95</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>91</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>1534</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
  <GROUPITEM>
    <COLUMN>tmp_test2.char2</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char3</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char8</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char4</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char5</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char6</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>
case when tmp_test2.char16='01' 
     then 'ľ������'
     
  when tmp_test2.char16='02' 
     then 'MUMUSO FAMILY'

     else 'δ֪' end
</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char9</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char10</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.date1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.date2</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char12</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char13</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char14</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char15</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>Ʒ��</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>tmp_test2.date3</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2017.06.01</RIGHTITEM>
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
    <DEFAULTVALUE>�³�</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test2.date4</LEFT>
    <OPERATOR><=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2017.06.13</RIGHTITEM>
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
    <LEFT>tmp_test2.char2</LEFT>
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
    <LEFT>tmp_test2.char3</LEFT>
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
    <LEFT>tmp_test2.char6</LEFT>
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
    <LEFT>tmp_test2.char4</LEFT>
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
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>103</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>2017.06.01</SGLINEITEM>
    <SGLINEITEM>2017.06.13</SGLINEITEM>
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
  <NUMOFNEXTQRY>1</NUMOFNEXTQRY>
  <NCRITERIALIST>
    <NEXTQUERY>�豸�����߸�������㵥(��ϸ).sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>��ʼ���ڴ��ڵ���</LEFT>
      <RIGHT>��ʼ���ڴ��ڵ���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>��������С�ڵ���</LEFT>
      <RIGHT>��������С�ڵ���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>��ŵ���</LEFT>
      <RIGHT>��ŵ���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>����������</LEFT>
      <RIGHT>����������</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>����������</LEFT>
      <RIGHT>����������</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>�ںŵ���</LEFT>
      <RIGHT>�ںŵ���</RIGHT>
    </NCRITERIAITEM>
  </NCRITERIALIST>
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
<RPTTITLE>���㵥(����)</RPTTITLE>
<RPTGROUPCOUNT>0</RPTGROUPCOUNT>
<RPTGROUPLIST>
</RPTGROUPLIST>
<RPTCOLUMNCOUNT>16</RPTCOLUMNCOUNT>
<RPTCOLUMNWIDTHLIST>
  <RPTCOLUMNWIDTHITEM>38</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>104</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>152</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>92</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>56</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>44</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>56</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>68</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>44</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>56</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>56</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>68</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>44</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>80</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>44</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>44</RPTCOLUMNWIDTHITEM>
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

