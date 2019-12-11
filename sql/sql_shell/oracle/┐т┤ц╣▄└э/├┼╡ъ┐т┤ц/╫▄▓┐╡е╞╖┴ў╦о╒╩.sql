<VERSION>4.1.1</VERSION>
<SQLQUERY>
<REMARK>
[标题]
总部单品流水帐
[应用背景]
查询单品在查询周期内的流水帐
[结果列描述]

[必要的查询条件]
期初库存期号：必填
商品代码：必填
仓位代码：必填
[实现方法]
[临时表结构]：
create global temporary table h4RTMP_DCGDFLOW
(
  WRH        NUMBER,
  SETTLENO   NUMBER,
  FILDATE    DATE,
  CLS        VARCHAR2(14),
  NUM        VARCHAR2(14),
  CLIENT     VARCHAR2(80),
  CLIENTCODE VARCHAR2(80),
  CLIENTNAME VARCHAR2(80),
  GDCODE     VARCHAR2(13),
  INQTY      NUMBER(24,4),
  OUTQTY     NUMBER(24,4),
  INAMT      NUMBER(24,2),
  OUTAMT     NUMBER(24,2),
  TOTAL      NUMBER(24,2),
  BALQTY     NUMBER(24,4),
  BALAMT     NUMBER(24,2)
)
ON COMMIT PRESERVE ROWS;
EXEC HDCREATESYNONYM('H4RTMP_DCGDFLOW');
EXEC GRANTTOQRYROLE('H4RTMP_DCGDFLOW');
[版本记录]：
--20100328/HEADING
--2O101003/LINING
增加 配方成本转移单商品流水帐
israw='0'，商品数量计入数量（+）
israw='1' 商品数量计入数量（-）
--2O101015/LINING 
调拨单同一商品多条记录合并。
[其它]
</REMARK>
<BEFORERUN>
declare 
        asettleno    NUMERIC(38) default 0;
        vgdcode      varchar2(100);
        vwrhcode     varchar2(100);
        preSettle    int;
        astore       int;
        Gd_Gid       int;
        awrh         int;
        t_InQty      NUMERIC(24,2) default 0;
        t_OutQty     NUMERIC(24,2) default 0;
        t_Date       Date;
        t_Cls        varchar2(20);
        t_Num        varchar2(14);
        t_BalQty     NUMERIC(24,2) default 0;
        t_InAmt      NUMERIC(24,2) default 0;
        t_OutAmt     numeric(24,2) default 0;
        t_BalAmt     NUMERIC(24,2) default 0;
        fromdate     date;
        adate        date;
        cursor  c1 is
        select FilDate, Cls, num, InQty, OutQty, InAmt, OutAmt from h4RTMP_DCGDFLOW order by FilDate;
        
