
select a.pasname as 名字,a.idno as 证件号,a.nclass as 舱位 from 
tbcash as a 
left join tbFiveCoupInfo as b on a.coupno=b.CoupNo 
left join tbFiveCoupInfosub as c on c.FkfiveNo=b.fiveno 
where inf=1 and (c.tair='MU' or c.tair='FM')
and a.datetime>='2015-07-01' and a.datetime<'2016-09-01' 
