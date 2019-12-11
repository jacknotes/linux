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
    vdatetype varchar2(20);
    vbgndate  date ;
    venddate  date ;
begin
  
  vdatetype := '\(3,1)';
  vbgndate := to_date('\(1,1)','yyyy.mm.dd');
  venddate := to_date('\(2,1)','yyyy.mm.dd');

  delete from H4RTMP_storebill ; commit ;
  delete from H4RTMP_storebill_total ; commit;
   --�����
 if vdatetype = '�����' then --�����
   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate , ALCIVCREG ,
     alctotal , alcamt , alctax, ALCRTOTAL)
   select sender , client , sender , num , cls ,stat , ocrdate ,fildate , paydate , ALCIVCREG ,
    total as alctotal , (total - tax) as alcamt , tax as alctax, CRTOTAL ALCRTOTAL
       from stkout 
    where  stat in (700,300)
    and fildate < venddate 
    and fildate >=  vbgndate
    
      ;
    --�������
   insert into H4RTMP_storebill 
   (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate , ALCIVCREG ,
     alcdiftotal , alcdifamt , alcdiftax, ALCDIFRTOTAL)
   select sender , store , sender , num , cls , stat , createtime , lstupdtime , lstupdtime , ALCIVCREG,
     total as alcdiftotal , (total- tax) as alcdifamt , tax as alcdiftax, CRTOTAL ALCDIFRTOTAL
    from alcdiff mst  
     where Stat in (400,300)
       and mst.lstupdtime < venddate 
       and mst.lstupdtime >= vbgndate
    ;
   
   --ͳ�����
   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     alcbcktotal , alcbckamt , alcbcktax, ALCBCKRTOTAL)
   select receiver , client , receiver , num , cls ,stat , ocrdate ,fildate , paydate , ALCIVCREG ,
    total as alcbcktotal , (total - tax) as alcbckamt , tax as alcbcktax, CRTOTAL ALCBCKRTOTAL
       from stkoutbck
    where STAT IN (1000,300)
    and fildate < venddate 
    and fildate >=  vbgndate;

   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     diralctotal , diralcamt , diralctax , diralcbcktotal , diralcbckamt , diralcbcktax, DIRALCRTOTAL, DIRALCBCKRTOTAL)
   select sender , receiver , vendor , num , cls ,stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    decode( cls , 'ֱ���' , alctotal , 0)  as diralctotal , decode( cls , 'ֱ���' , alctotal - alctax , 0) as diralcamt ,  decode( cls , 'ֱ���' , alctax , 0) as diralctax , 
    decode( cls , 'ֱ�����' , alctotal , 0)  as diralctotal , decode( cls , 'ֱ�����' , alctotal - alctax , 0) as diralcamt ,  decode( cls , 'ֱ�����' , alctax , 0) as diralctax, 
    DECODE(CLS, 'ֱ���', RTOTAL,0) DIRALCRTOTAL,
    DECODE(CLS, 'ֱ�����', RTOTAL,0) DIRALCBCKRTOTAL
       from diralc
    where STAT IN (700,1000, 300)
    and fildate < venddate 
    and fildate >=  vbgndate ;
    
  elsif vdatetype = '��������' then --��������
  
   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     alctotal , alcamt , alctax, ALCRTOTAL)
   select sender , client , sender , num , cls ,stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    total as alctotal , (total - tax) as alcamt , tax as alctax, CRTOTAL ALCRTOTAL
       from stkout 
    where Stat in (700,300)
    and ocrdate < venddate 
    and ocrdate >=  vbgndate
      ;
    --�������
   insert into H4RTMP_storebill 
   (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     alcdiftotal , alcdifamt , alcdiftax, ALCDIFRTOTAL)
   select sender , store , sender , num , cls , stat , createtime , lstupdtime , lstupdtime ,ALCIVCREG ,
     total as alcdiftotal , (total- tax) as alcdifamt , tax as alcdiftax, CRTOTAL ALCDIFRTOTAL
    from alcdiff mst  
     where Stat in (400,300)
       and mst.createtime < venddate 
       and mst.createtime >= vbgndate
    ;
   
   --ͳ�����
   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     alcbcktotal , alcbckamt , alcbcktax, ALCBCKRTOTAL)
   select receiver , client , receiver , num , cls ,stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    total as alcbcktotal , (total - tax) as alcbckamt , tax as alcbcktax, CRTOTAL ALCBCKRTOTAL
       from stkoutbck
    where STAT IN (1000,300)
    and ocrdate < venddate 
    and ocrdate >=  vbgndate ;

   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     diralctotal , diralcamt , diralctax , diralcbcktotal , diralcbckamt , diralcbcktax, DIRALCRTOTAL,DIRALCBCKRTOTAL)
   select sender , receiver , vendor , num , cls ,stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    decode( cls , 'ֱ���' , alctotal , 0)  as diralctotal , decode( cls , 'ֱ���' , alctotal - alctax , 0) as diralcamt ,  decode( cls , 'ֱ���' , alctax , 0) as diralctax , 
    decode( cls , 'ֱ�����' , alctotal , 0)  as diralctotal , decode( cls , 'ֱ�����' , alctotal - alctax , 0) as diralcamt , 
     decode( cls , 'ֱ�����' , alctax , 0) as diralctax, 
     DECODE(CLS, 'ֱ���', RTOTAL,0) DIRALCRTOTAL,
     DECODE(CLS, 'ֱ�����', RTOTAL,0) DIRALCBCKRTOTAL
       from diralc
    where STAT IN (700,1000,300)
    and ocrdate < venddate 
    and ocrdate >=  vbgndate ;    
    ------
  else  --�������� ���ձ�һ��
    ------
   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     alctotal , alcamt , alctax, ALCRTOTAL)
   select mst.sender , mst.client , mst.sender , mst.num , mst.cls , mst.stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    total as alctotal , (total - tax) as alcamt , tax as alctax, CRTOTAL ALCRTOTAL
       from stkout mst , stkoutlog log
     where mst.CLS = log.CLS  
         AND mst.NUM = log.NUM
         AND log.CLS = 'ͳ���'
         AND log.STAT IN (700,720,740,320,340)
         AND log.TIME < venddate
         AND log.TIME >= vbgndate
      ;
    --�������
   insert into H4RTMP_storebill 
   (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     alcdiftotal , alcdifamt , alcdiftax, ALCDIFRTOTAL)
   select sender , store , sender , mst.num , mst.cls , mst.stat , mst.createtime , lstupdtime , lstupdtime ,ALCIVCREG ,
     total as alcdiftotal , (total- tax) as alcdifamt , tax as alcdiftax, CRTOTAL ALCDIFRTOTAL
    from alcdiff mst , alcdifflog log  
     where  log.cls = mst.cls
        and log.num = mst.num
        and Log.Stat in (400,420,440,320,340)
        AND Log.time <  venddate
        and Log.time >= vbgndate
    ;
   
   --ͳ�����
   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     alcbcktotal , alcbckamt , alcbcktax, ALCBCKRTOTAL)
   select receiver , client , receiver , mst.num , mst.cls ,mst.stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    total as alcbcktotal , (total - tax) as alcbckamt , tax as alcbcktax, CRTOTAL ALCBCKRTOTAL
       from stkoutbck mst , stkoutbcklog log
    where Mst.CLS = log.CLS
           AND Mst.NUM = log.NUM
           AND Mst.CLS = 'ͳ�����'
           AND log.STAT IN (1000,1020,1040,320,340)
           AND log.TIME < venddate
           AND log.TIME >= vbgndate ;

   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     diralctotal , diralcamt , diralctax , diralcbcktotal , diralcbckamt , diralcbcktax, DIRALCRTOTAL, DIRALCBCKRTOTAL)
   select sender , receiver , vendor , m.num , m.cls ,m.stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    decode( m.cls , 'ֱ���' , alctotal , 0)  as diralctotal , decode( m.cls , 'ֱ���' , alctotal - alctax , 0) as diralcamt ,  decode( m.cls , 'ֱ���' , alctax , 0) as diralctax , 
    decode( m.cls , 'ֱ�����' , alctotal , 0)  as diralctotal , decode( m.cls , 'ֱ�����' , alctotal - alctax , 0) as diralcamt , 
     decode( m.cls , 'ֱ�����' , alctax , 0) as diralctax, 
     DECODE(M.CLS, 'ֱ���', RTOTAL,0) DIRALCRTOTAL,
     DECODE(M.CLS, 'ֱ�����', RTOTAL,0) DIRALCBCKRTOTAL 
       from diralc m , diralclog mm
    where  M.CLS = MM.CLS
         AND M.NUM = MM.NUM
         AND MM.CLS = 'ֱ���'
         AND MM.STAT IN (1000, 1020, 1040, 320 ,340)
       AND MM.TIME < venddate
       AND MM.TIME >= vbgndate ;
       
   insert into H4RTMP_storebill
    (snd , store , vendor , num , cls , stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
     diralctotal , diralcamt , diralctax , diralcbcktotal , diralcbckamt , diralcbcktax, DIRALCRTOTAL, DIRALCBCKRTOTAL)
   select sender , receiver , vendor , m.num , m.cls ,m.stat , ocrdate ,fildate , paydate ,ALCIVCREG ,
    decode( m.cls , 'ֱ���' , alctotal , 0)  as diralctotal , decode( m.cls , 'ֱ���' , alctotal - alctax , 0) as diralcamt ,  decode( m.cls , 'ֱ���' , alctax , 0) as diralctax , 
    decode( m.cls , 'ֱ�����' , alctotal , 0)  as diralctotal , decode( m.cls , 'ֱ�����' , alctotal - alctax , 0) as diralcamt , 
     decode( m.cls , 'ֱ�����' , alctax , 0) as diralctax, 
     DECODE(M.CLS, 'ֱ���', RTOTAL,0) DIRALCRTOTAL,
     DECODE(M.CLS, 'ֱ�����', RTOTAL,0) DIRALCBCKRTOTAL  
       from diralc m , diralclog mm
    where  M.CLS = MM.CLS
         AND M.NUM = MM.NUM
         AND MM.CLS = 'ֱ�����'
         AND MM.STAT IN (700,720,740,320,340)
         AND MM.TIME < venddate
         AND MM.TIME >= vbgndate ;       
       
  end if;


   --�ϼƣ�
   insert into H4RTMP_storebill_total
    ( store , bgndate , enddate ,fildate , datetype , stat,ALCIVCREG ,
       alctotal , alcamt , alctax , 
       alcbcktotal , alcbckamt , alcbcktax ,
       alcdiftotal , alcdifamt , alcdiftax ,
       diralctotal , diralcamt , diralctax , 
       diralcbcktotal , diralcbckamt , diralcbcktax, ALCRTOTAL, ALCDIFRTOTAL, ALCBCKRTOTAL, DIRALCRTOTAL, DIRALCBCKRTOTAL)
    select store  , vbgndate , venddate - 1, vbgndate , vdatetype  , stat,nvl(ALCIVCREG,0) ,
     sum(nvl(alctotal,0)) as alctotal , sum(nvl(alcamt,0)) as alcamt , sum(nvl(alctax,0)) as alctax ,
     sum(nvl(alcbcktotal,0)) as alcbcktotal , sum(nvl(alcbckamt,0)) as alcbckamt , sum(nvl(alcbcktax,0)) as alcbcktax ,
     sum(nvl(alcdiftotal,0)) as alcdiftotal , sum(nvl(alcdifamt,0)) as alcdifamt , sum(nvl(alcdiftax,0)) as alcdiftax ,
     sum(nvl(diralctotal,0)) as diralctotal ,sum(nvl(diralcamt,0)) as diralcamt , sum(nvl(diralctax,0)) as diralctax ,
     sum(nvl(diralcbcktotal,0)) as diralcbcktotal , sum(nvl(diralcbckamt,0)) as diralcbckamt , sum(nvl(diralcbcktax,0)) as diralcbcktax, 
     SUM(NVL(ALCRTOTAL,0)) AS ALCRTOTAL,
     SUM(NVL(ALCDIFRTOTAL,0)) AS ALCDIFRTOTAL,
     SUM(NVL(ALCBCKRTOTAL,0)) AS ALCBCKRTOTAL,
     SUM(NVL(DIRALCRTOTAL,0)) DIRALCRTOTAL,
     SUM(NVL(DIRALCBCKRTOTAL,0)) DIRALCBCKRTOTAL
    from 
     H4RTMP_storebill
    group by store , stat,nvl(ALCIVCREG,0) ;
       
   commit;
   