begin
        delete from h4RTMP_DCGDFLOW ;
        asettleno := '\(1,1)';
        vgdcode := '\(2,1)';
        vwrhcode :=  '\(3,1)';
        select gdinput.gid into Gd_Gid from gdinput where gdinput.code= vgdcode;

        select gid into awrh from warehouse where code = vwrhcode;

        select startdate into fromdate from monthsettle where no=asettleno;
        select max(no) into preSettle from monthsettle where no < aSettleno;

        
        insert into h4RTMP_DCGDFLOW(wrh, Settleno,fildate, Cls,GdCode,GDGID, BalQty, 
Total, BalAmt)
        (select vwrhcode,asettleno, fromdate, '期初',vgdcode,Gd_Gid, 
        nvl(sum(nvl(invmrpt.qty,0)),0), nvl(sum(nvl(invmrpt.Rtotal,0)),0),
    sum(nvl(invmrpt.iamt,0))
        from invmrpt
        where invmrpt.settleno = preSettle
        and invmrpt.gdgid = Gd_gid
        and invmrpt.wrh = awrh );
        
    
        insert into h4RTMP_DCGDFLOW(wrh, Settleno, FilDate, Cls, 
                 Num, clientcode,clientname,GdCode,GDGID, InQty, InAmt, Total,BalQty, BalAmt)
        (select vwrhcode,asettleno, l.time, decode(a.cls, '自营进','自营进'),
        a.Num,v.code,v.name,vgdcode,Gd_Gid, sum(b.Qty + B.LOSS), 
Sum(b.Total - b.tax), Sum(b.Total), 0, 0
        from Stkin a, StkinDtl b, stkinlog l,vendor v
        where a.Cls = b.Cls 
        and a.Num = b.Num
        and a.cls = l.cls
        and a.num = l.num
        and l.stat in (320,340,1000,1020,1040)
        and b.gdgid = Gd_Gid
        and l.time > fromdate
        and b.wrh = awrh
        and v.gid=a.vendor
        group by l.time, a.CLS, a.NUM,v.name,v.code);
        
        
      insert into h4RTMP_DCGDFLOW(wrh, Settleno, FilDate, Cls, 
                 Num, clientcode,clientname,GdCode,GDGID, InQty, InAmt, Total,BalQty, BalAmt)
        (select vwrhcode,asettleno, l.time, decode(a.cls, '成本转移','成本转移-产品'),
        a.Num,v.code,v.name,vgdcode,Gd_Gid, sum(b.Qty ), 
Sum(b.Total - b.tax), Sum(b.Total), 0, 0
        from Process a, ProcDtl b, Processlog l,store v
      where
        b.israw='0'
        and a.Cls = b.Cls 
        and a.Num = b.Num
        and a.cls = l.cls
        and a.num = l.num
        and l.stat in (100)
        and b.gdgid = Gd_Gid
        and l.time > fromdate
        and a.RAWWRH = awrh
        and v.gid=a.store
        group by l.time, a.CLS, a.NUM,v.name,v.code);
        
        insert into h4RTMP_DCGDFLOW(wrh, Settleno, FilDate, Cls, 
                 Num, clientcode,clientname,GdCode,GDGID, outQty, outAmt, Total,BalQty, BalAmt)
        (select vwrhcode,asettleno, l.time, decode(a.cls, '成本转移','成本转移-原料'),
        a.Num,v.code,v.name,vgdcode,Gd_Gid, sum(b.Qty ), 
Sum(b.Total - b.tax), Sum(b.Total), 0, 0
        from Process a, ProcDtl b, Processlog l,store v
      where
        b.israw='1'
        and a.Cls = b.Cls 
        and a.Num = b.Num
        and a.cls = l.cls
        and a.num = l.num
        and l.stat in (100)
        and b.gdgid = Gd_Gid
        and l.time > fromdate
        and a.RAWWRH = awrh
        and v.gid=a.store
        group by l.time, a.CLS, a.NUM,v.name,v.code);
       
 
        insert into h4RTMP_DCGDFLOW(wrh, Settleno, FilDate, Cls, Num,clientcode,clientname,  
GdCode,GDGID, OutQty, OutAmt, Total, BalQty, balamt)
        (select vwrhcode, asettleno, l.time,
        decode(a.CLS,'自营进退','自营进退'), 
        a.Num,v.code,v.name, vgdcode,Gd_Gid, sum(b.Qty), sum(CAmt), 
sum(b.Total),0, 0
        from StkinBck a, StkinBckDtl b, stkinbcklog l,vendor v
        where a.Cls = b.Cls 
        and a.Num = b.Num
        and a.cls = l.cls
  and a.CLS='自营进退'
        and a.num = l.num
        and l.stat in (320,340,720,740,700)
        and b.gdgid = Gd_Gid
        and l.time > fromdate
        and b.wrh = awrh
        and v.gid=a.vendor
        group by l.time, a.CLS, a.NUM,v.name,v.code);


        insert into h4RTMP_DCGDFLOW(wrh, Settleno, FilDate, Cls, 
                 Num, clientcode,clientname,GdCode,GDGID, InQty, InAmt, Total,BalQty, BalAmt)
        (select vwrhcode,asettleno, l.time, '换入',
        a.Num,a.inwrh,'',vgdcode,Gd_Gid, sum(b.Qty), Sum(b.Camt), Sum(b.RTotal), 0, 0
        from ExgGoods a, ExgGoodsDtl b, ExgGoodslog l
        where a.Num = b.Num
        and a.num = l.num
        and l.stat in (300,320,340)
        and b.gdgid = Gd_Gid
        and l.time > fromdate
        and a.InWrh = awrh
        and b.IsOut = 0
        group by l.time, a.NUM,a.inwrh);
       
        insert into h4RTMP_DCGDFLOW(wrh, Settleno, FilDate, Cls, 
                 Num,clientcode,clientname, GdCode,GDGID, OutQty, OutAmt, Total,BalQty, BalAmt)
        (select vwrhcode,asettleno, l.time, '换出',
        a.Num, a.outwrh,'',vgdcode,Gd_Gid, sum(b.Qty), Sum(b.Camt), Sum(b.RTotal), 0, 0
        from ExgGoods a, ExgGoodsDtl b, ExgGoodslog l
        where a.Num = b.Num
        and a.num = l.num
        and l.stat in (300,320,340)
        and b.gdgid = Gd_Gid
        and l.time > fromdate
        and a.OutWrh = awrh
        and b.IsOut = 1
        group by l.time, a.NUM, a.outwrh);
       
      adate:= fromdate;
      while adate<= trunc(sysdate) loop                
        
        insert into h4RTMP_DCGDFLOW(wrh, SettleNo, FilDate, Cls, Num, clientcode,clientname,
GdCode,GDGID, OutQty, OutAmt, Total, BalQty, balAmt)
        (select 
        vwrhcode,asettleno, l.time,
        decode(a.CLS ,'统配出','配出'), 
        a.Num,s.code,s.name, vgdcode,Gd_Gid, sum(b.Qty), sum(b.CAmt), 
sum(b.Total),0, 0
        from StkOut a, StkoutDtl b, stkoutlog l,store s
        where a.Cls = b.Cls 
        and a.Num = b.Num 
        and a.Cls = l.Cls 
        and a.Num = l.Num
        and a.cls = '统配出'
        and l.stat in (700,720,740,320,340)
        and b.gdgid = Gd_Gid
        and l.time >= adate
        and l.time < adate+1
        and b.wrh = awrh
        and s.gid=a.client
        group by l.time, a.CLS, a.NUM,s.name,s.code);   
        
        insert into h4RTMP_DCGDFLOW(wrh, SettleNo, FilDate, Cls, Num,  clientcode,clientname,
GdCode,GDGID, OutQty, OutAmt, Total, BalQty, balAmt)
        (select 
        vwrhcode,asettleno, l.time,
        decode(a.CLS ,'批发', '批发'), 
        a.Num,c.code,c.name, vgdcode,Gd_Gid, sum(b.Qty), sum(b.CAmt), 
sum(b.Total),0, 0
        from StkOut a, StkoutDtl b, stkoutlog l,client c
        where a.Cls = b.Cls 
        and a.Num = b.Num 
        and a.Cls = l.Cls 
        and a.Num = l.Num
        and a.cls = '批发'
        --and a.sender = 1000000
        and l.stat in (700,320,340,720,740)
        and b.gdgid = Gd_Gid
        and l.time >= adate
        and l.time < adate+1
        and b.wrh = awrh
        and c.gid=a.client
        group by l.time, a.CLS, a.NUM,c.name,c.code);   
        adate := adate+1;
      end loop;

     
        insert into h4RTMP_DCGDFLOW(wrh, Settleno, FilDate, Cls, Num, clientcode,clientname, 
GdCode,GDGID, InQty, InAmt, Total, BalQty, BalAmt)
        (select vwrhcode, asettleno, l.time,
        '统配出退',--decode(a.CLS,'统配出退','配出退','批发退'), 
        a.Num,s.code,s.name, vgdcode,Gd_Gid, sum(b.Qty), sum(b.camt), 
sum(b.Total),0, 0
        from StkOutBck a, StkoutBckDtl b, stkoutbcklog l,store s
        where a.Cls = b.Cls and a.Num = b.Num and a.Cls = l.Cls and a.Num = 
l.Num
        AND A.CLS = '统配出退'
        and l.Stat in (320,340,1000,1020,1040)
        --and a.receiver = 1000000
        and b.gdgid = Gd_Gid
        and l.time > fromdate
        and b.wrh = awrh
        and s.gid=a.client
        group by l.time, a.CLS, a.NUM,a.Num,s.name,s.code);
        
        insert into h4RTMP_DCGDFLOW(wrh, Settleno, FilDate, Cls, Num, clientcode,clientname,
GdCode,GDGID, InQty, InAmt, Total, BalQty, BalAmt)
        (select vwrhcode, asettleno, l.time,
        '批发退',--decode(a.CLS,'统配出退','配出退','批发退'), 
        a.Num,c.name,c.code, vgdcode,Gd_Gid, sum(b.Qty), sum(b.camt), 
sum(b.Total),0, 0
        from StkOutBck a, StkoutBckDtl b, stkoutbcklog l,client c
        where a.Cls = b.Cls and a.Num = b.Num and a.Cls = l.Cls and a.Num = l.Num
        and l.Stat in (320,340,1000,1020,1040)
        AND A.CLS =  '批发退'
        --and a.receiver = 1000000
        and b.gdgid = Gd_Gid
        and l.time > fromdate
        and b.wrh = awrh
        and c.gid=a.client
        group by l.time, a.CLS, a.NUM,c.name,c.code);

--配货差异
       insert into h4RTMP_DCGDFLOW(wrh, Settleno, FilDate, Cls, Num,clientcode,clientname, 
GdCode,GDGID, OutQty, OutAmt, Total, BalQty, BalAmt)
        (select vwrhcode, asettleno, Log.time,
        decode(mst.CLS,'配货差异','配货差异'), 
        mst.Num, s.code,s.name,vgdcode,Gd_Gid, sum(dtl.Qty), 
sum(dtl.camt), sum(dtl.Total),0, 0
          from ALCDIFF mst ,alcdiffdtl dtl , ALCDIFFlog Log ,store s
        where mst.num = dtl.num and mst.cls = dtl.cls and log.cls = mst.cls and 
log.num = mst.num 
        and Log.Stat in (400,420,440)
        AND MST.CLS = '配货差异'
        --and mst.sender = 1000000
        and dtl.gdgid = Gd_Gid
        and Log.time > fromdate
        and dtl.wrh = awrh 
        and s.gid=mst.store
        group by Log.time ,decode(mst.CLS,'配货差异','配货差异') , 
        mst.Num,s.name,s.code);

       insert into h4RTMP_DCGDFLOW(wrh, Settleno, FilDate, Cls, Num,clientcode,clientname, 
GdCode,GDGID, OutQty, OutAmt, Total, BalQty, BalAmt)
        (select vwrhcode, asettleno, Log.time,
        decode(mst.CLS,'批发差异','批发差异'), 
        mst.Num, s.code,s.name,vgdcode,Gd_Gid, sum(dtl.Qty), 
sum(dtl.camt), sum(dtl.Total),0, 0
          from ALCDIFF mst ,alcdiffdtl dtl , ALCDIFFlog Log ,client s
        where mst.num = dtl.num and mst.cls = dtl.cls and log.cls = mst.cls and 
log.num = mst.num 
        and Log.Stat in (400,420,440)
        AND MST.CLS = '批发差异'
        --and mst.sender = 1000000
        and dtl.gdgid = Gd_Gid
        and Log.time > fromdate
        and dtl.wrh = awrh 
        and s.gid=mst.store
        group by Log.time ,decode(mst.CLS,'批发差异','批发差异') , 
        mst.Num,s.name,s.code);

     
        insert into h4RTMP_DCGDFLOW(wrh, Settleno, FilDate, Cls, Num, clientcode,clientname, 
GdCode,GDGID, InQty, InAmt, OutQty, OutAmt, Total,BalQty, BalAmt)
        (select vwrhcode,asettleno,CKtimE, '盘入单', ck.Num, 
s.code,s.name, vgdcode,Gd_Gid,
         decode(sign(ck.QTY - ck.ACNTQTY),1, ck.Qty - ck.ACNTQTY, 0),
         decode(sign(ck.camt),1, ck.camt, 0),
         decode(sign(ck.QTY - ck.ACNTQTY),-1, ck.ACNTQTY - ck.Qty , 0),
         decode(sign(ck.camt), -1, -ck.camt, 0),
         ck.rTotal, 0, 0
         from CKdatas ck ,store s
         where ck.stat = 3
           and ck.gdgid = Gd_Gid 
           and ck.wrh = awrh
           --and ck.store = 1000000 
           and s.gid=ck.store
           and ck.cktime > fromdate);

        insert into h4RTMP_DCGDFLOW(wrh, Settleno, fildate, cls, num, clientcode,clientname, 
gdCode,GDGID, InQty, inAmt, total,BalQty, balAmt)
        (select vwrhcode, asettleno, l.time, '调入', a.num,s.code,s.name,
 vgdcode,Gd_Gid, sum(b.qty), sum(b.camt), sum(b.torTotal),0, 0
         from invxf a, invxfdtl b, invxflog l,store s
        where a.num = b.num and a.num = l.num
          and a.cls = b.cls and a.cls = l.cls and a.cls in ('仓库调拨',
'物流调拨')
          and l.stat in (300,320,340)
          and a.toWrh = awrh
          and l.time > fromdate
          and a.tostore=s.gid
          and b.gdgid = gd_gid
          group by vwrhcode, asettleno, l.time, '调入', a.num,s.code,s.name,vgdcode,Gd_Gid);

 insert into h4RTMP_DCGDFLOW(wrh, SettleNo, FilDate, Cls, Num, clientcode,clientname,
GdCode,GDGID, OutQty,  Total)
Select
       vwrhcode,
       asettleno,
       InvUseSign.FILDATE, 
       InvUseSign.CLS, 
       InvUseSign.NUM,       
       Dept.CODE  DTCODE,
       Dept.NAME  DTNAME,      
       goods.code gdcode,
       goods.GID GDGID,
       InvUseSignDtl.QTY,
       InvUseSignDtl.TOTAL
