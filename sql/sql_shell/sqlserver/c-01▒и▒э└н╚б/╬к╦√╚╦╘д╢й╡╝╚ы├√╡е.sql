--UC020866 �Ϻ�������ʱװ���޹�˾ ����Ԥ������
if OBJECT_ID ('tempdb..#spr') is not null drop table #spr
select Cmpid,up.BookingCollectionID 
into #spr
from homsomDB..Trv_Human h 
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies  un on un.ID=u.CompanyID
left join homsomDB..Trv_UPSettings up on up.ID=u.UPSettingID
where Cmpid='020866' and h.Name in('������','л����')

if OBJECT_ID ('tempdb..#sp') is not null drop table #sp
select BookingCollectionID,un.ID 
into #sp
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons un on un.ID=h.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=un.CompanyID
left join #spr s on s.cmpid=u.Cmpid
where u.Cmpid='020866' 
and h.Name in('������',
'���Ӣ',
'����',
'���˴�',
'�����',
'������',
'�˿���',
'���',
'����',
'����ʫ',
'Ī����',
'������',
'�ļ���',
'֣��',
'������',
'Ф����',
'������',
'л����',
'����',
'�����',
'�����',
'����',
'�޼���',
'׿˼��')

insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) select BookingCollectionID,ID from #sp