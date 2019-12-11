<VERSION>4.1.1</VERSION>
<SQLQUERY>
<REMARK>
[����]

[Ӧ�ñ���]

[���������]
���ۻ��ȣ��������۶�-�������۶�/�������۶�
�͵��ۻ��ȣ����ܿ͵���-���ܿ͵���/���ܿ͵���
���������ȣ����ܿ�����-���ܿ�����/���ܿ�����
[��Ҫ�Ĳ�ѯ����]

[ʵ�ַ���]

[����]
</REMARK>
<BEFORERUN>
/*
-- Create table
create global temporary table H4RTMP_SALEBYWEEK
(
  FILDATE    DATE,
  LSTFILDATE DATE,
  QUERYDATE  DATE,
  SALE0      NUMBER(24,2) default 0,
  SALE1      NUMBER(24,2) default 0,
  KDJ0       NUMBER(24,2) default 0,
  KDJ1       NUMBER(24,2) default 0,
  KDL0       INTEGER default 0,
  KDL1       INTEGER default 0,
  CB0        NUMBER(24,2) default 0,
  CB1        NUMBER(24,2) default 0,
  ML0        NUMBER(24,2) default 0,
  ML1        NUMBER(24,2) default 0,
  SALEHB     VARCHAR2(24) default 0,
  KDJHB      VARCHAR2(24) default 0,
  KDLHB      VARCHAR2(24) default 0,
  CBHB       VARCHAR2(24) default 0,
  MLHB       VARCHAR2(24) default 0,
  WEEKDAY    INTEGER,
  ISWEEK     INTEGER,
  ORGKEY     INTEGER,
  CLS        varchar2(20)
)
on commit preserve rows;
-- Grant/Revoke object privileges 
exec hdcreatesynonym('h4rtmp_salebyweek');
exec granttoqryrole('h4rtmp_salebyweek');
grant execute on hdrpt_basic to role_hdqry;

*/
declare
  vDate date;
  vWeekEndDate date;
  vWeekBegDate date;
  vlstWeekEndDate date;
  vlstWeekBegDate date;
  vday date;
  vweekday int;
  cursor c_thisweek is  --���ܵ����ۻ���
    SELECT  t.FILDATE, t.orgkey,SUM(t.saleqty) I,
      SUM(t.saleamt + t.saletax) sale0, 
      SUM(t.salecamt + t.salectax ) cb0, 
      SUM((t.saleamt + t.saletax) - (t.salecamt +  t.salectax)) ml0
    FROM hdtmp_SalDrpt t
    WHERE t.FILDATE >= vWeekBegDate 
     and t.FILDATE <=  vWeekEndDate  
    GROUP BY t.FILDATE,t.orgkey
    ORDER BY FILDATE ASC;

   cursor c_lstweek is  --���ܵ����ۻ���
    SELECT  t.FILDATE, t.orgkey,SUM(t.saleqty) I,
      SUM(t.saleamt + t.saletax) sale1, 
      SUM(t.salecamt + t.salectax ) cb1, 
      SUM((t.saleamt + t.saletax) - (t.salecamt +  t.salectax)) ml1
    FROM hdtmp_SalDrpt t
    WHERE t.FILDATE >= vlstWeekBegDate 
     and t.FILDATE <=  vlstWeekEndDate  
    GROUP BY t.FILDATE,t.orgkey
    ORDER BY FILDATE ASC;
  
  
/* cursor c_store is  --���ܵ��ŵ����
   SELECT  distinct(t.orgkey)   
    FROM STORE, hdtmp_SalDrpt t
    WHERE t.orgkey = STORE.GID      
     and t.FILDATE >= vlstWeekBegDate
     and t.FILDATE <= vlstvWeekEndDate;  
  
 cursor c_store_lst is  --���ܵ��ŵ����
   SELECT  distinct(t.orgkey)   
    FROM STORE, hdtmp_SalDrpt t
    WHERE t.orgkey = STORE.GID      
     and t.FILDATE >= vlstWeekBegDate
     and t.FILDATE <= vWeekEndDate;  */
 
  
  cursor c_thiskd is
    select t.adate fildate,st.gid orgkey, sum(t.dn1) kdl0, round(sum(dt1) / sum(dn1), 2) kdj0
      from cshdrpt t, store st
     where t.adate >= vWeekBegDate
       and t.adate <= vWeekEndDate
       and t.posno = st.code
     group by t.adate,st.gid;
  
  cursor c_lstkd is
    select t.adate fildate,st.gid orgkey, sum(t.dn1) kdl1, round(sum(dt1) / sum(dn1), 2) kdj1
      from cshdrpt t, store st
     where t.adate >= vlstWeekBegDate
       and t.adate <= vlstWeekEndDate
       and t.posno = st.code
     group by t.adate,st.gid;     
  