From InvUseSign InvUseSign, 
     InvUseSignDtl InvUseSignDtl,
     InvUseSignLog log,
     goods goods,
     Dept
Where InvUseSign.cls = '仓库领用' and InvUseSign.cls = log.cls and InvUseSign.num = log.num and log.stat in (700)
AND InvUseSign.Dept = Dept.Code(+)
AND (InvUseSign.NUM=InvUseSignDtl.NUM AND InvUseSign.CLS=InvUseSignDtl.CLS)
and InvUseSignDtl.Gdcode=goods.code
AND InvUseSign.fildate > fromdate and InvUseSignDtl.wrh = awrh
AND GOODS.CODE=vgdcode;  
       
        insert into h4RTMP_DCGDFLOW(wrh, Settleno, fildate, cls, num,clientcode,clientname, 
gdCode,GDGID, OutQty, OutAmt, Total,BalQty, balAmt)
        (select vwrhcode,asettleno, l.time, '调出', a.num,s.code,s.name, 
vgdcode,Gd_Gid, sum(b.qty), sum(b.camt), sum(b.fromrTotal),0, 0
         from invxf a, invxfdtl b, invxflog l,store s
        where a.num = b.num and a.num = l.num
          and a.cls = b.cls and a.cls = l.cls and a.cls in ('仓库调拨',
'物流调拨')
          and l.stat in (700,720,740)
          and l.time > fromdate
          and a.fromWrh = awrh
          and a.fromstore=s.gid
          and b.gdgid = gd_gid
          group by vwrhcode,asettleno, l.time, '调出', a.num,s.code,s.name, vgdcode,Gd_Gid );

        insert into h4RTMP_DCGDFLOW(wrh, Settleno, fildate, cls, num,  clientcode,clientname,
gdCode,GDGID, InQty, inAmt, total,BalQty, balAmt)
        (select vwrhcode, asettleno, l.time , '溢余', a.num, 
s.code,s.name, vgdcode,Gd_Gid, b.qty, b.camt, b.rtotal,0,0
         from invMOD a, invMODdtl b, invMODlog l,store s
        where a.num = b.num
          and a.num = l.num
          and a.cls = b.cls
          and a.cls = l.cls
          and a.cls = '仓库调整'
          and l.time > fromdate
          and l.stat in (300,320,340)
--          and a.Store = GetStore
          and a.Wrh = aWrh
          and b.gdgid = gd_gid
          and a.store=s.gid
          AND B.QTY > 0);

        insert into h4RTMP_DCGDFLOW(wrh, Settleno, fildate, cls, num, clientcode,clientname,
gdCode,GDGID, OutQty, OutAmt, Total,BalQty, balAmt)
        (select vwrhcode, asettleno, l.time , '损耗', a.num,
s.code,s.name, vgdcode,Gd_Gid, -b.qty, -b.camt, -b.rtotal, 0, 0
         from invMOD a, invMODdtl b, invMODlog l,store s
        where a.num = b.num
          and a.num = l.num
          and a.cls = b.cls
          and a.cls = l.cls
          and a.cls = '仓库调整'
          and l.time > fromdate
          and l.stat in (300,320,340)
--          and a.Store = GetStore
          and a.Wrh = aWrh
          and a.store=s.gid
          and b.gdgid = gd_gid
          AND B.QTY < 0);
       
        begin         
             select BalQty, balAmt into t_BalQty, t_balAMt from h4RTMP_DCGDFLOW 
