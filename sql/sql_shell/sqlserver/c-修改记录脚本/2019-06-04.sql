/*
�����������й��ڻ�Ʊ����Ʊ��Ϊ��ĵ�λ������ֻҪ��Ӫ����Ϊ��ѩ÷���������� ��������Ʊ�ۣ���
�ֶΣ�UC�š���λ���ơ����ù��ʣ��ͻ�������Ӫ����
*/

select u.Cmpid UC��,u.Name ��λ����,s.Name ���ù���,h1.MaintainName �ͻ�����,h.MaintainName ��Ӫ����,
case when IsSepPrice=0 then '��' else '' end  �����������Ʊ��
from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_TktUnitCompanies_TktTCs t on t.TktUnitCompanyID=u.ID
left join homsomDB..SSO_Users s on s.ID=t.TktTCID
left join Topway..HM_ThePreservationOfHumanInformation h on h.CmpId=u.Cmpid and MaintainType=9 and IsDisplay=1
left join Topway..HM_ThePreservationOfHumanInformation h1 on h1.CmpId=u.Cmpid and h1.MaintainType=1 and h1.IsDisplay=1
where IsSepPrice=0
and h.MaintainName in ('��ѩ÷','������')
and u.CooperativeStatus in ('1','2','3')

--�г̵�
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�����г̵�'
where coupno in('AS002481094','AS002481123')

select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno in('AS002462423')


select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno in('AS002500150','AS002500261')


--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020797_20190501'


select * from homsomDB..Trv_Human h 
left join homsomDB..Trv_UnitPersons un on un.ID=h.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=un.CompanyID
where Cmpid='020797'
and IsDisplay=1


--�޸���Ʊ¼����
select opername,operDep,* from Topway..tbReti 
--update Topway..tbReti  set opername='����',operDep='��Ӫ��'
where reno in ('0436534','0436535')

