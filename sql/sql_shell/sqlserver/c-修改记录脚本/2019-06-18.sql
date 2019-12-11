select empname,idnumber,* from Topway..Emppwd 
--update Topway..Emppwd  set dep='技术研发中心'
where dep='技术部' 

select * from ApproveBase..HR_Employee where DeptCode!=Department

select datetime 日期,coupno,status,owe,totprice,pform,* from Topway..tbcash where status=1 and owe<>0 order by 日期 desc


select bpay as 支付金额,status as 收款状态,opernum as 核销次数,oper2 as 核销人,oth2 as 备注,totprice as 销售价,dzhxDate as 核销时间,owe as 欠款金额
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
from Topway..tbcash where coupno in ('AS002520927','AS002492609','AS002407288','AS002404287')


--UC019294  UC017670 2018年集团子公司航空差旅费用统计表
--出票费用
if OBJECT_ID('tempdb..#cpfy') is not null drop table #cpfy
select cmpcode,SUM(totprice)/10000 出票费用
--into #cpfy
from Topway..tbcash 
where ModifyBillNumber in ('017670_20180101','017670_20180201','017670_20180301','017670_20180401','017670_20180501','017670_20180601',
'017670_20180701','017670_20180801','017670_20180901','017670_20181001','017670_20181101','017670_20181201',
'019294_20180101','019294_20180201','019294_20180301','019294_20180401','019294_20180501','019294_20180601',
'019294_20180701','019294_20180801','019294_20180901','019294_20181001','019294_20181101','019294_20181201')
--and ride  in('jd','Gs','Y8','8L','9H','gx','GT','PU','Uq','pn')
--and ride  in ('FM','MU')
--and ride  in ('CZ')
--and ride  in ('CA','ZH')
and inf=1
group by cmpcode

--退票费用
if OBJECT_ID('tempdb..#tpfy') is not null drop table #tpfy
select cmpcode,sum(-totprice)/10000 退票费用
--into #tpfy
from Topway..tbReti 
where  ModifyBillNumber in ('017670_20180101','017670_20180201','017670_20180301','017670_20180401','017670_20180501','017670_20180601',
'017670_20180701','017670_20180801','017670_20180901','017670_20181001','017670_20181101','017670_20181201',
'019294_20180101','019294_20180201','019294_20180301','019294_20180401','019294_20180501','019294_20180601',
'019294_20180701','019294_20180801','019294_20180901','019294_20181001','019294_20181101','019294_20181201')
--and ride not in ('FM','MU')
--and ride not in ('CZ')
--and ride not in ('CA','ZH')
and inf=1
group by cmpcode

select 出票费用+退票费用 国内年费用   from #cpfy c
left join #tpfy t on c.cmpcode=t.cmpcode




select BillNumber 账单号,BillAmount 机票账单金额 from Topway..AccountStatement 
where BillNumber in ('017670_20180101','017670_20180201','017670_20180301','017670_20180401','017670_20180501','017670_20180601',
'017670_20180701','017670_20180801','017670_20180901','017670_20181001','017670_20181101','017670_20181201',
'019294_20180101','019294_20180201','019294_20180301','019294_20180401','019294_20180501','019294_20180601',
'019294_20180701','019294_20180801','019294_20180901','019294_20181001','019294_20181101','019294_20181201')
order by 账单号

--UC020866上海依迪索时装有限公司 为他人预订 名单导入下
if OBJECT_ID ('tempdb..#spr') is not null drop table #spr
select Cmpid,up.BookingCollectionID 
into #spr
from homsomDB..Trv_Human h 
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies  un on un.ID=u.CompanyID
left join homsomDB..Trv_UPSettings up on up.ID=u.UPSettingID
where Cmpid='020866' and h.Name in('梁安琪','谢素蓉')

if OBJECT_ID ('tempdb..#sp') is not null drop table #sp
select BookingCollectionID,un.ID 
into #sp
from homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons un on un.ID=h.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=un.CompanyID
left join #spr s on s.cmpid=u.Cmpid
where u.Cmpid='020866' 
and h.Name in('杨君',
'关蕴',
'林雪菁',
'黄嘉惠',
'何倩怡',
'李赟恒',
'张子俊',
'王文清',
'萧纯文',
'李露',
'曹媛萍',
'颜俊清',
'林嘉健')

insert into homsomDB..Trv_UPCollections_UnitPersons (UPCollectionID,UnitPersonID) select BookingCollectionID,ID from #sp


--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set  sales='黄怡丽',SpareTC='黄怡丽'
where coupno='AS001712967'

--账单撤销
select SubmitState,BillAmount,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020548_20190501'

--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno='AS002517163'


--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice-1,profit=profit+1
where coupno in('AS002537847','AS002540149')

select * from Topway..tbSettlementApp where id='113052'

/*
UC020410贵酿酒业有限公司
2018.7--12月，2019.1-5月
酒店销量数据
*/
select CoupNo 销售单号,prdate 预订时间,end_date 离店时间,hotel 酒店名称,roomtype 房型
,pasname 入住人,nights 入住天数,pcs 房间数,price 销售价
from Topway..tbHtlcoupYf
where cmpid='020410'
and prdate>='2018-07-01'
and prdate<'2019-06-01'
and  status!=-2
order by 预订时间


--乘机人匹配常旅客
select distinct pasname,h.Name,idno  
from Topway..tbcash c
inner join homsomDB..Trv_Credentials cr on cr.CredentialNo=c.idno
inner join homsomDB..Trv_UnitPersons u on u.ID=cr.HumanID and CompanyID=(select id from homsomDB..Trv_UnitCompanies where Cmpid='020410')
inner join homsomDB..Trv_Human h on h.ID=cr.HumanID
where cmpcode='020410'

select pasname,COUNT(1)张数 from Topway..tbcash where cmpcode='020410' group by pasname


--更改支付方式（自付、垫付）
--国际自付变更垫付
select AdvanceStatus,PayStatus,TCPayNo,PayNo,TcPayWay,CustomerPayWay,TcPayDate,CustomerPayDate,* from Topway..tbFiveCoupInfo      
--UPDATE Topway..tbFiveCoupInfo SET AdvanceStatus=PayStatus,TCPayNo=PayNo,TcPayWay=CustomerPayWay,TcPayDate=CustomerPayDate,PayStatus=0,PayNo=NULL,CustomerPayWay=0,CustomerPayDate=NULL
WHERE CoupNo='AS002360084'

--更新出票信息中的支付号
select AdvanceStatus,PayStatus,TCPayNo,PayNo,TcPayWay,CustomerPayWay,TcPayDate,CustomerPayDate,dzhxDate,* from topway..tbcash
--update topway..tbcash set AdvanceStatus=PayStatus,TCPayNo=PayNo,TcPayWay=CustomerPayWay,TcPayDate=CustomerPayDate,PayStatus=0,PayNo=null,CustomerPayWay=0,CustomerPayDate=null
where coupno='AS002360084'

select * from ApproveBase..App_Content  where Value like '%2019050901872%'
