select * from tbDisctCommission where  id= 55366
update tbDisctCommission set CommissionStatus=3 where id= 55366

select * from tbcash where (dsettleno = 55366)
update tbcash set sdisct=0,dsettleno='' where (dsettleno = 55366)

select * from tbconventioncoup where(dsettleno = 55366)
update tbconventioncoup set sdisct=0,dsettleno='' where(dsettleno = 55366)