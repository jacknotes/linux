select OperDate,* from topway..tbTrvCoup 
--update topway..tbTrvCoup set OperDate='2018-12-29'
where TrvId='29068'
select ModifyDate,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set ModifyDate='2018-12-29'
where TrvId='29068'

SELECT TotFuprice,TotSprice,TotUnitprice,* FROM topway..tbTrainTicketInfo WHERE (CoupNo='RS000017976')
SELECT Fuprice,* FROM topway..tbTrainUser WHERE TrainTicketNo IN (SELECT ID FROM topway..tbTrainTicketInfo WHERE CoupNo='RS000017976')