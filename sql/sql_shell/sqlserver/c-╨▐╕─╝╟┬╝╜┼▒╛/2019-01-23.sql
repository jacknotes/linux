--锁定单位客户的旅游会务介绍人为homsom
--所有非HOMSOM不显示
select  * from Topway..HM_ThePreservationOfHumanInformation 
--update Topway..HM_ThePreservationOfHumanInformation set IsDisplay='0'
where Cmpid in('000126','006299','013184','013991','014412','015869','015918','016132','016266','016289','016358',																																																																																																																																																								
'016448','016457','016465','016490','016511','016531','016532','016564','016575','016618','016636','016676','016684','016795','016873','016876','016886','016973','017064','017111','017131',																																																																																																																																																								
'017186','017191','017275','017327','017329','017364','017426','017485','017505','017508','017509','017509','017525','017565','017583','017602','017643','017684','017706','017764','017800',																																																																																																																																																								
'017818','017828','017831','017831','017865','017882','017886','017907','017914','017931','017954','017977','017996','018004','018013','018080','018096','018125','018156','018156','018176',																																																																																																																																																								
'018193','018231','018266','018283','018294','018304','018309','018320','018343','018364','018383','018431','018515','018596','018615','018627','018642','018644','018662','018667','018667',																																																																																																																																																								
'018673','018675','018690','018700','018700','018707','018711','018714','018724','018741','018773','018798','018801','018808','018814','018931','018967','018986','019014','019041','019109',																																																																																																																																																								
'019140','019152','019166','019180','019188','019189',																																																																																																																																																								
'020201','019226','019256','019260','019299','019310','019334','019352','019371','019376','019378','019432','019453','019467','019467','019468','019471','019500','019504','019515','019517','019519','019523','019524','019526','019531','019535',																																																																																																																														
'020202',	'019547',	'019547',	'019558',	'019568',	'019569',	'019589',	'019607',	'019615',	'019629',	'019637',	'019653',	'019653',	'019660',	'019660',	'019661',	'019661',	'019669',	'019678',	'019689',	'019705',	'019705',	'019707',	'019708',	'019717',	'019732',	'019735',																																																																																																																														
'020205',	'019738',	'019748',	'019751',	'019751',	'019764',	'019793',	'019807',	'019811',	'019812',	'019820',	'019824',	'019830',	'019839',	'019845',	'019846',	'019882',	'019885',	'019888',	'019892',	'019895',	'019908',	'019908',	'019910',	'019912',																																																																																																																																
'020208',	'019918',	'019922',	'019923',	'019924',	'019928',	'019932',	'019937',	'019939',	'019940',	'019942',	'019944',	'019946',	'019949',	'019956',	'019970',	'019971',	'019985',	'019993',	'019995',	'020005',	'020012',	'020015',	'020016',	'020017',	'020027',																																																																																																																															
'020213',	'020029',	'020033',	'020043',	'020046',	'020056',	'020056',	'020066',	'020074',	'020082',	'020083',	'020087',	'020091',	'020096',	'020097',	'020109',	'020121',	'020122',	'020130',	'020139',	'020140',	'020142',	'020145',	'020149',	'020155',	'020161',	'020163',	'020183',																																																																																																																													
'020215',	'020201',	'020202',	'020205',	'020208',	'020213',	'020215',	'020216',	'020218',	'020222',	'020223',	'020226',	'020230',	'020240',	'020240',	'020252',	'020255',	'020255',	'020258',	'020259',	'020263',	'020264',	'020265',	'020268',	'020277',	'020281',	'020299',																																																																																																																														
'020216',	'020218',	'020222',	'020223',	'020226',	'020230',	'020240',	'020240',	'020252',	'020255',	'020255',	'020258',	'020259',	'020263',	'020264',	'020265',	'020268',	'020277',	'020281',	'020299',	'020300',	'020301',	'020307',	'020311',	'020313',	'020318',	'020318',																																																																																																																														
'020321',	'020322',	'020323',	'020325',	'020328',	'020331',	'020332',	'020335',	'020336',	'020339',	'020341',	'020343',	'020344',	'020347',	'020351',	'020352',	'020357',	'020358',	'020364',	'020364',	'020367',	'020370',	'020372',	'020373',	'020374',	'020374',	'020375',	'020381',	'020382',	'020386',	'020389',	'020390',	'020391',	'020392',	'020393',	'020398',	'020399',	'020400',	'020402',	'020404',	'020406',	'020409',	'020411',	'020412',	'020415',	'020417',	'020420',	'020424',	'020425',	'020429',	'020429',	'020435',	'020437',	'020439',	'020440',	'020443',	'020449',	'020452',	'020454',	'020456',	'020458',	'020465',	'020466',	'020469',	'020471',	'020473',	'020474',	'020479',	'020480',	'020484',	'020485',	'020486',	'020487',	'020489',	'020489',	'020492',	'020493',	'020494',	'020499',	'020501',	'020503',	'020509',	'020512',	'020515',	'020516',	'020520',	'020526',	'020527',	'020530',	'020534',	'020537',	'020539',	'020540',	'020549',	'020552',	'020553',	'020554',	'020557',	'020561',	'020562',	'020563',	'020571',	'020573',	'020574',	'020576',	'020577',	'020581',	'020584',	'020586',	'020587',	'020590',	'020593',	'020594',	'020595',	'020596',	'020599',	'020600',	'020601',	'020604',	'020605',	'020606',	'020607',	'020611',	'020612',	'020613',	'020615',	'020616',	'020619',	'020623',	'020624',	'020625',	'020627',	'020628',	'020632',	'020633',	'020642',	'020647',	'020648',	'020652',	'020653',	'020654',	'020658',	'020660',	'020661',	'020662',	'020665',	'020666',	'020668',	'020676',	'020678',	'020681',	'020682',	'020683'
)  and IsDisplay='1' and MaintainName='HOMSOM' and MaintainType='6' and IsDisplay='1'
order by CmpId

