select CoupNo,L.DepartureTime from homsomDB..Intl_BookingLegs l
left join homsomDB..Intl_BookingSegements s on l.BookingSegmentId=s.Id
left join Topway..tbFiveCoupInfo f on f.OrderId=s.BookingOrderId
where Code2='pvg'
AND  CoupNo in ('AS002419379',
'AS002414506',
'AS002384864',
'AS002351473',
'AS002349229',
'AS002349229',
'AS002329917',
'AS002328334',
'AS002323273',
'AS002314808',
'AS002314128',
'AS002314128',
'AS002314127',
'AS002290123',
'AS002290123')
AND Code1 IN('LHR',
'LHR',
'HKG',
'DXB',
'LHR',
'LHR',
'MAD',
'LHR',
'HKG',
'MAD',
'MAD',
'MAD',
'MAD',
'LHR',
'LHR')