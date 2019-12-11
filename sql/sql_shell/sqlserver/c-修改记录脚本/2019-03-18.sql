--UC020518 上海华谊建设有限公司 2.12号之前导入的常旅客名单

SELECT 
ISNULL(c.Cmpid,'') AS 单位编号,
ISNULL(c.Name,'') AS 单位名称,
ISNULL(h.Name,'') AS 中文名,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS 英文名,
h.Mobile AS 手机号码,
ISNULL((SELECT TOP 1 empname FROM Topway..Emppwd WHERE idnumber=h.CreateBy),'') AS 差旅顾问,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS 运营经理
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate<='2019-02-12' --AND h.CreateDate<'2019-02-14' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT idnumber FROM Topway..Emppwd WHERE dep='运营部' AND idnumber NOT IN('00002','00003','0421'))
and c.Cmpid='020518'
UNION ALL

SELECT 
ISNULL(c.Cmpid,'') AS 单位编号,
ISNULL(c.Name,'') AS 单位名称,
ISNULL(h.Name,'') AS 中文名,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS 英文名,
ISNULL(h.Mobile,'') AS 手机号码,
h.CreateBy AS 差旅顾问,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS 运营经理
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate<='2019-02-12' --AND h.CreateDate<'2019-02-14' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT empname FROM Topway..Emppwd WHERE dep='运营部' AND empname NOT IN('homsom','恒顺旅行','运营培训测试'))
and c.Cmpid='020518'

select Name 姓名,Mobile 电话,CreateDate 导入日期 from homsomDB..Trv_Human  h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
where u.CompanyID=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='020518')
and CreateDate<='2019-02-12'
order by CreateDate

--供应商来源
select t_source,* FROM Topway..tbcash 
--UPDATE Topway..tbcash SET t_source='HSBSPETI'
WHERE coupno='AS002324474'

--结算保险价进位
select sprice1,totsprice,* FROM Topway..tbcash 
--UPDATE Topway..tbcash  SET sprice1=2,totsprice=2
WHERE coupno IN('AS002296182','AS002299311','AS002299310','AS002299312','AS002299313','AS002299314','AS002303818','AS002303819','AS002303820', 
'AS002303821','AS002303828','AS002303830','AS002315492','AS002315692')

--单位类型、结算方式、账单开始日期、新增月、注册月
--注册日
SELECT CustomerType,indate 注册,depdate0 新增,sform,* FROM Topway..tbCompanyM 
--update Topway..tbCompanyM  set indate='2019-03-18',sform='月结(中行)'
WHERE cmpid='016890'

select Type,RegisterMonth,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set RegisterMonth='03  18 2019 12:00AM'
where Cmpid='016890'

--结算方式
select * from Topway..HM_CompanyAccountInfo 
where CmpId='016890'

select SEndDate,Status,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SEndDate='2019-02-28',Status=-1
where CmpId='016890' and Status=1

select SStartDate,Status,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SStartDate='2019-03-01',Status=1
where CmpId='016890' and Status=2

SELECT EndDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes  set EndDate='2019-02-28',Status='-1'
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '016890') and Status=1

SELECT StartDate,Status,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set StartDate='2019-03-01',Status=1
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '016890') and Status=2

--账单
select * from Topway..AccountStatement where CompanyCode='016890' order by BillNumber desc

select SX_BaseCreditLine,SX_TotalCreditLine* from Topway..AccountStatement where BillNumber='016890_20190301'

--康宝莱2018年7-12月里程
--国内
IF OBJECT_ID('tempdb.dbo.#mileage') IS NOT NULL DROP TABLE #mileage
select DISTINCT rtrim(cityfrom)+'-'+rtrim(cityto) route,mileage,kilometres 
into #mileage
from tbmileage

