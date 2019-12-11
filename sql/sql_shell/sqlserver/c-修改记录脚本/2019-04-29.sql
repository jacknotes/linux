--删除多余机场
--select* from homsomDB..Trv_Cities where ID='06766E93-C64A-4ECF-A94E-508EDD01AA03'
select * 
--delete
from homsomDB..Trv_Airport where Code='HUN' 
and CityID='290F54BE-76BF-4B6B-9B29-0EC5F7189FA2'

--火车票销售价信息
select TotFuprice,TotPrice,TotFuprice,TotSprice,TotUnitprice,* from Topway..tbTrainTicketInfo 
--update Topway..tbTrainTicketInfo set TotPrice=144,TotSprice=144,TotUnitprice=144
where CoupNo='RS000022924'

select SettlePrice,RealPrice,* from Topway..tbTrainUser 
--update Topway..tbTrainUser set SettlePrice=144,RealPrice=144
where TrainTicketNo=(select ID from Topway..tbTrainTicketInfo where CoupNo='RS000022924')

--会务预算单信息
select Sales,OperName,introducer,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Sales='崔之阳',OperName='0481崔之阳',introducer='崔之阳-0481-运营部'
where ConventionId in('1388','1088','1363','1371','1212','1211','1369','1169','940','1254','1086','1210',
'1015','1368','1107','1076','1070','1377')

--何洁4月份国际机票张数
select cmpcode,coupno,tcode+ticketno,sales,SpareTC from Topway..tbcash 
where sales='何洁' and SpareTC='何洁'
and datetime>='2019-04-01'
and inf=1
--and reti=''
and tickettype not like '%改期%'
and tickettype not like '%升舱%'
and route not like '%改期费%'
and route not like '%升舱费%'
and route not like '%退票费%'
and sales<>''
and cmpcode<>''


select cmpcode,coupno,tcode+ticketno,sales,SpareTC from Topway..tbcash 
where sales='何洁' and SpareTC='何洁'
and datetime>='2019-04-01'
and inf=1
--and reti=''
and tickettype not like '%改期%'
and tickettype not like '%升舱%'
and route not like '%改期费%'
and route not like '%升舱费%'
and route not like '%退票费%'
and sales<>''
and cmpcode=''
and totprice=0

select cmpcode,coupno,tcode+ticketno,sales,SpareTC from Topway..tbcash 
where sales<>SpareTC and SpareTC='何洁'
and datetime>='2019-04-01'
and inf=1
--and reti=''
and tickettype not like '%改期%'
and tickettype not like '%升舱%'
and route not like '%改期费%'
and route not like '%升舱费%'
and route not like '%退票费%'
and sales<>''
and cmpcode<>''
and totprice=0

select cmpcode,coupno,tcode+ticketno,sales,SpareTC from Topway..tbcash 
where sales<>SpareTC and SpareTC='何洁'
and datetime>='2019-04-01'
and inf=1
--and reti=''
and tickettype not like '%改期%'
and tickettype not like '%升舱%'
and route not like '%改期费%'
and route not like '%升舱费%'
and route not like '%退票费%'
and sales<>''
and cmpcode=''
and totprice=0

select cmpcode,coupno,tcode+ticketno,sales,SpareTC from Topway..tbcash 
where sales<>SpareTC and sales='何洁'
and datetime>='2019-04-01'
and inf=1
--and reti=''
and tickettype not like '%改期%'
and tickettype not like '%升舱%'
and route not like '%改期费%'
and route not like '%升舱费%'
and route not like '%退票费%'
and sales<>''
and cmpcode<>''
and totprice=0

select  r.cmpcode,r.coupno,c.tcode+c.ticketno,c.sales,c.SpareTC from Topway..tbReti r
left join Topway..tbcash c on c.reti=r.reno and c.ticketno=r.ticketno
 where r.inf=1
 and r.status2 not in (1,3,4) 
 and ExamineDate >='2019-04-01'
and c.cmpcode<>''
and c.sales<>SpareTC and  c.SpareTC='何洁'
and c.cmpcode=''

