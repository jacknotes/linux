--多付款单、退票付款申请单修改/作废
select IsEnable,* from Topway..tbExtraPayment 
--update Topway..tbExtraPayment  set IsEnable=0
where Id='51649'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='周琦',SpareTC='周琦'
where coupno='AS002592779'

--修改UC号（机票）
--select * from Topway..tbcash where cmpcode='020561' and datetime>'2019-06-01'

select custid,cmpcode,ModifyBillNumber,OriginalBillNumber,pform,* from Topway..tbcash 
--update Topway..tbcash  set custid='D607658',cmpcode='020561',ModifyBillNumber='020561_20190601',OriginalBillNumber='020561_20190601',pform='月结(中行)'
where coupno='AS002523046'

--修改税收
select stax,tax,totsprice,totprice,owe,amount,* from Topway..tbcash 
--update Topway..tbcash  set stax=tax
where coupno='AS002591854'

select stax,tax,totsprice,totprice,owe,amount,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=250
where coupno='AS002591854'

--多付款单、退票付款申请单修改
select Remarks,* from Topway..tbExtraPayment 
--update Topway..tbExtraPayment  set Remarks='AS002479818多付款7690'
where Id='51648'


--多付款单修改金额
select Total,TotalB,* from Topway..tbExtraPayment 
--update Topway..tbExtraPayment  set Total=7690,TotalB='柒仟陆佰玖拾元'
where Id='51648'


--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='员工垫付（王贞中行卡）'
where CoupNo='PTW085700'

--重开打印
select Pstatus,Prdate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,Prdate='1900-01-01'
where TrvId='30139' and Id='228615'

select Pstatus,Prdate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,Prdate='1900-01-01'
where TrvId='30058' and Id='228464'

--销售单拆分11个
 select * from topway..tbFiveCoupInfosub
--update topway..tbFiveCoupInfosub set MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='11',Department='无,无,无,无,无,无,无,无,无,无,无' 
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002599744')

--重开打印
select Pstatus,Prdate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,Prdate='1900-01-01'
where TrvId='30139' and Id='228615'

select Pstatus,Prdate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,Prdate='1900-01-01'
where TrvId='30219' and Id='228618'


--酒店REASON CODE，预订人，差旅目的

select  h.CoupNo as 销售单号,Purpose as 差旅目的,m.custname,ReasonDescription  FROM [HotelOrderDB].[dbo].[HTL_Orders] h
left join Topway..tbHtlcoupYf t on t.CoupNo=h.CoupNo
left join Topway..tbCusholderM m on m.custid=t.custid 
where h.CoupNo in ('PTW083934',
'PTW084009',
'PTW084063',
'-PTW083934',
'PTW084265',
'PTW084698',
'PTW084714',
'PTW084759',
'PTW084799',
'PTW085064',
'PTW085704',
'PTW085706',
'PTW085708',
'PTW085709')

--机票销售单匹配REASON CODE，预订人，差旅目的
select coupno,isnull(UnChoosedReason,'') REASONCODE,m.custname 预订人,isnull(Purpose,'')差旅目的  from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos t on d.PnrInfoID=t.PnrInfoID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=t.ItktBookingSegID
left join Topway..tbCusholderM m on m.custid=c.custid
where coupno in ('AS002530836',
'AS002530955',
'AS002530958',
'AS002531256',
'AS002531262',
'AS002533754',
'AS002539359',
'AS002541969',
'AS002541969',
'AS002547206',
'AS002549493',
'AS002549493',
'AS002549493',
'AS002554628',
'AS002554972',
'AS002556067',
'AS002556886',
'AS002556888',
'AS002563109',
'AS002563109',
'AS002564536',
'AS002567897',
'AS002569252',
'AS002569252',
'AS002570239',
'AS002571884',
'AS002572745',
'AS002583350',
'AS002583352',
'AS002583965',
'AS002593327',
'AS002593327',
'AS002593327',
'AS002593344',
'AS002593344',
'AS002593345',
'AS002593388',
'AS002593388',
'AS002593433',
'AS002593568',
'AS002593571',
'AS002593573',
'AS002593576',
'AS002512694',
'AS002512710',
'AS002512944')

--酒店销售单供应商来源
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='员工垫付（王贞中行卡）'
where CoupNo='PTW085700'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='009005_20190501'

--酒店销售单重开打印权限
select prdate,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set prdate='2019-06-30'
where CoupNo in('PTW085733','PTW085749')

--酒店销售单供应商来源
select profitsource 供应商来源,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='员工垫付（王贞中行卡）'
where CoupNo='PTW085844'

--旅游收款单信息
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus=0,PrDate='1900-01-01'
where TrvId='30369'

--旅游收款单信息
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='30396'