end;
/*
--�����˱��� created by zxf 2010.06.09
drop table H4RTMP_storebill cascade constraints;
-- Create table
create global temporary table H4RTMP_STOREBILL
(
  DATETYPE       VARCHAR2(20),  --��������
  BGNDATE        DATE,          --��ʼ����
  ENDDATE        DATE,          --��ֹ����
  SND            INTEGER,
  STORE          INTEGER,       ----�ŵ�
  VENDOR         INTEGER, --��Ӧ��
  NUM            VARCHAR2(24), --����
  CLS            VARCHAR2(24),--��������
  STAT           INTEGER,
  OCRDATE        DATE,--��������
  FILDATE        DATE,--�����
  PAYDATE        DATE,--��������
  ALCIVCREG      INTEGER,--��Ʊ��ʶ
  FILLER         VARCHAR2(40),
  RECCNT         NUMBER(24,4),
  NOTE           VARCHAR2(255),
  ALCTOTAL       NUMBER(24,4),--��˰ͳ��������
  ALCAMT         NUMBER(24,4),--ȥ˰ͳ��������
  ALCTAX         NUMBER(24,4),--ͳ�����˰��
  ALCDIFTOTAL    NUMBER(24,4),--��˰ͳ�����������
  ALCDIFAMT      NUMBER(24,4),--ȥ˰ͳ�����������
  ALCDIFTAX      NUMBER(24,4),--ͳ���������˰��
  ALCBCKTOTAL    NUMBER(24,4),--��˰ͳ������˻����
  ALCBCKAMT      NUMBER(24,4),--ȥ˰ͳ������˻����
  ALCBCKTAX      NUMBER(24,4),--ͳ������˻�˰��
  DIRALCTOTAL    NUMBER(24,4),--��˰ֱ��/ֱ�ͳ������
  DIRALCAMT      NUMBER(24,4),--ȥ˰ֱ��/ֱ�ͳ������
  DIRALCTAX      NUMBER(24,4),--ֱ��/ֱ�ͳ���˰��
  DIRALCBCKTOTAL NUMBER(24,4),-- ��˰ֱ��/ֱ�ͳ����˻����
  DIRALCBCKAMT   NUMBER(24,4),--ȥ˰ֱ��/ֱ�ͳ����˻����
  DIRALCBCKTAX   NUMBER(24,4),--ֱ��/ֱ�ͳ����˻�˰��
  RTOTAL         NUMBER(24,4),--�ۼ۽��
  ALCRTOTAL      NUMBER(24,4),-- ��������ۼ۶�
  ALCDIFRTOTAL   NUMBER(24,4),-- ������������ۼ۶�
  ALCBCKRTOTAL   NUMBER(24,4),--  ��������˻��ۼ۶�
  DIRALCRTOTAL   NUMBER(24,4),-- ֱ������ۼ۶�
  DIRALCBCKRTOTAL NUMBER(24,4),-- ֱ������˻��ۼ۶�
  VDRCODE        VARCHAR2(30), -- ��Ӧ�̴���
  VDRNAME        VARCHAR2(255), -- ��Ӧ������ 
  VDRBILLTOCODE  VARCHAR2(30), -- ���㹩Ӧ�̴��� 
  VDRBILLTONAME  VARCHAR2(255) -- ���㹩Ӧ������
)on commit preserve rows;
-- Grant/Revoke object privileges 
exec hdcreatesynonym('H4RTMP_STOREBILL');
grant insert, update, delete on H4RTMP_STOREBILL to ROLE_HDAPP;
grant insert, update, delete on H4RTMP_STOREBILL to ROLE_HDQRY;


drop table H4RTMP_storebill_total cascade constraints;
create global temporary table H4RTMP_STOREBILL_TOTAL
(
  DATETYPE       VARCHAR2(20),--��������
  BGNDATE        DATE,--��ʼ����
  ENDDATE        DATE,--��ֹ����
  SND            INTEGER,
  STORE          INTEGER,--�ŵ�
  VENDOR         INTEGER,--��Ӧ��
  NUM            VARCHAR2(24),--����
  CLS            VARCHAR2(24),--��������
  STAT           INTEGER,
  OCRDATE        DATE,--��������
  FILDATE        DATE,--�����
  PAYDATE        DATE,--��������
  ALCIVCREG      INTEGER,--��Ʊ��ʶ
  ALCTOTAL       NUMBER(24,4),--��˰ͳ��������
  ALCAMT         NUMBER(24,4),--ȥ˰ͳ��������
  ALCTAX         NUMBER(24,4),--ͳ�����˰��
  ALCDIFTOTAL    NUMBER(24,4),--��˰ͳ�����������
  ALCDIFAMT      NUMBER(24,4),--ȥ˰ͳ�����������
  ALCDIFTAX      NUMBER(24,4),--ͳ���������˰��
  ALCBCKTOTAL    NUMBER(24,4),--��˰ͳ������˻����
  ALCBCKAMT      NUMBER(24,4),--ȥ˰ͳ������˻����
  ALCBCKTAX      NUMBER(24,4),--ͳ������˻�˰��
  DIRALCTOTAL    NUMBER(24,4),--��˰ֱ��/ֱ�ͳ������
  DIRALCAMT      NUMBER(24,4),--ȥ˰ֱ��/ֱ�ͳ������
  DIRALCTAX      NUMBER(24,4),--ֱ��/ֱ�ͳ���˰��
  DIRALCBCKTOTAL NUMBER(24,4),-- ��˰ֱ��/ֱ�ͳ����˻����
  DIRALCBCKAMT   NUMBER(24,4),--ȥ˰ֱ��/ֱ�ͳ����˻����
  DIRALCBCKTAX   NUMBER(24,4),--ֱ��/ֱ�ͳ����˻�˰��
  RTOTAL         NUMBER(24,4),--�ۼ۽��
  ALCRTOTAL      NUMBER(24,4),-- ��������ۼ۶�
  ALCDIFRTOTAL   NUMBER(24,4),-- ������������ۼ۶�
  ALCBCKRTOTAL   NUMBER(24,4),--  ��������˻��ۼ۶�
  DIRALCRTOTAL   NUMBER(24,4),-- ֱ������ۼ۶�
  DIRALCBCKRTOTAL NUMBER(24,4),-- ֱ������˻��ۼ۶� 
  VDRCODE        VARCHAR2(30), -- ��Ӧ�̴���
  VDRNAME        VARCHAR2(255), -- ��Ӧ������ 
  VDRBILLTOCODE  VARCHAR2(30), -- ���㹩Ӧ�̴��� 
  VDRBILLTONAME  VARCHAR2(255) -- ���㹩Ӧ������ 
)on commit preserve rows;
-- Grant/Revoke object privileges 
exec hdcreatesynonym('H4RTMP_STOREBILL_TOTAL');
grant insert, update, delete on H4RTMP_STOREBILL_TOTAL to ROLE_HDAPP;
grant insert, update, delete on H4RTMP_STOREBILL_TOTAL to ROLE_HDQRY;

*/
</BEFORERUN>
<AFTERRUN>
</AFTERRUN>
<TABLELIST>
  <TABLEITEM>
    <TABLE>H4RTMP_storebill_total</TABLE>
    <ALIAS>H4RTMP_storebill_total</ALIAS>
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
  <TABLEITEM>
    <TABLE>STORE</TABLE>
    <ALIAS>STORE__1</ALIAS>
    <INDEXNAME></INDEXNAME>
    <INDEXMETHOD></INDEXMETHOD>
  </TABLEITEM>
