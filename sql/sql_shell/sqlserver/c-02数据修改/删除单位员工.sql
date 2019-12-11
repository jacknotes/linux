--查询已经销售custid
select custid from Topway..tbcash where cmpcode='018919' group by custid
select CustId from topway..tbTrvCoup where CmpId='018919' group by CustId
--删除员工脚本 TMS
select * from  homsomDB..Trv_Human
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (
select a.ID from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID in(select ID from homsomDB..Trv_UnitCompanies where Cmpid='020028')
and IsDisplay=1 and Name in ('程琳','冯朱兰','温馨')
)


--删除员工脚本ERP
select * from Topway..tbCusholderM where cmpid='020028' and custname in ('程琳','冯朱兰','温馨')

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

--删除多余ERP人员
delete from Topway..tbCusholderM where cmpid='018163'  and custname not in('陆秋燕','贺宇博','顾毓雯','马国强','阳兵兵','顾闻','周进')  and id between 167283 and 167305