select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='30139' and Id='228616'


--多付款单重开打印
select PrintTime,CustDate,CustId,CustStat,* from Topway..tbExtraPayment 
--update Topway..tbExtraPayment  set PrintTime='1900-01-01',CustDate='1900-01-01',CustId='',CustStat=''
where Id='51648'

--补票号
--update Topway..tbcash set pasname='',tcode='781',ticketno='' where coupno='AS002599744' and pasname=''
update Topway..tbcash set pasname='DU/JING',tcode='781',ticketno='2401216167' where coupno='AS002599744' and pasname='乘客0'
update Topway..tbcash set pasname='FANG/YAO',tcode='781',ticketno='2401216168' where coupno='AS002599744' and pasname='乘客1'
update Topway..tbcash set pasname='GUO/LONG',tcode='781',ticketno='2401216169' where coupno='AS002599744' and pasname='乘客2'
update Topway..tbcash set pasname='HAN/CHAOWEI',tcode='781',ticketno='2401216170' where coupno='AS002599744' and pasname='乘客3'
update Topway..tbcash set pasname='LIU/LINLING',tcode='781',ticketno='2401216171' where coupno='AS002599744' and pasname='乘客4'
update Topway..tbcash set pasname='LIU/RUOXI',tcode='781',ticketno='2401216172' where coupno='AS002599744' and pasname='乘客5'
update Topway..tbcash set pasname='LU/QIANG',tcode='781',ticketno='2401216173' where coupno='AS002599744' and pasname='乘客6'
update Topway..tbcash set pasname='QIN/MEI',tcode='781',ticketno='2401216174' where coupno='AS002599744' and pasname='乘客7'
update Topway..tbcash set pasname='TANG/GUANGZHI',tcode='781',ticketno='2401216175' where coupno='AS002599744' and pasname='乘客8'
update Topway..tbcash set pasname='WANG/ZHENG',tcode='781',ticketno='2401216176' where coupno='AS002599744' and pasname='乘客9'
update Topway..tbcash set pasname='ZHANG/BO',tcode='781',ticketno='2401216177' where coupno='AS002599744' and pasname='乘客10'

--天纳克数据 数据不包含退改，税收
--有返佣
select * from 
(select cmpcode UC号,u.Name 单位名称,SUM(price) 销量,SUM(xfprice) 返佣金额 from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='电子票'
and xfprice<>0
and cmpcode in('020665')
group by cmpcode,u.Name) t1
left join
--无返佣
(select cmpcode UC号,u.Name 单位名称,SUM(price) 销量 from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='电子票'
and xfprice=0
and cmpcode in('020665')
group by cmpcode,u.Name)t2 on t1.UC号=t2.UC号
left join 
(select cmpcode UC号,u.Name 单位名称,SUM(price) MUUFJY舱的销量 from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='电子票'
and xfprice=0
and ride='MU'
and nclass in('U','F','J','Y')
and cmpcode in('020665')
group by cmpcode,u.Name)t3 on t1.UC号=t3.UC号
left join

(select cmpcode UC号,u.Name 单位名称,SUM(price) MU其他舱位销量 from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='电子票'
and xfprice=0
and ride='MU'
and nclass not in('U','F','J','Y')
and cmpcode in('020665')
group by cmpcode,u.Name) t4 on t1.UC号=t4.UC号
left join 

(select cmpcode UC号,u.Name 单位名称,SUM(price) CZ销量 from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='电子票'
and xfprice=0
and ride='cz'
and cmpcode in('020665')
group by cmpcode,u.Name) t5 on t1.UC号=t5.UC号
left join 
(select cmpcode UC号,u.Name 单位名称,SUM(price) HO销量 from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='电子票'
and xfprice=0
and ride='ho'
and cmpcode in('020665')
group by cmpcode,u.Name) t6 on t1.UC号=t6.UC号

select cmpcode UC号,u.Name 单位名称,SUM(price) HO销量,SUM(xfprice) from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=1
and reti=''
and tickettype='电子票'
and xfprice<>0
and cmpcode in('020665')
group by cmpcode,u.Name

--UC018308删除员工
select IsDisplay,* from homsomDB..Trv_Human 
--update homsomDB..Trv_Human  set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons 
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='018308'))
and Name in('汤玮（离职）','孙晓倩（离职）','陈炎（离职）')

select EmployeeStatus,* from Topway..tbCusholderM
--update Topway..tbCusholderM set EmployeeStatus=0
where cmpid='018308'
and custname  in('汤玮（离职）','孙晓倩（离职）','陈炎（离职）')

