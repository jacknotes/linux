delete tbDetr
FROM Topway..tbDetr d
INNER JOIN Topway..tbcash c ON d.tcode=c.tcode AND d.ticketno=c.ticketno
WHERE c.datetime >='2017-01-01' AND c.t_source LIKE '%����%' AND d.fstatus='OPEN FOR USE'