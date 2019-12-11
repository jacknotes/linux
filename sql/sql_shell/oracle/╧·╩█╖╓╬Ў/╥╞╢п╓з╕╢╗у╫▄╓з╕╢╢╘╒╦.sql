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
--根据实际情况创建dblink
/*create database link POS_POLY.REGRESS.RDBMS.DEV.US.ORACLE.COM
  connect to polyservice identified by polyservice
  using '(DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.30.171)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = poly)
    )
  )';
--创建对应表视图
create view weixinpayrecord as select * from weixinpayrecord@pos_poly ;
begin
granttoqryrole('weixinpayrecord');
hdcreatesynonym('weixinpayrecord');
end;
*/
/*create global temporary table h4rtmp_alipaycheckline_2
(
       scode  varchar2(20),
       sname  varchar2(50),
       amount number(24,4),
       suuid  varchar2(64),
       targetnum  varchar2(64),
       type   varchar2(40)
)
on commit preserve rows; 

create global temporary table h4rtmp_alipaycheckline_1
( 
       posno  varchar2(40),
       flowno varchar2(40),
       scode  varchar2(20),
       sname  varchar2(50),
       amount number(24,4),
       suuid  varchar2(64),
       type   varchar2(20)
)
on commit preserve rows; 

create global temporary table h4rtmp_alipaycheckline
(  
       bdate  date,
       edate  date,
       scode  varchar2(20),
       sname  varchar2(50),
       posno  varchar2(40),
       flowno varchar2(40),
       amount1 number(24,4),
       amount2 number(24,4),
       targetnum  varchar2(40),
       type     varchar2(40),
       diffamount     number(24,4)
)
on commit preserve rows;


begin
granttoqryrole('h4rtmp_alipaycheckline_1');
hdcreatesynonym('h4rtmp_alipaycheckline_1');
end;

begin
granttoqryrole('h4rtmp_alipaycheckline_2');
hdcreatesynonym('h4rtmp_alipaycheckline_2');
end;

begin
granttoqryrole('h4rtmp_alipaycheckline');
hdcreatesynonym('h4rtmp_alipaycheckline');
end;
*/

--select * from cloudpayorder;

declare
   vbdate  date;
   vedate  date;
   vscode  varchar2(50);
   vflowno varchar2(50);
   vcode   varchar2(20);
   vflag   varchar2(20);
