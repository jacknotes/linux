--4/9���˻�Ʊ��ׯ��Ƽ�ĺ�������
select coupno ���۵���,bpay ���ǽ��,oper2 ��������,datetime2 ����ʱ�� from Topway..tbcash 
where oper2='ׯ��Ƽ'
and datetime2>='2019-04-09'
and datetime2<'2019-04-10'

/*
 AS002426439 ԭ��Ӧ����Դ HS���̴��D �޸�Ϊ HSBSPETD 4/24 
 AS002426441 ԭ��Ӧ����Դ HS���̴��D �޸�Ϊ HSBSPETD 4/26 
 AS002433096 ԭ��Ӧ����Դ HS���̸߶�D �޸�Ϊ HSBSPETD 4/30 
 AS002440662 ԭ��Ӧ����Դ HSBSPETD �޸�Ϊ HS���̸߶�D 4/30 
 AS002440880 ԭ��Ӧ����Դ HSBSPETD �޸�Ϊ HS�������ɿ�D 4/22 
 AS002419613 ԭ��Ӧ����Դ HS����ά������D �޸�Ϊ HSBSPETD 4/22 
 AS002420819 ԭ��Ӧ����Դ HS���̼��ָ�D �޸�Ϊ HSBSPETD 4/22 
 AS002421059 ԭ��Ӧ����Դ HS��������D �޸�Ϊ HSBSPETD 4/22 
 AS002421272 ԭ��Ӧ����Դ HS����̩��D �޸�Ϊ HSBSPETD 4/23 
 AS002422979 ԭ��Ӧ����Դ HS����ʤ��I �޸�Ϊ HSBSPETI 4/24 
 AS002425712 ԭ��Ӧ����Դ HS����������I �޸�Ϊ HSBSPETI
 */
 --�޸Ĺ�Ӧ����Դ
 select t_source,* from Topway..tbcash 
 --update Topway..tbcash set t_source='HSBSPETD'
 where coupno in ('AS002426439','AS002426441','AS002433096','AS002419613','AS002420819','AS002421059',
 'AS002421272')
 
 select t_source,* from Topway..tbcash 
 --update Topway..tbcash set t_source='HSBSPETI'
 where coupno in ('AS002422979','AS002425712')
 
  select t_source,* from Topway..tbcash 
 --update Topway..tbcash set t_source='HS���̸߶�D'
 where coupno in ('AS002440662')
 
  select t_source,* from Topway..tbcash 
 --update Topway..tbcash set t_source='HS�������ɿ�D'
 where coupno in ('AS002440880')
 
 --�����˸ĳ�δ��
 select haschecked,* from Topway..FinanceERP_ClientBankRealIncomeDetail 
 --update Topway..FinanceERP_ClientBankRealIncomeDetail  set haschecked=0
 where date='2019-04-02' and money='1300'


--����δ���
select state from topway..FinanceERP_ClientBankRealIncomeDetail 
--update topway..FinanceERP_ClientBankRealIncomeDetail set state=5
where date='2019-04-02' and money='1300'

--�ؿ���ӡ
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus=0,PrDate='1900-01-01'
where TrvId='29979' and Id='227889'

--��ӪС��������
/*����=1
�ֹ�����=2
�绰Ԥ��=3
�հ׵���=4
app=5
����=7
����=6
�����ڲ�=8
�����ڲ�=9
΢��Ԥ��=10
wapԤ��=11
*/
IF OBJECT_ID('tempdb.dbo.#cmp1') IS NOT NULL DROP TABLE #cmp1
select distinct c.coupno,e.team ҵ�������
into #cmp1
from Topway..tbcash c
inner join homsomDB..Trv_ItktBookings it on it.ID=c.BaokuID
inner join Topway..Emppwd e on e.empname=c.sales
where datetime>='2019-04-01'
and datetime<'2019-05-01'
and c.ConventionYsId=0
and c.trvYsId=0
and inf=0
and it.BookingSource in ('1','5','6','10','11')
and tickettype='����Ʊ'
and reti=''

