select c.pasname as 乘客姓名,c.begdate as 起飞日期, c.route as 行程 from Topway..tbcash c
left join Topway..tbCusholderM t on t.custid=c.custid
where cmpcode='016448' and datetime>='2018-01-01' and inf='1'


select * from Topway..tbCompanyM where cmpid='016448'

select * from Topway..tbCusholderM where cmpid='016448' 

(SELECT * FROM homsomDB..Trv_Human h
LEFT JOIN homsomDB..Trv_UnitPersons u ON h.ID=u.ID
LEFT JOIN homsomDB..Trv_Credentials c ON h.ID=c.HumanID
WHERE h.IsDisplay=1 AND u.CompanyID='016448')