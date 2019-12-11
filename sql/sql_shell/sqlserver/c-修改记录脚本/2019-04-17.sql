--提前出票天数数据
SELECT DAYSFLAG,SUM(totprice) 合计销量,SUM(price) 不含税销量,COUNT(1) 合计张数,SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) 经济舱平均折扣率   FROM (
SELECT --T1.coupno,
CASE WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 0 AND 2 THEN 1
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 3 AND 4 THEN 2
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 5 AND 6 THEN 3
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 7 AND 8 THEN 4
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 9 AND 10 THEN 5
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 11 AND 12 THEN 6
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) BETWEEN 13 AND 14 THEN 7
	WHEN DATEDIFF(DD,T1.[datetime],T1.begdate) >14 THEN 8 END DAYSFLAG,
totprice,price,priceinfo 
FROM Topway..tbcash T1 WITH (NOLOCK)
left join homsomDB..Trv_PnrInfos pn on pn.PNR=T1.recno
left join homsomDB..Trv_ItktBookingSegs it on it.ItktBookingID=pn.ItktBookingID and it.Flight=T1.ride+t1.flightno
WHERE T1.cmpcode ='020459'
and it.FlightClass like'%经济%'
AND T1.inf=0
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
--AND (@CUSTID ='' OR @CUSTID IS NULL OR @CUSTID=T1.custid)
and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
) T
GROUP BY DAYSFLAG

--修改销售单信息
select price,totprice,totsprice,profit,owe,tax,stax,sprice1,* 
from Topway..tbcash 
--update Topway..tbcash set price='54150',totprice='55888',totsprice='54508',profit='1380',owe='55888',tax='1738',sprice1='52770'
where coupno='AS002402478'

--航线数据
SELECT  T1.[route] 行程,avg(price) 平均销售价,SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) 经济舱平均折扣率
FROM Topway..tbcash T1 WITH (NOLOCK)
left join homsomDB..Trv_PnrInfos pn on pn.PNR=T1.recno
left join homsomDB..Trv_ItktBookingSegs it on it.ItktBookingID=pn.ItktBookingID and it.Flight=T1.ride+T1.flightno
WHERE --T1.cmpcode = '020459'
it.FlightClass like'%经济%'
AND T1.inf=0
AND T1.tickettype NOT IN ('改期费', '升舱费','改期升舱')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
and datetime>='2018-07-01'
and datetime<'2019-01-01'
and T1.[route] in('北京首都-上海虹桥','上海虹桥-北京首都','上海虹桥-成都','太原-上海虹桥','成都-上海虹桥')
--and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.[route] 
select top 10 * from homsomDB..Trv_ItktBookingSegs

--删除错误UC号结算方式
--select * from Topway..HM_SetCompanySettleMentManner where CmpId='019315' and CreateBy='0175'
select * from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner  set Status=-1
where CmpId='019315' and Id in('19541','19540')

select * from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set Status=1,SEndDate='2099-01-01'
where CmpId='019315' and Id in('19301','19300')

SELECT Status,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set Status=-1
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '019315') and Status=1

SELECT Status,EndDate,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set Status=1,EndDate='2099-01-01'
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '019315') and CreateBy='0175' and Status=-1

--UC017735修改常旅客姓名
--select Name from homsomDB..Trv_Human h left join homsomDB..Trv_UnitPersons un on un.ID=h.ID where un.CompanyID=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735') and IsDisplay=1 and Mobile='13601997531'
update homsomDB..Trv_Human set Name='阿部剛己' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='13601997531'
update homsomDB..Trv_Human set Name='张斯维' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='13761483477'
update homsomDB..Trv_Human set Name='何雅洁' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='15721319878'
update homsomDB..Trv_Human set Name='李晴怡' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='15802132682'
update homsomDB..Trv_Human set Name='荒木潤也' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='13681637375'
update homsomDB..Trv_Human set Name='木田共彦' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='15900963250'
update homsomDB..Trv_Human set Name='汪丹' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='13761037364'
update homsomDB..Trv_Human set Name='古賀孝彦' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='13918300694'
update homsomDB..Trv_Human set Name='青木馨' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='13810094276'
update homsomDB..Trv_Human set Name='池之上裕視' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='15901937363'
update homsomDB..Trv_Human set Name='北野英輔' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='13524514885'
update homsomDB..Trv_Human set Name='傅晶' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='13916525876'
update homsomDB..Trv_Human set Name='朱婧' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='13916245736'
update homsomDB..Trv_Human set Name='陈绿艳' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='15221279672'
update homsomDB..Trv_Human set Name='严丹莉' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='15900714060'
update homsomDB..Trv_Human set Name='孔令娟' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='017735')) and IsDisplay=1 and Mobile='15221389046'


--UC016888修改常旅客姓名
update homsomDB..Trv_Human set Name='吉田威史' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13661551302'
update homsomDB..Trv_Human set Name='孙宏达' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13801981306'
update homsomDB..Trv_Human set Name='浜辺祐一郎' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13918914249'
update homsomDB..Trv_Human set Name='张良' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='18321502402'
update homsomDB..Trv_Human set Name='陆行素' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13918916934'
update homsomDB..Trv_Human set Name='金海霞' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='15221932412'
update homsomDB..Trv_Human set Name='潘文忠' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='17802143415'
update homsomDB..Trv_Human set Name='蒋胤杰' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='17802183626'
update homsomDB..Trv_Human set Name='乔昊宸' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='18221567284'
update homsomDB..Trv_Human set Name='沈瑶' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13611801940'
update homsomDB..Trv_Human set Name='张婉冰' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13501867140'
update homsomDB..Trv_Human set Name='羽生英一郎' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13761304649'
update homsomDB..Trv_Human set Name='包佳' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13817366985'
update homsomDB..Trv_Human set Name='吴从悦' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13817861284'
update homsomDB..Trv_Human set Name='卢天兵' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='15021860940'
update homsomDB..Trv_Human set Name='邹捷' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='15021332316'
update homsomDB..Trv_Human set Name='张庆' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='14782912750'
update homsomDB..Trv_Human set Name='张辰' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='15021404267'
update homsomDB..Trv_Human set Name='许翔' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13758237610'
update homsomDB..Trv_Human set Name='周志浩' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13901737934'
update homsomDB..Trv_Human set Name='杜建庭' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='15201913950'
update homsomDB..Trv_Human set Name='施浩' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='14782976093'
update homsomDB..Trv_Human set Name='乐文刚' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13801777207'
update homsomDB..Trv_Human set Name='永井貴俊' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='18721893021'
update homsomDB..Trv_Human set Name='林挺' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13916039392'
update homsomDB..Trv_Human set Name='沈蔚' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13764316679'
update homsomDB..Trv_Human set Name='周光' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='14781945328'
update homsomDB..Trv_Human set Name='徐小广' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='18321200421'
update homsomDB..Trv_Human set Name='刘伟' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13817836592'
update homsomDB..Trv_Human set Name='陈晓波' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='15800337557'
update homsomDB..Trv_Human set Name='柴田崇' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13661953070'
update homsomDB..Trv_Human set Name='余小平' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13611695047'
update homsomDB..Trv_Human set Name='戈国辉' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13611923260'
update homsomDB..Trv_Human set Name='齐海' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13509402774'
update homsomDB..Trv_Human set Name='郑莉萍' where ID in(Select ID from homsomDB..Trv_UnitPersons where companyid=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='016888')) and IsDisplay=1 and Mobile='13512371508'


--账单撤销
select HotelSubmitStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set HotelSubmitStatus=2
where BillNumber='017173_20190301'

--火车票销售价信息
select TotPrice,TotSprice,TotUnitprice,* from Topway..tbTrainTicketInfo 
--update Topway..tbTrainTicketInfo  set TotPrice=45,TotSprice=45,TotUnitprice=45
where CoupNo='RS000022315'
select RealPrice,SettlePrice,* from Topway..tbTrainUser 
--update Topway..tbTrainUser set RealPrice=45,SettlePrice=45
where TrainTicketNo=(select id from Topway..tbTrainTicketInfo where CoupNo='RS000022315')

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='019974_20190301'

--UC018080 机票2018年数据
--国内
select count(id) 国内机票张数,sum(totprice-fuprice) 国内机票总费用不含服务费,SUM(fuprice) 国内机票服务费 from Topway..tbcash 
where cmpcode='018080'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=0
and (tickettype not like'%改期%' 
or tickettype not like'%升舱%')

--国际
select count(id) 国际机票张数,sum(totprice-fuprice) 国际机票总费用不含服务费,SUM(fuprice) 国际机票服务费 from Topway..tbcash 
where cmpcode='018080'
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and (tickettype not like'%改期%' 
and tickettype not like'%升舱%')
and (route not like '%改期%' or route not like '%升舱%')


--UC019372删除员工
select Name,* from homsomDB..Trv_Human 
--update homsomDB..Trv_Human  set IsDisplay=0
where IsDisplay=1 
and ID in(Select ID from homsomDB..Trv_UnitPersons 
where companyid=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='019372'))
and Name not in('张一鸣','陈春','于菲','刁品蓉')

select * from Topway..tbCusholderM 
--update Topway..tbCusholderM set EmployeeStatus=0
where cmpid='019372'
and custname not in('张一鸣','陈春','于菲','刁品蓉')


--修改结算方式
--select * from Topway..HM_CompanyAccountInfo where CmpId='017227'
--select * from Topway..AccountStatement where CompanyCode='017227' order by BillNumber desc
select SEndDate,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set Status=-1,SEndDate='2019-03-31'
where CmpId='017227' 
and Status=1
and Id in ('4282','2125')

select SStartDate,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SStartDate='2019-04-01'
where CmpId='017227' 
and Status=1
and SettleMentManner='月结(招行)'

select EndDate,* from homsomDB..Trv_UCSettleMentTypes 
--update homsomDB..Trv_UCSettleMentTypes  set Status=-1,EndDate='2019-04-01'
where UnitCompanyID=(Select ID  from homsomDB..Trv_UnitCompanies where Cmpid='017227') 
and Status=1
and CreateBy='homsom'

select StartDate,* from homsomDB..Trv_UCSettleMentTypes 
--update homsomDB..Trv_UCSettleMentTypes  set StartDate='2019-04-01'
where UnitCompanyID=(Select ID  from homsomDB..Trv_UnitCompanies where Cmpid='017227') 
and Status=1
and CreateBy='0538'


--UC019372修改注册月为2019年4月17日
select indate,* from Topway..tbCompanyM 
--update Topway..tbCompanyM  set indate='2019-04-17'
where cmpid='019372'

select RegisterMonth,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set RegisterMonth='04 17 2019  2:51PM'
where Cmpid='019372'

--重开打印
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='29695'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=4217,profit=423
where coupno='AS002402757'

--UC017227修改注册月为2019年4月17日
select indate,* from Topway..tbCompanyM 
--update Topway..tbCompanyM  set indate='2019-04-17'
where cmpid='017227'

select RegisterMonth,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set RegisterMonth='04 17 2019  2:51PM'
where Cmpid='017227'

--删除单位员工
select Name,* from homsomDB..Trv_Human 
--update homsomDB..Trv_Human  set IsDisplay=0
where IsDisplay=1 
and ID in(Select ID from homsomDB..Trv_UnitPersons 
where companyid=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='017227'))
and Name not in('张静')


--修改供应商来源
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS易商月星D'
where coupno='AS002393232'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS易商致同D'
where coupno='AS002393226'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS易商智睿D'
where coupno='AS002399729'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS易商智睿D'
where coupno='AS002399734'

 --UC019692快扣2019年1月至3月国内机票 利润率 
 
 select SUM(totprice) 销量,sum(profit-fuprice) 利润不含服务费,sum(profit-fuprice)/SUM(totprice) 利润率 
 from Topway..tbcash 
 where cmpcode='019692'
 and datetime>='2019-03-01'
 and datetime<'2019-04-01'
 and inf=0
 and tickettype='电子票'
 and reti=''
 
 --火车票销售价信息
 select TotFuprice,TotPrice,* from Topway..tbTrainTicketInfo 
 --update Topway..tbTrainTicketInfo set TotFuprice=20,TotPrice=99.5
 where CoupNo in ('RS000021689','RS000021690','RS000021691','RS000021692','RS000021693')
 
 select Fuprice,* from Topway..tbTrainUser 
 --update Topway..tbTrainUser set Fuprice=20
 where TrainTicketNo in(Select ID from Topway..tbTrainTicketInfo 
 where CoupNo in('RS000021689','RS000021690','RS000021691','RS000021692','RS000021693'))
 
 select TotFuprice,TotPrice,* from Topway..tbTrainTicketInfo 
 --update Topway..tbTrainTicketInfo set TotFuprice=20,TotPrice=99.5
 where CoupNo in ('RS000021694','RS000021695','RS000021696','RS000021697','RS000021698',
 'RS000021699','RS000021700','RS000021701')
 
 select Fuprice,* from Topway..tbTrainUser 
 --update Topway..tbTrainUser set Fuprice=20
 where TrainTicketNo in(Select ID from Topway..tbTrainTicketInfo 
 where CoupNo  in('RS000021694','RS000021695','RS000021696','RS000021697','RS000021698',
 'RS000021699','RS000021700','RS000021701'))