--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020410_20190501'

--�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='Ա���渶���������п���'
where CoupNo='PTW085256'

--��Ʊ���۵�����
select * 
--delete
from Topway..tbTrainUser where TrainTicketNo in(Select ID from Topway..tbTrainTicketInfo 
where CoupNo in('RS000025685','RS000025686','RS000025687'))

Select * 
--delete
from Topway..tbTrainTicketInfo 
where CoupNo in('RS000025685','RS000025686','RS000025687')


--��Ʊ
SELECT t1.RecordNumber,t5.Name 
FROM homsomDB..Trv_DomesticTicketRecord t1
left join homsomDB..Trv_PnrInfos t2 on t2.ID=t1.PnrInfoID
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t2.ItktBookingID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='����'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.RecordNumber in 
('AS002489374',
'AS002490427',
'AS002490578',
'AS002490667',
'AS002491026',
'AS002491487',
'AS002491510',
'AS002495011',
'AS002496319',
'AS002497546',
'AS002497624',
'AS002497630',
'AS002500041',
'AS002500041',
'AS002502512',
'AS002507745',
'AS002511370',
'AS002512819',
'AS002512821',
'AS002512823',
'AS002512825',
'AS002522609',
'AS002522611',
'AS002528491',
'AS002535574',
'AS002535574',
'AS002535574',
'AS002535592',
'AS002535888',
'AS002536180',
'AS002542042',
'AS002542044',
'AS002543016',
'AS002543016',
'AS002543016',
'AS002543671',
'AS002543671',
'AS002543672',
'AS002543949',
'AS002543949',
'AS002543950',
'AS002545556',
'AS002545558',
'AS002548014',
'AS002549306',
'AS002549308',
'AS002549346',
'AS002552448',
'AS002553462',
'AS002553466',
'AS002555004',
'AS002555008',
'AS002555010',
'AS002556395',
'AS002557075',
'AS002557173',
'AS002557190',
'AS002557787',
'AS002559531',
'AS002559539',
'AS002560059',
'AS002565972',
'AS002567754',
'AS002568468',
'AS002568793',
'AS002568826',
'AS002568927',
'AS002571221') and NodeType=110 and NodeID=111

--һ�� NodeType=110 and NodeID=110
--���� NodeType=110 and NodeID=111

/*
��æ������UC016991����������ó��(�Ϻ�)���޹�˾ 2019��1��1�տ�ʼ 
 
����-����������-���صĻ�Ʊ���õ���ϸ
*/

select coupno ���۵���,convert(varchar(10),datetime,120) ��Ʊ����,begdate ���ʱ��,pasname �˻���,route �г�,tcode+ticketno Ʊ��,price ���۵���,totprice ���ۼ�,reti ��Ʊ����
from Topway..tbcash 
where cmpcode='016991'
and datetime>='2019-01-01'
and route like '%����%'
and inf=0
order by ��Ʊ����

--����Ʒ��ר�ã���Ʊ��Ӧ����Դ�����ʣ�
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti  set ExamineDate='2019-03-28 15:08:24.937'
where reno='9266465'

--��Ʊ�������뵥��ӡ
select ReturnStatus,* from Topway..tbHtlcoupRefund 
--update Topway..tbHtlcoupRefund  set ReturnStatus='2'
where CoupNo='PTW085151'

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set SpareTC='������'
where coupno='AS002056875'

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit+1
where coupno='AS002569127'


--UC020897���뵥λBU
--select * from homsomDB..Trv_CompanyUndercover where CompanyId=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='020897')
--insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'AHDZ',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'ANXL-BMS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'ANWL',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'AP-DHL',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'BD',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'BJZX',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'BJYH',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'BJCJ',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'BJPP',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'BXDM',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CYKG',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CMAL-JA',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CMAL-E36',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CMAL-IF',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CMAL-S',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CMAL-SERVER',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CMAL-SH',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CMAL-SP',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CMAL-ZJ',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CMAL-MR',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CSGT',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CEVA',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CEVA-FSS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CEVA-SES',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CN-DHL',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'CYWL',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'DEV',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'DEV-TMS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'DEV-WMS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'DEV-BMS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'DEV-HUB',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'DEV-ADAPTER',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'DHL-SAAS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'DHL DM-SAAS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'DHL HKQ-SAAS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'DHL MT-SAAS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'DHL GF-SAAS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'DHL SEM-SAAS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'DHL SL-SAAS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'DHL Volvo-SAAS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'FNL',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'FSL-BMS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'FSL-TMS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'GZFS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'GZRT',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'HNXG',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'HR',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'HOLIDAY',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'HNYC',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'HWPOC',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'HW64',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'JNC-LW',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'JUSD',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'K&N',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'KN-BMW',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'KNDZ',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'LNHT',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'LNHY',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'MSZC',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'MHKD',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'PMO',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'PRAX-CY',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'PRAX-PDA',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'PRAX',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'QFKD',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'SAIC-TMS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'SHDL',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'SHENS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'SHHY',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'SHSS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'SHYD',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'SHYH',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'SHST',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'SZCLC',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'TEAM',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'TRA',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'TRINA',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'TRINA-2',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YCWL',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YHSW',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YHYL',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YJYW',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YQWL',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YQWL-E',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'ZCWL',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'ZSGJ',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'ZLWL',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'ZLWL-S',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-ANWL',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-BJCJ',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-CMAL-MR',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-CMAL-ZJ',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-MSZC',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-DHL DM-SAAS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-DHL MT-SAAS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-GZFS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-JNC-LW',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-KN-BMW',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-KNDZ',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-MHKD',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-PRAX',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-PRAX-CY',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-PRAX-PDA',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-SHSS',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-TRINA',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-TRINA-2',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-WYHZ',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-YQWL',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-YQWL-E',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')
insert into homsomDB..Trv_CompanyUndercover (ID,Ver,UnderName,CreateDate,CreateBy,ModifyDate,ModifyBy,CompanyId) values (NEWID(),GETDATE(),'YW-ZLWL',GETDATE(),'homsom',GETDATE(),'��������','55AEADB4-5A65-4E20-A23D-AA71010331F2')


--�����
select feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash  set feiyonginfo='������λMYI'
where coupno ='AS002574467'

select * from homsomDB..Trv_DeniedReason
select top 100 * from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_Reason r on r.UnitCompanyID=u.ID
where Cmpid='020897'