--UC018308删除员工角色权限
select UPRoleID,* from homsomDB..Trv_UnitPersons 
--update homsomDB..Trv_UnitPersons  set UPRoleID=null
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='018308')
and ID in('B1C1AC34-1F98-402E-A2F7-A6DC0122BB62','8FABCE0E-EAC3-4D47-BA3E-A9E500C9C9C9','48DD1488-79EA-4F15-A1D0-A91100BB7DAA')

-- 020278 欧士机需要拉取2019年所有外籍旅客的国际机票信息
select coupno 销售单号,convert(varchar(10),datetime,120) 出票日期,begdate 起飞日期,pasname 乘机人,idno 证件号,route 行程
,price 销售单价,totprice 销售价,tcode+ticketno  票号,tickettype 类型
from Topway..tbcash 
where cmpcode='020278'
and begdate>='2019-01-01'
and inf=1
order by 起飞日期


--酒店销售单重开打印权限
select pstatus,prdate,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set pstatus=0,prdate='1900-01-01'
where CoupNo='-PTW083551'

select DETR_RP,sales,SpareTC,* from Topway..tbcash where DETR_RP in('5098452430','5098452429')

/*
供应商来源：HSBSPETD 退票审核日期：2019-06-01至2019-06-30
舱位：F/A/J/C/D/Z/R/G/Y/W/S/T/L/P/N/K
素：票号、销售单号、供应商来源、退票单号、提交日期、审核日期、票面价、航空公司退票费、收客户退票金额、出票操作业务顾问、出票业务顾问、提交退票业务顾问、备注
*/
select distinct tcode+c.ticketno 票号,t.coupno 销售单号,t_source 供应商来源,reno 退票单号,edatetime 提交日期,ExamineDate 审核日期,sprice1+sprice2+sprice3+sprice4 票面价,
 scount2 航空公司退票费,rtprice 收客户退票金额,SpareTC 出票操作业务顾问,sales 出票业务顾问,opername 提交退票业务顾问,t.info 备注,nclass
from Topway..tbReti t
left join Topway..tbcash c on c.reti=t.reno and c.coupno=t.coupno
where ExamineDate>='2019-06-01'
and ExamineDate<'2019-07-01'
and t_source='HSBSPETD'
and nclass in('F','A','J','C','D','Z','R','G','Y','W','S','T','L','P','N','K')
and t.ride='ca'
order by 提交日期

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno ='AS002598386'

--修改供应商来源
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno in('AS002583747','AS002583754','AS002583777','AS002590002')

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETI'
where coupno in('AS002585166','AS002584496','AS002584528','AS002585316','AS002579241')

--请帮拉取以下数据（注：2019年1月1日前注册的单位客户为老客户）  维护人单位数据分析
select u.cmpid uc号,u.cmpname 单位名称,isnull(s.Name,'')维护人,indate 注册,un.Type 类型 from Topway..tbCompanyM u
left join homsomDB..Trv_UnitCompanies un on un.Cmpid=u.cmpid
left join homsomDB..Trv_UnitCompanies_KeyAccountManagers k on k.UnitCompanyID=un.ID
left join homsomDB..SSO_Users s on s.ID=k.EmployeeID
where hztype in ('1','2','3')
and s.Name is not null



/*
供应商来源：HSBSPETD 退票审核日期：2019-06-01至2019-06-30
舱位：F/A/J/C/D/Z/R/G/Y/W/S/T/L/P/N/K
航班号：CA开头
素：票号、销售单号、供应商来源、退票单号、提交日期、审核日期、票面价、航空公司退票费、收客户退票金额、出票操作业务顾问、出票业务顾问、提交退票业务顾问、备注
再帮我拉下四月和五月的，分开拉
舱位还要带在里面哦*/
select distinct tcode+c.ticketno 票号,t.coupno 销售单号,t_source 供应商来源,reno 退票单号,edatetime 提交日期,ExamineDate 审核日期,sprice1+sprice2+sprice3+sprice4 票面价,
 scount2 航空公司退票费,rtprice 收客户退票金额,SpareTC 出票操作业务顾问,sales 出票业务顾问,opername 提交退票业务顾问,t.info 备注,nclass
from Topway..tbReti t
left join Topway..tbcash c on c.reti=t.reno and c.coupno=t.coupno
where ExamineDate>='2019-05-01'
and ExamineDate<'2019-06-01'
and t_source='HSBSPETD'
and nclass in('F','A','J','C','D','Z','R','G','Y','W','S','T','L','P','N','K')
and t.ride='ca'
order by 提交日期


--修改酒店销售单账期
select ModifyBillNumber,OriginalBillNumber,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set OriginalBillNumber='017674_20190601'
where CoupNo='PTW085733'

select ModifyBillNumber,OriginalBillNumber,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set OriginalBillNumber='020552_20190601'
where CoupNo='PTW085749'