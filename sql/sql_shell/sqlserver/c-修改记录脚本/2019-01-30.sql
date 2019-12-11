--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='需打印行程单'
where coupno='AS002234920'

--单位客户授信额度调整
SELECT SX_BaseCreditLine,SX_TomporaryCreditLine, SX_TotalCreditLine FROM Topway..AccountStatement
--update Topway..AccountStatement set SX_TotalCreditLine='80000'
WHERE CompanyCode='016278' and BillNumber='016278_20190101'

--修改UC号（机票）电子销售单号：AS002217693 出票日期：2019-1-19 销售价：3890元 原UC号：UC017735 现UC号：UC016888 其它信息不变
select cmpcode,OriginalBillNumber,ModifyBillNumber,pform,totprice,custid,datetime,* from Topway..tbcash 
--update Topway..tbcash set cmpcode='016888',OriginalBillNumber='016888_20190126',custid='D172032'
where coupno='AS002217693'

select custid AS 现会员编号,* from tbCusholderM where cmpid ='016888' 
select SettleMentManner AS 现结算方式,* from HM_SetCompanySettleMentManner where CmpId='016888' and Type=0 and Status=1
select OriginalBillNumber AS 现账单号,ModifyBillNumber AS 现账单号,cmpcode,custid,datetime,* from tbcash where coupno in ('AS002217693')
select HSLastPaymentDate,* from AccountStatement where CompanyCode='016888' order by BillNumber desc

--航司
SELECT top 10 * FROM ehomsom..tbInfAirCompany where code2='TO'
INSERT INTO ehomsom..tbInfAirCompany (ID,airname,sx1,sx,code2,http,ntype,modifyDate,enairname,sortNo) values (400,'法国贯空航空','贯空航空','贯空航空','TO','www.Transavia.com','1','2019-01-30','Transavia France','1')
insert INTO ehomsom..tbInfAirCompany (airname ,
          sx1 ,
          sx ,
          code2 ,
          http ,
          ntype ,
          modifyDate ,
          enairname ,
          IsDeleted ,
          sortNo ,
          phone1 ,
          phone2 ,
          introinf
        )
values('法国贯空航空','贯空航空','贯空航空','TO','www.Transavia.com','1','2019-01-30','Transavia France',NULL,'1',NULL,NULL,NULL)

--拆单14人
select Pasname,MobileList,Idno,CostCenter,pcs,Department,BirthPlace,* from tbFiveCoupInfosub 
--update tbFiveCoupInfosub set Idno='无,无,无,无,无,无,无,无,无,无,无,无,无,无',MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='14',Department='无,无,无,无,无,无,无,无,无,无,无,无,无,无',Pasname='乘客1,乘客2,乘客3,乘客4,乘客5,乘客6,乘客7,乘客8,乘客9,乘客10,乘客11,乘客12,乘客13,乘客14',BirthPlace='1982-01-03,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01'
where FkfiveNo in (select fiveno from tbFiveCoupInfo where CoupNo='AS002235342')

--差额调整
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='23500',profit='7814'
where coupno='AS002234254'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='4392',profit='191'
where coupno='AS002235066'

--请帮拉取1/29差旅顾问添加的常飞旅客名单

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
WHERE h.CreateDate>='2019-01-29' AND h.CreateDate<'2019-01-30' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT idnumber FROM Topway..Emppwd WHERE dep='运营部' AND idnumber NOT IN('00002','00003','0421'))
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
WHERE h.CreateDate>='2019-01-29' AND h.CreateDate<'2019-01-30' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT empname FROM Topway..Emppwd WHERE dep='运营部' AND empname NOT IN('homsom','恒顺旅行','运营培训测试'))

--打印权限
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus='0',PrDate='1900-01-01'
where TrvId='29519' and Id='226898'

--上海丰树
select CostCenter,priceinfo,* from Topway..tbcash where cmpcode='019358' and datetime>='2018-01-01' and datetime<'2019-01-01' and inf=1  and priceinfo>'0'

 --上海丰树2018数据
 select t.datetime as 出票日期,t.begdate as 起飞日期,t.coupno as 销售单号,t.pasname as 乘客姓名,t.route as 线路,t.ride+t.flightno as 航班号,t2.airname as 航空公司,t.tcode+t.ticketno as 票号,(case t.priceinfo when '0' then t.price else priceinfo end) as 全价,
