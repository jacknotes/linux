--ɾ���������
--select* from homsomDB..Trv_Cities where ID='06766E93-C64A-4ECF-A94E-508EDD01AA03'
select * 
--delete
from homsomDB..Trv_Airport where Code='HUN' 
and CityID='290F54BE-76BF-4B6B-9B29-0EC5F7189FA2'

--��Ʊ���ۼ���Ϣ
select TotFuprice,TotPrice,TotFuprice,TotSprice,TotUnitprice,* from Topway..tbTrainTicketInfo 
--update Topway..tbTrainTicketInfo set TotPrice=144,TotSprice=144,TotUnitprice=144
where CoupNo='RS000022924'

select SettlePrice,RealPrice,* from Topway..tbTrainUser 
--update Topway..tbTrainUser set SettlePrice=144,RealPrice=144
where TrainTicketNo=(select ID from Topway..tbTrainTicketInfo where CoupNo='RS000022924')

--����Ԥ�㵥��Ϣ
select Sales,OperName,introducer,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Sales='��֮��',OperName='0481��֮��',introducer='��֮��-0481-��Ӫ��'
where ConventionId in('1388','1088','1363','1371','1212','1211','1369','1169','940','1254','1086','1210',
'1015','1368','1107','1076','1070','1377')

--�ν�4�·ݹ��ʻ�Ʊ����
select cmpcode,coupno,tcode+ticketno,sales,SpareTC from Topway..tbcash 
where sales='�ν�' and SpareTC='�ν�'
and datetime>='2019-04-01'
and inf=1
--and reti=''
and tickettype not like '%����%'
and tickettype not like '%����%'
and route not like '%���ڷ�%'
and route not like '%���շ�%'
and route not like '%��Ʊ��%'
and sales<>''
and cmpcode<>''


select cmpcode,coupno,tcode+ticketno,sales,SpareTC from Topway..tbcash 
where sales='�ν�' and SpareTC='�ν�'
and datetime>='2019-04-01'
and inf=1
--and reti=''
and tickettype not like '%����%'
and tickettype not like '%����%'
and route not like '%���ڷ�%'
and route not like '%���շ�%'
and route not like '%��Ʊ��%'
and sales<>''
and cmpcode=''
and totprice=0

select cmpcode,coupno,tcode+ticketno,sales,SpareTC from Topway..tbcash 
where sales<>SpareTC and SpareTC='�ν�'
and datetime>='2019-04-01'
and inf=1
--and reti=''
and tickettype not like '%����%'
and tickettype not like '%����%'
and route not like '%���ڷ�%'
and route not like '%���շ�%'
and route not like '%��Ʊ��%'
and sales<>''
and cmpcode<>''
and totprice=0

select cmpcode,coupno,tcode+ticketno,sales,SpareTC from Topway..tbcash 
where sales<>SpareTC and SpareTC='�ν�'
and datetime>='2019-04-01'
and inf=1
--and reti=''
and tickettype not like '%����%'
and tickettype not like '%����%'
and route not like '%���ڷ�%'
and route not like '%���շ�%'
and route not like '%��Ʊ��%'
and sales<>''
and cmpcode=''
and totprice=0

select cmpcode,coupno,tcode+ticketno,sales,SpareTC from Topway..tbcash 
where sales<>SpareTC and sales='�ν�'
and datetime>='2019-04-01'
and inf=1
--and reti=''
and tickettype not like '%����%'
and tickettype not like '%����%'
and route not like '%���ڷ�%'
and route not like '%���շ�%'
and route not like '%��Ʊ��%'
and sales<>''
and cmpcode<>''
and totprice=0

select  r.cmpcode,r.coupno,c.tcode+c.ticketno,c.sales,c.SpareTC from Topway..tbReti r
left join Topway..tbcash c on c.reti=r.reno and c.ticketno=r.ticketno
 where r.inf=1
 and r.status2 not in (1,3,4) 
 and ExamineDate >='2019-04-01'
and c.cmpcode<>''
and c.sales<>SpareTC and  c.SpareTC='�ν�'
and c.cmpcode=''

select  r.cmpcode,r.coupno,c.tcode+c.ticketno,c.sales,c.SpareTC from Topway..tbReti r
left join Topway..tbcash c on c.reti=r.reno and c.ticketno=r.ticketno
 where r.inf=1
 and r.status2 not in (1,3,4) 
 and ExamineDate >='2019-04-01'