where Cls = '期初';
        exception
             when NO_DATA_FOUND then
             begin
                 insert into h4RTMP_DCGDFLOW(wrh, Settleno,fildate, Cls, GdCode,GDGID, 
BalQty, Total, BalAmt)
                                 values(vwrhcode, asettleno, fromdate, '期初', 
vgdcode,Gd_Gid,0,0,0);
                 t_BalQty := 0;
                 t_balAMt := 0;
             end;
        end;


  
        for c_q1 in c1 loop    
                  t_Cls := c_q1.Cls;
                  t_num := c_q1.num;
                  t_InQty := c_q1.InQty;
                  t_OutQty := c_q1.OutQty;
      t_InAmt := c_q1.InAmt;
      t_OutAmt := c_q1.OutAmt;
                  t_Date := c_q1.FilDate;
                  t_BalQty := nvl(t_BalQty,0) + nvl(t_InQty,0) - 
nvl(c_q1.OutQty,0); 
      t_balAmt := nvl(t_balAmt,0) + nvl(t_InAmt,0) - nvl(c_q1.OutAmt,0);
                  update h4RTMP_DCGDFLOW set h4RTMP_DCGDFLOW.BalQty =  t_BalQty, 
balAmt = t_balAmt
                    where c_q1.FilDate = fildate and c_q1.Cls = cls 
                    and c_q1.Num = num
                    and cls <> '期初';
        End loop;

        insert into h4RTMP_DCGDFLOW(wrh, Settleno,fildate, Cls, GdCode,GDGID, BalQty, 
Total, BalAmt)
              values(vwrhcode, asettleno, sysdate, '期末', vgdcode,Gd_Gid,t_BalQty ,0,
t_balAmt );
        commit;
      
