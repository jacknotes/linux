
select a.pasname as ����,a.idno as ֤����,a.nclass as ��λ from 
tbcash as a 
left join tbFiveCoupInfo as b on a.coupno=b.CoupNo 
left join tbFiveCoupInfosub as c on c.FkfiveNo=b.fiveno 
where inf=1 and (c.tair='MU' or c.tair='FM')
and a.datetime>='2015-07-01' and a.datetime<'2016-09-01' 