select  r.cmpcode,r.coupno,c.tcode+c.ticketno,c.sales,c.SpareTC from Topway..tbReti r
left join Topway..tbcash c on c.reti=r.reno and c.ticketno=r.ticketno
 where r.inf=1
 and r.status2 not in (1,3,4) 
 and ExamineDate >='2019-04-01'
and c.cmpcode<>''
and c.sales<>SpareTC and  c.SpareTC='何洁'
and c.cmpcode<>''

select  r.cmpcode,r.coupno,c.tcode+c.ticketno,c.sales,c.SpareTC from Topway..tbReti r
left join Topway..tbcash c on c.reti=r.reno and c.ticketno=r.ticketno
 where r.inf=1
 and r.status2 not in (1,3,4) 
 and ExamineDate >='2019-04-01'
and c.cmpcode<>''
and c.sales<>SpareTC and  c.sales='何洁'
and c.cmpcode<>''

select  r.cmpcode,r.coupno,c.tcode+c.ticketno,c.sales,c.SpareTC from Topway..tbReti r
left join Topway..tbcash c on c.reti=r.reno and c.ticketno=r.ticketno
 where r.inf=1
 and r.status2 not in (1,3,4) 
 and ExamineDate >='2019-04-01'
and c.cmpcode<>''
and c.sales='何洁' and  c.SpareTC='何洁'
and c.cmpcode<>''

select  r.cmpcode,r.coupno,c.tcode+c.ticketno,c.sales,c.SpareTC from Topway..tbReti r
left join Topway..tbcash c on c.reti=r.reno and c.ticketno=r.ticketno
 where r.inf=1
 and r.status2 not in (1,3,4) 
 and ExamineDate >='2019-04-01'
and c.cmpcode<>''
and c.sales='何洁' and  c.SpareTC='何洁'
and c.cmpcode=''



SELECT sales,SpareTC,* FROM Topway..tbcash WHERE coupno='AS002384092'

--撤销闭团
select  ModifyDate,Status, * from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Status='14'
where ConventionId='1167'

select ModifyDate,Status,* 
--delete
from Topway..tbConventionCoup where ConventionId='1167'


--补名字
--select pasname,* from Topway..tbcash where coupno='AS002386292'
--update Topway..tbcash set pasname='' where coupno='AS002386292' and pasname=''

update Topway..tbcash set pasname='HUANG/XINYI' where coupno='AS002386292' and pasname='乘客0'
update Topway..tbcash set pasname='HUANG/YIMENG' where coupno='AS002386292' and pasname='乘客1'
update Topway..tbcash set pasname='JIANG/XUE' where coupno='AS002386292' and pasname='乘客2'
update Topway..tbcash set pasname='KE/YUXING' where coupno='AS002386292' and pasname='乘客3'
update Topway..tbcash set pasname='LIN/JIAYU' where coupno='AS002386292' and pasname='乘客4'
update Topway..tbcash set pasname='LIU/SICHEN' where coupno='AS002386292' and pasname='乘客5'
update Topway..tbcash set pasname='LU/YIWEN' where coupno='AS002386292' and pasname='乘客6'
update Topway..tbcash set pasname='PAN/WANJING' where coupno='AS002386292' and pasname='乘客7'
update Topway..tbcash set pasname='SHENG/HUIYING' where coupno='AS002386292' and pasname='乘客8'
update Topway..tbcash set pasname='TAO/LELE' where coupno='AS002386292' and pasname='乘客9'

