
select * from ehomsom..tbPlanetype where aname='32Q'
--增加机型
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('127','空客','A330系列','A330','3HH','200-262','宽体')
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('128','空客','A321系列','A321','32Q','174-220','窄体')

--重开打印权限
select Pstatus,PrDate,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set Pstatus='0',PrDate='1900-01-01'
where ConventionId='1155' and Id ='2585'

select Pstatus,PrDate,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set Pstatus='0',PrDate='1900-01-01'
where ConventionId='1068' and Id ='2586'

--修改收款核销时间

select dzHxDate,* from topway..tbConventionKhSk 
--update topway..tbConventionKhSk  set dzHxDate='2019-01-14'
where ConventionId='966' and Id='2587'

--清空申请费来源
select feiyonginfo,feiyong,* from Topway..tbcash 
--update Topway..tbcash set feiyonginfo='',feiyong=''
where coupno='AS002242733'

--酒店调整单
select totprofit,FixedDiscount,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set totprofit='596',FixedDiscount='-140'
where CoupNo='-PTW075878'

select totprice,owe,* from Topway..tbhtlyfchargeoff 
--update Topway..tbhtlyfchargeoff  totprice='-6698.00',owe='-6698.00'
where coupid in(select id from Topway..tbHtlcoupYf where CoupNo='-PTW075878')

--修改收款核销时间
select dzHxDate,* from topway..tbConventionKhSk 
--update topway..tbConventionKhSk  set dzHxDate='2019-01-10'
where ConventionId='1068' and Id='2586'

select dzHxDate,* from topway..tbConventionKhSk 
--update topway..tbConventionKhSk  set dzHxDate='2019-01-10'
where ConventionId='980' and Id='2584'

select dzHxDate,* from topway..tbConventionKhSk 
--update topway..tbConventionKhSk  set dzHxDate='2019-01-10'
where ConventionId='975' and Id='2583'

select dzHxDate,* from topway..tbConventionKhSk 
--update topway..tbConventionKhSk  set dzHxDate='2019-01-10'
where ConventionId='1155' and Id='2585'

--酒店调整单
select totprofit,FixedDiscount,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set totprofit='-188',FixedDiscount='-20'
where CoupNo='-PTW075928'

select totprofit,FixedDiscount,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set totprofit='-583',FixedDiscount='-30'
where CoupNo='-PTW075927'

--修改闭团时间
select OperDate,* from Topway..tbConventionCoup 
--update Topway..tbConventionCoup set OperDate='2019-01-23'
where ConventionId in('975','980','1068')

select OperDate,* from Topway..tbConventionCoup 
--update Topway..tbConventionCoup set OperDate='2019-01-28'
where ConventionId='966'

--火车票销售单作废
Select CmpId,*
  FROM Topway..tbTrainTicketInfo
  WHERE CoupNo in('RS000019399','RS000019400')
  --DELETE FROM Topway..tbTrainTicketInfo WHERE CoupNo in('RS000019399','RS000019400')

Select * 
  FROM Topway..tbTrainUser
  WHERE TrainTicketNo in(SELECT ID
  FROM Topway..tbTrainTicketInfo
  WHERE CoupNo='RS000019399')
--delete FROM Topway..tbTrainUser WHERE TrainTicketNo in (SELECT ID FROM Topway..tbTrainTicketInfo WHERE CoupNo='RS000019399')
--delete FROM Topway..tbTrainUser WHERE TrainTicketNo in (SELECT ID FROM Topway..tbTrainTicketInfo WHERE CoupNo='RS000019400')

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where BillNumber='020477_20190101'

