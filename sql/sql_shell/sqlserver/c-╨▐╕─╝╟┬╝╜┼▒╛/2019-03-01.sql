--�޸���Ʊ״̬�ѽ���
select status,status2,* from Topway..tbReti 
--update Topway..tbReti set status2=7
where reno='9264956'

--�޸Ľ���۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=6117,profit=636
where coupno='AS002270384'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=9623,profit=977
where coupno='AS002270832'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=5566,profit=426
where coupno='AS002270840'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=5241,profit=630
where coupno='AS002273400'

--��ӡȨ��
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId  in ('029635','029634') and Pstatus=1

--ɾ������
delete from FinanceERP_ClientBankRealIncomeDetail where money='47120' and date='2019-02-27' and state=0

--���ĵ�λ̧ͷ
--select cmpname,* from Topway..tbCompanyM where cmpid='017189'
--select * from homsomDB..Trv_UnitCompanies where Cmpid='017189'
select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement set CompanyNameCN='ӡ��ɪ˹������ѯ���Ϻ������޹�˾'
where  BillNumber='017189_20190301'

--���42��
select Pasname,MobileList,Idno,CostCenter,pcs,Department,BirthPlace,* from tbFiveCoupInfosub 
--update tbFiveCoupInfosub set Idno=Idno+',��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��',
--MobileList=MobileList+',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',
--CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',
--pcs='42',
--Department='��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��',
--Pasname=Pasname+',�˿�2,�˿�3,�˿�4,�˿�5,�˿�6,�˿�7,�˿�8,�˿�9,�˿�10,�˿�11,�˿�12,�˿�13,�˿�14,�˿�15,�˿�16,�˿�17,�˿�18,�˿�19,�˿�20,�˿�21,�˿�22,�˿�23,�˿�24,�˿�25,�˿�26,�˿�27,�˿�28,�˿�29,�˿�30,�˿�31,�˿�32,�˿�33,�˿�34,�˿�35,�˿�36,�˿�37,�˿�38,�˿�39,�˿�40,�˿�41,�˿�42',
--BirthPlace='1982-01-03,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01'
where FkfiveNo in (select fiveno from tbFiveCoupInfo where CoupNo='AS002283212')

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='018643_20190101'

--�޸Ĺ�Ӧ��
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='ZSBSPETI'
where coupno='AS002282010'

--�ؿ���ӡ
select PrintTime,CustDate,CustId,CustStat,* from Topway..tbExtraPayment 
--update Topway..tbExtraPayment  set PrintTime='',CustDate='',CustId='',CustStat=''
where Id='51590'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='018643_20190101'

--UC020583ƥ��Ԥ���ˣ�����Ŀ�ĺ�REASON CODE
select h.CoupNo as ���۵���,t.pasname as Ԥ����,isnull(Purpose,'') as ����Ŀ��,isnull(ReasonDescription,'') as REASONCODE from HotelOrderDB..HTL_Orders h
left join Topway..tbHtlcoupYf t on t.CoupNo=h.CoupNo
where h.CoupNo in ('PTW076231',
'PTW076688',
'PTW076707',
'PTW076802',
'PTW076799',
'PTW076779',
'PTW076843',
'PTW076897',
'PTW076940')

