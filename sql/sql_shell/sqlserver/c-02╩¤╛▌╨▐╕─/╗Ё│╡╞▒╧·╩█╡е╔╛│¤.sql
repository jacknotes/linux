SELECT *
--delete 
from Topway..tbTrainTicketInfo WHERE (CoupNo='RS000017404')
SELECT *
--delete 
from Topway ..tbTrainUser where TrainTicketNo in (Select id from tbTrainTicketInfo WHERE CoupNo='RS000017404' )