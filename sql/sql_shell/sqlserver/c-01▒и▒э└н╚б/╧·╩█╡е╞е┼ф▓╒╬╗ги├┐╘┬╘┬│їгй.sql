--ÀÏ
SELECT * FROM ehomsom..tbInfCabincode WHERE code2='MU' AND cabin='Y' AND begdate<='2017/07/03' AND enddate>='2017/07/03'

SELECT c.coupno,i.* FROM Topway..tbcash  c 
LEFT JOIN ehomsom..tbInfCabincode i ON c.ride=i.code2 AND c.nclass=i.cabin
WHERE i.begdate<=c.begdate AND i.enddate>=c.begdate AND 
c.coupno in 
()



--ÐÂ
SELECT c.coupno,(SELECT TOP 1 i.cabintype 
	FROM ehomsom..tbInfCabincode i 
	WHERE	c.ride=i.code2 AND c.nclass=i.cabin 
										AND i.begdate<=c.begdate AND i.enddate>=c.begdate
	ORDER BY id DESC
	) AS cabinType
fROM Topway..tbcash  c
where c.coupno in
('AS002241013',
'AS002242253',
'AS002243057',
'AS002247386',
'AS002248320',
'AS002248338',
'AS002250347',
'AS002251474',
'AS002254869',
'AS002255941',
'AS002259620',
'AS002259622',
'AS002263775',
'AS002264048',
'AS002268051',
'AS002268293',
'AS002268293',
'AS002268406',
'AS002268803',
'AS002269289',
'AS002272033',
'AS002272033',
'AS002272534',
'AS002274442',
'AS002279383',
'AS002281186')
