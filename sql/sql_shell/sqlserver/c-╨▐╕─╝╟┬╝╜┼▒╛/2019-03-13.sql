--导入常旅客登录名
select * from homsomDB..Trv_UnitCompanies where Cmpid='020756'

select UserName,* from homsomDB..Trv_UnitPersons  u
left join homsomDB..Trv_Human h on h.ID=u.ID
where h.Name in ('陈晓慧','徐晓娟','陈杨','杨基宏','李柏杨','陈琳','胡骏涛','丁一','何岑玮','蒋力','李瑞寅','徐佳','刘应敏','莫阳','戴嘉','李大鹏','郑嘉朗','唐哲人','张馨月','王珂蔷','王婕','庄楚楚','陆娟','孙玮','贾天歌','刘俊成','项印','曲智强','孙可','眭奕嘉','黄维思','秦双双','陈楚佳','刘捷',	
'何璐')
and h.IsDisplay=1
and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659'
update homsomDB..Trv_UnitPersons set UserName='15906291180' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='陈晓慧')
update homsomDB..Trv_UnitPersons set UserName='13918132996' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='徐晓娟')
update homsomDB..Trv_UnitPersons set UserName='13524928106' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='陈杨')
update homsomDB..Trv_UnitPersons set UserName='13601953865' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='杨基宏')
update homsomDB..Trv_UnitPersons set UserName='18217699671' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='李柏杨')
update homsomDB..Trv_UnitPersons set UserName='13817068964' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='陈琳')
update homsomDB..Trv_UnitPersons set UserName='13916269018' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='胡骏涛')
update homsomDB..Trv_UnitPersons set UserName='13601889757' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='丁一')
update homsomDB..Trv_UnitPersons set UserName='13901907775' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='何岑玮')
update homsomDB..Trv_UnitPersons set UserName='15922788865' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='蒋力')
update homsomDB..Trv_UnitPersons set UserName='13918174156' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='李瑞寅')
update homsomDB..Trv_UnitPersons set UserName='13482561280' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='徐佳')
update homsomDB..Trv_UnitPersons set UserName='13918139443' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='刘应敏')
update homsomDB..Trv_UnitPersons set UserName='15900607504' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='莫阳')
update homsomDB..Trv_UnitPersons set UserName='18502123022' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='戴嘉')
update homsomDB..Trv_UnitPersons set UserName='13262862873' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='李大鹏')
update homsomDB..Trv_UnitPersons set UserName='18621104736' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='郑嘉朗')
update homsomDB..Trv_UnitPersons set UserName='13795402257' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='唐哲人')
update homsomDB..Trv_UnitPersons set UserName='13166092021' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='张馨月')
update homsomDB..Trv_UnitPersons set UserName='15850699608' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='王珂蔷')
update homsomDB..Trv_UnitPersons set UserName='18616291298' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='王婕')
update homsomDB..Trv_UnitPersons set UserName='15026817092' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='庄楚楚')
update homsomDB..Trv_UnitPersons set UserName='13671834368' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='陆娟')
update homsomDB..Trv_UnitPersons set UserName='15683676758' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='孙玮')
update homsomDB..Trv_UnitPersons set UserName='18983424860' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='贾天歌')
update homsomDB..Trv_UnitPersons set UserName='18251330162' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='刘俊成')
update homsomDB..Trv_UnitPersons set UserName='18608627301' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='项印')
update homsomDB..Trv_UnitPersons set UserName='15104141505' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='曲智强')
update homsomDB..Trv_UnitPersons set UserName='17782205567' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='孙可')
update homsomDB..Trv_UnitPersons set UserName='18362155792' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='眭奕嘉')
update homsomDB..Trv_UnitPersons set UserName='18640349517' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='黄维思')
update homsomDB..Trv_UnitPersons set UserName='18217045113' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='秦双双')
update homsomDB..Trv_UnitPersons set UserName='13773536230' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='陈楚佳')
update homsomDB..Trv_UnitPersons set UserName='18115669998' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='刘捷')
update homsomDB..Trv_UnitPersons set UserName='18816912909' where ID=(Select u.ID from homsomDB..Trv_UnitPersons u inner join homsomDB..Trv_Human h on u.ID=h.ID where IsDisplay=1 and u.CompanyID='F32CD3C8-F366-42D0-8A02-AA0E00F68659' and Name='何璐')

update homsomDB..Trv_UnitPersons set CompanyDptId=(Select ID from homsomDB..Trv_CompanyStructure 
where DepName='EHS' and CompanyID='C5BFAE84-A02E-4000-8E1C-A2A700DC9DBA') 
where ID=(Select up.ID from homsomDB..Trv_UnitPersons up
inner join homsomDB..Trv_Human hu on hu.ID=up.ID
where up.CompanyID='C5BFAE84-A02E-4000-8E1C-A2A700DC9DBA' and IsDisplay=1 and UserName='SH002760')

