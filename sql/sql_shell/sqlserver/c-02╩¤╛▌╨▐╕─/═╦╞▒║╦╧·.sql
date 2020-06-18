--修改退票核销  ModifyBillNumber为空，status2=2，绑定账期status2=8
select ExamineDate,ModifyBillNumber,status2,* from Topway..tbReti 
--update Topway..tbReti set ExamineDate='1900-01-01',status2='8'
where reno='9267207'