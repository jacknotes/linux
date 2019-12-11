select uc.Cmpid as 单位编号,uc.Name as 单位名称,COUNT(*) as 下单数 from homsomDB..Trv_CompanyTravels t1
left join homsomDB..Trv_UnitCompanies uc on uc.ID=t1.UnitCompanyID
left join  homsomDB..Trv_ItktBookings t2 on t1.ID=t2.TravelID
left join homsomDB..Trv_TktBookings t3 on t2.ID=t3.ID
where t3.AdminStatus in (5) and t3.CreateDate>='2018-05-01' and t3.CreateDate<'2018-06-01'
and uc.Cmpid in 
('019688','019718','016258','019321','017290','020025','009005','016290','017977','018271','017949','018094','018113','019850','018732','020054','016278','019722','018131','018670')
group by uc.Cmpid,uc.Name


