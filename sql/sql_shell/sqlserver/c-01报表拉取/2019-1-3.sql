SELECT TotFuprice,TotPrice,* FROM tbTrainTicketInfo 
--update tbTrainTicketInfo set TotFuprice='0',TotPrice='553'
WHERE (CoupNo='RS000017976')


SELECT Fuprice,* FROM topway..tbTrainUser 
--update topway..tbTrainUser set Fuprice='0'
WHERE TrainTicketNo IN (SELECT ID FROM topway..tbTrainTicketInfo WHERE CoupNo='RS000017976')

select datetime,* from Topway..tbcash where coupno='AS002131778'

SELECT SubmitState,* FROM Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
WHERE (CompanyCode = '020204') and BillNumber='020204_20181201' 

SELECT SubmitState,* FROM Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
WHERE (CompanyCode = '016720') and BillNumber='016720_20181201' 

select Pstatus,PrDate,* from topway..tbTrvKhSk 
--update topway..tbTrvKhSk set Pstatus='0',PrDate='1900-01-01'
where Id='226658'

select t_source from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002154949'
select t_source from Topway..tbcash 
--update Topway..tbcash set t_source='HS易商天华D'
where coupno='AS002160833'
select t_source from Topway..tbcash 
--update Topway..tbcash set t_source='HS易商三井I'
where coupno='AS002166027'
select t_source from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETI'
where coupno='AS002166411'
select t_source from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno='AS002161178'

select BirthPlace,pcs,* from tbFiveCoupInfosub 
--update tbFiveCoupInfosub set pcs='27'

where FkfiveNo in (select fiveno from tbFiveCoupInfo where CoupNo='AS002174359')

select price,sfare1,sprice,mcost,profit,* from tbFiveCoupInfosub 
--update tbFiveCoupInfosub set price='2000',sfare1='1800',sprice='1800',mcost='30',profit='200'
where FkfiveNo in (select fiveno from tbFiveCoupInfo where CoupNo='AS002174359')

select * from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptCode='客户关系部',DeptName='客户关系部'
where ID=5
select * from ApproveBase..HR_AskForLeave_Signer
--update ApproveBase..HR_AskForLeave_Signer set DeptCode='客户关系部'
where DeptCode='售后服务部'
select * from ApproveBase..HR_Employee
--update ApproveBase..HR_Employee DeptCode='客户关系部',Department='客户关系部'
where DeptCode='售后服务部' or Department='售后服务部'

select datetime as 出票日期,coupno as 销售单号,totprice as 销售价,sales as 所属业务顾问
from Topway..tbcash where pform='月结' and status=0  --and trvYsId<>'0' or ConventionYsId<>'0' 
and  datetime>'2016-01-01' and datetime<'2019-01-01'
order by datetime