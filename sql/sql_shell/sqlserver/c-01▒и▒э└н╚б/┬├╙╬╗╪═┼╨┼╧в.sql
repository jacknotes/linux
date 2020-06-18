select TrvId as 预算单号,TrvCpName as 产品线路,PerNum as 人数,StartDate as 出发日期,EndDate as 返程日期
,left(REVERSE(SUBSTRING(REVERSE(Custinfo),1,CHARINDEX('@',REVERSE(Custinfo))+15)),3) as 经办人,left(REVERSE(SUBSTRING(REVERSE(Custinfo),1,CHARINDEX('@',REVERSE(Custinfo))+11)),11) as 经办人联系方式
,t1.Cmpid as 单位编号
,t3.cmpname as 单位名称,TrvCpBak as 备注
from tbTravelBudget t1
left join tbCusholderM t2 on t2.custid=t1.Custid
left join tbCusholderM t4 on t4.custid=t1.Custid
left join tbCompanyM t3 on t3.cmpid=t1.Cmpid
where EndDate>='2018-05-28' and t1.Status	<>2 and TrvType not like ('%5%')