update Topway..tbcash set pasname='WANG/JIAYIN ' where coupno='AS002386294' and pasname='乘客0'
update Topway..tbcash set pasname='WANG/QINGFENG ' where coupno='AS002386294' and pasname='乘客1'
update Topway..tbcash set pasname='WANG/YONGLIN   ' where coupno='AS002386294' and pasname='乘客2'
update Topway..tbcash set pasname='WU/WENPING ' where coupno='AS002386294' and pasname='乘客3'
update Topway..tbcash set pasname='YU/WEI  ' where coupno='AS002386294' and pasname='乘客4'
update Topway..tbcash set pasname='YUE/BING   ' where coupno='AS002386294' and pasname='乘客5'
update Topway..tbcash set pasname='ZHAI/ZHI  ' where coupno='AS002386294' and pasname='乘客6'
update Topway..tbcash set pasname='ZHANG/XIAOMEI   ' where coupno='AS002386294' and pasname='乘客7'
update Topway..tbcash set pasname='ZHU/LIN  ' where coupno='AS002386294' and pasname='乘客8'
update Topway..tbcash set pasname='WANG/HAIXUE ' where coupno='AS002386294' and pasname='乘客9'
update Topway..tbcash set pasname='OU/YIJOU  ' where coupno='AS002386294' and pasname='乘客10'

update Topway..tbcash set pasname='FENG/XIAOBEI' where coupno='AS002386293' and pasname='5月16日普吉岛36人团'

update Topway..tbcash set pasname='CHEN/LI ' where coupno='AS002386295' and pasname='乘客0'
update Topway..tbcash set pasname='CHEN/YANXI' where coupno='AS002386295' and pasname='乘客1'
update Topway..tbcash set pasname='CHEN/YING ' where coupno='AS002386295' and pasname='乘客2'
update Topway..tbcash set pasname='GONG/SHICHUN ' where coupno='AS002386295' and pasname='乘客3'
update Topway..tbcash set pasname='GUO/ZHENGJIANG ' where coupno='AS002386295' and pasname='乘客4'
update Topway..tbcash set pasname='HAN/WANGXIN' where coupno='AS002386295' and pasname='乘客5'
update Topway..tbcash set pasname='HU/MEIYING ' where coupno='AS002386295' and pasname='乘客6'
update Topway..tbcash set pasname='HU/YATING ' where coupno='AS002386295' and pasname='乘客7'
update Topway..tbcash set pasname='HUANG/TING   ' where coupno='AS002386295' and pasname='乘客8'
update Topway..tbcash set pasname='HUANG/WENQI ' where coupno='AS002386295' and pasname='乘客9'

--018890单位更名
--select * from Topway..tbCompanyM where cmpid='018890'
--select *from homsomDB..Trv_UnitCompanies where Cmpid='018890'

select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement set CompanyNameCN='上海海隆信技软件有限公司'
where BillNumber='018890_20190426'

--删除回访记录
SELECT UnitCompanyID,* FROM homsomdb..Trv_Memos
--update homsomdb..Trv_Memos set UnitCompanyID=null
WHERE UnitCompanyID in (select id from homsomdb..Trv_UnitCompanies where Cmpid='018178')
and ID in('0535A70A-F608-4D5F-ACE4-AA3E00E81432')

--账单核销
select dzhxDate,status,oper2,* from Topway..tbcash 
--update Topway..tbcash  set dzhxDate='2019-04-26',status=1,oper2='周玥玲'
where ModifyBillNumber='018661_20190301'

--删除结算方式
select * from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner  set Status=-1
where CmpId='020808' and Status=2

SELECT * FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set Status=-1
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '020808') and Status=2

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='携程官网分销联盟'
where CoupNo='PTW080720'

