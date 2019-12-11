--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash where coupno='AS001456731'

--修改到账日期
select * from Topway..FinanceERP_ClientBankRealIncomeDetail 
--update Topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-03-04'
where money='6663' and date='2019-03-05'

--任楠轩改成徐双钦
select * from ApproveBase..App_DefineBase 
--update ApproveBase..App_DefineBase set Signer=0602
where Signer=0465

--删除单位常旅客
select * from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (
select top 29 a.ID  from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID ='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1'
and IsDisplay=1 and Name in ('郑小军',
'钟德显',
'刘晓江',
'胡存根',
'胡晓芸',
'曾红刚',
'蔡俊恺',
'王友玮',
'陆燕',
'李文俊',
'张寅',
'张文淼',
'贾诺明',
'钱鸿虎',
'陆慧诚',
'张咏华',
'汪晓婷',
'徐雪梅',
'胡俊忠',
'杜文斯',
'郭荣',
'何东平',
'李文斌',
'徐涌',
'陈娟',
'李轲',
'张屹',
'涂婷',
'罗丹') 
order by Ver)

--导入成本中心
--select * from homsomDB..Trv_UnitPersons 
--where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID 
--where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='郑小军')

update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海分公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='许伟丽')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海分公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='于真真')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海分公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='郑小军')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海分公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='钟德显')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海分公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='刘晓江')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海分公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='胡存根')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='胡晓芸')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='曾红刚')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='蔡俊恺')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='王友玮')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='陆燕')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='李文俊')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='张寅')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='张文淼')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='贾诺明')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='钱鸿虎')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='陆慧诚')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='张咏华')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='汪晓婷')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='徐雪梅')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='胡俊忠')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='杜文斯')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='上海子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='郭荣')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='成都子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='何东平')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='成都子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='李文斌')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='成都子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='徐涌')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='成都子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='陈娟')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='成都子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='李轲')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='成都子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='张屹')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='成都子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='涂婷')
update homsomDB..Trv_UnitPersons set CostCenterID=(Select ID from homsomDB..Trv_CostCenter  where Name='成都子公司' and CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1') where ID in(Select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on hu.ID=up.ID where up.CompanyID='0AB3E1BC-2B6A-4CF7-BC81-853CC2C701E1' and IsDisplay=1 and hu.Name='罗丹')


--党月他们预定导到熊琼佳
--熊琼佳UPCollectionID
select  e.ID from homsomDB..Trv_Human b
inner join homsomDB..Trv_UnitPersons a on a.ID=b.ID
inner join homsomDB..Trv_UnitCompanies c on a.companyid=c.ID
inner join homsomDB..Trv_UPSettings d on a.UPSettingID=d.ID
inner join homsomDB..Trv_BookingCollections e on d.BookingCollectionID=e.ID
where c.Cmpid='019259' and IsDisplay=1 
and b.Name='熊琼佳'
--党月名下UnitPersonID
select f.UnitPersonID,f.UPCollectionID from homsomDB..Trv_UnitPersons a
left join homsomDB..Trv_Human b on a.ID=b.ID
left join homsomDB..Trv_UnitCompanies c on a.CompanyID=c.ID
left join homsomDB..Trv_UPSettings d on a.UPSettingID=d.ID
left join homsomDB..Trv_BookingCollections e on d.BookingCollectionID=e.ID
left join homsomDB..Trv_UPCollections_UnitPersons f on e.ID=f.UPCollectionID
where b.Name='党月' and Cmpid='019259' and b.IsDisplay=1

--替换党月为熊琼佳UPCollectionID
select * from homsomDB..Trv_UPCollections_UnitPersons 
--update homsomDB..Trv_UPCollections_UnitPersons set UPCollectionID='F0886C6F-CB98-43DE-9B28-AA0800A91922'
where UPCollectionID='C85C9042-14D6-47B5-AFE8-A999011448E1'

--插入新的他们预定
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('','')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','46D90D62-ABC8-46EE-93A6-9F254E70EB07')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','FF8E3096-D1D3-475D-8A4D-A8BE00BDAF0B')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','A7D14C99-2748-4455-814F-A6E300BFEECF')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','1DC9A6E7-F1F1-4AF8-B122-CBA24B3FAC6C')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','832FCB0A-3404-4259-958F-A6E300C11C2D')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','965BCD1F-C64E-471F-A61E-DFE871F7D37A')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','74C4E059-1928-492D-8D67-A72F0093BCC9')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','FA85E0CA-54F3-4DE5-954A-0EE74772D11C')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','59A5C12D-D9E1-4E90-BBBA-A77500FD7708')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','F0652BEE-3225-4FC5-9A9D-243AA56B7899')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','CE1FE85E-2BFF-41CD-9DDC-A7DF00EA0E28')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','53E67ECC-4FB8-41D5-A42D-A73200BB4927')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','608D5FE9-63CE-4F01-A052-A6E300BF7DE2')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','FF0608F1-C8EA-43E7-BE2E-A92001175A58')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','A8940583-2BF3-4224-A975-A6E300BE3C89')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','76C65759-EE7D-47A8-8AE4-A9200116EDFE')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','A7033C8B-C59E-4798-B603-65F802539131')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','0B9C8A05-DE07-47E1-AB46-A850011E75F9')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','8B48632C-1522-40C3-98CD-759F4049D8F1')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','551528B3-ADF5-4537-9ADC-A89E010819AB')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','B74FD630-D039-431B-ADB6-075A8CA6C262')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','E15FB8AD-183C-4AA0-AEA8-A73200BB8EBB')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','6B3695D7-EC1D-4F83-93D9-1EA7BF4DC7DE')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','A786967C-D3FD-4561-BFF0-A7DD00AF98CF')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','317C9F30-5141-4585-A10D-A0EEFD514884')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','E9F02F82-7264-4CAA-8C10-A8BE00C0E9D7')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','EBB548A0-864E-4F54-B34C-A6E300C057B0')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','9721DB82-F8E8-4073-8B09-DB40761B1C0C')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','63664736-551D-4136-A5F2-543482FAB319')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','1A1F46B9-C5DD-4321-ACC1-A7EE00FFF04C')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','C46998B0-418D-44ED-9767-A6E300BFAFF0')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','BF62E3D8-FB89-4DF6-9CE4-A999011448E1')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','26098201-7692-4026-BF8B-A55108386B9A')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','CE35382E-B658-45FB-A645-A92001153B98')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','8C383A84-CCFE-4974-9FC1-80EF46095AE5')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','32D1D6BD-77F0-4E05-BB07-A89E010961A6')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','1C74901D-52CE-4135-A3A8-98D3F5F70611')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','1846E699-9AD4-440E-BAC3-A89E0109C924')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','AC803DDC-8290-40B4-B64E-9FF12E3BE450')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','A45BCE99-7639-4537-AA7D-A8BE00BF5B58')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','9DAB1179-C88F-4BBE-B2FD-A6E5009746FB')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','A3B9452B-7546-4580-B2F9-E77F6DC97255')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','3E68EE9A-ED0E-4586-AE15-1C48DF9A9B6D')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','349CDBD9-2C75-465E-859A-A7DD00AF6384')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','1B289462-4376-4876-9535-29AF22410799')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','FB7FE3E6-9D4C-483B-8FD0-A7E800E6E39F')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('F0886C6F-CB98-43DE-9B28-AA0800A91922','43E5AA3A-E25F-4B07-93D5-A99E00E2D8FE')

--修改UC号（机票）
select custid AS 现会员编号,* from topway..tbCusholderM where cmpid ='020746'
select custid,OriginalBillNumber,ModifyBillNumber,* from Topway..tbcash where cmpcode='020746'
select SettleMentManner AS 现结算方式,* from topway..HM_SetCompanySettleMentManner where CmpId='020746' and Type=0 and Status=1
select OriginalBillNumber AS 现账单号,ModifyBillNumber AS 现账单号,cmpcode,custid,datetime,* from topway..tbcash where coupno in ('AS002291537','AS002292016')
select HSLastPaymentDate,* from topway..AccountStatement where CompanyCode='020746' order by BillNumber desc
select * from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
where  CustID='D632137'

--修改UC号（ERP）
select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,pform,* from Topway..tbcash
--update topway..tbcash set cmpcode='020746',OriginalBillNumber='020746_20190301',custid='D639512'
 where coupno in ('AS002291537','AS002292016')
 
 --火车票供应商来源,和供应商服务费
 select Tsource,TotFuprice,* from Topway..tbTrainTicketInfo 
 --update Topway..tbTrainTicketInfo  set Tsource='垫付现金支付'
 where CoupNo in('RS000020181','RS000020182','RS000020183','RS000020184','RS000020185','RS000020186')
 
 select ProviderFuprice,* from Topway..tbTrainUser 
 --update Topway..tbTrainUser  set ProviderFuprice=0
 where TrainTicketNo in (Select ID from Topway..tbTrainTicketInfo where CoupNo in('RS000020181','RS000020182','RS000020183','RS000020184','RS000020185','RS000020186'))
 
 --供应商来源
 select t_source,* from Topway..tbcash 
 --update Topway..tbcash  set t_source='HSBSPETD'
 where coupno in ('AS002278768','AS002269255')
 
 select t_source,* from Topway..tbcash 
 --update Topway..tbcash set t_source='ZSUATPI'
 where coupno='AS002277228'
 
 --换开销售单信息
 select HKPrice,* from Topway..tbcash 
 --update Topway..tbcash set HKPrice=300
 where coupno='AS002292031'
 
 --酒店销售单供应商来源
 select prdate,profitsource,* from Topway..tbHtlcoupYf 
 --update Topway..tbHtlcoupYf  set profitsource='深圳市道旅旅游科技股份有限公司'
 where CoupNo='PTW077360'
 
 --账单撤销
 select SubmitState,* from Topway..AccountStatement 
 --update Topway..AccountStatement  set SubmitState=1
 where BillNumber in('020176_20190201','017735_20190126','016888_20190126','018309_20190201')
 
 
 --修改uc号
 select * from Topway..AccountStatement where CompanyCode='016888' order by BillNumber desc
 select * from tbCusholderM where cmpid='016888'
 select * from tbCusholderM where cmpid='017735' and custid='D406036'
 --修改uc号
 select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,pform,* from Topway..tbcash
--update topway..tbcash set OriginalBillNumber='016888_20190126',ModifyBillNumber='016888_20190126'
 where coupno in ('AS002260524','AS002269293')
 
 --财务账单核销
select SalesOrderState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SalesOrderState=0
where BillNumber='018919_20190101'

select totprice,* from Topway..tbcash 
where ModifyBillNumber='018919_20190101'
--and reti=''
--and tickettype='电子票'
order by datetime 

--已付改未付
select bpay as 支付金额,status as 收款状态,opernum as 核销次数,oper2 as 核销人,oth2 as 备注,totprice as 销售价,dzhxDate as 核销时间,owe as 欠款金额
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
from Topway..tbcash where coupno in ('AS002134030',
'AS002134671',
'AS002134673',
'AS002135387',
'AS002137228',
'AS002137653',
'AS002138037',
'AS002138358',
'AS002138460',
'AS002138813',
'AS002138815',
'AS002139098',
'AS002139269',
'AS002139688',
'AS002139738',
'AS002140179',
'AS002140516',
'AS002142824',
'AS002142866',
'AS002142890',
'AS002143903',
'AS002143943',
'AS002144356',
'AS002145034',
'AS002145071',
'AS002145931',
'AS002146141',
'AS002146340',
'AS002148293',
'AS002148295',
'AS002149593',
'AS002149747',
'AS002152849',
'AS002152851',
'AS002152966',
'AS002154909',
'AS002155090',
'AS002155715',
'AS002155782',
'AS002156462',
'AS002156464',
'AS002157455',
'AS002157459',
'AS002157596',
'AS002157621',
'AS002157623',
'AS002157826',
'AS002158200',
'AS002159376',
'AS002159562',
'AS002159685',
'AS002159778',
'AS002159780',
'AS002159785',
'AS002159951',
'AS002162006',
'AS002163197',
'AS002163225',
'AS002164548',
'AS002164576',
'AS002165049',
'AS002165143',
'AS002165562',
'AS002167575',
'AS002168400',
'AS002168617',
'AS002170095',
'AS002170441',
'AS002170443',
'AS002170633',
'AS002171102',
'AS002175033',
'AS002176121',
'AS002176904',
'AS002176906',
'AS002176908',
'AS002176912',
'AS002181832',
'AS002181855',
'AS002181875',
'AS002181877',
'AS002183660',
'AS002183662',
'AS002183713',
'AS002183715',
'AS002183717',
'AS002183719',
'AS002184303',
'AS002184691',
'AS002186120',
'AS002186242',
'AS002186427',
'AS002186728',
'AS002186783',
'AS002186785',
'AS002186787',
'AS002187200',
'AS002187641',
'AS002187643',
'AS002189424',
'AS002189426',
'AS002191092',
'AS002191557',
'AS002192050',
'AS002192265',
'AS002192330',
'AS002192334',
'AS002192340',
'AS002192364',
'AS002192387',
'AS002192397',
'AS002192399',
'AS002193361',
'AS002193365',
'AS002196684',
'AS002196688',
'AS002196758',
'AS002197419',
'AS002199548',
'AS002200467',
'AS002201754',
'AS002202485',
'AS002202597',
'AS002202660',
'AS002202747',
'AS002203117',
'AS002203727',
'AS002203733',
'AS002203815',
'AS002204670',
'AS002204707',
'AS002204782',
'AS002204905',
'AS002205414',
'AS002205961',
'AS002206072',
'AS002206259',
'AS002206325',
'AS002206778',
'AS002206971',
'AS002206988',
'AS002207075',
'AS002207163',
'AS002207576',
'AS002207848',
'AS002207850',
'AS002207856',
'AS002207889',
'AS002208237',
'AS002208294',
'AS002208308',
'AS002208336',
'AS002208338',
'AS002208428',
'AS002208508',
'AS002208518',
'AS002208588',
'AS002209154',
'AS002209164',
'AS002209850',
'AS002209860',
'AS002209913',
'AS002210395',
'AS002210950',
'AS002211238',
'AS002211365',
'AS002211377',
'AS002211543',
'AS002211563',
'AS002211901',
'AS002212421',
'AS002213321',
'AS002213324',
'AS002214283',
'AS002216796',
'AS002221928',
'AS002222063',
'AS002222277',
'AS002223333',
'AS002224164',
'AS002224271',
'AS002224969',
'AS002224983',
'AS002225433',
'AS002226222',
'AS002226311',
'AS002227821',
'AS002228617',
'AS002228619',
'AS002228621',
'AS002228977',
'AS002229121',
'AS002230465',
'AS002231158',
'AS002231283',
'AS002231289',
'AS002231827',
'AS002232207',
'AS002232209',
'AS002232225',
'AS002232268',
'AS002232270',
'AS002232418',
'AS002232774',
'AS002233097',
'AS002233522',
'AS002234192',
'AS002235882',
'AS002236924',
'AS001992450',
'AS001996757',
'AS002125686',
'AS002118385',
'AS002118340',
'AS002118375',
'AS002114956',
'AS001837121')

--火车票账单撤销
select TrainBillStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement set TrainBillStatus=1
where BillNumber='018309_20190201'

--火车票供应商来源/配送信息
select Tsource,* from Topway..tbTrainTicketInfo 
--update Topway..tbTrainTicketInfo set Tsource='垫付现金支付'
where CoupNo in('RS000020195','RS000020196')
select ProviderFuprice,* from Topway..tbTrainUser 
--update Topway..tbTrainUser set ProviderFuprice=0
where TrainTicketNo in (Select ID from Topway..tbTrainTicketInfo where CoupNo in ('RS000020195','RS000020196'))

