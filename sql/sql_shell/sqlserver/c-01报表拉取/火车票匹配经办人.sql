select CoupNo,m.custname,* from tbTrainTicketInfo train
left join tbCusholderM m on train.CustId=m.custid
left join tbTrainUser [user] on [user].TrainTicketNo=train.ID
where coupno in 
('RS000005820','RS000005824','RS000005824','RS000005825','RS000005826','RS000005826','RS000005826','RS000005939','RS000005940','RS000005949','RS000005953','RS000005953','RS000005955','RS000005957')
order by train.coupno

