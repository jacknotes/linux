--账单撤销
select SubmitState,* from Topway..AccountStatement
--update Topway..AccountStatement set SubmitState=1
where BillNumber='016588_20190526'

select * from Topway..FinanceERP_ClientBankRealIncomeDetail where date='2019-07-09' and money='1000'

/*
帮我看下016448国际机票的销量，只要金额（不含税）
2017.07.01-2018.06.30
2018.07.01-2019.06.30
*/
select sum(销量不含税-isnull(退票费,0)) 销量不含税 from (
select SUM(price) 销量不含税,reti from Topway..tbcash 
where cmpcode='016448'
and datetime>='2017-07-01'
and datetime<'2018-07-01'
and inf=1
group by reti) t1
left join (
select SUM(totprice) 退票费,reno from Topway..tbReti
where cmpcode='016448'
and datetime>='2017-07-01'
and datetime<'2018-07-01'
and inf=1
group by reno
)  t2 on t1.reti=t2.reno

select sum(销量不含税-isnull(退票费,0))销量不含税 from (
select SUM(price) 销量不含税,reti from Topway..tbcash 
where cmpcode='016448'
and datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=1
group by reti) t1
left join (
select SUM(totprice) 退票费,reno from Topway..tbReti
where cmpcode='016448'
and datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=1
group by reno
)  t2 on t1.reti=t2.reno


--修改OA签核人
select Signer,* from ApproveBase..App_DefineBase 
--update ApproveBase..App_DefineBase  set Signer='0601'
where Signer='601'

select * from ApproveBase..App_DefineBase where Signer='601'
select * from ApproveBase..App_Content where AppID='APP201907120002'
select Signer,* from ApproveBase..App_DefineBase 
--update ApproveBase..App_DefineBase  set Signer='0602'
where AppNo in('WF0118','WF0123','WF0124','WF0148','WF0194') and Seq=1

--修改机票预订权限
select UPRankID,* from homsomDB..Trv_UnitPersons 
--update homsomDB..Trv_UnitPersons  set UPRankID='EEFB7FC3-E12E-426F-BBE9-AA8500EB243B'
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='020777')
and ID in(Select ID from homsomDB..Trv_Human where Name in('于刚',
'刘彤',
'陈阳',
'牟青',
'赵颖',
'张扬',
'李楠',
'王庄',
'许伟锋',
'涂晓夫',
'施承辰',
'胡双宝',
'肖思强',
'陈坤',
'陈军',
'胡茂华',
'李瑞',
'王海晖',
'徐向东',
'汪亮',
'祝鹏程') and IsDisplay=1)

select UPRankID,* from homsomDB..Trv_UnitPersons 
--update homsomDB..Trv_UnitPersons  set UPRankID='FEAC5608-702F-493D-A18E-AA8500EB0FA5'
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='020777')
and ID in(Select ID from homsomDB..Trv_Human where Name not in('于刚',
'刘彤',
'陈阳',
'牟青',
'赵颖',
'张扬',
'李楠',
'王庄',
'许伟锋',
'涂晓夫',
'施承辰',
'胡双宝',
'肖思强',
'陈坤',
'陈军',
'胡茂华',
'李瑞',
'王海晖',
'徐向东',
'汪亮',
'祝鹏程') and IsDisplay=1)

--（产品部专用）机票供应商来源（国际）
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='现金垫付'
where coupno in('AS002517582','AS002517581')

--重开打印
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate-'1900-01-01'
where TrvId='30217' and Id='228744'

select * from ApproveBase..App_Agent where AgentID='601'

--更改支付方式（自付、垫付）
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,vpayinf,amount,* from Topway..tbcash 
--update Topway..tbcash set TCPayNo=PayNo,PayNo='',AdvanceStatus=PayStatus,PayStatus=0,TcPayWay=CustomerPayWay,CustomerPayWay=0,TcPayDate=CustomerPayDate,dzhxDate='1900-01-01',CustomerPayDate='1900-01-01',status=0,owe=totprice,vpay=0,vpayinf=''
where coupno in ('AS002607776','AS002607772')


select PayStatus,AdvanceStatus,PayNo,TCPayNo,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from Topway..tbFiveCoupInfo
--UPDATE Topway..tbFiveCoupInfo SET AdvanceStatus=PayStatus,TCPayNo=PayNo,TcPayWay=CustomerPayWay,TcPayDate=CustomerPayDate,PayStatus=0,PayNo='',CustomerPayWay=0,CustomerPayDate=null
WHERE CoupNo in ('AS002607776','AS002607772')

--旅游收款单信息
select Price,totprice,owe,Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Price='36973',totprice='36973',owe='36973',Pstatus=0,PrDate='1900-01-01'
where TrvId='30413'

--旅游收款单信息
select Skstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Skstatus=2
where TrvId='29995' and Id='228720'

--旅游结算单信息
select beg_date,end_date,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set beg_date='2019-08-02',end_date='2019-08-04'
where CoupNo='PTW086460'

--酒店核销支付说明
 select cwstatus,owe,vpay,opername1,vpayinfo,oth2,totprice,operdate1,vpayinfo,* from Topway..tbhtlyfchargeoff
--update  Topway..tbhtlyfchargeoff set vpayinfo='支付宝'
where coupid in (Select id from Topway..tbHtlcoupYf where CoupNo in('PTW084499','PTW084219'))

--会务收款核销备注
select oth2,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set oth2=''
where ConventionId='1444'

--旅游收款核销备注
select oth2,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set oth2=''
where TrvId='30217'

--开通差旅顾问绩效排名
select IsJoinRank,* from Topway..Emppwd 
--update Topway..Emppwd  set IsJoinRank='1'
where idnumber='工号'


select c.coupno,route,CityName1,CityName2,b.Sort,bo.Sort
from Topway..tbcash c
left join Topway..tbFiveCoupInfo t on t.CoupNo=c.coupno
left join homsomDB..Intl_BookingSegements b on b.BookingOrderId=t.OrderId
left join homsomDB..Intl_BookingLegs bo on bo.BookingSegmentId=b.Id
where datetime>='2019-07-01'
and inf=1
order by b.Sort,bo.Sort

select tickettype,route,reti,begdate,cmpcode,trvYsId,ConventionYsId,* from Topway..tbcash where coupno in('AS002601445',
'AS002628290',
'AS002623774',
'AS002628292',
'AS002601448',
'AS002601441',
'AS002601442',
'AS002601442',
'AS002610403',
'AS002628291',
'AS002601447',
'AS002617826',
'AS002615958',
'AS002628294')
select OrderId,* from Topway..tbFiveCoupInfo where CoupNo in('AS002601445',
'AS002628290',
'AS002623774',
'AS002628292',
'AS002601448',
'AS002601441',
'AS002601442',
'AS002601442',
'AS002610403',
'AS002628291',
'AS002601447',
'AS002617826',
'AS002615958',
'AS002628294')