IF OBJECT_ID('tempdb.dbo.#tbcash1') IS NOT NULL DROP TABLE #tbcash1
select coupno as 销售单号,ride+flightno as 航班号,datetime as 出票日期,begdate 起飞日期,pasname 乘客姓名
,case SUBSTRING(route,1,CHARINDEX('-',route)-1) when '上海浦东' then '上海' when '上海虹桥' then '上海' when '北京首都' then '北京' when '北京南苑' then '北京' when '西安咸阳' then '西安' 
when '遵义新舟' then '遵义' when '揭阳' then '汕头' when '武汉天河' then '武汉' when '景洪' then '西双版纳' when '乌兰察布集宁' then '乌兰察布' when '德宏' then '芒市' when '思茅' then '普洱' when '梅县' then '梅州'
else SUBSTRING(route,1,CHARINDEX('-',route)-1) end as 出发
,case REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) when '上海浦东' then '上海' when '上海虹桥' then '上海' when '北京首都' then '北京' when '北京南苑' then '北京' when '西安咸阳' then '西安' 
when '遵义新舟' then '遵义' when '揭阳' then '汕头' when '武汉天河' then '武汉' when '景洪' then '西双版纳' when '乌兰察布集宁' then '乌兰察布' when '德宏' then '芒市' when '思茅' then '普洱' when '梅县' then '梅州'
else  REVERSE(SUBSTRING(REVERSE(route),1,CHARINDEX('-',REVERSE(route))-1)) end as 到达
,route as 行程
,t_source as 供应商来源
into #tbcash1
from tbcash c
where cmpcode='020459'
and (datetime>='2018-07-01' and datetime<'2019-01-01')
and inf=0
and route like ('%-%')
and reti=''
and tickettype='电子票'
order by datetime

IF OBJECT_ID('tempdb.dbo.#tbcash') IS NOT NULL DROP TABLE #tbcash
select *,出发+'-'+到达 as route2,到达+'-'+出发 as route3
into #tbcash
from #tbcash1


IF OBJECT_ID('tempdb.dbo.#tt') IS NOT NULL DROP TABLE #tt
select 销售单号,tbcash.行程,出票日期,起飞日期,乘客姓名,mileage 英里,kilometres 公里
into #tt
from #tbcash tbcash
left join #mileage mileage on mileage.route=tbcash.route2 or mileage.route=tbcash.route3

select * from #tt
order by 出票日期
where kilometres is null

--国际
select coupno 销售单号,route 行程,datetime 出票日期,begdate 起飞日期,pasname 乘客姓 ,'' 英里,'' 公里  from Topway..tbcash
where cmpcode='020459'
and (datetime>='2018-07-01' and datetime<'2019-01-01')
and inf=0
and route like ('%-%')
and reti=''
and tickettype='电子票'
order by datetime


select * from topway..tmpdata


--审批模板id更新
--select * from homsomDB..Trv_UnitCompanies where Cmpid='020380'

SELECT n.ProcessPerson,n.ProcessPersonName,h.IsDisplay,
(SELECT h1.id FROM homsomDB..Trv_Human h1 INNER JOIN homsomDB..Trv_UnitPersons u1 ON u1.ID = h1.ID AND h1.name=n.ProcessPersonName AND h1.IsDisplay=1 AND u1.CompanyID='1D209DB4-4F14-4635-B626-A8D600DB5C9E') name1
,h.Name,t.*,* 
--UPDATE workflow..Homsom_WF_Template_Node SET ProcessPerson=(SELECT TOP 1 h1.id FROM homsomDB..Trv_Human h1 INNER JOIN homsomDB..Trv_UnitPersons u1 ON u1.ID = h1.ID AND h1.name=n.ProcessPersonName AND h1.IsDisplay=1  AND u1.CompanyID='1D209DB4-4F14-4635-B626-A8D600DB5C9E') 
FROM workflow..Homsom_WF_Template_Node n 
LEFT JOIN workflow..Homsom_WF_Template t ON n.TemplateID=t.TemplateID
LEFT JOIN homsomDB..Trv_Human  h ON n.ProcessPerson=h.ID
LEFT JOIN homsomDB..Trv_UnitPersons u ON h.id=u.ID
WHERE n.ProcessPerson<>'' 
AND t.CmpID='020380'
--AND n.TemplateID IN(
--SELECT TemplateID FROM workflow..Homsom_WF_Template WHERE TemplateName IN
--('审批二级模板-周盛-冯朱兰','审批二级模板-俞俊承-冯朱兰','审批二级模板-姚金-冯朱兰','审批二级模板-陆友添-冯朱兰','审批二级模板-吴凯-冯朱兰',
--'审批二级模板-周荣-冯朱兰','审批二级模板-胡建波-冯朱兰','审批二级模板-程琳-冯朱兰','审批二级模板-石惠超-冯朱兰','审批二级模板-曹庆华-冯朱兰')
--) 
AND h.IsDisplay=0 order by t.templatename


--账单撤销
select TrainBillStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement set TrainBillStatus=1
where BillNumber='018309_20190201'