</TABLELIST>
<JOINLIST>
  <JOINITEM>
    <LEFT>H4RTMP_storebill_total.store</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>STORE.GID</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>STORE.AREA</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>AREA.CODE</RIGHT>
  </JOINITEM>
  <JOINITEM>
    <LEFT>STORE__1.GID</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>STORE.BILLTO</RIGHT>
  </JOINITEM>
</JOINLIST>
<COLUMNLIST>
  <FIXEDCOLUMNS>0</FIXEDCOLUMNS>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>AREA.CODE</COLUMN>
    <TITLE>�������</TITLE>
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
    <TITLE>��������</TITLE>
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
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>STORE__1.CODE</COLUMN>
    <TITLE>�����ŵ����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>CODE11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>STORE__1.NAME</COLUMN>
    <TITLE>�����ŵ�����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>NAME11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>(case when 
                  (DECODE(BITAND(STORE.PROPERTY, 4), 4, 1, 0)
       		+ DECODE(BITAND(STORE.PROPERTY,  64),  64, 1, 0)
       		+ DECODE(BITAND(STORE.PROPERTY, 256), 256, 1, 0)) = 0 then 'ֱӪ' 
                  else '����' end) 
</COLUMN>
    <TITLE>�ŵ�����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>storetype</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>STORE.CODE</COLUMN>
    <TITLE>�ŵ����</TITLE>
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
    <TITLE>�ŵ�����</TITLE>
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
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alctotal</COLUMN>
    <TITLE>ͳ�������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alctotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcamt</COLUMN>
    <TITLE>ȥ˰ͳ�������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcamt</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alctax</COLUMN>
    <TITLE>ͳ�����˰��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alctax</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.ALCRTOTAL</COLUMN>
    <TITLE>ͳ����ŵ��ۼ۶�</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>ALCRTOTAL</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcdiftotal</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcdiftotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcdifamt</COLUMN>
    <TITLE>ȥ˰��������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcdifamt</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcdiftax</COLUMN>
    <TITLE>�������˰��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcdiftax</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.ALCDIFRTOTAL</COLUMN>
    <TITLE>��������ŵ��ۼ۶�</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>ALCDIFRTOTAL</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcbcktotal</COLUMN>
    <TITLE>ͳ����˶�</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcbcktotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcbckamt</COLUMN>
    <TITLE>ȥ˰ͳ����˶�</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcbckamt</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcbcktax</COLUMN>
    <TITLE>ͳ�����˰��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcbcktax</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.ALCBCKRTOTAL</COLUMN>
    <TITLE>������ŵ��ۼ۶�</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>ALCBCKRTOTAL</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alctotal-H4RTMP_storebill_total.alcbcktotal+H4RTMP_storebill_total.alcdiftotal</COLUMN>
    <TITLE>��ͳ�������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcbcktotal1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711680</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alcamt-H4RTMP_storebill_total.alcbckamt+H4RTMP_storebill_total.alcdifamt</COLUMN>
    <TITLE>��ȥ˰ͳ�������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcbckamt1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711680</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.alctax-H4RTMP_storebill_total.alcbcktax+H4RTMP_storebill_total.alcdiftax</COLUMN>
    <TITLE>��ͳ���˰��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>alcbcktax1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711680</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.ALCRTOTAL-H4RTMP_storebill_total.ALCBCKRTOTAL+H4RTMP_storebill_total.ALCDIFRTOTAL</COLUMN>
    <TITLE>��ͳ����ŵ��ۼ۶�</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>REALALCRTOTAL</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711680</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralctotal</COLUMN>
    <TITLE>ֱ�������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralctotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralcamt</COLUMN>
    <TITLE>ȥ˰ֱ�������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralcamt</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralctax</COLUMN>
    <TITLE>ֱ�����˰��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralctax</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.DIRALCRTOTAL</COLUMN>
    <TITLE>ֱ����ŵ��ۼ۶�</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>DIRALCRTOTAL</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralcbcktotal</COLUMN>
    <TITLE>ֱ������˻���</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralcbcktotal</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralcbckamt</COLUMN>
    <TITLE>ȥ˰ֱ������˻���</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralcbckamt</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralcbcktax</COLUMN>
    <TITLE>ֱ������˻�˰��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralcbcktax</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.DIRALCBCKRTOTAL</COLUMN>
    <TITLE>ֱ������ŵ��ۼ۶�</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>DIRALCBCKRTOTAL</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralctotal-H4RTMP_storebill_total.diralcbcktotal</COLUMN>
    <TITLE>��ֱ�������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralctotal1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711680</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralcamt-H4RTMP_storebill_total.diralcbckamt</COLUMN>
    <TITLE>��ȥ˰ֱ�������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralcamt1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711680</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.diralctax-H4RTMP_storebill_total.diralcbcktax</COLUMN>
    <TITLE>��ֱ�����˰��</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>diralctax1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711680</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION>SUM</AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.DIRALCRTOTAL-H4RTMP_storebill_total.DIRALCBCKRTOTAL</COLUMN>
    <TITLE>��ֱ����ŵ��ۼ۶�</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION>SUM</GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>REALDIRALCRTOTAL</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>16711680</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.datetype</COLUMN>
    <TITLE>��������</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>datetype</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.bgndate</COLUMN>
    <TITLE>����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>FALSE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>fildate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.bgndate</COLUMN>
    <TITLE>��ʼ����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>bgndate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>H4RTMP_storebill_total.enddate</COLUMN>
    <TITLE>��ֹ����</TITLE>
    <FIELDTYPE>0</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>FALSE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>enddate</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT></CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>91</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>91</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>98</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>108</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>111</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>124</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>108</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>119</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>126</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>78</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>107</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>121</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>129</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>134</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>123</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>109</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>121</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>102</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>108</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>78</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>102</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>112</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>112</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>114</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>128</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>110</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>90</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>114</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>112</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>112</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
  <GROUPITEM>
    <COLUMN>AREA.CODE</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>AREA.NAME</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>STORE__1.CODE</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>STORE__1.NAME</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>(case when 
                  (DECODE(BITAND(STORE.PROPERTY, 4), 4, 1, 0)
       		+ DECODE(BITAND(STORE.PROPERTY,  64),  64, 1, 0)
       		+ DECODE(BITAND(STORE.PROPERTY, 256), 256, 1, 0)) = 0 then 'ֱӪ' 
                  else '����' end) 
