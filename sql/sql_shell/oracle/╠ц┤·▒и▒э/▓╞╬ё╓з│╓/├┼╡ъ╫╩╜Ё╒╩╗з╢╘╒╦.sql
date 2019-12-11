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
    VBGDDATE  DATE ;
    VENDDATE  DATE ;
begin
    
    delete from  h4rtmp_storealcctrluc ; 
    commit ;
    delete from  h4rtmp_storealcctrl ; 
    commit ;

    --------获得 起始截止时间
    VBGDDATE :=TO_DATE('\(1,1)' , 'YYYY.MM.DD') ;
    VENDDATE :=TO_DATE('\(2,1)' , 'YYYY.MM.DD') ;

    IF '\(1,1)' IS NULL THEN VBGDDATE := TO_DATE('2008.04.01' , 'YYYY.MM.DD'); END IF ; 

    IF '\(2,1)' IS NULL THEN VENDDATE := SYSDATE ; END IF ;
      
     
    ----------插入起始时间前一天晚上的余额 作为期初
    insert into h4rtmp_storealcctrl(storecode ,fildate ,actcls ,srccls ,srcnum ,alctotal,note,line)  ---使用 line 来作为排序 0 标示发生过程 1 标示当天晚上资金帐户余额
    select storegid , adate + 1 , actcls , to_char(adate,'yyyymmdd')||'晚上余额', 
          to_char(adate,'yyyymmdd')||'晚上余额', total , '' , - 1
     from  invstorealcctrldtl 
       WHERE ADATE = VBGDDATE - 1 ;

   ------------话费充值 ，按充值状态分组
   /* insert into h4rtmp_storealcctrluc(storegid ,fildate ,actcls , srccls ,srcnum , alctotal , teltotal , watertotal , crmtotal , flag)
    select storegid , trunc(fildate) , '普通' , '话费' ,
    to_char(fildate,'yyyymmdd')||decode( stat ,600 , '成功',900 , decode( autostat ,3 ,'充值失败',1,'待充值', decode(manualstat ,1 , '待充值')) ,910 , '失败退款','未成功')||'话费' ,
     - sum(payamount) , - sum(payamount) , 0 , 0 , 0
     from telefillup where stat >= 100 
        AND FILDATE < VENDDATE + 1
        AND FILDATE >= VBGDDATE   
      group by storegid , trunc(fildate) , 
      to_char(fildate,'yyyymmdd')||decode( stat ,600 , '成功',900 , decode( autostat ,3 ,'充值失败',1,'待充值', decode(manualstat ,1 , '待充值')) ,910 , '失败退款','未成功')||'话费'
      order by trunc(fildate);        

   ------------话费充值 ，对异常数据通过JOB返还资金
    insert into h4rtmp_storealcctrluc(storegid ,fildate ,actcls , srccls ,srcnum , alctotal , teltotal , watertotal , crmtotal , flag)
    select store  , trunc(OCRDATE) , '普通' , '话费充值失败返还' ,
    to_char(OCRDATE,'yyyymmdd')||'失败话费资金返还' ,
      sum(alctotal) ,  sum(alctotal) , 0 , 0 , 0
     from storealcctrllog where srccls = '话费充值失败返还' 
	AND OCRDATE < VENDDATE + 1
        AND OCRDATE >= VBGDDATE   
      group by store  , trunc(OCRDATE) , 
      to_char(OCRDATE,'yyyymmdd')||'失败话费资金返还' 
      ;  
                 
   ---------水费充值， 按充值状态分组   
    insert into h4rtmp_storealcctrluc(storegid ,fildate ,actcls , srccls ,srcnum , alctotal , teltotal , watertotal , crmtotal, flag)
    select storegid , trunc(fildate) , '普通' , '水费' ,
    to_char(fildate,'yyyymmdd')||decode( stat ,900, '成功', 100 ,'待充值','未成功')||'水费' ,
    -sum(payamount)  , 0 , -sum(payamount) ,0 ,0
       from watercashbill where stat >= 100
        AND FILDATE < VENDDATE + 1
        AND FILDATE >= VBGDDATE 
         group by storegid , trunc(fildate) ,
         to_char(fildate,'yyyymmdd')||decode( stat ,900, '成功' , 100 ,'待充值','未成功')||'水费' 
       order by trunc(fildate);    
  
   -------会员卡充值 
    insert into h4rtmp_storealcctrluc(storegid ,fildate ,actcls , srccls ,srcnum ,alctotal  , teltotal , watertotal , crmtotal , flag)   
    select store ,trunc(lstupdtime) ,'普通' , '会员卡' ,to_char(lstupdtime,'yyyymmdd')||'会员卡' ,  - sum(amount) , 0 , 0 , - sum(amount) ,0 
        from CRMCashStoreLog
         WHERE lstupdtime < VENDDATE + 1
         AND lstupdtime >= VBGDDATE 
      group by store , trunc(lstupdtime) ,to_char(lstupdtime,'yyyymmdd')||'会员卡'
         order by trunc(lstupdtime) ;
   */
    insert into h4rtmp_storealcctrluc(storegid ,fildate ,actcls  , srccls ,srcnum , alctotal , teltotal , watertotal , crmtotal , flag )
    select storegid , fildate , actcls , '合计' , '合计' , sum(alctotal) , sum(teltotal) , sum(watertotal) , sum(crmtotal) , 1 
     from  h4rtmp_storealcctrluc where flag = 0
      group by storegid , fildate , actcls  ;
     
    commit ;   
    -------合计到一张表里面

    
    ------------把门店缴款单和扣款单的备注显示出来
    insert into h4rtmp_storealcctrl(storecode ,fildate ,actcls ,srccls ,srcnum ,alctotal,note,line)
    select a.store , trunc(a.ocrdate) , a.actcls , a.srccls, a.srcnum  , sum(a.alctotal) , b.note , 0
    from storealcctrllog a, storealcpay b 
        where a.srcnum = b.num(+)
         and decode(a.srccls,'加盟金缴款','缴款','加盟金扣款','扣款' ,a.srccls) = b.cls(+)
         and a.srccls not in ('加盟店收款','扣减加盟金')
         AND OCRDATE < VENDDATE + 1
         AND OCRDATE >= VBGDDATE 
        group by trunc(ocrdate) , a.store , a.actcls , a.srcnum , a.srccls , b.note;    
    
    ---------对应资金扣减的明细 
    insert into h4rtmp_storealcctrl(storecode ,fildate ,actcls ,srccls ,srcnum ,alctotal,note,line)
    select storegid , fildate , actcls ,srccls ,srcnum , alctotal ,'' , 0
       from   h4rtmp_storealcctrluc where flag = 0 ;
        
    -------------------对于 1-3号，我们不是使用门店缴款单来返还门店收款单上多收款，而是直接充入资金帐户
    insert into h4rtmp_storealcctrl(storecode ,fildate ,actcls ,srccls ,srcnum ,alctotal,note,line)  ---使用 line 来作为排序 0 标示发生过程 1 标示当天晚上资金帐户余额
    select a.store , trunc(a.ocrdate) , a.actcls ,'门店收款单', a.srcnum  , sum(a.alctotal) , '门店收款单'||a.srcnum||'多收款' , 0
      from storealcctrllog a
        where a.srccls = '加盟店收款'
         AND OCRDATE < VENDDATE + 1
         AND OCRDATE >= VBGDDATE 
        group by trunc(ocrdate) , a.store , a.actcls , a.srcnum , a.srccls  ;   
     
    ----------插入每天晚上的余额 
    insert into h4rtmp_storealcctrl(storecode ,fildate ,actcls ,srccls ,srcnum ,alctotal,note,line)  ---使用 line 来作为排序 0 标示发生过程 1 标示当天晚上资金帐户余额
    select storegid , adate , actcls , to_char(adate,'yyyymmdd')||'晚上余额', 
          to_char(adate,'yyyymmdd')||'晚上余额', total , '' ,1
     from  invstorealcctrldtl
       WHERE ADATE <= VENDDATE AND ADATE >= VBGDDATE ;
                              
    ----------插入当前资金帐户余额
    insert into h4rtmp_storealcctrl(storecode ,fildate ,actcls ,srccls ,srcnum ,alctotal,note,line)  ---使用 line 来作为排序 0 标示发生过程 1 标示当天晚上资金帐户余额
    select storegid , sysdate , actcls , to_char(sysdate,'yyyymmdd')||'当前余额', 
          to_char(sysdate,'yyyymmdd')||'当前余额', total , '' ,1
     from  storealcctrldtl 
       WHERE SYSDATE < VENDDATE + 1
         AND SYSDATE >= VBGDDATE ;

    commit ;  
     -------对于总部来说资金帐户无意义
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
    <TITLE>门店代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <TITLE>门店名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
       		+ DECODE(BITAND(STORE.PROPERTY, 256), 256, 1, 0)) = 0 then '直营' 
                  else '加盟' end) </COLUMN>
    <TITLE>单位类型</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <TITLE>日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <TITLE>帐户类型</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <TITLE>来源类型</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <TITLE>来源单号</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <TITLE>资金使用情况</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alctotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>2228989</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_storealcctrl.note</COLUMN>
    <TITLE>备注</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
    <TITLE>排序标志</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
  <COLUMNWIDTHITEM>188</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>54</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>112</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>88</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>116</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>78</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>260</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>门店代码</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
  <ORDERITEM>
    <COLUMN>排序标志</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
  <ORDERITEM>
    <COLUMN>帐户类型</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
  <ORDERITEM>
    <COLUMN>日期</COLUMN>
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
    <DEFAULTVALUE>今天</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>h4rtmp_storealcctrl.fildate</LEFT>
    <OPERATOR><</OPERATOR>
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
    <DEFAULTVALUE>明天</DEFAULTVALUE>
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
  <CRITERIAWIDTHITEM>134</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>137</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>2010.06.24</SGLINEITEM>
    <SGLINEITEM>2010.06.25</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
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
  <NUMOFNEXTQRY>3</NUMOFNEXTQRY>
  <NCRITERIALIST>
    <NEXTQUERY>门店资金帐户对账_明细流水帐.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>日期大于等于</LEFT>
      <RIGHT>日期大于等于</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>日期小于等于</LEFT>
      <RIGHT>日期小于等于</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>门店代码在之中</LEFT>
      <RIGHT>门店代码</RIGHT>
    </NCRITERIAITEM>
  </NCRITERIALIST>
  <NCRITERIALIST>
    <NEXTQUERY>加盟店缴扣款报表.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>填单时间大于等于</LEFT>
      <RIGHT>日期大于等于</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>门店代码在之中</LEFT>
      <RIGHT>门店代码</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>单号在之中</LEFT>
      <RIGHT>来源单号</RIGHT>
    </NCRITERIAITEM>
  </NCRITERIALIST>
  <NCRITERIALIST>
    <NEXTQUERY>门店收款单报表.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>收款时间大于等于</LEFT>
      <RIGHT>日期</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>门店代码在之中</LEFT>
      <RIGHT>门店代码</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>收款时间小于</LEFT>
      <RIGHT>日期小于等于</RIGHT>
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
  <DXCOLORODDROW>16252902</DXCOLORODDROW>
  <DXCOLOREVENROW>15269373</DXCOLOREVENROW>
  <DXFILTERNAME></DXFILTERNAME>
  <DXFILTERLIST>
  </DXFILTERLIST>
  <DXSHOWGRIDLINE>1</DXSHOWGRIDLINE>
</DXDBGRIDITEM>
</SQLQUERY>
<SQLREPORT>
<RPTTITLE>门店资金帐户对账</RPTTITLE>
<RPTGROUPCOUNT>0</RPTGROUPCOUNT>
<RPTGROUPLIST>
</RPTGROUPLIST>
<RPTCOLUMNCOUNT>10</RPTCOLUMNCOUNT>
<RPTCOLUMNWIDTHLIST>
  <RPTCOLUMNWIDTHITEM>72</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>128</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>54</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>112</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>88</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>104</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>116</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>78</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>260</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>56</RPTCOLUMNWIDTHITEM>
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