and c.cmpcode<>''
and c.sales<>SpareTC and  c.SpareTC='�ν�'
and c.cmpcode<>''

select  r.cmpcode,r.coupno,c.tcode+c.ticketno,c.sales,c.SpareTC from Topway..tbReti r
left join Topway..tbcash c on c.reti=r.reno and c.ticketno=r.ticketno
 where r.inf=1
 and r.status2 not in (1,3,4) 
 and ExamineDate >='2019-04-01'
and c.cmpcode<>''
and c.sales<>SpareTC and  c.sales='�ν�'
and c.cmpcode<>''

select  r.cmpcode,r.coupno,c.tcode+c.ticketno,c.sales,c.SpareTC from Topway..tbReti r
left join Topway..tbcash c on c.reti=r.reno and c.ticketno=r.ticketno
 where r.inf=1
 and r.status2 not in (1,3,4) 
 and ExamineDate >='2019-04-01'
and c.cmpcode<>''
and c.sales='�ν�' and  c.SpareTC='�ν�'
and c.cmpcode<>''

select  r.cmpcode,r.coupno,c.tcode+c.ticketno,c.sales,c.SpareTC from Topway..tbReti r
left join Topway..tbcash c on c.reti=r.reno and c.ticketno=r.ticketno
 where r.inf=1
 and r.status2 not in (1,3,4) 
 and ExamineDate >='2019-04-01'
and c.cmpcode<>''
and c.sales='�ν�' and  c.SpareTC='�ν�'
and c.cmpcode=''



SELECT sales,SpareTC,* FROM Topway..tbcash WHERE coupno='AS002384092'

--��������
select  ModifyDate,Status, * from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Status='14'
where ConventionId='1167'

select ModifyDate,Status,* 
--delete
from Topway..tbConventionCoup where ConventionId='1167'


--������
--select pasname,* from Topway..tbcash where coupno='AS002386292'
--update Topway..tbcash set pasname='' where coupno='AS002386292' and pasname=''

update Topway..tbcash set pasname='HUANG/XINYI' where coupno='AS002386292' and pasname='�˿�0'
update Topway..tbcash set pasname='HUANG/YIMENG' where coupno='AS002386292' and pasname='�˿�1'
update Topway..tbcash set pasname='JIANG/XUE' where coupno='AS002386292' and pasname='�˿�2'
update Topway..tbcash set pasname='KE/YUXING' where coupno='AS002386292' and pasname='�˿�3'
update Topway..tbcash set pasname='LIN/JIAYU' where coupno='AS002386292' and pasname='�˿�4'
update Topway..tbcash set pasname='LIU/SICHEN' where coupno='AS002386292' and pasname='�˿�5'
update Topway..tbcash set pasname='LU/YIWEN' where coupno='AS002386292' and pasname='�˿�6'
update Topway..tbcash set pasname='PAN/WANJING' where coupno='AS002386292' and pasname='�˿�7'
update Topway..tbcash set pasname='SHENG/HUIYING' where coupno='AS002386292' and pasname='�˿�8'
update Topway..tbcash set pasname='TAO/LELE' where coupno='AS002386292' and pasname='�˿�9'

update Topway..tbcash set pasname='WANG/JIAYIN ' where coupno='AS002386294' and pasname='�˿�0'
update Topway..tbcash set pasname='WANG/QINGFENG ' where coupno='AS002386294' and pasname='�˿�1'
update Topway..tbcash set pasname='WANG/YONGLIN   ' where coupno='AS002386294' and pasname='�˿�2'
update Topway..tbcash set pasname='WU/WENPING ' where coupno='AS002386294' and pasname='�˿�3'
update Topway..tbcash set pasname='YU/WEI  ' where coupno='AS002386294' and pasname='�˿�4'
update Topway..tbcash set pasname='YUE/BING   ' where coupno='AS002386294' and pasname='�˿�5'
update Topway..tbcash set pasname='ZHAI/ZHI  ' where coupno='AS002386294' and pasname='�˿�6'
update Topway..tbcash set pasname='ZHANG/XIAOMEI   ' where coupno='AS002386294' and pasname='�˿�7'
update Topway..tbcash set pasname='ZHU/LIN  ' where coupno='AS002386294' and pasname='�˿�8'
update Topway..tbcash set pasname='WANG/HAIXUE ' where coupno='AS002386294' and pasname='�˿�9'
update Topway..tbcash set pasname='OU/YIJOU  ' where coupno='AS002386294' and pasname='�˿�10'

update Topway..tbcash set pasname='FENG/XIAOBEI' where coupno='AS002386293' and pasname='5��16���ռ���36����'

update Topway..tbcash set pasname='CHEN/LI ' where coupno='AS002386295' and pasname='�˿�0'
update Topway..tbcash set pasname='CHEN/YANXI' where coupno='AS002386295' and pasname='�˿�1'
update Topway..tbcash set pasname='CHEN/YING ' where coupno='AS002386295' and pasname='�˿�2'
update Topway..tbcash set pasname='GONG/SHICHUN ' where coupno='AS002386295' and pasname='�˿�3'
update Topway..tbcash set pasname='GUO/ZHENGJIANG ' where coupno='AS002386295' and pasname='�˿�4'
update Topway..tbcash set pasname='HAN/WANGXIN' where coupno='AS002386295' and pasname='�˿�5'
update Topway..tbcash set pasname='HU/MEIYING ' where coupno='AS002386295' and pasname='�˿�6'
update Topway..tbcash set pasname='HU/YATING ' where coupno='AS002386295' and pasname='�˿�7'
update Topway..tbcash set pasname='HUANG/TING   ' where coupno='AS002386295' and pasname='�˿�8'
update Topway..tbcash set pasname='HUANG/WENQI ' where coupno='AS002386295' and pasname='�˿�9'

--018890��λ����
--select * from Topway..tbCompanyM where cmpid='018890'
--select *from homsomDB..Trv_UnitCompanies where Cmpid='018890'

select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement set CompanyNameCN='�Ϻ���¡�ż�������޹�˾'
where BillNumber='018890_20190426'

--ɾ���طü�¼
SELECT UnitCompanyID,* FROM homsomdb..Trv_Memos
--update homsomdb..Trv_Memos set UnitCompanyID=null
WHERE UnitCompanyID in (select id from homsomdb..Trv_UnitCompanies where Cmpid='018178')
and ID in('0535A70A-F608-4D5F-ACE4-AA3E00E81432')

--�˵�����
select dzhxDate,status,oper2,* from Topway..tbcash 
--update Topway..tbcash  set dzhxDate='2019-04-26',status=1,oper2='�ܫh��'
where ModifyBillNumber='018661_20190301'

--ɾ�����㷽ʽ
select * from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner  set Status=-1
where CmpId='020808' and Status=2

SELECT * FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set Status=-1
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '020808') and Status=2

--�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='Я�̹�����������'
where CoupNo='PTW080720'

--�޸�UC�ţ���Ʊ��
select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,pform,xfprice,* from Topway..tbcash
--update topway..tbcash set cmpcode='016888',OriginalBillNumber='016888_20190326'
 where coupno in ('AS002430325')
 
 --����Ʒר�ã��������Դ/�����Ϣ�����ڣ�
 select feiyonginfo,feiyong,* from Topway..tbcash 
 --update Topway..tbcash set feiyonginfo='����YGD',feiyong=10
 where coupno in('AS002396125','AS002396843','AS002397428','AS002397466'
 ,'AS002408366','AS002405059','AS002407574','AS002419523')
 
 --����۲��
 select totsprice,profit,* from Topway..tbcash 
 --update Topway..tbcash  set totsprice=8980,profit=1101
 where coupno ='AS002435367'
 
  select totsprice,profit,* from Topway..tbcash 
 --update Topway..tbcash  set totsprice=8963,profit=811
 where coupno ='AS002434427'
 
 
 --��Ʊҵ�������Ϣ
 select sales,SpareTC,* from Topway..tbcash 
 --update Topway..tbcash  set sales='����',SpareTC='����'
 where coupno='AS002433360'
 
 --�˵�����
 select SubmitState,* from Topway..AccountStatement 
 --update Topway..AccountStatement  set SubmitState=1
 where BillNumber in('018309_20190201','018309_20190301')
 
 
 --����۲��
 select totsprice,profit,* from Topway..tbcash 
 --update Topway..tbcash  set totsprice=4083,profit=-1
 where coupno='AS002432908' and totsprice=4082.000
 
  select totsprice,profit,* from Topway..tbcash 
 --update Topway..tbcash  set totsprice=6151,profit=1438
 where coupno='AS002435612' 
 