--修改UC号（机票）
select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,inf,pform,xfprice,* from Topway..tbcash
--update topway..tbcash set cmpcode='016888',OriginalBillNumber='016888_20190326'
 where coupno in ('AS002430325')
 
 --（产品专用）申请费来源/金额信息（国内）
 select feiyonginfo,feiyong,* from Topway..tbcash 
 --update Topway..tbcash set feiyonginfo='申请YGD',feiyong=10
 where coupno in('AS002396125','AS002396843','AS002397428','AS002397466'
 ,'AS002408366','AS002405059','AS002407574','AS002419523')
 
 --结算价差额
 select totsprice,profit,* from Topway..tbcash 
 --update Topway..tbcash  set totsprice=8980,profit=1101
 where coupno ='AS002435367'
 
  select totsprice,profit,* from Topway..tbcash 
 --update Topway..tbcash  set totsprice=8963,profit=811
 where coupno ='AS002434427'
 
 
 --机票业务顾问信息
 select sales,SpareTC,* from Topway..tbcash 
 --update Topway..tbcash  set sales='丁琳',SpareTC='丁琳'
 where coupno='AS002433360'
 
 --账单撤销
 select SubmitState,* from Topway..AccountStatement 
 --update Topway..AccountStatement  set SubmitState=1
 where BillNumber in('018309_20190201','018309_20190301')
 
 
 --结算价差额
 select totsprice,profit,* from Topway..tbcash 
 --update Topway..tbcash  set totsprice=4083,profit=-1
 where coupno='AS002432908' and totsprice=4082.000
 
  select totsprice,profit,* from Topway..tbcash 
 --update Topway..tbcash  set totsprice=6151,profit=1438
 where coupno='AS002435612' 
 
--补票号
--select pasname,* from Topway..tbcash where coupno='AS002436636'
--update Topway..tbcash set tcode='',ticketno='',pasname='' where coupno='AS002436636' and pasname=''
update Topway..tbcash set tcode='781',ticketno='2400314721',pasname='CHEN/JINGSHU' where coupno='AS002436636' and pasname='乘客0'
update Topway..tbcash set tcode='781',ticketno='2400314722',pasname='CHENG/CHAOWEN' where coupno='AS002436636' and pasname='乘客1'
update Topway..tbcash set tcode='781',ticketno='2400314723',pasname='HUANG/HUIQIN' where coupno='AS002436636' and pasname='乘客2'
update Topway..tbcash set tcode='781',ticketno='2400314724',pasname='LI/HUI' where coupno='AS002436636' and pasname='乘客3'
update Topway..tbcash set tcode='781',ticketno='2400314725',pasname='LIU/AIPING' where coupno='AS002436636' and pasname='乘客4'
update Topway..tbcash set tcode='781',ticketno='2400314726',pasname='LIU/JUAN' where coupno='AS002436636' and pasname='乘客5'
update Topway..tbcash set tcode='781',ticketno='2400314727',pasname='TIAN/CHUNCHUN' where coupno='AS002436636' and pasname='乘客6'
update Topway..tbcash set tcode='781',ticketno='2400314728',pasname='WEN/XIAOYI' where coupno='AS002436636' and pasname='乘客7'
update Topway..tbcash set tcode='781',ticketno='2400314729',pasname='XIA/NANKAI' where coupno='AS002436636' and pasname='乘客8'
update Topway..tbcash set tcode='781',ticketno='2400314730',pasname='YUAN/JIANYING' where coupno='AS002436636' and pasname='乘客9'

--UC018781删除员工脚本 TMS
select * from  homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (
select a.ID from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018781')
and IsDisplay=1 and Name not in ('张晓燕','刘君','王珏莹')
)


--删除员工脚本ERP
select EmployeeStatus,* from Topway..tbCusholderM 
--update Topway..tbCusholderM  set EmployeeStatus=0
where cmpid='018781' and custname not in ('张晓燕','刘君','王珏莹')

--旅游收款单打印
select Pstatus,PrDate,* from Topway..tbTrvKhSk 

where TrvId='29997' and Id='227817'

select sales,* from Topway..tbcash 
--update Topway..tbcash set sales='何洁'
where coupno='AS002384092'