begin
  vbdate:=to_date('\(1,1)','yyyy.mm.dd');
  vedate:=to_date('\(2,1)','yyyy.mm.dd');
  --vbdate:=trunc(sysdate)-1;
  --vedate:=trunc(sysdate);
  vscode:=('\(3,1)');
 -- vflowno:= ('\(4,1)');
  delete from h4rtmp_alipaycheckline;
  delete from h4rtmp_alipaycheckline_1;
  delete from h4rtmp_alipaycheckline_2;
  commit;

  vflag:=1;
  --先取鼎付通的数据
  begin
    select code into vcode from currency where name like '%移动支付%';
  exception when no_data_found then
    vflag:=0;
    RAISE_APPLICATION_ERROR(-20002, '没有名为鼎力云支付或鼎付通的付款方式');
  end;

  if vflag=1 then

  
  --select code into vcode from currency where name like '%微信支付%';
  insert into h4rtmp_alipaycheckline_2(scode,sname,amount,suuid,targetnum,type)
  select s.code,s.name,r.amount,r.uuid,r.payno,paychannel from cloudpayorder r,store s
  where  r.state = 1
  and  r.storeno(+) =  s.code
  and  (r.fildate >= vbdate)
  and  (r.fildate < vedate)
  and  not exists (select 1 from cloudpayorder w where w.ORDERNUMBER = r.ORDERNUMBER and w.state=5)
  --and  (r.common3='hdpay')
  --and  not exists (select 1 from weixinpayrecord w where w.storeordnum = r.storeordnum and w.billstate='冲正成功')
  and  (s.code = vscode or vscode is null);

 insert into h4rtmp_alipaycheckline_1(posno,flowno,scode,sname,amount,suuid,type)
  select  b1.posno,b1.flowno,s.code,s.name,sum(b11.amount) amount,
       substr(b11.cardcode,instr(b11.cardcode,'|','1','2')+1,length(b11.cardcode)-instr(b11.cardcode,'|','1','2')) suuid,b11.platformflag
       from buy11s b11,workstation w,buy1s b1,store s
       where w.no = b1.posno
       and b1.posno = b11.posno
       and b1.flowno = b11.flowno
       and (b11.platformflag) is not null
       and w.storegid = s.gid
       and b11.currency = vcode --此处修改对应的付款方式
        --and (b1.fildate >= '2016.03.07') --or vbdate is null)
        --and (b1.fildate < '2016.03.08') --or vedate is null)
       and (b1.fildate >= vbdate)
       and (b1.fildate < vedate)
       and (s.code = vscode  or  vscode is null)
       and (b1.flowno = vflowno or vflowno is null)
       group by b1.posno,b1.flowno,w.storegid,s.code,s.name,b11.currency,b11.platformflag,
       substr(b11.cardcode,instr(b11.cardcode,'|','1','2')+1,length(b11.cardcode)-instr(b11.cardcode,'|','1','2'))
       having sum(b11.amount) > 0;
   
  --删除冲账的原单 --冲账不考虑先
   delete from h4rtmp_alipaycheckline_1 s where exists
        ( select 1  from buy1s b1,buy11s b2,workstation w, store s2
       where b1.posno  = b2.posno
        and  b1.flowno = b2.flowno
        and b2.currency = vcode
        and b2.amount < 0 
        and w.no = b1.posno
        and w.storegid = s2.gid
        --and (b2.platformflag)='weiXin'
        --and (b1.fildate >= '2016.03.07') --or vbdate is null)
        --and (b1.fildate < '2016.03.08') --or vedate is null)
        and (b1.fildate >= vbdate )
        and (b1.fildate < vedate )
        and (s2.code = vscode  or  vscode is null)
        and (b1.flowno = vflowno or vflowno is null)
        and s.posno = b1.posno
        and s.flowno = SUBSTR(b1.memo,-12,12));
   

  insert into h4rtmp_alipaycheckline(bdate,edate,scode,sname,posno,flowno,amount1,amount2,targetnum,type,flag)
         select vbdate,vedate-1,nvl(b.scode,a.scode),nvl(b.sname,a.sname),a.posno,a.flowno,nvl(a.amount,'0'),nvl(b.amount,'0'),b.targetnum,b.type,nvl(a.amount,'0')-nvl(b.amount,'0')
         from h4rtmp_alipaycheckline_1 a full outer join h4rtmp_alipaycheckline_2 b on a.suuid = b.targetnum;
  end if;
  commit;        