--查询重复字段
select CmpId from Topway..HM_ThePreservationOfHumanInformation 
where IsDisplay='1' and MaintainName='HOMSOM' and MaintainType='6' and IsDisplay='1' group by CmpId having count(*)>1

--HOMSOM状态显示
select  CmpId,IsDisplay,MaintainType,* from Topway..HM_ThePreservationOfHumanInformation
--UPDATE  Topway..HM_ThePreservationOfHumanInformation SET MaintainType='6',IsDisplay='1'
where Cmpid in('016575',	'016618',	'016684',	'017327',	'017684',	'017706',	'017882',	'017977',	'018004',	'018096',	'018283',	'018642',	'018814',	'018986',	'019189',	'019334',	'019432',
'020552',	'020553',	'020561',	'020571',	'020586',	'020587',	'020594',	'020599',	'020600',	'020601',	'020604',	'020606',	'020611',	'020613',	'020653',	'020665',	'020682',
'019500',	'019515',	'019707',	'019717',	'019812',	'019839',	'019946',	'019985',	'020027',	'020268',	'020351',	'020370',	'020439',	'020486',	'020534')  
and MaintainName='HOMSOM'

--会务预算单信息
SELECT Sales,OperName,ModifyName,introducer,* FROM Topway..tbConventionBudget 
--update Topway..tbConventionBudget set OperName='0481崔之阳',ModifyName='0481崔之阳',introducer='崔之阳-0481-运营部'
where ConventionId in('772','793','782','790')
--会务预算单信息
SELECT Sales,OperName,ModifyName,introducer,* FROM Topway..tbConventionBudget 
--update Topway..tbConventionBudget set OperName='0481崔之阳',ModifyName='0481崔之阳',introducer='崔之阳-0481-运营部'
where ConventionId in('902')

--（业务顾问专用）旅游结算单供应商来源
select GysSource,* from Topway..tbTrvJS 
--update Topway..tbTrvJS  set GysSource='百程国旅'
where TrvId='029391'


--单位类型、结算方式、账单开始日期、新增月、注册月

--注册日期
select  indate,indateA,* from Topway..tbcompanym 
--update Topway..tbcompanym  set indate='2019-01-23',indateA='2019-01-23'
where cmpid='018061'
select Type,RegisterMonth,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies set Type='A',RegisterMonth='01  23 2019 11:05AM'
where Cmpid='018061'
--结算账期
select PstartDate,Status,* from Topway..HM_CompanyAccountInfo 
--update Topway..HM_CompanyAccountInfo set PstartDate='2019-01-01'
where CmpId='018061' and Id='6827'

select PendDate,Status,* from Topway..HM_CompanyAccountInfo 
--update Topway..HM_CompanyAccountInfo set PendDate='2018-12-31',Status='-1'
where CmpId='018061' and Id='5308'

SELECT Status,EndDate,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set Status='-1',EndDate='2018-12-31 23:59:59.000'
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '018061') 
and ID in('E873B7ED-6776-465E-8698-A43E00BA6A02','A9990830-BCA4-49B6-9C70-A43E00BA6A2C')

SELECT Status,StartDate,* FROM homsomdb..Trv_UCSettleMentTypes 
--update homsomdb..Trv_UCSettleMentTypes set Status='1',StartDate='2019-01-01'
WHERE UnitCompanyID IN (SELECT ID FROM homsomdb..Trv_UnitCompanies WHERE Cmpid = '018061') 
and ID in('EC6EC427-46BF-49E5-A2CB-A9DE00B2B2EA','84CCFF62-C8B9-42EF-AC6D-A9DE00B2B310')