select COUNT(coupno) ������,ҵ������� from #cmp1
group by ҵ�������
order by ������ desc


/*
UC018734    ����ס�����У��й������޹�˾  
      ���밴����ģ���ṩ�ù�˾��2016�������������Ana���յĻ�Ʊ��Ϣ NH
      ��Ʊ����	�������۵���	PNR	Ʊ��	�������	�˿�����	����	��λ	���ۼ�	ǰ����1%��	�����	����ѣ�3%��	��������	�����
*/
select convert(varchar(10),datetime,120) ��Ʊ����,coupno,recno,begdate,pasname,route,nclass,totprice,xfprice,
totsprice,fuprice,profit,ride +flightno 
from Topway..tbcash 
where cmpcode='018734'
and datetime>='2016-01-01'
and ride='NH'
order by ��Ʊ����

--�г̵�������Ʊ��
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno='AS002395502'

--��Ʊ��
--select pasname,* from Topway..tbcash where coupno='AS002450753'
update Topway..tbcash set tcode='781',ticketno='2400378478',pasname='CHEN/HUAZHONG' where coupno='AS002450753' and pasname='�˿�0'
update Topway..tbcash set tcode='781',ticketno='2400378479',pasname='FAN/JIANHUI' where coupno='AS002450753' and pasname='�˿�1'
update Topway..tbcash set tcode='781',ticketno='2400378480',pasname='GAO/KEWEI' where coupno='AS002450753' and pasname='�˿�2'
update Topway..tbcash set tcode='781',ticketno='2400378481',pasname='GU/LEI' where coupno='AS002450753' and pasname='�˿�3'
update Topway..tbcash set tcode='781',ticketno='2400378482',pasname='KAN/ZONGGANG' where coupno='AS002450753' and pasname='�˿�4'
update Topway..tbcash set tcode='781',ticketno='2400378483',pasname='LIU/JIHONG' where coupno='AS002450753' and pasname='�˿�5'
update Topway..tbcash set tcode='781',ticketno='2400378484',pasname='LYU/WEIQI' where coupno='AS002450753' and pasname='�˿�6'
update Topway..tbcash set tcode='781',ticketno='2400378485',pasname='QIAN/ZHENJIE' where coupno='AS002450753' and pasname='�˿�7'
update Topway..tbcash set tcode='781',ticketno='2400378486',pasname='SHAN/YIQUAN' where coupno='AS002450753' and pasname='�˿�8'
update Topway..tbcash set tcode='781',ticketno='2400378487',pasname='SUN/ANGUO' where coupno='AS002450753' and pasname='�˿�9'
update Topway..tbcash set tcode='781',ticketno='2400378488',pasname='YE/SONG' where coupno='AS002450753' and pasname='�˿�10'
update Topway..tbcash set tcode='781',ticketno='2400378489',pasname='ZHOU/RONGQIANG' where coupno='AS002450753' and pasname='�˿�11'


--�޸����ۼ���Ϣ
select owe,amount,totprice,* from Topway..tbcash 
--update Topway..tbcash set owe=owe-10,amount=amount-10,totprice=totprice-10
where coupno in ('AS002400598',
'AS002400598',
'AS002401931',
'AS002401931',
'AS002406379',
'AS002406379',
'AS002413214',
'AS002413214',
'AS002417277',
'AS002417277',
'AS002417277',
'AS002417688',
'AS002422572',
'AS002422572',
'AS002435789',
'AS002435789',
'AS002435789',
'AS002440600',
'AS002440600',
'AS002440600')

--2019��1��1�����񣬻�����ʣ���֮�����Ź㺮�����ŵ���ϸ�������źš�����������

select Sales �������,ConventionId ����Ԥ�㵥��,XsPrice ���۽��,Profit ����,DisCountProfit ��������
from Topway..tbConventionCoup
where OperDate>'2019-01-01'
and Sales in('��֮��','�Ź㺮')
and Status<>2
order  by �������
