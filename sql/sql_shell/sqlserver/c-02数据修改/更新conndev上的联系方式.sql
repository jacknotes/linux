

select * from openrowset( 'SQLOLEDB', 'conndev'; 'sa'; 'simper@1q2w3e4r',homsomDB.dbo.trv_human) where mobile='13817762451'


update openrowset( 'SQLOLEDB', '192.168.13.211'; 'sa'; 'simper@1q2w3e4r',[homsomDB].[dbo].[Trv_Human]) set Mobile='13817762451',Email='yan.yang@homsom.com'--�����г��ÿ͵��ֻ����뼰������Ϊ��������
update openrowset( 'SQLOLEDB', '192.168.13.211'; 'sa'; 'simper@1q2w3e4r',[homsomDB].[dbo].[Trv_Passengers]) set Mobile='13817762451',Email='yan.yang@homsom.com'--�����Ʊ�����п����ֻ��ż��ʼ�
update openrowset( 'SQLOLEDB', '192.168.13.211'; 'sa'; 'simper@1q2w3e4r',[homsomDB].[dbo].[Trv_UnitPersons]) set Phone='13817762451'--�����Ʊ�����п����ֻ��ż��ʼ�
update openrowset( 'SQLOLEDB', '192.168.13.211'; 'sa'; 'simper@1q2w3e4r',[homsomDB].[dbo].[Trv_Contacts]) set Mobile='13817762451',Email='yan.yang@homsom.com'--�����Ʊ�����п����ֻ��ż��ʼ�
update openrowset( 'SQLOLEDB', '192.168.13.211'; 'sa'; 'simper@1q2w3e4r',[hotelorderdb].[dbo].[HTL_OrderPersons]) set Telephone='',Email='yan.yang@homsom.com'--����Ƶ궩���п����ֻ��ż��ʼ�


