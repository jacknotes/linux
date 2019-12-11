--增加酒店入住人
INSERT INTO [HotelOrderDB].[dbo].[HTL_OrderPersons]
           ([OrderPersonID]
           ,[OrderID]
           ,[UpID]
           ,[Name]
           ,[Sex]
           ,[Telephone]
           ,[Email]
           ,[DepartmentID]
           ,[DepartmentName]
           ,[PositionID]
           ,[PositionName]
           ,[CostCenterID]
           ,[CostCenterName]
           ,[ProjectNo]
           ,[ProjectName]
           ,[Nationality]
           ,[Number]
           ,[EmpType]
           ,[CreateDate]
           ,[ModifyDate]
           ,[VettingTemplateHotel]
           ,[PersonType]
           ,[GuestToRoomNo]
           ,[GuestType]
           ,[ConfirmSMS]
           ,[ConfirmEmail]
           ,[ConfirmWechat]
           ,[IsMyMobilePhone]
           ,[IdentityTag])
     VALUES
           (NEWID(),
           '17CC08F4-AB68-4DD5-91B9-F230CA163A8D',
           '00000000-0000-0000-0000-000000268656',
           '朱赛芳',
           1,
           '--',
           '--',
           '00000000-0000-0000-0000-000000000000',
           '--',
           '00000000-0000-0000-0000-000000000000',
           '',
           '00000000-0000-0000-0000-000000000000',
           '',
           '00000000-0000-0000-0000-000000000000',
           '',
           '--',
           '--',
           'nup',
           '2019-03-29 14:00:41.920',
           '2019-03-29 14:00:41.920',
           '0',
           '普通常旅客',
           '0',
           '0',
           '0',
           '0',
           '0',
           '0',
           NULL)
           
           
      select * from HotelOrderDB..HTL_OrderPersons where OrderID='2F772099-ED07-40FE-AF17-6871EA9CDA67'