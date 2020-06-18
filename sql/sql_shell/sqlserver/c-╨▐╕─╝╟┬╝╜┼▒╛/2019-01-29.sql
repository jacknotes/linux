--OA签核人
select Signer,* from ApproveBase..HR_AskForLeave_Signer 
--update ApproveBase..HR_AskForLeave_Signer set Signer='0019'
where DeptCode='销售部'

--修改部门
select DeptCode,DeptName,* from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptCode='售后服务部',DeptName='售后服务部'
where DeptName='客户关系部'

select DeptCode,Department,* from ApproveBase..HR_Employee 
--update ApproveBase..HR_Employee set DeptCode='售后服务部',Department='售后服务部'
where Department='客户关系部'

select * from ApproveBase..HR_AskForLeave_Signer 
--update ApproveBase..HR_AskForLeave_Signer set DeptCode='售后服务部'
where DeptCode='客户关系部'

select top 10 depdate0, * from Topway..tbCompanyM 

--机场改名
SELECT Name,* FROM homsomDB..Trv_Airport 
--update homsomDB..Trv_Airport set Name='纽瓦克自由国际机场'
WHERE Code='EWR'

--供应商来源
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002222163'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETI'
where coupno='AS002229117'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002228006'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002232320'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002232306'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002228347'

--旅游预算单信息预订人信息
select * from Topway..tbCusholderM where mobilephone='13611656658'
select Custid,Custinfo as 预定信息,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Custid='D634482'
where TrvId='29215'

--会务收款单信息,预算单号1065由于发票类型不对，申请删除所有收款信息
select *from Topway..tbConventionKhSk where ConventionId='1065' and Id in('2277','2276')
--delete from Topway..tbConventionKhSk where ConventionId='1065' and Id in('2277','2276')