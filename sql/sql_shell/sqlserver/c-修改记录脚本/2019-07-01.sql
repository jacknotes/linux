--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='019315_20190501'

--����Ʒר�ã����ս������Ϣ
select sprice1,totsprice,* from Topway..tbcash
--update Topway..tbcash set sprice1='3.3',totsprice='3.3'
where coupno in('AS002566774','AS002569678','AS002570426',
'AS002571045','AS002571049','AS002571115','AS002571203',
'AS002571746','AS002571865','AS002572151','AS002572263',
'AS002574205','AS002574740','AS002574746','AS002578355',
'AS002578356','AS002582847','AS002583996','AS002586591',
'AS002586618','AS002586634','AS002586644','AS002586795',
'AS002586866','AS002586867','AS002586949','AS002587584',
'AS002588856','AS002588857','AS002589204','AS002589205',
'AS002589349','AS002589578','AS002592291','AS002592512')

select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash set sprice1='3.3',totsprice='3.3'
where coupno in('AS002560146','AS002561344','AS002563128','AS002565933',
'AS002565947','AS002566623','AS002566992','AS002566993')

select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash set sprice1='2.2',totsprice='2.2'
where coupno in('AS002568688','AS002582483','AS002582525','AS002585421',
'AS002585422','AS002586032','AS002586033','AS002586468',
'AS002586469','AS002589517')

/*
����ȡ��Ʊ���ݣ�
����ţ�MU5122��FM9320��FM9304��FM9332��MU5452��MU5336��MU9980��FM9426��MU5690��MU9320��MU9304��MU9332��MU9426
����������ڣ�2019��7��1�գ�����֮��
 
���Ҫ��
���۵���  Ʊ��  �����  ����������� ���ù���
*/
select coupno ���۵���,tcode+ticketno Ʊ��,ride+flightno �����,begdate �����������,sales ���ù���
from Topway..tbcash 
where begdate>='2019-07-01'
and ride+flightno in('MU5122','FM9320','FM9304',
'FM9332','MU5452','MU5336','MU9980','FM9426',
'MU5690','MU9320','MU9304','MU9332','MU9426')
order by �����������

SELECT TotFuprice,* FROM Topway..tbTrainTicketInfo WHERE CoupNo='RS000025977'
select Fuprice,ProviderFuprice,* from Topway..tbTrainUser 
--update  Topway..tbTrainUser  set ProviderFuprice=0
where TrainTicketNo=(SELECT ID FROM Topway..tbTrainTicketInfo WHERE CoupNo='RS000025977')

--UC020350 ֻҪ���� 2019.01.01������
select COUNT(1)������Ʊ���� from Topway..tbcash 
where datetime>='2019-01-01'
and cmpcode='020350'
and reti=''
and tickettype='����Ʊ'
and route not like'%��Ʊ%'
and route not like'%����%'
and route not like'%����%'

select COUNT(1)��Ʊ��Ʊ���� from Topway..tbcash 
where datetime>='2019-01-01'
and cmpcode='020350'
and (reti<>'' or route like'%��Ʊ%')
and tickettype='����Ʊ'
--and route not like'%��Ʊ%'
--and route not like'%����%'
--and route not like'%����%'

select count(1)��ǩ��Ʊ���� from Topway..tbcash 
where datetime>='2019-01-01'
and cmpcode='020350'
and reti=''
and (tickettype like'%����%' or tickettype like'%����%'
or route  like'%����%'
or route  like'%����%')
and route not like '%��Ʊ%'


select COUNT(1)�����Ƶ����,SUM(nights*pcs) ��ҹ��
from Topway..tbHtlcoupYf 
where cmpid='020350'
and prdate>='2019-01-01'
and status<>-2

--����۲��
select totsprice,profit, * from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno='AS002593214'


select Email, * from Topway..Emppwd 
--update Topway..Emppwd  set Email='rita.zhou@homsom.com'
where id='1707'


--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='019791_20190321'

--���㵥����   ���㵥��: 113520 �ѽ��� ����AS002571781 ��Ӧ����Դ����ȷ �������� �����ύ
select settleStatus,* from Topway..tbSettlementApp
--update topway..tbSettlementApp set settleStatus='3' 
where id='113520'

select wstatus,settleno,* from Topway..tbcash
--update topway..tbcash set wstatus='0',settleno='0' 
where settleno='113520'

select Status,* from topway..Tab_WF_Instance
--update topway..Tab_WF_Instance set Status='4' 
where BusinessID='113520'



--����Ʒר�ã��������Դ
select feiyong,feiyonginfo,profit,* from Topway..tbcash 
--update Topway..tbcash  set feiyong=300,profit=profit-300,feiyonginfo='������λMYI'
where coupno='AS002587784'

select feiyong,feiyonginfo,profit,* from Topway..tbcash 
--update Topway..tbcash  set feiyonginfo='������λMYI'
where coupno='AS002592197'

select feiyong,feiyonginfo,profit,* from Topway..tbcash 
--update Topway..tbcash  set feiyonginfo='������λMYI'
where coupno='AS002592290'

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno='AS002592779'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno='AS002589896' and id='4412886'