--��Ʊ��
--select pasname,* from Topway..tbcash where coupno='AS002436636'
--update Topway..tbcash set tcode='',ticketno='',pasname='' where coupno='AS002436636' and pasname=''
update Topway..tbcash set tcode='781',ticketno='2400314721',pasname='CHEN/JINGSHU' where coupno='AS002436636' and pasname='�˿�0'
update Topway..tbcash set tcode='781',ticketno='2400314722',pasname='CHENG/CHAOWEN' where coupno='AS002436636' and pasname='�˿�1'
update Topway..tbcash set tcode='781',ticketno='2400314723',pasname='HUANG/HUIQIN' where coupno='AS002436636' and pasname='�˿�2'
update Topway..tbcash set tcode='781',ticketno='2400314724',pasname='LI/HUI' where coupno='AS002436636' and pasname='�˿�3'
update Topway..tbcash set tcode='781',ticketno='2400314725',pasname='LIU/AIPING' where coupno='AS002436636' and pasname='�˿�4'
update Topway..tbcash set tcode='781',ticketno='2400314726',pasname='LIU/JUAN' where coupno='AS002436636' and pasname='�˿�5'
update Topway..tbcash set tcode='781',ticketno='2400314727',pasname='TIAN/CHUNCHUN' where coupno='AS002436636' and pasname='�˿�6'
update Topway..tbcash set tcode='781',ticketno='2400314728',pasname='WEN/XIAOYI' where coupno='AS002436636' and pasname='�˿�7'
update Topway..tbcash set tcode='781',ticketno='2400314729',pasname='XIA/NANKAI' where coupno='AS002436636' and pasname='�˿�8'
update Topway..tbcash set tcode='781',ticketno='2400314730',pasname='YUAN/JIANYING' where coupno='AS002436636' and pasname='�˿�9'

--UC018781ɾ��Ա���ű� TMS
select * from  homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (
select a.ID from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018781')
and IsDisplay=1 and Name not in ('������','����','����Ө')
)


--ɾ��Ա���ű�ERP
select EmployeeStatus,* from Topway..tbCusholderM 
--update Topway..tbCusholderM  set EmployeeStatus=0
where cmpid='018781' and custname not in ('������','����','����Ө')

--�����տ��ӡ
select Pstatus,PrDate,* from Topway..tbTrvKhSk 

where TrvId='29997' and Id='227817'

select sales,* from Topway..tbcash 
--update Topway..tbcash set sales='�ν�'
where coupno='AS002384092'

