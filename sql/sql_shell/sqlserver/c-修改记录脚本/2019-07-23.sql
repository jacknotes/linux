--申请费报表 序号	申请费来源	出票日期	销售单号	申请费	退票日期	退票单号	扣申请费	HS应收申请费	销售利润	差旅顾问
declare @startdatetime varchar(10)
declare @enddatetime varchar(10)
declare @startExamineDate varchar(10)
declare @endExamineDate varchar(10)
declare @inf varchar(10)
declare @feiyonginfo varchar(10)
declare @tickettype varchar(10)

if OBJECT_ID('tempdb..#feiyong') is not null drop table #feiyong
create table #feiyong (
feiyonginfo varchar(20),
datetime varchar(10),
coupno varchar(20),
feiyong decimal(18,3),
ExamineDate varchar(20),
reno varchar(10),
sfeiyong decimal(18,3),
HStotprice decimal(18,3),
profit decimal(18,3),
sales varchar(10))
insert into #feiyong (feiyonginfo,datetime,coupno,feiyong,ExamineDate,reno,sfeiyong,HStotprice,profit,sales)
select feiyonginfo 申请费来源,t.datetime 出票日期,t.coupno 销售单号,t.feiyong 申请费,convert(varchar(19),ExamineDate,120) 退票日期,reno 退票单号,t.sfeiyong 扣申请费,
t.feiyong-t.sfeiyong HS应收申请费,t.profit 销售利润,sales 差旅顾问
from Topway..tbReti t
left join Topway..tbcash c on c.reti=t.reno
where t.datetime>=@startdatetime
and t.datetime<=@enddatetime
and ExamineDate>=@startExamineDate
and ExamineDate<=@endExamineDate
and t.inf=@inf
and feiyonginfo in(@feiyonginfo)
and CONVERT(varchar(4),tickettype) in(@tickettype)

select * from #feiyong

--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno='AS002604873'

--火车票供应商来源/配送信息
select Ptype,* from Topway..tbTrainTicketInfo 
--update Topway..tbTrainTicketInfo  set Ptype=4
where CoupNo='RS000027394'

--修改出票日期
select datetime,* from Topway..tbcash 
--update Topway..tbcash  set datetime='2019-07-22'
where coupno='AS002656928'

--航线各航司占比  航空公司	结算价	税收	结算总计	结算比例	销售利润	利润比例	张数	张数比例
select ride,totprice,tax,
from Topway..tbcash 
where 


--匹配乘机人员工编号
select EmployeeNo, * from homsomDB..Trv_UnitPersons 
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies
where Cmpid='020810')

select top 100  * from homsomDB..Trv_Passengers
select top 100* from homsomDB..Trv_DomesticTicketRecord

select tcode+ticketno,cr.CredentialNo from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on c.coupno=d.RecordNumber
left join homsomDB..Trv_ItktBookingSegments_PnrInfos it on it.PnrInfoID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs i on i.ID=it.ItktBookingSegID 
left join homsomDB..Trv_Passengers p on p.ItktBookingID=i.ItktBookingID
left join homsomDB..Trv_UnitPersons un on un.ID=p.UPID
left join homsomDB..Trv_Human h on h.ID=p.UPID
left join homsomDB..Trv_Credentials cr on cr.HumanID=p.UPID
where cr.Type=1
and ticketno in('5515714985',
'5515717036',
'5060789326',
'5060790357',
'5061590018',
'5061590367',
'5061590780',
'5061590992',
'5061591587',
'5061591588',
'5061591707',
'5061591977',
'5061592031',
'5062984274',
'5062984732',
'5063304496',
'5063304729',
'5063305310',
'5063305571',
'5063305766',
'9423071884',
'9423071882',
'9423074027',
'9424012746',
'9424012747',
'9424012918',
'9424012917',
'9425690610',
'9425690611',
'9425692558',
'9426571533',
'9426571601',
'9427139328',
'9427139836',
'9427139870',
'9427139871',
'9427139868',
'9427139869',
'9427139974',
'9427140244',
'9427140245',
'9427140529',
'9427140530',
'9427141074',
'9427142362',
'9427142361',
'9427142450',
'9427142777',
'4535920010')


select * from homsomDB..Trv_Human where Mobile='15050597739'

