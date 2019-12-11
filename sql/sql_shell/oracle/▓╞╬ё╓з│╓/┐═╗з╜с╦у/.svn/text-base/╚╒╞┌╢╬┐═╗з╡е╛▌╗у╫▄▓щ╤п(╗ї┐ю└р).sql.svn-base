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
vbegdate date;
venddate date;
vvdrcode varchar2(50);
begin
/*
alter table H4RTMP_VDRDocuments add rcvreg int;
alter table H4RTMP_VDRDocuments add ivcreg int;
alter table H4RTMP_VDRDocuments add payreg int;
*/

  vbegdate := to_date('\(1,1)','yyyy.mm.dd');
  venddate := to_date('\(2,1)','yyyy.mm.dd');
  vvdrcode := trim('\(3,1)')||'%';

     --出货
    insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat,ivcreg,payreg)
    select s.client,'分销','分销',s.num,l.stat,trunc(l.time),s.total,s.stat,s.ivcreg,s.payreg
    from stkout s , stkoutlog l
    where s.num=l.num
      and s.cls=l.cls
      and s.cls = '批发'
      and l.stat in (700, 720, 740, 320 ,340)
      and l.time < venddate + 1
      and l.time >= vbegdate
      and s.client in (select gid from clienth where code like vvdrcode );

    --进货
    insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat,ivcreg,payreg)
    select s.Store,'分销差异','分销差异',s.num,l.stat,trunc(l.time),s.total,s.stat,s.ivcreg,s.payreg
    from ALCDIFF s , ALCDIFFlog l
    where s.num=l.num
      and s.cls=l.cls
      and s.cls = '批发差异'
      and l.stat in (100,120,140,320 ,340)
      and l.time < venddate + 1
      and l.time >= vbegdate
      and s.Store in (select gid from clienth where code like vvdrcode );

     --退货金额
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat,ivcreg,payreg)
     select s.client,'分销退','分销退',s.num,l.stat,trunc(l.time),s.total,s.stat,s.ivcreg,s.payreg
     from StkOutBck s,stkoutbcklog l
     where s.num=l.num
       and s.cls=l.cls
       and s.cls='批发退'
       and l.stat in (320,340,1000,1020,1040)
      and l.time < venddate + 1
      and l.time >= vbegdate
      and s.client in (select gid from clienth where code like vvdrcode );

     --
     update H4RTMP_VDRDocuments set rcvreg = 1 where (num,cls) in (select d.srcnum,decode(d.srccls,'批发','分销','批发差异','分销差异','批发退','分销退',d.srccls)
                                                                    from CLIENTCHKRCV m,CLIENTCHKRCVDTL d
                                                                   where m.num = d.num
                                                                     and m.stat in (0,100,1700,300));
     update H4RTMP_VDRDocuments set rcvreg = 0 where rcvreg is null and cls in ('分销','分销差异','分销退');
     update H4RTMP_VDRDocuments set rcvreg = 0 where ivcreg is null and cls in ('分销','分销差异','分销退');
     update H4RTMP_VDRDocuments set rcvreg = 0 where payreg is null and cls in ('分销','分销差异','分销退');
     --
     --已收货款
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     select a.vgid,'收款登记','货款',a.num,l.stat,trunc(l.time),a.svipaytotal+a.chkrcvtotal,a.stat
     from cpay a ,cpayLOG l
     where a.num = l.num
       and l.stat in (500,520,540)
       and l.time< venddate + 1
       and l.time>= vbegdate
       and A.vgid in (select gid from clienth where code like vvdrcode );

     --费用发生
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     SELECT c.CLIENT,'客户费用单',d.finname,c.num,l.stat,trunc(l.time),c.shouldamt*c.paydirect*-1,c.stat
     FROM CLIENTCHGBOOK c,CLIENTCHGBOOKlog l,CLTCHGDEF d
     WHERE c.num =l.num and c.chgcode = D.CODE 
      and l.STAT in (100,120,140,320,340)
      and l.time< venddate + 1
      and l.time>= vbegdate
      and c.CLIENT in (select gid from clienth where code like vvdrcode );

     --费用付款
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     select a.client,'客户收款单','客户收款单',a.num,l.stat,trunc(l.time),a.total,a.stat
       from ClientPay a,ClientPaylog l
      where a.num =l.num
      and a.cls = l.cls
      and l.stat in (900,920,940,320,340)
      and l.time< venddate + 1
      and l.time>= vbegdate
      and a.client in (select gid from clienth where code like vvdrcode );

     --费用抵扣-货款抵扣
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     select a.vgid,'收款登记','费用',a.num,l.stat,trunc(l.time),a.feepaytotal,a.stat
     from cpay a ,cpayLOG l
     where a.num = l.num
       and l.stat in (500,520,540)
       and l.time< venddate + 1
       and l.time>= vbegdate
       and A.vgid in (select gid from clienth where code like vvdrcode);
     --费用抵扣-进货抵扣？？？

     --预收收款
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     SELECT a.client,'预收收款单','预收收款单',a.num,decode(l.stat,300,1800,l.stat),trunc(l.time),a.TOTAL,a.stat
     FROM CLTPREPAY a,CLTPREPAYlog l
     WHERE a.num = l.num
       and decode(l.stat,300,1800,l.stat) in (1800,1820,1840,320,340)
       and l.time< venddate + 1
       and l.time>= vbegdate
       and A.client in (select gid from clienth where code like vvdrcode);

     --预收还款
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     SELECT a.client,'预收还款单','预收还款单',a.num,l.stat,trunc(l.time),a.TOTAL,a.stat
     FROM CLTPREPAYRTN a,CLTPREPAYRTNlog l
     WHERE a.num = l.num
       and l.stat in (900,920,940,320,340)
       and l.time< venddate + 1
       and l.time>= vbegdate
       and A.client in (select gid from clienth where code like vvdrcode) ;

     --预收使用
     insert into H4RTMP_VDRDocuments(vdrkey,cls,subject,num,ocrstat,ocrdate,total,stat)
     select a.vgid,'收款登记','预收款',a.num,l.stat,trunc(l.time),a.pretotal,a.stat
     from cpay a ,cpayLOG l
     where a.num = l.num
       and l.stat in (500,520,540)
       and l.time< venddate + 1
       and l.time>= vbegdate
       and A.vgid in (select gid from clienth where code like vvdrcode);

     commit;

end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>H4RTMP_VDRDocuments</TABLE>
    <ALIAS>H4RTMP_VDRDocuments</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD>abc</INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>MODULESTAT</TABLE>
    <ALIAS>MODULESTAT</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>MODULESTAT</TABLE>
    <ALIAS>MODULESTAT__1</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>CTCHGDEF</TABLE>
    <ALIAS>CTCHGDEF</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>CLIENTH</TABLE>
    <ALIAS>CLIENTH</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
</TABLELIST>
<JOINLIST>
  <JOINITEM>
    <LEFT>H4RTMP_VDRDocuments.vdrkey</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>CLIENTH.GID</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>MODULESTAT.NO</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>H4RTMP_VDRDocuments.ocrstat</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>MODULESTAT__1.NO</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>H4RTMP_VDRDocuments.stat</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>H4RTMP_VDRDocuments.subject</LEFT>
    <OPERATOR>*=</OPERATOR>
    <RIGHT>CTCHGDEF.CODE</RIGHT>
  </JOINITEM>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>2</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>CLIENTH.CODE</COLUMN>
    <TITLE>客户代码</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>CODE1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>CLIENTH.NAME</COLUMN>
    <TITLE>客户名称</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>NAME1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_VDRDocuments.cls</COLUMN>
    <TITLE>单据类型</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>cls</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>nvl( CTCHGDEF.NAME ,H4RTMP_VDRDocuments.subject)</COLUMN>
    <TITLE>科目</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>subject</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_VDRDocuments.num</COLUMN>
    <TITLE>单据号</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_VDRDocuments.ocrdate</COLUMN>
    <TITLE>业务发生日期</TITLE>
    <FIELDTYPE>11</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>ocrdate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>MODULESTAT.STATNAME</COLUMN>
    <TITLE>业务发生状态</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>STATNAME</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_VDRDocuments.total</COLUMN>
    <TITLE>发生金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>total</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>MODULESTAT__1.STATNAME</COLUMN>
    <TITLE>单据当前状态</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>STATNAME1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(CLIENTH.BUSTYPE,1,'分销客户',0,'普通客户','团购客户')</COLUMN>
    <TITLE>客户业务类型</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>BUSTYPE</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(H4RTMP_VDRDocuments.rcvreg,1,'是','0','否')</COLUMN>
    <TITLE>客户对帐</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>rcvreg</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(H4RTMP_VDRDocuments.ivcreg,1,'已登记',0,'未登记')</COLUMN>
    <TITLE>发票登记</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>ivcreg</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(H4RTMP_VDRDocuments.payreg,1,'收款中',2,'已收款',0,'未收款')</COLUMN>
    <TITLE>收款标记</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>payreg</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>188</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>122</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>89</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>业务发生日期</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>H4RTMP_VDRDocuments.ocrdate</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2010.09.26</RIGHTITEM>
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
    <DEFAULTVALUE>昨天</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>H4RTMP_VDRDocuments.ocrdate</LEFT>
    <OPERATOR><=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2010.11.04</RIGHTITEM>
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
    <DEFAULTVALUE>昨天</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>CLIENTH.CODE</LEFT>
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
    <LEFT>CLIENTH.NAME</LEFT>
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
    <LEFT>decode(CLIENTH.BUSTYPE,1,'分销客户',0,'普通客户','团购客户')</LEFT>
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
      <PICKNAMEITEM>分销客户</PICKNAMEITEM>
      <PICKNAMEITEM>普通客户</PICKNAMEITEM>
      <PICKNAMEITEM>团购客户</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>分销客户</PICKVALUEITEM>
      <PICKVALUEITEM>普通客户</PICKVALUEITEM>
      <PICKVALUEITEM>团购客户</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>H4RTMP_VDRDocuments.cls</LEFT>
    <OPERATOR>IN</OPERATOR>
    <RIGHT>
      <RIGHTITEM>分销,分销差异,分销退</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
      <PICKNAMEITEM>货款类</PICKNAMEITEM>
      <PICKNAMEITEM>预收款类</PICKNAMEITEM>
      <PICKNAMEITEM>费用类</PICKNAMEITEM>
      <PICKNAMEITEM>非货款类</PICKNAMEITEM>
      <PICKNAMEITEM>收款登记</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>分销,分销差异,分销退</PICKVALUEITEM>
      <PICKVALUEITEM>预收收款单,预收还款单</PICKVALUEITEM>
      <PICKVALUEITEM>客户费用单,客户收款单</PICKVALUEITEM>
      <PICKVALUEITEM>客户费用单,客户收款单,收款登记,预收收款单,预收还款单</PICKVALUEITEM>
      <PICKVALUEITEM>收款登记</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE>货款类</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>138</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>149</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>135</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>118</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>110</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>2010.09.26</SGLINEITEM>
    <SGLINEITEM>2010.11.04</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM>货款类</SGLINEITEM>
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
  <DXLOADMETHOD>FALSE</DXLOADMETHOD>
  <DXSHOWGROUP>FALSE</DXSHOWGROUP>
  <DXSHOWFOOTER>TRUE</DXSHOWFOOTER>
  <DXSHOWSUMMARY>FALSE</DXSHOWSUMMARY>
  <DXSHOWPREVIEW>FALSE</DXSHOWPREVIEW>
  <DXSHOWFILTER>FALSE</DXSHOWFILTER>
  <DXPREVIEWFIELD></DXPREVIEWFIELD>
  <DXCOLORODDROW>16777215</DXCOLORODDROW>
  <DXCOLOREVENROW>15921906</DXCOLOREVENROW>
  <DXFILTERNAME></DXFILTERNAME>
  <DXFILTERLIST>
  </DXFILTERLIST>
  <DXSHOWGRIDLINE>1</DXSHOWGRIDLINE>
</DXDBGRIDITEM>
</SQLQUERY>
<SQLREPORT>
<RPTTITLE>日期段供应商单据汇总查询</RPTTITLE>
<RPTGROUPCOUNT>0</RPTGROUPCOUNT>
<RPTGROUPLIST>
</RPTGROUPLIST>
<RPTCOLUMNCOUNT>23</RPTCOLUMNCOUNT>
<RPTCOLUMNWIDTHLIST>
  <RPTCOLUMNWIDTHITEM>90</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>170</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>97</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>92</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>79</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>109</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>101</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>103</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>89</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>88</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>104</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>92</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>101</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>90</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>105</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>89</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>102</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>106</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>109</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>85</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>80</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>87</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>90</RPTCOLUMNWIDTHITEM>
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