--������Ŀ���
--select * from homsomdb..Trv_UnitCompanies where Cmpid='020805'
--select * from homsomdb..Trv_Customizations
--insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���',0,'���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�к�',0,'�к�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���',0,'���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��',0,'��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��',0,'��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'ɽ������',0,'ɽ������','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'̩��',0,'̩��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'³��',0,'³��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�¿�˹',0,'�¿�˹','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�½��',0,'�½��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��ҫ��',0,'��ҫ��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���',0,'���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���ϲ���',0,'���ϲ���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�ް�',0,'�ް�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���ź���',0,'���ź���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���ݸ�',0,'���ݸ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��ϣ��',0,'��ϣ��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��Ͷ',0,'��Ͷ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���',0,'���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�㽭����',0,'�㽭����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��Ͷ',0,'��Ͷ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��ó',0,'��ó','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�ལ��',0,'�ལ��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��������',0,'��������','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��ɽ',0,'��ɽ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'׿Խ',0,'׿Խ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�̵�',0,'�̵�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�ٺ�',0,'�ٺ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'Ŧ����',0,'Ŧ����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'ʥ��',0,'ʥ��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����װ��',0,'����װ��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�λ�',0,'�λ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��ͨ����',0,'��ͨ����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�̹�԰',0,'�̹�԰','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��',0,'��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����ʢ',0,'����ʢ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�人���',0,'�人���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'Ԫ¢',0,'Ԫ¢','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'·��',0,'·��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�׿�',0,'�׿�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���ͺ�ͨ',0,'���ͺ�ͨ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�ڻ�',0,'�ڻ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���ó�',0,'���ó�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�Ϸ�����',0,'�Ϸ�����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�����ʢ',0,'�����ʢ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�κ�',0,'�κ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�ž���',0,'�ž���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��ó',0,'��ó','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���ƽ�',0,'���ƽ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���ؽ����',0,'���ؽ����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��������',0,'��������','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�г�',0,'�г�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���Ƽ���',0,'���Ƽ���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��̩',0,'��̩','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'������ҵ',0,'������ҵ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���Ű���',0,'���Ű���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��������',0,'��������','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����100',0,'����100','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'ɽ����ƽ',0,'ɽ����ƽ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���',0,'���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�¸߶�',0,'�¸߶�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'̩��',0,'̩��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'������',0,'������','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���',0,'���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���ް�',0,'���ް�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��ʢ',0,'��ʢ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'������',0,'������','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�����',0,'�����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���',0,'���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����סլ',0,'����סլ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�ɶ�������',0,'�ɶ�������','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��ï',0,'��ï','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'Э��',0,'Э��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�н�����',0,'�н�����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����ͨ��',0,'����ͨ��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�ʺ�',0,'�ʺ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��Ϊ',0,'��Ϊ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�н��߾�',0,'�н��߾�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��Ÿ��',0,'��Ÿ��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�����ҵ',0,'�����ҵ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�����ҵ',0,'�����ҵ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�ڰ�',0,'�ڰ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�Ŵ�',0,'�Ŵ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���',0,'���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��ʢ',0,'��ʢ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���',0,'���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�н����',0,'�н����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�к�',0,'�к�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���',0,'���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�����õ�',0,'�����õ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���',0,'���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'������',0,'������','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�Ǻ��ʱ�',0,'�Ǻ��ʱ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'Խ��',0,'Խ��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�Ͼ�̩��',0,'�Ͼ�̩��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'³��',0,'³��','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��ï',0,'��ï','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�׵�',0,'�׵�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��ԭ',0,'��ԭ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'������ҵ',0,'������ҵ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��ҵ',0,'��ҵ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��������',0,'��������','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�״�',0,'�״�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�н��˾�',0,'�н��˾�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���',0,'���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����ҵ',0,'����ҵ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�гǽ�',0,'�гǽ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�и�',0,'�и�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���',0,'���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�ڳϴ�',0,'�ڳϴ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�׸�',0,'�׸�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��ľ',0,'��ľ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�з�',0,'�з�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'��Ͷ',0,'��Ͷ','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���ݵ���',0,'���ݵ���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���ȳ�',0,'���ȳ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'������',0,'������','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�³ǿع�',0,'�³ǿع�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���',0,'���','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�����ڷ�',0,'�����ڷ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'�������',0,'�������','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'���˼ʻ�',0,'���˼ʻ�','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'����',0,'����','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')


/*
UC020758�Ͳ�ҽҩ���Ϻ����������ι�˾�����æ��һ�ݽ�ֹĿǰ��ȫ�����÷��ñ��棬лл��

��������������ݣ�Ԥ���ˣ��г̣����ڣ��۸��
*/
select pasname,route,convert(varchar(10),datetime,120),begdate,totprice,reti
from Topway..tbcash 
where cmpcode='020758' 
order by datetime




/*
���ھ��òղ��֣��밴������9-12���˵��ṩ�������ݣ�
1.��Υ����������Ʊ�ۼ���������Reason Code������ռ��
2.����Υ��ſ�������������Υ�������Υ��ռ��
3.Ա��Ԥ����Ϊ�������ͼ�δ����ռ�ȣ��˸�ǩռ�ȣ�Υ����          ��
4.Ա��Υ�����������ǰ10λ�������� ����  Υ�����
5.�ͼ����ѽ�֧�������·ݣ�9--12������Ʊ���ѽ���Ʊ�������ͼ����Ѵ�����Ǳ�ڿɽ�ʡ���

PS:9���˵��У���������ͼۣ���Reason Code�Ļ�Ʊֱ���޳�
*/