</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>STORE.CODE</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>STORE.NAME</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>H4RTMP_storebill_total.bgndate</COLUMN>
  </GROUPITEM>
  <GROUPITEM>
    <COLUMN>H4RTMP_storebill_total.enddate</COLUMN>
  </GROUPITEM>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>��ͳ�������</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>H4RTMP_storebill_total.bgndate</LEFT>
    <OPERATOR>>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2010.11.01</RIGHTITEM>
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
    <ISREQUIRED>TRUE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>H4RTMP_storebill_total.bgndate</LEFT>
    <OPERATOR><</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2010.11.26</RIGHTITEM>
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
    <LEFT>H4RTMP_storebill_total.datetype</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>��������</RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
      <RIGHTITEM></RIGHTITEM>
    </RIGHT>
    <ISHAVING>FALSE</ISHAVING>
    <ISQUOTED>0</ISQUOTED>
    <PICKNAME>
      <PICKNAMEITEM>�����</PICKNAMEITEM>
      <PICKNAMEITEM>��������</PICKNAMEITEM>
      <PICKNAMEITEM>��������</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM>�����</PICKVALUEITEM>
      <PICKVALUEITEM>��������</PICKVALUEITEM>
      <PICKVALUEITEM>��������</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE>��������</DEFAULTVALUE>
    <ISREQUIRED>FALSE</ISREQUIRED>
    <WIDTH>0</WIDTH>
  </CRITERIAITEM>
  <CRITERIAITEM>
    <LEFT>(case when 
                  (DECODE(BITAND(STORE.PROPERTY, 4), 4, 1, 0)
       		+ DECODE(BITAND(STORE.PROPERTY,  64),  64, 1, 0)
       		+ DECODE(BITAND(STORE.PROPERTY, 256), 256, 1, 0)) = 0 then 'ֱӪ' 
                  else '����' end) 
