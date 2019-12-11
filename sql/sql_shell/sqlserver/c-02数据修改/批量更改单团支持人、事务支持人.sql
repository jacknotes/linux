select JiDiao,introducer,Sales,* from tbTravelBudget
where TrvId in 
(23466,23500,23052,23350,23356,23353,22900,23420)
select * from tbTrvCoup
where TrvId in 
(23466,23500,23052,23350,23356,23353,22900,23420)

update tbTravelBudget set JiDiao=''
where TrvId in 
(23466,23500,23052,23350,23356,23353,22900,23420)
update tbTrvCoup set JiDiao=''
where TrvId in 
(23466,23500,23052,23350,23356,23353,22900,23420)


select JiDiao,introducer,Sales,Emppwd.idnumber,* from tbTravelBudget
inner join Emppwd on Emppwd.empname=tbTravelBudget.Sales
where TrvId in 
('22899','23524','23474','23478','23437','23436','23407','23361','23338','23319','23287','23058','23238','23489','23490','23508','23537','23204','23082','23201','23406','23326','23487','23488','23531','23720')
order by trvid

update tbTravelBudget 
set introducer=tbTravelBudget.Sales+'-'+Emppwd.idnumber+'-ÔËÓª²¿'
from tbTravelBudget
left join Emppwd on Emppwd.empname=tbTravelBudget.Sales
where TrvId in 
('22899','23524','23474','23478','23437','23436','23407','23361','23338','23319','23287','23058','23238','23489','23490','23508','23537','23204','23082','23201','23406','23326','23487','23488','23531','23720')

