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

  FBdate  date;
  FEdate  date;
  Bdate   date;
  Edate   date;

  area1 varchar(10);
begin
  FBdate:='\(1,1)';
  FEdate:='\(2,1)';
  Bdate :='\(3,1)';
  Edate :='\(4,1)';
  area1 := trim('\(5,1)');


  
delete from tmp_test2;
  commit;
  
insert into tmp_test2
(
       char1    --Ʒ�����
      ,char2    --Ʒ��
      ,char3    --�������
      ,char4    --����
      ,char5    --�������
      ,char6    --����
      ,char7    --С�����
      ,char8    --С��
      ,char9    --����
      ,char10   --����
      ,char11   --����
      ,num1     --��������
      ,int1     --��������
      ,num2     --��������
      ,int2     --��������
      
      ,int4     --�ŵ���
      ,int5     ---�ŵ�sku��
      
      ,date1                      --���ܲ�ѯ��ʼʱ��
      ,date2                      --���ܲ�ѯ����ʱ��
      ,date3                      --���ܲ�ѯ��ʼʱ��
      ,date4                      --���ܲ�ѯ����ʱ��
      
       
)
select h4v_goodssort.ascode       --Ʒ�����
      ,h4v_goodssort.asname       --Ʒ��
      ,h4v_goodssort.bscode       --�������
      ,h4v_goodssort.bsname       --����
      ,h4v_goodssort.cscode       --�������
      ,h4v_goodssort.csname       --����
      ,h4v_goodssort.dscode       --С�����
      ,h4v_goodssort.dsname       --С��
      ,goods.c_faseason           --����
      ,AA.area                    --����
      ,AA.name areaN              ---��������    
      ,sum(AA.Fweekamt)                --��������
      ,sum(AA.Fweekqty)                --��������
      ,sum(AA.weekamt)                 --��������
      ,sum(AA.weekqty)                 --��������
      
      ,sum(BB.Qty)                ---�ŵ���  
      ,count(distinct goods.gid)  ---�ŵ�sku��
      
      ,FBdate   --���ܲ�ѯ��ʼʱ��
      ,FEdate   --���ܲ�ѯ����ʱ��
      ,Bdate    --���ܲ�ѯ��ʼʱ��
      ,Edate    --���ܲ�ѯ����ʱ��
      
      
from (select * from goods where substr(goods.sort, 0, 2) like '1%' )goods
left join h4v_goodssort on  goods.gid = h4v_goodssort.gid

left join
(/*����*/
select goods.gid
      ,store.area
      ,area.name
      ,sum(case when sdrpts.fildate>=FBdate and sdrpts.fildate<=FEdate then (decode(sdrpts.cls,'����',1,'����',1,'�ɱ�����',0,'�ɱ�����',0,-1)*(sdrpts.amt+sdrpts.tax)) end) Fweekamt  
      ,sum(case when sdrpts.fildate>=FBdate and sdrpts.fildate<=FEdate then (decode(sdrpts.cls,'����',1,'����',1,'�ɱ�����',0,'�ɱ�����',0,-1)*(sdrpts.qty)) end) Fweekqty 
      ,sum(case when sdrpts.fildate>=Bdate and sdrpts.fildate<=Edate then (decode(sdrpts.cls,'����',1,'����',1,'�ɱ�����',0,'�ɱ�����',0,-1)*(sdrpts.amt+sdrpts.tax)) end) weekamt 
      ,sum(case when sdrpts.fildate>=Bdate and sdrpts.fildate<=Edate then (decode(sdrpts.cls,'����',1,'����',1,'�ɱ�����',0,'�ɱ�����',0,-1)*(sdrpts.qty)) end) weekqty 
      
  from sdrpts ,goods ,store,area
 where sdrpts.gdgid=goods.gid
   and sdrpts.cls in ( '����','������','����','������','�ɱ�����','�ɱ�����')
   and substr(goods.sort, 0, 2) like '1%'
   and sdrpts.snd=store.gid
   and store.area=area.code
group by goods.gid ,store.area,area.name ) AA on goods.gid=AA.gid


left join
(/*�ŵ���*/
select businv.GDGID
      ,store.area
     -- ,store.PROVINCE
      ,sum(businv.QTY) Qty
  from businv ,store
 where businv.STORE=store.gid
     and businv.STORE!=1000000

group by businv.GDGID ,store.area ) BB on goods.gid=BB.GDGID
and AA.area=BB.area

where AA.Fweekqty>0 or AA.weekqty>0 or BB.Qty>0


       
group by h4v_goodssort.ascode       
        ,h4v_goodssort.asname       
        ,h4v_goodssort.bscode       
        ,h4v_goodssort.bsname       
        ,h4v_goodssort.cscode      
        ,h4v_goodssort.csname       
        ,h4v_goodssort.dscode       
        ,h4v_goodssort.dsname  
        ,AA.area 
        ,AA.name     
        ,goods.c_faseason       ;
        
