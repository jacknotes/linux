<VERSION>4.1.0</VERSION>
<SQLQUERY>
<REMARK>
[标题]

[应用背景]
用于门店营业款核对，纬度达到：日期，门店，付款方式，根据对比销售和OTTER
[结果列描述]
销售金额，取自销售表中BUSDATE的对应日期的记录。
BUSDATE的记录算法：如果交易接收的时间和实际发生日期是同一个结转期，这里记录实际的发生
日期；如果不是同一个结转期，这里记录实际的接收日期。

[必要的查询条件]

[实现方法]

[其它]
-- Create table
create global temporary table H4RTMP_JKDTL
(
  CODE       VARCHAR2(8),
  NAME       VARCHAR2(60),
  FILDATE    VARCHAR2(20),
  DCODE      VARCHAR2(30),
  CHNNAME    VARCHAR2(80),
  SCODE      VARCHAR2(20),
  SNAME      VARCHAR2(60),
  CCODE      VARCHAR2(20),
  CNAME      VARCHAR2(60),
  RTNRECEIPT VARCHAR2(60),
  TRESULT    VARCHAR2(60),
  S1         NUMBER(24,2) default 0,
  S2         NUMBER(24,2) default 0,
  S3         NUMBER(24,2) default 0,
  S4         NUMBER(24,2) default 0,
  S5         NUMBER(24,2) default 0,
  S6         NUMBER(24,2) default 0,
  ADATE      DATE,
  EMP        VARCHAR2(60)
)
on commit preserve rows;
EXEC hdcreatesynonym('H4RTMP_JKDTL');
EXEC granttoqryrole('H4RTMP_JKDTL');

-- Create table
create global temporary table H4RTMP_JKDTL_1
(
  CODE       VARCHAR2(8),
  NAME       VARCHAR2(60),
  FILDATE    VARCHAR2(20),
  DCODE      VARCHAR2(30),
  CHNNAME    VARCHAR2(80),
  SCODE      VARCHAR2(20),
  SNAME      VARCHAR2(60),
  CCODE      VARCHAR2(20),
  CNAME      VARCHAR2(60),
  RTNRECEIPT VARCHAR2(60),
  TRESULT    VARCHAR2(60),
  S1         NUMBER(24,2) default 0,
  S2         NUMBER(24,2) default 0,
  S3         NUMBER(24,2) default 0,
  S4         NUMBER(24,2) default 0,
  S5         NUMBER(24,2) default 0,
  S6         NUMBER(24,2) default 0,
  ADATE      DATE,
  EMP        VARCHAR2(60)
)
on commit preserve rows;
EXEC hdcreatesynonym('H4RTMP_JKDTL_1');
EXEC granttoqryrole('H4RTMP_JKDTL_1');


create or replace procedure h4rcalc_getstore_gdgid
  (
    storecodein     in varchar2  default '' ,
    storecodenotin     in varchar2  default '' ,
    sortcodein     in varchar2  default '' ,
    sortnamelike   in varchar2  default '' ,
    sortCodelike   in varchar2  default '' ,
    gdcodein       in varchar2  default '',
    areacodein     in varchar2  default '' ,
    areacodelike     in varchar2  default '' ,
    BIllStorein     in varchar2  default '' ,
    Billstorelike  in varchar2 default ''  ,
    gdcodelike     in varchar2  default '' ,
    vdrcodein      in varchar2  default '' ,
    vdrnamelike    in varchar2  default ''
  )
  as
     vsql  varchar2(2000);

    vp4     varchar2(3056)  ;
    vp5     varchar2(2000)  ;
    vp6     varchar2(2000)  ;
    vp7     varchar2(3056)  ;
    vp8     varchar2(2000)  ;
    vp9     varchar2(2000)  ;
    vp10   varchar2(2000)  ;
    vp11   varchar2(2000)  ;
    vp12   varchar2(2000)  ;
    vp13   varchar2(2000)  ;

 begin
     /*
    p4  := '\(4,1)'; --门店代码 在** 之中
    p5  := '\(5,1)';--类别代码 在** 之中
    p6  := '\(6,1)';--类别名称类似
    p7  := '\(7,1)';--商品代码 在** 之中
    p8  := '\(8,1)';--区域代码 在** 之中
    p9  := '\(9,1)';--结算门店代码 在** 之中
    p10 := '\(10,1)';--商品代码 类似于
    p11 := '\(11,1)';--第一供应商代码在** 之中
    p12 := '\(12,1)';--第一供应商代码类似于
    vp13 storecodenotin --排除门店
     */
      delete from H4RTMP_STOREGDWASH  ;

      vp4 := ''''||replace(storecodein,',',''',''')||'''';
      vp13 := ''''||replace(storecodenotin,',',''',''')
||'''';--排除门店

      vp5 := ''''||replace(sortcodein,',',''',''')||'''';

      vp7 := ''''||replace(gdcodein,',',''',''')||'''';
      vp8 := ''''||replace(areacodein,',',''',''')||'''';
      vp9 := ''''||replace(BIllStorein,',',''',''')||'''';
      vp11 := ''''||replace(vdrcodein,',',''',''')||'''';
      --vp12 := ''''||replace(vdrnamelike,',',''',''')||'''';
     -- 门店
     vsql := '';
     vsql := ' insert into H4RTMP_STOREGDWASH(storegid , gdgid )
                select gid , 1 from store where 1=1 ' ;

     if storecodein is not null then
        vsql := vsql ||
          ' and code in ( '|| vp4 ||' ) '  ;
     end if;

     if storecodenotin is not null then
        vsql := vsql ||
          ' and code not in ( '|| vp13 ||' ) '  ;
     end if;


     if areacodein is not null then
        vsql := vsql ||
          ' and area in ( '|| vp8 ||' ) ' ;
     end if;
     if BIllStorein is not null then
        vsql := vsql ||
          ' and Billto in (select gid from store where code in 
( '|| vp9 ||' ) )' ;
     end if;

     if Billstorelike is not null then
        vsql := vsql ||
          ' and Billto in (select gid from store where name like  
( ''%'|| trim( Billstorelike )||'%'' ) )'  ;
     end if;

     if areacodelike is not null then
        vsql := vsql ||
          ' and area in  (select code from area where name like 
( ''%'|| trim( areacodelike )||'%'') )'  ;
     end if;

     if areacodelike is not null then
        vsql := vsql ||
          ' and area in  (select code from area where name like 
( ''%'|| trim( areacodelike )||'%'') )'  ;
     end if;

     execute immediate vsql ;


     ---商品
     vsql := '';
     vsql := ' insert into H4RTMP_STOREGDWASH(storegid , gdgid )
                select 1 , gid from goodsh where 1=1 ' ;

     if sortcodein is not null then
        vsql := vsql ||
          ' and sort in ( select cscode from hdtmp_sort where 
acode = ''0000'' and ascode in ( '|| vp5 ||' ) )'  ;
     end if;

     if gdcodein is not null then
        vsql := vsql ||
          ' and code in  ( '|| vp7 ||' )'  ;
     end if;

     if sortnamelike is not null then
        vsql := vsql ||
           ' and sort in ( select cscode from hdtmp_sort where 
acode = ''0000'' asname like ( ''%'|| trim( sortnamelike )
||'%'' ) )'  ;
     end if;

     if sortCodelike is not null then
        vsql := vsql ||
           ' and sort like ('''|| trim(sortCodelike)|| '%'' )' ;
     end if ;

     if gdcodelike is not null then
        vsql := vsql ||
           ' and code like ( ''%'|| trim(gdcodelike)|| '%'' )'  
;
     end if;

     ---添加第一供应商条件
     if vdrcodein is not null then
        vsql := vsql ||
           ' and vdrgid in (select gid from vendorh where code 
in ( '|| vp11 ||' ) )'   ;
     end if;

     if vdrnamelike is not null then
        vsql := vsql ||
           ' and vdrgid in (select gid from vendorh where name 
