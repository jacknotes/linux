--�Ƶ�Ԥ��Ȩ�ޱ�
select top 100 Name,* from homsomDB..Trv_UPBookingRanks where CompanyID='FF076962-62C1-4F30-9EE8-A9A500BDF725'

select top 100 UPBookingRankID,* from homsomDB..Trv_UnitPersons 

update homsomDB..Trv_UnitPersons set UPBookingRankID='88B944AF-CC9F-4793-8360-AA1600A77774' where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�����' and IsDisplay=1  and up.companyid='FF076962-62C1-4F30-9EE8-A9A500BDF725')

--��ƱԤ��Ȩ�ޱ�
select top 100 * from homsomDB..Trv_UPRanks where Name ='ȫ����λ' and CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659'

select * from homsomDB..Trv_UnitCompanies where Cmpid=020665

select top 100 UPRankID,* from homsomDB..Trv_UnitPersons 

update homsomDB..Trv_UnitPersons set UPRankID=(Select ID from homsomDB..Trv_UPRanks where Name='���ò�ȫ��' and CompanyID='FF076962-62C1-4F30-9EE8-A9A500BDF725') where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�����' and IsDisplay=1  and up.companyid='FF076962-62C1-4F30-9EE8-A9A500BDF725')

---ϵͳ��ɫ

select top 100  * from homsomdb..Trv_UPRoles

select top 100 UPRoleID,* from homsomDB..Trv_UnitPersons 

update homsomDB..Trv_UnitPersons set UPRoleID=(Select ID from homsomDB..Trv_UPRoles where Name='��ͨԱ��' and UnitCompanyID='FF076962-62C1-4F30-9EE8-A9A500BDF725') where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='�����' and IsDisplay=1  and up.companyid='FF076962-62C1-4F30-9EE8-A9A500BDF725')


----UC020665Ԥ�����ͣ�����Ԥ��=0 ����Ԥ��=1 Ϊ����Ԥ��=2 ����Ԥ��=3

select  top 100 BookingType,* from homsomdb..Trv_BookingCollections 
select Top 100  BookingCollectionID,* from homsomDB..Trv_UPSettings

select  us.ID ,BookingType,*from homsomdb..Trv_UPSettings us
left join homsomDB..Trv_BookingCollections b on b.ID=us.BookingCollectionID
left join homsomDB..Trv_UnitPersons un on un.UPSettingID=us.ID
left join homsomDB..Trv_Human h on h.ID=un.ID
where un.CompanyID='FF076962-62C1-4F30-9EE8-A9A500BDF725' and h.Name='��־'

select distinct UPSettingID from homsomDB..Trv_UnitPersons where CompanyID='FF076962-62C1-4F30-9EE8-A9A500BDF725'

select top 100 UPSettingID,* from homsomDB..Trv_UnitPersons 


--UC020665Ԥ������
--����Ԥ��=1
select * from homsomDB..Trv_BookingCollections
--update homsomDB..Trv_BookingCollections set BookingType=1
where ID in(Select BookingCollectionID from homsomDB..Trv_UPSettings 
where ID in(Select UPSettingID from homsomDB..Trv_UnitPersons u left join homsomDB..Trv_Human h on h.ID=u.ID  where u.CompanyID='FF076962-62C1-4F30-9EE8-A9A500BDF725' and Name in('��־',
'���',
'����',
'��Զ',
'�»���',
'��歾�',
'��ï',
'����',
'�ż���',
'������',
'����־',
'�ֿ�',
'����',
'���',
'��ӱ',
'¬��',
'������',
'����',
'����',
'��ѩ',
'��ΰ��',
'�ܵ�',
'Ѧ����',
'�ž�',
'�ױ�',
'����',
'�',
'������',
'��Ө',
'����',
'�˲���',
'������',
'�Ŀ�',
'�߾�',
'������',
'������',
'֣��',
'����',
'����',
'����',
'CLASSEN/TIMOTHY DAVID',
'����',
'���ǿ',
'��־ΰ',
'����',
'��ΰ',
'�ѵ�Ʒ',
'����',
'�Թ���',
'��ǿ',
'��Ԫ��',
'�a��',
'���ѻ�',
'�ױ�',
'�ܽ�',
'��ͨ',
'������',
'������',
'�޳���',
'���鸻',
'����',
'����ƽ',
'������',
'�˼���',
'��ɽ��',
'�����')))

--����Ԥ��=2
select * from homsomDB..Trv_BookingCollections
--update homsomDB..Trv_BookingCollections set BookingType=2
where ID in(Select BookingCollectionID from homsomDB..Trv_UPSettings 
where ID in(Select UPSettingID from homsomDB..Trv_UnitPersons u left join homsomDB..Trv_Human h on h.ID=u.ID  where u.CompanyID='FF076962-62C1-4F30-9EE8-A9A500BDF725' and Name in('����',
'����ޱ',
'����',
'����',
'�γ���',
'����',
'�ų�',
'���')))
