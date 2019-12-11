--UC020866 上海依迪索时装有限公司 他人预订导入
if OBJECT_ID ('tempdb..#spr') is not null drop table #spr
select Cmpid,up.BookingCollectionID 
into #spr
from homsomDB..Trv_Human h 
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies  un on un.ID=u.CompanyID
left join homsomDB..Trv_UPSettings up on up.ID=u.UPSettingID
where Cmpid='020866' and h.Name in('梁安琪','谢素蓉')

if OBJECT_ID ('tempdb..#sp') is not null drop table #sp
select BookingCollectionID,un.ID 
into #sp
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons un on un.ID=h.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=un.CompanyID
left join #spr s on s.cmpid=u.Cmpid
where u.Cmpid='020866' 
and h.Name in('韩冬清',
'杨杰英',
'利民',
'刘运村',
'钟泽鸿',
'陈瑞意',
'邓俊荣',
'杨春丽',
'胡林',
'朱梦诗',
'莫靖婷',
'季竞明',
'文嘉莉',
'郑晨',
'梁安琪',
'肖晓蕾',
'梁美妮',
'谢素蓉',
'曾瑞海',
'温汝驰',
'马泽标',
'周瑶',
'罗嘉欣',
'卓思敏')

insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) select BookingCollectionID,ID from #sp