--��Ʊ��
--select pasname,tcode,ticketno,* from Topway..tbcash where coupno='AS002592758'
--update Topway..tbcash set pasname='',tcode='',ticketno='' where coupno ='AS002592758' and pasname=''
update Topway..tbcash set pasname='SHUI/Nuo',tcode='131',ticketno='2133709578' where coupno ='AS002592758' and pasname='�˿�0'
update Topway..tbcash set pasname='LIU/Li',tcode='131',ticketno='2133709579' where coupno ='AS002592758' and pasname='�˿�1'
update Topway..tbcash set pasname='HUA/Tianze',tcode='131',ticketno='2133709580' where coupno ='AS002592758' and pasname='�˿�2'
update Topway..tbcash set pasname='HUANG/Huihui',tcode='131',ticketno='2133709581' where coupno ='AS002592758' and pasname='�˿�3'
update Topway..tbcash set pasname='TAO/Xuechun',tcode='131',ticketno='2133709582' where coupno ='AS002592758' and pasname='�˿�4'
update Topway..tbcash set pasname='ZHOU/Jinyu',tcode='131',ticketno='2133709583' where coupno ='AS002592758' and pasname='�˿�5'
update Topway..tbcash set pasname='AI/Jing',tcode='131',ticketno='2133709584' where coupno ='AS002592758' and pasname='�˿�6'
update Topway..tbcash set pasname='ZHANG/Xuyang',tcode='131',ticketno='2133709585' where coupno ='AS002592758' and pasname='�˿�7'
update Topway..tbcash set pasname='WANG/Wanqi',tcode='131',ticketno='2133709586' where coupno ='AS002592758' and pasname='�˿�8'
update Topway..tbcash set pasname='LI/Hong',tcode='131',ticketno='2133709587' where coupno ='AS002592758' and pasname='�˿�9'
update Topway..tbcash set pasname='CHEN/Haofeng',tcode='131',ticketno='2133709588' where coupno ='AS002592758' and pasname='�˿�10'
update Topway..tbcash set pasname='CHU/Beiying',tcode='131',ticketno='2133709589' where coupno ='AS002592758' and pasname='�˿�11'
update Topway..tbcash set pasname='WAN/Yuting',tcode='131',ticketno='2133709590' where coupno ='AS002592758' and pasname='�˿�12'
update Topway..tbcash set pasname='HUANG/Xuejing',tcode='131',ticketno='2133709591' where coupno ='AS002592758' and pasname='�˿�13'
update Topway..tbcash set pasname='CHENG/Yiyun',tcode='131',ticketno='2133709592' where coupno ='AS002592758' and pasname='�˿�14'
update Topway..tbcash set pasname='WANG/Yueru',tcode='131',ticketno='2133709593' where coupno ='AS002592758' and pasname='�˿�15'


--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='�',SpareTC='�'
where coupno='AS001735675'

--����Ʒר�ã��������Դ
select feiyong,feiyonginfo,profit,* from Topway..tbcash 
--update Topway..tbcash  set feiyong='577',feiyonginfo='������λZYI',profit=profit-577
where coupno='AS002584440'

select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash  set feiyong='1400',feiyonginfo='������λZYI',profit=profit-1400
where coupno='AS002596334'

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='�',SpareTC='�'
where coupno='AS001735336'

--����֧����ʽ
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,* from Topway..tbcash 
--update Topway..tbcash set TCPayNo=PayNo,PayNo='',AdvanceStatus=PayStatus,PayStatus=0,TcPayWay=CustomerPayWay,CustomerPayWay=null,TcPayDate=CustomerPayDate,dzhxDate=CustomerPayDate,CustomerPayDate='1900-01-01'
where coupno in ('AS002588945')

select PayStatus,AdvanceStatus,PayNo,TCPayNo,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET AdvanceStatus=PayStatus,TCPayNo=PayNo,TcPayWay=CustomerPayWay,TcPayDate=CustomerPayDate,PayStatus=0,PayNo='',CustomerPayWay=0,CustomerPayDate=null
WHERE CoupNo in ('AS002588945')

--�����տ����
select Skstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Skstatus=2
where TrvId='30014' and Id in('227852','227860','228278')

--�޸�UC�ţ���Ʊ��
--select * from Topway..tbcash where cmpcode='020787'

select custid,cmpcode,ModifyBillNumber,ModifyBillNumber,pform,* from Topway..tbcash 
--update Topway..tbcash  set custid='D660877',cmpcode='020787',ModifyBillNumber='020787_20190601',ModifyBillNumber='020787_20190601'
where coupno='AS002533101'

select Cmpname,CmpId,* from Topway..tbFiveCoupInfo 
--update Topway..tbFiveCoupInfo set Cmpname='�����пƾ�о�Ƽ����޹�˾',CmpId='020787'
where CoupNo='AS002533101'

--�����˿��Ϣ
select AcountInfo,* from Topway..tbTrvKhTk 
--update Topway..tbTrvKhTk  set AcountInfo='�����£��Ϻ�������ó�����޹�˾||==||������У��й������޹�˾�Ϻ�����||==||088530878011'
where TrvId='30090'

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='������' ,SpareTC='������'
where coupno='AS001758940'

--�����˿��Ϣ
select * from Topway..tbTrvKhTk 
--update Topway..tbTrvKhTk set AcountInfo='������||==||20190612200040011100370074562255 ||==||13817828249||==||2019-06-12'
where TrvId='30133' 
