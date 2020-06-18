--UC019707删除下回访记录
select * from homsomDB..Trv_Memos 
--update homsomDB..Trv_Memos  set UnitCompanyID=null
where UnitCompanyID=(Select id  from homsomDB..Trv_UnitCompanies where Cmpid='019707')
and ID in ('9193BBB6-927A-4EA1-9C54-AA5B010DBFF8','75D07550-8E2D-40D7-AC66-AA5B010DD61B')

--补票号
--select pasname,* from Topway..tbcash where coupno='AS002507409'
update Topway..tbcash set pasname='SUN/XUANHUA',tcode='781',ticketno='2400584815' where coupno ='AS002507409' and pasname='乘客0'
update Topway..tbcash set pasname='TAO/LAN',tcode='781',ticketno='2400584816' where coupno ='AS002507409' and pasname='乘客1'
update Topway..tbcash set pasname='WANG/DEZHEN',tcode='781',ticketno='2400584817' where coupno ='AS002507409' and pasname='乘客2'
update Topway..tbcash set pasname='XU/LENIAN',tcode='781',ticketno='2400584818' where coupno ='AS002507409' and pasname='乘客3'
update Topway..tbcash set pasname='ZHANG/XIUJUAN',tcode='781',ticketno='2400584819' where coupno ='AS002507409' and pasname='乘客4'
update Topway..tbcash set pasname='ZHAO/SHUIXIAN',tcode='781',ticketno='2400584820' where coupno ='AS002507409' and pasname='乘客5'
update Topway..tbcash set pasname='ZHONG/YULAN',tcode='781',ticketno='2400584821' where coupno ='AS002507409' and pasname='乘客6'
update Topway..tbcash set pasname='ZHOU/MINGZHEN',tcode='781',ticketno='2400584822' where coupno ='AS002507409' and pasname='乘客7'
update Topway..tbcash set pasname='ZHOU/PEIFANG',tcode='781',ticketno='2400584823' where coupno ='AS002507409' and pasname='乘客8'
update Topway..tbcash set pasname='CAI/PEIMIN',tcode='781',ticketno='2400584824' where coupno ='AS002507409' and pasname='乘客9'
update Topway..tbcash set pasname='CHAI/JUE',tcode='781',ticketno='2400584825' where coupno ='AS002507409' and pasname='乘客10'
update Topway..tbcash set pasname='CHEN/YINYUE',tcode='781',ticketno='2400584826' where coupno ='AS002507409' and pasname='乘客11'
update Topway..tbcash set pasname='DONG/LAN',tcode='781',ticketno='2400584827' where coupno ='AS002507409' and pasname='乘客12'
update Topway..tbcash set pasname='FU/MINZHEN',tcode='781',ticketno='2400584828' where coupno ='AS002507409' and pasname='乘客13'
update Topway..tbcash set pasname='HE/PING',tcode='781',ticketno='2400584829' where coupno ='AS002507409' and pasname='乘客14'
update Topway..tbcash set pasname='LIAO/XIANGJIE',tcode='781',ticketno='2400584830' where coupno ='AS002507409' and pasname='乘客15'
update Topway..tbcash set pasname='LU/PUMING',tcode='781',ticketno='2400584831' where coupno ='AS002507409' and pasname='乘客16'
update Topway..tbcash set pasname='MA/YING',tcode='781',ticketno='2400584832' where coupno ='AS002507409' and pasname='乘客17'
update Topway..tbcash set pasname='NI/JIN',tcode='781',ticketno='2400584833' where coupno ='AS002507409' and pasname='乘客18'

/*
单位编号：UC020778
出票日期：2019.1.1-2019.5.27
客票类型：国内+国际
*/
select coupno,pasname,idno 
from Topway..tbcash where cmpcode='020778'
and datetime>='2019-01-01'
and datetime<'2019-05-28'

/*
   UC018734   三井住友银行（中国）有限公司
     该公司正在做续签，需我司提供2018.5-2019.4的机票、火车票、酒店明细
*/
--机票
select coupno 销售单号,convert(varchar(10),datetime,120)出票日期,begdate 起飞日期,pasname 乘机人,route 行程,price 销售单价,
tax 税收,totprice 销售价,isnull(CostCenter,'') 成本中心,ride+flightno 航班号,nclass 舱位,tickettype 类型,reti 退票单号
from Topway..tbcash 
where cmpcode='018734'
and datetime>='2018-05-01'
and datetime<'2019-05-01'
order by datetime