--修改UC号（酒店）
select * from Topway..tbCusholderM where custname='龚恬'
select custid,custinfo,spersoninfo,* from Topway..tbHtlcoupYf
--update tbHtlcoupYf set custid='D641764',custinfo='和铂医药（上海）有限责任公司|龚恬|13962103393|13962103393',spersoninfo='龚恬|13962103393||' 
where coupno in ('PTW078216')

--（产品专用）申请费来源/金额信息（国际）
select feiyong,feiyonginfo,* from Topway..tbcash  
--update Topway..tbcash set feiyonginfo='申请座位ZYI'
where coupno='AS002314148'

select feiyong,feiyonginfo,* from Topway..tbcash  
--update Topway..tbcash set feiyonginfo='申请座位MYI'
where coupno='AS002310184'

--酒店销售单 结算总价 请调整为40201.56
select price,sprice,totprofit,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set sprice='40201.56',totprofit='-0.56'
where CoupNo='PTW078138'
--select price,sprice,totprofit,* from Topway..tbHtlcoupYf where CoupNo='PTW076453'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='10951',profit='982'
where coupno='AS002322399'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='7564',profit='4241'
where coupno='AS002319994'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='7964',profit='3842'
where coupno='AS002320003'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='7204',profit='4602'
where coupno='AS002320030'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='7964',profit='3842'
where coupno='AS002320057'

--UC016448 的2018年国内国际的销量，就成本中心CA的
--国际
select convert(varchar(6),datetime,112)  月份,sum(price) 销量
from Topway..tbcash
where cmpcode='016448'
and(datetime BETWEEN '2018-01-01' AND '2018-12-31')
and reti=''
and inf=1
and tickettype='电子票'
and CostCenter='ca'
and (route not like '%改期%' or route not like'%升舱%')
group by convert(varchar(6),datetime,112)
order  by 月份

--国内
select convert(varchar(6),datetime,112)  月份,sum(price) 销量
from Topway..tbcash
where cmpcode='016448'
and(datetime BETWEEN '2018-01-01' AND '2018-12-31')
and reti=''
and inf=0
and tickettype='电子票'
and CostCenter='ca'
group by convert(varchar(6),datetime,112)
order  by 月份

--（产品专用）申请费来源/金额信息（国际）
select feiyong,feiyonginfo,* from Topway..tbcash  
--update Topway..tbcash set feiyong=717,feiyonginfo='申请座位ZYI'
where coupno='AS002308529'
select feiyong,feiyonginfo,* from Topway..tbcash  
--update Topway..tbcash set feiyong=0,feiyonginfo=''
where coupno='AS002318981'

--酒店垫付改自付
select AdvanceMethod,PayMethod,AdvanceStatus,PayStatus,AdvancePayNo,PayNo,AdvanceDate,PaySubmitDate from Topway..tbHtlcoupRefund 
--update Topway..tbHtlcoupRefund  set AdvanceMethod=0,PayMethod=3,AdvanceStatus=0,PayStatus=3,PayNo='4200000261201902262051324341',AdvancePayNo=null,PaySubmitDate='2019-02-26 15:58:34.000',AdvanceDate=null
where CoupNo='PTW076858'

select cwstatus,owe,vpay,opername1,vpayinfo,oth2 from Topway..tbhtlyfchargeoff
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo='PTW076858')

select AdvanceNumber,AdvanceName,AdvanceStatus,AdvanceDate,PayStatus,PayDate from HotelOrderDB..HTL_Orders 
--update HotelOrderDB..HTL_Orders set AdvanceNumber='',AdvanceName='',PayStatus=3,AdvanceStatus=0,PayDate='2019-02-26 15:58:34.000',AdvanceDate=null
where CoupNo='PTW076858'

select AdvancePayNo,PayNo,AdvanceMethod,PayMethod,* from HotelOrderDB..HTL_OrderSettlements 
--update HotelOrderDB..HTL_OrderSettlements  set PayNo='4200000261201902262051324341',AdvancePayNo=null,PayMethod=3,AdvanceMethod=null
where OrderID in(Select OrderID from HotelOrderDB..HTL_Orders where CoupNo='PTW076858')

--账单撤销

select SubmitState,* from  Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='018294_20190116'

