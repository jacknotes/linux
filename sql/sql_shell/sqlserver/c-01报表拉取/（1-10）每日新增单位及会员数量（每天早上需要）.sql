select * from (
select convert(nvarchar(10),joindate,120) as ʱ��
,(case custtype when '��ͨ���˻�Ա' then '��ͨ���˻�Ա' when '����ͻ�' then 'VIP���˻�Ա' when 'VIP���˻�Ա' then 'VIP���˻�Ա' else '' end) as ����,COUNT(*) as ����
from tbCusholder with(nolock) where CONVERT(varchar(8),joindate,112)>=CONVERT(varchar(8),GETDATE()-7,112)
and mobilephone not in (select isnull(Mobile,'') from homsomDB..Trv_Human)
group by custtype,convert(nvarchar(10),joindate,120)
UNION ALL
select CONVERT(nvarchar(8),CreateDate,112)as ʱ��,(case Type when 'A' then '���õ�λ' when 'C' then '���ε�λ' when 'F' then '����λ' else '' end) as ����,COUNT(*) as ��λ
from homsomDB..Trv_UnitCompanies with(nolock) where CONVERT(varchar(8),CreateDate,112)>=CONVERT(varchar(8),GETDATE()-7,112)
group by Type,CONVERT(nvarchar(8),CreateDate,112)
UNION ALL
select convert(nvarchar(10),joindate,120) as ʱ��,(case custtype when '��ͨ���˻�Ա' then '��ͨ��λ��Ա' when '����ͻ�' then 'VIP��λ�ͻ�' when 'VIP���˻�Ա' then 'VIP��λ�ͻ�' else '' end) as ����,COUNT(*) as ����
from tbCusholder with(nolock) where CONVERT(varchar(8),joindate,112)>=CONVERT(varchar(8),GETDATE()-7,112)
and (custname in (select h.Name from homsomDB..Trv_UnitPersons p
inner join homsomDB..Trv_Human h on h.ID=p.ID and IsDisplay=1) or mobilephone in (select h.Mobile from homsomDB..Trv_UnitPersons p
inner join homsomDB..Trv_Human h on h.ID=p.ID and IsDisplay=1))
group by custtype,convert(nvarchar(10),joindate,120)
)g
order by ʱ��

