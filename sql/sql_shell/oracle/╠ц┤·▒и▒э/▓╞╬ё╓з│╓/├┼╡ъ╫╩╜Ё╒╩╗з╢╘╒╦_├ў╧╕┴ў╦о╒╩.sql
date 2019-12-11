<VERSION>4.1.0</VERSION>
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
    VBGDDATE  DATE ;
    VENDDATE  DATE ;
begin
    
    delete from  h4rtmp_storealcctrluc ; 
    commit ;
    delete from  h4rtmp_storealcctrl ; 
    commit ;

    --------��� ��ʼ��ֹʱ��
    VBGDDATE :=TO_DATE('\(1,1)' , 'YYYY.MM.DD') ;
    VENDDATE :=TO_DATE('\(2,1)' , 'YYYY.MM.DD') ;

    IF '\(1,1)' IS NULL THEN VBGDDATE := TO_DATE('2008.04.01' , 'YYYY.MM.DD'); END IF ; 

    IF '\(2,1)' IS NULL THEN VENDDATE := SYSDATE ; END IF ;
      
     
    ----------������ʼʱ��ǰһ�����ϵ���� ��Ϊ�ڳ�
    insert into h4rtmp_storealcctrl(storecode ,fildate ,actcls ,srccls ,srcnum ,alctotal,note,line)  ---ʹ�� line ����Ϊ���� 0 ��ʾ�������� 1 ��ʾ���������ʽ��ʻ����
    select storegid , adate + 1 , actcls , to_char(adate,'yyyymmdd')||'�������', 
          to_char(adate,'yyyymmdd')||'�������', total , '' , - 1
     from  invstorealcctrldtl 
       WHERE ADATE = VBGDDATE - 1 ;

  
   -------��Ա����ֵ 
    insert into h4rtmp_storealcctrluc(storegid ,fildate ,actcls , srccls ,srcnum ,alctotal  , teltotal , watertotal , crmtotal , flag)   
    select store ,lstupdtime ,'��ͨ' , '��Ա��' ,hstnum ,  - sum(amount) , 0 , 0 , - sum(amount) ,0 
        from CRMCashStoreLog
         WHERE lstupdtime < VENDDATE + 1
         AND lstupdtime >= VBGDDATE 
      group by store , lstupdtime ,hstnum;
   
    insert into h4rtmp_storealcctrluc(storegid ,fildate ,actcls  , srccls ,srcnum , alctotal , teltotal , watertotal , crmtotal , flag )
    select storegid , fildate , actcls , '�ϼ�' , '�ϼ�' , sum(alctotal) , sum(teltotal) , sum(watertotal) , sum(crmtotal) , 1 
     from  h4rtmp_storealcctrluc where flag = 0
      group by storegid , fildate , actcls  ;
    commit ;   

    -------�ϼƵ�һ�ű�����

    
    ------------���ŵ�ɿ�Ϳۿ�ı�ע��ʾ����
    insert into h4rtmp_storealcctrl(storecode ,fildate ,actcls ,srccls ,srcnum ,alctotal,note,line)
    select a.store , a.ocrdate , a.actcls , a.srccls, a.srcnum  , sum(a.alctotal) , b.note , 0
    from storealcctrllog a, storealcpay b 
        where a.srcnum = b.num(+)
         and decode(a.srccls,'���˽�ɿ�','�ɿ�','���˽�ۿ�','�ۿ�' ,a.srccls) = b.cls(+)
         and a.srccls not in ('���˵��տ�','�ۼ����˽�')
         AND OCRDATE < VENDDATE + 1
         AND OCRDATE >= VBGDDATE 
        group by ocrdate , a.store , a.actcls , a.srcnum , a.srccls , b.note;    
    
    ---------��Ӧ�ʽ�ۼ�����ϸ 
    insert into h4rtmp_storealcctrl(storecode ,fildate ,actcls ,srccls ,srcnum ,alctotal,note,line)
    select storegid , fildate , actcls ,srccls ,srcnum , alctotal ,'' , 0
       from   h4rtmp_storealcctrluc where flag = 0 ;
        
    -------------------���� 1-3�ţ����ǲ���ʹ���ŵ�ɿ�������ŵ��տ�϶��տ����ֱ�ӳ����ʽ��ʻ�
    insert into h4rtmp_storealcctrl(storecode ,fildate ,actcls ,srccls ,srcnum ,alctotal,note,line)  ---ʹ�� line ����Ϊ���� 0 ��ʾ�������� 1 ��ʾ���������ʽ��ʻ����
    select a.store , a.ocrdate , a.actcls ,'�ŵ��տ', a.srcnum  , sum(a.alctotal) , '�ŵ��տ'||a.srcnum||'���տ�' , 0
      from storealcctrllog a
        where a.srccls = '���˵��տ�'
         AND OCRDATE < VENDDATE + 1
         AND OCRDATE >= VBGDDATE 
        group by ocrdate , a.store , a.actcls , a.srcnum , a.srccls  ;   
     
    ----------����ÿ�����ϵ���� 
    insert into h4rtmp_storealcctrl(storecode ,fildate ,actcls ,srccls ,srcnum ,alctotal,note,line)  ---ʹ�� line ����Ϊ���� 0 ��ʾ�������� 1 ��ʾ���������ʽ��ʻ����
    select storegid , adate , actcls , to_char(adate,'yyyymmdd')||'�������', 
          to_char(adate,'yyyymmdd')||'�������', total , '' ,1
     from  invstorealcctrldtl
       WHERE ADATE <= VENDDATE AND ADATE >= VBGDDATE ;
                              
    ----------���뵱ǰ�ʽ��ʻ����
    insert into h4rtmp_storealcctrl(storecode ,fildate ,actcls ,srccls ,srcnum ,alctotal,note,line)  ---ʹ�� line ����Ϊ���� 0 ��ʾ�������� 1 ��ʾ���������ʽ��ʻ����
    select storegid , sysdate , actcls , to_char(sysdate,'yyyymmdd')||'��ǰ���', 
          to_char(sysdate,'yyyymmdd')||'��ǰ���', total , '' ,1
     from  storealcctrldtl 
       WHERE SYSDATE < VENDDATE + 1
         AND SYSDATE >= VBGDDATE ;

    commit ;  
     -------�����ܲ���˵�ʽ��ʻ�������
    delete from  h4rtmp_storealcctrl where storecode = 1000000;  
    commit ;
