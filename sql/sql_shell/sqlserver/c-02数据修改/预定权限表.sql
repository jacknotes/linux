--酒店预订权限表
select top 100 Name,* from homsomDB..Trv_UPBookingRanks where CompanyID='FF076962-62C1-4F30-9EE8-A9A500BDF725'

select top 100 UPBookingRankID,* from homsomDB..Trv_UnitPersons 

update homsomDB..Trv_UnitPersons set UPBookingRankID='88B944AF-CC9F-4793-8360-AA1600A77774' where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='杨风坤' and IsDisplay=1  and up.companyid='FF076962-62C1-4F30-9EE8-A9A500BDF725')

--机票预订权限表
select top 100 * from homsomDB..Trv_UPRanks where Name ='全部舱位' and CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659'

select * from homsomDB..Trv_UnitCompanies where Cmpid=020665

select top 100 UPRankID,* from homsomDB..Trv_UnitPersons 

update homsomDB..Trv_UnitPersons set UPRankID=(Select ID from homsomDB..Trv_UPRanks where Name='经济舱全价' and CompanyID='FF076962-62C1-4F30-9EE8-A9A500BDF725') where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='杨风坤' and IsDisplay=1  and up.companyid='FF076962-62C1-4F30-9EE8-A9A500BDF725')

---系统角色

select top 100  * from homsomdb..Trv_UPRoles

select top 100 UPRoleID,* from homsomDB..Trv_UnitPersons 

update homsomDB..Trv_UnitPersons set UPRoleID=(Select ID from homsomDB..Trv_UPRoles where Name='普通员工' and UnitCompanyID='FF076962-62C1-4F30-9EE8-A9A500BDF725') where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='杨风坤' and IsDisplay=1  and up.companyid='FF076962-62C1-4F30-9EE8-A9A500BDF725')


----UC020665预订类型：不可预订=0 自身预订=1 为他人预订=2 所有预订=3

select  top 100 BookingType,* from homsomdb..Trv_BookingCollections 
select Top 100  BookingCollectionID,* from homsomDB..Trv_UPSettings

select  us.ID ,BookingType,*from homsomdb..Trv_UPSettings us
left join homsomDB..Trv_BookingCollections b on b.ID=us.BookingCollectionID
left join homsomDB..Trv_UnitPersons un on un.UPSettingID=us.ID
left join homsomDB..Trv_Human h on h.ID=un.ID
where un.CompanyID='FF076962-62C1-4F30-9EE8-A9A500BDF725' and h.Name='黄志'

select distinct UPSettingID from homsomDB..Trv_UnitPersons where CompanyID='FF076962-62C1-4F30-9EE8-A9A500BDF725'

select top 100 UPSettingID,* from homsomDB..Trv_UnitPersons 


--UC020665预订类型
--自身预订=1
select * from homsomDB..Trv_BookingCollections
--update homsomDB..Trv_BookingCollections set BookingType=1
where ID in(Select BookingCollectionID from homsomDB..Trv_UPSettings 
where ID in(Select UPSettingID from homsomDB..Trv_UnitPersons u left join homsomDB..Trv_Human h on h.ID=u.ID  where u.CompanyID='FF076962-62C1-4F30-9EE8-A9A500BDF725' and Name in('黄志',
'杨杰',
'刘丹',
'王远',
'陈华忠',
'辛姝静',
'杨茂',
'刘科',
'张佳明',
'刘长君',
'解正志',
'林俊',
'陈琳',
'李春娇',
'黄颖',
'卢欢',
'吴卫军',
'郭琳',
'王萌',
'贾雪',
'古伟麟',
'周丹',
'薛中正',
'张军',
'雷斌',
'梁杰',
'杨川',
'钟世海',
'段莹',
'刘飞',
'潘昌满',
'廖忠亮',
'夏奎',
'高军',
'宋七松',
'郭朝文',
'郑辉',
'刘洋',
'刘陈',
'高翔',
'CLASSEN/TIMOTHY DAVID',
'张涛',
'马刚强',
'车志伟',
'何坤',
'朱伟',
'缪德品',
'刘娜',
'赵国安',
'杨强',
'马元清',
'芶彪',
'杨友辉',
'巫斌',
'周杰',
'易通',
'刘建柱',
'李雅雯',
'罗崇庆',
'赖祥富',
'丁超',
'闫秀平',
'韩承相',
'顾家兴',
'邓山江',
'杨风坤')))

--他人预订=2
select * from homsomDB..Trv_BookingCollections
--update homsomDB..Trv_BookingCollections set BookingType=2
where ID in(Select BookingCollectionID from homsomDB..Trv_UPSettings 
where ID in(Select UPSettingID from homsomDB..Trv_UnitPersons u left join homsomDB..Trv_Human h on h.ID=u.ID  where u.CompanyID='FF076962-62C1-4F30-9EE8-A9A500BDF725' and Name in('彭栋良',
'王晓薇',
'宁松',
'程坤',
'何长洪',
'成莉',
'张晨',
'祁娟')))