end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>h4RTMP_DCGDFLOW</TABLE>
    <ALIAS>h4RTMP_DCGDFLOW</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>WAREHOUSEH</TABLE>
    <ALIAS>WAREHOUSEH</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
  <TABLEITEM>
    <TABLE>GOODSH</TABLE>
    <ALIAS>GOODSH</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
</TABLELIST>
<JOINLIST>
  <JOINITEM>
    <LEFT>WAREHOUSEH.CODE</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>h4RTMP_DCGDFLOW.wrh</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>GOODSH.GID</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>h4RTMP_DCGDFLOW.GDGID</RIGHT>
  </JOINITEM>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4RTMP_DCGDFLOW.FilDate</COLUMN>
    <TITLE>填单日期</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>FilDate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4RTMP_DCGDFLOW.Cls</COLUMN>
    <TITLE>操作类型</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>B</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4RTMP_DCGDFLOW.clientcode</COLUMN>
    <TITLE>客户代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>clientcode</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4RTMP_DCGDFLOW.clientname</COLUMN>
    <TITLE>客户名称</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>clientname</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4RTMP_DCGDFLOW.Num</COLUMN>
    <TITLE>单据号</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>C</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4RTMP_DCGDFLOW.GdCode</COLUMN>
    <TITLE>商品代码/条码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>J</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>GOODSH.NAME</COLUMN>
    <TITLE>商品名称</TITLE>
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
    <COLUMN>h4RTMP_DCGDFLOW.InQty</COLUMN>
    <TITLE>数量（+）</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>D</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4RTMP_DCGDFLOW.OutQty</COLUMN>
    <TITLE>数量（-）</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>E</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4RTMP_DCGDFLOW.BalQty</COLUMN>
    <TITLE>数量平衡</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>F</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4RTMP_DCGDFLOW.Total</COLUMN>
    <TITLE>发生额</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>G</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>WAREHOUSEH.CODE</COLUMN>
    <TITLE>仓位代码</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>H</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4RTMP_DCGDFLOW.Settleno</COLUMN>
    <TITLE>期初库存期号</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>I</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4RTMP_DCGDFLOW.InAmt</COLUMN>
    <TITLE>成本额（+）</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>K</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4RTMP_DCGDFLOW.OutAmt</COLUMN>
    <TITLE>成本额（-）</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>L</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4RTMP_DCGDFLOW.BalAmt</COLUMN>
    <TITLE>成本额平衡</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>M</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>DECODE ( h4RTMP_DCGDFLOW.BalQty , 0 , 0 , h4RTMP_DCGDFLOW.BalAmt / h4RTMP_DCGDFLOW.BalQty )</COLUMN>
    <TITLE>库存价</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>N</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>124</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>86</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>134</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>100</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>112</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>177</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>72</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>71</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>81</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>71</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>填单日期</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>h4RTMP_DCGDFLOW.Settleno</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>201411</RIGHTITEM>
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
    <DEFAULTVALUE>上期</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>h4RTMP_DCGDFLOW.GdCode</LEFT>
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
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>WAREHOUSEH.CODE</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>01</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
      <PICKNAMEITEM>#TABLE</PICKNAMEITEM>
      <PICKNAMEITEM>code||'-'||name</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>select code,code||'-'||name from warehouse order by code</PICKVALUEITEM>
      <PICKVALUEITEM>code</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE>01</DEFAULTVALUE>
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>h4RTMP_DCGDFLOW.Cls</LEFT>
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
    <LEFT>h4RTMP_DCGDFLOW.FilDate</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2014.12.01</RIGHTITEM>
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
    <DEFAULTVALUE>月初</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>h4RTMP_DCGDFLOW.FilDate</LEFT>
    <OPERATOR><=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2014.12.01</RIGHTITEM>
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
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>111</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>133</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>89</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>92</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>条件 1：</SGLINEITEM>
    <SGLINEITEM>201411</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM>01</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM>2014.12.01</SGLINEITEM>
    <SGLINEITEM>2014.12.01</SGLINEITEM>
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
  <DXFILTERTYPE></DXFILTERTYPE>
  <DXFILTERLIST>
  </DXFILTERLIST>
  <DXSHOWGRIDLINE>1</DXSHOWGRIDLINE>