(case t.priceinfo when '0' then '1' else t.price/t.priceinfo end) as 折扣率, t.price as 销售单价,t.tax as 税收,t.fuprice as 服务费,t.totprice as 销售价,t.reti as 退票单号,t.CostCenter as 成本中心,t1.rtprice as 退票费,
(Select c.totprice from Topway..tbcash c where c.coupno=t.coupno and c.ticketno=t.ticketno and (c.route like'%改期%' or c.tickettype like'%改期%') and c.cmpcode='019358' and c.ModifyBillNumber in('019358_20180101','019358_20180201','019358_20180301','019358_20180401','019358_20180501','019358_20180601','019358_20180701','019358_20180801','019358_20180901','019358_20181001','019358_20181101','019358_20181201')) as 改期升舱费
  ,t.nclass as 舱位代码
  from Topway..tbcash t
  left join Topway..tbReti t1 on t1.reno=t.reti
  left join ehomsom..tbInfAirCompany t2 on t2.code2=t.ride
 where t.ModifyBillNumber in('019358_20180101','019358_20180201','019358_20180301','019358_20180401','019358_20180501','019358_20180601','019358_20180701','019358_20180801','019358_20180901','019358_20181001','019358_20181101','019358_20181201') 
 and t.cmpcode='019358' and t.inf=1  
 order by t.ModifyBillNumber
 
 --成本中心
 select DISTINCT pasname,CostCenter from Topway..tbcash where cmpcode='019358' and CostCenter is not null and CostCenter<>'undefined'
 
 
 
 --插入票号
 select pasname,* from Topway..tbcash where coupno='AS002235779'
 update topway..tbcash set pasname='CHEN/WENXIN',tcode='781',ticketno='2318173779' where coupno in ('AS002235342') and pasname='乘客1'
update topway..tbcash set pasname='DAI/RUIQI',tcode='781',ticketno='2318173780' where coupno in ('AS002235342') and pasname='乘客2'
update topway..tbcash set pasname='FU/ZIRAN',tcode='781',ticketno='2318173781' where coupno in ('AS002235342') and pasname='乘客3'
update topway..tbcash set pasname='HU/HAIYING',tcode='781',ticketno='2318173782' where coupno in ('AS002235342') and pasname='乘客4'
update topway..tbcash set pasname='LAN/PU',tcode='781',ticketno='2318173783' where coupno in ('AS002235342') and pasname='乘客5'
update topway..tbcash set pasname='LI/HANBO',tcode='781',ticketno='2318173784' where coupno in ('AS002235342') and pasname='乘客6'
update topway..tbcash set pasname='SUN/YANXUN',tcode='781',ticketno='2318173785' where coupno in ('AS002235342') and pasname='乘客7'
update topway..tbcash set pasname='TANG/MIAOMIAO',tcode='781',ticketno='2318173786' where coupno in ('AS002235342') and pasname='乘客8'
update topway..tbcash set pasname='WANG/SHUNI',tcode='781',ticketno='2318173787' where coupno in ('AS002235342') and pasname='乘客9'
update topway..tbcash set pasname='WANG/YAOZHEN',tcode='781',ticketno='2318173788' where coupno in ('AS002235342') and pasname='乘客10'
update topway..tbcash set pasname='WENG/ZHENZHEN',tcode='781',ticketno='2318173789' where coupno in ('AS002235342') and pasname='乘客11'
update topway..tbcash set pasname='XU/JIAHUI',tcode='781',ticketno='2318173790' where coupno in ('AS002235342') and pasname='乘客12'
update topway..tbcash set pasname='ZHAO/RUIJING',tcode='781',ticketno='2318173791' where coupno in ('AS002235342') and pasname='乘客13'
update topway..tbcash set pasname='ZHAO/WENJUN',tcode='781',ticketno='2318173792' where coupno in ('AS002235342') and pasname='乘客14'
update topway..tbcash set pasname='WANG/SHUNI',tcode='781',ticketno='2318463163' where coupno in ('AS002235779') and pasname='HE/ZHENZHEN'

--结算单信息
select settleStatus,* from topway..tbSettlementApp
 --update topway..tbSettlementApp set settleStatus='3' 
 where id='108510'
select wstatus,settleno,* from topway..tbcash
--update topway..tbcash set wstatus='0',settleno='0' 
where settleno='108510'
select inf2,settleno,* from Topway..tbReti
--update topway..tbReti set inf2='0',settleno='0' 
where settleno='108510'
select Status,* from Topway..Tab_WF_Instance
--update topway..Tab_WF_Instance set Status='4' 
where BusinessID='108510'

delete from  topway..Tab_WF_Instance_Node where InstanceID in (select id from topway..Tab_WF_Instance where BusinessID='108510') and Status='0'