--��Ʊ��
--select tcode+ticketno,pasname,* from Topway..tbcash where coupno='AS002283187'
update topway..tbcash set pasname='YING/BIJUN',tcode='205',ticketno='2411500943' where coupno in ('AS002283212') and pasname='ZHANG/HUI'
update topway..tbcash set pasname='ZHANG/HUI',tcode='205',ticketno='2411500944' where coupno in ('AS002283212') and pasname='�˿�2'
update topway..tbcash set pasname='GONG/ZHEN',tcode='205',ticketno='2411500945' where coupno in ('AS002283212') and pasname='�˿�3'
update topway..tbcash set pasname='QIAN/ZHONGHONG',tcode='205',ticketno='2411500946' where coupno in ('AS002283212') and pasname='�˿�4'
update topway..tbcash set pasname='MIAO/WENJIN',tcode='205',ticketno='2411500947' where coupno in ('AS002283212') and pasname='�˿�5'
update topway..tbcash set pasname='GE/MEILIN',tcode='205',ticketno='2411500948' where coupno in ('AS002283212') and pasname='�˿�6'
update topway..tbcash set pasname='XU/TING',tcode='205',ticketno='2411500949' where coupno in ('AS002283212') and pasname='�˿�7'
update topway..tbcash set pasname='TONG/JIALIN',tcode='205',ticketno='2411500950' where coupno in ('AS002283212') and pasname='�˿�8'
update topway..tbcash set pasname='ZHU/WEIDONG',tcode='205',ticketno='2411500951' where coupno in ('AS002283212') and pasname='�˿�9'
update topway..tbcash set pasname='BAO/JUN',tcode='205',ticketno='2411500952' where coupno in ('AS002283212') and pasname='�˿�10'
update topway..tbcash set pasname='BAO/GUOFENG',tcode='205',ticketno='2411500953' where coupno in ('AS002283212') and pasname='�˿�11'
update topway..tbcash set pasname='ZHANG/JIE',tcode='205',ticketno='2411500954' where coupno in ('AS002283212') and pasname='�˿�12'
update topway..tbcash set pasname='ZHU/HAIYAN',tcode='205',ticketno='2411500955' where coupno in ('AS002283212') and pasname='�˿�13'
update topway..tbcash set pasname='LI/JING',tcode='205',ticketno='2411500956' where coupno in ('AS002283212') and pasname='�˿�14'
update topway..tbcash set pasname='TANG/JIANFENG',tcode='205',ticketno='2411500957' where coupno in ('AS002283212') and pasname='�˿�15'
update topway..tbcash set pasname='FENG/MIN',tcode='205',ticketno='2411500958' where coupno in ('AS002283212') and pasname='�˿�16'
update topway..tbcash set pasname='ZENG/YI',tcode='205',ticketno='2411500959' where coupno in ('AS002283212') and pasname='�˿�17'
update topway..tbcash set pasname='ZHU/JINGJIE',tcode='205',ticketno='2411500960' where coupno in ('AS002283212') and pasname='�˿�18'
update topway..tbcash set pasname='WANG/JING',tcode='205',ticketno='2411500961' where coupno in ('AS002283212') and pasname='�˿�19'
update topway..tbcash set pasname='CHEN/THOMAS',tcode='205',ticketno='2411500962' where coupno in ('AS002283212') and pasname='�˿�20'
update topway..tbcash set pasname='LU/YIQIAN',tcode='205',ticketno='2411500963' where coupno in ('AS002283212') and pasname='�˿�21'
update topway..tbcash set pasname='ZHAO/HUA',tcode='205',ticketno='2411500964' where coupno in ('AS002283212') and pasname='�˿�22'
update topway..tbcash set pasname='JIN/YAJUN',tcode='205',ticketno='2411500965' where coupno in ('AS002283212') and pasname='�˿�23'
update topway..tbcash set pasname='LAI/TING',tcode='205',ticketno='2411500966' where coupno in ('AS002283212') and pasname='�˿�24'
update topway..tbcash set pasname='HUANG/HUANG',tcode='205',ticketno='2411500967' where coupno in ('AS002283212') and pasname='�˿�25'
update topway..tbcash set pasname='XIA/GUILING',tcode='205',ticketno='2411500968' where coupno in ('AS002283212') and pasname='�˿�26'
update topway..tbcash set pasname='QIAN/YUYANG',tcode='205',ticketno='2411500969' where coupno in ('AS002283212') and pasname='�˿�27'
update topway..tbcash set pasname='YANG/RUOYING',tcode='205',ticketno='2411500970' where coupno in ('AS002283212') and pasname='�˿�28'
update topway..tbcash set pasname='SONG/YIWEN',tcode='205',ticketno='2411500971' where coupno in ('AS002283212') and pasname='�˿�29'
update topway..tbcash set pasname='ZHAO/LEI',tcode='205',ticketno='2411500972' where coupno in ('AS002283212') and pasname='�˿�30'
update topway..tbcash set pasname='FEI/RUJUAN',tcode='205',ticketno='2411500973' where coupno in ('AS002283212') and pasname='�˿�31'
update topway..tbcash set pasname='DENG/CHEXIZI',tcode='205',ticketno='2411500974' where coupno in ('AS002283212') and pasname='�˿�32'
update topway..tbcash set pasname='SHI/YINGTING',tcode='205',ticketno='2411500975' where coupno in ('AS002283212') and pasname='�˿�33'
update topway..tbcash set pasname='ZHAO/LUOJIE',tcode='205',ticketno='2411500976' where coupno in ('AS002283212') and pasname='�˿�34'
update topway..tbcash set pasname='LI/HUA',tcode='205',ticketno='2411500977' where coupno in ('AS002283212') and pasname='�˿�35'
update topway..tbcash set pasname='WANG/JIAYUAN',tcode='205',ticketno='2411500978' where coupno in ('AS002283212') and pasname='�˿�36'
update topway..tbcash set pasname='ZHU/YIHUA',tcode='205',ticketno='2411500979' where coupno in ('AS002283212') and pasname='�˿�37'
update topway..tbcash set pasname='SONG/YUN',tcode='205',ticketno='2411500980' where coupno in ('AS002283212') and pasname='�˿�38'
update topway..tbcash set pasname='CHEN/YU',tcode='205',ticketno='2411500981' where coupno in ('AS002283212') and pasname='�˿�39'
update topway..tbcash set pasname='ZHANG/MIAO',tcode='205',ticketno='2411500982' where coupno in ('AS002283212') and pasname='�˿�40'
update topway..tbcash set pasname='CHEN/JINGWEI',tcode='205',ticketno='2411500983' where coupno in ('AS002283212') and pasname='�˿�41'
update topway..tbcash set pasname='XUE/JING',tcode='205',ticketno='2411500984' where coupno in ('AS002283212') and pasname='�˿�42'
update topway..tbcash set pasname='OHARA/TOSHIHIRO',tcode='205',ticketno='2411500985' where coupno in ('AS002283187') and pasname='OHARA/TOSHIHIRO'
update topway..tbcash set pasname='NAKAI/KENJI',tcode='205',ticketno='2411500986' where coupno in ('AS002283187') and pasname='NAKAI/KENJI'
update topway..tbcash set pasname='HAGIWARA/TORU',tcode='205',ticketno='2411500987' where coupno in ('AS002283187') and pasname='HAGIWARA/TORU'