--UC019830和通汽车投资有限公司常旅客
select Name,CredentialNo from homsomDB..Trv_UnitPersons u
left join homsomDB..Trv_Human h on h.ID=u.ID
left join homsomDB..Trv_Credentials cr on cr.HumanID=h.ID
where u.CompanyID='681617C0-6857-427F-B793-A73800FFFAC0'
and IsDisplay=1

--国内机票审批模板

update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='韩再嘉' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='王星杰' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='杨健' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='潘家豪' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='徐陈倩' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='贠徐凯' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='陈丽' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='徐玮' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='闫桂荣' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='廖李' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='陈龙' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='马顺' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='李阳光' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='魏江风' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='赵苏' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='巢羽' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='张俐' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='刘吉' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='张彧佳' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='朱强' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='程大雷' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='汪明琴' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='宋雨' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='衡猛' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='李俊杰' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='曹再辉' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='刘欢' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='熊琴霞' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='刘铮' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='张鹏' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='刘红红' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='刘杨' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='邓代江' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='张文杰' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='郑慧娟' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='张红丽' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='戴亚楠' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='柯欢' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='侯明久' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='李国栋' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='赵德明' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')
update homsomDB..Trv_UnitPersons set VettingTemplateID=(select ID from homsomDB..Trv_VettingTemplates  a left join homsomDB..Trv_VettingTemplate_UnitCompany b on a.ID=b.VettingTemplateID where UnitCompanyID='681617C0-6857-427F-B793-A73800FFFAC0' and TemplateName='审批1级模版-陆林花' and Inf=0) where ID=(select up.ID from homsomDB..Trv_UnitPersons up inner join homsomDB..Trv_Human hu on up.ID=hu.ID where hu.Name='李佳兴' and IsDisplay=1  and up.companyid='681617C0-6857-427F-B793-A73800FFFAC0')


--周丹苹名下添加审批
--周丹苹UPCollectionID
select  e.ID from homsomDB..Trv_Human b
inner join homsomDB..Trv_UnitPersons a on a.ID=b.ID
inner join homsomDB..Trv_UnitCompanies c on a.companyid=c.ID
inner join homsomDB..Trv_UPSettings d on a.UPSettingID=d.ID
inner join homsomDB..Trv_BookingCollections e on d.BookingCollectionID=e.ID
where c.Cmpid='019830' and IsDisplay=1 
and b.Name='周丹苹'

select u.ID from homsomDB..Trv_UnitPersons u
left join homsomDB..Trv_Human h on h.ID=u.ID
where h.Name in ('韩再嘉','王星杰',
'杨健','潘家豪','徐陈倩','贠徐凯','陈丽','徐玮',
'闫桂荣','廖李','陈龙','马顺','李阳光','魏江风',
'赵苏','巢羽','张俐','刘吉','张彧佳','朱强',
'程大雷','汪明琴','宋雨','衡猛','李俊杰','曹再辉','刘欢',
'熊琴霞','刘铮','张鹏','刘红红','刘杨','邓代江','张文杰','郑慧娟','张红丽','戴亚楠','柯欢','侯明久','李国栋','赵德明','李佳兴')
and u.CompanyID='681617C0-6857-427F-B793-A73800FFFAC0'

--插入新的他们预定
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


--结算价差额
select totsprice,profit,* from Topway..tbcash  
--update Topway..tbcash set totsprice='9336',profit='945'
where coupno='AS002321892'