--最新结算方式
select SEndDate,Status,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SEndDate='2018-12-31',Status='-1'
where CmpId='018061' and Id  in('9936','9935')

select SStartDate,Status,* from Topway..HM_SetCompanySettleMentManner 
--update Topway..HM_SetCompanySettleMentManner set SStartDate='2019-01-01',Status='1'
where CmpId='018061' and Id  in('18059','18058')

--修改新账单额度
select SX_BaseCreditLine,SX_TomporaryCreditLine,SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SX_BaseCreditLine='60000',SX_TomporaryCreditLine='60000',SX_TotalCreditLine='60000'
where CompanyCode='018061' and BillNumber='018061_20190101'

--销售单号 PTW075468未结算 删除以上销售单号 金额错误
select status,* from Topway..tbHtlcoupYf 
--update  Topway..tbHtlcoupYf set status='-2'
where CoupNo='PTW075468'

--康宝莱匹配数据
select reti, coupno as 原销售单号,price as 原销售价,tax as 税收,fuprice from Topway..tbcash 
where reti in('0425198','0425089','0425199','0425394','0425201','0425231','0424848','0424783','0424949','0426596','0424815','0425197','0424814','0425588','0425200','0424849','0426070')

--销售单匹配舱位
--新
SELECT c.coupno,(SELECT TOP 1 i.cabintype 
	FROM ehomsom..tbInfCabincode i 
	WHERE	c.ride=i.code2 AND c.nclass=i.cabin 
										AND i.begdate<=c.begdate AND i.enddate>=c.begdate
	ORDER BY id DESC
	) AS cabinType
fROM Topway..tbcash  c
where c.coupno in ('AS002165900',	'AS002161391',	'AS002165336',	'AS002159334',	'AS001908134',	'AS001910752',	'AS001952463',	'AS001876445',	'AS001876372',	'AS001876449',	'AS002167185',	'AS002157707',	'AS002163959',	'AS002163957',	'AS002157378',	'AS002167424',	'AS002165021')

--订单号（国内）
SELECT t.TravelID,coupno FROM tbcash c
LEFT JOIN homsomDB..Trv_DomesticTicketRecord d ON c.coupno=d.RecordNumber
LEFT JOIN homsomDB..Trv_PnrInfos p ON d.PnrInfoID=p.ID
LEFT JOIN homsomDB..Trv_ItktBookings i ON p.ItktBookingID=i.ID
LEFT JOIN homsomDB..Trv_Travels t ON i.TravelID=t.ID
where coupno in ('AS002165900',	'AS002161391',	'AS002165336',	'AS002159334',	'AS001908134',	'AS001910752',	'AS001952463',	'AS001876445',	'AS001876372',	'AS001876449',	'AS002167185',	'AS002157707',	'AS002163959',	'AS002163957',	'AS002157378',	'AS002167424',	'AS002165021')

--财务到账状态

select state,AuditARop,AuditARopid,* from topway..FinanceERP_ClientBankRealIncomeDetail 
--update topway..FinanceERP_ClientBankRealIncomeDetail set state='5'
where money='50000' and id='46485155-1AA7-475A-B27F-B87E7C19E6CE' 
--删除到账审核人

select Payee,* 
--update topway..AccountStatementItem set Payee=''
from topway..AccountStatementItem where PKeyBill in 
(select PKey from topway..AccountStatement where CompanyCode='020548' and BillNumber='020548_20190101')
and ReceivedAmount='50000'

--（产品部专用）机票供应商来源（国内
select t_source,* from Topway ..tbcash 
--update Topway ..tbcash set t_source='HSBSPETI'
where coupno='AS002216601'
select t_source,* from Topway ..tbcash 
--update Topway ..tbcash set t_source='HS易商伊藤忠D'
where coupno='AS002200937'
select t_source,* from Topway ..tbcash 
--update Topway ..tbcash set t_source='HSBSPETD'
where coupno='AS002215812'

--机票业务顾问信息

select SpareTC,sales,* from Topway..tbcash 
--update Topway..tbcash set SpareTC='徐薇'
where coupno='AS001408121'


--修改企业差旅顾问和运营经理
select t.Cmpid as 单位编号,Name as 单位名称,t1.TcName as 差旅顾问,t2.MaintainName as 运营经理
from homsomDB..Trv_UnitCompanies t
left join Topway..HM_AgreementCompanyTC t1 on t1.Cmpid=t.Cmpid and t1.TcName='张超'
left join Topway..HM_ThePreservationOfHumanInformation t2 on t2.CmpId=t.Cmpid and t2.MaintainName='邵雪梅'
where t1.TcName='张超' and t2.MaintainName='邵雪梅' and t2.IsDisplay='1' and t1.isDisplay='0'
and t.CooperativeStatus in('1','2','3')