--��ӡȨ��
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='029539' and Id='227051'


--�Ƶ����۵��渶���Ը�
select AdvanceMethod,PayMethod,AdvanceStatus,PayStatus,AdvancePayNo,PayNo,AdvanceDate,PaySubmitDate from Topway..tbHtlcoupRefund 
--update Topway..tbHtlcoupRefund  set AdvanceMethod=null,PayMethod=3,AdvanceStatus=0,PayStatus=3,PayNo='4200000285201902280439223864',AdvancePayNo=null,PaySubmitDate='2019-02-28 17:59:25.850',AdvanceDate=null
where CoupNo='PTW077047'

select AdvanceNumber,AdvanceName,AdvanceStatus,AdvanceDate,PayStatus,PayDate from HotelOrderDB..HTL_Orders 
--update HotelOrderDB..HTL_Orders set AdvanceNumber='',AdvanceName='',PayStatus=3,AdvanceStatus=0,PayDate='2019-02-28 17:59:06.000',AdvanceDate=null
where CoupNo='PTW077047'

select AdvancePayNo,PayNo,AdvanceMethod,PayMethod,* from HotelOrderDB..HTL_OrderSettlements 
--update HotelOrderDB..HTL_OrderSettlements  set PayNo='4200000285201902280439223864',AdvancePayNo=null,PayMethod=3,AdvanceMethod=null
where OrderID in(Select OrderID from HotelOrderDB..HTL_Orders where CoupNo='PTW077047')

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber in('018449_20190201','018398_20190201')

--��������С��
select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=2,totsprice=2
where coupno in ('AS002254535',
'AS002254536',
'AS002267153',
'AS002277606',
'AS002277719',
'AS002280540',
'AS002280541',
'AS002280542',
'AS002280543',
'AS002280582',
'AS002280583',
'AS002280584',
'AS002280585')

--ɾ��������㵥��
select * from  topway..tbSettlementAppInception WHERE id='43119'
select * from topway..tbcashInception WHERE settleno='43119'

--delete FROM topway..tbSettlementAppInception WHERE id='43119'
--delete FROM topway..tbcashInception WHERE settleno='43119'

select * from  topway..tbSettlementAppInception WHERE id='43121'
select * from topway..tbcashInception WHERE settleno='43121'

--delete FROM topway..tbSettlementAppInception WHERE id='43121'
--delete FROM topway..tbcashInception WHERE settleno='43121'

--��ӡȨ��
select PrDate,Pstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set PrDate='1900-01-01',Pstatus=0
where TrvId='29539' and Id='227051'

--��ӡȨ��
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus=0,PrDate='1900-01-01'
where TrvId in ('029635','029634') and Id in ('227115','227103')

select PrDate,Pstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set PrDate='1900-01-01',Pstatus=0
where TrvId='029593'

SELECT distinct AirCompanyCode,t_source FROM homsomDB..trv_Disc_hf order by  t_source
select * from homsomDB..trv_Disc_hf where t_source='HS���̺ͻ�I'
insert into homsomDB..trv_Disc_hf values(NEWID(),'code','name','t_source','0050���','2019-03-01','','2019-03-01',0)