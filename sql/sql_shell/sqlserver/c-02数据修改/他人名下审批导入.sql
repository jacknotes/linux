--÷‹µ§∆ª√˚œ¬ÃÌº”…Û≈˙
--÷‹µ§∆ªUPCollectionID
select  e.ID from homsomDB..Trv_Human b
inner join homsomDB..Trv_UnitPersons a on a.ID=b.ID
inner join homsomDB..Trv_UnitCompanies c on a.companyid=c.ID
inner join homsomDB..Trv_UPSettings d on a.UPSettingID=d.ID
inner join homsomDB..Trv_BookingCollections e on d.BookingCollectionID=e.ID
where c.Cmpid='019830' and IsDisplay=1 
and b.Name='÷‹µ§∆ª'

select u.ID from homsomDB..Trv_UnitPersons u
left join homsomDB..Trv_Human h on h.ID=u.ID
where h.Name in ('∫´‘ŸºŒ','Õı–«Ω‹',
'—ÓΩ°','≈Àº“∫¿','–Ï≥¬Ÿª','⁄O–Ïø≠','≥¬¿ˆ','–ÏÁ‚',
'„∆π»Ÿ','¡Œ¿Ó','≥¬¡˙','¬ÌÀ≥','¿Ó—Ùπ‚','Œ∫Ω≠∑Á',
'’‘À’','≥≤”','’≈¿˛','¡ıº™','’≈è™º—','÷Ï«ø',
'≥Ã¥Û¿◊','ÕÙ√˜«Ÿ','ÀŒ”Í','∫‚√Õ','¿Óø°Ω‹','≤‹‘Ÿª‘','¡ıª∂',
'–‹«Ÿœº','¡ıÔ£','’≈≈Ù','¡ı∫Ï∫Ï','¡ı—Ó','µÀ¥˙Ω≠','’≈ŒƒΩ‹','÷£ª€æÍ','’≈∫Ï¿ˆ','¥˜—«È™','ø¬ª∂','∫Ó√˜æ√','¿Óπ˙∂∞','’‘µ¬√˜','¿Óº—–À')
and u.CompanyID='681617C0-6857-427F-B793-A73800FFFAC0'

--≤Â»Î–¬µƒÀ˚√«‘§∂®
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','DE41C50A-6B28-452E-B91E-059C0880A898')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','5CA25F1C-9E45-42BD-850F-0B721F67A721')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','D85CB319-CE28-480F-8810-0F71E540546C')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','7456E3C6-0CCD-449C-8184-0F922B25E272')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','3BA9C5CD-144D-4958-B56E-18E6A91AB05C')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','9EA0D7FE-ABD1-4F71-A65C-1A3846B42BA5')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','AE7BB9C3-736B-4128-AB9E-1AB081DBC0CF')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','F348B725-A7DE-41DB-961B-1F8907F2B295')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','CCCA4B84-62BF-4E7C-B9A1-2403223C6387')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','70345E79-E68C-4574-8C06-2C4F619426CA')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','F3CDA9C2-DFDC-45B6-A393-3F4A28E89ADE')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','09A354A2-869A-483E-AB9F-4AFA53AAEEA5')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','E2599853-2A5F-4111-9522-4B118FD28A96')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','53DE15E7-AF19-47A0-A75E-4B5C8D38189C')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','299B97F0-06FD-4364-953E-600069E9E32E')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','2FE2CDC2-779A-4C7F-B268-6A2E19210597')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','A68DAACF-5FD7-498B-A601-6CD2E65C670B')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','05E6295C-2BDB-4FD4-ABAD-734B4BAD66A7')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','F3AAC953-6316-416B-A3E4-7A161FFFC7EA')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','802A1366-1A63-483D-ADAA-80E149375AE0')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','16876598-0127-4684-A0A8-83C686099CC2')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','C4C37FF4-739D-4E2D-BEBA-84E6DD06F66B')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','165EE575-EA5E-4A1F-B56B-8611A8591A53')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','95F5E469-D3B4-4E48-993F-B0838DA8CE7F')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','EA8CBE6C-D417-415F-A2AA-B0848DA93207')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','0370A17E-76D0-4230-953F-B0AB14425B4B')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','109C07EC-B4AB-482F-808D-B26E25A1E1F4')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','773C43BB-24AD-4181-8775-B2D3E3F5E618')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','97A9602C-45AB-4905-B9E0-C4B963C863D5')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','5EE0ACEA-BA30-4C39-95AC-CD1272540009')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','B534DB91-0BC1-4CE8-9B96-DFCFEA865006')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','EB82592B-1693-4E6D-9946-E11AF925DA15')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','5B6485B3-BB95-4C5C-A56F-E96BC9B9D95E')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','B9965D6C-8EFD-4836-99AC-E9CB97680A93')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','F0B44C46-D8FC-43B5-B6AE-EB2540C2A5E0')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','12619D7F-BD4D-4095-8E4E-EC32AA67E104')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','06E04250-0994-423C-8FA0-EFFB18EDCDA2')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','DA940381-E8C9-4101-82C5-F035F8BBB604')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','722E3015-B2AA-4246-B9DB-F2B6FA894D7E')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','E99E7F1D-AB84-4191-91C1-F5E5B49F7F67')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','96F8436A-E506-4C00-8F0E-FACCAB7EC6BA')
insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) values ('0ECF5EBA-C859-4540-9FC7-DBE2C53D9462','8238754D-6CD7-46C2-86CA-FFDC7B48FDA2')