select tcode+ticketno,pasname,h.Name,EmployeeNo from Topway..tbcash c
left join homsomDB..Trv_Credentials cr on cr.CredentialNo=c.idno
left join homsomDB..Trv_UnitPersons u on u.ID=cr.HumanID
left join homsomDB..Trv_Human h on h.ID=cr.HumanID
where ticketno in('5527351764',
'5527366736',
'5527394734',
'5527401984',
'9579524490',
'5527429807',
'5527442590',
'5527461893',
'5527548342',
'2319857222',
'5527710890',
'5529455542',
'5527952792',
'5527953332',
'5529455567',
'5528010392',
'5528004834',
'5528019886',
'5528032264',
'5528027534',
'5528036920',
'5528024963',
'5528048791',
'5528060983',
'5529831994',
'5529831995',
'5528070145',
'5528080535',
'5528090755',
'5528083741',
'5528091155',
'5528091303',
'5528095961',
'5528096941',
'5528097222',
'5528118185',
'5528113488',
'5528164569',
'5528220871',
'5528219871',
'5528219870',
'5528246570',
'5529832108',
'5528282133',
'5528322948',
'5528323675',
'5582059482',
'9579947948',
'9579508975')

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002653295','AS002656036')

--UC020928删除回访
select * 
--delete
from homsomDB..Trv_Memos where id='8406583A-F0DC-4179-8B72-AA8D01232663'

--018627 康帕斯帮我把里面的常旅客都删了
select * from homsomDB..Trv_Human 
--update homsomDB..Trv_Human  set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies
where Cmpid='018627'))
and IsDisplay=1

select * from Topway..tbCusholderM
--update Topway..tbCusholderM set EmployeeStatus=0
where cmpid='018627'

--UC019392范德兰德物流自动化系统(上海)有限公司 请提供2018年1月1日-2019年7月19日出过国内机票的常旅客名单

select distinct case when h.Name<>'' then h.Name when h.Name='' then LastName+'/'+FirstName+MiddleName else '' end 姓名,
CredentialNo 证件号,idno,pasname
from Topway..tbcash c
left join homsomDB..Trv_Credentials cr on isnull(cr.CredentialNo,'')=isnull(c.idno,'')
left join homsomDB..Trv_Human h on h.ID=cr.HumanID
where cmpcode='019392'
and datetime>='2018-01-01'
and datetime<'2019-07-20'
and inf=0
and reti=''
and idno!='null'
order by 姓名

select distinct pasname,idno from Topway..tbcash where cmpcode='019392'
and datetime>='2018-01-01'
and datetime<'2019-07-20'
and inf=0
and reti=''

--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno='AS002654051'

--酒店销售单作废
select status,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set status=-2
where CoupNo in('-PTW086177','PTW087652')



select top 100  totprice,owe,* from Topway..tbhtlyfchargeoff  where opername1='张红'
--update Topway..tbhtlyfchargeoff  set totprice=0,owe=0
where coupid in(select id from Topway..tbHtlcoupYf 
where CoupNo in('-PTW086177','PTW087652'))




---删除酒店调整单
select * 
--delete
from Topway..tbHtlcoupYf where CoupNo='-PTW086177'

select * 
--delete
from Topway..tbhtlyfchargeoff 
where coupid in(select id from Topway..tbHtlcoupYf 
where CoupNo in('-PTW086177'))


--机场英文名称
update homsomDB..Trv_Airport set EnglishName='' where ID=''

select EndDate,* from Topway..tbcash where coupno='AS002653437'
select * from homsomDB..Trv_DomesticTicketRecord where RecordNumber='AS002653437'
select * from homsomDB..Trv_ItktBookingSegments_PnrInfos where PnrInfoID='74660005-C395-4ED1-9AFC-AA9200A838F0'
select * from homsomDB..Trv_ItktBookingSegs where ID='A0108D5B-A161-490A-BF3E-AA9200A838F0'

select * from Topway..Emppwd where idnumber=0698

 --拆单16人
select MobileList,CostCenter,pcs,Department,price,sfare1,* from topway..tbFiveCoupInfosub
--update topway..tbFiveCoupInfosub set MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='16',Department='无,无,无,无,无,无,无,无,无,无,无,无,无,无,无' 
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002655784')

--旅游预算单信息
SELECT EndDate,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set EndDate='2019-08-09'
where TrvId='30322'