--机票销售单改为未付
select bpay ,status ,opernum ,oper2,oth2 ,totprice,dzhxDate ,owe  from Topway..tbcash
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
 where coupno in ('AS002250569',
'AS002211474',
'AS002211953',
'AS002212444',
'AS002212444',
'AS002212442',
'AS002214516',
'AS002214646',
'AS002214666',
'AS002215488',
'AS002215488',
'AS002215488',
'AS002215486',
'AS002215486',
'AS002215486',
'AS002215678',
'AS002215678',
'AS002215684',
'AS002215684',
'AS002217432',
'AS002218235',
'AS002220945',
'AS002223196',
'AS002223202',
'AS002223198',
'AS002223205',
'AS002223211',
'AS002223209',
'AS002224699',
'AS002225050',
'AS002225154',
'AS002225227',
'AS002225655',
'AS002225670',
'AS002225672',
'AS002225749',
'AS002226537',
'AS002227475',
'AS002227479',
'AS002227693',
'AS002228014',
'AS002228038',
'AS002228968',
'AS002229288',
'AS002229628',
'AS002229722',
'AS002230139',
'AS002230384',
'AS002230386',
'AS002230561',
'AS002230561',
'AS002230601',
'AS002230741',
'AS002230767',
'AS002230800',
'AS002230819',
'AS002230743',
'AS002230888',
'AS002231477',
'AS002231621',
'AS002231631',
'AS002231716',
'AS002232085',
'AS002232362',
'AS002232347',
'AS002232347',
'AS002232347',
'AS002232347',
'AS002232347',
'AS002232347',
'AS002232347',
'AS002232347',
'AS002232856',
'AS002233025',
'AS002233745',
'AS002234085',
'AS002234098',
'AS002234250',
'AS002234325',
'AS002234327',
'AS002234726',
'AS002235089',
'AS002235175',
'AS002235555',
'AS002236316',
'AS002236938',
'AS002238964',
'AS002239025',
'AS002239109',
'AS002239377',
'AS002240590',
'AS002240597',
'AS002240779',
'AS002240780',
'AS002242526',
'AS002242522',
'AS002243541',
'AS002243535',
'AS002243543',
'AS002243549',
'AS002246984',
'AS002246984',
'AS002246990',
'AS002246990',
'AS002247551',
'AS002247632',
'AS002247632',
'AS002247634',
'AS002247634',
'AS002247926',
'AS002247926',
'AS002247926',
'AS002247928',
'AS002247928',
'AS002247928',
'AS002248004',
'AS002250174',
'AS002250227',
'AS002250227',
'AS002250341')
 
 --酒店销售单改为未付
 
 select cwstatus,owe,vpay,opername1,vpayinfo,oth2,totprice,operdate1,* from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set cwstatus=0,owe=totprice,opername1='',operdate1='1900-01-01'
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo in('PTW075117','PTW075504','PTW075760','PTW076016'))

/*  报表一 查询条件
    1、出票日期：2018年1月1日--12月31日
    2、业务类型：国际
    3、供应商来源：去除外开XXXI 、官网XXX I、垫付XXXXI 、B2BXXXI
    4、扣除退票、扣除结算价为0、10、20
    5、报表要求： 给出总的出票笔数即可    
    */
  select COUNT(1) 出票笔数 from Topway..tbcash  
  where datetime>='2018-01-01'  
  and datetime<'2019-01-01'
  and inf=1
  and t_source not like'外开%I'
  and t_source not like'官网%I'
  and t_source not like'垫付%I'
  and t_source not like'B2B%I'
  --and reti=''
  and totsprice not in ('0','10','20')  
    
  /*  报表二 查询条件
    1、出票日期：2018年1月1日--12月31日 
    2、业务类型：国际
    3、供应商来源：去除外开XXXI 、官网XXX I、垫付XXXXI 、B2BXXXI
    4、扣除退票、扣除结算价为0、10、20
    5、销售单类型：改期升舱 或行程中包含“改期”
    5、报表要求： 销售单号、航司2字码、票号、行程、差旅顾问
*/
select coupno 销售单号,ride 航司2字码,tcode+ticketno 票号,route 行程,sales  差旅顾问 from Topway..tbcash  
  where datetime>='2018-01-01'  
  and datetime<'2019-01-01'
  and inf=1
  and t_source not like'外开%I'
  and t_source not like'官网%I'
  and t_source not like'垫付%I'
  and t_source not like'B2B%I'
  --and reti=''
  and ((tickettype like'%改期%' or tickettype like'%升舱%') or route in('%改期%','%升舱%'))
  and totsprice not in ('0','10','20')  
  
  select bpay ,status ,opernum ,oper2,oth2 ,totprice,dzhxDate ,owe  from Topway..tbcash
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
 where coupno in ('AS002238964','AS002234726','AS002231716','AS002231631','AS002203199')
 
 --账单核销状态
 select SalesOrderState,* from Topway..AccountStatement 
 --update Topway..AccountStatement  set SalesOrderState=0
 where BillNumber='018294_20190116'
 
 --机票业务顾问信息
 select sales,SpareTC,* from Topway..tbcash 
 --update Topway..tbcash set sales='黄怡丽',SpareTC='黄怡丽'
 where coupno  in ('AS001547835','AS001504424')
 
 --结算价差额
 select totsprice,profit,* from Topway..tbcash  where coupno='AS002321892'
 
 select * from homsomDB..Trv_Memos
 
 select COUNT(1) from Topway..tbcash  where cmpcode='020459'
 and datetime>='2018-07-01'
 and datetime<'2019-01-01'