like ( ''%'|| trim(vdrnamelike)|| '%'' ))'  ;
     end if;
     execute immediate vsql ;


 end ;
</REMARK>
<BEFORERUN>
declare
  BDate date;
  EDate date;
  VSTORECODE VARCHAR2(24);
  ADATE DATE ;
begin
  
  delete from H4RTMP_JKDTL;
  delete from H4RTMP_JKDTL_1;
  BDate := '\(1,1)';
  EDate := '\(2,1)';
  VSTORECODE := '';


  begin 

    h4rcalc_getstore_gdgid(storecodein => '' , Billstorelike => '' , 
         areacodein => '' , areacodelike => '' );
  end ;   

  --按付款方式、收银员日报 来做统计 s1 是销售金额
  insert into H4RTMP_JKDTL_1(code, name, scode, sname, fildate, ccode, cname, s1,
 s2,Emp)
select  s.code, s.name, t.code, t.name, to_char(b1.busdate, 'YYYY.MM.DD'),c.code,c.name,sum(b11.amount),0,
e.name||'['||e.code||']'
from buy1s b1,buy11s b11,currency c,workstation w,store s,store t,employeeh e
where b1.posno = b11.posno and b1.flowno = b11.flowno and abs(b11.currency) = c.code
and b11.currency <> -2
and b1.posno = w.no and b1.cashier = e.gid and w.storegid = s.gid and s.billto = t.gid
and S.CODE LIKE VSTORECODE||'%' and (b1.busdate) >= BDate  and (b1.busdate) < EDate
group by s.code, s.name, t.code, t.name, to_char(b1.busdate, 'YYYY.MM.DD'),c.code,c.name,e.name||'['||e.code||']';


  --统计Otter中的 缴款单 s2 是缴款金额
  insert into H4RTMP_JKDTL_1(code, name, scode, sname, fildate, ccode, cname, s1,
 s2,Dcode,RTNRECEIPT, S4,Adate,Emp)
  select s.code, s.name, t.code, t.name, to_char(p.thedate, 'YYYY.MM.DD'), c.code,
 c.name, 0, 
  sum(pd.amount), max(pd.bankcode),max(pd.rtnreceipt), count(1), 
to_char(p.thedate, 'YYYY.MM.DD'),p.operator
  from PS4STOREPAYMENT p, PS4STOREPAYMENTdtl pd, store s, store t, currency c
  where p.num = pd.num 
  and p.storegid = s.gid
  and pd.currency = c.code
  and s.billto = t.gid
  and p.stat in (1300,100)
  and p.thedate >= BDate
  and p.thedate < EDate
  group by s.code, s.name, t.code, t.name, to_char(p.thedate, 'YYYY.MM.DD'), 
c.code,c.name,p.operator; 
  
  ---退货 ，默认退货都是现金
  insert into H4RTMP_JKDTL_1(code, name, scode, sname, fildate, ccode, cname, s5,
 s6, Adate,Emp)
  select s.code, s.name, t.code, t.name, to_char(cs.adate, 'YYYY.MM.DD'), 
c.code, c.name, sum(cs.dt2), sum(cs.dn2), 
  to_char(cs.adate, 'YYYY.MM.DD'),cs.cashier
  from cshdrpts cs, store s, store t, currency c , workstation d
  where 1 = c.code
  and cs.posno = d.no
        and d.storegid = s.gid
  and s.billto = t.gid
  and cs.adate < EDate
  and cs.adate >= Bdate
  group by s.code, s.name, t.code, t.name, to_char(cs.adate, 'YYYY.MM.DD'), 
c.code, c.name,cs.cashier;

-------------- 合计  
  insert into H4RTMP_JKDTL(code, name, scode, sname, fildate, ccode, cname, s1, 
s2, s4, s5, s6, Dcode,RTNRECEIPT,Adate/*,Emp*/)
  select code, name, scode, sname, fildate, ccode, cname, sum(s1), sum(s2), 
max(s4), sum(s5), sum(s6), 
  max(Dcode),max(RTNRECEIPT),max(adate)/*,emp*/
  from H4RTMP_JKDTL_1
  group by code, name, scode, sname, fildate, ccode, cname/*,emp*/;
  
  update H4RTMP_JKDTL set s2 = 0 where s2 is null;
  update H4RTMP_JKDTL set s3 = s2 - s1, chnname = (select chnname from da_bank 
where code = dcode);--s3 是差异金额
  
  update H4RTMP_JKDTL set tresult = decode(sign(s3), -1, '短款', 0, '平', 
'长款');
  --update H4RTMP_JKDTL set tresult = '未填写或未确认缴款单' where adate is null;
  commit;


  
  ADATE := Bdate ;
  WHILE ADATE < EDate LOOP
    insert into H4RTMP_JKDTL(code, name, scode, sname, fildate, ccode, cname, s1,
 s2, s4, s5, s6, Dcode,RTNRECEIPT,tresult ,Adate)
     SELECT S.CODE , S.NAME , ST.CODE , ST.NAME ,  TO_CHAR(ADATE , 
'YYYY.MM.DD') , c.code, c.name, 0,0,0,0,0,'','','没有销售传回' , ADATE
      FROM STORE S , STORE ST , currency c
       WHERE S.BILLTO = ST.GID
          and c.code = 1
          and exists (select 1 from h4rtmp_storegdwash where STOREGID = S.gid)
         AND  NOT EXISTS (SELECT 1 FROM H4RTMP_JKDTL WHERE fildate = TO_CHAR(ADATE ,
 'YYYY.MM.DD') AND CODE = S.CODE)
         AND S.STAT = 0 --正常营业
        ;
    ADATE := ADATE + 1;
    commit;
  END LOOP;


END;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>H4RTMP_JKDTL</TABLE>
    <ALIAS>H4RTMP_JKDTL</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>STORE</TABLE>
    <ALIAS>STORE</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>AREA</TABLE>
    <ALIAS>AREA</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
</TABLELIST>
<JOINLIST>
  <JOINITEM>
    <LEFT>H4RTMP_JKDTL.CODE</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>STORE.CODE</RIGHT>
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
    <COLUMN>H4RTMP_JKDTL.CODE</COLUMN>
    <TITLE>门店代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>COUNT</GAGGREGATION>
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
    <COLUMN>H4RTMP_JKDTL.NAME</COLUMN>
    <TITLE>门店名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>COUNT</GAGGREGATION>
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
    <COLUMN>H4RTMP_JKDTL.emp</COLUMN>
    <TITLE>收银员</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>emp</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_JKDTL.FILDATE</COLUMN>
    <TITLE>销售日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>FILDATE</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_JKDTL.cname</COLUMN>
    <TITLE>付款方式</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>cname</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_JKDTL.S1</COLUMN>
    <TITLE>应缴款金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>S1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>#,##0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_JKDTL.S2</COLUMN>
    <TITLE>实际缴款金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>S2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>#,##0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_JKDTL.S3</COLUMN>
    <TITLE>差异</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>S3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>#,##0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_JKDTL.TRESULT</COLUMN>
    <TITLE>对账结果</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>TRESULT</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_JKDTL.S4</COLUMN>
    <TITLE>缴款次数</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>S4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_JKDTL.CHNNAME</COLUMN>
    <TITLE>银行名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>CHNNAME</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_JKDTL.rtnreceipt</COLUMN>
    <TITLE>回执单</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>rtnreceipt</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_JKDTL.scode</COLUMN>
    <TITLE>核算单位代码</TITLE>
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
    <COLUMN>H4RTMP_JKDTL.sname</COLUMN>
    <TITLE>核算单位名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sname</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_JKDTL.s5</COLUMN>
    <TITLE>退货金额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>s5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_JKDTL.s6</COLUMN>
    <TITLE>退货笔数</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>s6</COLUMNNAME>
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
    <COLUMN>AREA.NAME</COLUMN>
    <TITLE>区域名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
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
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>89</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>73</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>127</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>124</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>74</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>79</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>66</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>65</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>59</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>124</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
  <GROUPITEM>
    <COLUMN>H4RTMP_JKDTL.CODE</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>H4RTMP_JKDTL.NAME</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>H4RTMP_JKDTL.FILDATE</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>H4RTMP_JKDTL.cname</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>H4RTMP_JKDTL.TRESULT</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>H4RTMP_JKDTL.S4</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>AREA.CODE</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>AREA.NAME</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>销售日期</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
  <ORDERITEM>
    <COLUMN>门店代码</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
  <ORDERITEM>
    <COLUMN>付款方式</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>H4RTMP_JKDTL.FILDATE</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2011.11.01</RIGHTITEM>
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
    <LEFT>H4RTMP_JKDTL.FILDATE</LEFT>
    <OPERATOR><</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2011.11.02</RIGHTITEM>
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
    <LEFT>H4RTMP_JKDTL.CODE</LEFT>
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
    <LEFT>H4RTMP_JKDTL.TRESULT</LEFT>
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
    <LEFT>H4RTMP_JKDTL.sname</LEFT>
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
    <LEFT>SUM(H4RTMP_JKDTL.S3)</LEFT>
    <OPERATOR><></OPERATOR>
    <RIGHT>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>TRUE</ISHAVING>
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
    <LEFT>AREA.CODE</LEFT>
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
    <LEFT>AREA.NAME</LEFT>
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
    <LEFT>H4RTMP_JKDTL.cname</LEFT>
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
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>95</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>112</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>139</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>2011.11.01</SGLINEITEM>
    <SGLINEITEM>2011.11.02</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  或 2：</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
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
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>no</SGLINEITEM>
  </LINE>