--火车票
select CoupNo 销售单号,Name 乘客,PrintDate 出票时间,OutBegdate 出发时间,OutTrainNo 车次,OutStroke 行程,OutGrade 座次,TotUnitprice 原价,TotFuprice 服务费,TotPrintPrice 打印费,TotPrice 销售价
from Topway..tbTrainTicketInfo t
left join Topway..tbTrainUser t2 on t.ID=t2.TrainTicketNo
where CmpId='018734'
and PrintDate>='2018-05-01'
and PrintDate<'2019-05-01'
order by PrintDate

/*
UC020459康宝莱（上海）管理有限公司
5月  所有供应商来源为：嘉惠BSP， 这部分的资金成本*/
select coupno 销售单号,convert(varchar(10),datetime,120) 出票日期,t_source 供应商来源,Mcost 资金成本
from Topway..tbcash 
where cmpcode='020459'
and datetime>='2019-05-01'
 and t_source like '%嘉惠%'
 order by 出票日期
 
--UC019707删除常旅客
select * from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (Select ID from homsomDB..Trv_UnitPersons 
where companyid=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='019707'))
and IsDisplay=1
and Name not in ('周颖','徐蓓莉','高睿','吕月华')

select EmployeeStatus,* from Topway..tbCusholderM 
--update Topway..tbCusholderM set EmployeeStatus=0
where cmpid='019707' 
and joindate<'2019-05-29' 
and custname not in ('周颖','徐蓓莉','高睿','吕月华')

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='携程官网分销联盟'
where CoupNo='PTW082698'

--销售单改成未付
select bpay,status,opernum,oper2,oth2,totprice,dzhxDate,owe,cowe,coweinf,vpay,vpayinf,*  from Topway..tbcash 
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
where coupno='AS002439241'

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='员工垫付（王贞中行卡）'
where coupno='PTW083473'

--酒店销售单改成国内
select dinf,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set dinf=0
where CoupNo='PTW083463'

--请帮忙拉取高参名下的单位客户开通“特殊票价”+“行程单”的公司UC号和名称
--国内
select Cmpid,u.Name,s.Name 
from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_TktUnitCompanies_TktTCs t on t.TktUnitCompanyID=u.ID
left join homsomDB..SSO_Users s on s.ID=t.TktTCID
where CertificateD=1
and IsSepPrice=1
and s.Name='高参'
and CooperativeStatus in ('1','2','3')

--国际
select Cmpid,u.Name,s.Name 
from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_TktUnitCompanies_TktTCs t on t.TktUnitCompanyID=u.ID
left join homsomDB..SSO_Users s on s.ID=t.TktTCID
where CertificateI=1
and IsIntlSpecialPrice=1
and s.Name='高参'
and CooperativeStatus in ('1','2','3')

--020075需要酒店的数据分析 预订日期：2018-06-01-2019-05-29，只要订单状态是已确认的 
SELECT case when dinf=0 then '国内' when dinf=1 then '国际' else '' end 类型,CoupNo 销售单号,prdate 预订日期
,hotel 酒店名称,cmpid 编号,pasname 客人姓名,beg_date 入住日期,end_date 离店日期,nights*pcs 间夜,price 销售总价,fwprice 服务费,price+fwprice-yhprice 应收金额,
sprice 结算总价,totprofit 利润,case when status=1 then '已确认' else '' end 订单状态,
case when status2=1 then '已结算' when status2=2 then '申请' when status2=0 then '未结算' else '' end 收款状态,
case when pstatus=0 then '未打印' when pstatus=1 then '已打印' when pstatus=2 then'申请打印' else '' end 打印状态,
Sales 业务顾问
FROM Topway..tbHtlcoupYf 
WHERE cmpid='020075'
AND prdate>='2018-06-01'
and status=1


--UC016682删除常旅客
select * from homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (Select ID from homsomDB..Trv_UnitPersons 
where companyid=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='016682'))
and IsDisplay=1
and ID not in ('6FED6291-5268-4A5B-8541-AA5C00FA0B74','C2921360-8BC8-4535-8B7D-1C1AFF4D3311')


--UC016682修改注册月2019.05.29
select  indate,* from Topway..tbCompanyM 
--update Topway..tbCompanyM  set indate='2019-05-29'
where cmpid='016682'

select RegisterMonth,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies  set RegisterMonth='05  29 2019 12:00AM'
where Cmpid='016682'

--UC016682上海中隈商事贸易有限公司 要改旅游改差旅
select CustomerType,* from Topway..tbCompanyM 
--update Topway..tbCompanyM set CustomerType='A'
where cmpid='016682'

SELECT Type,* FROM homsomDB..Trv_UnitCompanies 
--UPDATE homsomDB..Trv_UnitCompanies SET Type='A'
WHERE Cmpid='016682'