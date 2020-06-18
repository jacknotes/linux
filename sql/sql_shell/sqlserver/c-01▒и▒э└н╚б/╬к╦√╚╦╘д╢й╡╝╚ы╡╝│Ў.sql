select id from Trv_UnitCompanies where Cmpid='020459'

insert into homsomDB..Trv_UPCollections_UnitPersons(UpCollectionID,UnitPersonID)
select distinct e.ID,a.ID from homsomDB..Trv_Human b
left join homsomDB..Trv_UnitPersons a on a.ID=b.ID
left join homsomDB..Trv_UnitCompanies c on a.companyid=c.ID
left join homsomDB..Trv_UPSettings d on a.UPSettingID=d.ID
left join homsomDB..Trv_BookingCollections e on d.BookingCollectionID=e.ID
where c.Cmpid='020459' and IsDisplay=1 

insert into homsomDB..Trv_UPCollections_UnitPersons(UpCollectionID,UnitPersonID)
select 'C85C9042-14D6-47B5-AFE8-A999011448E1',id from #pp


select (
select  e.ID from homsomDB..Trv_Human b
inner join homsomDB..Trv_UnitPersons a on a.ID=b.ID
inner join homsomDB..Trv_UnitCompanies c on a.companyid=c.ID
inner join homsomDB..Trv_UPSettings d on a.UPSettingID=d.ID
inner join homsomDB..Trv_BookingCollections e on d.BookingCollectionID=e.ID
where c.Cmpid='019259' and IsDisplay=1 
and b.Name='党月'
) h
,
(select b.ID into #pp from homsomDB..Trv_Human b
inner join homsomDB..Trv_UnitPersons a on a.ID=b.ID and b.IsDisplay=1
inner join homsomDB..Trv_UnitCompanies c on a.companyid=c.ID 
where b.name in ('潘松','张楚唯','米满红','焦森','王欢','高小丽','李玉','胡维','孙雨爽','郝贞贞','张靖','马雪庆','杨晓璐','樊雅洁','姚云霞','张倩','朱天颖','王成对','吕琼','高颖','童靖淳','马丽丽','连亚红','吴镝飞','张铭玥','李彩霞','孙代勇','张艳红','王燕琳','李杨','张继坤','孙敏','鹿晓燕','李艳','王虹','刘媛','姚微','李玉凤','宋世豪','李娜','党月','王小娜','王丽','李宁','润蓓蓓')
and c.Cmpid='019259') 


--导出
select distinct t.Name as '1',b.Name ,c.Name  from (
select b.Name,f.*,e.ID from homsomDB..Trv_UnitPersons a
left join homsomDB..Trv_Human b on a.ID=b.ID
left join homsomDB..Trv_UnitCompanies c on a.CompanyID=c.ID
left join homsomDB..Trv_UPSettings d on a.UPSettingID=d.ID
left join homsomDB..Trv_BookingCollections e on d.BookingCollectionID=e.ID
left join homsomDB..Trv_UPCollections_UnitPersons f on e.ID=f.UPCollectionID
where  Cmpid='020459' 
)t
left join homsomDB..Trv_UnitPersons up on t.UnitPersonID=up.ID
left join homsomDB..Trv_Human b on up.ID=b.ID
left join homsomDB..Trv_UnitCompanies c on up.CompanyID=c.ID