</SG>
<CHECKLIST>
  <CAPTION>
    <CAPTIONITEM>应缴金额不等于0</CAPTIONITEM>
  </CAPTION>
  <EXPRESSION>
    <EXPRESSIONITEM>H4RTMP_JKDTL.S1 <> 0</EXPRESSIONITEM>
  </EXPRESSION>
  <CHECKED>
    <CHECKEDITEM>no</CHECKEDITEM>
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
  <DXSHOWSUMMARY>FALSE</DXSHOWSUMMARY>
  <DXSHOWPREVIEW>FALSE</DXSHOWPREVIEW>
  <DXSHOWFILTER>TRUE</DXSHOWFILTER>
  <DXPREVIEWFIELD></DXPREVIEWFIELD>
  <DXCOLORODDROW>15921906</DXCOLORODDROW>
  <DXCOLOREVENROW>12632256</DXCOLOREVENROW>
  <DXFILTERNAME>TRESULT</DXFILTERNAME>
  <DXFILTERLIST>
    <DXFILTERITEM>
      <DXFILTERVALUE>长款</DXFILTERVALUE>
      <DXFILTERCOLOR>16711680</DXFILTERCOLOR>
    </DXFILTERITEM>
    <DXFILTERITEM>
      <DXFILTERVALUE>短款</DXFILTERVALUE>
      <DXFILTERCOLOR>255</DXFILTERCOLOR>
    </DXFILTERITEM>
    <DXFILTERITEM>
      <DXFILTERVALUE>未填写或未确认缴款单</DXFILTERVALUE>
      <DXFILTERCOLOR>8421376</DXFILTERCOLOR>
    </DXFILTERITEM>
  </DXFILTERLIST>
  <DXSHOWGRIDLINE>1</DXSHOWGRIDLINE>
</DXDBGRIDITEM>
</SQLQUERY>
<SQLREPORT>
<RPTTITLE>门店缴款明细</RPTTITLE>
<RPTGROUPCOUNT>0</RPTGROUPCOUNT>
<RPTGROUPLIST>
</RPTGROUPLIST>
<RPTCOLUMNCOUNT>10</RPTCOLUMNCOUNT>
<RPTCOLUMNWIDTHLIST>
  <RPTCOLUMNWIDTHITEM>54</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>247</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>72</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>72</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>93</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>79</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>80</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>65</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>65</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>97</RPTCOLUMNWIDTHITEM>
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