--�޸����۵���
select price,* from Topway..tbcash where coupno='AS002441175'
update Topway..tbcash set price=2470,profit=profit-110,totprice=2520,owe=2520,amount=2520  where coupno='AS002441175'
update Topway..tbcash set price=930,profit=profit-30,totprice=980,owe=980,amount=980  where coupno='AS002441681'
update Topway..tbcash set price=2190,profit=profit-20,totprice=2240,owe=2240,amount=2240  where coupno='AS002441794'
update Topway..tbcash set price=1470,profit=profit-90,totprice=1520,owe=1520,amount=1520  where coupno='AS002442798'
update Topway..tbcash set price=2190,profit=profit-80,totprice=2240,owe=2240,amount=2240  where coupno='AS002448578'
update Topway..tbcash set price=2190,profit=profit-50,totprice=2240,owe=2240,amount=2240  where coupno='AS002449094'
update Topway..tbcash set price=1900,profit=profit-100,totprice=1950,owe=1950,amount=1950  where coupno='AS002449347'
update Topway..tbcash set price=1500,profit=profit-50,totprice=1550,owe=1550,amount=1550  where coupno='AS002450142'
update Topway..tbcash set price=1060,profit=profit-10,totprice=1110,owe=1110,amount=1110  where coupno='AS002450372'
update Topway..tbcash set price=1190,profit=profit-60,totprice=1240,owe=1240,amount=1240  where coupno='AS002453494'
update Topway..tbcash set price=800,profit=profit-40,totprice=850,owe=850,amount=850  where coupno='AS002454385'
update Topway..tbcash set price=930,profit=profit-10,totprice=980,owe=980,amount=980  where coupno='AS002464119'
update Topway..tbcash set price=830,profit=profit-10,totprice=880,owe=880,amount=880  where coupno='AS002465599'
update Topway..tbcash set price=1080,profit=profit-10,totprice=1130,owe=1130,amount=1130  where coupno='AS002465617'
update Topway..tbcash set price=1460,profit=profit-80,totprice=1510,owe=1510,amount=1510  where coupno='AS002470491'
update Topway..tbcash set price=890,profit=profit-20,totprice=940,owe=940,amount=940  where coupno='AS002471083'
update Topway..tbcash set price=900,profit=profit-60,totprice=950,owe=950,amount=950  where coupno='AS002474161'
update Topway..tbcash set price=1290,profit=profit-40,totprice=1340,owe=1340,amount=1340  where coupno='AS002474647'
update Topway..tbcash set price=960,profit=profit-30,totprice=1010,owe=1010,amount=1010  where coupno='AS002475662'
update Topway..tbcash set price=1510,profit=profit-80,totprice=1560,owe=1560,amount=1560  where coupno='AS002476624'
update Topway..tbcash set price=1470,profit=profit-120,totprice=1520,owe=1520,amount=1520  where coupno='AS002476626'
update Topway..tbcash set price=1050,profit=profit-120,totprice=1100,owe=1100,amount=1100  where coupno='AS002476697'
update Topway..tbcash set price=1540,profit=profit-120,totprice=1590,owe=1590,amount=1590  where coupno='AS002482005'
update Topway..tbcash set price=650,profit=profit-20,totprice=700,owe=700,amount=700  where coupno='AS002482883'
update Topway..tbcash set price=1810,profit=profit-140,totprice=1860,owe=1860,amount=1860  where coupno='AS002483025'
update Topway..tbcash set price=1100,profit=profit-40,totprice=1150,owe=1150,amount=1150  where coupno='AS002483170'
update Topway..tbcash set price=1470,profit=profit-120,totprice=1520,owe=1520,amount=1520  where coupno='AS002483450'
update Topway..tbcash set price=1040,profit=profit-30,totprice=1090,owe=1090,amount=1090  where coupno='AS002483828'
update Topway..tbcash set price=1700,profit=profit-20,totprice=1750,owe=1750,amount=1750  where coupno='AS002485728'
update Topway..tbcash set price=1080,profit=profit-10,totprice=1130,owe=1130,amount=1130  where coupno='AS002487382'
update Topway..tbcash set price=560,profit=profit-30,totprice=610,owe=610,amount=610  where coupno='AS002489165'
update Topway..tbcash set price=1510,profit=profit-80,totprice=1560,owe=1560,amount=1560  where coupno='AS002489183'


 --UC019392 ������Ŀ���
 --select * from homsomDB..Trv_Customizations where UnitCompanyID=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='019392')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������:MarkvanBruchem','0','һ������:MarkvanBruchem','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ��������Mobility.china','0','һ��������Mobility.china','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������������ɭ','0','һ������������ɭ','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������������Դ','0','һ������������Դ','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ���������³�','0','һ���������³�','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ���������¾�','0','һ���������¾�','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������������','0','һ������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ��������������','0','һ��������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ����������ӵƽ','0','һ����������ӵƽ','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������:������','0','һ������:������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ��������������','0','һ��������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ��������������','0','һ��������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ��������������','0','һ��������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ����������Ӿ��','0','һ����������Ӿ��','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ�����������н�','0','һ�����������н�','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ��������������','0','һ��������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ��������������','0','һ��������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ����������ɺ','0','һ����������ɺ','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������������','0','һ������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ�����������','0','һ�����������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ���������','0','һ���������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ����������ƽ','0','һ����������ƽ','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������������','0','һ������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ�����������Ӿ�','0','һ�����������Ӿ�','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������������','0','һ������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ��������������','0','һ��������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������:������','0','һ������:������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������������','0','һ������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ��������½˴Ң','0','һ��������½˴Ң','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������:½�','0','һ������:½�','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ��������������','0','һ��������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������������','0','һ������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ����������ʦ��','0','һ����������ʦ��','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������:�ῡ��','0','һ������:�ῡ��','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ��������̸�ξ�','0','һ��������̸�ξ�','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������:��ΰ��','0','һ������:��ΰ��','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������:�ڲʱ�','0','һ������:�ڲʱ�','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������������','0','һ������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������:������','0','һ������:������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������������˧','0','һ������������˧','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������������','0','һ������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������:���P','0','һ������:���P','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ���������컶','0','һ���������컶','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������:���ٻ�','0','һ������:���ٻ�','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������������','0','һ������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������:��','0','һ������:��','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ�����������','0','һ�����������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ��������Ҧ��Ƽ','0','һ��������Ҧ��Ƽ','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ��������Ҷ����','0','һ��������Ҷ����','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ���������Ŵ��','0','һ���������Ŵ��','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ�����������','0','һ�����������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ�������������','0','һ�������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ������:�Ժ��','0','һ������:�Ժ��','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ��������������','0','һ��������������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ�����������','0','һ�����������','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'һ����������»�','0','һ����������»�','8733D8C2-EA46-4087-92AC-A541011086C4')

select Mobile,Cmpid,* from homsomDB..Trv_Human h 
left join homsomDB..Trv_UnitPersons un on un.ID=h.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=un.CompanyID
where CustID='d694293'

--����Ʒר�ã��������Դ
select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash  set feiyong=0,feiyonginfo=''
where coupno='AS002526497'

--UC019392ɾ�����ÿ�
select * from homsomDB..Trv_Human
--update  homsomDB..Trv_Human set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons where 
companyid=(Select  ID from homsomDB..Trv_UnitCompanies where Cmpid='019392'))
and IsDisplay=1


--�г̵�
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno in('AS002456884')

--UC020105���� Ӣ�����գ��Ϻ���������ѯ���޹�˾

select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement  set CompanyNameCN='Ӣ�����գ��Ϻ���������ѯ���޹�˾'
where BillNumber='020105_20190601'

--�����տ��Ϣ
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='29989' and Id='228256'

--�˵�����
select TrainBillStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set TrainBillStatus=1
where BillNumber='019394_20190501'

--UC017969ŷ��¡0501�˵�  �г̵���
select detr_rp from Topway..tbcash where ModifyBillNumber='017969_20190501' and DETR_RP<>'' order by detr_rp