begin
  --vDate := to_date('2011.05.11','yyyy.mm.dd');
  vDate := '\(1,1)';
  vWeekEndDate := hdrpt_basic.getWeekEnddateByday(vDate)+1;
  vWeekBegDate := vWeekEndDate - 7;
  vlstWeekBegDate := vWeekEndDate - 14;
  vlstWeekEndDate := vWeekEndDate - 7;
  delete from hdtmp_SalDrpt;  commit;

  insert into hdtmp_SalDrpt(cls,orgkey,pdkey,vdrkey,brdkey,fildate,
                            saleqty,saleamt,saletax,salecamt,salectax,
                            saleqty7,saleamt7,saletax7,salecamt7,salectax7,
                            saleqty14,saleamt14,saletax14,salecamt14,salectax14,
                            saleqty30,saleamt30,saletax30,salecamt30,salectax30,
                            saleqty60,saleamt60,saletax60,salecamt60,salectax60,
                            saleqty90,saleamt90,saletax90,salecamt90,salectax90)
    select null,r.orgkey,null,null,null,(r.fildate),
           sum(r.saleqty),sum(r.saleamt),sum(r.saletax),sum(r.salecamt),
sum(r.salectax),
           sum(r.saleqty7),sum(r.saleamt7),sum(r.saletax7),sum(r.salecamt7),
sum(r.salectax7),
           sum(r.saleqty14),sum(r.saleamt14),sum(r.saletax14),sum(r.salecamt14),
sum(r.salectax14),
           sum(r.saleqty30),sum(r.saleamt30),sum(r.saletax30),sum(r.salecamt30),
sum(r.salectax30),
           sum(r.saleqty60),sum(r.saleamt60),sum(r.saletax60),sum(r.salecamt60),
sum(r.salectax60),
           sum(r.saleqty90),sum(r.saleamt90),sum(r.saletax90),sum(r.salecamt90),
sum(r.salectax90)
     from rpt_storedrpt r,store s
    where r.orgkey = s.gid
      and s.gid <> 1000000  --ȥ���ܲ�
      and r.cls in ('����','�ɱ�����')   
    --  and r.saleqty <> 0
      and (r.fildate <= vWeekEndDate)
      and (r.fildate >= vlstWeekBegDate)
    group by r.orgkey,(r.fildate);

   insert into hdtmp_SalDrpt(cls,orgkey,pdkey,vdrkey,brdkey,fildate,
                            saleqty,saleamt,saletax,salecamt,salectax)
     select null,r.snd,'',null,null,(r.fildate),
           sum(decode(r.cls,'����',1,'����',1,'�ɱ�����',0,'�ɱ�����',0,
-1)*r.qty),sum(decode(r.cls,'����',1,'����',1,'�ɱ�����',0,'�ɱ�����',0,
-1)*r.amt),
           sum(decode(r.cls,'����',1,'����',1,'�ɱ�����',0,'�ɱ�����',0,
-1)*r.tax),
           sum(decode(r.cls,'����',1,'����',1,'�ɱ�����',1,'�ɱ�����',1,
-1)*r.iamt),sum(decode(r.cls,'����',1,'����',1,'�ɱ�����',1,'�ɱ�����',1,
-1)*r.itax)          
    from sdrpts r,store s
    where r.snd = s.gid 
      and s.gid <> 1000000
      and r.cls in ( '����','������','����','������','�ɱ�����','�ɱ�����')
      and (r.ocrdate >= trunc(sysdate))
      and (r.fildate <= vWeekEndDate)
      and (r.fildate >= vlstWeekBegDate)
    group by r.snd,(r.fildate); 
   commit;
  
  vday:= vWeekBegDate;
  vweekday := 1;
  delete from h4rtmp_salebyweek;COMMIT;
  while vday < vWeekEndDate loop
    insert into h4rtmp_salebyweek(fildate,orgkey,querydate,isweek,weekday) 
      select  vday,orgkey,vdate,0,vweekday from (SELECT  distinct(st.orgkey)   
    FROM STORE, hdtmp_SalDrpt st
    WHERE st.orgkey = STORE.GID      
     and st.FILDATE >= vlstWeekBegDate
     and st.FILDATE <= vWeekEndDate
     and st.orgkey <> 1000000) t;
    vday := vday+1;
    vweekday := vweekday+1;  
  end loop; 
  
  vday:= vlstWeekBegdate;
  while vday < vlstWeekEndDate loop
    update h4rtmp_salebyweek set lstfildate = vday where fildate = vday+7; 
    vday := vday+1;  
  end loop; 
   
  for r in c_thisweek loop
     update h4rtmp_salebyweek set sale0 = r.sale0, cb0 = r.cb0, ml0 = r.ml0 where fildate = r.fildate and orgkey = r.orgkey;
  end loop;
  
  for rl in c_lstweek loop
     update h4rtmp_salebyweek set sale1 = rl.sale1, cb1 = rl.cb1, ml1 = rl.ml1 where lstfildate = rl.fildate and orgkey = rl.orgkey;
  end loop;  
  
  for p in c_thiskd loop
     update h4rtmp_salebyweek set kdj0 = p.kdj0, kdl0 = p.kdl0 where fildate = p.fildate and orgkey = p.orgkey;
  end loop;  
  
  for p1 in c_lstkd loop
     update h4rtmp_salebyweek set kdj1 = p1.kdj1, kdl1 = p1.kdl1 where lstfildate = p1.fildate and orgkey = p1.orgkey;
  end loop;   
  /* 
  insert into h4rtmp_salebyweek(querydate,sale0,sale1,kdj0,kdj1,kdl0,kdl1,cb0,cb1,ml0,ml1,isweek)
    select vdate,sum(sale0),sum(sale1),avg(kdj0),avg(kdj1),sum(kdl0),sum(kdl1),sum(cb0),sum(cb1),sum(ml0),sum(ml1),1 from h4rtmp_salebyweek group by vdate;*/
  update h4rtmp_salebyweek t set t.salehb = decode(t.sale1,0,0,round((t.sale0-t.sale1)/t.sale1,4)*100),t.kdjhb = decode(t.kdj1,0,0,round((t.kdj0-t.kdj1)/t.kdj1,4)*100),  
    t.mlhb = decode(t.ml1,0,0,round((t.ml0-t.ml1)/t.ml1,4)*100),t.kdlhb = decode(t.kdl1,0,0,round((t.kdl0-t.kdl1)/t.kdl1,4)*100),t.cbhb = decode(t.cb1,0,0,round((t.cb0-t.cb1)/t.cb1,4)*100);
  COMMIT;