</LEFT>
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
      <PICKNAMEITEM>ȫ��</PICKNAMEITEM>
      <PICKNAMEITEM>ֱӪ</PICKNAMEITEM>
      <PICKNAMEITEM>����</PICKNAMEITEM>
    </PICKNAME>
    <PICKVALUE>
      <PICKVALUEITEM></PICKVALUEITEM>
      <PICKVALUEITEM>ֱӪ</PICKVALUEITEM>
      <PICKVALUEITEM>����</PICKVALUEITEM>
    </PICKVALUE>
    <DEFAULTVALUE>ȫ��</DEFAULTVALUE>
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
    <LEFT>STORE.CODE</LEFT>
    <OPERATOR>IN</OPERATOR>
    <RIGHT>
      <RIGHTITEM>1001</RIGHTITEM>
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
  <CRITERIAITEM>
    <LEFT>STORE__1.CODE</LEFT>
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
    <LEFT>STORE__1.NAME</LEFT>
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
  <CRITERIAWIDTHITEM>78</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>76</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>112</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>112</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>112</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>2010.11.01</SGLINEITEM>
    <SGLINEITEM>2010.11.26</SGLINEITEM>
    <SGLINEITEM>��������</SGLINEITEM>
    <SGLINEITEM>ȫ��</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM>1001</SGLINEITEM>
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
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
  </LINE>
  <LINE>
    <SGLINEITEM>no</SGLINEITEM>
    <SGLINEITEM>no</SGLINEITEM>
    <SGLINEITEM>no</SGLINEITEM>
  </LINE>