--插入项目编号
--select * from homsomdb..Trv_UnitCompanies where Cmpid='020805'
--select * from homsomdb..Trv_Customizations
--insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'招商',0,'招商','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'招商',0,'招商','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'领地',0,'领地','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中海',0,'中海','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'五矿',0,'五矿','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'铧发',0,'铧发','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'大发',0,'大发','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'复地',0,'复地','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'瑞安',0,'瑞安','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'华宇',0,'华宇','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'山东高速',0,'山东高速','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'泰禾',0,'泰禾','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'鲁能',0,'鲁能','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'建邦',0,'建邦','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'华新',0,'华新','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'奥克斯',0,'奥克斯','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'新金城',0,'新金城','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'银城',0,'银城','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'星耀城',0,'星耀城','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'明发',0,'明发','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'旭辉',0,'旭辉','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'建华',0,'建华','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'河南昌建',0,'河南昌建','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'巨岸',0,'巨岸','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'厦门航空',0,'厦门航空','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'广宇',0,'广宇','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'数据港',0,'数据港','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'新希望',0,'新希望','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'滨投',0,'滨投','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'广汇',0,'广汇','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'浙江富成',0,'浙江富成','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'光明',0,'光明','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'城投',0,'城投','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'爱家',0,'爱家','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'华贸',0,'华贸','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'青剑湖',0,'青剑湖','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'江西普瑞',0,'江西普瑞','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'奥山',0,'奥山','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'江河',0,'江河','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'卓越',0,'卓越','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'绿地',0,'绿地','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'荣和',0,'荣和','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'纽宾凯',0,'纽宾凯','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'圣桦',0,'圣桦','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'美好装配',0,'美好装配','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'嘉华',0,'嘉华','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'南通三建',0,'南通三建','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'美的',0,'美的','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'碧桂园',0,'碧桂园','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'齐天',0,'齐天','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'万华',0,'万华','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'淮矿',0,'淮矿','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'和纵盛',0,'和纵盛','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'武汉光谷',0,'武汉光谷','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'元垄',0,'元垄','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'路劲',0,'路劲','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'首开',0,'首开','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'世纪海通',0,'世纪海通','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'融汇',0,'融汇','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'大悦城',0,'大悦城','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'南方都市',0,'南方都市','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'福建懋盛',0,'福建懋盛','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'嘉宏',0,'嘉宏','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'雅居乐',0,'雅居乐','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'国贸',0,'国贸','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'北科建',0,'北科建','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'江河',0,'江河','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'永锋',0,'永锋','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'和县建设局',0,'和县建设局','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'西安房屋',0,'西安房屋','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中驰',0,'中驰','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'正黄集团',0,'正黄集团','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'铭泰',0,'铭泰','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'民生置业',0,'民生置业','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'厦门安居',0,'厦门安居','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'东方经典',0,'东方经典','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'阳光100',0,'阳光100','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'山东地平',0,'山东地平','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'恒邦',0,'恒邦','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'菜鸟',0,'菜鸟','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'新高度',0,'新高度','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'蓝光',0,'蓝光','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'泰康',0,'泰康','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'新世界',0,'新世界','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'红星',0,'红星','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'龙光',0,'龙光','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'万豪',0,'万豪','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'葛洲坝',0,'葛洲坝','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'上坤',0,'上坤','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'正盛',0,'正盛','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'华润',0,'华润','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'新星宇',0,'新星宇','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中梁',0,'中梁','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'恒生',0,'恒生','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'阳光城',0,'阳光城','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'金地',0,'金地','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'保利',0,'保利','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'厦门住宅',0,'厦门住宅','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'弘阳',0,'弘阳','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'成都高新区',0,'成都高新区','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'建发',0,'建发','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'世茂',0,'世茂','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'协信',0,'协信','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中建三局',0,'中建三局','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中天',0,'中天','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'紫气通华',0,'紫气通华','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'鸿坤',0,'鸿坤','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'仁恒',0,'仁恒','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'华为',0,'华为','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'景瑞',0,'景瑞','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'象屿',0,'象屿','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'宝龙',0,'宝龙','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中建七局',0,'中建七局','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'蓝城',0,'蓝城','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'新鸥鹏',0,'新鸥鹏','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'万年基业',0,'万年基业','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'汇嘉物业',0,'汇嘉物业','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'联发',0,'联发','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'众安',0,'众安','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'信达',0,'信达','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'金科',0,'金科','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'三盛',0,'三盛','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'万达',0,'万达','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'天润',0,'天润','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'坤和',0,'坤和','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中建五局',0,'中建五局','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中航',0,'中航','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'恒大',0,'恒大','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'安徽置地',0,'安徽置地','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'光大',0,'光大','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'东方城',0,'东方城','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'星浩资本',0,'星浩资本','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'越秀',0,'越秀','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'合景泰富',0,'合景泰富','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'鲁商',0,'鲁商','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'富华',0,'富华','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'金茂',0,'金茂','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'首地',0,'首地','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'东原',0,'东原','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中铁置业',0,'中铁置业','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'合能',0,'合能','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'安邦',0,'安邦','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'长业',0,'长业','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'复城',0,'复城','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'北京东湖',0,'北京东湖','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'首创',0,'首创','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'龙湖',0,'龙湖','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'长征',0,'长征','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中建八局',0,'中建八局','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'万科',0,'万科','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'融信',0,'融信','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'佳兆业',0,'佳兆业','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中城建',0,'中城建','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中粮',0,'中粮','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'亚新',0,'亚新','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中庚',0,'中庚','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'金大地',0,'金大地','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'大家',0,'大家','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'当代',0,'当代','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'勤诚达',0,'勤诚达','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'首钢',0,'首钢','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中南',0,'中南','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'三木',0,'三木','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'西城',0,'西城','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中联',0,'中联','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中房',0,'中房','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'联投',0,'联投','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'保亿',0,'保亿','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'广州地铁',0,'广州地铁','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'华侨城',0,'华侨城','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'华夏',0,'华夏','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'金隅',0,'金隅','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'科鑫',0,'科鑫','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'保华',0,'保华','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'百荣',0,'百荣','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中铁建',0,'中铁建','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'新城控股',0,'新城控股','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'金城',0,'金城','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'新力',0,'新力','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'星桥腾飞',0,'星桥腾飞','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'商丘建设局',0,'商丘建设局','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'百悦',0,'百悦','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'明湖',0,'明湖','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'新兴际华',0,'新兴际华','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'中锐',0,'中锐','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')
insert into homsomdb..Trv_Customizations(ID,Ver,ModifyDate,ModifyBy,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom','homsom',GETDATE(),'其他',0,'其他','AD0CAA2B-8155-44C2-B03C-AA3B00AF1BEE')


/*
UC020758和铂医药（上海）有限责任公司，请帮忙导一份截止目前的全部差旅费用报告，谢谢。

报告需包含的内容：预定人，行程，日期，价格等
*/
select pasname,route,convert(varchar(10),datetime,120),begdate,totprice,reti
from Topway..tbcash 
where cmpcode='020758' 
order by datetime




/*
国内经济舱部分，请按附件内9-12月账单提供以下数据：
1.总违规次数，最低票价间相差金额，各类Reason Code次数和占比
2.部门违规概况分析：各部门违规次数，违规占比
3.员工预订行为分析：低价未采纳占比，退改签占比，违规率          空
4.员工违规情况分析（前10位）：姓名 部门  违规次数
5.低价提醒节支分析：月份（9--12），机票消费金额，机票张数，低价提醒次数，潜在可节省金额

PS:9月账单中，部分有最低价，无Reason Code的机票直接剔除
*/

--1.总违规次数，最低票价间相差金额，各类Reason Code次数和占比
select coupno 销售单号,tcode+ticketno 票号,c.price 销售单价,isnull(l.Price,'') 最低价,isnull(de.ReasonDescription,'') Reasoncode
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber and pasname=PassengerNames
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookings i1 on p.ItktBookingID=i1.ID
left join homsomDB..Trv_DeniedReason de on de.ItktBookingID=i1.ID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=i1.ID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%经济舱%'
and c.tickettype NOT IN ('改期费', '升舱费','改期升舱')
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274','AS002121652')
and c.price>isnull(l.Price,'')
and isnull(l.Price,'')>0

select tcode+ticketno,SUM(c.price)实际价销量,sum(l.Price) 最低价销量,isnull(de.ReasonDescription,'') Reasoncode,COUNT(1) ReasonCode次数
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber and pasname=PassengerNames
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookings i1 on p.ItktBookingID=i1.ID
left join homsomDB..Trv_DeniedReason de on de.ItktBookingID=i1.ID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=i1.ID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%经济舱%'
and c.tickettype NOT IN ('改期费', '升舱费','改期升舱')
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274','AS002121652')
and c.price>isnull(l.Price,'')
and isnull(l.Price,'')>0
group by isnull(de.ReasonDescription,''),tcode+ticketno

--2.部门违规概况分析：各部门违规次数，违规占比
select coupno,tcode+ticketno,c.Department,sum(c.price) 实际价销量,sum(l.Price) 最低价销量,isnull(de.ReasonDescription,'') Reasoncode,COUNT(1) ReasonCode次数
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber and pasname=PassengerNames
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookings i1 on p.ItktBookingID=i1.ID
left join homsomDB..Trv_DeniedReason de on de.ItktBookingID=i1.ID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=i1.ID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%经济舱%'
and c.tickettype NOT IN ('改期费', '升舱费','改期升舱')
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274','AS002121652')
and c.price>isnull(l.Price,'')
and isnull(l.Price,'')>0
group by isnull(de.ReasonDescription,''),c.Department,tcode+ticketno,coupno
order by c.Department

--员工违规情况分析（前10位）：姓名 部门  违规次数

select top 10 c.Department,pasname,sum(c.price) 实际价销量,sum(l.Price) 最低价销量,COUNT(1) ReasonCode次数
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber and pasname=PassengerNames
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookings i1 on p.ItktBookingID=i1.ID
left join homsomDB..Trv_DeniedReason de on de.ItktBookingID=i1.ID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=i1.ID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%经济舱%'
and c.tickettype NOT IN ('改期费', '升舱费','改期升舱')
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274','AS002121652')
and c.price>isnull(l.Price,'')
and isnull(l.Price,'')>0
group by c.Department,pasname
order by ReasonCode次数 desc

select  c.Department,pasname,sum(c.price) 实际价销量,sum(l.Price) 最低价销量,isnull(de.ReasonDescription,''),COUNT(1) ReasonCode次数
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber and pasname=PassengerNames
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookings i1 on p.ItktBookingID=i1.ID
left join homsomDB..Trv_DeniedReason de on de.ItktBookingID=i1.ID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=i1.ID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%经济舱%'
and c.tickettype NOT IN ('改期费', '升舱费','改期升舱')
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274','AS002121652')
and c.price>isnull(l.Price,'')
and isnull(l.Price,'')>0
and pasname in ('谢逸尘',
'张昊天',
'李建东',
'戚鹏飞',
'李毅',
'黄宬',
'马琳',
'王生',
'龚淼',
'唐斐界')
group by c.Department,pasname,isnull(de.ReasonDescription,'')
order by ReasonCode次数 desc

--低价提醒节支分析：月份（9--12），机票消费金额，机票张数，低价提醒次数，潜在可节省金额

select sum(c.price) 销量不含税,sum(isnull(l.Price,'')) 最低价销量
from Topway..tbcash c
left join ehomsom..tbInfCabincode i3 on i3.cabin=c.nclass and c.ride=i3.code2 and c.[datetime]>=i3.begdate and c.[datetime]<=i3.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or (c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) 
or (c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or (c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=RecordNumber and pasname=PassengerNames
left join homsomDB..Trv_PnrInfos p on p.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookings i1 on p.ItktBookingID=i1.ID
left join homsomDB..Trv_DeniedReason de on de.ItktBookingID=i1.ID
left join homsomDB..Trv_ItktBookingSegs i2 on i2.ItktBookingID=i1.ID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=i2.ID
where (ModifyBillNumber in('020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
and inf=0
and i3.cabintype like'%经济舱%'
and c.tickettype NOT IN ('改期费', '升舱费','改期升舱')
and c.coupno not in ('AS001894003','AS001892371','AS001892359','AS001892338','AS001891959','AS001907274','AS002121652')
and c.price>isnull(l.Price,'')



