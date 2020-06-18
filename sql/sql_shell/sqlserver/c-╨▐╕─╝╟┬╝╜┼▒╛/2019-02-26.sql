--修改旅游收款单核销日期
select dzHxDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set dzHxDate='2019-02-22'
where TrvId='29606' and Id='227047'

--调整结算差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=2072,profit=112
where coupno='AS002266755'

--修改供应商来源
select t_source,* from Topway..tbcash  
--update Topway..tbcash  set t_source='ZSBSPETI'
where coupno='AS002253266'

select * from Topway..tbcash c
left join Topway..tbCompanyM m on m.cmpid=c.cmpcode
left join Topway..tbCusholder m1 on m1.

--重开打印

select PrDate,Pstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set PrDate='1900-01-01',Pstatus=0
where TrvId='029591'


select SUM(profitcompensation) from Topway..tbTrvCoup where OperDate>='2017-01-01' and OperDate<'2019-01-01'

--删除员工脚本
--TMS
select * from homsomDB..Trv_Human 
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (
select a.ID from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID=(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1 and Name not in ('陆秋燕','贺宇博','顾毓雯','马国强','阳兵兵','顾闻','周进'))

--ERP删除多余信息
select * from Topway..tbCusholderM where cmpid='018163' and custname not in('陆秋燕','贺宇博','顾毓雯','马国强','阳兵兵','顾闻','周进')
delete from Topway..tbCusholderM where cmpid='018163'  and custname not in('陆秋燕','贺宇博','顾毓雯','马国强','阳兵兵','顾闻','周进')  and id between 167283 and 167305
--delete from Topway..tbCusholderM where cmpid='018163' and custname not in('陆秋燕','贺宇博','顾毓雯','马国强','阳兵兵','顾闻','周进')

--TMS常旅客导入ERP
insert into tbcusholderM(cmpid,custid,ccustid,custname,custtype1,male,username,phone,mobilephone,personemail,CardId,custtype,homeadd,joindate) 
select cmpid,CustID,CustID,h.Name,
CASE
WHEN u.Type='普通员工' THEN ''
WHEN u.Type='经办人' THEN '3'
WHEN u.Type='负责人' THEN '4'
WHEN u.Type='高管' THEN '5'
ELSE 2 end,
CASE 
WHEN h.Gender=1 THEN '男'
WHEN h.Gender=0 THEN '女'
ELSE '男' end
,'',h.Telephone,h.Mobile,h.Email,'',u.CustomerType,'手工批量导入' ,h.CreateDate
FROM homsomDB..Trv_UnitPersons u
INNER JOIN homsomDB..Trv_Human h ON u.id =h.ID
INNER JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID
WHERE Cmpid='018163' AND h.IsDisplay=1 and h.Name not in ('陆秋燕','贺宇博','顾毓雯','马国强','阳兵兵','顾闻','周进')

select custid from Topway..tbcash where cmpcode='018919' group by custid
select CustId from topway..tbTrvCoup where CmpId='018919' group by CustId

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='徐薇',SpareTC='徐薇'
where coupno='AS001447710'


--结算价差额调整
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=6866,profit=478
where coupno='AS002262985'
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=2267,profit=1031
where coupno='AS002265405'

--航司调整
select * from ehomsom..tbInfAirCompany where code2='mu'

--修改资金利润
select Mcost,* from Topway..tbcash 
--update Topway..tbcash set Mcost=0
where coupno in('AS002257180','AS002257215')

select Mcost,* from Topway..tbcash 
--update Topway..tbcash set Mcost=0
where coupno='AS002257312'

--重开打印
select PrDate,Pstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set PrDate='1900-01-01',Pstatus=0
where TrvId='29627'

--机票数据
--国内
--select cmpid, * from Topway..tbCompanyM where cmpname like '欧梯克工业（天津）有限公司上海分公司'
select * from Topway..tbcash 
where cmpcode='018487' 
and datetime>='2018-08-01' 
and inf=0 and reti='' 
and tickettype='电子票' 
--and (route like '%改期%' or route like '%升舱%') 
--退票
select * from Topway..tbReti 
where cmpcode ='018487' 
and datetime>='2018-08-01'
and inf=0 
--改期升舱
select * from Topway..tbcash 
where cmpcode='018487' 
and datetime>='2018-08-01' 
and inf=0 and reti='' 
and (tickettype like'%改期%' or tickettype like'%升舱%')
--国际
select * from Topway..tbcash 
where cmpcode='018487' 
and datetime>='2018-08-01' 
and inf=1 and reti='' 
and tickettype='电子票' 
 
 