end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>h4rtmp_storealcctrl</TABLE>
    <ALIAS>h4rtmp_storealcctrl</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>STORE</TABLE>
    <ALIAS>STORE</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
</TABLELIST>
<JOINLIST>
  <JOINITEM>
    <LEFT>h4rtmp_storealcctrl.storecode</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>STORE.GID</RIGHT>
  </JOINITEM>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>STORE.CODE</COLUMN>
    <TITLE>�ŵ����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
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
    <TITLE>�ŵ�����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>NAME</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN> (case when 
                  (DECODE(BITAND(STORE.PROPERTY, 4), 4, 1, 0)
       		+ DECODE(BITAND(STORE.PROPERTY,  64),  64, 1, 0)
       		+ DECODE(BITAND(STORE.PROPERTY, 256), 256, 1, 0)) = 0 then 'ֱӪ' 
                  else '����' end) </COLUMN>
    <TITLE>��λ����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>PROPERTY</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_storealcctrl.fildate</COLUMN>
    <TITLE>����</TITLE>
    <FIELDTYPE>11</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>fildate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_storealcctrl.actcls</COLUMN>
    <TITLE>�ʻ�����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>actcls</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_storealcctrl.srccls</COLUMN>
    <TITLE>��Դ����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>srccls</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_storealcctrl.srcnum</COLUMN>
    <TITLE>��Դ����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>srcnum</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_storealcctrl.alctotal</COLUMN>
    <TITLE>�ʽ�ʹ�����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alctotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>8388863</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_storealcctrl.note</COLUMN>
    <TITLE>��ע</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>note</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_storealcctrl.line</COLUMN>
    <TITLE>�����־</TITLE>
    <FIELDTYPE>3</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>line</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>72</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>128</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>54</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>137</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>88</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>244</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>78</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>260</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>�ŵ����</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
  <ORDERITEM>
    <COLUMN>�����־</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
  <ORDERITEM>
    <COLUMN>�ʻ�����</COLUMN>
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
    <LEFT>h4rtmp_storealcctrl.fildate</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2010.06.24</RIGHTITEM>
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
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>h4rtmp_storealcctrl.fildate</LEFT>
    <OPERATOR><=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2010.06.25</RIGHTITEM>
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
    <ISREQUIRED>TRUE</ISREQUIRED>
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
    <LEFT>STORE.CODE</LEFT>
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
  <CRITERIAWIDTHITEM>89</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>119</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>119</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>2010.06.24</SGLINEITEM>
    <SGLINEITEM>2010.06.25</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
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
    <SGLINEITEM>no</SGLINEITEM>
    <SGLINEITEM>yes</SGLINEITEM>
  </LINE>
</SG>
<CHECKLIST>
  <CAPTION>
    <CAPTIONITEM>������ͬ��֤��</CAPTIONITEM>
    <CAPTIONITEM>��������ͬ��֤��</CAPTIONITEM>
  </CAPTION>
  <EXPRESSION>
    <EXPRESSIONITEM>h4rtmp_storealcctrl.actcls in ('��ͨ','������')</EXPRESSIONITEM>
    <EXPRESSIONITEM>h4rtmp_storealcctrl.actcls in ('��ͨ')</EXPRESSIONITEM>
  </EXPRESSION>
  <CHECKED>
    <CHECKEDITEM>no</CHECKEDITEM>
    <CHECKEDITEM>yes</CHECKEDITEM>
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
  <DXCOLORODDROW>15204074</DXCOLORODDROW>
  <DXCOLOREVENROW>15466463</DXCOLOREVENROW>
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
<RPTLINEHEIGHT>����</RPTLINEHEIGHT>
<RPTPAGEHEIGHT>66</RPTPAGEHEIGHT>
<RPTPAGEWIDTH>80</RPTPAGEWIDTH>
<RPTTITLETYPE>0</RPTTITLETYPE>
<RPTCURREPORT></RPTCURREPORT>
<RPTREPORTLIST>
</RPTREPORTLIST>
</SQLREPORT>