--1.��Υ����������Ʊ�ۼ���������Reason Code������ռ��
select coupno ���۵���,tcode+ticketno Ʊ��,c.price ���۵���,isnull(l.Price,'') ��ͼ�,isnull(de.ReasonDescription,'') Reasoncode
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber and pasname=PassengerNames
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookings i1 on p.ItktBookingID=i1.ID
left join homsomDB..Trv_DeniedReason de on de.ItktBookingID=i1.ID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=i1.ID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%���ò�%'
and c.tickettype NOT IN ('���ڷ�', '���շ�','��������')
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274','AS002121652')
and c.price>isnull(l.Price,'')
and isnull(l.Price,'')>0

select tcode+ticketno,SUM(c.price)ʵ�ʼ�����,sum(l.Price) ��ͼ�����,isnull(de.ReasonDescription,'') Reasoncode,COUNT(1) ReasonCode����
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber and pasname=PassengerNames
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookings i1 on p.ItktBookingID=i1.ID
left join homsomDB..Trv_DeniedReason de on de.ItktBookingID=i1.ID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=i1.ID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%���ò�%'
and c.tickettype NOT IN ('���ڷ�', '���շ�','��������')
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274','AS002121652')
and c.price>isnull(l.Price,'')
and isnull(l.Price,'')>0
group by isnull(de.ReasonDescription,''),tcode+ticketno

--2.����Υ��ſ�������������Υ�������Υ��ռ��
select coupno,tcode+ticketno,c.Department,sum(c.price) ʵ�ʼ�����,sum(l.Price) ��ͼ�����,isnull(de.ReasonDescription,'') Reasoncode,COUNT(1) ReasonCode����
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber and pasname=PassengerNames
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookings i1 on p.ItktBookingID=i1.ID
left join homsomDB..Trv_DeniedReason de on de.ItktBookingID=i1.ID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=i1.ID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%���ò�%'
and c.tickettype NOT IN ('���ڷ�', '���շ�','��������')
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274','AS002121652')
and c.price>isnull(l.Price,'')
and isnull(l.Price,'')>0
group by isnull(de.ReasonDescription,''),c.Department,tcode+ticketno,coupno
order by c.Department

--Ա��Υ�����������ǰ10λ�������� ����  Υ�����

select top 10 c.Department,pasname,sum(c.price) ʵ�ʼ�����,sum(l.Price) ��ͼ�����,COUNT(1) ReasonCode����
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber and pasname=PassengerNames
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookings i1 on p.ItktBookingID=i1.ID
left join homsomDB..Trv_DeniedReason de on de.ItktBookingID=i1.ID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=i1.ID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%���ò�%'
and c.tickettype NOT IN ('���ڷ�', '���շ�','��������')
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274','AS002121652')
and c.price>isnull(l.Price,'')
and isnull(l.Price,'')>0
group by c.Department,pasname
order by ReasonCode���� desc

select  c.Department,pasname,sum(c.price) ʵ�ʼ�����,sum(l.Price) ��ͼ�����,isnull(de.ReasonDescription,''),COUNT(1) ReasonCode����
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber and pasname=PassengerNames
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookings i1 on p.ItktBookingID=i1.ID
left join homsomDB..Trv_DeniedReason de on de.ItktBookingID=i1.ID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=i1.ID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%���ò�%'
and c.tickettype NOT IN ('���ڷ�', '���շ�','��������')
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274','AS002121652')
and c.price>isnull(l.Price,'')
and isnull(l.Price,'')>0
and pasname in ('л�ݳ�',
'�����',
'���',
'������',
'����',
'�ƌk',
'����',
'����',
'���',
'��쳽�')
group by c.Department,pasname,isnull(de.ReasonDescription,'')
order by ReasonCode���� desc

--�ͼ����ѽ�֧�������·ݣ�9--12������Ʊ���ѽ���Ʊ�������ͼ����Ѵ�����Ǳ�ڿɽ�ʡ���

select sum(c.price) ��������˰,sum(isnull(l.Price,'')) ��ͼ�����
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber and pasname=PassengerNames
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookings i1 on p.ItktBookingID=i1.ID
left join homsomDB..Trv_DeniedReason de on de.ItktBookingID=i1.ID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=i1.ID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%���ò�%'
and c.tickettype NOT IN ('���ڷ�', '���շ�','��������')
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274','AS002121652')
and c.price>isnull(l.Price,'')