--打印权限
select PrDate,Pstatus,* from Topway..tbTrvKhTk where Id='301179'
select IsDisplay,Mobile,* from homsomDB..Trv_Human where Name in ('胡建波',
'周盛',
'姚金',
'陆友添',
'俞俊承',
'程琳',
'冯朱兰')
--and IsDisplay=0
and companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='020028')
order by Name

select IsDisplay,Name,ModifyDate,* from homsomDB..Trv_Human where Name in ('程琳','冯朱兰') and IsDisplay=1 and companyid='636613F1-2BB0-43F5-AF3C-A7C900D87177'
select IsDisplay,Name,ModifyDate,* from homsomDB..Trv_Human where Name in ('程琳','冯朱兰')  and companyid='636613F1-2BB0-43F5-AF3C-A7C900D87177'
select * from homsomDB..Trv_UnitPersons where ID in(Select ID from homsomDB..Trv_Human 

select * from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
 where h.Name in ('程琳','冯朱兰') and u.companyid='636613F1-2BB0-43F5-AF3C-A7C900D87177'
 
select TemplateName from homsomDB..Trv_VettingTemplates a 
left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID
where UnitCompanyID='636613F1-2BB0-43F5-AF3C-A7C900D87177'  and Inf=0  and (TemplateName like '%程琳%' or TemplateName like '%冯朱兰%')

--（产品部专用）机票供应商来源（国内）
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002295209'

--火车票销售价信息
select Ptype,* from Topway..tbTrainTicketInfo 
--update Topway..tbTrainTicketInfo set Ptype=4
where CoupNo in ('RS000020449','RS000020450','RS000020451','RS000020452')

--更新常旅客ID
select h.ID from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
 where h.Name in ('程琳') and u.companyid='636613F1-2BB0-43F5-AF3C-A7C900D87177' and IsDisplay=1
 
 select h.ID from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
 where h.Name in ('冯朱兰') and u.companyid='636613F1-2BB0-43F5-AF3C-A7C900D87177' and IsDisplay=1
 
update homsomDB..Trv_UnitPersons  set ID=(Select ID from homsomDB..Trv_Human where companyid='636613F1-2BB0-43F5-AF3C-A7C900D87177'and name='程琳' and IsDisplay=0)
where ID='2736B584-A647-48E2-B087-A7C900E5D905'
update homsomDB..Trv_UnitPersons  set ID=(Select ID from homsomDB..Trv_Human where companyid='636613F1-2BB0-43F5-AF3C-A7C900D87177'and name='冯朱兰' and IsDisplay=0)
where ID='3F4C40BD-FF1B-4CF5-87E4-A7C900E66EED'


--删除员工脚本 TMS
select * from  homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (
select a.ID from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='020756')
and IsDisplay=1 ) and CreateDate>='2019-03-13'
order by Name

--删除员工脚本ERP
select * from Topway..tbCusholderM 
--update Topway..tbCusholderM  set EmployeeStatus=0
where cmpid='020756'  and EmployeeStatus=1 and joindate>='2019-03-13'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='黄怡丽',SpareTC='黄怡丽'
where coupno='AS001485640'

--重开权限
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='29671'

--（产品部专用）机票供应商来源（国际）
select t_source,* from Topway..tbcash  
--update Topway..tbcash set t_source='垫付施中行I'
where coupno='AS002311712'

--旅游退款单作废
select Tkstatus,* from Topway..tbTrvKhTk 
--update Topway..tbTrvKhTk set Tkstatus=2
where Id='301179'

--酒店销售单 销售总价 请调整为-5600 结算总价 请调整为-5867 销售利润调整为14
select price,sprice,totprofit,status,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set price='-5600',sprice='-5867',totprofit='14'
where CoupNo='PTW077966'
--select price,sprice,totprofit,* from Topway..tbHtlcoupYf where CoupNo='PTW076453'
select totprice,owe,* from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set totprice='-5600',owe='-5600'
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo='PTW077966')

select TotalPrice,Status,* from HotelOrderDB..HTL_Orders 
--update HotelOrderDB..HTL_Orders set Status=40
where CoupNo='PTW077966'

select * from HotelOrderDB..HTL_Orders  where CoupNo='PTW076453'

--酒店销售单修改已确认
select price,sprice,totprofit,status,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set status=1
where CoupNo='PTW077966'

select TotalPrice,Status,* from HotelOrderDB..HTL_Orders 
--update HotelOrderDB..HTL_Orders set Status=40
where CoupNo='PTW077966'


--结算价差额
select totsprice,profit,* from Topway..tbcash  
--update Topway..tbcash  set totsprice=27053,profit=1946
where coupno='AS002313095'

