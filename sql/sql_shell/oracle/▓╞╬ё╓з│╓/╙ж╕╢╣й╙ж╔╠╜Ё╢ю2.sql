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
  vendorcode varchar2(10);
  vendorname varchar2(20);
  Emddate    varchar2(20);
begin
  vendorcode := to_char('\(1,1)');
  vendorname := to_char('\(2,1)');
  Emddate    := to_char('\(3,1)');

    delete tmp_test2;
  commit;

  insert into tmp_test2
    (char1, ------��Ӧ�̴���
     char2, ---��Ӧ������
     char3, ---��Ӧ��״̬
     num1, ---�����
     num2, ---�ڵ���� 
     num3, --��Ԥ������
     num4, ---��ʷ�����
     num5, ----������  
     num6, ---�˻����
     num11, ---���ý��
     num7, ---δ������
     date1, ----ͳ������
     num12 ---��Ԥ�����˿���
     )
  
    select vendor.code, ---��Ӧ�̴���
           vendor.name, ---��Ӧ������
           '����', ---��Ӧ��״̬
           nvl(ckMoney.Money, 0), ---��ǰ�����    
           nvl(zdMoney.ototal, 0), --�ڵ����    
           nvl(YFmoney.YFtotal, 0), --��Ԥ������
           nvl(rkMoney.ototal, 0), ---�����
           nvl(FKMoney.FKtotal, 0), --������   
           nvl(Tmoney.toMoney, 0), ---�˻����
           nvl(fy.amt, 0), ---���ý��
           nvl(nvl(rkMoney.ototal, 0) - nvl(YFmoney.YFtotal, 0) -
               nvl(FKMoney.FKtotal, 0) - nvl(Tmoney.toMoney, 0) -
               nvl(fy.amt, 0) + nvl(YFTmoney.YFTtotal,0),
               0), ---δ������
           
           to_date(Emddate, 'yyyy-mm-dd'), ----ͳ������
           nvl(YFTmoney.YFTtotal,0)     ----Ԥ�����˿���
      from vendor
      left join
    
     (select sum(ACTINVS.AMT + ACTINVS.TAX) Money, goods.VDRGID
        from ACTINVS
        left join goods
          on ACTINVS.GDGID = goods.gid
       group by goods.VDRGID) ckMoney ---��ǰ�����
        on vendor.gid = ckMoney.VDRGID
    
      left join (select ord.vendor,
                        sum(orddtl.ADALCPRC * orddtl.LACKQTY) ototal
                 
                   from ord
                   left join orddtl
                     on ord.num = orddtl.num
                    and ord.cls = orddtl.cls
                   left join ordlog
                     on ord.num = ordlog.num
                    and ord.cls = ordlog.cls
                  where PURORDTYPE <> 1
                    and ordlog.time <= to_date(Emddate, 'yyyy-mm-dd') + 1
                    and ordlog.stat=100
                    and (ord.stat = 200 or
                        (ord.stat = 100 and ord.FINSTAT in ('P')))
                 
                  group by ord.vendor) zdMoney ---�ڵ����
        on vendor.gid = zdMoney.vendor
    
      left join
    
     (select sum(CntrPrePay.Total) YFtotal,
             CntrPrePay.Vendor
        from CntrPrePay, CNTRPREPAYCHKLOG
       where (CntrPrePay.stat = 900 or CntrPrePay.stat = 100 or CntrPrePay.stat = 300)
         and CntrPrePay.Num = CNTRPREPAYCHKLOG.Num
         and CNTRPREPAYCHKLOG.CHKFLAG = 900
         and CNTRPREPAYCHKLOG.ATIME <= to_date(Emddate, 'yyyy-mm-dd') + 1
       group by CntrPrePay.Vendor) YFmoney --��Ԥ������
        on vendor.gid = YFmoney.Vendor


      left join
    
     (select sum(CTPrePayRtn.Total) YFTtotal,
             CTPrePayRtn.Vendor
        from CTPrePayRtn, CTPrePayRtnLog
       where (CTPrePayRtn.stat = 900 or CTPrePayRtn.stat = 100 or CTPrePayRtn.stat = 300)
         and CTPrePayRtn.Num = CTPrePayRtnLog.Num
         and CTPrePayRtnLog.ToStat = 900
         and CTPrePayRtnLog.OperTime <= to_date(Emddate, 'yyyy-mm-dd') + 1
       group by CTPrePayRtn.Vendor) YFTmoney --��Ԥ�����˿���
        on vendor.gid = YFTmoney.Vendor

    
      left join (select sum(stkin.total) ototal, ---�������
                        --stkinlog.time,       ---����ʱ��
                        stkin.vendor ---��Ӧ��
                   from stkin, stkinlog
                  where stkin.num = stkinlog.num
                    and stkin.cls = stkinlog.cls
                    and stkinlog.stat = 1000
                    and stkinlog.time <= to_date(Emddate, 'yyyy-mm-dd') + 1
                  group by stkin.vendor) rkMoney ---�����
        on vendor.gid = rkMoney.vendor
    
      left join (select sum(decode(stat, 900, CNTRPAYCASH.PAYTOTAL, 0)) FKtotal,
                        --    sum(decode(stat, 100, CNTRPAYCASH.PAYTOTAL, 0)) CFKtotal,
                        CNTRPAYCASH.Vdrgid
                   from CNTRPAYCASH, CNTRPAYCASHCHKLOG
                  where CNTRPAYCASH.stat in (100, 900)
                    and CNTRPAYCASH.Num = CNTRPAYCASHCHKLOG.NUM
                    and CNTRPAYCASHCHKLOG.CHKFLAG = 900
                    and CNTRPAYCASHCHKLOG.ATIME <=
                        to_date(Emddate, 'yyyy-mm-dd') + 1
                  group by CNTRPAYCASH.Vdrgid) FKMoney --������
        on vendor.gid = FKMoney.Vdrgid
    
      left join
    
     (select sum(TOTAL) toMoney, Vendor
        from (select TOTAL, STKINBCK.Vendor
                from STKINBCK, STKINBCKLOG
               where STKINBCK.Stat in (100, 300, 700)
                 and STKINBCK.Num = STKINBCKLOG.Num
                 and STKINBCK.Cls = STKINBCKLOG.Cls
                 and STKINBCKLOG.Stat = 100
                 and STKINBCKLOG.TIME <= to_date(Emddate, 'yyyy-mm-dd') + 1
                 and STKINBCK.cls = '��Ӫ����'
              union all
              select TOTAL, DirAlc.Vendor
                from DirAlc, DIRALClog
               where DirAlc.Stat in (100, 300, 700)
                 and DirAlc.Num = DIRALClog.Num
                 and DirAlc.Cls = DIRALClog.Cls
                 and DIRALClog.Stat = 100
                 and DIRALClog.Time <= to_date(Emddate, 'yyyy-mm-dd') + 1
                 and DirAlc.cls = 'ֱ�����')
       group by Vendor) Tmoney
        on vendor.gid = Tmoney.Vendor
      left join (select sum(RealAmt) amt, ChgBook.Billto
                   from ChgBook, ChgBooklog
                  where ChgBook.Stat in (300, 500)
                    and ChgBook.Num = ChgBooklog.Num
                    and ChgBooklog.Stat = 500
                    and ChgBooklog.Time <=
                        to_date(Emddate, 'yyyy-mm-dd') + 1
                  group by ChgBook.Billto) fy     ---���õ�
        on vendor.gid = fy.Billto
    
     where (vendorcode is null or vendor.code = vendorcode)
        or (vendorname is null or vendor.name like vendorname || '%');

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
    <COLUMN>tmp_test2.date1</COLUMN>
    <TITLE>ͳ�ƽ�ֹ����</TITLE>
    <FIELDTYPE>11</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>date1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>yyyy-MM-dd</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.char1</COLUMN>
    <TITLE>��Ӧ�̴���</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <TITLE>��Ӧ������</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <TITLE>��Ӧ��״̬</TITLE>
    <FIELDTYPE>1</FIELDTYPE>
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
    <COLUMN>tmp_test2.num1</COLUMN>
    <TITLE>�����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num1</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num2</COLUMN>
    <TITLE>�ڵ����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num2</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num4</COLUMN>
    <TITLE>��ʷ�����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num4</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num3</COLUMN>
    <TITLE>��ʷԤ������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num3</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num12</COLUMN>
    <TITLE>��ʷԤ�����˿���</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num12</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num5</COLUMN>
    <TITLE>��ʷ������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num5</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num6</COLUMN>
    <TITLE>��ʷ�˻����</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num6</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num11</COLUMN>
    <TITLE>���ý��</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num11</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
  <COLUMNITEM>
    <AGGREGATION></AGGREGATION>
    <COLUMN>tmp_test2.num7</COLUMN>
    <TITLE>δ������</TITLE>
    <FIELDTYPE>6</FIELDTYPE>
    <VISIBLE>TRUE</VISIBLE>
    <GAGGREGATION></GAGGREGATION>
    <DISPLAYINNEXT>TRUE</DISPLAYINNEXT>
    <ISKEY>FALSE</ISKEY>
    <COLUMNNAME>num7</COLUMNNAME>
    <CFILTER>FALSE</CFILTER>
    <CFONTCOLOR>0</CFONTCOLOR>
    <CDISFORMAT>,0.00</CDISFORMAT>
    <CGROUPINDEX>-1</CGROUPINDEX>
  </COLUMNITEM>
</COLUMNLIST>
<COLUMNWIDTH>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>140</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>68</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>92</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>132</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>80</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>56</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>74</COLUMNWIDTHITEM>
  <COLUMNWIDTHITEM>66</COLUMNWIDTHITEM>
</COLUMNWIDTH>
<GROUPLIST>
</GROUPLIST>
<ORDERLIST>
  <ORDERITEM>
    <COLUMN>��Ӧ������</COLUMN>
    <ORDER>ASC</ORDER>
  </ORDERITEM>
</ORDERLIST>
<CRITERIALIST>
  <WIDTHLIST>
  </WIDTHLIST>
  <CRITERIAITEM>
    <LEFT>tmp_test2.char1</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>102013</RIGHTITEM>
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
    <LEFT>tmp_test2.char2</LEFT>
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
    <LEFT>tmp_test2.date1</LEFT>
    <OPERATOR>=</OPERATOR>
    <RIGHT>
      <RIGHTITEM>2016.08.19</RIGHTITEM>
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
</CRITERIALIST>
<CRITERIAWIDTH>
  <CRITERIAWIDTHITEM>88</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>172</CRITERIAWIDTHITEM>
  <CRITERIAWIDTHITEM>100</CRITERIAWIDTHITEM>
</CRITERIAWIDTH>
<SG>
  <LINE>
  </LINE>
  <LINE>
    <SGLINEITEM>���� 1��</SGLINEITEM>
    <SGLINEITEM>102013</SGLINEITEM>
    <SGLINEITEM></SGLINEITEM>
    <SGLINEITEM>2016.08.19</SGLINEITEM>
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
  <NUMOFNEXTQRY>6</NUMOFNEXTQRY>
  <NCRITERIALIST>
    <NEXTQUERY>Ӧ����Ӧ�̽���ڵ����.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>��Ӧ�̴������</LEFT>
      <RIGHT>��Ӧ�̴���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>ͳ�����ڵ���</LEFT>
      <RIGHT>ͳ�ƽ�ֹ����</RIGHT>
    </NCRITERIAITEM>
  </NCRITERIALIST>
  <NCRITERIALIST>
    <NEXTQUERY>Ӧ����Ӧ�̽�������.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>��Ӧ�̴������</LEFT>
      <RIGHT>��Ӧ�̴���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>ͳ�����ڵ���</LEFT>
      <RIGHT>ͳ�ƽ�ֹ����</RIGHT>
    </NCRITERIAITEM>
  </NCRITERIALIST>
  <NCRITERIALIST>
    <NEXTQUERY>Ӧ����Ӧ�̽��Ԥ������.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>��Ӧ�̴������</LEFT>
      <RIGHT>��Ӧ�̴���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>ͳ�����ڵ���</LEFT>
      <RIGHT>ͳ�ƽ�ֹ����</RIGHT>
    </NCRITERIAITEM>
  </NCRITERIALIST>
  <NCRITERIALIST>
    <NEXTQUERY>Ӧ����Ӧ�̽�����.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>��Ӧ�̴������</LEFT>
      <RIGHT>��Ӧ�̴���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>ͳ�����ڵ���</LEFT>
      <RIGHT>ͳ�ƽ�ֹ����</RIGHT>
    </NCRITERIAITEM>
  </NCRITERIALIST>
  <NCRITERIALIST>
    <NEXTQUERY>Ӧ����Ӧ�̽���˻����.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>ͳ�����ڵ���</LEFT>
      <RIGHT>ͳ�ƽ�ֹ����</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>��Ӧ�̴������</LEFT>
      <RIGHT>��Ӧ�̴���</RIGHT>
    </NCRITERIAITEM>
  </NCRITERIALIST>
  <NCRITERIALIST>
    <NEXTQUERY>Ӧ����Ӧ�̽����ý��.sql</NEXTQUERY>
    <NCRITERIAITEM>
      <LEFT>��Ӧ�̴������</LEFT>
      <RIGHT>��Ӧ�̴���</RIGHT>
    </NCRITERIAITEM>
    <NCRITERIAITEM>
      <LEFT>ͳ�����ڵ���</LEFT>
      <RIGHT>ͳ�ƽ�ֹ����</RIGHT>
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

