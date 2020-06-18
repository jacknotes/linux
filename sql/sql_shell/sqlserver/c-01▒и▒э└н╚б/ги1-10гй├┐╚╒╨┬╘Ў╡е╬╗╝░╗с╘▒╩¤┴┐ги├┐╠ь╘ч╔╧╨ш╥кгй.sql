select * from (
select convert(nvarchar(10),joindate,120) as 时间
,(case custtype when '普通个人会员' then '普通个人会员' when '贵宾客户' then 'VIP个人会员' when 'VIP个人会员' then 'VIP个人会员' else '' end) as 类型,COUNT(*) as 数量
from tbCusholder with(nolock) where CONVERT(varchar(8),joindate,112)>=CONVERT(varchar(8),GETDATE()-7,112)
and mobilephone not in (select isnull(Mobile,'') from homsomDB..Trv_Human)
group by custtype,convert(nvarchar(10),joindate,120)
UNION ALL
select CONVERT(nvarchar(8),CreateDate,112)as 时间,(case Type when 'A' then '差旅单位' when 'C' then '旅游单位' when 'F' then '会务单位' else '' end) as 类型,COUNT(*) as 单位
from homsomDB..Trv_UnitCompanies with(nolock) where CONVERT(varchar(8),CreateDate,112)>=CONVERT(varchar(8),GETDATE()-7,112)
group by Type,CONVERT(nvarchar(8),CreateDate,112)
UNION ALL
select convert(nvarchar(10),joindate,120) as 时间,(case custtype when '普通个人会员' then '普通单位会员' when '贵宾客户' then 'VIP单位客户' when 'VIP个人会员' then 'VIP单位客户' else '' end) as 类型,COUNT(*) as 数量
from tbCusholder with(nolock) where CONVERT(varchar(8),joindate,112)>=CONVERT(varchar(8),GETDATE()-7,112)
and (custname in (select h.Name from homsomDB..Trv_UnitPersons p
inner join homsomDB..Trv_Human h on h.ID=p.ID and IsDisplay=1) or mobilephone in (select h.Mobile from homsomDB..Trv_UnitPersons p
inner join homsomDB..Trv_Human h on h.ID=p.ID and IsDisplay=1))
group by custtype,convert(nvarchar(10),joindate,120)
)g
order by 时间