</SG>
<CHECKLIST>
  <CAPTION>
    <CAPTIONITEM>����/�ѷ���</CAPTIONITEM>
    <CAPTIONITEM>�����/δ��Ʊ</CAPTIONITEM>
    <CAPTIONITEM>�ѿ�Ʊ</CAPTIONITEM>
  </CAPTION>
  <EXPRESSION>
    <EXPRESSIONITEM>H4RTMP_storebill_total.stat in (700,1000,400)</EXPRESSIONITEM>
    <EXPRESSIONITEM>H4RTMP_storebill_total.stat in (300) and H4RTMP_storebill_total.ALCIVCREG = 0</EXPRESSIONITEM>
    <EXPRESSIONITEM>H4RTMP_storebill_total.ALCIVCREG = 1 and H4RTMP_storebill_total.stat in (300)</EXPRESSIONITEM>
  </EXPRESSION>
  <CHECKED>
    <CHECKEDITEM>no</CHECKEDITEM>
    <CHECKEDITEM>no</CHECKEDITEM>
    <CHECKEDITEM>no</CHECKEDITEM>
  </CHECKED>
  <ANDOR> or </ANDOR>
</CHECKLIST>
<UNIONLIST>
</UNIONLIST>
<NCRITERIAS>
  <NUMOFNEXTQRY>1</NUMOFNEXTQRY>
  <NCRITERIALIST>
    <NEXTQUERY>�ŵ����ҵ��(������)����.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>���ڴ��ڵ���</LEFT>
      <RIGHT>���ڴ��ڵ���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>����С��</LEFT>
      <RIGHT>����С��</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>�������͵���</LEFT>
      <RIGHT>�������͵���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>�ŵ������֮��</LEFT>
      <RIGHT>�ŵ����</RIGHT>
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
  <DXCOLORODDROW>16775398</DXCOLORODDROW>
  <DXCOLOREVENROW>16777215</DXCOLOREVENROW>
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

