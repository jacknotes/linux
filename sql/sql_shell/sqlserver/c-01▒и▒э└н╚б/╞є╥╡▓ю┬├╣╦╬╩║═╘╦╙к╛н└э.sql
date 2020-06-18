--修改企业差旅顾问和运营经理
select t.Cmpid as 单位编号,Name as 单位名称,t1.TcName as 差旅顾问,t2.MaintainName as 运营经理
from homsomDB..Trv_UnitCompanies t
left join Topway..HM_AgreementCompanyTC t1 on t1.Cmpid=t.Cmpid and t1.TcName='张超'
left join Topway..HM_ThePreservationOfHumanInformation t2 on t2.CmpId=t.Cmpid and t2.MaintainName='邵雪梅'
where t1.TcName='张超' and t2.MaintainName='邵雪梅' and t2.IsDisplay='1' and t1.isDisplay='0'
and t.CooperativeStatus in('1','2','3')