end;
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>h4rtmp_salebyweek</TABLE>
    <ALIAS>h4rtmp_salebyweek</ALIAS>
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
    <LEFT>STORE.GID</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>h4rtmp_salebyweek.orgkey</RIGHT>
  </JOINITEM>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(h4rtmp_salebyweek.weekday,1,'����һ',2,'���ڶ�',3,'������',4,'������',5,'������',6,'������',7,'������','�ܻ���')</COLUMN>
    <TITLE>����</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>weekday</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
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
    <CGROUPINDEX>0</CGROUPINDEX>
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
    <COLUMN>h4rtmp_salebyweek.querydate</COLUMN>
    <TITLE>��ѯ����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>querydate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>8388672</CFONTCOLOR>
    <CDISFORMAT>yyyy.MM.dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.fildate</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>11</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>fildate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy.MM.dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.lstfildate</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>11</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>lstfildate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy.MM.dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.sale0</COLUMN>
    <TITLE>���۶Ԫ��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sale0</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.sale1</COLUMN>
    <TITLE>�������۶Ԫ��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>sale1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711808</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.salehb</COLUMN>
    <TITLE>���ۻ��ȣ�%��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>salehb</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>255</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.kdj0</COLUMN>
    <TITLE>�͵���</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>kdj0</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.kdj1</COLUMN>
    <TITLE>���ܿ͵���</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>kdj1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711808</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.kdjhb</COLUMN>
    <TITLE>�͵��ۻ��ȣ�%��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>kdjhb</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>255</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.kdl0</COLUMN>
    <TITLE>������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>kdl0</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.kdl1</COLUMN>
    <TITLE>���ܿ�����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>kdl1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711808</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.kdlhb</COLUMN>
    <TITLE>���������ȣ�%��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>kdlhb</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>255</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.cb0</COLUMN>
    <TITLE>�ɱ���</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>cb0</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.cb1</COLUMN>
    <TITLE>���ܳɱ���</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>cb1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711808</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.ml0</COLUMN>
    <TITLE>ë����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>ml0</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.ml1</COLUMN>
    <TITLE>����ë����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>ml1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711808</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.cbhb</COLUMN>
    <TITLE>�ɱ����ȣ�%��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>cbhb</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>h4rtmp_salebyweek.mlhb</COLUMN>
    <TITLE>ë����ȣ�%��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>mlhb</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(h4rtmp_salebyweek.sale0,0,0,round(h4rtmp_salebyweek.ml0*100/(h4rtmp_salebyweek.cb0+h4rtmp_salebyweek.ml0),2))</COLUMN>
    <TITLE>ë����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>mll0</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>decode(h4rtmp_salebyweek.sale1,0,0,round(h4rtmp_salebyweek.ml1*100/(h4rtmp_salebyweek.cb1+h4rtmp_salebyweek.ml1),2))</COLUMN>
    <TITLE>����ë����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>mll1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>-1</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>44</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>62</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>108</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>73</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>75</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>104</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>69</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>81</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>98</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>148</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>64</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>66</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>��������</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
  <ORDERITEM>
    <COLUMN>�ŵ����</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>h4rtmp_salebyweek.querydate</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2013.04.16</RIGHTITEM>
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
    <LEFT>STORE.CODE</LEFT>
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
    <LEFT>STORE.NAME</LEFT>
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
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>2013.04.16</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 2��</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 3��</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>  �� 4��</SGLINEITEM>
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
  <DXCOLORODDROW>16777215</DXCOLORODDROW>
  <DXCOLOREVENROW>16777215</DXCOLOREVENROW>
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

