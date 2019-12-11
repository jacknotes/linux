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
select f.UnitPersonID from homsomDB..Trv_UnitPersons a
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