end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>h4rtmp_alipaycheckline</TABLE>
    <ALIAS>h4rtmp_alipaycheckline</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>AREA</TABLE>
    <ALIAS>AREA</ALIAS>
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
    <LEFT>STORE.CODE</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>h4rtmp_alipaycheckline.scode</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>STORE.AREA</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>AREA.CODE</RIGHT>
  </JOINITEM>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(h4rtmp_alipaycheckline.type,'aliPay','支付宝','weiXin','微信支付','nbPay','创新户联','wjika','万集卡','bestPay','翼支付',
'qqPay','手Q支付','unionPay','银联钱包','baiduWallet','百度钱包','未知')</COLUMN>
    <TITLE>渠道类型</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>type</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_alipaycheckline.scode</COLUMN>
    <TITLE>门店代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>scode</COLUMNNAME>
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
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>NAME1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>AREA.CODE</COLUMN>
    <TITLE>区域代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>CODE</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>AREA.NAME</COLUMN>
    <TITLE>区域名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>NAME</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_alipaycheckline.posno</COLUMN>
    <TITLE>收银机号</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>posno</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_alipaycheckline.flowno</COLUMN>
    <TITLE>流水号</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>flowno</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>h4rtmp_alipaycheckline.amount1</COLUMN>
    <TITLE>pos金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>amount1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>h4rtmp_alipaycheckline.amount2</COLUMN>
    <TITLE>平台金额</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>amount2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>count(h4rtmp_alipaycheckline.amount1)</COLUMN>
    <TITLE>交易笔数</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>amount12</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_alipaycheckline.targetnum</COLUMN>
    <TITLE>渠道单号</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>targetnum</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_alipaycheckline.bdate</COLUMN>
    <TITLE>开始日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>bdate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_alipaycheckline.edate</COLUMN>
    <TITLE>结束日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>edate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(h4rtmp_alipaycheckline.flag,'0','平','不平')</COLUMN>
    <TITLE>对账平衡</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>flag</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(SUM(amount1-amount2),0,'平','不平')</COLUMN>
    <TITLE>对账结果</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>flag1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>50</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
  <GROUPITEM>
    <COLUMN>decode(h4rtmp_alipaycheckline.type,'aliPay','支付宝','weiXin','微信支付','nbPay','创新户联','wjika','万集卡','bestPay','翼支付',
'qqPay','手Q支付','unionPay','银联钱包','baiduWallet','百度钱包','未知')</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>h4rtmp_alipaycheckline.bdate</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2016.05.18</RIGHTITEM>
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
    <LEFT>h4rtmp_alipaycheckline.edate</LEFT>
    <OPERATOR><</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2016.05.20</RIGHTITEM>
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
    <LEFT>h4rtmp_alipaycheckline.scode</LEFT>
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
    <LEFT>decode(h4rtmp_alipaycheckline.type,'aliPay','支付宝','weiXin','微信支付','nbPay','创新户联','wjika','万集卡','bestPay','翼支付',
'qqPay','手Q支付','unionPay','银联钱包','baiduWallet','百度钱包','未知')</LEFT>
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
      <PICKNAMEITEM>支付宝</PICKNAMEITEM>
      <PICKNAMEITEM>微信支付</PICKNAMEITEM>
      <PICKNAMEITEM>创新户联</PICKNAMEITEM>
      <PICKNAMEITEM>万集卡</PICKNAMEITEM>
      <PICKNAMEITEM>翼支付</PICKNAMEITEM>
      <PICKNAMEITEM>手Q支付</PICKNAMEITEM>
      <PICKNAMEITEM>银联钱包</PICKNAMEITEM>
      <PICKNAMEITEM>百度钱包</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>支付宝</PICKVALUEITEM>
      <PICKVALUEITEM>微信支付</PICKVALUEITEM>
      <PICKVALUEITEM>创新户联</PICKVALUEITEM>
      <PICKVALUEITEM>万集卡</PICKVALUEITEM>
      <PICKVALUEITEM>翼支付</PICKVALUEITEM>
      <PICKVALUEITEM>手Q支付</PICKVALUEITEM>
      <PICKVALUEITEM>银联钱包</PICKVALUEITEM>
      <PICKVALUEITEM>百度钱包</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE></DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>64</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>2016.05.18</SGLINEITEM>
    <SGLINEITEM>2016.05.20</SGLINEITEM>
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
  <DXFILTERNAME>flag</DXFILTERNAME>
  <DXFILTERTYPE>STRING</DXFILTERTYPE>
  <DXFILTERLIST>
    <DXFILTERITEM>
      <DXFILTEROPERATOR>'='</DXFILTEROPERATOR>
      <DXFILTERVALUE>不平</DXFILTERVALUE>
      <DXFILTERCOLOR>255</DXFILTERCOLOR>
    </DXFILTERITEM>
  </DXFILTERLIST>
  <DXSHOWGRIDLINE>1</DXSHOWGRIDLINE>
</DXDBGRIDITEM>
</SQLQUERY>
<SQLREPORT>
<RPTTITLE>微信支付明细对账报表NEW2</RPTTITLE>
<RPTGROUPCOUNT>0</RPTGROUPCOUNT>
<RPTGROUPLIST>
</RPTGROUPLIST>
<RPTCOLUMNCOUNT>9</RPTCOLUMNCOUNT>
<RPTCOLUMNWIDTHLIST>
  <RPTCOLUMNWIDTHITEM>56</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>98</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>56</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>80</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>80</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>68</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>176</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>68</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>64</RPTCOLUMNWIDTHITEM>
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