</DXDBGRIDITEM>
</SQLQUERY>
<SQLREPORT>
<RPTTITLE>总部单品流水帐</RPTTITLE>
<RPTGROUPCOUNT>0</RPTGROUPCOUNT>
<RPTGROUPLIST>
</RPTGROUPLIST>
<RPTCOLUMNCOUNT>11</RPTCOLUMNCOUNT>
<RPTCOLUMNWIDTHLIST>
  <RPTCOLUMNWIDTHITEM>122</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>61</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>56</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>134</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>100</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>56</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>177</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>72</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>71</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>81</RPTCOLUMNWIDTHITEM>
  <RPTCOLUMNWIDTHITEM>71</RPTCOLUMNWIDTHITEM>
</RPTCOLUMNWIDTHLIST>
<RPTLEFTMARGIN>40</RPTLEFTMARGIN>
<RPTORIENTATION>0</RPTORIENTATION>
<RPTCOLUMNS>1</RPTCOLUMNS>
<RPTHEADERLEVEL>0</RPTHEADERLEVEL>
<RPTPRINTCRITERIA>TRUE</RPTPRINTCRITERIA>
<RPTVERSION></RPTVERSION>
<RPTNOTE></RPTNOTE>
<RPTFONTSIZE>9</RPTFONTSIZE>
<RPTLINEHEIGHT>宋体</RPTLINEHEIGHT>
<RPTPAGEHEIGHT>66</RPTPAGEHEIGHT>
<RPTPAGEWIDTH>80</RPTPAGEWIDTH>
<RPTTITLETYPE>0</RPTTITLETYPE>
<RPTCURREPORT></RPTCURREPORT>
<RPTREPORTLIST>
</RPTREPORTLIST>
</SQLREPORT>