commit;


    delete from tmp_test1;
  commit;

  insert into tmp_test1
    (char1, ----С���
     int1,   ----�ֿܲ��
     char2   ----����
     )
   select goods.sort, sum(Qty) CQty,goods.c_faseason
             from goods, businv
            where goods.gid = businv.GDGID
              and  businv.WRH = 1000020
            group by goods.sort,goods.c_faseason;
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
    <TABLE>tmp_test1</TABLE>
    <ALIAS>tmp_test1</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
</TABLELIST>
<JOINLIST>
  <JOINITEM>
    <LEFT>tmp_test2.char7</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>tmp_test1.char1</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>tmp_test2.char9</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>tmp_test1.char2</RIGHT>
  </JOINITEM>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char11</COLUMN>
    <TITLE>����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>0</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char9</COLUMN>
    <TITLE>����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>char9</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char1</COLUMN>
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
    <COLUMN>tmp_test2.char2</COLUMN>
    <TITLE>Ʒ����</TITLE>
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
    <COLUMN>tmp_test2.char8</COLUMN>
    <TITLE>С��2</TITLE>
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
    <COLUMN>tmp_test2.int5</COLUMN>
    <TITLE>SKU��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
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
    <COLUMN>tmp_test2.int1</COLUMN>
    <TITLE>������������</TITLE>
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
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.num1</COLUMN>
    <TITLE>�������۽��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.int2</COLUMN>
    <TITLE>������������</TITLE>
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
    <COLUMN>tmp_test2.num2</COLUMN>
    <TITLE>�������۽��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>tmp_test2.int4</COLUMN>
    <TITLE>�ŵ���</TITLE>
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
    <COLUMN>tmp_test1.int1</COLUMN>
    <TITLE>�ֿܲ��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>int11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(tmp_test2.int1,0,0,(tmp_test2.int2-tmp_test2.int1)*100/tmp_test2.int1)</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00%</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(tmp_test2.num1,0,0,(tmp_test2.num2-tmp_test2.num1)*100/tmp_test2.num1)</COLUMN>
    <TITLE>���۶��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00%</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>decode((select sum(num2) from tmp_test2 t where t.char10=tmp_test2.char10),0,0,
 tmp_test2.num2*100/(select sum(num2) from tmp_test2 t where t.char10=tmp_test2.char10)
)</COLUMN>
    <TITLE>�������۶�ռ��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00%</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.date1</COLUMN>
    <TITLE>���ܿ�ʼ����</TITLE>
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
    <COLUMN>tmp_test2.date2</COLUMN>
    <TITLE>���ܽ�������</TITLE>
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
    <COLUMN>tmp_test2.date3</COLUMN>
    <TITLE>���ܿ�ʼ����</TITLE>
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
    <COLUMN>tmp_test2.date4</COLUMN>
    <TITLE>���ܽ�������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>62</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>98</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>84</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>136</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>129</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>152</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>87</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>106</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>141</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
  <GROUPITEM>
    <COLUMN>tmp_test2.char11</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char9</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char2</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.char8</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test2.int5</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>tmp_test1.int1</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>decode(tmp_test2.int1,0,0,(tmp_test2.int2-tmp_test2.int1)*100/tmp_test2.int1)</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>decode(tmp_test2.num1,0,0,(tmp_test2.num2-tmp_test2.num1)*100/tmp_test2.num1)</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>Ʒ��</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
  <ORDERITEM>
    <COLUMN>����</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
  <ORDERITEM>
    <COLUMN>����</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>tmp_test2.date1</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2016.02.25</RIGHTITEM>
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
    <DEFAULTVALUE>ǰ14��</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test2.date2</LEFT>
    <OPERATOR><=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2016.03.02</RIGHTITEM>
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
    <DEFAULTVALUE>ǰ8��</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test2.date3</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2016.03.03</RIGHTITEM>
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
    <LEFT>tmp_test2.date4</LEFT>
    <OPERATOR><=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2016.03.09</RIGHTITEM>
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
    <LEFT>tmp_test2.char11</LEFT>
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
      <PICKNAMEITEM>name1</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>select '['||code||']'||name name1,name from area</PICKVALUEITEM>
      <PICKVALUEITEM>name</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE>[-]</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>tmp_test2.char1</LEFT>
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
      <PICKNAMEITEM>'['||CODE||']'||NAME</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>select CODE, '['||CODE||']'||NAME from sort where length(code)=2 and code like '1%' order by code
</PICKVALUEITEM>
      <PICKVALUEITEM>CODE</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>121</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>96</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>2016.02.25</SGLINEITEM>
    <SGLINEITEM>2016.03.02</SGLINEITEM>
    <SGLINEITEM>2016.03.03</SGLINEITEM>
    <SGLINEITEM>2016.03.09</SGLINEITEM>
    <SGLINEITEM>[-]</SGLINEITEM>
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
<RPTLINEHEIGHT>����</RPTLINEHEIGHT>
<RPTPAGEHEIGHT>66</RPTPAGEHEIGHT>
<RPTPAGEWIDTH>80</RPTPAGEWIDTH>
<RPTTITLETYPE>0</RPTTITLETYPE>
<RPTCURREPORT></RPTCURREPORT>
<RPTREPORTLIST>
</RPTREPORTLIST>
</SQLREPORT>

